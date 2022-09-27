module Secret exposing (..)

import Array exposing (Array(..))

type Secret = Secret (Array Int)

fromList : List Int -> Secret
fromList list =
    Secret <| Array.fromList list

toList : Secret -> List Int
toList (Secret array) =
    Array.toList array

zeroFill : Secret
zeroFill =
    Secret <| Array.repeat 4 0

toString : Secret -> String
toString (Secret digits) =
    digits
        |> Array.map String.fromInt
        |> Array.foldr (++) ""
