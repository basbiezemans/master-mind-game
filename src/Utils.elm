module Utils exposing (..)

import List exposing (any, filter)
import Tuple exposing (first, second)


elem : comparable -> List comparable -> Bool
elem x xs =
    any ((==) x) xs


delete : comparable -> List comparable -> List comparable
delete x xs =
    deleteBy (==) x xs


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


flip : (a -> b -> c) -> b -> a -> c
flip function x y =
    function y x


zip : List a -> List b -> List ( a, b )
zip xs ys =
    List.map2 Tuple.pair xs ys


uncurry : (a -> b -> c) -> (( a, b ) -> c)
uncurry function args =
    function (first args) (second args)


unequal : List ( comparable, comparable ) -> List ( comparable, comparable )
unequal pairs =
    filter (uncurry (/=)) pairs


maybe : b -> (a -> b) -> Maybe a -> b
maybe defaultVal function maybeVal =
    case maybeVal of
        Nothing ->
            defaultVal

        Just val ->
            function val


listPadRight : a -> Int -> List a -> List a
listPadRight value n xs =
    let
        ys =
            List.take n xs
    in
    ys ++ List.repeat (n - List.length xs) value
