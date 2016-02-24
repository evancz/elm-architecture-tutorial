module CounterList where

import Counter
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)


-- MODEL

type alias Model =
    { counters : List ( ID, Counter.Model )
    , nextID : ID
    }

type alias ID = Int


init : Model
init =
    { counters = []
    , nextID = 0
    }


-- UPDATE

type Action
    = Insert
    | Remove
    | Modify ID Counter.Action


update : Action -> Model -> Model
update action model =
  case action of
    Insert ->
      let
        newCounter =
          Counter.init 0

        newCounterEntry =
          ( model.nextID, newCounter )

        newCounters =
          model.counters ++ [newCounterEntry]

        newModel =
          Model newCounters (model.nextID + 1)
      in
        newModel

    Remove ->
      { model | counters = List.drop 1 model.counters }

    Modify id counterAction ->
      let
        updateCounter counter =
          Counter.update counterAction counter

        newCounterEntry counterID counter =
          ( counterID, updateCounter counter )

        updateCounterEntry ((counterID, counter) as entry) =
          if counterID == id then
            newCounterEntry counterID counter
          else
            entry

        newCounters =
          List.map updateCounterEntry model.counters

        newModel =
            { model | counters = newCounters }
      in
        newModel


-- VIEW

view : Signal.Address Action -> Model -> Html
view address model =
  let counters = List.map (viewCounter address) model.counters
      remove = button [ onClick address Remove ] [ text "Remove" ]
      insert = button [ onClick address Insert ] [ text "Add" ]
  in
      div [] ([remove, insert] ++ counters)


viewCounter : Signal.Address Action -> (ID, Counter.Model) -> Html
viewCounter address (id, model) =
  Counter.view (Signal.forwardTo address (Modify id)) model
