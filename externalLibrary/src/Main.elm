port module Main exposing (Msg(..), init, itemLinked, jsonConsole, linkExit, main, openPlaidLink, subscriptions, update, view)

import Browser
import Decoders
import Encoders
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Json.Decode exposing (Error, decodeValue)
import Json.Encode as E
import Models exposing (..)



-- MAIN


main =
    Browser.element
        { init = init
        , subscriptions = subscriptions
        , update = update
        , view = view
        }


type Msg
    = OpenPlaidLink (List Product)
    | GotItem (Result Error Item)
    | ShowLinkAnotherBank
    | ShowFinish
    | ConsoleLogJson
    | LinkExited (Result Error ItemExit)





init : String -> ( Model, Cmd msg )
init name =
    ( { initialModel | name = name }, Cmd.none )



-- PORTS


port openPlaidLink : E.Value -> Cmd msg


port itemLinked : (E.Value -> msg) -> Sub msg


port jsonConsole : E.Value -> Cmd msg


port linkExit : (E.Value -> msg) -> Sub msg



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.batch
        [ itemLinked (decodeValue Decoders.item >> GotItem)
        , linkExit (decodeValue Decoders.exit >> LinkExited)
        ]


setPrimaryAccount : Account -> Item -> Item
setPrimaryAccount account item =
    let
        setAsPrimary id a =
            if account.id == a.id then
                { a | primary = True }

            else
                { a | primary = False }

        accounts =
            List.map (\a -> setAsPrimary account a) item.accounts
    in
    { item | accounts = accounts }



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case Debug.log "MSG" msg of
        GotItem item ->
            case Result.toMaybe item of
                Nothing ->
                    ( model, Cmd.none )

                Just a ->
                    let
                        stage =
                            if List.length model.items == 0 then
                                nextStage model.stage

                            else
                                model.stage
                    in
                    ( { model | items = List.append model.items [ a ], stage = stage }
                    , Cmd.none
                    )

        OpenPlaidLink products ->
            ( model, openPlaidLink (Encoders.products products) )


        ShowLinkAnotherBank ->
            let
                stage =
                    nextStage model.stage
            in
            ( Debug.log "item" { model | stage = stage }
            , Cmd.none
            )

        ShowFinish ->
            ( Debug.log "item" { model | stage = Finish }
            , Cmd.none
            )


        ConsoleLogJson ->
            let
                json = Encoders.model model
            in
                ( model, jsonConsole json )


        LinkExited exit ->
            case exit of
                Ok itemExit ->
                  ( Debug.log "item" { model | stage = Exited, itemExit = Just itemExit }
                  , Cmd.none
                  )

                Err err ->
                  ( Debug.log "error :(" { model | stage = Exited }
                  , Cmd.none
                  )



-- VIEW


view : Model -> Html Msg
view model =
    div [] [ viewFor model ]


viewFor : Model -> Html Msg
viewFor model =
    case model.stage of
        Start ->
            startView model

        LinkAnotherBank ->
            linkAnotherBankView model

        Finish ->
            finishView model

        Exited ->
            exitedView model


startView : Model -> Html Msg
startView model =
    div []
        [ 
          div [] [ enrollingText model ]
        , div [] [ button [ onClick <| OpenPlaidLink [ Auth ] ] [ text "Get Started" ] ]
        ]



linkAnotherBankView : Model -> Html Msg
linkAnotherBankView model =
    let
        list =
            banksLinkedSoFar model.items
    in
    div []
        [ 
          div [] [ enrollingText model ]
        , div [] [ div [] [ h4 [] [ text "You've linked: " ] ]
                 , div [] [ div [] [ ul [] list ] ]
                 , div [] [ button [ onClick <| OpenPlaidLink [ Transactions ] ] [ text "Link another bank" ] ]
                 , div [] [ button [ onClick ShowFinish ] [ text "Finish" ] ]
                 ]
        ]


banksLinkedSoFar : List Item -> List (Html Msg)
banksLinkedSoFar items =
    List.concatMap
        (\item ->
            let
                numberOfAccounts =
                    item.accounts |> List.length |> String.fromInt

                numberOfAccountsText =
                    "- " ++ numberOfAccounts ++ " accounts"

                accountNames =
                    List.map .name item.accounts

                accounts =
                    String.join ", " accountNames
            in
            [ li [] [ text item.institution.name, span [ title accounts ] [ text numberOfAccountsText ] ]
            ]
        )
        items


finishView : Model -> Html Msg
finishView model =
    div []
        [ h4 [] [ text "Thank you for linking your accounts." ]
        , text "Here's where you might trigger an HTTP call."
        ]


exitedView : Model -> Html Msg
exitedView model =
    let
        sessionId =
          case model.itemExit of
            Just ie ->
              ie.metadata.sessionId

            Nothing ->
              "No sessionId"
    in
    div []
        [ h4 [] [ text "Link Exited" ]
        , text ("SessionId: " ++ sessionId)
        ]


enrollingText : Model -> Html Msg
enrollingText model =
    h3 [] [ "Enrolling " ++ model.name |> text ]


institutionRowsForDepositorySelection : Model -> List (Html Msg)
institutionRowsForDepositorySelection model =
    List.concatMap (\item -> institutionRowForDepositorySelection item model) model.items


institutionRowForDepositorySelection : Item -> Model -> List (Html Msg)
institutionRowForDepositorySelection item model =
    let
        rows =
            accountRowsForDepositorySelection item.accounts model
    in
    List.concat
        [ [ div [] [ h4 [] [ text item.institution.name ] ] ]
        , rows
        ]


accountRowsForDepositorySelection : List Account -> Model -> List (Html Msg)
accountRowsForDepositorySelection accounts model =
    let
        depositoryAccounts =
            List.filter (\account -> account.type_ == Depository) accounts
    in
    List.concatMap (\account -> accountRowForDepositorySelection account model) depositoryAccounts


accountRowForDepositorySelection : Account -> Model -> List (Html Msg)
accountRowForDepositorySelection account model =
    let
        defaultRowClasses =
            "m-3 p-2 pointer"

        class_ =
            if account.primary then
                "bg-light rounded shadow " ++ defaultRowClasses

            else
                defaultRowClasses
    in
    [ div [ class class_ ]
        [ h5 [] [ text account.name ]
        , h6 [ class "mask" ] [ text <| "************" ++ account.mask ]
        ]
    ]


nextStage : Stage -> Stage
nextStage stage =
    case stage of
        Start ->
            LinkAnotherBank

        LinkAnotherBank ->
            Finish

        Finish ->
            Finish

        Exited ->
            Exited
