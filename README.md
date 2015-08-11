# The Elm Architecture

This tutorial outlines “The Elm Architecture” which you will see in all [Elm][] programs, from [TodoMVC][] and [dreamwriter][] to the code running in production at [NoRedInk][] and [CircuitHub][]. The basic pattern is useful whether you are writing your front-end in Elm or JS or whatever else.

[Elm]: http://elm-lang.org/
[TodoMVC]: https://github.com/evancz/elm-todomvc
[dreamwriter]: https://github.com/rtfeldman/dreamwriter#dreamwriter
[NoRedInk]: https://www.noredink.com/
[CircuitHub]: https://www.circuithub.com/

The Elm Architecture is a simple pattern for infinitely nestable components. It is great for modularity, code reuse, and testing. Ultimately, this pattern makes it easy to create complex webapps in a way that stays modular. We will run through 8 examples, slowly building on core principles and patterns:

  1. Counter
  2. Pair of counters
  3. List of counters
  4. List of counters (variation)
  5. GIF fetcher
  6. Pair of GIF fetchers
  7. List of GIF fetchers
  8. Pair of animating squares

It helps to go through them in order (and with the tutorial here, it helps!)

One very interesting aspect of the architecture in all these programs is that it *emerges* from Elm naturally. The language design itself leads you towards this architecture whether you have read this document and know the benefits or not. I actually discovered this pattern just using Elm and have been shocked by its simplicity and power.

**Note**: To follow along with this tutorial with code, [install Elm](http://elm-lang.org/install) and fork this repo. Each example in the tutorial gives instructions of how to run the code.


## The Basic Pattern

The logic of every Elm program will break up into three cleanly separated parts: model, update, and view. You can pretty reliably start with the following skeleton and then iteratively fill in details for your particular case.

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

Our first example is a simple counter that can be incremented or decremented. To see it in action, navigate into directory `1/`, run `elm-reactor`, and then open [http://localhost:8000/Counter.elm?debug](http://localhost:8000/Counter.elm?debug).

This code starts with a very simple model. We just need to keep track of a single number:

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

This pattern is the essense of architecting Elm programs. Every example we see from now on will be a slight variation on this basic pattern: `Model`, `update`, `view`.


## Starting the Program

Pretty much all Elm programs will have a small bit of code that drives the whole application. In example 1 the snippet looks like this:

```elm
main =
  StartApp.start { model = 0, update = update, view = view }
```

We are use the [`StartApp`](https://github.com/evancz/start-app) package to wire together our initial model with the update and view functions. It is a small wrapper around Elm's [signals](http://elm-lang.org/learn/Using-Signals.elm) so that you do not need to dive into that concept yet.

The key to wiring up your application is the concept of an `Address`. Every event handler in our `view` function reports to a particular address. It just sends chunks of data along. The `StartApp` package monitors all the messages coming in to this address and feeds them into the `update` function. The model gets updated and [elm-html][] takes care of rendering the changes efficiently.

This means values flow through an Elm program in only one direction, something like this:

![Signal Graph Summary](diagrams/signal-graph-summary.png)

The blue part is our core Elm program which is exactly the model/update/view pattern we have been discussing so far. When programming in Elm, you can mostly think inside this box and make great progress.

Notice we are not *performing* actions as they get sent back to our app. We are simply sending some data over. This separation is a key detail, keeping our logic totally separate from our view code.


## Example 2: A Pair of Counters

In example 1 we created a basic counter, but how does that pattern scale when we want *two* counters? Can we keep things modular? To see example 2 in action, navigate into directory `2/`, run `elm-reactor`, and then open
[http://localhost:8000/CounterPair.elm?debug](http://localhost:8000/CounterPair.elm?debug).

Wouldn't it be great if we could reuse all the code from example 1? The crazy thing about the Elm Architecture is that **we can reuse code with absolutely no changes**. We just create a self-contained `Counter` module that encapsulates all the implementation details:

```elm
module Counter (Model, init, Action, update, view) where

type Model = ...

init : Int -> Model
init = ...

type Action = ...

update : Action -> Model -> Model
update = ...

view : Signal.Address Action -> Model -> Html
view = ...
```

Creating modular code is all about creating strong abstractions. We want boundaries which appropriately expose functionality and hide implementation. From outside of the `Counter` module, we just see a basic set of values: `Model`, `init`, `Action`, `update`, and `view`. We do not care at all how these things are implemented. In fact, it is *impossible* to know how these things are implemented. This means no one can rely on implementation details that were not made public.

So now that we have our basic `Counter` module, we need to use it to create our `CounterPair`. As always, we start with a `Model`:

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
          topCounter <- Counter.update act model.topCounter
      }

    Bottom act ->
      { model |
          bottomCounter <- Counter.update act model.bottomCounter
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

A pair of counters is cool, but what about a list of counters where we can add and remove counters as we see fit? Can this pattern work for that too?

To see this example in action, navigate into directory `3/`, run `elm-reactor`, and then open
[http://localhost:8000/CounterList.elm?debug](http://localhost:8000/CounterList.elm?debug).

In this example we can reuse the `Counter` module exactly as it was in example
2.

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
              counters <- newCounters,
              nextID <- model.nextID + 1
          }

    Remove ->
      { model | counters <- List.drop 1 model.counters }

    Modify id counterAction ->
      let updateCounter (counterID, counterModel) =
            if counterID == id
                then (counterID, Counter.update counterAction counterModel)
                else (counterID, counterModel)
      in
          { model | counters <- List.map updateCounter model.counters }
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

Okay, keeping things simple and modular on a dynamic list of counters is pretty cool, but instead of a general remove button, what if each counter had its own specific remove button? Surely *that* will mess things up!

Nah, it works.

To see this example in action, navigate into directory `4/`, run `elm-reactor`, and then open
[http://localhost:8000/CounterList.elm?debug](http://localhost:8000/CounterList.elm?debug).

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

The `update` function is pretty similar to example 4 as well.

```elm
update : Action -> Model -> Model
update action model =
  case action of
    Insert ->
      { model |
          counters <- ( model.nextID, Counter.init 0 ) :: model.counters,
          nextID <- model.nextID + 1
      }

    Remove id ->
      { model |
          counters <- List.filter (\(counterID, _) -> counterID /= id) model.counters
      }

    Modify id counterAction ->
      let updateCounter (counterID, counterModel) =
            if counterID == id
                then (counterID, Counter.update counterAction counterModel)
                else (counterID, counterModel)
      in
          { model | counters <- List.map updateCounter model.counters }
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

In our `viewCounter` function, we construct the `Counter.Context` to pass in all the nesessary forwarding addresses. In both cases we annotate each `Counter.Action` so that we know which counter to modify or remove.


## Big Lessons So Far

**Basic Pattern** &mdash; Everything is built around a `Model`, a way to `update` that model, and a way to `view` that model. Everything is a variation on this basic pattern.

**Nesting Modules** &mdash; Forwarding addresses makes it easy to nest our basic pattern, hiding implementation details entirely. We can nest this pattern arbitrarily deep, and each level only needs to know about what is going on one level lower.

**Adding Context** &mdash; Sometimes to `update` or `view` our model, extra information is needed. We can always add some `Context` to these functions and pass in all the additional information we need without complicating our `Model`.

```elm
update : Context -> Action -> Model -> Model
view : Context' -> Model -> Html
```

At every level of nesting we can derive the specific `Context` needed for each submodule.

**Testing is Easy** &mdash; All of the functions we have created are [pure functions][pure]. That makes it extremely easy to test your `update` function. There is no special initialization or mocking or configuration step, you just call the function with the arguments you would like to test.

[pure]: http://en.wikipedia.org/wiki/Pure_function


## Example 5: Random GIF Viewer

