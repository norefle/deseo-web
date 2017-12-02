module Main exposing (..)

import Actor
import Footer
import Header
import Html exposing (..)
import InitialPage
import Json.Decode
import ListPage
import Navigation exposing (Location)
import UrlParser exposing (..)
import User exposing (User)


type Route
    = RouteHome


type Page
    = PageHome
    | PageList


type Action
    = OnLocationChanged Location
    | OnActor Actor.Action
    | OnHeader Header.Action
    | OnFooter Never
    | OnInitialPage InitialPage.Action
    | OnListPage ListPage.Action


type alias Model =
    { user : Maybe User
    , header : Header.Model
    , activePage : Page
    , listModel : Maybe ListPage.Model
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


empty : Model
empty =
    { user = Nothing
    , header = Header.init False
    , activePage = PageHome
    , listModel = Nothing
    }


init : Location -> ( Model, Cmd Action )
init location =
    case parseLocation location of
        RouteHome ->
            Actor.nope empty


update : Action -> Model -> ( Model, Cmd Action )
update action model =
    case action of
        OnLocationChanged location ->
            init location

        OnHeader (Header.RequestedLogOut) ->
            Actor.logout model

        OnHeader subaction ->
            Actor.nope model

        OnFooter _ ->
            Actor.nope model

        OnInitialPage (InitialPage.RequestedLogin) ->
            Actor.login model

        OnListPage subaction ->
            let
                ( pageModel, pageAction ) =
                    Actor.orNope (ListPage.update subaction) model.listModel
            in
                ( { model | listModel = pageModel }, Cmd.map OnListPage pageAction )

        OnActor (Actor.ReceivedUser value) ->
            let
                newHeader =
                    Header.authenticate model.header True

                newUser =
                    Actor.user value

                ( newListModel, newAction ) =
                    ListPage.init newUser
            in
                ( { model
                    | header = newHeader
                    , activePage = PageList
                    , user = newUser
                    , listModel = newListModel
                  }
                , Cmd.map OnListPage newAction
                )

        OnActor (Actor.ReceivedAuthenticated True) ->
            Actor.nope model

        OnActor (Actor.ReceivedAuthenticated False) ->
            let
                newHeader =
                    Header.authenticate model.header False
            in
                ( { empty | header = newHeader }, Cmd.none )


view : Model -> Html Action
view model =
    let
        body =
            case model.activePage of
                PageHome ->
                    InitialPage.view |> Html.map OnInitialPage

                PageList ->
                    Actor.orNothing ListPage.view model.listModel |> Html.map OnListPage
    in
        div []
            [ Header.view model.header |> Html.map OnHeader
            , body
            , Footer.view |> Html.map OnFooter
            ]


subscriptions : Model -> Sub Action
subscriptions model =
    Actor.subscribe model |> Sub.map OnActor


main : Program Never Model Action
main =
    Navigation.program OnLocationChanged
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }
