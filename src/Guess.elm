module Guess exposing (..)

import Array exposing (Array(..))


type Guess
    = Guess (Array Int)


fromList : List Int -> Guess
fromList list =
    Guess <| Array.fromList list


toList : Guess -> List Int
toList (Guess array) =
    Array.toList array


length : Guess -> Int
length (Guess array) =
    Array.length array


push : Int -> Guess -> Guess
push digit (Guess array) =
    if Array.length array < 4 then
        Guess <| Array.push digit array

    else
        Guess array


pop : Guess -> Guess
pop (Guess array) =
    Guess <| Array.slice 0 -1 array


empty : Guess
empty =
    Guess Array.empty


isEmpty : Guess -> Bool
isEmpty (Guess array) =
    Array.isEmpty array


isReady : Guess -> Bool
isReady (Guess array) =
    Array.length array == 4


toString : Guess -> String
toString (Guess array) =
    array
        |> Array.map String.fromInt
        |> Array.foldr (++) ""
