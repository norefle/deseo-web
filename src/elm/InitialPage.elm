module InitialPage exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)


type Action
    = RequestedLogin


view : Html Action
view =
    div [ class "container-fluid" ]
        [ div [ class "row mt-3" ]
            [ div [ class "col-12" ]
                [ div [ class "card" ]
                    [ div [ class "card-body" ]
                        [ h4 [ class "card-title" ]
                            [ text "Sign in" ]
                        , div [ class "d-flex justify-content-center" ]
                            [ a
                                [ class "g-signin2 btn"
                                , href "javascript:void(0)"
                                , onClick RequestedLogin
                                ]
                                [ text "Sign in with google" ]
                            ]
                        ]
                    ]
                ]
            ]
        ]
