module User exposing (..)

import Json.Decode as Decode
import Json.Decode.Pipeline as Pipeline


type alias User =
    { id : Id
    , token : Token
    }


type alias Id =
    String


type alias Token =
    String


fromJson : Decode.Decoder User
fromJson =
    Pipeline.decode User
        |> Pipeline.required "user" Decode.string
        |> Pipeline.required "token" Decode.string
