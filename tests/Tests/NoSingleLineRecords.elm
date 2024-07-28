module Tests.NoSingleLineRecords exposing (all)

import NoSingleLineRecords exposing (rule)
import Review.Test
import Test exposing (Test, describe, test)


all : Test
all =
    describe "NoSingleLineRecords"
        [ test "should report an error when a record is not formatted over multiple lines" <|
            \() ->
                """
module A exposing (Person)
type alias Person =
    { name : String, age : Int, address : Address }
"""
                    |> Review.Test.run rule
                    |> Review.Test.expectErrors
                        [ Review.Test.error
                            { message = "Record not formatted over multiple lines"
                            , details = [ "Records in type aliases should be formatted on multiple lines to help the reader." ]
                            , under = "{ name : String, age : Int, address : Address }"
                            }
                            |> Review.Test.whenFixed
                                (String.replace "}" "\n }" """
module A exposing (Person)
type alias Person =
    { name : String, age : Int, address : Address }
""")
                        ]
        , test "should not report an error when a record is split over multiple lines" <|
            \() ->
                """
module A exposing (Person)
type alias Person =
    { name : String
    , age : Int
    , address : Address
    }
"""
                    |> Review.Test.run rule
                    |> Review.Test.expectNoErrors
        , test "should not report an error when a single field record is split over multiple lines" <|
            \() ->
                """
module A exposing (Person)
type alias Person =
    { name : String
    }
"""
                    |> Review.Test.run rule
                    |> Review.Test.expectNoErrors
        , test "should report an error when an extensible record is not formatted over multiple lines" <|
            \() ->
                """
module A exposing (Person)
type alias Person p =
    { p | name : String, age : Int, address : Address }
"""
                    |> Review.Test.run rule
                    |> Review.Test.expectErrors
                        [ Review.Test.error
                            { message = "Record not formatted over multiple lines"
                            , details = [ "Records in type aliases should be formatted on multiple lines to help the reader." ]
                            , under = "{ p | name : String, age : Int, address : Address }"
                            }
                            |> Review.Test.whenFixed
                                (String.replace "}" "\n }" """
module A exposing (Person)
type alias Person p =
    { p | name : String, age : Int, address : Address }
""")
                        ]
        , test "should not report an error when a single field extensible record is split over multiple lines" <|
            \() ->
                """
module A exposing (Person)
type alias Person p =
    { p
        | name : String
        , age : Int
        , address : Address
    }
"""
                    |> Review.Test.run rule
                    |> Review.Test.expectNoErrors
        ]
