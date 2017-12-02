module Main exposing (..)

import Footer
import Header
import Html exposing (..)
import InitialPage
import Json.Encode
import Json.Decode
import ListPage
import Navigation exposing (Location)
import Ports
import UrlParser exposing (..)
import User exposing (User)


type Route
    = RouteHome


type Page
    = PageHome
    | PageList


type Action
    = OnLocationChanged Location
    | OnHeader Header.Action
    | OnFooter Never
    | OnInitialPage InitialPage.Action
    | OnListPage ListPage.Action
    | OnUser Json.Encode.Value
    | OnAuthenticated Bool


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
            ( empty, Cmd.none )


update : Action -> Model -> ( Model, Cmd Action )
update action model =
    case action of
        OnLocationChanged location ->
            init location

        OnHeader (Header.RequestedLogOut) ->
            ( model, Ports.logout "" )

        OnHeader subaction ->
            ( model, Cmd.none )

        OnFooter _ ->
            ( model, Cmd.none )

        OnInitialPage (InitialPage.RequestedLogin) ->
            ( model, Ports.login "" )

        OnListPage subaction ->
            let
                ( pageModel, pageAction ) =
                    model.listModel
                        |> Maybe.andThen
                            (\x ->
                                let
                                    ( m, a ) =
                                        ListPage.update subaction x
                                in
                                    Just ( Just m, a )
                            )
                        |> Maybe.withDefault ( Nothing, Cmd.none )
            in
                ( { model | listModel = pageModel }, Cmd.map OnListPage pageAction )

        OnUser value ->
            let
                newHeader =
                    Header.authenticate model.header True

                parsed =
                    Json.Decode.decodeValue User.fromJson value

                newUser =
                    case parsed of
                        Ok user ->
                            Just user

                        Err error ->
                            Nothing

                ( newListModel, newAction ) =
                    newUser
                        |> Maybe.andThen
                            (\x ->
                                let
                                    ( m, a ) =
                                        ListPage.init x
                                in
                                    Just ( Just m, a )
                            )
                        |> Maybe.withDefault ( Nothing, Cmd.none )
            in
                ( { model | header = newHeader, activePage = PageList, user = newUser, listModel = newListModel }
                , Cmd.map OnListPage newAction
                )

        OnAuthenticated True ->
            ( model, Cmd.none )

        OnAuthenticated False ->
            let
                newHeader =
                    Header.authenticate model.header False
            in
                ( { empty | header = newHeader }, Cmd.none )


view : Model -> Html Action
view model =
    case model.activePage of
        PageHome ->
            div []
                [ Header.view model.header |> Html.map OnHeader
                , InitialPage.view |> Html.map OnInitialPage
                , Footer.view |> Html.map OnFooter
                ]

        PageList ->
            div []
                [ Header.view model.header |> Html.map OnHeader
                , model.listModel
                    |> (Maybe.andThen (ListPage.view >> Just))
                    |> Maybe.withDefault (Html.text "")
                    |> Html.map OnListPage
                , Footer.view |> Html.map OnFooter
                ]


subscriptions : Model -> Sub Action
subscriptions model =
    Sub.batch
        [ Ports.user OnUser
        , Ports.authenticated OnAuthenticated
        ]


main : Program Never Model Action
main =
    Navigation.program OnLocationChanged
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }
