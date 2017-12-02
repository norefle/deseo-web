module IdeaCard exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Idea exposing (Idea)
import Price


type alias Model =
    Idea


type Action
    = OnDeleteClicked Model


init : Idea -> Model
init idea =
    idea


view : Model -> Html Action
view model =
    div [ class "card" ]
        [ div [ class "card-body" ]
            [ a [ href model.url ]
                [ img
                    [ class "float-md-left float-sm-none"
                    , style
                        [ ( "max-width", "20rem" )
                        , ( "max-height", "15rem" )
                        ]
                    , src model.image
                    ]
                    []
                ]
            , h4 [ class "card-title" ]
                [ span [] [ text model.title ]
                , span [ class "float-right text-danger" ] [ text (Price.toString model.price) ]
                ]
            , h6 [ class "card-subtitle mb-2 text-muted" ] [ text model.added ]
            , p [ class "card-text" ] [ text model.description ]
            ]
        , div [ class "card-footer" ]
            [ a [ href "javascript:void(0)", class "mdl-button text-muted" ]
                [ i [ class "material-icons" ] [ text "done" ] ]
            , a [ href "javascript:void(0)", class "mdl-button", onClick (OnDeleteClicked model) ]
                [ i [ class "material-icons" ] [ text "delete" ] ]
            , a [ href "javascript:void(0)", class "mdl-button text-muted" ]
                [ i [ class "material-icons" ] [ text "arrow_upward" ] ]
            , a [ href "javascript:void(0)", class "mdl-button text-muted" ]
                [ i [ class "material-icons" ] [ text "arrow_downward" ] ]
            ]
        ]
