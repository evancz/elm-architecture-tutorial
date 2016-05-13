import Counter
import Html exposing (Html, button, div, text)
import Html.App as App
import Html.Events exposing (onClick)



main =
  App.beginnerProgram
    { model = init 0 0
    , update = update
    , view = view
    }



-- MODEL


type alias Model =
    { topCounter : Counter.Model
    , bottomCounter : Counter.Model
    }


init : Int -> Int -> Model
init top bottom =
    { topCounter = Counter.init top
    , bottomCounter = Counter.init bottom
    }



-- UPDATE


type Msg
  = Reset
  | Top Counter.Msg
  | Bottom Counter.Msg


update : Msg -> Model -> Model
update msg model =
  case msg of
    Reset ->
      init 0 0

    Top topMsg ->
      let
        newCounter =
          Counter.update topMsg model.topCounter
      in
        { model | topCounter = newCounter }

    Bottom bottomMsg ->
      let
        newCounter =
          Counter.update bottomMsg model.bottomCounter
      in
        { model | bottomCounter = newCounter }



-- VIEW


view : Model -> Html Msg
view model =
  div
    []
    [ App.map Top (Counter.view model.topCounter)
    , App.map Bottom (Counter.view model.bottomCounter)
    , button [ onClick Reset ] [ text "RESET" ]
    ]