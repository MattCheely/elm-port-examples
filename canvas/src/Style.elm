module Style exposing (globals)

import Css exposing (..)
import Css.Global exposing (global)
import Html.Styled as Html exposing (Html)


globals : Html msg
globals =
    [ Css.Global.p [ pBasic ] ]
        |> global


pBasic : Style
pBasic =
    [ fontFamilies [ "Arial" ] ]
        |> Css.batch
