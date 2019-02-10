module Model exposing
    ( Model
    , clearMouseDownPosition
    , init
    , setLastMouseDownPosition
    )

import Color exposing (Color)
import Data.Position as Position exposing (Position)



-- TYPES --


type alias Model =
    { color : Color
    , lastMouseDownPosition : Maybe Position
    }


init : Model
init =
    { color = Color.black
    , lastMouseDownPosition = Nothing
    }



-- HELPERS --


clearMouseDownPosition : Model -> Model
clearMouseDownPosition model =
    { model | lastMouseDownPosition = Nothing }


setLastMouseDownPosition : Position -> Model -> Model
setLastMouseDownPosition newLastMouseDownPosition model =
    { model | lastMouseDownPosition = Just newLastMouseDownPosition }
