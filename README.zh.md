# Elm 架构教程

本教程概述“Elm 架构”，你在所有 [Elm][] 程序中都能看到它, 从 [TodoMVC][] 、[dreamwriter][] 到 [NoRedInk][] 和 [CircuitHub][] 在生产环境中运行的代码。这种基本模式无论用 Elm 或 JS 写前端代码时都很有用。

[Elm]: http://elm-lang.org/
[TodoMVC]: https://github.com/evancz/elm-todomvc
[dreamwriter]: https://github.com/rtfeldman/dreamwriter#dreamwriter
[NoRedInk]: https://www.noredink.com/
[CircuitHub]: https://www.circuithub.com/

Elm 架构是无限嵌套组件的简单模式，对于模块化，代码重用和测试都很有效。而且，这种模式可以很容易地用模块化的方式创建复杂的Web应用程序。我们将通过 8 个例子，一步步学习它的核心原则和模式：
Ultimately, this pattern makes it easy to create complex web apps in a way that stays modular. We will run through 8 examples, slowly building on core principles and patterns:

  1. [计数器](http://evancz.github.io/elm-architecture-tutorial/examples/1.html)
  2. [双计数器](http://evancz.github.io/elm-architecture-tutorial/examples/2.html)
  3. [计数器列表](http://evancz.github.io/elm-architecture-tutorial/examples/3.html)
  4. [计数器列表 (变体)](http://evancz.github.io/elm-architecture-tutorial/examples/4.html)
  5. [GIF 提取](http://evancz.github.io/elm-architecture-tutorial/examples/5.html)
  6. [双 GIF 提取器](http://evancz.github.io/elm-architecture-tutorial/examples/6.html)
  7. [GIF 提取器队列](http://evancz.github.io/elm-architecture-tutorial/examples/7.html)
  8. [Pair of animating squares](http://evancz.github.io/elm-architecture-tutorial/examples/8.html)

本教程绝对牛B，绝对屌！它会教会你必要的概念和想法，让做例子 7 和 8 超级简单。这笔对基础的投资绝对是值得的！

在这些例子架构中一个非常有趣的方面是，它会从 Elm 中 *自然浮现* 出来。Elm 语言的设计本身导致你走向这个架构，无论你是否已阅读本文件，知道它的好处与否。我只是在使用 Elm 时偶然发现了这种模式，并深深地为它的简单和强悍感到震惊。

**注意**: 要使用此教程，必须和代码一起学习。[安装 Elm](http://elm-lang.org/install) 并 Fork 这个项目。在本教程的每个例子中都给出了如何运行项目代码的指令。

## 基础模式

每个 Elm 程序的逻辑将被分为三个完全分离的部分：

  * model
  * update
  * view

你可以非常放心地使用下面的脚手架，然后为你的具体需求不断填写细节。

> 如果你是第一次阅读 Elm 代码，请查看 [language docs](http://elm-lang.org/docs) 它涵盖了从语法到 “函数式思维”。[完整指南](http://elm-lang.org/docs#complete-guide) 的前两章可以帮你快速入门。

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

本教程都是关于这种模式的变化和扩展。


## Example 1: A Counter

**[demo](http://evancz.github.io/elm-architecture-tutorial/examples/1.html) / [see code](examples/1/)**

我们的第一个例子是一个简单的计数器，它可以递增或递减。

[这段代码](examples/1/Counter.elm) 以一个非常简单的模型开始。我们只需要跟踪一个数字：

```elm
type alias Model = Int
```

当需要更新我们的模型时，事情又一次变得简单。我们定义一组可以执行的动作，以及一个 `update` 函数来实际执行这些动作：

```elm
type Action = Increment | Decrement

update : Action -> Model -> Model
update action model =
  case action of
    Increment -> model + 1
    Decrement -> model - 1
```

请注意，`Action` [union type][] *没有做任何事*。它简单地描述了可能的行动。如果有人认为当按下某个按钮时我们的计数器应该增加一倍，我们就需要一个新的 `Action`。这意味着这段代码非常清楚模型该如何转化。任何阅读此代码的人将立即知道那些是允许的，哪些不是。此外，他们将知道如何以一致的方式添加新的功能。

[union type]: http://elm-lang.org/learn/Union-Types.elm

最后，我们创建了一种 `view` 来展示 `Model`. 我们使用 [elm-html][] 来创建一些 HTML 在浏览器中显示。我们将创建一个包裹的 div，内含：一个减量按钮，显示当前计数的 div，和一个增量按钮。

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

比较棘手的是 `view` 的 `Address` 功能。我们将在下一章深入讲解它！现在，我只是想让你注意到 **这段代码完全只是声明**。我们使用 `Model` 生成 `Html`。就是这样，在任何时候，我们不会手工改变 DOM，这给了库 [更大的自由度做出使聪明的优化][elm-html] 并且使渲染速度更快。这简直疯狂！而且, `view` 是一个普通的函数，所以我们创建 `view` 时可以得到 Elm 的模块系统，测试框架和库。

这种模式是架构 Elm 程序的精髓。我们从现在开始看到每一个例子都将只是对这个基本模式的略微变化: `Model`，`update`，`view`。


## 启动程序

几乎所有的 Elm 程序都只是用一小段代码，驱动整个应用程序。在本教程的每个例子中，该代码命名为 `Main.elm`。作为反例，有趣的代码如下所示：

```elm
import Counter exposing (update, view)
import StartApp.Simple exposing (start)

main =
  start { model = 0, update = update, view = view }
```

我们使用 [`StartApp`](https://github.com/evancz/start-app) 这个库把初始模型的 `update` 和 `view` 连接起来。它只是对 Elm 的 [signals](http://elm-lang.org/learn/Using-Signals.elm) 做了一个小封装，所以你还不需要深入研究它的原理。


装配应用时的关键概念是 `Address`。每个事件处理器在 `view` 函数得到一个特定的地址，并且和数据块一起传递。`StartApp` 监视所有传给这个地址的消息，并把它们传给 `update` 函数。`model` 获得更新， 而且 [elm-html][] 负责渲染和高效的修改。

这意味着，Elm 程序中的数据只在一个方向流动, 类似这样:

![Signal Graph Summary](diagrams/signal-graph-summary.png)

蓝色部分是我们 Elm 程序的核心，这正是 model/update/view，我们一直在讨论的模式。使用 Elm 编程，你可以一直呆在这个舒服的盒子里面，并取得很大的进步。

注意，我们 *不执行* 送回应用程序的 `action` 。我们只是在发送一些数据。这种分离是一个关键的细节，使我们的逻辑完全从我们的视图代码分离。



## Example 2: A Pair of Counters

**[demo](http://evancz.github.io/elm-architecture-tutorial/examples/2.html) / [see code](examples/2/)**

在上一个例子里我们创造了一个计数器，但是当增加到两个计数器时这个模式会怎样变化呢？我们能继续保持模块化吗？

如果我们能完全重用例子一的代码就再好不过了。Elm 架构最疯狂的是 **我们可以一句不改地重用代码**。当我们创造例子一的计 `Counter` 模块时，它包括了所有实现细节所已我们可以在任何地方使用它。

```elm
module Counter (Model, init, Action, update, view) where

type Model

init : Int -> Model

type Action

update : Action -> Model -> Model

view : Signal.Address Action -> Model -> Html
```

编写模块代码其实完全是在创建一种很强的抽象。我们期待的是合适的函数暴露和隐藏具体执行过程。从 `Counter` 模块的外部我们只能看到一些基础的值: `Model`, `init`, `Action`, `update`, 和 `view`。我们完全不用关心这些是如何实现的。事实上，也不可能知道这些是如何实现的。这意味着没人能以赖这些不公开的实现细节。

所以我们本可以完全复制 `Counter` 模块, 但是我们还是使用它来实现 `CounterPair`。 像往常一样, 我们从一个 `Model` 开始:

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

我们的 `Model` 纪录了两个计数器, 一个是需要在屏幕上显示的。这个完全描述了应用所有的状态。我们还有一个 `init` 函数可以在任何地方创建一个新的 `Model`。

下一步我们来描述下我们想要支持的 `Actions`。我们需要的功能是: 重置所有的计数器, 更新顶部的计数器，或者更新下面的计数器。

```elm
type Action
    = Reset
    | Top Counter.Action
    | Bottom Counter.Action
```

请注意，我们的 [union type][] 是参考 `Counter.Action` 类型，但是我们并知道那些 `action` 的细节。当我们创建 `update` 函数时，我们主要是路由这些 `Counter.Actions` 到正确的地方:

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

所以最后要做的事情就是创建一个 `view` 函数显示两个计数器和两个重置按钮。

```elm
view : Signal.Address Action -> Model -> Html
view address model =
  div []
    [ Counter.view (Signal.forwardTo address Top) model.topCounter
    , Counter.view (Signal.forwardTo address Bottom) model.bottomCounter
    , button [ onClick address Reset ] [ text "RESET" ]
    ]
```
请注意，我们可以重用 `Counter.view` 函数在两个计数器之中。我们为每个计数器创建一个转发地址。大体上，我们这里做的事情其实是说：&ldquo;这些计数器将会给所有向外传递的消息打上 `Top` 或 `Bottom` 标签，以便我们区分&rdquo;

这就是所有的事情。最屌的是我们可以一层又一层地保持嵌套。我们可以创建 `CounterPair` 模块，暴露关键值和方法，然后创建 `CounterPairPair` 或者任何其他我们需要的。


## Example 3: A Dynamic List of Counters

**[demo](http://evancz.github.io/elm-architecture-tutorial/examples/3.html) / [see code](examples/3/)**

两个计数器已经很屌了，但一个可以随意添加和删除的计数器队列会怎么样呢？这种模式还有效吗？

而且我们可以完全像例子一盒例子二里那样复用 `Counter` !

```elm
module Counter (Model, init, Action, update, view)
```

这意味着我们可以开始创建 `CounterList` 模块。 像往常一样, 我们从 `Model` 开始:

```elm
type alias Model =
    { counters : List ( ID, Counter.Model )
    , nextID : ID
    }

type alias ID = Int
```

现在，我们的 `model` 有了一个计数器队列，每个计数器有一个唯一的 ID。这些 ID 使我们可以区别它们，所以如果我们要更新 4 号计数器，我们可以很轻松的找到它。（当我们考虑优化渲染时，这个 ID 也给了我们一些 [`key`][key] 的便利，然而它并不是这个教程的重点！）我们的 `modal` 还包含一个 `nextID` 帮助我们指定 ID 给每一个新增的计数器。

[key]: http://package.elm-lang.org/packages/evancz/elm-html/latest/Html-Attributes#key


Now we can define the set of `Actions` that can be performed on our model. We
want to be able to add counters, remove counters, and update certain counters.

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
view : Context' -> Model -> Html
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
