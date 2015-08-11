module SpinSquarePair where

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import SpinSquare
import Start
import Task
import Transaction exposing (Transaction, done, tag, with, with2, Never)


app =
  Start.start
    { init = init
    , update = update
    , view = view
    , inputs = []
    }


main =
  app.html


port tasks : Signal (Task.Task Never ())
port tasks =
  app.tasks


-- MODEL

type alias Model =
    { left : SpinSquare.Model
    , right : SpinSquare.Model
    }


init : Transaction Message Model
init =
  with2
    (tag Left SpinSquare.init)
    (tag Right SpinSquare.init)
    (\left right -> done { left = left, right = right })


-- UPDATE

type Message
    = Left SpinSquare.Message
    | Right SpinSquare.Message


update : Message -> Model -> Transaction Message Model
update message model =
  case message of
    Left msg ->
      with
        (tag Left <| SpinSquare.update msg model.left)
        (\left -> done { model | left <- left })

    Right msg ->
      with
        (tag Right <| SpinSquare.update msg model.right)
        (\right -> done { model | right <- right })


-- VIEW

(=>) = (,)


view : Signal.Address Message -> Model -> Html
view address model =
  div [ style [ "display" => "flex" ] ]
    [ SpinSquare.view (Signal.forwardTo address Left) model.left
    , SpinSquare.view (Signal.forwardTo address Right) model.right
    ]