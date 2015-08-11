
import RandomGifList exposing (init, update, view)
import StartApp


app =
  StartApp.start
    { init = init "funny cats" "funny dogs"
    , update = update
    , view = view
    , inputs = []
    }


main =
  app.html


port tasks : Signal (Task.Task Never ())
port tasks =
  app.tasks


