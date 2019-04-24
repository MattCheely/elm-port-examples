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


{-| The websocket events we track from JS. All of them contain details about the connection
where the event originated. Some have additional payloads.

  - Connected: A websocket connection is successfully established
  - StringMessage: We received string data on a websocket connection (includes the string)
  - Closed: A websocket connection was closed (includes a count of buffered but unsent bytes)
  - Error: There was a connection error (includes the error code)
  - BadMessage: JS sent a message that could not be parsed.

-}
type Event
    = Connected ConnectionInfo
    | StringMessage ConnectionInfo String
    | Closed ConnectionInfo Int
    | Error ConnectionInfo Int
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
                        Decode.map2 StringMessage
                            (Decode.field "msg" connectionDecoder)
                            (Decode.at [ "msg", "data" ] Decode.string)

                    "closed" ->
                        Decode.map2 Closed
                            (Decode.field "msg" connectionDecoder)
                            (Decode.at [ "msg", "unsentBytes" ] Decode.int)

                    "error" ->
                        Decode.map2 Error
                            (Decode.field "msg" connectionDecoder)
                            (Decode.at [ "msg", "code" ] Decode.int)

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
