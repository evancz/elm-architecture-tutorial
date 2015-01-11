module CounterPair where

import Counter
import Html (..)
import Html.Attributes (..)
import Html.Events (..)
import LocalChannel as LC
import Signal


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

type Action
    = Reset
    | Top Counter.Action
    | Bottom Counter.Action


update : Action -> Model -> Model
update action model =
  case action of
    Reset -> init 0 0

    Top act ->
      { model |
          topCounter <- Counter.update act model.topCounter
      }

    Bottom act ->
      { model |
          bottomCounter <- Counter.update act model.bottomCounter
      }


-- VIEW

view : Model -> Html
view model =
  div []
    [ Counter.view (LC.create Top actionChannel) model.topCounter
    , Counter.view (LC.create Bottom actionChannel) model.bottomCounter
    , button [ onClick (Signal.send actionChannel Reset) ] [ text "RESET" ]
    ]


-- SIGNALS

main : Signal Html
main =
  Signal.map view model


model : Signal Model
model =
  Signal.foldp update (init 0 0) (Signal.subscribe actionChannel)


actionChannel : Signal.Channel Action
actionChannel =
  Signal.channel Reset