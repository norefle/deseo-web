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
            [ div [ class "d-flex justify-content-center float-md-left float-sm-none" ]
                [ a [ href model.url ]
                    [ img
                        [ class "img-fluid"
                        , style
                            [ ( "max-width", "20rem" )
                            , ( "max-height", "15rem" )
                            ]
                        , src model.image
                        ]
                        []
                    ]
                ]
            , div [ class "d-flex justify-content-start" ]
                [ h4 [ class "card-title" ] [ text model.title ]
                , h4 [ class "ml-auto text-danger" ] [ text (Price.toString model.price) ]
                ]
            , div [ class "d-flex flex-column" ]
                [ h6 [ class "card-subtitle mb-2 text-muted" ] [ text model.added ]
                , p [ class "card-text" ] [ text model.description ]
                ]
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
