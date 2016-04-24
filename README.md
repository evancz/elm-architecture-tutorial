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
