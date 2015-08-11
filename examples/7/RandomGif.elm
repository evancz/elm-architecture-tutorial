module RandomGif (Model, init, Message, update, view) where

import Effects as Fx exposing (Effects, Never)
import Html exposing (..)
import Html.Attributes exposing (style)
import Html.Events exposing (onClick)
import Http
import Json.Decode as Json
import Start
import Task


-- MODEL

type alias Model =
    { topic : String
    , image : String
    }


init : String -> (Model, Effects Message)
init topic =
  ( Model topic "assets/waiting.gif"
  , getRandomImage topic
  )


-- UPDATE

type Message
    = RequestMore
    | NewImage (Maybe String)


update : Message -> Model -> (Model, Effects Message)
update msg model =
  case msg of
    RequestMore ->
      (model, getRandomImage model.topic)

    NewImage maybeUrl ->
      ( Model model.topic (Maybe.withDefault model.image maybeUrl)
      , Fx.none
      )


-- VIEW

(=>) = (,)


view : Signal.Address Message -> Model -> Html
view address model =
  div [ style [ "width" => "200px" ] ]
    [ h2 [headerStyle] [text model.topic]
    , div [imgStyle model.image] []
    , button [ onClick address RequestMore ] [ text "More Please!" ]
    ]


headerStyle : Attribute
headerStyle =
  style
    [ "width" => "200px"
    , "text-align" => "center"
    ]


imgStyle : String -> Attribute
imgStyle url =
  style
    [ "display" => "inline-block"
    , "width" => "200px"
    , "height" => "200px"
    , "background-position" => "center center"
    , "background-size" => "cover"
    , "background-image" => ("url('" ++ url ++ "')")
    ]


-- EFFECTS

getRandomImage : String -> Effects Message
getRandomImage topic =
  Http.get decodeImageUrl (randomUrl topic)
    |> Task.toMaybe
    |> Task.map NewImage
    |> Fx.task


randomUrl : String -> String
randomUrl topic =
  Http.url "http://api.giphy.com/v1/gifs/random"
    [ "api_key" => "dc6zaTOxFJmzC"
    , "tag" => topic
    ]


decodeImageUrl : Json.Decoder String
decodeImageUrl =
  Json.at ["data", "image_url"] Json.string
