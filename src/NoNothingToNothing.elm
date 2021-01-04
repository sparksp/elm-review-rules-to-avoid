module NoNothingToNothing exposing (rule)

{-|

@docs rule

-}

import Elm.Syntax.Expression as Expression exposing (Expression)
import Elm.Syntax.Node as Node exposing (Node)
import Elm.Syntax.Pattern as Pattern exposing (Pattern)
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
    Rule.newModuleRuleSchema "NoNothingToNothing" ()
        |> Rule.withSimpleExpressionVisitor expressionVisitor
        |> Rule.fromModuleRuleSchema


expressionVisitor : Node Expression -> List (Rule.Error {})
expressionVisitor expression =
    case Node.value expression of
        Expression.CaseExpression { cases } ->
            List.foldr caseVisitor [] cases

        _ ->
            []


caseVisitor : ( Node Pattern, Node Expression ) -> List (Rule.Error {}) -> List (Rule.Error {})
caseVisitor ( pattern, expression ) errors =
    case ( parseNothingPattern pattern, parseNothingExpression expression ) of
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


parseNothingPattern : Node Pattern -> IsNothing
parseNothingPattern pattern =
    case Node.value pattern of
        Pattern.NamedPattern { moduleName, name } _ ->
            case ( moduleName, name ) of
                ( [], "Nothing" ) ->
                    IsNothing

                ( [ "Maybe" ], "Nothing" ) ->
                    IsNothing

                _ ->
                    NotNothing

        _ ->
            NotNothing


parseNothingExpression : Node Expression -> IsNothing
parseNothingExpression expression =
    case Node.value expression of
        Expression.FunctionOrValue [] "Nothing" ->
            IsNothing

        Expression.FunctionOrValue [ "Maybe" ] "Nothing" ->
            IsNothing

        _ ->
            NotNothing
