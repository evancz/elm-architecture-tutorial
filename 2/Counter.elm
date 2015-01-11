module Counter (Model, init, Action, update, view) where

import Html (..)
import Html.Attributes (..)
import Html.Events (..)
import LocalChannel (..)


-- MODEL

type alias Model = Int


init : Int -> Model
init count = count


-- UPDATE

type Action = Increment | Decrement


update : Action -> Model -> Model
update action model =
  case action of
    Increment -> model + 1
    Decrement -> model - 1


-- VIEW

view : LocalChannel Action -> Model -> Html
view channel model =
  div []
    [ button [ onClick (send channel Decrement) ] [ text "-" ]
    , div [ countStyle ] [ text (toString model) ]
    , button [ onClick (send channel Increment) ] [ text "+" ]
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
