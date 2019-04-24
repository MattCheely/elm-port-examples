port module Websocket exposing (ConnectionInfo, Event(..), connect, events, sendString)

import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode exposing (Value)



-- OUTBOUND


{-| Metadata about a Websocket connection
-}
type alias ConnectionInfo =
    { protocol : String
    , extensions : String
    , url : String
    }


{-| Requests a connection to the provided URL with a list of acceptable protocols. It is fine for the list to be empty.
-}
connect : String -> List String -> Cmd msg
connect url protocols =
    message "connect"
        (Encode.object
            [ ( "url", Encode.string url )
            , ( "protocols", Encode.list Encode.string protocols )
            ]
        )
        |> toSocket


{-| Requests a string to be sent out on the provided socket connection.
-}
sendString : ConnectionInfo -> String -> Cmd msg
sendString connection text =
    message "sendString"
        (Encode.object
            [ ( "url", Encode.string connection.url )
            , ( "message", Encode.string text )
            ]
        )
        |> toSocket



-- INBOUND


{-| The types of messages we track from JS. We are notified when the socket
is connected, when a (string) message comes in, when the socket is closed and
on an error. There's a catch all event for messages we can't parse.
-}
type Event
    = Connected ConnectionInfo
    | StringMessage String
    | BadMessage String


events : (Event -> msg) -> Sub msg
events msg =
    fromSocket
        (\val ->
            case Decode.decodeValue eventDecoder val of
                Ok event ->
                    msg event

                Err decodeErr ->
                    msg (BadMessage (Decode.errorToString decodeErr))
        )


eventDecoder : Decoder Event
eventDecoder =
    Decode.field "msgType" Decode.string
        |> Decode.andThen
            (\msgType ->
                case msgType of
                    "connected" ->
                        Decode.map Connected
                            (Decode.field "msg" connectionDecoder)

                    "stringMessage" ->
                        Decode.map StringMessage
                            (Decode.field "msg" Decode.string)

                    _ ->
                        Decode.succeed (BadMessage ("Unknown message type: " ++ msgType))
            )


connectionDecoder : Decoder ConnectionInfo
connectionDecoder =
    Decode.map3 ConnectionInfo
        (Decode.field "protocol" Decode.string)
        (Decode.field "extensions" Decode.string)
        (Decode.field "url" Decode.string)



-- HELPERS


{-| Creates a standard message object structure for JS.
-}
message : String -> Value -> Value
message msgType msg =
    Encode.object
        [ ( "msgType", Encode.string msgType )
        , ( "msg", msg )
        ]



-- PORTS


port toSocket : Value -> Cmd msg


port fromSocket : (Value -> a) -> Sub a
