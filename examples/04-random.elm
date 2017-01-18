import Html exposing (..)
import Html.Events exposing (..)
import Html.Attributes exposing (src)
import Random


main =
  Html.program
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }



-- MODEL


type alias Model =
  { dieFace : (Int, Int)
  }


init : (Model, Cmd Msg)
init =
  (Model (1,1), Cmd.none)


-- UPDATE


type Msg
  = Roll
  | NewFace (Int, Int)


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    Roll ->
      (model, Random.generate NewFace (Random.pair (Random.int 1 5) (Random.int 1 5)))

    NewFace pair ->
      (Model pair, Cmd.none)


-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none



-- VIEW


view : Model -> Html Msg
view model =
  let
    (a,b) = model.dieFace
  in
  div []
    [ h1 [] [ text (toString a) ]
    , h1 [] [ text (toString b) ]
    , img [src ("http://www.homeschoolmath.net/teaching/a/images/dieface-" ++ (toString a) ++ ".gif") ] []
    , img [src ("http://www.homeschoolmath.net/teaching/a/images/dieface-" ++ (toString b) ++ ".gif") ] []
    , button [ onClick Roll ] [ text "Roll" ]
    ]
