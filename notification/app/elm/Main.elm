module Main exposing (main)

import Browser
import Html exposing (Html, button, text)
import Html.Events exposing (onClick)
import Notification


{-| This creates the most basic sort of Elm progam available in the
browser. No side effects like HTTP requests are available, just user
input and view rendering. For more options, see the elm/browser package
documentation @ <https://package.elm-lang.org/packages/elm/browser/latest/>
-}
main : Program () () Msg
main =
    Browser.element
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }



-- Model


init : () -> ( (), Cmd Msg )
init _ =
    ( (), Cmd.none )



-- Update


type Msg
    = NewNotification String


update : Msg -> () -> ( (), Cmd Msg )
update msg _ =
    case msg of
        NewNotification title ->
            ( (), Notification.new title )



-- Subscriptions


subscriptions : () -> Sub Msg
subscriptions _ =
    Sub.none



-- View


view : () -> Html Msg
view _ =
    Html.button [ onClick (NewNotification "Hello") ] [ Html.text "Send Hello" ]
