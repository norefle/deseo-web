module Header exposing (Action(..), Model, authenticate, init, update, view)

import Actor
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)


type Action
    = ReceivedAuthenticated Bool
    | RequestedLogOut


type alias Model =
    { authenticated : Bool
    }


authenticate : Model -> Bool -> Model
authenticate model value =
    { model | authenticated = value }


init : Bool -> Model
init authenticated =
    { authenticated = authenticated }


update : Action -> Model -> ( Model, Cmd Action )
update action model =
    case action of
        ReceivedAuthenticated status ->
            ( { model | authenticated = status }, Cmd.none )

        RequestedLogOut ->
            Actor.nope model


view : Model -> Html Action
view model =
    nav
        [ id "main-nav"
        , class "navbar navbar-expand-md navbar-dark bg-dark"
        ]
        [ a
            [ class "navbar-brand"
            , href "#"
            ]
            [ text "Wish lists" ]
        , if model.authenticated then
            logoutBtn
          else
            Actor.nothing
        ]


logoutBtn : Html Action
logoutBtn =
    a
        [ class "btn btn-dark float-right"
        , href "javascript:void(0)"
        , onClick RequestedLogOut
        ]
        [ text "Log out" ]
