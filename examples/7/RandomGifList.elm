module RandomGifList where

import Effects exposing (Effects, map, batch, Never)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode as Json

import RandomGif


-- MODEL

type alias Model =
    { topic : String
    , randomGifs : List (ID, RandomGif.Model)
    , nextID : ID
    }

type alias ID = Int


init : (Model, Effects Action)
init =
    ( Model "" [] 0
    , Effects.none
    )


-- UPDATE

type Action
    = Topic String
    | Insert
    | Modify ID RandomGif.Action


update : Action -> Model -> (Model, Effects Action)
update message model =
    case message of
        Topic topic ->
            ( { model | topic = topic }
            , Effects.none
            )

        Insert ->
            let
                (newRandomGif, newRandomGifEffects) =
                    RandomGif.init model.topic

                newRandomGifEntry =
                  (model.nextID, newRandomGif)

                newRandomGifs =
                  model.randomGifs ++ [newRandomGifEntry]

                newModel =
                    Model "" newRandomGifs (model.nextID + 1)

                newEffects =
                  Effects.map (Modify model.nextID) newRandomGifEffects
            in
                (newModel, newEffects)

        Modify id randomGifAction ->
            let
                updateRandomGif randomGif =
                  RandomGif.update randomGifAction randomGif

                newRandomGifEntry randomGifID randomGif =
                  let
                      (newRandomGif, newRandomGifEffects) =
                        updateRandomGif randomGif

                      newEntryEffects =
                        Effects.map (Modify randomGifID) newRandomGifEffects
                  in
                      ((randomGifID, newRandomGif), newEntryEffects)

                updateRandomGifEntry ((randomGifID, randomGif) as entry) =
                    if randomGifID == id then
                        newRandomGifEntry randomGifID randomGif
                    else
                        (entry, Effects.none)

                (newRandomGifs, newEffectsList) =
                    model.randomGifs
                        |> List.map updateRandomGifEntry
                        |> List.unzip

                newModel =
                  { model |
                    randomGifs = newRandomGifs }

                newEffects =
                  Effects.batch newEffectsList
            in
              (newModel, newEffects)


-- VIEW

(=>) = (,)


view : Signal.Address Action -> Model -> Html
view address model =
    div []
        [ input
            [ placeholder "What kind of gifs do you want?"
            , value model.topic
            , onEnter address Insert
            , on "input" targetValue (Signal.message address << Topic)
            , inputStyle
            ]
            []
        , div [ style [ "display" => "flex", "flex-wrap" => "wrap" ] ]
            (List.map (elementView address) model.randomGifs)
        ]


elementView : Signal.Address Action -> (Int, RandomGif.Model) -> Html
elementView address (id, model) =
    RandomGif.view (Signal.forwardTo address (Modify id)) model


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
    if code == 13 then
        Ok ()

    else
        Err "not the right key code"
