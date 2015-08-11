module SpinSquare (Model, Message, init, update, view) where

import Easing exposing (ease, easeOutBounce, float)
import Html exposing (Html)
import Http
import Json.Decode as Json
import Svg exposing (svg, rect, g, text, text')
import Svg.Attributes exposing (..)
import Svg.Events exposing (onClick)
import Task
import Transaction exposing (Transaction, done, requestTick, Never)


-- MODEL

type alias Model =
    { angle : Float
    , animationState : Maybe { prevClockTime : Float, count : Float }
    }


init : Transaction Message Model
init =
  done { angle = 0, animationState = Nothing }


rotateStep = 90


-- UPDATE

type Message
    = Spin
    | Tick Float


update : Message -> Model -> Transaction Message Model
update msg model =
  case msg of
    Spin ->
      case model.animationState of
        Nothing ->
          requestTick Tick model

        Just _ ->
          done model

    Tick clockTime ->
      let
        newCount =
          case model.animationState of
            Nothing ->
              0

            Just {count, prevClockTime} ->
              count + (clockTime - prevClockTime)
      in
        if newCount > 1000 then
          done
            { angle = model.angle + rotateStep
            , animationState = Nothing
            }
        else
          requestTick Tick
            { angle = model.angle
            , animationState = Just { count = newCount, prevClockTime = clockTime }
            }


-- VIEW

view : Signal.Address Message -> Model -> Html
view address model =
  let
    angle =
      case model.animationState of
        Nothing ->
          model.angle

        Just {count} ->
          model.angle + ease easeOutBounce float 0 rotateStep 1000 count
  in
    svg
      [ width "200", height "200", viewBox "0 0 200 200" ]
      [ g [ transform ("translate(100, 100) rotate(" ++ toString angle ++ ")")
          , onClick (Signal.message address Spin)
          ]
          [ rect
              [ x "-50"
              , y "-50"
              , width "100"
              , height "100"
              , rx "15"
              , ry "15"
              , style "fill: #60B5CC;"
              ]
              []
          , text' [ fill "white", textAnchor "middle" ] [ text "Click me!" ]
          ]
      ]
