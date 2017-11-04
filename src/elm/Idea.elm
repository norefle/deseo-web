module Idea exposing (..)

import Price exposing (Price)


init : Idea
init =
    { id = "59fde065a486eea31caaf14c"
    , title = "Amazon Fire TV"
    , description = "Amazon Fir TV\n4K\nWant! Want! Want!"
    , url = "https://www.amazon.com/dp/B01N32NCPM"
    , image = "https://images-na.ssl-images-amazon.com/images/I/51AOKqohyVL._SL1000_.jpg"
    , priority = 0
    , price = 6999
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
