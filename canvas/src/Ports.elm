port module Ports exposing
    ( JsMsg(..)
    , send
    )

import Color exposing (Color)
import Data.Position as Position exposing (Position)
import Json.Encode as Encode



-- TYPES --


type JsMsg
    = ColorPixels (List ( Color, Position ))


toCmd : String -> Encode.Value -> Cmd msg
toCmd type_ payload =
    [ ( "type", Encode.string type_ )
    , ( "payload", payload )
    ]
        |> Encode.object
        |> toJs


noPayload : String -> Cmd msg
noPayload type_ =
    toCmd type_ Encode.null


send : JsMsg -> Cmd msg
send msg =
    case msg of
        ColorPixels pixels ->
            pixels
                |> Encode.list encodePixel
                |> toCmd "colorPixels"


encodePixel : ( Color, Position ) -> Encode.Value
encodePixel ( color, position ) =
    [ ( "position", Position.encode position )
    , ( "color", encodeColor color )
    ]
        |> Encode.object


encodeColor : Color -> Encode.Value
encodeColor color =
    let
        { red, green, blue, alpha } =
            Color.toRgba color
    in
    [ ( "red", encodeTo255 red )
    , ( "green", encodeTo255 green )
    , ( "blue", encodeTo255 blue )
    , ( "alpha", encodeTo255 alpha )
    ]
        |> Encode.object


encodeTo255 : Float -> Encode.Value
encodeTo255 =
    Encode.int << round << (*) 255


port toJs : Encode.Value -> Cmd msg
