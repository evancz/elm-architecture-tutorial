module CounterList where

import Counter
import Html (..)
import Html.Attributes (..)
import Html.Events (..)
import List
import LocalChannel as LC
import Signal


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
    | Remove ID
    | Modify ID Counter.Action


update : Action -> Model -> Model
update action model =
  case action of
    Insert ->
      { model |
          counters <- ( model.nextID, Counter.init 0 ) :: model.counters,
          nextID <- model.nextID + 1
      }

    Remove id ->
      { model |
          counters <- List.filter (\(counterID, _) -> counterID /= id) model.counters
      }

    Modify id counterAction ->
      let updateCounter (counterID, counterModel) =
            if counterID == id
                then (counterID, Counter.update counterAction counterModel)
                else (counterID, counterModel)
      in
          { model | counters <- List.map updateCounter model.counters }


-- VIEW

view : Model -> Html
view model =
  let insert = button [ onClick (Signal.send actionChannel Insert) ] [ text "Add" ]
  in
      div [] (insert :: List.map viewCounter model.counters)


viewCounter : (ID, Counter.Model) -> Html
viewCounter (id, model) =
  let channels =
        Counter.Channels
          (LC.create (Modify id) actionChannel)
          (LC.create (always (Remove id)) actionChannel)
  in
      Counter.view channels model


-- SIGNALS

main : Signal Html
main =
  Signal.map view model


model : Signal Model
model =
  Signal.foldp update init (Signal.subscribe actionChannel)


actionChannel : Signal.Channel Action
actionChannel =
  Signal.channel Insert