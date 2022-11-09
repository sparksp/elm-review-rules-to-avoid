module NoSingleLineRecords exposing (rule)

{-|

@docs rule

-}

import Elm.Syntax.Declaration as Declaration exposing (Declaration)
import Elm.Syntax.Node as Node exposing (Node(..))
import Elm.Syntax.Range as Range exposing (Range)
import Elm.Syntax.TypeAnnotation as TypeAnnotation exposing (TypeAnnotation)
import Review.Fix as Fix exposing (Fix)
import Review.Rule as Rule exposing (Rule)


{-| Reports record definitions in type aliases that are written on a single line.

    config =
        [ NoSingleLineRecords.rule
        ]


## Fail

    type alias Person =
        { name : String, age : Int, address : Address }


## Success

    type alias Person =
        { name : String
        , age : Int
        , address : Address
        }


## When (not) to enable this rule

You don't ever need to enable this rule. This is a code style that can easily be reviewed manually as appropriate.


## Try it out

You can try this rule out by running the following command:

```bash
elm-review --template sparksp/elm-review-rules-to-avoid/preview --rules NoSingleLineRecords
```

-}
rule : Rule
rule =
    Rule.newModuleRuleSchema "NoSingleLineRecords" ()
        |> Rule.withSimpleDeclarationVisitor declarationVisitor
        |> Rule.providesFixesForModuleRule
        |> Rule.fromModuleRuleSchema


declarationVisitor : Node Declaration -> List (Rule.Error {})
declarationVisitor declaration =
    case Node.value declaration of
        Declaration.AliasDeclaration { typeAnnotation } ->
            aliasDeclarationVisitor typeAnnotation

        _ ->
            []


aliasDeclarationVisitor : Node TypeAnnotation -> List (Rule.Error {})
aliasDeclarationVisitor (Node range typeAnnotation) =
    case ( typeAnnotation, linesInRange range ) of
        ( TypeAnnotation.Record _, 1 ) ->
            [ singleLineRecordError range ]

        ( TypeAnnotation.GenericRecord _ _, 1 ) ->
            [ singleLineRecordError range ]

        _ ->
            []


singleLineRecordError : Range -> Rule.Error {}
singleLineRecordError range =
    Rule.errorWithFix
        { message = "Record not formatted over multiple lines"
        , details = [ "Records in type aliases should be formatted on multiple lines to help the reader." ]
        }
        range
        [ insertNewLineBefore range.end ]


insertNewLineBefore : Range.Location -> Fix
insertNewLineBefore location =
    Fix.insertAt (columnBefore location) "\n"


linesInRange : Range -> Int
linesInRange { start, end } =
    start.row - end.row + 1


columnBefore : Range.Location -> Range.Location
columnBefore =
    mapColumn (\x -> x - 1)


mapColumn : (Int -> Int) -> Range.Location -> Range.Location
mapColumn mapper location =
    { location | column = mapper location.column }
