module View exposing (view)

import Browser
import Css exposing (..)
import Data.Position as Position
import Html.Events.Extra.Mouse as Mouse
import Html.Styled as Html exposing (Attribute, Html)
import Html.Styled.Attributes as Attrs
import Html.Styled.Lazy
import Model exposing (Model)
import Msg exposing (Msg(..))
import Style


view : Model -> Browser.Document Msg
view model =
    { title = "Elm Canvas Ports Experiment"
    , body =
        [ Style.globals
        , title
        , drawingCanvas
        , summary
        ]
            |> List.map Html.toUnstyled
    }


title : Html Msg
title =
    Html.p
        [ Attrs.css [ centerTextStyle ] ]
        [ Html.text "Elm Canvas Ports Experiment" ]


summary : Html Msg
summary =
    Html.p
        [ Attrs.css [ centerTextStyle ] ]
        [ Html.text "Click on the canvas, and drag, to draw." ]


centerTextStyle : Style
centerTextStyle =
    textAlign center


drawingCanvas : Html Msg
drawingCanvas =
    Html.div
        [ Attrs.css
            [ displayFlex
            , justifyContent center
            ]
        ]
        [ Html.node "elm-canvas"
            [ Attrs.id "main-canvas"
            , Attrs.css [ display block ]
            , Mouse.onDown
                (MouseDownOnCanvas << Position.onTargetFromMouseEvent)
                |> Attrs.fromUnstyled
            , Mouse.onMove
                (MouseMoveOnCanvas << Position.onTargetFromMouseEvent)
                |> Attrs.fromUnstyled
            , Mouse.onUp (always MouseUpOnCanvas)
                |> Attrs.fromUnstyled
            ]
            []
        ]
