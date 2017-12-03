module Api exposing (..)

import Http
import Idea exposing (Idea)
import Json.Decode as Decode
import Json.Decode.Pipeline as Pipeline
import Json.Encode as Encode
import ListInfo exposing (ListInfo)
import User exposing (User)


type Event
    = ReceivedLists (Result Http.Error ListsResponse)
    | ReceivedWishes (Result Http.Error WishesResponse)
    | ReceivedPostAck (Result Http.Error PostResponse)



{- GET lists for user -}


type alias ListsResponse =
    { success : Bool
    , lists : List ListInfo
    }


listLists : User -> Cmd Event
listLists user =
    Http.get ("/api/v1/lists?user=" ++ user.id) decodeListResponse
        |> Http.send ReceivedLists


decodeListResponse : Decode.Decoder ListsResponse
decodeListResponse =
    Pipeline.decode ListsResponse
        |> Pipeline.required "success" Decode.bool
        |> Pipeline.optional "data" (Decode.list decodeListInfo) []


decodeListInfo : Decode.Decoder ListInfo
decodeListInfo =
    Pipeline.decode ListInfo
        |> Pipeline.required "_id" Decode.string
        |> Pipeline.required "list" Decode.string
        |> Pipeline.required "owner" Decode.string
        |> Pipeline.optional "readers" (Decode.list Decode.string) []
        |> Pipeline.optional "writers" (Decode.list Decode.string) []
        |> Pipeline.required "created" Decode.string



{- GET wishes for list -}


type alias WishesResponse =
    { success : Bool
    , wishes : List Idea
    }


listWishes : User -> ListInfo.Id -> Cmd Event
listWishes user listId =
    Http.get ("/api/v1/lists/" ++ listId ++ "?user=" ++ user.id) decodeWishesResponse
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


encodeIdea : Idea -> Encode.Value
encodeIdea idea =
    Encode.object
        [ ( "id", Encode.string idea.id )
        , ( "title", Encode.string idea.title )
        , ( "description", Encode.string idea.description )
        , ( "url", Encode.string idea.url )
        , ( "image", Encode.string idea.image )
        , ( "priority", Encode.int idea.priority )
        , ( "price", Encode.int idea.price )
        , ( "date", Encode.string idea.added )
        , ( "status", Encode.bool idea.status )
        ]



{- POST new idea for user -}


type alias PostResponse =
    { success : Bool
    , error : Maybe String
    }


addIdea : User -> ListInfo.Id -> Idea -> Cmd Event
addIdea user listId idea =
    Http.post
        ("/api/v1/lists/" ++ listId ++ "?user=" ++ user.id)
        (Http.jsonBody (encodeIdea idea))
        decodePostResponse
        |> Http.send ReceivedPostAck


decodePostResponse : Decode.Decoder PostResponse
decodePostResponse =
    Pipeline.decode PostResponse
        |> Pipeline.required "success" Decode.bool
        |> Pipeline.optional "error" (Decode.maybe Decode.string) Nothing



{- DELETE idea -}


delete : String -> Http.Body -> Decode.Decoder a -> Http.Request a
delete url body decoder =
    Http.request
        { method = "DELETE"
        , headers = []
        , url = url
        , body = body
        , expect = Http.expectJson decoder
        , timeout = Nothing
        , withCredentials = True
        }


deleteIdea : User -> ListInfo.Id -> Idea -> Cmd Event
deleteIdea user listId idea =
    delete
        ("/api/v1/lists/" ++ listId ++ "?user=" ++ user.id)
        (Http.jsonBody (encodeIdea idea))
        decodePostResponse
        |> Http.send ReceivedPostAck
