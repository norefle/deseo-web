module ListPage exposing (..)

import Api
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import IdeaCard as Card
import Price exposing (Price)
import User exposing (User)
import Idea exposing (Idea)


type Action
    = OnCard Card.Action
    | OnCreateClicked
    | OnIdeaUpdated String
    | OnApi Api.Event


type alias Model =
    { user : User
    , error : Maybe String
    , demand : Price
    , supply : Price
    , ideas : List Card.Model
    , url : Maybe String
    }


init : User -> ( Model, Cmd Action )
init user =
    ( { user = user
      , error = Nothing
      , demand = 0
      , supply = 0
      , ideas = []
      , url = Nothing
      }
    , Cmd.map OnApi (Api.listWishes user)
    )


update : Action -> Model -> ( Model, Cmd Action )
update action model =
    case action of
        OnCard (Card.OnDeleteClicked card) ->
            let
                newIdeas =
                    model.ideas
                        |> List.filter (\item -> item.id /= card.id)

                newDemand =
                    totalDemand newIdeas
            in
                ( { model | ideas = newIdeas, demand = newDemand }, Cmd.map OnApi (Api.deleteIdea model.user card) )

        OnApi (Api.ReceivedWishes (Err error)) ->
            ( { model | error = Just (toString error) }, Cmd.none )

        OnApi (Api.ReceivedWishes (Ok response)) ->
            let
                newIdeas =
                    response.wishes

                newDemand =
                    totalDemand newIdeas
            in
                ( { model | error = Nothing, ideas = response.wishes, demand = newDemand }, Cmd.none )

        OnApi (Api.ReceivedPostAck (Ok response)) ->
            ( model, Cmd.map OnApi (Api.listWishes model.user) )

        OnApi (Api.ReceivedPostAck (Err error)) ->
            ( { model | error = Just (toString error) }, Cmd.none )

        OnCreateClicked ->
            let
                action =
                    model.url
                        |> Maybe.andThen (Idea.init >> Just)
                        |> Maybe.andThen (Api.addIdea model.user >> Just)
                        |> Maybe.andThen (Cmd.map OnApi >> Just)
                        |> Maybe.withDefault Cmd.none
            in
                ( model, action )

        OnIdeaUpdated value ->
            ( { model | url = Just value }, Cmd.none )


totalDemand : List Idea -> Price
totalDemand ideas =
    ideas |> List.foldl (\idea acc -> acc + idea.price) 0


view : Model -> Html Action
view model =
    div [ class "row" ]
        ([ balance model
         , ideaCreator
         ]
            ++ (ideas model.ideas)
        )


balance : Model -> Html Action
balance model =
    div [ class "col-12 mt-3" ]
        [ div [ class "card" ]
            [ div [ class "card-body" ]
                [ h4 [ class "card-title" ]
                    [ span []
                        [ text "Balance" ]
                    , div [ class "float-right" ]
                        [ span [ class "text-danger" ] [ text (Price.toString model.demand) ]
                        , span [] [ text " / " ]
                        , span [ class "text-success" ] [ text (Price.toString model.supply) ]
                        ]
                    ]
                ]
            ]
        ]


ideaCreator : Html Action
ideaCreator =
    div [ class "col-12 mt-3" ]
        [ div [ class "card" ]
            [ div [ class "card-body" ]
                [ div [ class "input-group" ]
                    [ input
                        [ type_ "text"
                        , class "form-control"
                        , placeholder "Title or Url like https://amazon.de/dp/B01LQF9UKS"
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
