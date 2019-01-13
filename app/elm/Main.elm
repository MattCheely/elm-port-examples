module Main exposing (main)

import Browser exposing (sandbox)
import Html exposing (Html, button, div, text)
import Html.Attributes exposing (class, id)
import Html.Events exposing (onClick)
import Json.Decode as Decode
import Json.Encode as Encode
import LocalStorage


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
    ( { theInt = 1
      , theFloat = 1.1
      }
    , Cmd.none
    )



-- Update


type Msg
    = IntChanged (Maybe Int)
    | FloatChanged (Maybe Float)
    | ClearInt
    | ClearFloat
    | IncreaseInt
    | IncreaseFloat
    | BadData LocalStorage.MessageError


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        IntChanged int ->
            ( { model | theInt = Maybe.withDefault 0 int }, Cmd.none )

        IncreaseInt ->
            ( model, saveInt (model.theInt + 1) )

        ClearInt ->
            ( model, LocalStorage.clear "theInt" )

        FloatChanged float ->
            ( { model | theFloat = Maybe.withDefault 0.0 float }, Cmd.none )

        IncreaseFloat ->
            ( model, saveFloat (model.theFloat + 0.1) )

        ClearFloat ->
            ( model, LocalStorage.clear "theFloat" )

        BadData error ->
            ( model, Cmd.none )


saveInt : Int -> Cmd Msg
saveInt int =
    LocalStorage.save "theInt" (Encode.int int)


saveFloat : Float -> Cmd Msg
saveFloat float =
    LocalStorage.save "theFloat" (Encode.float float)



-- Subscriptions


subscriptions : Model -> Sub Msg
subscriptions model =
    LocalStorage.watchKeys
        [ ( "theInt", Decode.map IntChanged (Decode.nullable Decode.int) )
        , ( "theFloat", Decode.map FloatChanged (Decode.nullable Decode.float) )
        ]
        |> Sub.map
            (\result ->
                case result of
                    Ok msg ->
                        msg

                    Err error ->
                        BadData error
            )



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
