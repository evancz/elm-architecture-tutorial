module Main exposing (Model, Msg(..), init, main, update, view, viewInput, viewValidation)

import Browser
import Debug exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)



-- MAIN


main =
    Browser.sandbox { init = init, update = update, view = view }



-- MODEL


type alias Model =
    { name : String
    , password : String
    , passwordAgain : String
    , age : Int
    , submitted : Bool
    }


init : Model
init =
    Model "" "" "" 0 False



-- UPDATE


type Msg
    = Submit
    | NameInput String
    | PasswordInput String
    | PasswordAgainInput String
    | AgeInput String


update : Msg -> Model -> Model
update msg model =
    case msg of
        Submit ->
            { model | submitted = log "Submitted" True }

        NameInput name ->
            { model | name = log "name" name }

        PasswordInput password ->
            { model | password = log "password" password }

        PasswordAgainInput passwordAgain ->
            { model | passwordAgain = log "password again" passwordAgain }

        AgeInput age ->
            { model | age = log "age" (String.toInt age |> Maybe.withDefault 0) }



-- VIEW


view : Model -> Html Msg
view model =
    Html.form []
        [ viewInput "text" "Name" model.name NameInput
        , viewInput "password" "Password" model.password PasswordInput
        , viewInput "password" "Re-enter Password" model.passwordAgain PasswordAgainInput
        , viewInput "number" "Enter your age" (toString model.age) AgeInput
        , viewSubmit "Submit" Submit
        , viewModel model
        , viewValidation model
        ]


viewInput : String -> String -> String -> (String -> msg) -> Html msg
viewInput t p v toMsg =
    input [ type_ t, placeholder p, value v, onInput toMsg ] []


viewSubmit : String -> msg -> Html msg
viewSubmit cta msg =
    button [ onClick msg, type_ "button" ] [ text cta ]


viewModel : Model -> Html msg
viewModel model =
    div []
        [ div [] [ text "Name: ", text model.name ]
        , div [] [ text "Password: ", text model.password ]
        , div [] [ text "Password Again: ", text model.passwordAgain ]
        , div [] [ text "Age: ", text (toString model.age) ]
        , div [] [ text "Form Submitted: ", text (toString model.submitted) ]
        ]


viewValidation : Model -> Html msg
viewValidation model =
    if model.submitted then
        if isNotOldEnough model.age then
            div [ style "color" "red" ] [ text "Age must be greater than 12" ]

        else if isNotLongEnough model.password then
            div [ style "color" "red" ] [ text "Password must be more than 8 characters long!" ]

        else if isNotStrongEnough model.password then
            div [ style "color" "red" ] [ text "Password must contain upper case, lower case and numeric characters!" ]

        else if passwordsDontMatch model.password model.passwordAgain then
            div [ style "color" "red" ] [ text "Passwords don't match!" ]

        else
            div [ style "color" "green" ] [ text "Validations passed!" ]

    else
        div [ style "display" "none" ] []


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


isNotOldEnough : Int -> Bool
isNotOldEnough age =
    age <= 12


isUpperCase : Char -> Bool
isUpperCase char =
    String.contains (String.fromChar char) "ABCDEFGHIJKLMNOPQRSTUVWXYZ"


isLowerCase : Char -> Bool
isLowerCase char =
    String.contains (String.fromChar char) "abcdefghijklmnopqrstuvwxyz"


isDigit : Char -> Bool
isDigit char =
    String.contains (String.fromChar char) "0123456789"
