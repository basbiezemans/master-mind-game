module Code exposing (..)

import Array exposing (Array(..))
import Random


type Code
    = Code (Array Int)


random : Random.Generator (List Int)
random =
    Random.list 4 (Random.int 1 6)


fromList : List Int -> Code
fromList list =
    Code <| Array.fromList list


toList : Code -> List Int
toList (Code array) =
    Array.toList array


length : Code -> Int
length (Code array) =
    Array.length array


push : Int -> Code -> Code
push digit (Code array) =
    if Array.length array < 4 then
        Code <| Array.push digit array

    else
        Code array


equal : Code -> Code -> Bool
equal (Code xs) (Code ys) =
    xs == ys


pop : Code -> Code
pop (Code array) =
    Code <| Array.slice 0 -1 array


empty : Code
empty =
    Code Array.empty


isEmpty : Code -> Bool
isEmpty (Code array) =
    Array.isEmpty array


isValid : Code -> Bool
isValid (Code array) =
    Array.length array == 4 -- TODO: proper validation


toString : Code -> String
toString (Code array) =
    array
        |> Array.map String.fromInt
        |> Array.foldr (++) ""
