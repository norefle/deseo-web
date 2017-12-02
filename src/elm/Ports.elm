port module Ports exposing (..)

import Json.Encode


port login : String -> Cmd msg


port logout : String -> Cmd msg


port authenticated : (Bool -> msg) -> Sub msg


port user : (Json.Encode.Value -> msg) -> Sub msg
