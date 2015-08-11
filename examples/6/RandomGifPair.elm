module RandomGifPair where

import Effects as Fx exposing (Effects, map, batch, Never)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Start
import Task

import RandomGif as Gif


app =
  Start.start
    { init = init "funny cats" "funny dogs"
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
    { left : Gif.Model
    , right : Gif.Model
    }


init : String -> String -> (Model, Effects Message)
init leftTopic rightTopic =
  let
    (model1, fx1) = Gif.init leftTopic
    (model2, fx2) = Gif.init rightTopic
  in
    ( Model model1 model2
    , batch [map Left fx1, map Right fx2]
    )


-- UPDATE

type Message
    = Left Gif.Message
    | Right Gif.Message


update : Message -> Model -> (Model, Effects Message)
update message model =
  case message of
    Left msg ->
      let
        (left, fx) = Gif.update msg model.left
      in
        ( Model left model.right
        , map Left fx
        )

    Right msg ->
      let
        (right, fx) = Gif.update msg model.right
      in
        ( Model model.left right
        , map Right fx
        )


-- VIEW

(=>) = (,)


view : Signal.Address Message -> Model -> Html
view address model =
  div [ style [ "display" => "flex" ] ]
    [ Gif.view (Signal.forwardTo address Left) model.left
    , Gif.view (Signal.forwardTo address Right) model.right
    ]