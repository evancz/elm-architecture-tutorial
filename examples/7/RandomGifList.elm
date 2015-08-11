module RandomGifList where

import Effects exposing (Effects, map, batch, Never)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode as Json
import Task

import RandomGif


-- MODEL

type alias Model =
    { topic : String
    , gifList : List (Int, RandomGif.Model)
    , uid : Int
    }


init : (Model, Effects Action)
init =
    ( Model "" [] 0
    , Effects.none
    )


-- UPDATE

type Action
    = Topic String
    | Create
    | SubMsg Int RandomGif.Action


update : Action -> Model -> (Model, Effects Action)
update message model =
    case message of
        Topic topic ->
            ( { model | topic <- topic }
            , Effects.none
            )

        Create ->
            let
                (newRandomGif, fx) =
                    RandomGif.init model.topic

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
                            (newRandomGif, fx) = RandomGif.update msg randomGif
                        in
                            ( (id, newRandomGif)
                            , map (SubMsg id) fx
                            )
                    else
                        (entry, Effects.none)

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


view : Signal.Address Action -> Model -> Html
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


elementView : Signal.Address Action -> (Int, RandomGif.Model) -> Html
elementView address (id, model) =
    RandomGif.view (Signal.forwardTo address (SubMsg id)) model


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
