このファイルは README.md の翻訳です。
commit 7d5d75bc7a2ecb87c0d7ed182a94ff4d128f722f 時点の README.md に基づいています。

# Elm アーキテクチャ

このチュートリアルでは　"Elm アーキテクチャ" を概説する。 "Elm アーキテクチャ" は全ての [Elm][] プログラムに見出す事が出来る。例えば、 [TodoMVC][] や [dreamwriter][] といったものから、[NoRedInk][] や [CircuitHub][] などの商用製品の中で動作しているものにもである。基本的なパターンはフロントエンドを Elm や JS や、他の何かで記述する際にも有用である。

[Elm]: http://elm-lang.org/
[TodoMVC]: https://github.com/evancz/elm-todomvc
[dreamwriter]: https://github.com/rtfeldman/dreamwriter#dreamwriter
[NoRedInk]: https://www.noredink.com/
[CircuitHub]: https://www.circuithub.com/

Elm アーキテクチャは無限にネストされるコンポーネントの為の単純なパターンであり、モジュール性、コードの再利用、テストの観点で優れている。究極的には、このパターンは複雑なウェブアプリケーションを、モジュラー方式で簡単に構築する事を可能にする。このチュートリアルでは以下の 8 つの例を、核となる原理とパターンの上に構築し、動作させる。

  1. [カウンタ](http://evancz.github.io/elm-architecture-tutorial/examples/1.html)
  2. [二つのカウンタ](http://evancz.github.io/elm-architecture-tutorial/examples/2.html)
  3. [カウンタのリスト](http://evancz.github.io/elm-architecture-tutorial/examples/3.html)
  4. [カウンタのリスト(別の実装)](http://evancz.github.io/elm-architecture-tutorial/examples/4.html)
  5. [GIF 取得器](http://evancz.github.io/elm-architecture-tutorial/examples/5.html)
  6. [二つの GIF 取得器](http://evancz.github.io/elm-architecture-tutorial/examples/6.html)
  7. [GIT 取得器のリスト](http://evancz.github.io/elm-architecture-tutorial/examples/7.html)
  8. [二つのアニメーションする四角形](http://evancz.github.io/elm-architecture-tutorial/examples/8.html)

このチュートリアルは本当に役立つだろう!例 7 と 8 を超簡単に作るために必要な概念と考え方を明らかにする。 Elm の基礎に時間を費やすのはその価値があるよ!

これらのプログラム全てに見られる Elm アーキテクチャの非常に興味深い性質として一つ上げられるのは、それが Elm から自然に*現れる*事である。 あなたがこのチュートリアルを読んでいるかどうかや、 Elm アーキテクチャのご利益を知っているかどうかに関わらず、言語のデザインそれ自体があなたを Elm アーキテクチャへと導く。事実私はこのパターンを Elm を使っているだけで発見し、その単純明快さと応用範囲の広さに衝撃を受けた。

**注意**: このチュートリアルをコードを試しながら進めるには、[Elm をインストール](http://elm-lang.org/install)して、このレポジトリをフォークした方がいいだろう。このチュートリアルのそれぞれの例はどうやってコードを動作させれば良いか教えてくれる。


## 基本のパターン

全ての Elm プログラムのロジックは、以下の 3 つの部品に明確に分割する事ができる。

  * model
  * update
  * view

まずは拠り所としてふさわしい以下のスケルトンから初めて、それに個別のケースのコードを追加するかたちですすめていこう。

> もしあなたが Elm コードを初めて読むなら、[言語のドキュメント](http://elm-lang.org/docs)を参照するとよい。ドキュメントは言語の文法から、"関数プログラミング脳"の身につけ方まで、全てのカバーしている。[完全ガイド](http://elm-lang.org/docs#complete-guide)の最初の 2 節は、理解の速度を速めるだろう!

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
view model =
  ...
```

このチュートリアルはこのパターンの詳細と、小さな変更や拡張について説明する。


## 例 1: カウンタ

**[デモ](http://evancz.github.io/elm-architecture-tutorial/examples/1.html) / [ローカルホストで実行](examples/1/)**

最初の例は 1 の加算と 1 の減算のできる単純なカウンターである。

[コード](examples/1/Counter.elm)には始めに非常に単純な Model を定義する。カウンタを作るためには一つの数字を追跡し続ける事ができればよい。

```elm
type alias Model = Int
```

この Model を更新するとしても、コードは比較的単純なままである。実行されうる Action の集合を定義して、実際に Action を実行する `update` 関数を定義する。

```elm
type Action = Increment | Decrement

update : Action -> Model -> Model
update action model =
  case action of
    Increment -> model + 1
    Decrement -> model - 1
```

注意点としては、 `Action` [union 型][]は何か*する*わけではなく、あくまで取りうる Action の記述であるという事である。誰かがあるボタンを押されたらこのカウンタが 2 倍されるようにしようとした場合、それは `Action` の取りうる新しい値となる。これはつまり、このコードがモデルがどのように変形され得るか非常に明確になるという事である。このコードを読む人は、何ができて何ができないのか、すぐに知る事ができる。さらには、新しい機能を追加する一環した方法も正確に知る事ができる。

[union 型]: http://elm-lang.org/learn/Union-Types.elm

最後に、 `Model` を `view`(見る) 方法を作る。ここでは [elm-html][] を利用してブラウザでHTMLを表示する。 div 要素を作成して、その中に 1 の減算ボタンと、現在のカウントを格納する div 要素と、 1 の加算ボタンを格納する。

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

この `view` 関数のトリッキーな部分として、 `Address` がある。これについては次の節で詳しく説明する!今の所は、**このコードは完全に宣言的** であるという事を理解してほしい。このコードで `Model` を決めて、 `Html` を提供した。これがつまりそうである。どの部分でも DOM を手動で変化することがない。これはライブラリが[賢い最適化を行う為の自由度][elm-html]を提供し、全体として*より速い*レンダリングを現実のものとする。これはイかれたやり方だ。さらには `view` は昔ながらの普通の関数なので、これを作る時には、 Elm のモジュールシステム、テスト、フレームワーク、ライブラリの全ての力を借りる事ができる。

このパターンは Elm プログラムの構造化の本質である。これから見て行く全ての例はこの基本パターンの `Model` 、 `update` 、 `view` を、ほんの少し変えたものである。


## プログラムの開始

ほぼ全ての Elm プログラムは、アプリケーション全体を駆動する小さなコードを含む。このコードは、このチュートリアルの例それぞれで、 `Main.elm` というファイルに分離して格納されている。カウンタの例では、この興味深いコードは以下のようになる。

```elm
import Counter exposing (update, view)
import StartApp.Simple exposing (start)

main =
  start { model = 0, update = update, view = view }
```

ここでは最初の Model と同時に update と view 関数を記述するために、 [`StartApp`](https://github.com/evancz/start-app) パッケージを利用している。これは Elm の [signal](http://elm-lang.org/learn/Using-Signals.elm) に関係する部分の小さなパッケージで、さしあたって signal の事を知らずとも良いようにしてくれる。

アプリケーションを書き上げるための鍵は、 `Address` の概念である。この `view` 関数の中のすべてのイベントハンドラは、特定のアドレスを通知する。アドレスはデータの塊と一緒に送られる。 `StartApp` パッケージはこのアドレスに送られてくる全てのメッセージをモニタし、 `update` 関数に送り込む。モデルは更新され、 [elm-html][] は効率的な変更のレンダリングの面倒を見る。

この事はつまり、 Elm プログラムの値の流れは、以下のように一方向だということである。

![シグナルグラフの概要](diagrams/signal-graph-summary.png)

青い部品が我々の Elm プログラムのコアであるが、これはまさに何度も議論されてきた model/update/view パターンである。 Elm でプログラミングを行なう際には、この青い箱の中身に集中する事が出来るので、開発を大きく進める事ができる。

注意点として、アクションがアプリケーションに送り返されるのと同じように、このプログラムはアクションを*実行している*わけではないという事である。プログラムはただデータを送るだけである。この分割がアプリケーションを書き上げるための鍵の詳細であり、ロジックを view のコードから完全に分離しておく事である。


## 例 2: 二つのカウンタ

**[デモ](http://evancz.github.io/elm-architecture-tutorial/examples/2.html) / [ローカルホストで実行](examples/2/)**

例 1 では、基本的なカウンタを作成した。では、このパターンをスケールして、カウンタを *2* つにするにはどうしたら良いのだろう?モジュール性を維持出来るのだろうか?

例 1 のコード全てを再利用できたら素晴らしくはないだろうか? Elm アーキテクチャはイかれた事に、**コードは全く変更する事なく再利用できる**。例 1 で `Counter` モジュールを作成したが、細々とした実装が全てカプセル化されていたので、どこであっても再利用できる。

```elm
module Counter (Model, init, Action, update, view) where

type Model

init : Int -> Model

type Action

update : Action -> Model -> Model

view : Signal.Address Action -> Model -> Html
```

モジュール化されたコードを作成することは、協力な抽象レイヤを作成する事と同義である。正しく機能性を提供し、実装を隠す境界が欲しいところだが、たった今 `Counter` モジュールの外面から、基本的な値のセット、 `Model` 、 `init` 、 `Action` 、 `update` 、 `view` を見て来たばかりだ。これらの実装がどのようであるかは少しも気にする必要はない。実際のところ、それらがどのような実装かを知る事は*不可能*である。このことはつまり、公開されない実装の詳細を気にする必要はないという事だ。

`Counter` モジュールを再利用するのは、 `CounterPair` モジュールを作成するためである。いつも通り、まず `Model` からはじめよう。

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

`Model` は二つのフィールドを持つレコードであり、 1 つ 1 つがスクリーンに表示したいカウンタのものである。この `Model` はアプリケーションの全ての状態を完全に記述できる。同様に必要に応じて新しい `Model` を作成するために `init` 関数を作成する。

次にサポートしたい `Action` の集合を記述する。今度の機能は、全てのカウンターのリセット、上のカウンタの更新、下のカウンタの更新、である。

```elm
type Action
    = Reset
    | Top Counter.Action
    | Bottom Counter.Action
```

注意点として、 [union 型][]は `Counter.Action` 型を参照しているが、これらの action の詳細について知らないという事だ。 `update` 関数を作るときには、 `Counter.Actions` を適切な場所に引き回してやる。

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

さて、最後やらなければならない事は、 `view` 関数を作る事である。これは両方のカウンタをリセットボタンと一緒にスクリーンに表示する。

```elm
view : Signal.Address Action -> Model -> Html
view address model =
  div []
    [ Counter.view (Signal.forwardTo address Top) model.topCounter
    , Counter.view (Signal.forwardTo address Bottom) model.bottomCounter
    , button [ onClick address Reset ] [ text "RESET" ]
    ]
```

両方のカウンターに `Counter.view` 関数を再利用出来ている事に注意してほしい。それぞれのカウンタについて、転送 address を作成している。このコードでしている事は本質的に次のように言う事ができる、 &ldquo;これらのカウンタは送り出されるメッセージに `Top` もしくは `Bottom` のタグ付けを行い、違うものである事を知らせる。&ldquo;

これで全てである。イカした事に、モジュールはどんどんネストしていく事ができる。今 `CounterPair` モジュールを使えるようになったが、これは鍵となる値と関数を提供するので、 `CounterPairPair` や必要なものを何でも作る事ができる。


## 例 3: 動的なカウンタのリスト

**[デモ](http://evancz.github.io/elm-architecture-tutorial/examples/3.html) / [ローカルホストで実行](examples/3/)**

二つのカウンタはイカしていたが、カウンタのリスト、しかも適当な数になるようカウンタの追加や削除が出来るようなものについてはどうだろう? Em アーキテクチャのパターンはまた上手く適用できるのだろうか?

例 1 、例 2 がそうだったように、今回もまた `Counter` モジュールを完全に再利用する事が出来る!

```elm
module Counter (Model, init, Action, update, view)
```

これはつまり、 `CounterList` モジュールを作成するところから始めるという事である。いつも通り `Model` から始める。

```elm
type alias Model =
    { counters : List ( ID, Counter.Model )
    , nextID : ID
    }

type alias ID = Int
```

今回の Model はカウンタのリストである。それぞれのカウンタにユニークな ID が注記されている。これらの ID によりそれぞれのカウンタを区別する事が出来るので、例えば 4 番のカウンタを更新する必要がある時に、そのカウンタを参照する方法が出来た(この ID は同時に、レンダリングの最適化を考える際に依って立つ[`キー`][key]として役立つものであるが、この話題はこのチュートリアルの範囲外だ!)。この Model は同時に `nextID` を含んでおり、これは新しく追加したカウンタにユニークな ID を割り当てる時に役立つ。

[key]: http://package.elm-lang.org/packages/evancz/elm-html/latest/Html-Attributes#key

それでは Model に対して実行できる `Action` の集合を定義しよう。ここでは、カウンタの追加、カウンタの削除、指定されたカウンタを更新を行ないたいと考えている。

```elm
type Action
    = Insert
    | Remove
    | Modify ID Counter.Action
```

`Action` [union 型][]はビックリするほど高レベルの記述に近い。これで `update` 関数を定義できるようになった。

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

これは以下の各々の場合の高レベル記述である。

  * `Insert` &mdash; まず、新しいカウンタを作成しカウンタのリストの最後に追加する。そして `nextID` に 1 加算して次に使える新しい ID を用意する。

  * `Remove` &mdash; カウンタのリスト一番最初の内容を落とす。

  * `Modify` &mdash; 全てのカウンタを走査して、 ID が一致するものを見つけたら、与えられた `Action` をカウンタに適用する

もはやなすべき事は `view` を定義する事だけである。

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

一番面白い部分は `viewCounter` 関数である。これは今まで使ったのと同じ `Counter.View` 関数を使っているが、このケースでは全てのメッセージにレンダリングされるカウンターを指定する ID を全てのメッセージに付記した転送 address を提供している。

実際の `view` 関数を作成する時には、 `viewCounter` を全てのカウンタに map を用いて適用して、さらに `address` が直接送信される add 、 remove ボタンを作っている。

この ID のトリックは動的な数のサブコンポーネントが必要な時にはいつも使える。カウンタはとても単純だが、このパターンは ユーザプロファイル、 tweet、ニュースフィードアイテム、製品の詳細情報のリストを扱う時にも全く同じである。


## 例 4: もっと凝ったカウンタのリスト

**[デモ](http://evancz.github.io/elm-architecture-tutorial/examples/4.html) / [ローカルホストで実行](examples/4/)**

よし、動的なカウンタのリストについては、じつにイカした感じで簡潔さとモジュール性を維持出来たね。でも、グローバルな削除ボタンの代わりにそれぞれのカウンタ毎に削除ボタンを付けられないかな?*そいつ*は確かにコードが汚くなりそうだ!

いんや、 Elm アーキテクチャはやっぱりうまくやるよ。

このケースのゴールから考えるに、 `Counter` に、 削除ボタンを追加した新しい view を作らなきゃいけない。面白い事に、前の `view` 関数はそのままに、基底の `Model` にちょっとばかし違う view を提供してくれる `viewWithRemoveButton` 関数を追加出来る。実にグッとくるね。コードの複製だとか、サブタイピングやオーバーロードとか、その手のイカレたことはなんもしなくていい。単に新しい関数を追加して、公開 API として新しい機能を提供してやればいい!

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

`viewWithRemoveButton` 関数は新しくボタンを一つ追加する。気をつけたいのは 1 加算/ 1 減算ボタンはメッセージを `action` アドレスに送るが、削除ボタンは `remove` アドレスに送るって点だ。 `remove` に向けて送ったメッセージは、つまるところこんな意味だ。 &ldquo;よう、誰が俺の上に居るのかしらんけどさ、俺を削除してくれよな!&rdquo; 削除するかどうかは、そのカウンタの上に居る奴次第だ。

`viewWithRemoveButton` が出来たから、カウンタをまとめて配置してくれる `CounterList` モジュールを作れるようになった。 `Model` はほとんど例 3 とおなじで、カウンタのリストとユニークな ID だ。

```elm
type alias Model =
    { counters : List ( ID, Counter.Model )
    , nextID : ID
    }

type alias ID = Int
```

Action の集合はちょいと変わって来る。古いカウンタのどれかをどかす代わりに、特定のカウンタを削除するようにしたい。そういうわけで、　`Remove` ケースは ID を持つようになる。

```elm
type Action
    = Insert
    | Remove ID
    | Modify ID Counter.Action
```

`update` 関数は例 3とほとんど同じだ。

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

`Remove` ケースは、 ID を頼りに削除することになってるカウンタをとりだすようになっている。でもまあ、ほとんど前と同じだ。

最後にこいつらを `view` に入れ込んでやろう。

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

この `viewCounter` 関数では、メッセージを渡し込むために必要な転送 Address として `Counter.Context` を構築してる。注記を付加した `Counter.Action` のどの場合も、どのカウンタが更新されたり削除されれば良いのか分かるようになっている。


## ここまでで重要な事柄

**基本パターン** &mdash; 全ては `Model` の周りに作られていく、 Model を `update` する方法、 Model を `view` する方法。全てこの基本パターンから派生する。

**モジュールのネスト** &mdash; 転送 Address は基本パターンを簡単にネストできるようにしてくれる。基本パターンは好きな深さにネストできるし、それぞれの階層では一つ下の階層で何が起きているのかさえ分かっていればいい。

**Context の追加** &mdash; Model に対して `update` もしくは `view` するときに、追加の情報が必要になることがある。そのときは、 `Context` をそれらの関数に追加して、追加情報と一緒に引き渡す。そうすると `Model` を複雑にする必要がなくなる。

```elm
update : Context -> Action -> Model -> Model
view : Context' -> Model -> Html
```

ネストの全ての階層でそれぞれのサブモジュールのための特別な `Context` を作り出す事ができる。

**テストが簡単** &mdash; ここまでで作った関数は全て[純粋な関数][pure]だった。こうすることで、 `update` 関数のテストがとんでもなく簡単になる。特別な初期化やモックの準備や設定は必要なくなり、テストしたい関数に引数を渡して呼び出せばテストが出来る。

[pure]: http://en.wikipedia.org/wiki/Pure_function


## 例 5: ランダム GIF ビューワ

**[デモ](http://evancz.github.io/elm-architecture-tutorial/examples/5.html) / [ローカルホストで実行](examples/5/)**

無限にネスト出来るコンポーネントをどう作ればいいかはわかったけど、 HTTP リクエストを投げたい場合はどうしたら良いんだろう?あるいはデータベースと対話するばあいは?この例では、 [`elm-effects` パッケージ][fx]を使って、 giphy.com から “funny cats” というトピックでランダムな GIF ファイルを取って来る簡単なコンポーネントを作ってみる。

[fx]: http://package.elm-lang.org/packages/evancz/elm-effects/latest

[実装](examples/5/RandomGif.elm)をざっと見ると、カウンタを作った例 1 とほとんどコードが同じだって事に気付くだろう。 `Model` はとってもありきたりだ。

```elm
type alias Model =
    { topic : String
    , gifUrl : String
    }
```

この例を作るためには、 GIF ファイルを探すための `topic` は何か、表示する `gifUrl` は何か、この二つを知る必要がある。この例で唯一新しい部分は、 `init` と `update` で、ちょっとだけ凝ったデータ型になっている。

```elm
init : String -> (Model, Effects Action)

update : Action -> Model -> (Model, Effects Action)
```

このコードは単に新しい `Model` を返す代わりに、実行したい Effects も一緒に返す。これにより、 [`Effects` API][fx_api]　を使えるようになる。

[fx_api]: http://package.elm-lang.org/packages/evancz/elm-effects/latest/Effects

```elm
module Effects where

type Effects a

none : Effects a
  -- don't do anything

task : Task Never a -> Effects a
  -- request a task, do HTTP and database stuff
```

`Effects` 型は本質的にはデータ構造であり、後で走らせる予定のひとまとまりの Task を保持している。 `update` の中を見て、どのように動くのか感じをつかもう。

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

ユーザは “More Please!” ボタンを押して `RequestMore` アクションを発動できる。サーバが応答を返すと、 `NewGif` アクションが発動する。 `update` 関数ではこれらのアクションの両方のシナリオを取り扱う。

`RequestMore` については、まず既に存在する Model を返す。ユーザがボタンをクリックしたあと、すぐには何も起こらない。同様に `getRandomGif` 関数を使って、 `Effect Action` を作る。どうやって `getRandomGif` を定義するかについてはすぐに説明する。今はいつ `Effects Action` が走り、アプリケーション全体に引き回される一連の `Action` の値が発生するのか知っておけばいい。さて、 `getRandomGif model.topic` は動作すると次のような結果を返す。

```elm
NewGif (Just "http://s3.amazonaws.com/giphygifs/media/ka1aeBvFCSLD2/giphy.gif")
```

Action は　`Maybe` を返す。これはサーバへの要求が失敗する事があるからだ。 `Action` は `update` 関数にフィードバックされる。そして、 update 関数中の `NewGif` のケースを通ると、それが出来る場合に現在の `gifUrl` を更新する。もし要求が失敗した場合には、現在の `model.gifUrl` がそのまま返される。

`init` も同様の内容で、 Model の初期状態を定義し、現在の topic で giphy.com の API から GIF ファイルを探す。

```elm
init : String -> (Model, Effects Action)
init topic =
  ( Model topic "assets/waiting.gif"
  , getRandomGif topic
  )

-- getRandomGif : String -> Effects Action
```

ランダム GIF 取得 Effect が処理を終えた時は、いままでと同じように `Action` が `update` 関数に引き回される。

> **注意:** これまでは [start-app パッケージ](http://package.elm-lang.org/packages/evancz/start-app/latest)の　`StartApp.Simple` モジュールを使っているだけだったが、今度は `StartApp` モジュールを使っている。これはより実際に近いの web アプリケーションの複雑さを扱う事ができて、[少し凝った API](http://package.elm-lang.org/packages/evancz/start-app/latest/StartApp) を持っている。重要な違いは、この例の新しい `init` 型と `update` 型を取り扱えるようになった事だ。

この例の重要な部分の一つは、 `getRandomGif` 関数で、この関数こそにランダムな GIF を取って来る方法が記述されている。この関数は [tasks][] と [`Http` パッケージ][http]を使っており、これらがどのように使われるのかおいおい説明してみる。まずは定義を見てみよう。

[tasks]: http://elm-lang.org/guide/reactivity#tasks
[http]: http://package.elm-lang.org/packages/evancz/elm-http/latest

```elm
getRandomGif : String -> Effects Action
getRandomGif topic =
  Http.get decodeImageUrl (randomUrl topic)
    |> Task.toMaybe
    |> Task.map NewGif
    |> Effects.task

-- この最初の行は HTTP GET リクエストを作成している。このリクエストは `randomUrl topi` の中で
-- いくばくかの JSON を取り出し、 `decodeImageUrl` をつかって結果を復号する。
-- どちらも以下で定義されている!
--
-- つづいて `Task.toMaybe` を使っている。これは起こりうる失敗を捕捉したり、
-- 結果を `Action` に変換するために `NewGif` タグを適用したりする。
-- 最後に、 `init` 関数や `update` 関数で使われる `Effects` 値に変換される。


-- 渡されたトピックに基づいて giphy API に渡す URL を構築
randomUrl : String -> String
randomUrl topic =
  Http.url "http://api.giphy.com/v1/gifs/random"
    [ "api_key" => "dc6zaTOxFJmzC"
    , "tag" => topic
    ]


-- JSON 複合器。 giphy から吐き出される大きな JSON の塊を受け取り、
-- `json.data.image_url` の文字列を引き出す。
decodeImageUrl : Json.Decoder String
decodeImageUrl =
  Json.at ["data", "image_url"] Json.string
```

これらを書きあげたら、先の `init` 関数と `update` 関数で `getRandomGif` 関数を再利用できる。

`getRandomGif` によって返される Task の興味深い点の一つは、 `Never` により絶対に失敗しないという事である。これは、起こりうる失敗は明示的に対応*されなければならない*、という考え方である。どんな Task も知らないうちに失敗していてほしくはない。

そのうちこの仕組みがどのように働くのか説明しようと思うが、使うだけなら全部を知ることは重要じゃない!でだ、そういうわけで全ての `Task` が失敗の変数型と成功の変数型を持っている。例えば、 HTTP Task は `Task Http.Error String` という型を持っていて、 `Http.Error` を返して失敗したり、 `String` を返して成功したりする。これによりエラーをそんなに気にする事なく、いくつもの Task を繋げやすくなっている。では、この例のコンポーネントが Task をリクエストしたが、失敗したとしよう。この時なにが起こるだろうか?だれが失敗の通知を受けるのだろうか?どうやって復旧したらいいのだろうか?失敗の型 `Never` を作る事で、起こりうるエラーを成功の型に押し込み、コンポーネントにより明示的に扱えるようになる。このケースでは、 `Task.toMaybe : Task x a -> Task y (Maybe a)` を使い、 `update` 関数は明示的に HTTP の失敗を取り扱う。これはつまり Task は何も知らせずに失敗する事がないということであり、起こりうるエラーを常に明示的に処理しなければならないという事だ。


## 例 6: 二つのランダム GIF 取得器

**[デモ](http://evancz.github.io/elm-architecture-tutorial/examples/6.html) / [ローカルホストで実行](examples/6/)**

やったね、 Effect を使えるようになった。でも Effect の*ネスト*はどうだろう?その事を考えていたかな?!この例では例 5 の GIF 取得器のコードをそのまま再利用して、二つの GIF 取得器を作る。

[実装](examples/6/RandomGifPair.elm)をみれば分かるように、例 2 の二つのカウンタ場合とコードはほとんど同じだ。 `Model` は二つの `RandomGif.Mode` 値として定義される。

```elm
type alias Model =
    { left : RandomGif.Model
    , right : RandomGif.Model
    }
```

これで、それぞれを独立に追跡し続けられるようになった。 Action は、適切なサブコンポーネントに引き回すためのメッセージだ。

```elm
type Action
    = Left RandomGif.Action
    | Right RandomGif.Action
```

興味深いのは、 `Left` と `Rigth` タグは `update` 関数と `init` 関数のなかで実際にすこし使われるということだ。

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

それぞれの分岐で `RandomGif.update` 関数を呼び出し、新しい Model と Effect が返される。 Effect はここでは `fx` と名付ける。このあと Model は通常通り更新されたものを返すが、 Effect には少し追加の処理が必要だ。 Effect はそのまま返す代わりに、 [`Effects.map`](http://package.elm-lang.org/packages/evancz/elm-effects/latest/Effects#map) 関数を適用する。これは Effect を同じ種類の `Action` に変換するためだ。この働きは `Signal.forwardTo` とほとんど同じで、値にタグ付けをしてどのように引き回されるべきか明確にしてくれる。

`init` 関数でも同様だ。それぞれのランダム GIF 取得器にトピックを設定し、 Model の初期状態といくばくかの Effect を定義する。

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

このケースでは、 `Effects.map` を結果に適切にタグ付けするために使うだけではなく、それらを全部まとめるために [`Effects.batch`](http://package.elm-lang.org/packages/evancz/elm-effects/latest/Effects#batch) 関数を使っている。全ての要求された Task は別個に起動され、実行される。そして、 Left と Right の Effect の処理は同時に進む。


## 例 7: ランダム GIF 取得器のリスト

**[デモ](http://evancz.github.io/elm-architecture-tutorial/examples/7.html) / [ローカルホストで実行](examples/7/)**

この例はランダム GIF 取得器のリストの作り方を説明する。このリストではトピックを自分で作り出せる。これまで通り、 `RandomGif` モジュールをそのまま再利用する。

[実装](examples/7/RandomGifList.elm)に目を通せば、例 3 と完全に対応している事が見て取れるだろう。サブモジュールを ID と紐づけてリストに入れて、 ID に基づいて操作を行なう。唯一の新しい部分としては、 `init` 関数と `update` 関数のなかで `Effects` を扱っている点だ。 `Effects.map` と `Effects.batch` を使って操作をしている。

こいつがどのように動いているかもっと詳しく説明が必要なら、 issue を開いてくれ!


## 例 8: 二つのアニメーションする四角形

**[デモ](http://evancz.github.io/elm-architecture-tutorial/examples/8.html) / [ローカルホストで実行](examples/8/)**

ここまでで、色々な方法でネスト出来るコンポーネントとそれに対する Task を見て来た。しかしアニメーションについてはどうだろう?

面白いことに、これまでとほとんど同じだ!(まあでも、もう驚かないかもしれないね、同じパターンが他の例でも動く事を見て来たし... つまりそれだけ Elm アーキテクチャは良いパターンだってことさ!)

この例では二つのクリック可能な四角形を作る。四角形をクリックすると、クリックした四角形は 90 度回転する。コードの全体は例 2 と例 6 をこの例に合うように変えたもので、アニメーションのための全てのロジックは `SpinSquare.elm` に格納されていて、 `SpinSquarePair.elm` から何度も再利用される。

さて、新しく興味深い要素の全ては、 [`SpinSquare` の中にある](examples/8/SpinSquare.elm)。なので、このコードについて詳しく見てみよう。まず最初に必要なのは Model だ。

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

さて、　Model の核は `angle` で、これは四角形の現在の傾きだ。そして `animationState` により、現在進行中のアニメーションで何が起こっているのか追跡できる。アニメーションしていなければ、この値は `Nothing` になる。もし何かが起こっていれば、その`何か`が保持される。
  
  * `prevClockTime` &mdash; もっとも最近の時刻。時間の差分を算出するために使う。最後のフレームから何ミリ秒たったか正確に知る助けになる。
  * `elapsedTime` &mdash; 0 から `duration` までの値。アニメーションをどのくらいしているか教えてくれる。

定数 `rotateStep` は、一回のクリック毎にどれだけ回転するかを宣言しているだけだ。値をいじってもこの例はちゃんと動く。

では 　`update` の興味深い部分を見て行こう。

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

ここでは 2 種類の `Action` を処理しなくてはならない。

  - `Spin` はユーザが四角形をクリックした事を知らせ、回転するよう要求する。 `update` 関数では、アニメーションしていない時は clock tick を要求し、既に進行中のものをそのままにしておく。
  - `Tick` は clock tick の到着を知らせるので、これが到着するとアニメーションの次の段階に進めなければならない。これはつまり `update` 関数で `animationState` を更新しなければならないということだ。なので、まずアニメーションが進行中かどうか調べる。進行中なら、現在の `elapsedTime` を取得して、そして時間の差をそれに足して、 `newElapsedTime` を知る事ができる。 elapsed Time が `duration` より大きい場合、アニメーションを止めて、 clock tick の要求を止める。そうでなければ、 アニメーションの状態(animationState) を更新して、また別の clock tick を要求する。

今回もまた、コードをきりつめる事が出来そうだ。こういうふうにコードを書くにつれて、一般的なパターンを見出しはじめている。パターンを見つけるのはワクワクするね!

最後の `view` 関数はちょっと興味深い!この例はいい感じの跳ねるアニメーションをするけれど、コードに書いたのは Model の字面の上で `elapsedTime` を増やしているだけだ。何がおきているんだろうか?

`view` コードそれ自体は、完璧に標準的な [`elm-svg`](http://package.elm-lang.org/packages/evancz/elm-svg/latest/) のもので、これは凝ったクリック可能な図形を作るためのものだ。これのイケてるところは、 view のコードは `toOffset` で、これは現在の `AnimationState` に対する回転オフセットを算出する。

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

ここでは、 [@Dandandan](https://github.com/Dandandan) の [easing パッケージ](http://package.elm-lang.org/packages/Dandandan/Easing/latest)を使う。このパッケージは数字、点、さらに望むなら他のイカれた何かに、[あらゆる種類のイカす平滑化](http://easings.net/)を施す事ができる。

`ease` 関数は 0 から `duration` の間の数を取る。そして、 0 から　`rotateStep` の間の数字に変換する。 `rotateStep` はプログラムの最初で 90 度に設定した。さらに平滑化を行なおう。このケースでは `easeOutBouce` を使っている。これに 0 から `duration` へと値を変えながら入力すると、 0 から 90 までの値に平滑化のための値が足されて出力される。これはイカレてるね! `easeOutBounce` を[他の平滑化](http://package.elm-lang.org/packages/Dandandan/Easing/latest/Easing)に変えみて、どんな風になるか見てみよう!

ここまでで、 `SpinSquarePair` の全てが繋がった。でも、コードは例 2 や　例 6 ともうほとんど同じだった。

よし、これがこのライブラリを使ってアニメーションをやる場合の基本だ!このやり方が一番いいかどうかは、まだわからない。なので、あなたがもっと経験を積んだら、どうやったら良いか教えてほしい。願わくばもっと簡単に作れるようになっている事を!

> **注意:** 僕はこの問題についてなにがしかの抽象階層を、核となるアイディアの上に設けることができるとおもっている。この例はちょっと低い階層の処理をしているけれど、このもっと問題と付き合っていれば、なんか良いパターンを見つけてこいつをもっと簡単にできると思っている。もし今なんかおかしい部分が見つかったら、改良にチャレンジして、それを僕らに教えてくれよな!
