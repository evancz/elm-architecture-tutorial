# The Elm Architecture

This tutorial outlines “The Elm Architecture” which you will see in all [Elm][] programs, from [TodoMVC][] and [dreamwriter][] to the code running in production at [NoRedInk][] and [CircuitHub][]. The basic pattern is useful whether you are writing your front-end in Elm or JS or whatever else.

[Elm]: http://elm-lang.org/
[TodoMVC]: https://github.com/evancz/elm-todomvc
[dreamwriter]: https://github.com/rtfeldman/dreamwriter#dreamwriter
[NoRedInk]: https://www.noredink.com/
[CircuitHub]: https://www.circuithub.com/

The Elm Architecture is a simple pattern for infinitely nestable components. It is great for modularity, code reuse, and testing. Ultimately, this pattern makes it easy to create complex web apps in a way that stays modular. We will run through 8 examples, slowly building on core principles and patterns:

  1. [Counter](http://evancz.github.io/elm-architecture-tutorial/examples/1.html)
  2. [Pair of counters](http://evancz.github.io/elm-architecture-tutorial/examples/2.html)
  3. [List of counters](http://evancz.github.io/elm-architecture-tutorial/examples/3.html)
  4. [List of counters (variation)](http://evancz.github.io/elm-architecture-tutorial/examples/4.html)
  5. [GIF fetcher](http://evancz.github.io/elm-architecture-tutorial/examples/5.html)
  6. [Pair of GIF fetchers](http://evancz.github.io/elm-architecture-tutorial/examples/6.html)
  7. [List of GIF fetchers](http://evancz.github.io/elm-architecture-tutorial/examples/7.html)
  8. [Pair of animating squares](http://evancz.github.io/elm-architecture-tutorial/examples/8.html)

This tutorial will really help! It will bring out the concepts and ideas necessary to get to make examples 7 and 8 super easy. Investing in the foundation will be worth it!

One very interesting aspect of the architecture in all these programs is that it *emerges* from Elm naturally. The language design itself leads you towards this architecture whether you have read this document and know the benefits or not. I actually discovered this pattern just using Elm and have been shocked by its simplicity and power.

**Note**: To follow along with this tutorial with code, [install Elm](http://elm-lang.org/install) and fork this repo. Each example in the tutorial gives instructions of how to run the code.


## The Basic Pattern

The logic of every Elm program will break up into three cleanly separated parts:

  * model
  * update
  * view

You can pretty reliably start with the following skeleton and then iteratively fill in details for your particular case.

> If you are new to reading Elm code, check out the [language docs](http://elm-lang.org/docs) which covers everything from syntax to getting into a “functional mindset”. The first two sections of [the complete guide](http://elm-lang.org/docs#complete-guide) will get you up to speed!

```elm
-- MODEL

type alias Model = { ... }


-- UPDATE

type Action = Reset | ...

update : Action -> Model -> Model
update action model =
  case action of
    Reset -> ...
    ...


-- VIEW

view : Model -> Html
view =
  ...
```

This tutorial is all about this pattern and small variations and extensions.


## Example 1: A Counter

**[demo](http://evancz.github.io/elm-architecture-tutorial/examples/1.html) / [see code](examples/1/)**

Our first example is a simple counter that can be incremented or decremented.

[The code](examples/1/Counter.elm) starts with a very simple model. We just need to keep track of a single number:

```elm
type alias Model = Int
```

When it comes to updating our model, things are relatively simple again. We define a set of actions that can be performed, and an `update` function to actually perform those actions:

```elm
type Action = Increment | Decrement

update : Action -> Model -> Model
update action model =
  case action of
    Increment -> model + 1
    Decrement -> model - 1
```

Notice that our `Action` [union type][] does not *do* anything. It simply describes the actions that are possible. If someone decides our counter should be doubled when a certain button is pressed, that will be a new case in `Action`. This means our code ends up very clear about how our model can be transformed. Anyone reading this code will immediately know what is allowed and what is not. Furthermore, they will know exactly how to add new features in a consistent way.

[union type]: http://elm-lang.org/learn/Union-Types.elm

Finally, we create a way to `view` our `Model`. We are using [elm-html][] to create some HTML to show in a browser. We will create a div that contains: a decrement button, a div showing the current count, and an increment button.

[elm-html]: http://elm-lang.org/blog/Blazing-Fast-Html.elm

```elm
view : Signal.Address Action -> Model -> Html
view address model =
  div []
    [ button [ onClick address Decrement ] [ text "-" ]
    , div [ countStyle ] [ text (toString model) ]
    , button [ onClick address Increment ] [ text "+" ]
    ]

countStyle : Attribute
countStyle =
  ...
```

The tricky thing about our `view` function is the `Address`. We will dive into that in the next section! For now, I just want you to notice that **this code is entirely declarative**. We take in a `Model` and produce some `Html`. That is it. At no point do we mutate the DOM manually, which gives the library [much more freedom to make clever optimizations][elm-html] and actually makes rendering *faster* overall. It is crazy. Furthermore, `view` is a plain old function so we can get the full power of Elm&rsquo;s module system, test frameworks, and libraries when creating views.

This pattern is the essence of architecting Elm programs. Every example we see from now on will be a slight variation on this basic pattern: `Model`, `update`, `view`.


## Starting the Program

Pretty much all Elm programs will have a small bit of code that drives the whole application. For each example in this tutorial, that code is broken out into `Main.elm`. For our counter example, the interesting code looks like this:

```elm
import Counter exposing (update, view)
import StartApp.Simple exposing (start)

main =
  start { model = 0, update = update, view = view }
```

We are using the [`StartApp`](https://github.com/evancz/start-app) package to wire together our initial model with the update and view functions. It is a small wrapper around Elm's [signals](http://elm-lang.org/learn/Using-Signals.elm) so that you do not need to dive into that concept yet.

The key to wiring up your application is the concept of an `Address`. Every event handler in our `view` function reports to a particular address. It just sends chunks of data along. The `StartApp` package monitors all the messages coming in to this address and feeds them into the `update` function. The model gets updated and [elm-html][] takes care of rendering the changes efficiently.

This means values flow through an Elm program in only one direction, something like this:

![Signal Graph Summary](diagrams/signal-graph-summary.png)

The blue part is our core Elm program which is exactly the model/update/view pattern we have been discussing so far. When programming in Elm, you can mostly think inside this box and make great progress.

Notice we are not *performing* actions as they get sent back to our app. We are simply sending some data over. This separation is a key detail, keeping our logic totally separate from our view code.


## Example 2: A Pair of Counters

**[demo](http://evancz.github.io/elm-architecture-tutorial/examples/2.html) / [see code](examples/2/)**

In example 1 we created a basic counter, but how does that pattern scale when we want *two* counters? Can we keep things modular?

Wouldn't it be great if we could reuse all the code from example 1? The crazy thing about the Elm Architecture is that **we can reuse code with absolutely no changes**. When we created the `Counter` module in example one, it encapsulated all the implementation details so we can use them elsewhere:

```elm
module Counter (Model, init, Action, update, view) where

type Model

init : Int -> Model

type Action

update : Action -> Model -> Model

view : Signal.Address Action -> Model -> Html
```

Creating modular code is all about creating strong abstractions. We want boundaries which appropriately expose functionality and hide implementation. From outside of the `Counter` module, we just see a basic set of values: `Model`, `init`, `Action`, `update`, and `view`. We do not care at all how these things are implemented. In fact, it is *impossible* to know how these things are implemented. This means no one can rely on implementation details that were not made public.

So we can reuse our `Counter` module, but now we need to use it to create our `CounterPair`. As always, we start with a `Model`:

```elm
type alias Model =
    { topCounter : Counter.Model
    , bottomCounter : Counter.Model
    }

init : Int -> Int -> Model
init top bottom =
    { topCounter = Counter.init top
    , bottomCounter = Counter.init bottom
    }
```

Our `Model` is a record with two fields, one for each of the counters we would like to show on screen. This fully describes all of the application state. We also have an `init` function to create a new `Model` whenever we want.

Next we describe the set of `Actions` we would like to support. This time our features should be: reset all counters, update the top counter, or update the bottom counter.

```elm
type Action
    = Reset
    | Top Counter.Action
    | Bottom Counter.Action
```

Notice that our [union type][] refers to the `Counter.Action` type, but we do not know the particulars of those actions. When we create our `update` function, we are mainly routing these `Counter.Actions` to the right place:

```elm
update : Action -> Model -> Model
update action model =
  case action of
    Reset -> init 0 0

    Top act ->
      { model |
          topCounter = Counter.update act model.topCounter
      }

    Bottom act ->
      { model |
          bottomCounter = Counter.update act model.bottomCounter
      }
```

So now the final thing to do is create a `view` function that shows both of our counters on screen along with a reset button.

```elm
view : Signal.Address Action -> Model -> Html
view address model =
  div []
    [ Counter.view (Signal.forwardTo address Top) model.topCounter
    , Counter.view (Signal.forwardTo address Bottom) model.bottomCounter
    , button [ onClick address Reset ] [ text "RESET" ]
    ]
```

Notice that we are able to reuse the `Counter.view` function for both of our counters. For each counter we create a forwarding address. Essentially what we are doing here is saying, &ldquo;these counters will tag all outgoing messages with `Top` or `Bottom` so we can tell the difference.&rdquo;

That is the whole thing. The cool thing is that we can keep nesting more and more. We can take the `CounterPair` module, expose the key values and functions, and create a `CounterPairPair` or whatever it is we need.


## Example 3: A Dynamic List of Counters

**[demo](http://evancz.github.io/elm-architecture-tutorial/examples/3.html) / [see code](examples/3/)**

A pair of counters is cool, but what about a list of counters where we can add and remove counters as we see fit? Can this pattern work for that too?

Again we can reuse the `Counter` module exactly as it was in example 1 and 2!

```elm
module Counter (Model, init, Action, update, view)
```

That means we can just get started on our `CounterList` module. As always, we begin with our `Model`:

```elm
type alias Model =
    { counters : List ( ID, Counter.Model )
    , nextID : ID
    }

type alias ID = Int
```

Now our model has a list of counters, each annotated with a unique ID. These IDs allow us to distinguish between them, so if we need to update counter number 4 we have a nice way to refer to it. (This ID also gives us something convenient to [`key`][key] on when we are thinking about optimizing rendering, but that is not the focus of this tutorial!) Our model also contains a
`nextID` which helps us assign unique IDs to each counter as we add new ones.

[key]: http://package.elm-lang.org/packages/evancz/elm-html/latest/Html-Attributes#key

Now we can define the set of `Actions` that can be performed on our model. We want to be able to add counters, remove counters, and update certain counters.

```elm
type Action
    = Insert
    | Remove
    | Modify ID Counter.Action
```

Our `Action` [union type][] is shockingly close to the high-level description. Now we can define our `update` function.

```elm
update : Action -> Model -> Model
update action model =
  case action of
    Insert ->
      let newCounter = ( model.nextID, Counter.init 0 )
          newCounters = model.counters ++ [ newCounter ]
      in
          { model |
              counters = newCounters,
              nextID = model.nextID + 1
          }

    Remove ->
      { model | counters = List.drop 1 model.counters }

    Modify id counterAction ->
      let updateCounter (counterID, counterModel) =
            if counterID == id
                then (counterID, Counter.update counterAction counterModel)
                else (counterID, counterModel)
      in
          { model | counters = List.map updateCounter model.counters }
```

Here is a high-level description of each case:

  * `Insert` &mdash; First we create a new counter and put it at the end of
    our counter list. Then we increment our `nextID` so that we have a fresh
    ID next time around.

  * `Remove` &mdash; Drop the first member of our counter list.

  * `Modify` &mdash; Run through all of our counters. If we find one with
    a matching ID, we perform the given `Action` on that counter.

All that is left to do now is to define the `view`.

```elm
view : Signal.Address Action -> Model -> Html
view address model =
  let counters = List.map (viewCounter address) model.counters
      remove = button [ onClick address Remove ] [ text "Remove" ]
      insert = button [ onClick address Insert ] [ text "Add" ]
  in
      div [] ([remove, insert] ++ counters)

viewCounter : Signal.Address Action -> (ID, Counter.Model) -> Html
viewCounter address (id, model) =
  Counter.view (Signal.forwardTo address (Modify id)) model
```

The fun part here is the `viewCounter` function. It uses the same old
`Counter.view` function, but in this case we provide a forwarding address that annotates all messages with the ID of the particular counter that is getting rendered.

When we create the actual `view` function, we map `viewCounter` over all of our counters and create add and remove buttons that report to the `address` directly.

This ID trick can be used any time you want a dynamic number of subcomponents. Counters are very simple, but the pattern would work exactly the same if you had a list of user profiles or tweets or newsfeed items or product details.


## Example 4: A Fancier List of Counters

**[demo](http://evancz.github.io/elm-architecture-tutorial/examples/4.html) / [see code](examples/4/)**

Okay, keeping things simple and modular on a dynamic list of counters is pretty cool, but instead of a general remove button, what if each counter had its own specific remove button? Surely *that* will mess things up!

Nah, it works.

In this case our goals mean that we need a new way to view a `Counter` that adds a remove button. Interestingly, we can keep the `view` function from before and add a new `viewWithRemoveButton` function that provides a slightly different view of our underlying `Model`. This is pretty cool. We do not need to duplicate any code or do any crazy subtyping or overloading. We just add a new function to the public API to expose new functionality!

```elm
module Counter (Model, init, Action, update, view, viewWithRemoveButton, Context) where

...

type alias Context =
    { actions : Signal.Address Action
    , remove : Signal.Address ()
    }

viewWithRemoveButton : Context -> Model -> Html
viewWithRemoveButton context model =
  div []
    [ button [ onClick context.actions Decrement ] [ text "-" ]
    , div [ countStyle ] [ text (toString model) ]
    , button [ onClick context.actions Increment ] [ text "+" ]
    , div [ countStyle ] []
    , button [ onClick context.remove () ] [ text "X" ]
    ]
```

The `viewWithRemoveButton` function adds one extra button. Notice that the increment/decrement buttons send messages to the `actions` address but the delete button sends messages to the `remove` address. The messages we send along to `remove` are essentially saying, &ldquo;hey, whoever owns me, remove me!&rdquo; It is up to whoever owns this particular counter to do the removing.

Now that we have our new `viewWithRemoveButton`, we can create a `CounterList` module which puts all the individual counters together. The `Model` is the same as in example 3: a list of counters and a unique ID.

```elm
type alias Model =
    { counters : List ( ID, Counter.Model )
    , nextID : ID
    }

type alias ID = Int
```

Our set of actions is a bit different. Instead of removing any old counter, we want to remove a specific one, so the `Remove` case now holds an ID.

```elm
type Action
    = Insert
    | Remove ID
    | Modify ID Counter.Action
```

The `update` function is pretty similar to example 3 as well.

```elm
update : Action -> Model -> Model
update action model =
  case action of
    Insert ->
      { model |
          counters = ( model.nextID, Counter.init 0 ) :: model.counters,
          nextID = model.nextID + 1
      }

    Remove id ->
      { model |
          counters = List.filter (\(counterID, _) -> counterID /= id) model.counters
      }

    Modify id counterAction ->
      let updateCounter (counterID, counterModel) =
            if counterID == id
                then (counterID, Counter.update counterAction counterModel)
                else (counterID, counterModel)
      in
          { model | counters = List.map updateCounter model.counters }
```

In the case of `Remove`, we take out the counter that has the ID we are supposed to remove. Otherwise, the cases are quite close to how they were before.

Finally, we put it all together in the `view`:

```elm
view : Signal.Address Action -> Model -> Html
view address model =
  let insert = button [ onClick address Insert ] [ text "Add" ]
  in
      div [] (insert :: List.map (viewCounter address) model.counters)

viewCounter : Signal.Address Action -> (ID, Counter.Model) -> Html
viewCounter address (id, model) =
  let context =
        Counter.Context
          (Signal.forwardTo address (Modify id))
          (Signal.forwardTo address (always (Remove id)))
  in
      Counter.viewWithRemoveButton context model
```

In our `viewCounter` function, we construct the `Counter.Context` to pass in all the necessary forwarding addresses. In both cases we annotate each `Counter.Action` so that we know which counter to modify or remove.


## Big Lessons So Far

**Basic Pattern** &mdash; Everything is built around a `Model`, a way to `update` that model, and a way to `view` that model. Everything is a variation on this basic pattern.

**Nesting Modules** &mdash; Forwarding addresses makes it easy to nest our basic pattern, hiding implementation details entirely. We can nest this pattern arbitrarily deep, and each level only needs to know about what is going on one level lower.

**Adding Context** &mdash; Sometimes to `update` or `view` our model, extra information is needed. We can always add some `Context` to these functions and pass in all the additional information we need without complicating our `Model`.

```elm
update : Context -> Action -> Model -> Model
view : Context -> Model -> Html
```

At every level of nesting we can derive the specific `Context` needed for each submodule.

**Testing is Easy** &mdash; All of the functions we have created are [pure functions][pure]. That makes it extremely easy to test your `update` function. There is no special initialization or mocking or configuration step, you just call the function with the arguments you would like to test.

[pure]: http://en.wikipedia.org/wiki/Pure_function


## Example 5: Random GIF Viewer

**[demo](http://evancz.github.io/elm-architecture-tutorial/examples/5.html) / [see code](examples/5/)**

So we have covered how to create infinitely nestable components, but what happens when we want to do an HTTP request from somewhere in there? Or talk to a database? This example starts using [the `elm-effects` package][fx] to create a simple component that fetches random gifs from giphy.com with the topic “funny cats”. 

[fx]: http://package.elm-lang.org/packages/evancz/elm-effects/latest

As you look through [the implementation](examples/5/RandomGif.elm), notice that it is pretty much the same code as the counter in example 1. The `Model` is very typical:

```elm
type alias Model =
    { topic : String
    , gifUrl : String
    }
```

We need to know what the `topic` of the finder is and what `gifUrl` we are showing right this second. The only new thing in this example is that `init` and `update` have slightly fancier types:

```elm
init : String -> (Model, Effects Action)

update : Action -> Model -> (Model, Effects Action)
```

Instead of returning just a new `Model` we also give back some effects that we would like to run. So we will be using [the `Effects` API][fx_api], which looks something like this:

[fx_api]: http://package.elm-lang.org/packages/evancz/elm-effects/latest/Effects

```elm
module Effects where

type Effects a

none : Effects a
  -- don't do anything

task : Task Never a -> Effects a
  -- request a task, do HTTP and database stuff
```

The `Effects` type is essentially a data structure holding a bunch of independent tasks that will get run at some later point. Let’s get a better feeling of how this works by checking out how `update` works in this example:

```elm
type Action
    = RequestMore
    | NewGif (Maybe String)


update : Action -> Model -> (Model, Effects Action)
update msg model =
  case msg of
    RequestMore ->
      ( model
      , getRandomGif model.topic
      )

    NewGif maybeUrl ->
      ( Model model.topic (Maybe.withDefault model.gifUrl maybeUrl)
      , Effects.none
      )

-- getRandomGif : String -> Effects Action
```

So the user can trigger a `RequestMore` action by clicking the “More Please!” button, and when the server responds it will give us a `NewGif` action. We handle both these scenarios in our `update` function.

In the case of `RequestMore` first return the existing model. The user just clicked a button, there is nothing to change right now. We also create an `Effects Action` using the `getRandomGif` function. We will get to how `getRandomGif` is defined soon. For now we just need to know that when an `Effects Action` is run, it will produce a bunch of `Action` values that will be routed throughout the application. So `getRandomGif model.topic` will eventually result in an action like this:

```elm
NewGif (Just "http://s3.amazonaws.com/giphygifs/media/ka1aeBvFCSLD2/giphy.gif")
```

It returns a `Maybe` because the request to the server may fail. That `Action` will get fed right back into our `update` function. So when we take the `NewGif` route we just update the current `gifUrl` if possible. If the request failed, we just stick with the current `model.gifUrl`.

We see the same kind of thing happening in `init` which defines the initial model and asks for a GIF in the correct topic from giphy.com’s API.

```elm
init : String -> (Model, Effects Action)
init topic =
  ( Model topic "assets/waiting.gif"
  , getRandomGif topic
  )

-- getRandomGif : String -> Effects Action
```

Again, when the random GIF effect is complete, it will produce an `Action` that gets routed to our `update` function.

> **Note:** So far we have been using the `StartApp.Simple` module from [the start-app package](http://package.elm-lang.org/packages/evancz/start-app/latest), but now upgrade to the `StartApp` module. It is able to handle the complexity of more realistic web apps. It has [a slightly fancier API](http://package.elm-lang.org/packages/evancz/start-app/latest/StartApp). The crucial change is that it can handle our new `init` and `update` types.

One of the crucial aspects of this example is the `getRandomGif` function that actually describes how to get a random GIF. It uses [tasks][] and [the `Http` package][http], and I will try to give an overview of how these things are being used as we go. Let’s look at the definition:

[tasks]: http://elm-lang.org/guide/reactivity#tasks
[http]: http://package.elm-lang.org/packages/evancz/elm-http/latest

```elm
getRandomGif : String -> Effects Action
getRandomGif topic =
  Http.get decodeImageUrl (randomUrl topic)
    |> Task.toMaybe
    |> Task.map NewGif
    |> Effects.task

-- The first line there created an HTTP GET request. It tries to
-- get some JSON at `randomUrl topic` and decodes the result
-- with `decodeImageUrl`. Both are defined below!
--
-- Next we use `Task.toMaybe` to capture any potential failures and
-- apply the `NewGif` tag to turn the result into a `Action`.
-- Finally we turn it into an `Effects` value that can be used in our
-- `init` or `update` functions.


-- Given a topic, construct a URL for the giphy API.
randomUrl : String -> String
randomUrl topic =
  Http.url "http://api.giphy.com/v1/gifs/random"
    [ "api_key" => "dc6zaTOxFJmzC"
    , "tag" => topic
    ]


-- A JSON decoder that takes a big chunk of JSON spit out by
-- giphy and extracts the string at `json.data.image_url` 
decodeImageUrl : Json.Decoder String
decodeImageUrl =
  Json.at ["data", "image_url"] Json.string
```

Once we have written this up, we are able to reuse `getRandomGif` in our `init` and `update` functions.

One of the interesting things about the task returned by `getRandomGif` is that it can `Never` fail. The idea is that any potential failure *must* be handled explicitly. We do not want any tasks failing silently.

I am going to try to explain exactly how that works, but it is not crucial to get every piece of this to use things! Okay, so every `Task` has a failure type and a success type. For example, an HTTP task may have a type like this `Task Http.Error String` such that we can fail with an `Http.Error` or succeed with a `String`. This makes it nice to chain a bunch of tasks together without worrying too much about errors. Now lets say our component requests a task, but the task fails. What happens then? Who gets notified? How do we recover? By making the failure type `Never` we force any potential errors into the success type such that they can be handled explicitly by the component. In our case, we use `Task.toMaybe : Task x a -> Task y (Maybe a)` so our `update` function must explicitly handle HTTP failures. This means tasks cannot silently fail, you always handle potential errors explicitly.


## Example 6: Pair of random GIF viewers

**[demo](http://evancz.github.io/elm-architecture-tutorial/examples/6.html) / [see code](examples/6/)**

Alright, effects can be done, but what about *nested* effects? Did you think about that?! This example reuses the exact code from the GIF viewer in example 5 to create a pair of independent GIF viewers.

As you look through [the implementation](examples/6/RandomGifPair.elm), notice that it is pretty much the same code as the pair of counters in example 2. The `Model` is defined as two `RandomGif.Model` values:

```elm
type alias Model =
    { left : RandomGif.Model
    , right : RandomGif.Model
    }
```

This lets us keep track of each independently. Our actions are just routing messages to the appropriate subcomponent.

```elm
type Action
    = Left RandomGif.Action
    | Right RandomGif.Action
```

The interesting thing is that we actually use the `Left` and `Right` tags a bit in our `update` and `init` functions.

```elm
-- Effects.map : (a -> b) -> Effects a -> Effects b

update : Action -> Model -> (Model, Effects Action)
update action model =
  case action of
    Left msg ->
      let
        (left, fx) = RandomGif.update msg model.left
      in
        ( Model left model.right
        , Effects.map Left fx
        )

    Right msg ->
      let
        (right, fx) = RandomGif.update msg model.right
      in
        ( Model model.left right
        , Effects.map Right fx
        )
```

So in each branch we call the `RandomGif.update` function which is returning a new model and some effects we are calling `fx`. We return an updated model like normal, but we need to do some extra work on our effects. Instead of returning them directly, we use [`Effects.map`](http://package.elm-lang.org/packages/evancz/elm-effects/latest/Effects#map) function to turn them into the same kind of `Action`. This works very much like `Signal.forwardTo`, letting us tag the values to make it clear how they should be routed.

The same thing happens in the `init` function. We provide a topic for each random GIF viewer and get back an initial model and some effects.

```elm
init : String -> String -> (Model, Effects Action)
init leftTopic rightTopic =
  let
    (left, leftFx) = RandomGif.init leftTopic
    (right, rightFx) = RandomGif.init rightTopic
  in
    ( Model left right
    , Effects.batch
        [ Effects.map Left leftFx
        , Effects.map Right rightFx
        ]
    )

-- Effects.batch : List (Effects a) -> Effects a
```

In this case we not only use `Effects.map` to tag results appropriately, we also use the [`Effects.batch`](http://package.elm-lang.org/packages/evancz/elm-effects/latest/Effects#batch) function to lump them all together. All of the requested tasks will get spawned off and run independently, so the left and right effects will be in progress at the same time.


## Example 7: List of random GIF viewers

**[demo](http://evancz.github.io/elm-architecture-tutorial/examples/7.html) / [see code](examples/7/)**

This example lets you have a list of random GIF viewers where you can create the topics yourself. Again, we reuse the core `RandomGif` module exactly as is.

When you look through [the implementation](examples/7/RandomGifList.elm) you will see that it exactly corresponds to example 3. We put all of our submodels in a list associated with an ID and do our operations based on those IDs. The only thing new is that we are using `Effects` in the `init` and `update` function, putting them together with `Effects.map` and `Effects.batch`.

Please open an issue if this section should go into more detail about how things work!


## Example 8: Animation

**[demo](http://evancz.github.io/elm-architecture-tutorial/examples/8.html) / [see code](examples/8/)**

Now we have seen components with tasks that can be nested in arbitrary ways, but how does it work for animation?

Interestingly, it is pretty much exactly the same! (Or perhaps it is no longer surprising that the same pattern as in all the other examples works here too... Seems like a pretty good pattern!)

This example is a pair of clickable squares. When you click a square, it rotates 90 degrees. Overall the code is an adapted form of example 2 and example 6 where we keep all the logic for animation in `SpinSquare.elm` which we then reuse multiple times in `SpinSquarePair.elm`. 

So all the new and interesting stuff is happening [in `SpinSquare`](examples/8/SpinSquare.elm), so we are going to focus on that code. The first thing we need is a model:

```elm
type alias Model =
    { angle : Float
    , animationState : AnimationState
    }


type alias AnimationState =
    Maybe { prevClockTime : Time,  elapsedTime: Time }


rotateStep = 90
duration = second
```

So our core model is the `angle` that the square is currently at and then some `animationState` to track what is going on with any ongoing animation. If there is no animation it is `Nothing`, but if something is happening it holds:
  
  * `prevClockTime` &mdash; The most recent clock time which we will use for calculating time diffs. It will help us know exactly how many milliseconds have passed since last frame.
  * `elapsedTime` &mdash; A number between 0 and `duration` that tells us how far we are in the animation.

The `rotateStep` constant is just declaring how far it turns on each click. You can mess with that and everything should keep working.

Now the interesting stuff all happens in `update`:

```elm
type Action
    = Spin
    | Tick Time


update : Action -> Model -> (Model, Effects Action)
update msg model =
  case msg of
    Spin ->
      case model.animationState of
        Nothing ->
          ( model, Effects.tick Tick )

        Just _ ->
          ( model, Effects.none )

    Tick clockTime ->
      let
        newElapsedTime =
          case model.animationState of
            Nothing ->
              0

            Just {elapsedTime, prevClockTime} ->
              elapsedTime + (clockTime - prevClockTime)
      in
        if newElapsedTime > duration then
          ( { angle = model.angle + rotateStep
            , animationState = Nothing
            }
          , Effects.none
          )
        else
          ( { angle = model.angle
            , animationState = Just { elapsedTime = newElapsedTime, prevClockTime = clockTime }
            }
          , Effects.tick Tick
          )
```

There are two kinds of `Action` we need to handle:

  - `Spin` indicates that a user clicked the shape, requesting a spin. So in the `update` function, we request a clock tick if there is no animation going and just let things stay as is if one is already going.
  - `Tick` indicates that we have gotten a clock tick so we need to take an animation step. In the `update` function this means we need to update our `animationState`. So first we check if there is an animation in progress. If so, we just figure out what the `newElapsedTime` is by taking the current `elapsedTime` and adding a time diff to it. If the now elapsed time is greater than `duration` we stop animating and stop requesting new clock ticks. Otherwise we update the animation state and request another clock tick.

Again, I think we can cut this code down as we write more code like this and start seeing the general pattern. Should be exciting to find!

Finally we have a somewhat interesting `view` function! This example gets a nice bouncy animation, but we are just incrementing our `elapsedTime` in linear chunks. How is that happening?

The `view` code itself is totally standard [`elm-svg`](http://package.elm-lang.org/packages/evancz/elm-svg/latest/) to make some fancier clickable shapes. The cool part of the view code is `toOffset` which calculates the rotation offset for the current `AnimationState`.

```elm
-- import Easing exposing (ease, easeOutBounce, float)

toOffset : AnimationState -> Float
toOffset animationState =
  case animationState of
    Nothing ->
      0

    Just {elapsedTime} ->
      ease easeOutBounce float 0 rotateStep duration elapsedTime
```

We are using [@Dandandan](https://github.com/Dandandan)’s [easing package](http://package.elm-lang.org/packages/Dandandan/Easing/latest) which makes it easy to do [all sorts of cool easings](http://easings.net/) on numbers, colors, points, and any other crazy thing you want.

So the `ease` function is taking a number between 0 and `duration`. It then turns that into a number between 0 and `rotateStep` which we set to 90 degrees up at the top of our program. You also provide an easing. In our case we gave `easeOutBounce` which means as we slide from 0 to `duration`, we will get a number between 0 and 90 with that easing added. Pretty crazy! Try swapping `easeOutBounce` out for [other easings](http://package.elm-lang.org/packages/Dandandan/Easing/latest/Easing) and see how it looks!

From here, we wire everything together in `SpinSquarePair`, but that code is pretty much exactly the same as in example 2 and example 6.

Okay, so that is the basics of doing animation with this library! It is not clear if we nailed everything here, so let us know how things go as you get more experience. Hopefully we can make it even easier!

> **Note:** I expect we can build some abstractions on top of the core ideas here. This example does some lower level stuff, but I bet we can find some nice patterns to make this easier as we work with it more. If you find it weird now, try to make something better and tell us about it!
