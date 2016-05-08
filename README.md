# The Elm Architecture

這個教程 “The Elm Architecture” 你將會看到許多跟 [Elm][] 相關的程式, 包含 [TodoMVC][] 、 [dreamwriter][]以及正式上線的  [NoRedInk][] 、 [CircuitHub][]. 了解這個設計模式將對你在 Elm 中的程式或任何其他編程都很有幫助。

[Elm]: http://elm-lang.org/
[TodoMVC]: https://github.com/evancz/elm-todomvc
[dreamwriter]: https://github.com/rtfeldman/dreamwriter#dreamwriter
[NoRedInk]: https://www.noredink.com/
[CircuitHub]: https://www.circuithub.com/

 Elm 架構中的設計模式讓你的元件可以有無限嵌套. 對於模組化、 程式碼復用、 測試很有幫助，最終讓你可以簡單的設計出一個複雜但模組化的web程式。 下面將有八個範例

  1. [Counter](http://evancz.github.io/elm-architecture-tutorial/examples/1.html)
  2. [Pair of counters](http://evancz.github.io/elm-architecture-tutorial/examples/2.html)
  3. [List of counters](http://evancz.github.io/elm-architecture-tutorial/examples/3.html)
  4. [List of counters (variation)](http://evancz.github.io/elm-architecture-tutorial/examples/4.html)
  5. [GIF fetcher](http://evancz.github.io/elm-architecture-tutorial/examples/5.html)
  6. [Pair of GIF fetchers](http://evancz.github.io/elm-architecture-tutorial/examples/6.html)
  7. [List of GIF fetchers](http://evancz.github.io/elm-architecture-tutorial/examples/7.html)
  8. [Pair of animating squares](http://evancz.github.io/elm-architecture-tutorial/examples/8.html)




**注意**: 要運行這些範例需先, [安裝 Elm](http://elm-lang.org/install) 以及 fork this repo. 每個範例都會教導你，該如何去運行它


## Elm中的基本設計模式概念

每個 Elm program 都有如下三個區塊架構:


  * model
  * update
  * view


> 如果你還沒學習過elm可以先參考 [language docs](http://elm-lang.org/docs) 與[the complete guide](http://elm-lang.org/docs#complete-guide)

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

這個教程都是由上面範例的這個設計模式 與一些小變化及插件所組成的。


## Example 1: A Counter

**[demo](http://evancz.github.io/elm-architecture-tutorial/examples/1.html) / [see code](examples/1/)**

第一個範例是一個簡單的計數器，可以進行增加與減少

[The code](examples/1/Counter.elm) 由一個很簡單的 model所組成， 我們要做的只是追蹤一個會改變的數字

```elm
type alias Model = Int
```

當 model 更新時， 我們定義一系列 actions, 以及一個 `update` function用來接收 actions並執行相應的case

```elm 
type Action = Increment | Decrement

update : Action -> Model -> Model
update action model =
  case action of
    Increment -> model + 1
    Decrement -> model - 1
```

需要注意的是 `Action` [union type][] 並沒有做任何事， 他只是描述了一個動作的型態. 假設有人想讓計數器在點擊某個按鈕時可以讓數字變double, 這將需要增加一個新的 `Action`類型，這可以保持我們的Model簡潔，並且他人可以清楚的知道他可以對這個model進行何種操作

[union type]: http://elm-lang.org/learn/Union-Types.elm

 `view` our `Model`.我們使用 [elm-html][]來創造一個 HTML，其它包含一個 div 裡面裝有一個 decrement button以及a div showing the current count與 an increment button.

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
在 `view` 這個函式中的 `Address`我們將會在下一節提到! 在這裡我們使用了 `Model` 並產生一些 `Html`. 我們並沒有手動去更動DOM，
這讓這個 library [有了更好的自由度及優化][elm-html] 並且讓畫面 rendering的速度更快。 以及 `view`是一個function ，我們可使用 Elm中的 module system、 test frameworks與其他 libraries 來創造 views.

這種設計模式是Elm中的基本架構，接著的範例中都是以此種架構去進行 `Model`, `update`, `view`.


## Starting the Program

在elm程式中，都會有一個主體的部分，程式從此開始進行，如同以下的範例均是以 `Main.elm`為主體

```elm
import Counter exposing (update, view)
import StartApp.Simple exposing (start)

main =
  start { model = 0, update = update, view = view }
```

我們使用了 [`StartApp`](https://github.com/evancz/start-app) 來建造初始的 model 、 update 與 view functions. 這即是Elm's [signals](http://elm-lang.org/learn/Using-Signals.elm)的概念，所以你暫時還不用了解signals的概念。

其中的關鍵點在於 `Address`。 每個 event handler 於我們的 `view` function 之中會回傳一個特別的  address. It just sends chunks of data along.而 `StartApp` package 監測每個來自 address 的訊息，並轉送到 `update` function. 接著 model 被更新 ，然後[elm-html][] 把view更新

 Elm 程式中的單向資料流如同下圖的概念

![Signal Graph Summary](diagrams/signal-graph-summary.png)

圖片中的藍色部分為 Elm 程式的核心，此即為我們先前提到的 model/update/view 概念。 未來在寫Elm程式時，即可以此種架構去規劃，讓邏輯的部分完全與View分開。


## Example 2: A Pair of Counters

**[demo](http://evancz.github.io/elm-architecture-tutorial/examples/2.html) / [see code](examples/2/)**

在範例1中，我們建立了一個簡單的計數器。但我們該如何擴展架構，當我們需要兩個計數器時呢? 

 Elm架構中的優點是  **我們可以不更動程式碼**來達成擴展架構。 當我們在上個範例創造 `Counter` 模組時,他把細節封裝起來，所以我們可以把他用在別處。

```elm
module Counter (Model, init, Action, update, view) where

type Model

init : Int -> Model

type Action

update : Action -> Model -> Model

view : Signal.Address Action -> Model -> Html
```

創造模組化的code 是很抽象的。我們把一些 functionality 的部分提供出來並隱藏一些實做細節。在 `Counter` module外面，我們只看得到
一些基本的關於 `Model`, `init`, `Action`, `update`, 與 `view`。我們並不在乎他們是如何被實做的。 事實上,這是不可能被知道的
. 意思是當我們選擇不把他公開時，其他人無法知道我們的實做細節。

所以我們可以複用 `Counter` module，並用他來創造 `CounterPair`，和先前一樣，我們先從 `Model`開始:

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

這個 `Model` 擁有兩個區塊分別為顯示在螢幕的top和bottom。用來完整描述我們應用程式中的 state。 以及一個 `init` function 
讓我們在未來更新`Model`所用。 

接著我們將定義 `Actions` ，將包含: reset all counters、 update the top counter與 update the bottom counter.

```elm
type Action
    = Reset
    | Top Counter.Action
    | Bottom Counter.Action
```

注意到的是，上面的 [union type][] 指向 `Counter.Action` type,但我們並不知道這些 actions，當我們創造 `update` function時， 我們才將
這些 `Counter.Actions` 指向正確的地方:

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

最後，我們建造一個 `view` function用來在畫面上顯示兩個 counters 與一個 reset button.

```elm
view : Signal.Address Action -> Model -> Html
view address model =
  div []
    [ Counter.view (Signal.forwardTo address Top) model.topCounter
    , Counter.view (Signal.forwardTo address Bottom) model.bottomCounter
    , button [ onClick address Reset ] [ text "RESET" ]
    ]
```

我們可以重複使用 `Counter.view` function 於兩個 counters. 於每個 counter 我們創造一個 forwarding address.我們在這裡做的事為，這兩個計數器會把傳出的訊息以 `Top` or `Bottom` tag起來，讓我們可以區分。

接著我們還可以讓他更巢狀化，我們可以使用 `CounterPair` module,指對外展示出一些 key values 與d functions, 再創造一個 `CounterPairPair` 或是任何你想要的。


## Example 3: A Dynamic List of Counters

**[demo](http://evancz.github.io/elm-architecture-tutorial/examples/3.html) / [see code](examples/3/)**

接著我們要來創造一系列的計數器，我們可使用add或remove來增加與減少畫面上計數器的數量。

我們一樣複用 `Counter` module ，如同上面的範例。 

```elm
module Counter (Model, init, Action, update, view)
```

接著我們可以直接開始設計 `CounterList` module，和之前一樣 ，先從 `Model`開始:

```elm
type alias Model =
    { counters : List ( ID, Counter.Model )
    , nextID : ID
    }

type alias ID = Int
```

現在我們的model有一系列的counter,每個均擁有一個獨特的ID，讓我們可以區別他們，
(這些 ID 還帶給我們於 rendering時具有最佳化的表現[`key`][key] )

我們的model 還包含了一個`nextID`這可以幫助我們在新增counter時，可以分配新的ID給他

[key]: http://package.elm-lang.org/packages/evancz/elm-html/latest/Html-Attributes#key

現在我們來定義一系列的`Actions` 用來傳給 model。包含了 add counters、 remove counters與update certain counters.

```elm
type Action
    = Insert
    | Remove
    | Modify ID Counter.Action
```


現在我們可以定義`update` function.

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

可以看下面的描述:

  * `Insert` &mdash; 首先我們創造了一個新的計數器， 放在所有以建造的計數器的最後。
  接著增加 `nextID` 來讓下一次使用。

  * `Remove` &mdash;從許多計數器中移除最前面那個

  * `Modify` &mdash; 找尋這些計數器中與其符合的 ID, 我們在這個符合的計數器上執行這個 `Action`

最後是定義我們的 `view`.

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

有趣的地方在於其中的 `viewCounter` function. 他使用先前的
`Counter.view` function，但這次，我們提供了一個 forwarding address 上面標住了所有被 rendered的counter的相關訊息。

當我們真正創造 `view` function時， 我們對所有counters進行了`viewCounter`的map動作，並且創造兩個按鈕:add 、remove ，直接傳遞到 the `address` 中

上面這種創造 ID的方法，可以用於任何你想要於子組件創造動態數字時，也可應用在其他範例，例如: list of user profiles 、 tweets 或是 newsfeed items 以及 product details中。


## Example 4: A Fancier List of Counters

**[demo](http://evancz.github.io/elm-architecture-tutorial/examples/4.html) / [see code](examples/4/)**

但是，如果我們想要不只是有一個移除按鈕，而是想讓每個按鈕擁有自己專屬的移除按鈕呢? 


要這麼做的話，我們先保持原本的`view` function 不變，並且可以新增一個`viewWithRemoveButton`，如以下範例:
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

`viewWithRemoveButton` function 增加了一個額外的按鈕，其中  increment/decrement 按紐送出訊息到 `actions` address 中，但移除按鈕
送出訊息到 `remove` address中。 在 `remove` 訊息中寫了類似下面的文字, &ldquo;任何擁有我的人請移除我!&rdquo; 

現在我們有了新的 `viewWithRemoveButton`，我們可以建造一個 `CounterList` module 用來放置每個獨立的計數器， 其中 `Model` 和範例3的相同  a 

```elm
type alias Model =
    { counters : List ( ID, Counter.Model )
    , nextID : ID
    }

type alias ID = Int
```

但這裡的 actions 有一些改變，這裡我們想讓他可以移除特定的按鈕，所以 `Remove` case 現在擁有一個 ID。

```elm
type Action
    = Insert
    | Remove ID
    | Modify ID Counter.Action
```
其中的`update` function 和範例 3的相同。

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

其中的 `Remove`， 我們過濾出了想要的ID


最後是 `view`:

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

在 `viewCounter` function中，我們建造了 `Counter.Context` 用來傳遞所有必要的 forwarding addresses。在兩個情況，我們均標註了 `Counter.Action` 讓我們知道該移除或修改哪個counter、


## Big Lessons So Far(到目前為止)

**Basic Pattern** &mdash; 所有東西都是圍繞著 `Model`所建構的，包含 `更新` model, 以及將model轉為 `view` ，都是根據這個設計模式在變動。

**Nesting Modules** &mdash; Forwarding addresses 讓巢狀化更加簡單，把實做細節整個隱藏起來。 我們可以繼續往下一層深入實做，而每一層只需要知道在他的上一層發生了什麼事就好。

**Adding Context** &mdash; 有時在 `更新` 或是 `檢視` 我們的 model時，額外的資訊是很必要的。我們可以增加一些 `Context`到這些 functions 在避免 `Model`變得更複雜的情況下，將這些資訊傳遞進去。

```elm
update : Context -> Action -> Model -> Model
view : Context' -> Model -> Html
```

在巢狀結構下的每一層， 我們可以導出一些特定的 `Context`給子模組使用。

**Testing is Easy** &mdash; 我們在這建立的所有function都是所謂的 [pure functions][pure].這讓你在測試你的 `update` function時
變得很簡單。 在這之中沒有特定的步驟，你可以直接呼叫你想測試的函式與參數來進行測試。

[pure]: http://en.wikipedia.org/wiki/Pure_function


## Example 5: Random GIF Viewer

**[demo](http://evancz.github.io/elm-architecture-tutorial/examples/5.html) / [see code](examples/5/)**

我們展示了如何建立巢狀的元件， 但，我們該如何執行一個HTTP request呢?如何跟 database 取得資料?在這個範例中使用了 [the `elm-effects` package][fx]來建立一個簡單的元件，可以從 giphy.com取得隨機的 gifs  其中包含 “funny cats” topic。

[fx]: http://package.elm-lang.org/packages/evancz/elm-effects/latest

在這個範例[the implementation](examples/5/RandomGif.elm)，與範例1很類似， `Model` 如下(非常典型)l:

```elm
type alias Model =
    { topic : String
    , gifUrl : String
    }
```

我們需要知道要找尋的 `topic` 以及 `gifUrl`。這個範例特別點在於`init` 與 `update`是一個暫時為空想的types:

```elm
init : String -> (Model, Effects Action)

update : Action -> Model -> (Model, Effects Action)
```

相較於直接返回一個新的 `Model`，為了讓我們可以執行一些效果[the `Effects` API][fx_api]，可參考如下範例

[fx_api]: http://package.elm-lang.org/packages/evancz/elm-effects/latest/Effects

```elm
module Effects where

type Effects a

none : Effects a
  -- don't do anything

task : Task Never a -> Effects a
  -- request a task, do HTTP and database stuff
```

其中的 `Effects` type為一個 擁有許多不同 tasks的資料結構，將會在未來去執行，我們用下面的範例來展示 `update` 是如何執行的:

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

使用者可以觸發一個 `RequestMore` action 於點擊“More Please!” 按鈕之後， 當server 回覆時將返回一個 `NewGif` action，這兩個情景都寫在`update` function中。

其中 `RequestMore` 將會先返回一個已存在的 model， 並且我們還使用了 `getRandomGif` function建造了一個 `Effects Action`。 在後面會講到`getRandomGif`是如何定義的。現在我們只需要知道，當`Effects Action` 在執行時，他會產生大量的 `Action` values並且被導向到程式的各個部分。最後 `getRandomGif model.topic` 將產生向下面這樣的action:

```elm
NewGif (Just "http://s3.amazonaws.com/giphygifs/media/ka1aeBvFCSLD2/giphy.gif")
```

並且返回一個`Maybe` 因為這個送往server的request可能會失敗。 `Action`會被傳回 `update` function. 所以假設向server的請求失敗時，我們依然保持原有的 `model.gifUrl`.

在 `init`將會發生相同的事。他定義了一個初始的 model並且使用特定的topic向giphy.com’s API請求 GIF 圖片。

```elm
init : String -> (Model, Effects Action)
init topic =
  ( Model topic "assets/waiting.gif"
  , getRandomGif topic
  )

-- getRandomGif : String -> Effects Action
```

當 random GIF effect 完成時， 他將會產生一個 `Action` 並且導向 `update` function.

> **Note:** 目前為止我們使用了 `StartApp.Simple` module 來源為[the start-app package](http://package.elm-lang.org/packages/evancz/start-app/latest)接著我們需要更新 `StartApp` module. 它可以用來處理更複雜的應用
. It has [a slightly fancier API](http://package.elm-lang.org/packages/evancz/start-app/latest/StartApp)他將可以處理 new `init` 與 `update` types.

其中需要注意的一點是 `getRandomGif` function 用來定義如何取得 random GIF，他使用了 [tasks][] 與 [the `Http` package][http], 下面的範例將會教導如何使用他們:

[tasks]: http://elm-lang.org/guide/reactivity#tasks
[http]: http://package.elm-lang.org/packages/evancz/elm-http/latest

```elm
getRandomGif : String -> Effects Action
getRandomGif topic =
  Http.get decodeImageUrl (randomUrl topic)
    |> Task.toMaybe
    |> Task.map NewGif
    |> Effects.task

-- 第一行創造了一個 HTTP GET request. 他試著
-- 去從  `randomUrl topic`取得JSON 
-- 並且使用 `decodeImageUrl`解析它，下方可以看到他們的定義
--
-- 接著我們使用了 `Task.toMaybe`來抓取任何潛在的錯誤 
-- 並且讓 `NewGif` tag 的結果轉為 `Action`.
-- 最後我們將它轉為 `Effects` value 讓它可以用在接下來的
-- `init` 或是 `update` functions中.


-- 給入一個 topic,與 URL 傳給 giphy API.
randomUrl : String -> String
randomUrl topic =
  Http.url "http://api.giphy.com/v1/gifs/random"
    [ "api_key" => "dc6zaTOxFJmzC"
    , "tag" => topic
    ]


--  JSON decoder 將會接受大批的 JSON 並且
-- 取出其中的 `json.data.image_url` 
decodeImageUrl : Json.Decoder String
decodeImageUrl =
  Json.at ["data", "image_url"] Json.string
```

當我們寫好這些後，未來，我們將可以使用 `getRandomGif` 於 `init`與 `update` functions中

其中有趣的一點是， `getRandomGif`所返回的task將永遠不會失敗，因為我們希望所有可能發生的失敗都要被明確的處理，下面將會解釋這點。

每個`Task` 有兩個型態，分別為 failure type 與 success type。 舉例來說:一個 HTTP task 可能有一個type 類似 `Task Http.Error String`
以此範例來說，它可能會失敗於`Http.Error` 或是成功返回 `String`， 這讓我們可以處理一系列的task並且不用處理錯誤發生。

現在，假設我們有一個 component 要求了一個  task, 但是這個 task 失敗了。接下來會發生什麼事? 誰會被通知? 該如何復原它? 
我們創造了一個發生錯誤時的錯誤型態 `Never` 我們讓任何可能發生的錯誤，都轉到了 success type ，讓他們可以明確地被處理。
在範例中，我們使用了 `Task.toMaybe : Task x a -> Task y (Maybe a)` 所以我們的 `update` function 可以精準的處理 HTTP failures的情況。



## Example 6: Pair of random GIF viewers

**[demo](http://evancz.github.io/elm-architecture-tutorial/examples/6.html) / [see code](examples/6/)**

一般的effects 可以被處理，但如果是*巢狀的* effects呢?這個範例使用了和範例 5同樣的程式，用來建立一對獨立的GIF viewers.

在你看完 [the implementation](examples/6/RandomGifPair.elm)後，你會發現他和範例二有點類似， 其中的 `Model`定義了兩個 `RandomGif.Model` 的值:

```elm
type alias Model =
    { left : RandomGif.Model
    , right : RandomGif.Model
    }
```

這讓我們可以分別的處理它們。 其中的actions指是負責用來傳遞訊息到子組件用的。

```elm
type Action
    = Left RandomGif.Action
    | Right RandomGif.Action
```

我們使用 `Left` 與 `Right` 在我們的 `update` 與 `init` functions中

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
