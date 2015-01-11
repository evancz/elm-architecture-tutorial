module Counter (Model, init, Action, update, Channels, view) where

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

type alias Channels =
    { actions : LocalChannel Action
    , delete : LocalChannel ()
    }


view : Channels -> Model -> Html
view channels model =
  div []
    [ button [ onClick (send channels.actions Decrement) ] [ text "-" ]
    , div [ countStyle ] [ text (toString model) ]
    , button [ onClick (send channels.actions Increment) ] [ text "+" ]
    , div [ countStyle ] []
    , button [ onClick (send channels.delete ()) ] [ text "X" ]
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
