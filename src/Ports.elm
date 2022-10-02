port module Ports exposing (storeScore)

import Json.Encode as Encode


port storeScore : String -> Cmd msg
