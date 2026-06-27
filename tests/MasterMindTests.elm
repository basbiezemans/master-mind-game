module MasterMindTests exposing (feedbackTest, unequalTest)

import Expect
import Feedback exposing (makeFeedback)
import Guess exposing (Guess(..))
import Secret exposing (Secret(..))
import Test exposing (..)
import Utils exposing (unequal)



-- Unequal pairs


unequalTest : Test
unequalTest =
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


testSingleCase : ( List Int, List Int, Feedback.Feedback ) -> Test
testSingleCase ( code1, code2, feedback ) =
    let
        secret =
            Secret.fromList code1

        guess =
            Guess.fromList code2

        makeFeedbackTestCase =
            String.join " "
                [ "makeFeedback"
                , Secret.toString secret
                , Guess.toString guess
                , "=="
                , Feedback.toString feedback
                ]
    in
    test makeFeedbackTestCase <|
        \_ -> makeFeedback secret guess |> Expect.equal feedback


testCases : List ( List Int, List Int, Feedback.Feedback )
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


feedbackTest : Test
feedbackTest =
    describe "The makeFeedback function should return the correct feedback."
        (List.map testSingleCase testCases)
