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
        ]
