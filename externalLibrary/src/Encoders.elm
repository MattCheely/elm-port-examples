module Encoders exposing (model, products)

import Json.Encode exposing (Value, bool, list, null, object, string)
import Models exposing (Account, AccountSubType(..), AccountType(..), Institution, Item, Model, Product(..))


accountType : AccountType -> Value
accountType accountType_ =
    let
        at =
            case accountType_ of
                Depository ->
                    "depository"

                Credit ->
                    "credit"

                Brokerage ->
                    "brokerage"

                Loan ->
                    "loan"

                OtherType ->
                    "other"
    in
    string at


account : Account -> Value
account account_ =
    object
        [ ( "name", string account_.name )
        , ( "id", string account_.id )
        , ( "type", accountType account_.type_ )
        , ( "subtype", subType <| Just account_.subType )
        , ( "primary", bool account_.primary )
        , ( "mask", string account_.mask )
        ]


institution : Institution -> Value
institution institution_ =
    object
        [ ( "name", string institution_.name )
        , ( "id", string institution_.id )
        ]

product : Product -> Value
product product_ =
    case product_ of
        Auth ->
            string "auth"

        Transactions ->
            string "transactions"


products : List Product -> Value
products products_ =
    list product products_


model : Model -> Value
model model_ =
    object
        [ ( "name", string model_.name )
        , ( "items", list item model_.items )
        ]

item : Item -> Value
item item_ =
    object
        [ ( "institution", institution item_.institution )
        , ( "accounts", list account item_.accounts )
        ]


subType : Maybe AccountSubType -> Value
subType subType_ =
    case subType_ of
        Nothing ->
            null

        Just aSubType ->
            let
                st =
                    case aSubType of
                        CD ->
                            "cd"

                        Checking ->
                            "checking"

                        Savings ->
                            "savings"

                        MoneyMarket ->
                            "money_market"

                        Paypal ->
                            "paypal"

                        Prepaid ->
                            "prepaid"

                        CreditCard ->
                            "credit_card"

                        Rewards ->
                            "rewards"

                        OtherSubType ->
                            "other"
            in
            string st
