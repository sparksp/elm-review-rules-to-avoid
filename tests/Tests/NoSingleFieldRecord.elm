module Tests.NoSingleFieldRecord exposing (all)

import NoSingleFieldRecord exposing (rule)
import Review.Test
import Test exposing (Test, describe, test)


all : Test
all =
    describe "NoSingleFieldRecord"
        [ test "should report a type alias record containing only 1 field" <|
            \() ->
                """
module A exposing (..)
type alias SingleFieldRecord = { foo : String }
"""
                    |> Review.Test.run rule
                    |> Review.Test.expectErrors
                        [ Review.Test.error
                            { message = "Record has only one field"
                            , details = [ "You should use the field's type or introduce a custom Type." ]
                            , under = "{ foo : String }"
                            }
                        ]
        , test "does not report type alias records with more than one field" <|
            \() ->
                """
module A exposing (..)
type alias MultipleFieldRecord = { foo : String, bar : Int }
"""
                    |> Review.Test.run rule
                    |> Review.Test.expectNoErrors
        , test "should report an argument record containing only 1 field" <|
            \() ->
                """
module A exposing (..)
singleFieldRecord : { foo : String } -> String
singleFieldRecord { foo } =
    foo
"""
                    |> Review.Test.run rule
                    |> Review.Test.expectErrors
                        [ Review.Test.error
                            { message = "Record has only one field"
                            , details = [ "You should use the field's type or introduce a custom Type." ]
                            , under = "{ foo : String }"
                            }
                        ]
        , test "should report a function returning a single field record" <|
            \() ->
                """
module A exposing (..)
singleFieldRecord : String -> { foo : String }
singleFieldRecord foo =
    { foo = foo }
"""
                    |> Review.Test.run rule
                    |> Review.Test.expectErrors
                        [ Review.Test.error
                            { message = "Record has only one field"
                            , details = [ "You should use the field's type or introduce a custom Type." ]
                            , under = "{ foo : String }"
                            }
                        ]
        , test "does not report argument records containing more than 1 field" <|
            \() ->
                """
module A exposing (..)
multipleFieldRecord : { foo : String, bar : Int } -> String
multipleFieldRecord { foo } =
    foo
"""
                    |> Review.Test.run rule
                    |> Review.Test.expectNoErrors
        ]
