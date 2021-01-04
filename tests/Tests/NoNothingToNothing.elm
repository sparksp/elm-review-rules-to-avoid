module Tests.NoNothingToNothing exposing (all)

import NoNothingToNothing exposing (rule)
import Review.Test
import Test exposing (Test, describe, test)


all : Test
all =
    describe "NoNothingToNothing"
        [ test "should report an error when a case matches and returns Nothing" <|
            \() ->
                """module Greet exposing (greet)

greet : Maybe String -> Maybe String
greet maybeName =
    case maybeName of
        Nothing ->
            Nothing

        Just name ->
            Just ("Hello " ++ name)
"""
                    |> Review.Test.run rule
                    |> Review.Test.expectErrors
                        [ Review.Test.error
                            { message = "`Nothing` mapped to `Nothing` in case expression"
                            , details = [ "Do not map a `Nothing` to `Nothing` with a case expression. Use `Maybe.andThen` or `Maybe.map` instead." ]
                            , under = "Nothing"
                            }
                            |> Review.Test.atExactly { start = { row = 6, column = 9 }, end = { row = 6, column = 16 } }
                        ]
        , test "should not report an error when a case matches Nothing and returns Just" <|
            \() ->
                """module Greet exposing (greet)

greet : Maybe String -> Maybe String
greet maybeName =
    case maybeName of
        Nothing ->
            Just "Hello"

        Just name ->
            Just ("Hello " ++ name)
"""
                    |> Review.Test.run rule
                    |> Review.Test.expectNoErrors
        , test "should not report an error when a case matches Nothing and returns a String" <|
            \() ->
                """module Greet exposing (greet)

greet : Maybe String -> String
greet maybeName =
    case maybeName of
        Nothing ->
            "Nothing"

        Just name ->
            "Just " ++ name
"""
                    |> Review.Test.run rule
                    |> Review.Test.expectNoErrors
        ]
