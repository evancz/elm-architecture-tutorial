import Html exposing (..)
import Html.App as App
import Html.Attributes exposing (..)
import Gif



main =
  App.program
    { init = init "funny cats" "funny dogs"
    , view = view
    , update = update
    , subscriptions = subscriptions
    }



-- MODEL


type alias Model =
  { left : Gif.Model
  , right : Gif.Model
  }


init : String -> String -> ( Model, Cmd Msg )
init leftTopic rightTopic =
  let
    (left, leftFx) =
      Gif.init leftTopic

    (right, rightFx) =
      Gif.init rightTopic
  in
    ( Model left right
    , Cmd.batch
        [ Cmd.map Left leftFx
        , Cmd.map Right rightFx
        ]
    )



-- UPDATE


type Msg
  = Left Gif.Msg
  | Right Gif.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    Left leftMsg ->
      let
        (left, leftCmds) =
          Gif.update leftMsg model.left
      in
        ( Model left model.right
        , Cmd.map Left leftCmds
        )

    Right rightMsg ->
      let
        (right, rightCmds) =
          Gif.update rightMsg model.right
      in
        ( Model model.left right
        , Cmd.map Right rightCmds
        )



-- VIEW


view : Model -> Html Msg
view model =
  div
    [ style [ ("display", "flex") ]
    ]
    [ App.map Left (Gif.view model.left)
    , App.map Right (Gif.view model.right)
    ]



-- SUBS


subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.batch
    [ Sub.map Left (Gif.subscriptions model.left)
    , Sub.map Right (Gif.subscriptions model.right)
    ]
