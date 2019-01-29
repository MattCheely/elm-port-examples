port module LocalStorage exposing (Event(..), clear, request, save, watchChanges)

{-| This module provides a basic interface to the localStorage API. It supports
requesting, saving, and clearing values for specific keys. It also provides a
subscription for listening to changes to values. The subscription will emit events for
any change to localStorage, whether it's triggered by the current instance of the app
or one in another browser tab.

The recommended practice when keeping data in localStorage is to bridge all updates
through the subscription to storage events. This means using the initial request to
change data to write to localStorage with the `save` function without updating model
state. Only when receiving a `LocalStorage.Event` through a subscription should model
state be updated. This serves two purposes:

1.  It keeps the application in the loop if a different tab/window saves data
2.  It provides a natural way to detect and handle write failures

-}

import Dict exposing (Dict)
import Json.Decode as Decode exposing (Decoder, decodeValue)
import Json.Encode as Encode exposing (Value)



-- Outbound API


{-| Writes a value to localStorage under the provided key
-}
save : String -> String -> Cmd msg
save key value =
    toStorage (updateMessage key (Encode.string value))


{-| Clears all data from the provided localStorage key
-}
clear : String -> Cmd msg
clear key =
    toStorage (updateMessage key Encode.null)


{-| Requests that a message be sent with the current state of the provided localStorage key.
For the vast majority of use cases, this only makes sense during the `init` phase of your program.
-}
request : String -> Cmd msg
request key =
    toStorage
        (Encode.object
            [ ( "msgType", Encode.string "request" )
            , ( "msg", Encode.string key )
            ]
        )



-- Inbound API


{-| An event from the JS localStorage bindings.

  - `Updated key value`: Indicates that `key` has changed. If `value` is `Nothing`
    the key's data has been cleared.
  - `WriteFalure key value error`: Indicates a failure saving to `key`. The `value`
    that should have been saved is provided so the application can continue to update
    the model state and log `error` if saving to localStorage is not a critical feature.
  - `BadMessage error`: Indicates that the data from JavaScript wasn't what this module
    expected. If you get this, either this file or the JS bindings have been edited in
    a way that breaks compatibility.

-}
type Event
    = Updated String (Maybe String)
    | WriteFailure String (Maybe String) String
    | BadMessage Decode.Error


{-| Watch for changes to values in localStorage.
-}
watchChanges : Sub Event
watchChanges =
    storageEvent handleStorageMessage



-- Outbound Helpers


updateMessage : String -> Value -> Value
updateMessage key value =
    Encode.object
        [ ( "msgType", Encode.string "save" )
        , ( "msg"
          , Encode.object
                [ ( "key", Encode.string key )
                , ( "value", value )
                ]
          )
        ]



-- Inbound Helpers


handleStorageMessage : Value -> Event
handleStorageMessage value =
    case
        decodeValue
            (Decode.oneOf
                [ errorDecoder
                , updateDecoder
                ]
            )
            value
    of
        Ok event ->
            event

        Err error ->
            BadMessage error


updateDecoder : Decoder Event
updateDecoder =
    Decode.map2 Updated
        keyDecoder
        valueDecoder


errorDecoder : Decoder Event
errorDecoder =
    Decode.map3 WriteFailure
        keyDecoder
        valueDecoder
        (Decode.field "error" Decode.string)


keyDecoder : Decoder String
keyDecoder =
    Decode.field "key" Decode.string


valueDecoder : Decoder (Maybe String)
valueDecoder =
    Decode.field "value" (Decode.nullable Decode.string)



-- PORTS


port toStorage : Value -> Cmd msg


port storageEvent : (Value -> a) -> Sub a
