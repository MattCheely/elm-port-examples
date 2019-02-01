port module Notification exposing (new)

{-| This module provides a basic interface to the notification API. It supports
new Notification.
-}

import Json.Encode as Encode exposing (Value)



-- Outbound API


new : String -> Cmd msg
new title =
    newNotification (Encode.string title)



-- PORTS


port newNotification : Value -> Cmd msg
