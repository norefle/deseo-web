module Main exposing (..)

import Navigation exposing (Location)
import UrlParser exposing (..)
import Html exposing (Html)


type Route
    = RouteHome


type Page
    = PageHome


type Action
    = OnLocationChanged Location


type alias Model =
    { page : Page
    }


matchers : UrlParser.Parser (Route -> a) a
matchers =
    UrlParser.oneOf
        [ UrlParser.map RouteHome UrlParser.top
        ]


parseLocation : Location -> Route
parseLocation location =
    case (UrlParser.parseHash matchers location) of
        Just route ->
            route

        Nothing ->
            RouteHome


init : Location -> ( Model, Cmd Action )
init location =
    case parseLocation location of
        RouteHome ->
            ( { page = PageHome }, Cmd.none )


update : Action -> Model -> ( Model, Cmd Action )
update action model =
    case action of
        OnLocationChanged location ->
            init location


view : Model -> Html Action
view model =
    case model.page of
        PageHome ->
            Html.div [] [ Html.text "Elm!" ]


subscriptions : Model -> Sub Action
subscriptions model =
    Sub.none


main : Program Never Model Action
main =
    Navigation.program OnLocationChanged
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }
