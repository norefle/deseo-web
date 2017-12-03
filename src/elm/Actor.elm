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


lorem : String
lorem =
    """
Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor
incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud
exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute
irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla
pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia
deserunt mollit anim id est laborum.

Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium
doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore
veritatis et quasi architecto beatae vitae dicta sunt explicabo. Nemo enim ipsam
voluptatem quia voluptas sit aspernatur aut odit aut fugit, sed quia consequuntur
magni dolores eos qui ratione voluptatem sequi nesciunt. Neque porro quisquam est,
qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit, sed quia non
numquam eius modi tempora incidunt ut labore et dolore magnam aliquam quaerat
voluptatem. Ut enim ad minima veniam, quis nostrum exercitationem ullam corporis
suscipit laboriosam, nisi ut aliquid ex ea commodi consequatur? Quis autem vel eum
iure reprehenderit qui in ea voluptate velit esse quam nihil molestiae consequatur,
vel illum qui dolorem eum fugiat quo voluptas nulla pariatur?"""
