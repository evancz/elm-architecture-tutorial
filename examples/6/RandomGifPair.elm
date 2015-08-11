module RandomGifPair where

import Effects exposing (Effects)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Task

import RandomGif


-- MODEL

type alias Model =
    { left : RandomGif.Model
    , right : RandomGif.Model
    }


init : String -> String -> (Model, Effects Action)
init leftTopic rightTopic =
  let
    (left, leftFx) = RandomGif.init leftTopic
    (right, rightFx) = RandomGif.init rightTopic
  in
    ( Model left right
    , Effects.batch
        [ Effects.map Left leftFx
        , Effects.map Right rightFx
        ]
    )


-- UPDATE

type Action
    = Left RandomGif.Action
    | Right RandomGif.Action


update : Action -> Model -> (Model, Effects Action)
update action model =
  case action of
    Left act ->
      let
        (left, fx) = RandomGif.update act model.left
      in
        ( Model left model.right
        , Effects.map Left fx
        )

    Right act ->
      let
        (right, fx) = RandomGif.update act model.right
      in
        ( Model model.left right
        , Effects.map Right fx
        )


-- VIEW

view : Signal.Address Action -> Model -> Html
view address model =
  div [ style [ ("display", "flex") ] ]
    [ RandomGif.view (Signal.forwardTo address Left) model.left
    , RandomGif.view (Signal.forwardTo address Right) model.right
    ]
