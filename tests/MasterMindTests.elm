module MasterMindTests exposing (testCodeIsValid, testFeedback, testUnequal)

import Code exposing (Code(..))
import Expect
import Feedback exposing (Feedback, makeFeedback)
import Test exposing (..)
import Utils exposing (unequal)



-- Unequal pairs


testUnequal : Test
testUnequal =
    let
        pairs =
            [ ( 6, 1 ), ( 1, 1 ), ( 6, 3 ), ( 3, 6 ) ]

        answer =
            [ ( 6, 1 ), ( 6, 3 ), ( 3, 6 ) ]
    in
    test "The unequal function filters out equal pairs." <|
        \_ ->
            unequal pairs
                |> Expect.equal answer



-- Feedback for Code Breaker


testSingleCase : ( List Int, List Int, Feedback ) -> Test
testSingleCase ( list1, list2, feedback ) =
    let
        code1 =
            Code.fromList list1

        code2 =
            Code.fromList list2

        makeFeedbackTestCase =
            String.join " "
                [ "makeFeedback"
                , Code.toString code1
                , Code.toString code2
                , "=="
                , Feedback.toString feedback
                ]
    in
    test makeFeedbackTestCase <|
        \_ -> makeFeedback code1 code2 |> Expect.equal feedback


testCases : List ( List Int, List Int, Feedback )
testCases =
    [ ( [ 1, 2, 3, 4 ], [ 1, 2, 3, 4 ], { correct = 4, present = 0 } )
    , ( [ 6, 2, 4, 3 ], [ 6, 2, 2, 5 ], { correct = 2, present = 0 } )
    , ( [ 5, 2, 5, 6 ], [ 2, 2, 4, 4 ], { correct = 1, present = 0 } )
    , ( [ 6, 2, 4, 3 ], [ 2, 4, 3, 6 ], { correct = 0, present = 4 } )
    , ( [ 1, 1, 1, 1 ], [ 2, 2, 2, 2 ], { correct = 0, present = 0 } )
    , ( [ 6, 4, 2, 3 ], [ 2, 2, 5, 2 ], { correct = 0, present = 1 } )
    , ( [ 6, 4, 4, 3 ], [ 4, 1, 2, 4 ], { correct = 0, present = 2 } )
    , ( [ 6, 1, 6, 3 ], [ 1, 1, 3, 6 ], { correct = 1, present = 2 } )
    , ( [ 1, 2, 3, 4 ], [ 2, 1, 3, 4 ], { correct = 2, present = 2 } )
    ]


testFeedback : Test
testFeedback =
    describe "The makeFeedback function should return the correct feedback."
        (List.map testSingleCase testCases)


testCodeIsValid : Test
testCodeIsValid =
    describe "The isValid function validates a given code."
        (List.map
            (\{ given, expected } ->
                test (Code.toString given) <|
                    \_ -> Expect.equal expected (Code.isValid given)
            )
            [ { given = Code.fromList [ 0, 1, 2, 3 ], expected = False }
            , { given = Code.fromList [ 1, 2, 3, 7 ], expected = False }
            , { given = Code.fromList [ 1, 2, 3 ], expected = False }
            , { given = Code.fromList [ 1, 2, 3, 4, 5 ], expected = False }
            , { given = Code.fromList [ 1, 2, 3, 6 ], expected = True }
            ]
        )
