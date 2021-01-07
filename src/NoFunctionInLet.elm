module NoFunctionInLet exposing (rule)

{-|

@docs rule

-}

import Elm.Syntax.Expression as Expression exposing (Expression)
import Elm.Syntax.Node as Node exposing (Node(..))
import Elm.Syntax.TypeAnnotation as TypeAnnotation
import Review.Rule as Rule exposing (Rule)


{-| Reports functions declared in `let` expressions.

    config =
        [ NoFunctionInLet.rule
        ]


## Fail

    foo : Int -> Int
    foo x =
        let
            somethingIShouldDefineOnTopLevel : Int -> Int
            somethingIShouldDefineOnTopLevel y =
                y + 1
        in
        somethingIShouldDefineOnTopLevel x


## Success

    somethingIShouldDefineOnTopLevel : Int -> Int
    somethingIShouldDefineOnTopLevel y =
        y + 1

    foo : Int -> Int
    foo x =
        somethingIShouldDefineOnTopLevel x


## When (not) to enable this rule

Just don't enable this - whilst it's a good basic rule of thumb, there often needs to be much more to this review than this simple rule can account for.


## Try it out

You can try this rule out by running the following command:

```bash
elm-review --template sparksp/elm-review-rules-to-avoid/preview --rules NoFunctionInLet
```

-}
rule : Rule
rule =
    Rule.newModuleRuleSchema "NoFunctionInLet" ()
        |> Rule.withSimpleExpressionVisitor expressionVisitor
        |> Rule.fromModuleRuleSchema


expressionVisitor : Node Expression -> List (Rule.Error {})
expressionVisitor expression =
    case Node.value expression of
        Expression.LetExpression { declarations } ->
            letDeclarationListVisitor declarations

        _ ->
            []


letDeclarationListVisitor : List (Node Expression.LetDeclaration) -> List (Rule.Error {})
letDeclarationListVisitor declarations =
    List.filterMap letDeclarationError declarations


letDeclarationError : Node Expression.LetDeclaration -> Maybe (Rule.Error {})
letDeclarationError letDeclaration =
    parseFunction letDeclaration
        |> Maybe.map functionError


parseFunction : Node Expression.LetDeclaration -> Maybe Expression.Function
parseFunction letDeclaration =
    case Node.value letDeclaration of
        Expression.LetFunction function ->
            case function.signature of
                Just (Node _ { typeAnnotation }) ->
                    case typeAnnotation of
                        Node _ (TypeAnnotation.FunctionTypeAnnotation _ _) ->
                            Just function

                        _ ->
                            Nothing

                Nothing ->
                    case function |> .declaration |> Node.value |> .arguments of
                        _ :: _ ->
                            Just function

                        [] ->
                            Nothing

        _ ->
            Nothing


functionError : Expression.Function -> Rule.Error {}
functionError function =
    Rule.error
        { message = "Function declared in let expression"
        , details =
            [ "In a let statement you can define variables and functions in their own scope, but you are already in the scope of a module. Just define the functions you want on a top-level. There is not much need to define functions in let statements."
            ]
        }
        (Expression.functionRange function)
