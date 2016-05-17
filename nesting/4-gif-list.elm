import Gif
import Html exposing (..)
import Html.App as App
import Html.Attributes exposing (..)
import Html.Events as Events exposing (on, onInput)
import Json.Decode as Json



main =
  App.program
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }



-- MODEL


type alias Model =
  { topic : String
  , gifs : List Gif
  , uid : Int
  }


type alias Gif =
  { id : Int
  , model : Gif.Model
  }


init : ( Model, Cmd Msg )
init =
  ( Model "" [] 0, Cmd.none )



-- UPDATE


type Msg
  = Topic String
  | Create
  | SubMsg Int Gif.Msg


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    Topic topic ->
      ( { model | topic = topic }, Cmd.none )

    Create ->
      let
        id =
          model.uid

        (newGif, cmds) =
          Gif.init model.topic

        newGifs =
          model.gifs ++ [Gif id newGif]
      in
        ( Model "" newGifs (id + 1)
        , Cmd.map (SubMsg id) cmds
        )

    SubMsg id subMsg ->
      let
        (newGifs, cmds) =
          List.unzip (List.map (updateHelp id subMsg) model.gifs)
      in
        ( { model | gifs = newGifs }
        , Cmd.batch cmds
        )


updateHelp : Int -> Gif.Msg -> Gif -> ( Gif, Cmd Msg )
updateHelp id msg gif =
  if gif.id /= id then
    ( gif, Cmd.none )

  else
    let
      ( newGif, cmds ) =
        Gif.update msg gif.model
    in
      ( Gif id newGif
      , Cmd.map (SubMsg id) cmds
      )



-- VIEW


view : Model -> Html Msg
view model =
  div []
    [ input
        [ placeholder "What kind of gifs do you want?"
        , value model.topic
        , onEnter Create
        , onInput Topic
        , inputStyle
        ]
        []
    , div
        [ style [ ("display", "flex"), ("flex-wrap", "wrap") ]
        ]
        (List.map viewGif model.gifs)
    ]


viewGif : Gif -> Html Msg
viewGif {id, model} =
  App.map (SubMsg id) (Gif.view model)


inputStyle : Attribute msg
inputStyle =
  style
    [ ("width", "100%")
    , ("height", "40px")
    , ("padding", "10px 0")
    , ("font-size", "2em")
    , ("text-align", "center")
    ]


onEnter : msg -> Attribute msg
onEnter msg =
  on "keydown" (Json.map (always msg) (Json.customDecoder Events.keyCode is13))


is13 : Int -> Result String ()
is13 code =
  if code == 13 then
    Ok ()

  else
    Err "not the right key code"



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.batch (List.map subHelp model.gifs)


subHelp : Gif -> Sub Msg
subHelp {id, model} =
  Sub.map (SubMsg id) (Gif.subscriptions model)
