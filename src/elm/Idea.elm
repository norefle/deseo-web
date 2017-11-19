module Idea exposing (..)

import Price exposing (Price)


init : Title -> Idea
init title =
    { id = ""
    , title = title
    , description = ""
    , url = ""
    , image = ""
    , priority = 0
    , price = 0
    , added = "2017-11-04T16:00:00.000+0000"
    , status = True
    }


type alias Idea =
    { id : Id
    , title : Title
    , description : Description
    , url : Url
    , image : Image
    , priority : Priority
    , price : Price
    , added : Date
    , status : Status
    }


type alias Id =
    String


type alias Title =
    String


type alias Description =
    String


type alias Url =
    String


type alias Image =
    String


type alias Priority =
    Int


type alias Date =
    String


type alias Status =
    Bool
