module Main exposing (main)

import Browser exposing (sandbox)
import Html exposing (Html, button, div, text)
import Html.Attributes exposing (class, id)
import Html.Events exposing (onClick)
import Json.Decode as Decode
import Json.Encode as Encode
import LocalStorage exposing (Event(..))


{-| This creates the most basic sort of Elm progam available in the
browser. No side effects like HTTP requests are available, just user
input and view rendering. For more options, see the elm/browser package
documentation @ <https://package.elm-lang.org/packages/elm/browser/latest/>
-}
main : Program () Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }



-- Model


type alias Model =
    { theInt : Int
    , theFloat : Float
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( { theInt = 0
      , theFloat = 0.0
      }
    , Cmd.batch
        [ LocalStorage.request "theInt"
        , LocalStorage.request "theFloat"
        ]
    )



-- Update


type Msg
    = ClearInt
    | ClearFloat
    | IncreaseInt
    | IncreaseFloat
    | StorageEvent LocalStorage.Event
    | NoOp


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        IncreaseInt ->
            ( model, saveInt (model.theInt + 1) )

        ClearInt ->
            ( model, LocalStorage.clear "theInt" )

        IncreaseFloat ->
            ( model, saveFloat (model.theFloat + 0.1) )

        ClearFloat ->
            ( model, LocalStorage.clear "theFloat" )

        StorageEvent event ->
            handleStorageEvent model event

        NoOp ->
            ( model, Cmd.none )


handleStorageEvent : Model -> LocalStorage.Event -> ( Model, Cmd Msg )
handleStorageEvent model event =
    case event of
        Updated key value ->
            storageUpdate model key value

        WriteFailure key value err ->
            storageUpdate model key value
                |> withErrorLog
                    ("Unable to write to localStorage key '"
                        ++ key
                        ++ "': "
                        ++ err
                    )

        BadMessage err ->
            ( model, Cmd.none )
                |> withErrorLog ("Malformed storage event: " ++ Decode.errorToString err)


storageUpdate : Model -> String -> Maybe String -> ( Model, Cmd Msg )
storageUpdate model key value =
    case key of
        "theInt" ->
            Maybe.map (updateInt model) value
                |> Maybe.withDefault (resetInt model)

        "theFloat" ->
            Maybe.map (updateFloat model) value
                |> Maybe.withDefault (resetFloat model)

        _ ->
            ( model, Cmd.none )


updateInt : Model -> String -> ( Model, Cmd Msg )
updateInt model intStr =
    case String.toInt intStr of
        Just int ->
            ( { model | theInt = int }, Cmd.none )

        Nothing ->
            ( model, logError ("Got invalid int value: " ++ intStr) )


resetInt : Model -> ( Model, Cmd Msg )
resetInt model =
    ( { model | theInt = 0 }, Cmd.none )


updateFloat : Model -> String -> ( Model, Cmd Msg )
updateFloat model floatStr =
    case String.toFloat floatStr of
        Just float ->
            ( { model | theFloat = float }, Cmd.none )

        Nothing ->
            ( model, logError ("Got invalid float value: " ++ floatStr) )


resetFloat : Model -> ( Model, Cmd Msg )
resetFloat model =
    ( { model | theFloat = 0 }, Cmd.none )


withErrorLog : String -> ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
withErrorLog err updateTuple =
    updateTuple
        |> Tuple.mapSecond (\cmd -> Cmd.batch [ cmd, logError err ])


logError : String -> Cmd Msg
logError error =
    let
        log =
            Debug.log "ERROR" error
    in
    Cmd.none


saveInt : Int -> Cmd Msg
saveInt int =
    LocalStorage.save "theInt" (String.fromInt int)


saveFloat : Float -> Cmd Msg
saveFloat float =
    LocalStorage.save "theFloat" (String.fromFloat float)



-- Subscriptions


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.map StorageEvent LocalStorage.watchChanges



-- View


view : Model -> Html Msg
view model =
    div []
        [ div []
            [ text "The Int: "
            , text (String.fromInt model.theInt)
            , button [ onClick IncreaseInt ] [ text "Increase" ]
            , button [ onClick ClearInt ] [ text "Clear" ]
            ]
        , div []
            [ text "The Float: "
            , text (String.fromFloat model.theFloat)
            , button [ onClick IncreaseFloat ] [ text "Increase" ]
            , button [ onClick ClearFloat ] [ text "Clear" ]
            ]
        ]
