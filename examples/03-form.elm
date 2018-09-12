module Main exposing (Model, Msg(..), init, main, update, view, viewInput, viewValidation)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput)



-- MAIN


main =
    Browser.sandbox { init = init, update = update, view = view }



-- MODEL


type alias Model =
    { name : String
    , password : String
    , passwordAgain : String
    , age : String
    }


init : Model
init =
    Model "" "" "" ""



-- UPDATE


type Msg
    = Name String
    | Password String
    | PasswordAgain String
    | Age String


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
            { model | age = age }



-- VIEW


view : Model -> Html Msg
view model =
    Html.form []
        [ viewInput "text" "Name" model.name Name
        , viewInput "password" "Password" model.password Password
        , viewInput "password" "Re-enter Password" model.passwordAgain PasswordAgain
        , viewInput "text" "Enter your age" model.age Age
        , viewSubmit "Submit"
        , viewValidation model
        ]


viewInput : String -> String -> String -> (String -> msg) -> Html msg
viewInput t p v toMsg =
    input [ type_ t, placeholder p, value v, onInput toMsg ] []


viewSubmit : String -> Html msg
viewSubmit text =
    input [ type_ "submit", value text ] []


viewValidation : Model -> Html msg
viewValidation model =
    if isNotLongEnough model.password then
        div [ style "color" "red" ] [ text "Password must be more than 8 characters long!" ]

    else if isNotStrongEnough model.password then
        div [ style "color" "red" ] [ text "Password must contain upper case, lower case and numeric characters!" ]

    else if passwordsDontMatch model.password model.passwordAgain then
        div [ style "color" "red" ] [ text "Passwords don't match!" ]

    else if isNotNumber model.age then
        div [ style "color" "red" ] [ text "Age must be a number!" ]

    else
        div [ style "color" "green" ] [ text "Validations passed!" ]


isNotLongEnough : String -> Bool
isNotLongEnough password =
    String.length password <= 8


isNotStrongEnough : String -> Bool
isNotStrongEnough password =
    not <|
        String.any isUpperCase password
            && String.any isLowerCase password
            && String.any isDigit password


passwordsDontMatch : String -> String -> Bool
passwordsDontMatch password passwordAgain =
    password /= passwordAgain


isNotNumber : String -> Bool
isNotNumber age =
    String.length age == 0 || not (String.all isDigit age)


isUpperCase : Char -> Bool
isUpperCase char =
    String.contains (String.fromChar char) "ABCDEFGHIJKLMNOPQRSTUVWXYZ"


isLowerCase : Char -> Bool
isLowerCase char =
    String.contains (String.fromChar char) "abcdefghijklmnopqrstuvwxyz"


isDigit : Char -> Bool
isDigit char =
    String.contains (String.fromChar char) "0123456789"
