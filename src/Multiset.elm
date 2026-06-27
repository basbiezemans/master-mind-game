module Multiset exposing (fromList, intersect, size)

import Dict


type Multiset t
    = Multiset (Dict.Dict t Int)


empty : Multiset a
empty =
    Multiset Dict.empty


insert : comparable -> Multiset comparable -> Multiset comparable
insert key (Multiset dict) =
    case Dict.get key dict of
        Just value ->
            Multiset (Dict.insert key (value + 1) dict)

        Nothing ->
            Multiset (Dict.insert key 1 dict)


size : Multiset a -> Int
size (Multiset dict) =
    List.sum <| Dict.values dict


fromList : List comparable -> Multiset comparable
fromList list =
    List.foldl insert empty list


type alias DictTuple t =
    ( Dict.Dict t Int, Dict.Dict t Int )


minVal : comparable -> Int -> DictTuple comparable -> DictTuple comparable
minVal key val1 ( dict1, dict2 ) =
    case Dict.get key dict2 of
        Just val2 ->
            ( Dict.insert key (min val1 val2) dict1, dict2 )

        Nothing ->
            ( dict1, dict2 )


intersect : Multiset comparable -> Multiset comparable -> Multiset comparable
intersect (Multiset dict1) (Multiset dict2) =
    Dict.foldl minVal ( Dict.empty, dict2 ) dict1
        |> Tuple.first
        |> Multiset
