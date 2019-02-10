module Data.Position exposing
    ( Position
    , encode
    , onTargetFromMouseEvent
    )

import Html.Events.Extra.Mouse as Mouse
import Json.Encode as Encode



-- TYPES --


type alias Position =
    { x : Int
    , y : Int
    }



-- HELPERS --


onTargetFromMouseEvent : Mouse.Event -> Position
onTargetFromMouseEvent { offsetPos } =
    let
        ( offsetX, offsetY ) =
            offsetPos
    in
    { x = floor offsetX
    , y = floor offsetY
    }


encode : Position -> Encode.Value
encode position =
    [ ( "x", Encode.int position.x )
    , ( "y", Encode.int position.y )
    ]
        |> Encode.object
