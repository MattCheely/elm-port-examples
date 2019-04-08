module Models exposing (Account, AccountSubType(..), AccountType(..), ExitError, ExitMetadata, Institution, Item, ItemExit, MetadataStatus(..), Model, Product(..), Stage(..), initialModel)


type alias Model =
    { items : List Item
    , name : String
    , stage : Stage
    , itemExit : Maybe ItemExit
    }


initialModel : Model
initialModel =
    { items = []
    , name = ""
    , stage = Start
    , itemExit = Nothing
    }


type alias Account =
    { name : String
    , id : String
    , type_ : AccountType
    , subType : AccountSubType
    , mask : String
    , primary : Bool
    }


type AccountType
    = Depository
    | Credit
    | Brokerage
    | Loan
    | OtherType


type AccountSubType
    = CD
    | Checking
    | Savings
    | MoneyMarket
    | Paypal
    | Prepaid
    | CreditCard
    | Rewards
    | OtherSubType


type alias Institution =
    { name : String
    , id : String
    }


type alias Item =
    { public_token : String
    , institution : Institution
    , accounts : List Account
    }


type Product
    = Auth
    | Transactions


type Stage
    = Start
    | LinkAnotherBank
    | Finish
    | Exited


type alias ExitError =
    { displayMessage : String
    , errorCode : String
    , errorMessage : String
    , errorType : String
    }


type alias ExitMetadata =
    { sessionId : String
    , institution : Maybe Institution
    , status : MetadataStatus
    }


type alias ItemExit =
    { error : Maybe ExitError
    , metadata : ExitMetadata
    }



type MetadataStatus
    = ChooseDevice
    | InstitutionNotFound
    | RequiresCode
    | RequiresCredentials
    | RequiresQuestions
    | RequiresSelections
