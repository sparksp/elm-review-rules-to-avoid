module Tests.NoFunctionInLet exposing (all)

import NoFunctionInLet exposing (rule)
import Review.Test
import Test exposing (Test, describe, test)


all : Test
all =
    describe "NoFunctionInLet"
        [ test "should report an error when a function is declared in a let statement" <|
            \() ->
                """module A exposing (..)
foo : Int -> Int
foo x =
    let
        somethingIShouldDefineOnTopLevel : Int -> Int
        somethingIShouldDefineOnTopLevel y =
            y + 1
    in
        somethingIShouldDefineOnTopLevel x
"""
                    |> Review.Test.run rule
                    |> Review.Test.expectErrors
                        [ letFunctionErrorUnder
                            "somethingIShouldDefineOnTopLevel : Int -> Int"
                            [ "        somethingIShouldDefineOnTopLevel y ="
                            , "            y + 1"
                            ]
                        ]
        , test "should report an error when a function having arguments with no type signature is declared in a let statement" <|
            \() ->
                """module A exposing (..)
foo : Int -> Int
foo x =
    let
        somethingIShouldDefineOnTopLevel y =
            y + 1
    in
        somethingIShouldDefineOnTopLevel x
"""
                    |> Review.Test.run rule
                    |> Review.Test.expectErrors
                        [ letFunctionErrorUnder
                            "somethingIShouldDefineOnTopLevel y ="
                            [ "            y + 1"
                            ]
                        ]
        , test "should report an error when a function with no arguments and having a function signature is present in a let statement" <|
            \() ->
                """module A exposing (..)
foo : Int -> Int
foo x =
    let
        add1 : Int -> Int
        add1 =
            (+) 1
    in
        add1 x
"""
                    |> Review.Test.run rule
                    |> Review.Test.expectErrors
                        [ letFunctionErrorUnder
                            "add1 : Int -> Int"
                            [ "        add1 ="
                            , "            (+) 1"
                            ]
                        ]
        , test "should not report an error when a constant is declared in a let statement" <|
            \() ->
                """module A exposing (..)
foo : Int -> Int
foo x =
    let
        y = 1
    in
        x + y
"""
                    |> Review.Test.run rule
                    |> Review.Test.expectNoErrors
        , test "should not report an error when a value is destructured in a let statement" <|
            \() ->
                """module A exposing (..)
foo : ( Int, Int ) -> Int
foo point =
    let
        ( x, y ) = point
    in
    x + y
"""
                    |> Review.Test.run rule
                    |> Review.Test.expectNoErrors
        ]


letFunctionErrorUnder : String -> List String -> Review.Test.ExpectedError
letFunctionErrorUnder first rest =
    Review.Test.error
        { message = "Function declared in let expression"
        , details =
            [ "In a let statement you can define variables and functions in their own scope, but you are already in the scope of a module. Just define the functions you want on a top-level. There is not much need to define functions in let statements."
            ]
        , under = String.join "\n" (first :: rest)
        }
