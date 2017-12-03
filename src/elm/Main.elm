module Main exposing (..)

import Actor
import Api
import Footer
import Header
import Html exposing (..)
import InitialPage
import Json.Decode
import ListInfo exposing (ListInfo)
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
    | OnApi Api.Event


type alias Model =
    { user : Maybe User
    , lists : List ListInfo
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
    , lists = []
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
                newUser =
                    Actor.user value

                newAction =
                    newUser
                        |> Maybe.andThen (Api.listLists >> Just)
                        |> Maybe.withDefault Cmd.none
            in
                ( { model | user = newUser }, Cmd.map OnApi newAction )

        OnApi (Api.ReceivedLists (Ok response)) ->
            let
                newHeader =
                    Header.authenticate model.header True

                newLists =
                    response.lists

                newList =
                    List.head response.lists

                newModelAction =
                    case ( model.user, newList ) of
                        ( Just user, Just list ) ->
                            Just (ListPage.init user list)

                        _ ->
                            Nothing

                ( newModel, newAction ) =
                    case newModelAction of
                        Just ( pageModel, pageAction ) ->
                            ( Just pageModel, Cmd.map OnListPage pageAction )

                        Nothing ->
                            ( Nothing, Cmd.none )
            in
                ( { model
                    | lists = newLists
                    , listModel = newModel
                    , header = newHeader
                    , activePage = PageList
                  }
                , newAction
                )

        OnApi (Api.ReceivedLists (Err error)) ->
            Actor.nope model

        OnApi _ ->
            Actor.nope model

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
