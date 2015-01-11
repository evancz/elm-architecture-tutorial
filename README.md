# A Modular Architecture for Elm programs

This tutorial outlines the general architecture you will see in all Elm
programs. It is a simple pattern that is great for modularity, code reuse,
and testing. I find it somewhat shocking in its simplicity. We will start
with the basic pattern in a small example and slowly build on those core
principles.

## The Basic Pattern

The essense of any application is:

  * A `Model` of the application. These are the most basic facts necessary
    to fully describe your application.

  * A way to `update` that model in response to actions from the user or server.

  * A way to `view` the model.

This is the minimal set of concepts necessary to describe an interactive
application. This pattern translates into Elm code very directly:

```haskell
type Model

type Action

update : Action -> Model -> Model

view : Model -> Html
```

This is the architecture used in [the TodoMVC app written in
Elm](https://github.com/evancz/elm-todomvc/blob/master/Todo.elm) and pretty
much all Elm programs. The rest of this tutorial shows this pattern in action,
showing how it scales nicely for more and more complex cases.

## Example 1: A Counter

## Example 2: A Pair of Counters

## Example 3: A Dynamic List of Counters

## Example 4: A Fancier List of Counters



## Historical Aside

It seems that this architecture arises naturally from the language itself. I
did not come up with it. I learned it by writing Elm code. I find this
particularly surprising given that I created Elm.