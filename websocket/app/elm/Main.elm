module Main exposing (main)

import Browser
import Html exposing (Html, button, div, input, pre, text)
import Html.Attributes exposing (class, value)
import Html.Events exposing (onClick, onInput)
import Http
import Websocket exposing (Event(..))



-- MAIN


main =
    Browser.element
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }



-- MODEL


type alias Model =
    { socketInfo : Maybe Websocket.ConnectionInfo
    , toSend : String
    , sentMessages : List String
    , recievedMessages : List String
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( { socketInfo = Nothing
      , toSend = "ping!"
      , sentMessages = []
      , recievedMessages = []
      }
    , Websocket.connect "wss://echo.websocket.org" []
    )



-- UPDATE


type Msg
    = SocketConnect Websocket.ConnectionInfo
    | SendStringChanged String
    | RecievedString String
    | SendString
    | Error String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SocketConnect socketInfo ->
            ( { model | socketInfo = Just socketInfo }, Cmd.none )

        SendStringChanged string ->
            ( { model | toSend = string }, Cmd.none )

        SendString ->
            case model.socketInfo of
                Just socketInfo ->
                    ( { model | sentMessages = model.toSend :: model.sentMessages }
                    , Websocket.sendString socketInfo model.toSend
                    )

                Nothing ->
                    ( model, Cmd.none )

        RecievedString message ->
            ( { model | recievedMessages = message :: model.recievedMessages }
            , Cmd.none
            )

        Error errMsg ->
            let
                errLog =
                    Debug.log "Error" errMsg
            in
            ( model, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Websocket.events
        (\event ->
            case event of
                Websocket.Connected info ->
                    SocketConnect info

                StringMessage message ->
                    RecievedString message

                BadMessage error ->
                    Error error
        )



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ connectionState model
        , stringMsgControls model
        ]


connectionState model =
    div [ class "connectionState" ]
        [ case model.socketInfo of
            Nothing ->
                text "Connecting..."

            Just info ->
                div []
                    [ text "Connected to "
                    , text info.url
                    ]
        ]


stringMsgControls : Model -> Html Msg
stringMsgControls model =
    div []
        [ div [ class "controls" ]
            [ button [ onClick SendString ] [ text "Send" ]
            , input [ onInput SendStringChanged, value model.toSend ] []
            ]
        , div [ class "stringMessages" ]
            [ div [ class "sent" ]
                (div [ class "header" ] [ text "Sent" ]
                    :: List.map messageInfo model.sentMessages
                )
            , div [ class "recieved" ]
                (div [ class "header" ] [ text "Recieved" ]
                    :: List.map messageInfo model.recievedMessages
                )
            ]
        ]


messageInfo : String -> Html Msg
messageInfo message =
    div [] [ text message ]
