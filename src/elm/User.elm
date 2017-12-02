module User exposing (User, fromJson)

import Json.Decode as Decode
import Json.Decode.Pipeline as Pipeline


type alias User =
    { id : String
    , token : String
    }


fromJson : Decode.Decoder User
fromJson =
    Pipeline.decode User
        |> Pipeline.required "user" Decode.string
        |> Pipeline.required "token" Decode.string
