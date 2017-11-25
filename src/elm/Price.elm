module Price exposing (Price, toString)


type alias Price =
    Int


toString : Price -> String
toString price =
    units price ++ "." ++ subunits price


units : Price -> String
units value =
    Basics.toString (value // 100)


subunits : Price -> String
subunits value =
    let
        subvalue =
            value % 100
    in
        case subvalue of
            0 ->
                "00"

            _ ->
                Basics.toString subvalue
