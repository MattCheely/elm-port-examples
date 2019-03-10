port module Websocket exposing (ConnectionInfo, Event(..), connect, events, sendString)

import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode exposing (Value)



-- OUTBOUND


type alias ConnectionInfo =
    { protocol : String
    , extensions : String
    , url : String
    }


connect : String -> List String -> Cmd msg
connect url protocols =
    message "connect"
        (Encode.object
            [ ( "url", Encode.string url )
            , ( "protocols", Encode.list Encode.string protocols )
            ]
        )
        |> toSocket


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


message : String -> Value -> Value
message msgType msg =
    Encode.object
        [ ( "msgType", Encode.string msgType )
        , ( "msg", msg )
        ]



-- PORTS


port toSocket : Value -> Cmd msg


port fromSocket : (Value -> a) -> Sub a
