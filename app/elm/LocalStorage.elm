port module LocalStorage exposing (MessageError(..), clear, save, watchKeys)

import Dict exposing (Dict)
import Json.Decode as Decode exposing (Decoder, decodeValue)
import Json.Encode as Encode exposing (Value)



-- Outbound To Storage


save : String -> Value -> Cmd msg
save key value =
    toStorage (updateMessage key value)


clear : String -> Cmd msg
clear key =
    toStorage (updateMessage key Encode.null)


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


port toStorage : Value -> Cmd msg



-- Inbound From Storage


type MessageError
    = UnwatchedKey String
    | BadValue String Decode.Error
    | BadMessage Decode.Error


watchKeys : (MessageError -> msg) -> List ( String, Decoder msg ) -> Sub msg
watchKeys onError decoders =
    let
        storageDecoders =
            Dict.fromList decoders
    in
    storageEvent (handleStorageMessage onError storageDecoders)


handleStorageMessage : (MessageError -> msg) -> Dict String (Decoder msg) -> Value -> msg
handleStorageMessage onError storageDecoders value =
    case decodeValue (Decode.field "key" Decode.string) value of
        Err decodeError ->
            onError (BadMessage decodeError)

        Ok key ->
            case Dict.get key storageDecoders of
                Nothing ->
                    onError (UnwatchedKey key)

                Just decoder ->
                    extractValue onError key value decoder


extractValue : (MessageError -> msg) -> String -> Value -> Decoder msg -> msg
extractValue onError key value decoder =
    case decodeValue (Decode.field "value" decoder) value of
        Ok msg ->
            msg

        Err decodeError ->
            onError (BadValue key decodeError)


port storageEvent : (Value -> a) -> Sub a
