module Feedback exposing (Feedback, makeFeedback, toString)

import Guess exposing (Guess(..))
import Secret exposing (Secret(..))
import Utils exposing (delete, elem, unequal, zip)


type alias Feedback =
    { correct : Int -- Number of digits that are guessed correctly.
    , present : Int -- Number of digits that are present in the code but in the wrong position.
    }



-- Take a secret code and a guess, and return feedback which
-- shows how many digits are correct and/or present in the guess.


makeFeedback : Secret -> Guess -> Feedback
makeFeedback secret guess =
    let
        pairs =
            listOfPairs secret guess
    in
    Feedback (numCorrect pairs) (numPresent <| unequal pairs)


numCorrect : List ( Int, Int ) -> Int
numCorrect pairs =
    List.length pairs - List.length (unequal pairs)


countNumPresent : Int -> ( Int, List Int ) -> ( Int, List Int )
countNumPresent digit ( tally, secret ) =
    if elem digit secret then
        ( tally + 1, delete digit secret )

    else
        ( tally, secret )


numPresent : List ( Int, Int ) -> Int
numPresent pairs =
    let
        ( secret, digits ) =
            List.unzip pairs
    in
    Tuple.first <| List.foldl countNumPresent ( 0, secret ) digits


listOfPairs : Secret -> Guess -> List ( Int, Int )
listOfPairs secret guess =
    zip (Secret.toList secret) (Guess.toList guess)


toString : Feedback -> String
toString feedback =
    let
        correct =
            String.repeat feedback.correct "●"

        present =
            String.repeat feedback.present "○"
    in
    correct ++ present
