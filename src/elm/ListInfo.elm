module ListInfo exposing (..)

import User


type alias ListInfo =
    { id : Id
    , name : String
    , owner : User.Id
    , readers : List User.Id
    , writers : List User.Id
    , created : String
    }


type alias Id =
    String
