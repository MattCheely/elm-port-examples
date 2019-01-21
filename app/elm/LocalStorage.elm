port module LocalStorage exposing (Event(..), clear, request, save, watchChanges)

import Dict exposing (Dict)
import Json.Decode as Decode exposing (Decoder, decodeValue)
import Json.Encode as Encode exposing (Value)



-- Outbound To Storage


save : String -> String -> Cmd msg
save key value =
    toStorage (updateMessage key (Encode.string value))


clear : String -> Cmd msg
clear key =
    toStorage (updateMessage key Encode.null)


request : String -> Cmd msg
request key =
    toStorage
        (Encode.object
            [ ( "msgType", Encode.string "request" )
            , ( "msg", Encode.string key )
            ]
        )


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


type Event
    = Updated String (Maybe String)
    | WriteFailure String (Maybe String) String
    | BadMessage Decode.Error


watchChanges : Sub Event
watchChanges =
    storageEvent handleStorageMessage


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


port storageEvent : (Value -> a) -> Sub a
