port module LocalStorage exposing (MessageError(..), StorageResult, clear, save, watchKeys)

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


type alias StorageResult msg =
    Result MessageError msg


watchKeys : List ( String, Decoder msg ) -> Sub (StorageResult msg)
watchKeys decoders =
    let
        storageDecoders =
            Dict.fromList decoders
    in
    storageEvent (handleStorageMessage storageDecoders)


handleStorageMessage : Dict String (Decoder msg) -> Value -> StorageResult msg
handleStorageMessage storageDecoders value =
    decodeValue (Decode.field "key" Decode.string) value
        |> Result.mapError BadMessage
        |> Result.andThen
            (\key ->
                case Dict.get key storageDecoders of
                    Nothing ->
                        Err (UnwatchedKey key)

                    Just decoder ->
                        decodeValue (Decode.field "value" decoder) value
                            |> Result.mapError (BadValue key)
            )


port storageEvent : (Value -> a) -> Sub a
