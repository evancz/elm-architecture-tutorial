# The Elm Architecture

The Elm Architecture is a simple pattern for infinitely nestable components. It is great for modularity, code reuse, and testing. Ultimately, it makes it easy to create complex web apps that stay healthy as you refactor and add features.

You will see it in all [Elm][] programs, from [TodoMVC][] and [dreamwriter][] to the code running in production at [NoRedInk][] and [CircuitHub][]. The basic pattern is useful whether you are writing your front-end in Elm or JS or whatever else.

[Elm]: http://elm-lang.org/
[TodoMVC]: https://github.com/evancz/elm-todomvc
[dreamwriter]: https://github.com/rtfeldman/dreamwriter#dreamwriter
[NoRedInk]: https://www.noredink.com/
[CircuitHub]: https://www.circuithub.com/

**You should read [The Elm Architecture tutorial](https://evancz.gitbooks.io/an-introduction-to-elm/content/architecture/index.html).** It will explain the examples in this repo one-by-one, gradually introducing new concepts so it is easy to learn the whole pattern.


## Preview The Examples

  1. [Buttons][demo1] / [code][code1]
  2. [Text Fields][demo2] / [code][code2]
  3. [Forms][demo3] / [code][code3]
  4. [Random Numbers][demo4] / [code][code4]
  5. [HTTP][demo5] / [code][code5]
  6. [Time][demo6] / [code][code6]
  7. [WebSockets][demo7] / [code][code7]

[demo1]: http://evancz.github.io/elm-architecture-tutorial/examples/1.html
[demo2]: http://evancz.github.io/elm-architecture-tutorial/examples/2.html
[demo3]: http://evancz.github.io/elm-architecture-tutorial/examples/3.html
[demo4]: http://evancz.github.io/elm-architecture-tutorial/examples/4.html
[demo5]: http://evancz.github.io/elm-architecture-tutorial/examples/5.html
[demo6]: http://evancz.github.io/elm-architecture-tutorial/examples/6.html
[demo7]: http://evancz.github.io/elm-architecture-tutorial/examples/7.html

[code1]: examples/1.elm
[code2]: examples/2.elm
[code3]: examples/3.elm
[code4]: examples/4.elm
[code5]: examples/5.elm
[code6]: examples/6.elm
[code7]: examples/7.elm


## Run The Examples

To run the examples, first [install Elm](http://elm-lang.org/install). Once that is done, run the following commands in your terminal:

```bash
git clone https://github.com/evancz/elm-architecture-tutorial.git
cd elm-architecture-tutorial
elm reactor
```

This will download this repo and start a server that compiles Elm code for you.

Now go to [http://localhost:8000/](http://localhost:8000/) and start looking at the examples. When you edit an Elm file, just refresh the corresponding page in your browser and it will recompile.