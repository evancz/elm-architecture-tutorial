# Elm

Elm is a programming language that compiles to JavaScript. The highlight features are great performance and no runtime exceptions. You can read more about all that on the [home page](http://elm-lang.org/). Elm also has its own virtual DOM implementation that is [very fast](http://elm-lang.org/blog/blazing-fast-html-round-two) compared to React, Angular, and Ember.

This repo focuses **The Elm Architecture**, an architecture pattern you see in all Elm programs. It has influenced projects like Redux that borrow core concepts but add many JS-focused ideas.


## The Elm Architecture

The Elm Architecture is a simple pattern for architecting webapps. The core idea is that your code is built around a `Model` of your application state, a way to `update` your model, and a way to `view` your model.

To learn more about this, read the [the official Elm guide][guide] and check out [this section][arch] which is all about The Elm Architecture. This repo is a collection of all the examples in that section, so you can follow along and compile things on your computer as you read through.

[guide]: http://guide.elm-lang.org/
[arch]: http://guide.elm-lang.org/architecture/


## Run The Examples

After you [install Elm](http://guide.elm-lang.org/get_started.html), run the following commands in your terminal to download this repo and start a server that compiles Elm for you:

```bash
git clone https://github.com/evancz/elm-architecture-tutorial.git
cd elm-architecture-tutorial
elm-reactor
```

Now go to [http://localhost:8000/](http://localhost:8000/) and start looking at the `examples/` directory. When you edit an Elm file, just refresh the corresponding page in your browser and it will recompile!
