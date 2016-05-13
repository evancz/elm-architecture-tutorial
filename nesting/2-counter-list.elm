import Counter
import Html exposing (..)
import Html.App as App
import Html.Attributes exposing (..)
import Html.Events exposing (..)



main =
  App.beginnerProgram
    { model = init
    , update = update
    , view = view
    }



-- MODEL


type alias Model =
    { counters : List ( ID, Counter.Model )
    , nextID : ID
    }


type alias ID = Int


init : Model
init =
  { counters = []
  , nextID = 0
  }



-- UPDATE


type Msg
  = Insert
  | Remove
  | Modify ID Counter.Msg


update : Msg -> Model -> Model
update msg model =
  case msg of
    Insert ->
      let
        newCounter =
          ( model.nextID, Counter.init 0 )

        newCounters =
          model.counters ++ [ newCounter ]
      in
        Model newCounters (model.nextID + 1)

    Remove ->
      { model | counters = List.drop 1 model.counters }

    Modify id counterMsg ->
      let
        updateCounter (counterID, counterModel) =
          if counterID == id then
            (counterID, Counter.update counterMsg counterModel)

          else
            (counterID, counterModel)
      in
        { model | counters = List.map updateCounter model.counters }



-- VIEW


view : Model -> Html Msg
view model =
  let
    remove =
      button [ onClick Remove ] [ text "Remove" ]

    insert =
      button [ onClick Insert ] [ text "Add" ]

    counters =
      List.map viewCounter model.counters
  in
    div [] ([remove, insert] ++ counters)


viewCounter : (ID, Counter.Model) -> Html Msg
viewCounter (id, model) =
  App.map (Modify id) (Counter.view model)