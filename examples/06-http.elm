module Main exposing (Model, Msg(..), getRandomGif, gifDecoder, init, main, subscriptions, toGiphyUrl, update, view)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Json.Decode as Decode
import Url.Builder as Url



-- MAIN


main =
    Browser.element
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }



-- MODEL


type alias Model =
    { topic : String
    , url : String
    , error : String
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( Model "cat" "waiting.gif" ""
    , getRandomGif "cat"
    )



-- UPDATE


type Msg
    = MorePlease
    | NewGif (Result Http.Error String)
    | TopicChange String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        TopicChange newTopic ->
            ( { model | topic = newTopic }
            , Cmd.none
            )

        MorePlease ->
            ( model
            , getRandomGif model.topic
            )

        NewGif result ->
            case result of
                Ok newUrl ->
                    ( { model | url = newUrl, error = "" }
                    , Cmd.none
                    )

                Err error ->
                    let
                        errorMessage =
                            case error of
                                Http.BadUrl errorString ->
                                    "Invalid URL provided."

                                Http.Timeout ->
                                    "It's taking too much time. Please retry."

                                Http.NetworkError ->
                                    "Could not connect to the network. Please check your connection and try again."

                                Http.BadStatus response ->
                                    Debug.toString response.status.code
                                        ++ ": "
                                        ++ response.status.message

                                Http.BadPayload message response ->
                                    let
                                        _ =
                                            Debug.log "Response: " response
                                    in
                                    "Bad Payload: " ++ message
                    in
                    ( { model | error = errorMessage }
                    , Cmd.none
                    )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ h2 [] [ text model.topic ]
        , p []
            [ label [ for "topic" ]
                [ text "Topic: " ]
            , select [ id "topic", onInput TopicChange ]
                [ option [ value "cat" ] [ text "Cat" ]
                , option [ value "dog" ] [ text "Dog" ]
                , option [ value "minions" ] [ text "Minions" ]
                , option [ value "pingu" ] [ text "Pingu" ]
                ]
            ]
        , button [ onClick MorePlease ] [ text "More Please!" ]
        , br [] []
        , img [ src model.url ] []
        , p [] [ text model.error ]
        ]



-- HTTP


getRandomGif : String -> Cmd Msg
getRandomGif topic =
    Http.send NewGif (Http.get (toGiphyUrl topic) gifDecoder)


toGiphyUrl : String -> String
toGiphyUrl topic =
    Url.crossOrigin "https://api.giphy.com"
        [ "v1", "gifs", "random" ]
        [ Url.string "api_key" "dc6zaTOxFJmzC"
        , Url.string "tag" topic
        ]


gifDecoder : Decode.Decoder String
gifDecoder =
    Decode.field "data" (Decode.field "image_url" Decode.string)
