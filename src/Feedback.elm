module Feedback exposing (Feedback, makeFeedback, toList, toString)

import Code exposing (Code(..))
import Multiset
import Utils exposing (unequal, zip)


type alias Feedback =
    { correct : Int -- Number of digits that are guessed correctly.
    , present : Int -- Number of digits that are present in the code but in the wrong position.
    }


{-| Take a secret code and a guess, and return feedback which
shows how many digits are correct and/or present in the guess
-}
makeFeedback : Code -> Code -> Feedback
makeFeedback code1 code2 =
    let
        pairs =
            listOfPairs code1 code2
    in
    Feedback (numCorrect pairs) (numPresent <| unequal pairs)


numCorrect : List ( Int, Int ) -> Int
numCorrect pairs =
    List.length pairs - List.length (unequal pairs)


numPresent : List ( Int, Int ) -> Int
numPresent pairs =
    let
        ( code1, code2 ) =
            List.unzip pairs

        mset1 =
            Multiset.fromList code1

        mset2 =
            Multiset.fromList code2
    in
    Multiset.size <| Multiset.intersect mset1 mset2


listOfPairs : Code -> Code -> List ( Int, Int )
listOfPairs code1 code2 =
    zip (Code.toList code1) (Code.toList code2)


toString : Feedback -> String
toString feedback =
    let
        correct =
            String.repeat feedback.correct "●"

        present =
            String.repeat feedback.present "○"
    in
    correct ++ present


toList : Feedback -> List Int
toList feedback =
    let
        correct =
            List.repeat feedback.correct 1

        present =
            List.repeat feedback.present 0
    in
    correct ++ present
