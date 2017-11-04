module IdeaCard exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Idea exposing (Idea)


type alias Model =
    Idea


type Action
    = None


init : Idea -> Model
init idea =
    idea


view : Model -> Html Action
view model =
    div [ class "card" ]
        [ div [ class "card-body" ]
            [ img
                [ class "float-left"
                , style
                    [ ( "max-width", "20rem" )
                    , ( "max-height", "15rem" )
                    ]
                , src model.image
                ]
                []
            , h4 [ class "card-title" ] [ text model.title ]
            , h6 [ class "card-subtitle mb-2 text-muted" ] [ text model.added ]
            , p [ class "card-text" ] [ text model.description ]
            ]
        , div [ class "card-footer" ]
            [ a [ href "#", class "mdl-button" ]
                [ i [ class "material-icons" ] [ text "done" ] ]
            , a [ href "#", class "mdl-button" ]
                [ i [ class "material-icons" ] [ text "delete" ] ]
            , a [ href "#", class "mdl-button" ]
                [ i [ class "material-icons" ] [ text "arrow_upward" ] ]
            , a [ href "#", class "mdl-button" ]
                [ i [ class "material-icons" ] [ text "arrow_downward" ] ]
            ]
        ]
