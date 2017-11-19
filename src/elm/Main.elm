module Main exposing (..)

import Navigation exposing (Location)
import UrlParser exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import ListPage


type Route
    = RouteHome


type Page
    = PageHome


type Action
    = OnLocationChanged Location
    | OnListPage ListPage.Action


type alias Model =
    { activePage : Page
    , listModel : ListPage.Model
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
            let
                ( model, action ) =
                    ListPage.init "test"
            in
                ( { activePage = PageHome, listModel = model }, Cmd.map OnListPage action )


update : Action -> Model -> ( Model, Cmd Action )
update action model =
    case action of
        OnLocationChanged location ->
            init location

        OnListPage subaction ->
            let
                ( pageModel, pageAction ) =
                    ListPage.update subaction model.listModel
            in
                ( { model | listModel = pageModel }, Cmd.map OnListPage pageAction )


view : Model -> Html Action
view model =
    case model.activePage of
        PageHome ->
            div [ class "container-fluid" ]
                [ ListPage.view model.listModel |> Html.map OnListPage ]


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
