import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput, onClick)
import Result exposing (withDefault)
import Regex
pattern = Regex.regex "(?=^.{6,}$)(?=.*\\d)(?=.*[A-Z])(?=.*[a-z]).*$"

main =
  Html.beginnerProgram
    { model = model
    , view = view
    , update = update
    }

-- MODEL


type alias Model =
  { name : String
  , password : String
  , passwordAgain : String
  , age : Int
  , submit : Bool
  }


model : Model
model =
  Model "" "" "" 0 False



-- UPDATE


type Msg
    = Name String
    | Password String
    | PasswordAgain String
    | Age String
    | Submit


update : Msg -> Model -> Model
update msg model =
  case msg of
    Name name ->
      { model | name = name }

    Password password ->
      { model | password = password }

    PasswordAgain password ->
      { model | passwordAgain = password }

    Age age ->
    { model | age = withDefault 0 (String.toInt age) }

    Submit ->
    { model | submit = True }

-- VIEW


view : Model -> Html Msg
view model =
  div []
    [ input [ type_ "text", placeholder "Name", onInput Name ] []
    , input [ type_ "password", placeholder "Password", onInput Password ] []
    , input [ type_ "password", placeholder "Re-enter Password", onInput PasswordAgain ] []
    , input [ type_ "number", placeholder "Age", onInput Age ] []
    , button [ onClick Submit ] [ text "Submit" ]
    , viewValidation model
    ]


viewValidation : Model -> Html msg
viewValidation model =
  let
    (color, message) =
      if not model.submit then
         ("transparent", "")
      else if model.password == model.passwordAgain && Regex.contains pattern model.password then
        ("green", "OK")
      else if model.password /= model.passwordAgain then
        ("red", "Passwords do not match!")
      else if not (Regex.contains pattern model.password) then
        ("red", "Password must contain upper case, lower case and numeric characters")
      else
        ("red", "Password is too short, must be 8 characters")
  in
    div [ style [("color", color)] ] [ text message ]
