module Main exposing (Model, Msg(..), init, main, subscriptions, update, view)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Random
import Svg
import Svg.Attributes



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
    { dieFace : Int
    , die : Die
    }


type alias Die =
    { width : Int
    , height : Int
    , stroke : String
    , fill : String
    , dot : Dot
    }


type alias Dot =
    { radius : Int
    , stroke : String
    , fill : String
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( Model 1
        (Die
            100
            100
            "hsl(0, 0%, 87%)"
            "hsl(0, 0%, 95%)"
            (Dot
                12
                "hsl(0, 100%, 50%)"
                "hsl(0, 90%, 50%)"
            )
        )
    , Cmd.none
    )



-- UPDATE


type Msg
    = Roll
    | NewFace Int


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Roll ->
            ( model
            , Random.generate NewFace (Random.int 1 6)
            )

        NewFace newFace ->
            ( { model | dieFace = newFace }
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
        [ p []
            [ diceFacing model.dieFace model.die
            ]
        , button [ onClick Roll ] [ Html.text "Roll" ]
        ]


dieRectangle : Die -> Html Msg
dieRectangle die =
    Svg.rect
        [ Svg.Attributes.x "0"
        , Svg.Attributes.y "0"
        , Svg.Attributes.width <| String.fromInt die.width
        , Svg.Attributes.height <| String.fromInt die.height
        , Svg.Attributes.rx <| String.fromInt die.dot.radius
        , Svg.Attributes.ry <| String.fromInt die.dot.radius
        , Svg.Attributes.stroke die.stroke
        , Svg.Attributes.fill die.fill
        ]
        []


dieDot : Die -> Int -> Html Msg
dieDot die position =
    let
        dx =
            2 * die.width // 7

        ddx =
            dx // 4

        dy =
            2 * die.height // 7

        ddy =
            dy // 4

        nx =
            modBy 3 (position - 1) + 1

        ny =
            ((position - 1) // 3) + 1

        x =
            nx * dx - ddx

        y =
            ny * dy - ddy
    in
    Svg.circle
        [ Svg.Attributes.cx <| String.fromInt x
        , Svg.Attributes.cy <| String.fromInt y
        , Svg.Attributes.r <| String.fromInt die.dot.radius
        , Svg.Attributes.stroke die.dot.stroke
        , Svg.Attributes.fill die.dot.fill
        ]
        []


diceFacing : Int -> Die -> Html Msg
diceFacing face die =
    Svg.svg
        [ Svg.Attributes.viewBox <|
            "0 0 "
                ++ String.fromInt die.width
                ++ " "
                ++ String.fromInt die.height
        , Svg.Attributes.width <| String.fromInt die.width
        , Svg.Attributes.height <| String.fromInt die.height
        ]
        (if face == 1 then
            [ dieRectangle die
            , dieDot die 5
            ]

         else if face == 2 then
            [ dieRectangle die
            , dieDot die 3
            , dieDot die 7
            ]

         else if face == 3 then
            [ dieRectangle die
            , dieDot die 3
            , dieDot die 5
            , dieDot die 7
            ]

         else if face == 4 then
            [ dieRectangle die
            , dieDot die 1
            , dieDot die 3
            , dieDot die 7
            , dieDot die 9
            ]

         else if face == 5 then
            [ dieRectangle die
            , dieDot die 1
            , dieDot die 3
            , dieDot die 5
            , dieDot die 7
            , dieDot die 9
            ]

         else if face == 6 then
            [ dieRectangle die
            , dieDot die 1
            , dieDot die 3
            , dieDot die 4
            , dieDot die 6
            , dieDot die 7
            , dieDot die 9
            ]

         else
            [ dieRectangle die
            , dieDot die 1
            , dieDot die 2
            , dieDot die 3
            , dieDot die 4
            , dieDot die 5
            , dieDot die 6
            , dieDot die 7
            , dieDot die 8
            , dieDot die 9
            ]
        )
