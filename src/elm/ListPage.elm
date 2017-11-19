module ListPage exposing (..)

import Api
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import IdeaCard as Card
import User exposing (User)


type Action
    = OnCard Card.Action
    | OnCreateClicked
    | OnIdeaUpdated String
    | OnApi Api.Event


type alias Model =
    { error : Maybe String
    , ideas : List Card.Model
    , url : Maybe String
    }


init : User -> ( Model, Cmd Action )
init user =
    ( { error = Nothing
      , ideas = []
      , url = Nothing
      }
    , Cmd.map OnApi (Api.listWishes user)
    )


update : Action -> Model -> ( Model, Cmd Action )
update action model =
    case action of
        OnCard _ ->
            ( model, Cmd.none )

        OnApi (Api.ReceivedWishes (Err error)) ->
            ( { model | error = Just (toString error) }, Cmd.none )

        OnApi (Api.ReceivedWishes (Ok response)) ->
            ( { model | error = Nothing, ideas = response.wishes }, Cmd.none )

        OnCreateClicked ->
            ( model, Cmd.none )

        OnIdeaUpdated value ->
            ( { model | url = Just value }, Cmd.none )


view : Model -> Html Action
view model =
    div [ class "row" ]
        ([ ideaCreator ]
            ++ (ideas model.ideas)
        )


ideaCreator : Html Action
ideaCreator =
    div [ class "col-12 mt-3" ]
        [ div [ class "card" ]
            [ div [ class "card-body" ]
                [ div [ class "input-group" ]
                    [ input
                        [ type_ "text"
                        , class "form-control"
                        , placeholder "https://amazon.de/dp/B01LQF9UKS"
                        , attribute "aria-label" "Add idea"
                        , onInput OnIdeaUpdated
                        ]
                        []
                    , span [ class "input-group-btn" ]
                        [ button
                            [ class "btn btn-secondary"
                            , type_ "button"
                            , onClick OnCreateClicked
                            ]
                            [ text "Add" ]
                        ]
                    ]
                ]
            ]
        ]


ideas : List Card.Model -> List (Html Action)
ideas data =
    List.map card data


card : Card.Model -> Html Action
card card =
    div [ class "col-12 mt-3" ]
        [ Html.map OnCard (Card.view (Card.init card))
        ]
