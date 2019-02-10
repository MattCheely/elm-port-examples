module Msg exposing (Msg(..))

import Data.Position exposing (Position)
import Html.Events.Extra.Mouse as Mouse
import Json.Decode as Decode exposing (Decoder)



-- TYPES --


type Msg
    = MouseDownOnCanvas Position
    | MouseMoveOnCanvas Position
    | MouseUpOnCanvas
