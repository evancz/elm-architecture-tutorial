import Html exposing (Html)
import Counter exposing (update, view)
import StartApp.Simple exposing (start)

main : Signal Html
main =
  start
    { model = 0
    , update = update
    , view = view
    }
