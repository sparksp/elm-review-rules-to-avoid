module NoSingleFieldRecord exposing (rule)

{-|

@docs rule

-}

import Elm.Syntax.Declaration as Declaration exposing (Declaration)
import Elm.Syntax.Node as Node exposing (Node(..))
import Elm.Syntax.Signature exposing (Signature)
import Elm.Syntax.TypeAnnotation as TypeAnnotation exposing (TypeAnnotation)
import Review.Rule as Rule exposing (Rule)


{-| Reports records containing only a single field.

    config =
        [ NoSingleFieldRecord.rule
        ]


## Fail

    type alias SingleFieldRecord =
        { foo : String }

    singleFieldRecord : String -> { foo : String }
    singleFieldRecord foo =
        { foo = foo }

    foo : { r | foo : String } -> String
    foo r =
        r.foo


## Success

    type alias MultipleFieldRecord =
        { foo : String
        , bar : Int
        }


## When (not) to enable this rule

Using a record is obsolete if you only plan to store a single field in it. However, there are times when a single field may be desirable, for example:

  - Rapid development, when you're planning ahead and trying out data models.
  - When you're refactoring to or from a record you may need to step through a single record.
  - To match the pattern of similar data types and to make a predictable API.
  - When you're working with generic records matching only one field, e.g., `{ r | some : String }`. Although, these should be refactored to take one field.


## Try it out

You can try this rule out by running the following command:

```bash
elm-review --template sparksp/elm-review-rules-to-avoid/preview --rules NoSingleFieldRecord
```

-}
rule : Rule
rule =
    Rule.newModuleRuleSchema "NoSingleFieldRecord" ()
        |> Rule.withSimpleDeclarationVisitor declarationVisitor
        |> Rule.fromModuleRuleSchema


declarationVisitor : Node Declaration -> List (Rule.Error {})
declarationVisitor node =
    case Node.value node of
        Declaration.AliasDeclaration { typeAnnotation } ->
            errorsForTypeAnnotation typeAnnotation

        Declaration.FunctionDeclaration { signature } ->
            errorsForFunctionSignature signature

        _ ->
            []


errorsForFunctionSignature : Maybe (Node Signature) -> List (Rule.Error {})
errorsForFunctionSignature signature =
    case signature of
        Just (Node _ { typeAnnotation }) ->
            errorsForTypeAnnotation typeAnnotation

        _ ->
            []


errorsForTypeAnnotation : Node TypeAnnotation -> List (Rule.Error {})
errorsForTypeAnnotation typeAnnotation =
    case Node.value typeAnnotation of
        TypeAnnotation.Record [ _ ] ->
            [ Rule.error
                { message = "Record has only one field"
                , details = [ "You should use the field's type or introduce a custom Type." ]
                }
                (Node.range typeAnnotation)
            ]

        TypeAnnotation.GenericRecord _ (Node _ [ _ ]) ->
            [ Rule.error
                { message = "Record has only one field"
                , details = [ "You should use the field's type or introduce a custom Type." ]
                }
                (Node.range typeAnnotation)
            ]

        TypeAnnotation.FunctionTypeAnnotation left right ->
            errorsForTypeAnnotation left
                ++ errorsForTypeAnnotation right

        _ ->
            []
