module Counter where

import Html (..)
import Html.Attributes (..)
import Html.Events (..)
import Signal


-- MODEL

type alias Model = Int


-- UPDATE

type Action = Increment | Decrement

update : Action -> Model -> Model
update action model =
  case action of
    Increment -> model + 1
    Decrement -> model - 1


-- VIEW

view : Model -> Html
view model =
  div []
    [ button [ onClick (Signal.send actionChannel Decrement) ] [ text "-" ]
    , div [ countStyle ] [ text (toString model) ]
    , button [ onClick (Signal.send actionChannel Increment) ] [ text "+" ]
    ]


countStyle : Attribute
countStyle =
  style
    [ ("font-size", "20px")
    , ("font-family", "monospace")
    , ("display", "inline-block")
    , ("width", "50px")
    , ("text-align", "center")
    ]


-- SIGNALS

main : Signal Html
main =
  Signal.map view model

model : Signal Model
model =
  Signal.foldp update 0 (Signal.subscribe actionChannel)

actionChannel : Signal.Channel Action
actionChannel =
  Signal.channel Increment