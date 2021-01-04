module Tests.NoNothingToNothing exposing (all)

import Dependencies.ElmCore
import Elm.Project
import Json.Decode as Decode
import NoNothingToNothing exposing (rule)
import Review.Project as Project exposing (Project)
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
                    |> Review.Test.runWithProjectData project rule
                    |> Review.Test.expectErrors
                        [ Review.Test.error
                            { message = "`Nothing` mapped to `Nothing` in case expression"
                            , details = [ "Do not map a `Nothing` to `Nothing` with a case expression. Use `Maybe.andThen` or `Maybe.map` instead." ]
                            , under = "Nothing"
                            }
                            |> Review.Test.atExactly { start = { row = 6, column = 9 }, end = { row = 6, column = 16 } }
                        ]
        , test "should report an error when a case matches and returns Maybe.Nothing" <|
            \() ->
                """module Greet exposing (greet)

greet : Maybe String -> Maybe String
greet maybeName =
    case maybeName of
        Maybe.Nothing ->
            Maybe.Nothing

        Maybe.Just name ->
            Maybe.Just ("Hello " ++ name)
"""
                    |> Review.Test.runWithProjectData project rule
                    |> Review.Test.expectErrors
                        [ Review.Test.error
                            { message = "`Nothing` mapped to `Nothing` in case expression"
                            , details = [ "Do not map a `Nothing` to `Nothing` with a case expression. Use `Maybe.andThen` or `Maybe.map` instead." ]
                            , under = "Maybe.Nothing"
                            }
                            |> Review.Test.atExactly { start = { row = 6, column = 9 }, end = { row = 6, column = 22 } }
                        ]
        , test "should report an error when Maybe is aliased" <|
            \() ->
                """module Greet exposing (greet)
import Maybe as M
greet : Maybe String -> Maybe String
greet maybeName =
    case maybeName of
        M.Nothing ->
            M.Nothing

        M.Just name ->
            M.Just ("Hello " ++ name)
"""
                    |> Review.Test.runWithProjectData project rule
                    |> Review.Test.expectErrors
                        [ Review.Test.error
                            { message = "`Nothing` mapped to `Nothing` in case expression"
                            , details = [ "Do not map a `Nothing` to `Nothing` with a case expression. Use `Maybe.andThen` or `Maybe.map` instead." ]
                            , under = "M.Nothing"
                            }
                            |> Review.Test.atExactly { start = { row = 6, column = 9 }, end = { row = 6, column = 18 } }
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
                    |> Review.Test.runWithProjectData project rule
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
                    |> Review.Test.runWithProjectData project rule
                    |> Review.Test.expectNoErrors
        ]



--- TEST PROJECT DATA


project : Project
project =
    Project.new
        |> Project.addElmJson (createElmJson applicationElmJson)
        |> Project.addDependency Dependencies.ElmCore.dependency


createElmJson : String -> { path : String, raw : String, project : Elm.Project.Project }
createElmJson rawElmJson =
    case Decode.decodeString Elm.Project.decoder rawElmJson of
        Ok elmJson ->
            { path = "elm.json"
            , raw = rawElmJson
            , project = elmJson
            }

        Err err ->
            Debug.todo ("Invalid elm.json supplied to test: " ++ Debug.toString err)


applicationElmJson : String
applicationElmJson =
    """
{
    "type": "application",
    "source-directories": [
        "src"
    ],
    "elm-version": "0.19.1",
    "dependencies": {
        "direct": {
            "elm/core": "1.0.5"
        },
        "indirect": {}
    },
    "test-dependencies": {
        "direct": {},
        "indirect": {}
    }
}"""
