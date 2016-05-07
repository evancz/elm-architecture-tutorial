
import Counter exposing (init, update, view)
import StartApp.Simple exposing (start)


main =
  start
    { model = init 0
    , update = update
    , view = view
    }
