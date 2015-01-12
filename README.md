# A Modular Architecture for Elm programs

This tutorial outlines the general architecture you will see in all Elm
programs. It is a simple pattern that is great for modularity, code reuse,
and testing. I find it somewhat shocking in its simplicity. We will start
with the basic pattern in a small example and slowly build on those core
principles.

To follow along with this tutorial, clone this repo and navigate to the root
directory.

## The Basic Pattern

The logic of every Elm program will break up into three cleanly separated
parts: model, update, and view. You can pretty reliably start with the
following skeleton and then iteratively fill in details for your particular
case.

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

Our first example is a simple counter that can be incremented or decremented.
To see it in action, navigate into directory `1/`, run `elm-reactor`, and then
open [http://localhost:8000/Counter.elm](http://localhost:8000/Counter.elm).

This code starts with a very simple model. We just need to keep track of a
single number:

```elm
type alias Model = Int
```

When it comes to updating our model, things are relatively simple again. We
define a set of actions that can be performed, and an `update` function to
actually perform those actions:

```elm
type Action = Increment | Decrement

update : Action -> Model -> Model
update action model =
  case action of
    Increment -> model + 1
    Decrement -> model - 1
```

Notice that an `Action` does not *do* anything. It simply describes the
actions that are possible. If someone decides our counter should be doubled
when a certain button is pressed, that will be a new case in `Action`.
This means our code ends up very clear about how our model can be transformed.
Anyone reading this code will immediately know what is allowed and what is not.
Furthermore, they will know exactly how to add new features in a consistent
way.

Finally, we create a way to `view` our `Model`. We are using [elm-html][] to
create some HTML to show in a browser. We will create a div that contains: a
decrement button, a div showing the current count, and an increment button.

[elm-html]: http://elm-lang.org/blog/Blazing-Fast-Html.elm

```elm
view : Model -> Html
view model =
  div []
    [ button [ onClick (Signal.send actionChannel Decrement) ] [ text "-" ]
    , div [ countStyle ] [ text (toString model) ]
    , button [ onClick (Signal.send actionChannel Increment) ] [ text "+" ]
    ]

countStyle : Attribute
countStyle =
  ...
```

The first thing I want you to notice about this code is that it is entirely
declarative. Take in a `Model` and produce some `Html`. That is it. At no point
do we mutate the DOM, giving the language and libraries [much more freedom to
make clever optimizations][elm-html]. Furthermore, `view` is a plain old
function so we can get the full power of Elm&rsquo;s module system, test
frameworks, and libraries when creating views.

The most tricky thing here is how `onClick` works for the two buttons. To
understand what it means to &ldquo;send a value to a channel&rdquo; we need to
talk about [signals][] for a bit.

## Aside: Driving your App with Signals

So far we have only been talking about pure functions and immutable data. This
is great, but we also need to react to events in the world. This is the role of
[signals][] in Elm. A signal is a value that changes over time, and it lets us
talk about how our `Model` is going to evolve.

Pretty much all Elm programs will have a small bit of code that drives the
whole application. The details are not super important for our purpose, but
the code will be some minor variation of what is seen in Example 1:

```elm
main : Signal Html
main =
  Signal.map view model

model : Signal Model
model =
  Signal.foldp update 0 (Signal.subscribe actionChannel)

actionChannel : Signal.Channel Action
actionChannel =
  Signal.channel Increment
```

Rather than trying to figure out exactly what is going on line by line, I
think it is enough to visualize what is happening at a high level.

[signals]: http://elm-lang.org/learn/Using-Signals.elm

![Signal Graph Summary](diagrams/signal-graph-summary.png)

The blue part is our core Elm program which is exactly the model/update/view
pattern we have been discussing so far. When programming in Elm, you can
mostly think inside this box and make great progress.

The new thing here is how &ldquo;channels&rdquo; make it possible for new
`Actions` to be triggered in response to user inputs. These channels are
roughly represented by the dotted arrows going from the monitor back to our
Elm program. So when we specify certain channels in our `view`, we are
describing how user `Actions` should come back into our program. Notice we
are not *performing* those actions, we are simply reporting them back to
our main Elm program. This separation is a key detail!

I want to reemphasize that this `Signal` code is pretty much the same in all
Elm programs. You can be very productive without diving much deeper than this,
and it is not vital to modularity or the specific architecture this tutorial
is focused on. All of our subsequent examples will focus on the `Model`,
`update`, and `view` so that we do not repeat this signal information again
and again.

## Example 2: A Pair of Counters

## Example 3: A Dynamic List of Counters

## Example 4: A Fancier List of Counters

## Additional Comments

Given how many conflicting definitions of [MVC][] are floating about in the
world, I am not sure how valuable it is to try to see connections besides
making the simple observation that these things look related.

The architecture I outlined here is made up entirely of immutable data and
[functions with no side-effects][pure], making it uniquely easy to reuse and
test code. I think it is much more important to focus on the specific patterns
and techniques than to get obsessed with relating it to other stuff, especially
if that other stuff has a contested defintion and worse properties when it
comes to testing, reuse, and modularity.

[MVC]: http://en.wikipedia.org/wiki/Model%E2%80%93view%E2%80%93controller
[pure]: http://en.wikipedia.org/wiki/Pure_function

