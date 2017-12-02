module Footer exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)


view : Html Never
view =
    footer [ class "w-100 mt-3 bg-dark" ]
        [ div [ class "container-fluid" ]
            [ div [ class "row" ]
                [ div [ class "col-12" ]
                    [ p [ class "navbar-text text-light" ]
                        [ text "Wish list © 2017" ]
                    ]
                ]
            ]
        ]
