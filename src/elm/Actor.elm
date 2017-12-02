module Actor exposing (..)

import Json.Encode
import Json.Decode
import Html exposing (Html)
import Ports
import User exposing (User)


type Action
    = ReceivedUser Json.Encode.Value
    | ReceivedAuthenticated Bool


nope : model -> ( model, Cmd msg )
nope model =
    ( model, Cmd.none )


orNope : (a -> ( a, Cmd msg )) -> Maybe a -> ( Maybe a, Cmd msg )
orNope transform data =
    data
        |> Maybe.andThen (transform >> Just)
        |> Maybe.map (\( x, y ) -> ( Just x, y ))
        |> Maybe.withDefault ( Nothing, Cmd.none )


nothing : Html msg
nothing =
    Html.text ""


orNothing : (a -> Html msg) -> Maybe a -> Html msg
orNothing transform data =
    data
        |> Maybe.andThen (transform >> Just)
        |> Maybe.withDefault nothing


user : Json.Encode.Value -> Maybe User
user value =
    let
        parsed =
            Json.Decode.decodeValue User.fromJson value

        newUser =
            case parsed of
                Ok user ->
                    Just user

                Err error ->
                    Nothing
    in
        newUser


login : model -> ( model, Cmd msg )
login model =
    ( model, Ports.login "" )


logout : model -> ( model, Cmd msg )
logout model =
    ( model, Ports.logout "" )


subscribe : model -> Sub Action
subscribe model =
    Sub.batch
        [ Ports.user ReceivedUser
        , Ports.authenticated ReceivedAuthenticated
        ]
