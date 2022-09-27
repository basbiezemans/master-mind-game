module MasterMindTests exposing (..)

import Expect
import Feedback exposing (makeFeedback)
import Guess exposing (Guess(..))
import Secret exposing (Secret(..))
import Test exposing (..)
import Utils exposing (unequal)


-- Unequal pairs

unequality : Test
unequality =
    let
        pairs  = [(6,1), (1,1), (6,3), (3,6)]
        answer = [(6,1), (6,3), (3,6)]
    in
    test "The unequal function filters out equal pairs." <|
        \_ ->
            unequal pairs
                |> Expect.equal answer


-- Feedback to Code Breaker

feedbackInclusionTest : Test
feedbackInclusionTest =
    let
        secret = Secret.fromList [6, 2, 4, 3]
        guess  = Guess.fromList  [1, 2, 3, 4] -- 2, 3 and 4 are included, 2 also has the correct position
        answer = { correct = 1
                 , present = 2 }
    in
    test "Correct digits should not be selected as included." <|
        \_ ->
            makeFeedback secret guess
                |> Expect.equal answer

-- When there are duplicate digits in the guess, they cannot all be awarded a key bit
-- unless they correspond to the same number of duplicate digits in the hidden code.

feedbackDuplicatesTest1 : Test
feedbackDuplicatesTest1 =
    let
        secret = Secret.fromList [6, 2, 4, 3]
        guess  = Guess.fromList  [6, 2, 2, 5]
        answer = { correct = 2
                 , present = 0 }
    in
    test "Feedback: duplicates test 1." <|
        \_ ->
            makeFeedback secret guess
                |> Expect.equal answer

feedbackDuplicatesTest2 : Test
feedbackDuplicatesTest2 =
    let
        secret = Secret.fromList [5, 2, 5, 6]
        guess  = Guess.fromList  [2, 2, 4, 4]
        answer = { correct = 1
                 , present = 0 }
    in
    test "Feedback: duplicates test 2." <|
        \_ ->
            makeFeedback secret guess
                |> Expect.equal answer

feedbackDuplicatesTest3 : Test
feedbackDuplicatesTest3 =
    let
        secret = Secret.fromList [6, 4, 4, 3]
        guess  = Guess.fromList  [4, 1, 2, 4]
        answer = { correct = 0
                 , present = 2 }
    in
    test "Feedback: duplicates test 3." <|
        \_ ->
            makeFeedback secret guess
                |> Expect.equal answer

feedbackDuplicatesTest4 : Test
feedbackDuplicatesTest4 =
    let
        secret = Secret.fromList [6, 4, 2, 3]
        guess  = Guess.fromList  [2, 2, 5, 2]
        answer = { correct = 0
                 , present = 1 }
    in
    test "Feedback: duplicates test 4." <|
        \_ ->
            makeFeedback secret guess
                |> Expect.equal answer

feedbackDuplicatesTest5 : Test
feedbackDuplicatesTest5 =
    let
        secret = Secret.fromList [6, 1, 6, 3]
        guess  = Guess.fromList  [1, 1, 3, 6]
        answer = { correct = 1
                 , present = 2 }
    in
    test "Feedback: duplicates test 5." <|
        \_ ->
            makeFeedback secret guess
                |> Expect.equal answer
