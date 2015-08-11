module RandomGifList where

import Effects as Fx exposing (Effects, map, batch, Never)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode as Json
import Start
import Task

import RandomGif as Gif


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
    { topic : String
    , gifList : List (Int, Gif.Model)
    , uid : Int
    }


init : (Model, Effects Message)
init =
    ( Model "" [] 0, Fx.none )


-- UPDATE

type Message
    = Topic String
    | Create
    | SubMsg Int Gif.Message


update : Message -> Model -> (Model, Effects Message)
update message model =
    case message of
        Topic topic ->
            ( { model | topic <- topic }
            , Fx.none
            )

        Create ->
            let
                (newRandomGif, fx) =
                    Gif.init model.topic

                newModel =
                    Model "" (model.gifList ++ [(model.uid, newRandomGif)]) (model.uid + 1)
            in
                ( newModel
                , map (SubMsg model.uid) fx
                )

        SubMsg msgId msg ->
            let
                subUpdate ((id, randomGif) as entry) =
                    if id == msgId then
                        let
                            (newRandomGif, fx) = Gif.update msg randomGif
                        in
                            ( (id, newRandomGif)
                            , map (SubMsg id) fx
                            )
                    else
                        (entry, Fx.none)

                (newGifList, fxList) =
                    model.gifList
                        |> List.map subUpdate
                        |> List.unzip
            in
                ( { model | gifList <- newGifList }
                , batch fxList
                )


-- VIEW

(=>) = (,)


view : Signal.Address Message -> Model -> Html
view address model =
    div []
        [ input
            [ placeholder "What kind of gifs do you want?"
            , value model.topic
            , onEnter address Create
            , on "input" targetValue (Signal.message address << Topic)
            , inputStyle
            ]
            []
        , div [ style [ "display" => "flex", "flex-wrap" => "wrap" ] ]
            (List.map (elementView address) model.gifList)
        ]


elementView : Signal.Address Message -> (Int, Gif.Model) -> Html
elementView address (id, model) =
    Gif.view (Signal.forwardTo address (SubMsg id)) model


inputStyle : Attribute
inputStyle =
    style
        [ ("width", "100%")
        , ("height", "40px")
        , ("padding", "10px 0")
        , ("font-size", "2em")
        , ("text-align", "center")
        ]


onEnter : Signal.Address a -> a -> Attribute
onEnter address value =
    on "keydown"
        (Json.customDecoder keyCode is13)
        (\_ -> Signal.message address value)


is13 : Int -> Result String ()
is13 code =
    if code == 13 then Ok () else Err "not the right key code"
