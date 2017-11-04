module Api exposing (..)

import Http
import Json.Decode as Decode
import Json.Decode.Pipeline as Pipeline
import User exposing (User)
import Idea exposing (Idea)


type Event
    = ReceivedWishes (Result Http.Error WishesResponse)



{- GET lists for user -}


type alias WishesResponse =
    { success : Bool
    , wishes : List Idea
    }


listWishes : User -> Cmd Event
listWishes user =
    Http.get ("/api/v1/list/" ++ user) decodeWishesResponse
        |> Http.send ReceivedWishes


decodeWishesResponse : Decode.Decoder WishesResponse
decodeWishesResponse =
    Pipeline.decode WishesResponse
        |> Pipeline.required "success" Decode.bool
        |> Pipeline.optional "data" (Decode.list decodeIdea) []


decodeIdea : Decode.Decoder Idea
decodeIdea =
    Pipeline.decode Idea
        |> Pipeline.required "_id" Decode.string
        |> Pipeline.required "title" Decode.string
        |> Pipeline.optional "description" Decode.string ""
        |> Pipeline.optional "url" Decode.string ""
        |> Pipeline.required "image" Decode.string
        |> Pipeline.optional "priority" Decode.int 0
        |> Pipeline.required "price" Decode.int
        |> Pipeline.required "date" Decode.string
        |> Pipeline.optional "status" Decode.bool False
