module Utils exposing (..)

-- Library for generic functions

import List exposing (any, filter)
import Tuple exposing (first, second)


{-| Determine whether an element occurs in a list
-}
elem : comparable -> List comparable -> Bool
elem x xs =
    any ((==) x) xs


{-| Remove the first occurrence of an element from a list
-}
delete : comparable -> List comparable -> List comparable
delete x xs =
    deleteBy (==) x xs


{-| Remove the first occurrence of an element from a list
using an equality predicate
-}
deleteBy : (a -> a -> Bool) -> a -> List a -> List a
deleteBy equal x xs =
    case xs of
        [] ->
            []

        y :: ys ->
            if equal x y then
                ys

            else
                y :: deleteBy equal x ys


{-| Reverse the first two arguments of a function
-}
flip : (a -> b -> c) -> b -> a -> c
flip function x y =
    function y x


{-| Take two lists and return a list of corresponding pairs
-}
zip : List a -> List b -> List ( a, b )
zip xs ys =
    List.map2 Tuple.pair xs ys


{-| Convert a curried function to a function on pairs
-}
uncurry : (a -> b -> c) -> (( a, b ) -> c)
uncurry function args =
    function (first args) (second args)


{-| Return the unequal pairs from a list of pairs
-}
unequal : List ( comparable, comparable ) -> List ( comparable, comparable )
unequal pairs =
    filter (uncurry (/=)) pairs


{-| Apply a function to the value inside a Just and return the result
or return the default value if the Maybe value is Nothing
-}
maybe : b -> (a -> b) -> Maybe a -> b
maybe defaultVal function maybeVal =
    case maybeVal of
        Nothing ->
            defaultVal

        Just val ->
            function val


{-| Pad a list with elements of a given value until length n is reached
-}
listPadRight : a -> Int -> List a -> List a
listPadRight value n xs =
    let
        ys =
            List.take n xs
    in
    ys ++ List.repeat (n - List.length xs) value
