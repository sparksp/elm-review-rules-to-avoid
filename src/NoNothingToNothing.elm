module NoNothingToNothing exposing (rule)

{-|

@docs rule

-}

import Elm.Syntax.Expression as Expression exposing (Expression)
import Elm.Syntax.Node as Node exposing (Node)
import Elm.Syntax.Pattern as Pattern exposing (Pattern)
import Review.ModuleNameLookupTable as ModuleNameLookupTable exposing (ModuleNameLookupTable)
import Review.Rule as Rule exposing (Rule)


{-| Reports case expressions where `Nothing` is matched and then `Nothing` is returned.

    config =
        [ NoNothingToNothing.rule
        ]


## Fail

    greet : Maybe String -> Maybe String
    greet maybeName =
        case maybeName of
            Nothing ->
                Nothing

            Just name ->
                Just ("Hello " ++ name)


## Success

    greet : Maybe String -> Maybe String
    greet maybeName =
        case maybeName of
            Nothing ->
                Just "Hello"

            Just name ->
                Just ("Hello " ++ name)


## When (not) to enable this rule

You don't need this rule. If you're writing code like this then there may be some wider code restructures to consider.


## Try it out

You can try this rule out by running the following command:

```bash
elm-review --template sparksp/elm-review-rules-to-avoid/preview --rules NoNothingToNothing
```

-}
rule : Rule
rule =
    Rule.newModuleRuleSchemaUsingContextCreator "NoNothingToNothing" contextCreator
        |> Rule.withExpressionEnterVisitor expressionVisitor
        |> Rule.fromModuleRuleSchema


type Context
    = Context ModuleNameLookupTable ()


contextCreator : Rule.ContextCreator () Context
contextCreator =
    Rule.initContextCreator
        Context
        |> Rule.withModuleNameLookupTable


expressionVisitor : Node Expression -> Context -> ( List (Rule.Error {}), Context )
expressionVisitor expression ((Context lookupTable ()) as context) =
    case Node.value expression of
        Expression.CaseExpression { cases } ->
            ( List.foldr (caseVisitor lookupTable) [] cases, context )

        _ ->
            ( [], context )


caseVisitor : ModuleNameLookupTable -> ( Node Pattern, Node Expression ) -> List (Rule.Error {}) -> List (Rule.Error {})
caseVisitor lookupTable ( pattern, expression ) errors =
    case ( parseNothingPattern lookupTable pattern, parseNothingExpression lookupTable expression ) of
        ( IsNothing, IsNothing ) ->
            Rule.error
                { message = "`Nothing` mapped to `Nothing` in case expression"
                , details = [ "Do not map a `Nothing` to `Nothing` with a case expression. Use `Maybe.andThen` or `Maybe.map` instead." ]
                }
                (Node.range pattern)
                :: errors

        _ ->
            errors


type IsNothing
    = IsNothing
    | NotNothing


parseNothingPattern : ModuleNameLookupTable -> Node Pattern -> IsNothing
parseNothingPattern lookupTable pattern =
    case Node.value pattern of
        Pattern.NamedPattern { name } _ ->
            case ( ModuleNameLookupTable.moduleNameFor lookupTable pattern, name ) of
                ( Just [ "Maybe" ], "Nothing" ) ->
                    IsNothing

                _ ->
                    NotNothing

        _ ->
            NotNothing


parseNothingExpression : ModuleNameLookupTable -> Node Expression -> IsNothing
parseNothingExpression lookupTable expression =
    case Node.value expression of
        Expression.FunctionOrValue _ "Nothing" ->
            case ModuleNameLookupTable.moduleNameFor lookupTable expression of
                Just [ "Maybe" ] ->
                    IsNothing

                _ ->
                    NotNothing

        _ ->
            NotNothing
