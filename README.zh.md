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

现在我们可以定义一组 `Action` 来操作 `model`。我们希望可以添加计数器，删除计数器，以及更新特定的计数器。

```elm
type Action
    = Insert
    | Remove
    | Modify ID Counter.Action
```

我们的 `Action` [union type][] 令人震惊的接近高阶描述。下面我们可以定义 `update` 函数了。

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

这里有对每种情况的高阶描述：

  * `Insert` &mdash; 首先我们创造一个新的计数器，并把它当在计数器队列的最后。然后我们给 `nextID` 加一，以便下一次添加时有一个新的ID。 

  * `Remove` &mdash; 删除计数器列表的第一个成员。

  * `Modify` &mdash; 遍历所有计数器，当找到匹配的 ID 时，用所给的 `Action` 操作这个计数器。

下面唯一要做的就是定义 `view`。

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

这里的 `viewCounter` 函数比较有趣。它必须使用同一个 `Counter.view` 函数，但在这里我们提供了一个转发地址来标记所有的消息和正在渲染的计数器的 ID。

实际上，当我们创建 `view` 函数时，我们映射 `viewCounter` 到所有的计数器，然后创建添加和删除按钮直接返回 `address`。

这个 ID 的玩法可以用在任何你需要数目可变的子模块时。计数器是简单的，但是这种模式可以完全不变的在用户信息，tweets，新闻列表或者产品列表上复用。


## Example 4: A Fancier List of Counters

**[demo](http://evancz.github.io/elm-architecture-tutorial/examples/4.html) / [see code](examples/4/)**

OK，在一个动态的计数器列表上保持简单和模块化是很屌的，但是如果不要一个通用的删除按钮，而是每个计数器有一个单独的删除按钮呢？它会把事情搞糟吗？

不, 它仍然有效.

在这里，我们的目标是找到一种新的方法给每个计数器添加一个删除按钮。有趣的是，我们可以继续使用原有的 `view` 函数并添加一个新的 `viewWithRemoveButton` 函数，这个函数为我们依赖的 `Model` 提供一个微小的变化。屌屌屌，我们不用重复任何代码更不用做任何疯狂的继承和重载。我们只是给公开的 API 添加了一个函数暴露新的功能！

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


`viewWithRemoveButton` 函数添加了一个额外的按钮。请注意 *增加/减少* 按钮发送消息给 `actions` 地址，但是删除按钮发送消息给 `remove` 这个地址。我们发给 `remove` 的消息其实是在说：&ldquo;嘿，无论谁拥有我，请删掉我！&rdquo; 这个计数器的拥有者负责删除。

既然我们有了新的 `viewWithRemoveButton`, 我们可以创建一个新的 `CounterList` 模块把所有独立的计数器放在一起。这个 `Model` 和 栗子3 中的一样: 带各自 ID 的计数器列表。

```elm
type alias Model =
    { counters : List ( ID, Counter.Model )
    , nextID : ID
    }

type alias ID = Int
```
我们的 `action` 稍有不同。不是删除一个旧的计数器，而是删除特定的一个，所以 `Remove` 需要一个 ID。

```elm
type Action
    = Insert
    | Remove ID
    | Modify ID Counter.Action
```

`update` 函数和 栗子3 中的非常像。

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

在 `Remove` 时，我们取出拥有该 ID 的计数器。否则，退出直接退出并保持原来那样。

最后，我们我们把萌宝宝们都放进 `view` 中：

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

在 `viewCounter` 函数中, 我们构造了 `Counter.Context` 来传递所有必需的转发地址。在两种情况下分别声明 `Counter.Action` 以便我们知道哪个计数器需要修改或删除。

## 目前为止获得的人生经验

**基础模式** &mdash; 任何事都是围绕 `Model` 创建出来的，包括更新 `model` 的函数, 以及 `model` 的 `view`。任何事都可以看作基础模式的变体。

**嵌套 Modules** &mdash; 转发地址使基础模式的嵌套变的简单，完全隐藏实现细节。我们可以无限深地嵌套这种模式，并且每一层只需要知道下一层在发生什么。

**添加上下文** &mdash; 有时对 `modal` 进行 `update` 或者 `view` 操作时需要额外的信息。我们随时可以添加 `Context` 给这些函数并传递所有的附加信息而不需要改变 `Model`。

```elm
update : Context -> Action -> Model -> Model
view : Context' -> Model -> Html
```

在嵌套的每一层，我们都可以为每个子模块衍生出所需的 `Context`。

**测试变的简单** &mdash; 我们创建的所有函数都是 [纯洁函数][pure]。这样测试 `update` 函数变的极其简单。不需要特别的初始化、模拟、配置步骤，你只要带着你想要测试的参数直接调用函数即可。

[pure]: http://en.wikipedia.org/wiki/Pure_function


## Example 5: Random GIF Viewer

**[demo](http://evancz.github.io/elm-architecture-tutorial/examples/5.html) / [see code](examples/5/)**

我们已经讲了如何创建可无限嵌套的组件，但当我们在某个组件里发出一个 HTTP 请求时会发生什么呢？与数据库通信呢？这个栗子使用 [`elm-effects` 包][fx] 来创建一个简单的组件，这个组件可以从 giphy.com 获取随机的可爱喵星人的 gif。 

[fx]: http://package.elm-lang.org/packages/evancz/elm-effects/latest

如果看了 [这个栗子的实现](examples/5/RandomGif.elm), 你会注意到它和 栗子1 中的代码非常接近。它的 `Model` 非常典型:

```elm
type alias Model =
    { topic : String
    , gifUrl : String
    }
```

我们需要知道要查找的 `topic` 值和当前展示的 `gifUrl`。这里唯一新颖的东西是 `init` 和 `update` 的类型:

```elm
init : String -> (Model, Effects Action)

update : Action -> Model -> (Model, Effects Action)
```

并非只是返回一个新的 `Model` 我们还返回一些我们需要执行的效果。所以我们将会使用 [`Effects` API][fx_api]，看起来像这样：

[fx_api]: http://package.elm-lang.org/packages/evancz/elm-effects/latest/Effects

```elm
module Effects where

type Effects a

none : Effects a
  -- don't do anything

task : Task Never a -> Effects a
  -- request a task, do HTTP and database stuff
```

`Effects` 类型本质上是一个包含了一些会在之后执行的独立任务的数据类型。让我们通过分析这里的 `update` 来更深入了解下这是怎么工作的：

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

所以用户可以通过点击 “More Please!” 按钮来触发 `RequestMore`，当服务器响应请求后它会给我们一个 `NewGif` 的 `action`。我们在 `update` 函数中处理这两种情况。

在这里 `RequestMore` 第一次返回已经存在的 `model`。用户只是点击了一个按钮，这时并没有任何改变。我们还使用 `getRandomGif` 函数创建了一个 `Effects Action`。我们马上将会知道 `getRandomGif` 是如何定义的。到此为止，我们只需知道当一个 `Effects Action` 运行时，会有一系列 `Action` 值产生并被传递给整个应用。所以 `getRandomGif model.topic` 最终会产生像这样的一个 `action like`：

```elm
NewGif (Just "http://s3.amazonaws.com/giphygifs/media/ka1aeBvFCSLD2/giphy.gif")
```

它返回一个 `Maybe` 因为向服务器发出的请求可能失败。那个 `Action` 将会原路返回给 `update` 函数。所以当我们执行 `NewGif` 时，我们只是更新当前的 `gifUrl`，如果他可以被更新。当请求失败后，我们只是停留在当前的 `model.gifUrl`。

我们看到同样的事情发生在 `init` 函数中，它定义了初始时的 `modal` 并且通过 giphy.com 的 API 请求一个特定话题的 GIF。

```elm
init : String -> (Model, Effects Action)
init topic =
  ( Model topic "assets/waiting.gif"
  , getRandomGif topic
  )

-- getRandomGif : String -> Effects Action
```

再一次，当随机的 GIF 下载完成，它会产生一个 `Action` 发送给 `update` 函数。

> **注意：** 之前我们使用的是来自 [the start-app package](http://package.elm-lang.org/packages/evancz/start-app/latest) 的 `StartApp.Simple` 模块，但是现在请升级到 `StartApp` 模块。它可以处理更实际的 web 应用中的复杂情况。它有 [更优雅的 API](http://package.elm-lang.org/packages/evancz/start-app/latest/StartApp)。更至关重要的改变是它可以处理我们新的 `init` 和 `update` 类型。

这个例子中一个至关重要的方面是 `getRandomGif` 函数，它描述了如何得到一张随机的 GIF。它使用了 [任务][] 和 [`Http`][http] 库, 我会尽力概述它是如何运做的。让我们看定义：

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

一旦我们写了上面这些，我们就可以在 `init` 和 `update` 函数中复用 `getRandomGif`。

有趣的是，`getRandomGif` 返回的任务是*永远*不会失败的。原因是任何可能的失败*必须*被明确的处理，我们不希望任何任务静静地失败。

我试图确切地解释下它是如何实现的，虽然这对于整个项目的正常运行并不特别重要。Okay，这样每个 `Task` 有一个失败的类型和一个成功的类型。例如，一个 HTTP 任务可能有类型如：`Task Http.Error String`，我们可以在失败时返回一个 `Http.Error` 或者成功时返回一个 `String`。这样可以优雅地把一组任务串在一起而不用过多的担心出错。现在，假设我们的组件请求了一个任务，但是任务失败了。会发生什么呢？谁会被通知？如何恢复？通过设置失败类型为 `Never`，我们强制任何可能的错误变成成功类型，这样它们就可以被组件明确的处理了。在这个例子里，我们用 `Task.toMaybe : Task x a -> Task y (Maybe a)` 所以 `update` 函数精确的处理了 HTTP 失败。这意味着任务不能静默的失败，你永远精确的处理着未知的错误。


## Example 6: Pair of random GIF viewers

**[demo](http://evancz.github.io/elm-architecture-tutorial/examples/6.html) / [see code](examples/6/)**

好了，结果搞定了，但是 *嵌套* 的结果呢？你是否思考过这个问题？！这个例子完全重用栗子5中的 GIF 查看器的代码创建了两个独立的 GIF 查看器。

你阅读 [这个实现代码](examples/6/RandomGifPair.elm) 时，会注意到它和栗子2中的两个计数器的代码几乎一样。`Model` 被定义为两个 `RandomGif.Model` 的值：

```elm
type alias Model =
    { left : RandomGif.Model
    , right : RandomGif.Model
    }
```

这让我们可以独立地分别跟踪它们。我们的 `action` 只是路由消息到正确的自模块。

```elm
type Action
    = Left RandomGif.Action
    | Right RandomGif.Action
```

有趣的是，我们实际上使用了 `Left` and `Right` 标签在 `update` 和 `init` 函数中。

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

所以不论在哪个分支中调用 `RandomGif.update` 函数时都会返回一个新 `model` 和一些被我们称作 `fx` 的操作。我们像往常一样返回一个更新过的 `model`，但是需要在操作上做一些额外的工作。并非直接返回它们，我们使用 [`Effects.map`](http://package.elm-lang.org/packages/evancz/elm-effects/latest/Effects#map) 函数把他们转化为一种 `Action`。这工作很像 `Signal.forwardTo`，让我们标记这些值以便确定如何路由。

`init` 函数也是一样。我们提供一个 `topic` 给每个随机 GIF 查看器，然后得到一个初始的 `model` 和一些 `effects`。

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

在这里我们并非只用 `Effects.map` 来标记合适的结果，还要用 [`Effects.batch`](http://package.elm-lang.org/packages/evancz/elm-effects/latest/Effects#batch) 函数来把他们归并到一起。所有请求的任务将会被生成并且独立运行，所以左边和右边两个 `effects` 会同时被处理。


## Example 7: List of random GIF viewers

**[demo](http://evancz.github.io/elm-architecture-tutorial/examples/7.html) / [see code](examples/7/)**

这个例子实现了一个随机 GIF 查看器的队列，你可以自己为他设置话题。而且，我们完全重用了 `RandomGif` 模块的核心。

仔细看看 [它的代码](examples/7/RandomGifList.elm) 你会发现它和 例子3 几乎一致。我们把所有子模块放进一个关联了 ID 的列表，并依据这些 ID 来进行操作。唯一新鲜的是我们使用 `Effects` 在 `init` 和 `update` 函数中，把他们和 `Effects.map` 以及 `Effects.batch` 放在一起。

如果你对它的实现细节还不够清楚，请创建一个 issue。

## Example 8: Animation

**[demo](http://evancz.github.io/elm-architecture-tutorial/examples/8.html) / [see code](examples/8/)**

现在，我们已经看到了带任务的组件可以很轻松地嵌套在一起，但是用它如何实现动画呢？

很有趣，它们完全一样！（或许你已经不再感到惊奇了，相同的模式在这里也适用，真是一个可爱的模式！）

这个例子是两个可点击的方块。当你点击一个方块时，它旋转 90 度。总体上，这里的代码是对 例子2 和 例子6 的调整，我们保留了所有的动画逻辑在 `SpinSquare.elm` 里面，并且在 `SpinSquarePair.elm` 里多次复用它。 

所有新的和有趣的东西都发生在 [`SpinSquare`](examples/8/SpinSquare.elm) 里，所以我们来关注下这里的代码。首先我们需要一个 model：

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

所以 model 的核心是方块当前的 `angle` 和一些用来记录每个动画要做什么的 `animationState`。如果没有动画就是 `Nothing`，但是如果有动作发生，它就变为:
  
  * `prevClockTime` &mdash; 用于计算时间差的最近时间。它帮我们精确地确定上一帧后过了多少毫秒。
  * `elapsedTime` &mdash; 0 到 `duration` 之间的一个数字，告诉我们当前动画已经进行了多久。

常量 `rotateStep` 只是声明每次点击转变多少度。你可以随意修改它，而不会影响正常运行。

现在，`update` 里发生了一些有趣的事:

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

有两种 `Action` 我们需要处理：

  - `Spin` 标示一个用户点击了方块，请求一次旋转。所以在 `update` 函数中，如果没有正在进行的动画，我们就请求一个时间戳，并把状态设置为一个动画正在进行。
  - `Tick` 标示我们已经得到了一个时间戳，所以我们需要进行一次动画。在 `update` 函数中，这意味着我们需要更新 `animationState`。所以，首先，我们检查当前是否有正在进行的动画。如果有，我们只是计算出 `newElapsedTime` 的值，通过把当前的 `elapsedTime` 加上一个时间差。如果当前经过的时间大于 `duration`，我们就停止动画并请求一个新的时间戳。否则，我们更新动画状态，也请求一个新的时间戳。

再一次，随着写了这么多类似的代码，审视一遍它们，我们会发现一个通用的模式。发现它时你一定很激动！

终于，无论如何我们有了一个有趣的 `view` 函数！这个例子有了一个优雅又充满活力的动画，而我们只是在时间线上增加了 `elapsedTime` 而已。这是怎么做到的呢？

`view` 的代码本身就是一个标准的 [`elm-svg`](http://package.elm-lang.org/packages/evancz/elm-svg/latest/)，可以制作一些漂亮的可点击图形。 代码中 最牛X 的是 `toOffset`，它计算了当前 `AnimationState` 的旋转的度数。

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

我们使用 [@Dandandan](https://github.com/Dandandan) 的 [easing](http://package.elm-lang.org/packages/Dandandan/Easing/latest) 库，它使得对数字、颜色、点以及其他任何疯狂的东西的 [补间排序](http://easings.net/) 变得很简单。

所以 `ease` 函数从 0 到 `duration` 之间取出一个数。然后它把它转变成一个 0 到 `rotateStep`（我们之前的代码里已经把它设置为 90 度了）之间的一个数。在这里你还提供了一个 `补间` 给 `easeOutBounce` 这意味着随着它从 0 到 `duration` 变化，我们会得到一个从 0 到 90 变化的数字。太疯狂了！尝试替换 `easeOutBounce` 为 [另一个补间](http://package.elm-lang.org/packages/Dandandan/Easing/latest/Easing) 看看是什么效果！

从这儿开始，我们把所有东西都拼装到了一起成为 `SpinSquarePair`, 而它的代码几乎与 例子2 和 例子6 的一模一样。

好了，这就是用这些工具实现动画的基础！如果把所有东西都摆在这儿，可能不够清晰，所以当你有了更多的经验，请让我们知道你的收获。希望我们可以把她变得更简单！

> **注意：** 我期待我们可以在这些核心思想之上构建一些抽象概念。这个例子做了一些基础的事情，但是我打赌随着我们继续为它做出的工作，我们可以找到一些优雅的模式使它更简单。如果你觉得它现在还是很复杂，请试着让它变得更好，并把你的想法告诉我们吧！
