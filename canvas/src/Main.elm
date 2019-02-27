module Main exposing (main)

import Browser
import Data.Position as Position exposing (Position)
import Html.Styled
import Json.Decode as Decode
import Model exposing (Model)
import Msg exposing (Msg(..))
import Ports exposing (JsMsg)
import RasterShapes
import View exposing (view)



-- MAIN --


main : Program Decode.Value Model Msg
main =
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }
        |> Browser.document


init : Decode.Value -> ( Model, Cmd Msg )
init json =
    ( Model.init, Cmd.none )



-- SUBSCRIPTIONS --


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- UPDATE --


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        MouseDownOnCanvas positionOnElement ->
            ( model
                |> Model.setLastMouseDownPosition positionOnElement
            , [ ( model.color, positionOnElement )
              ]
                |> Ports.ColorPixels
                |> Ports.send
            )

        MouseMoveOnCanvas positionOnElement ->
            case model.lastMouseDownPosition of
                Just lastMouseDownPosition ->
                    ( model
                        |> Model.setLastMouseDownPosition positionOnElement
                    , RasterShapes.line
                        positionOnElement
                        lastMouseDownPosition
                        |> List.map (Tuple.pair model.color)
                        |> Ports.ColorPixels
                        |> Ports.send
                    )

                Nothing ->
                    ( model, Cmd.none )

        MouseUpOnCanvas ->
            ( Model.clearMouseDownPosition model, Cmd.none )
