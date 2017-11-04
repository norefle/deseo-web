module Main exposing (..)

import Navigation exposing (Location)
import UrlParser exposing (..)
import Http exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import IdeaCard as Card
import Idea exposing (Idea)
import Api


type Route
    = RouteHome


type Page
    = PageHome


type Action
    = OnLocationChanged Location
    | OnCard Card.Action
    | OnApi Api.Event


type alias Model =
    { page : Page
    , error : String
    , ideas : List Idea
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
            ( { page = PageHome, ideas = [], error = "" }, Cmd.map OnApi (Api.listWishes "test") )


update : Action -> Model -> ( Model, Cmd Action )
update action model =
    case action of
        OnLocationChanged location ->
            init location

        OnCard _ ->
            ( model, Cmd.none )

        OnApi (Api.ReceivedWishes (Err error)) ->
            ( { model | error = (toString error) }, Cmd.none )

        OnApi (Api.ReceivedWishes (Ok response)) ->
            ( { model | ideas = response.wishes }, Cmd.none )


view : Model -> Html Action
view model =
    case model.page of
        PageHome ->
            div [ class "container-fluid" ]
                [ div [ class "row" ]
                    (model.ideas
                        |> List.map cards
                    )
                ]


cards : Idea -> Html Action
cards idea =
    div [ class "col-12 mt-3" ]
        [ Html.map OnCard (Card.view (Card.init idea))
        ]


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
