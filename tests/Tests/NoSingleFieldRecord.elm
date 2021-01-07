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
                        [ singleFieldRecordErrorUnder "{ foo : String }"
                        ]
        , test "does not report type alias records with more than one field" <|
            \() ->
                """
module A exposing (..)
type alias MultipleFieldRecord = { foo : String, bar : Int }
"""
                    |> Review.Test.run rule
                    |> Review.Test.expectNoErrors
        , test "should report a type alias generic record containing only 1 field" <|
            \() ->
                """
module A exposing (..)
type alias SingleFieldRecord = { r | foo : String }
"""
                    |> Review.Test.run rule
                    |> Review.Test.expectErrors
                        [ singleFieldRecordErrorUnder "{ r | foo : String }"
                        ]
        , test "does not report type alias generic records with more than one field" <|
            \() ->
                """
module A exposing (..)
type alias MultipleFieldRecord = { r | foo : String, bar : Int }
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
                        [ singleFieldRecordErrorUnder "{ foo : String }"
                        ]
        , test "should report an argument generic record containing only 1 field" <|
            \() ->
                """
module A exposing (..)
singleFieldRecord : { r | foo : String } -> String
singleFieldRecord { foo } =
    foo
"""
                    |> Review.Test.run rule
                    |> Review.Test.expectErrors
                        [ singleFieldRecordErrorUnder "{ r | foo : String }"
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
                        [ singleFieldRecordErrorUnder "{ foo : String }"
                        ]
        , test "should report a function returning a single field generic record" <|
            \() ->
                """
module A exposing (..)
singleFieldRecord : String -> { r | foo : String }
singleFieldRecord foo =
    { foo = foo }
"""
                    |> Review.Test.run rule
                    |> Review.Test.expectErrors
                        [ singleFieldRecordErrorUnder "{ r | foo : String }"
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
        , test "does not report argument generic records containing more than 1 field" <|
            \() ->
                """
module A exposing (..)
multipleFieldRecord : { r | foo : String, bar : Int } -> String
multipleFieldRecord { foo } =
    foo
"""
                    |> Review.Test.run rule
                    |> Review.Test.expectNoErrors
        , test "should report a single field record in a custom type" <|
            \() ->
                """
module A exposing (..)
type Foo
    = Foo { bar : String }
"""
                    |> Review.Test.run rule
                    |> Review.Test.expectErrors
                        [ singleFieldRecordErrorUnder "{ bar : String }"
                        ]
        , test "should report a single field generic record in a custom type" <|
            \() ->
                """
module A exposing (..)
type Foo a
    = Foo { a | bar : String }
"""
                    |> Review.Test.run rule
                    |> Review.Test.expectErrors
                        [ singleFieldRecordErrorUnder "{ a | bar : String }"
                        ]
        , test "does not report a records in custom types with more than 1 field" <|
            \() ->
                """
module A exposing (..)
type Foo
    = Foo { bish : String, bosh : Int }
"""
                    |> Review.Test.run rule
                    |> Review.Test.expectNoErrors
        , test "does not report generic records in a custom types with more than 1 field" <|
            \() ->
                """
module A exposing (..)
type Foo a
    = Foo { a | bish : String, bosh : Int }
"""
                    |> Review.Test.run rule
                    |> Review.Test.expectNoErrors
        ]


singleFieldRecordErrorUnder : String -> Review.Test.ExpectedError
singleFieldRecordErrorUnder under =
    Review.Test.error
        { message = "Record has only one field"
        , details = [ "You should use the field's type or introduce a custom Type." ]
        , under = under
        }
