module Decoders exposing (..)

import Json.Decode
    exposing
        ( Decoder
        , andThen
        , fail
        , field
        , list
        , map2
        , map3
        , map4
        , map6
        , maybe
        , string
        , succeed
        )
import Models exposing (..)


account : Decoder Account
account =
    map6
        Account
        (field "name" string)
        (field "id" string)
        (field "type" accountType)
        (field "subtype" accountSubType)
        (field "mask" string)
        (succeed False)


accounts : Decoder (List Account)
accounts =
    list account


accountSubType : Decoder AccountSubType
accountSubType =
    string
        |> andThen
            (\str ->
                case str of
                    "cd" ->
                        succeed CD

                    "checking" ->
                        succeed Checking

                    "savings" ->
                        succeed Savings

                    "money market" ->
                        succeed MoneyMarket

                    "paypal" ->
                        succeed Paypal

                    "credit card" ->
                        succeed CreditCard

                    "rewards" ->
                        succeed Rewards

                    another ->
                        succeed OtherSubType
            )


accountType : Decoder AccountType
accountType =
    string
        |> andThen
            (\str ->
                case str of
                    "depository" ->
                        succeed Depository

                    "credit" ->
                        succeed Credit

                    "brokerage" ->
                        succeed Brokerage

                    "loan" ->
                        succeed Loan

                    other ->
                        succeed OtherType
            )


institution : Decoder Institution
institution =
    map2
        Institution
        (field "name" string)
        (field "institution_id" string)


item : Decoder Item
item =
    map3
        Item
        (field "public_token" string)
        (field "institution" institution)
        (field "accounts" accounts)


user : Decoder String
user =
    field "name" string


exit : Decoder ItemExit
exit =
    map2
        ItemExit
        (field "error" (maybe exitError))
        (field "metadata" exitMetadata)


exitError : Decoder ExitError
exitError =
    map4
        ExitError
        (field "display_message" string)
        (field "error_code" string)
        (field "error_message" string)
        (field "error_type" string)


exitMetadata : Decoder ExitMetadata
exitMetadata =
    map3
        ExitMetadata
        (field "link_session_id" string)
        (field "institution" institution)
        (field "status" metadataStatus)



metadataStatus : Decoder MetadataStatus
metadataStatus =
    string
        |> andThen
            (\status ->
                case status of
                    "choose_device" ->
                        succeed ChooseDevice

                    "institution_not_found" ->
                        succeed InstitutionNotFound

                    "requires_code" ->
                        succeed RequiresCode

                    "requires_credentials" ->
                        succeed RequiresCredentials

                    "requires_questions" ->
                        succeed RequiresQuestions

                    "requires_selections" ->
                        succeed RequiresSelections

                    _ ->
                        fail <|
                            "Trying to decode metadata status, but status "
                                ++ status
                                ++ " is not supported"
            )
