title: RxJS 初探
date: 2019-07-13 16:28:30
categories: JuntingLiu
tags: 
- RxJS
- redux-observable
---

&emsp;&emsp;RxJS 最近经常被提起，但其实在工作中，我并没有怎么用到过 RxJS，只在公司内部封装的桥接库中使用过。所以 RxJS 是没多少使用场景么？到底为什么要学习 RxJS 呢？

<!--more-->

# 一、什么是 RxJS 
&emsp;&emsp;RxJS 是 Reactive Extension 这种模式的 JS 实现。它使用了一种不同于传统的编程模式----函数响应式编程。也有人称它为操作数据流的 「lodash」，旨在更方便的处理数据流。

## 函数式编程
用函数来解决问题的一种编程范式，主要特点有：声明式、纯函数、数据不可变性。
## 响应式编程
响应式编程是一个编程范式，但是与其他编程范式不同的是它是基于数据流和变化传播的。比如 A = B + C, 如果我们运用一种机制，当 B 或 C 变化时，A 也同时变化，这样就实现了响应式。我们熟悉的 React、Redux 就利用了响应式。
## Reactive Extension
Reactive Extension，也叫ReactiveX，或者简称Rx，指的是实践响应式编程的一套工具，是一套通过可监听流来做异步编程的API。Rx的概念最初由微软公司实现并开源，也就是Rx.NET，因为Rx带来的编程方式大大改进了异步编程模型，在.NET之后，众多开发者在其他平台和语言上也实现了Rx的类库，如 RxJava、RxJS 、Rx.NET。

----------------------

# 二、RxJS 中的基本概念与原理
&emsp;&emsp;任何数据都可以被表达为数据流的形式，我们需要对数据流进行创建、订阅、过滤、转换、合并等各种操作，RxJS 便可以很好的解决这些问题。

<img src="https://user-images.githubusercontent.com/14134344/62932664-28c1c180-bdf3-11e9-9f0f-64a648101070.png" width="600" height="400"/>

## 在 RxJS 中用来解决异步事件管理的的基本概念是
  * Observable (可观察对象): 表示一个概念，这个概念是一个可调用的未来值或事件的集合。
  * Observer (观察者): 一个回调函数的集合，它知道如何去监听由 Observable 提供的值。
  * Subscription (订阅): 表示 Observable 的执行，主要用于取消 Observable 的执行。
  * Operators (操作符): 采用函数式编程风格的纯函数 (pure function)，使用像 map、filter、concat、flatMap 等这样的操作符来处理集合。
  * Subject (主体): 相当于 EventEmitter，并且是将值或事件多路推送给多个 Observer 的唯一方式。
  * Schedulers (调度器): 用来控制并发并且是中央集权的调度员，允许我们在发生计算时进行协调，例如 setTimeout 或requestAnimationFrame 或其他。

以上概念大部分依据发布订阅模式去思考都是比较容易理解的。对我来说比较不太理解的是 Subject 的存在。为什么只有通过 Subject 才能实现多播，而多次对一个普通的 observable 进行 subscribe 不能实现多播？下面通过一段代码来解释这个问题。
```
const numbers$ = interval(1000).pipe(take(3));
numbers$.subscribe(value => {
  console.log("observer1: " + value);
});
setTimeout(() => {
  numbers$.subscribe(value => {
    console.log("observer2: " + value);
  });
}, 1000);
```
你觉得这段代码的输出结果是？
```
observer1: 0
observer1: 1
observer2: 1
observer1: 2
observer2: 2
```
实际结果：
```
observer1: 0
observer1: 1
observer2: 0
observer1: 2
observer2: 1
observer2: 2
```

虽然我们对 Observable 做了多次 subscribe，但是对于每个 Observer ，其实都有一个独立的数据流。而真正的多播应该是同一个数据源的。其实这种区别涉及了一个概念叫做 Cold Observable 和 hot Observable， interval 实际上产生的是一个 Cold Observable，而 Cold Observable 是无法实现真正的多播的。

## RxJS 的设计模式
### 发布订阅
<img src="https://user-images.githubusercontent.com/14134344/62932669-2bbcb200-bdf3-11e9-92bc-cf6c117505c9.png" width="500" height="200"/>
### 迭代器 
迭代器模式是指提供一种方法，顺序访问一个聚合对象中的各元素，而又不需要暴露该对象的内部表示。迭代器模式的实现主要处理以下三种情况：
* 获取下一个值
* 无更多值
* 错误处理

```
const observable$ = Observable.create(observer => {
  observer.next(1);
  observer.next(2);
  observer.complete();
});

const observer = {
  next: x => console.log("Observer got a next value: " + x),
  error: err => console.error("Observer got an error: " + err),
  complete: () => console.log("Observer got a complete notification")
};

observable$.subscribe(observer);

// 输出结果
// Observer got a next value: 1
// Observer got a next value: 2
// Observer got a complete notification
```
----------------------

# 三、RxJS 的使用示例
## 防抖
```
class RxSearch extends Component {
  constructor(props) {
    super(props);
    this.state = {
      search: "",
      debounced: ""
    };
    this.onSearch$ = new Subject();
  }
  componentDidMount() {
    this.subscription = this.onSearch$
      .pipe(debounceTime(300))
      .subscribe(debounced => this.setState({ debounced }));
  }

  componentWillUnmount() {
    this.subscription && this.subscription.unsubscribe();
  }

  onSearch = e => {
    const search = e.target.value;
    this.setState({ search });
    this.onSearch$.next(search);
  };

  render() {
    const { search, debounced } = this.state;
    return (
      <div>
        <input type="text" value={search} onChange={this.onSearch} />
        <div>debounced value: {debounced}</div>
      </div>
    );
  }
}

```
当然，防抖节流类有很多工具库，比如 lodash、Ramda 。但对于函数式编程的实践 lodash 是不够的，而且这些库更多的目的是工具库，而不是处理数据流，如果有更多的要求，这些库处理起来是不够优雅的。比如结果再延迟 1000 毫秒显示，结果做过滤、转换、取消失效结果、自动重试等等。
## 快速切换筛选条件，结果竟态
```
this.onClickFilter$
  .pipe(
    debounceTime(300), // 加入 debounce 特性，停止输入 500ms 之后再发送请求
    distinctUntilChanged(), //内容不变时不再继续流水线
    // switchMap 后前面的请求会被自动 cancel 掉，天然避免竞态问题
    switchMap(filter =>
      from(fetch("https://api.github.com/repos/ReactiveX/rxjs"))
    )
  )
  .subscribe(data => {
    console.log(data);
  });
```
## 批量请求异步数据流的集中管理与重试
```
const source$ = range(1, 5);
source$
  .pipe(
    mergeMap(x => {
      return fetch(`https://api.github.com/repos/ReactiveX/rxjs`).then(res => {
        if (res.status !== "200") {
          throw new Error("Error!");
        } else {
          return of(res);
        }
      });
    }),
    retry(2),
    catchError(err => of(err))
  )
  .subscribe(x => console.log("source1$:", x));
```

## RxJS 结合 Redux 驱动 React
我们在工作中，大部分时候会用数据管理的库结合 UI 框架去开发，比如 Vuex + Vue，Redux + React 等，所以此处我们来实践一下 Rxjs + Redux + React 。
为什么不干脆用 RxJS 代替 Redux ？Redux 的社区相对更成熟，Redux 不足的是对异步的处理，周边已经有了 redux-thunk、redux-promise、redux-saga 等一系列的中间件。RxJS 也可以提供更优雅的异步处理能力，而与此对应的中间件便是redux-observable 。（[对比参考](https://juejin.im/entry/58db23552f301e007e9786a2)）

> Store.js
```
import { createStore, applyMiddleware } from "redux";
import { createEpicMiddleware } from "redux-observable";
import reducer from "./Reducer";
import epic from "./Epic";

const initValues = {
  count: 0
};
const epicMiddleware = createEpicMiddleware();
const store = createStore(reducer, initValues, applyMiddleware(epicMiddleware));
epicMiddleware.run(epic);
export default store;
```

> Epic.js
```
import { increment, decrement } from "./Actions";
import * as ActionTypes from "./ActionTypes";
import { delay, filter, map } from "rxjs/operators";

const epic = (action$, state$) => {
  return action$.pipe(
    filter(
      action =>
        action.type === ActionTypes.DECREMENT ||
        action.type === ActionTypes.INCREMENT
    ),
    delay(1000),
    map(action => {
      const count = state$.value.count;
      console.log(action$, state$);
      if (count > 0) {
        return decrement();
      } else if (count < 0) {
        return increment();
      } else {
        return { type: "no-op" };
      }
    })
  );
};

export default epic;
```

>Counter.js
```
import { connect } from "react-redux";
import * as Actions from "../../redux/Actions";
import CounterView from "./CounterView";

function mapStateToProps(state, ownProps) {
  return { count: state.count };
}
function mapDispatchToProps(dispatch, ownProps) {
  return {
    onIncrement: () => dispatch(Actions.increment()),
    onDecrement: () => {
      debugger;
      const action = Actions.decrement();
      return dispatch(action);
    },
    reset: () => {
      dispatch(Actions.reset());
    }
  };
}
const ReduxCounter = connect(
  mapStateToProps,
  mapDispatchToProps
)(CounterView);
export default ReduxCounter;
```
Reducer.js Action.js 等和基础 Redux 使用时没有区别的，最需要关注的就是 Epic.js, 我们在 Epic 里，可以随意的使用 RxJS 提供的异步处理能力，而且可以保证真正的 Action 动作不需要写到组件逻辑中（可以对比 thunk 、promise 等方案的代码）

---------------------

# 四、总结
我认为学习 RxJS 的原因有两点: 
* RxJS 为我们提供了便捷处理异步数据流的能力。比如上文所提到的节流防抖、结果竟态、重试、数据流合并、多播等问题。当然，RxJS 不仅限于解决这些问题，还有很多本文没有涉及到，比如调度器的提供使我们更便捷的调度异步数据流、多种 Subject 的变体使我们可以进行便捷的进行多样化的多播。
* RxJS 的编程范式以及设计模式都是我们该去了解的知识。

学习方法总结:
* 掌握基础操作符，才能体会到 RxJS 的能力
* 利用弹珠图理解基础操作符

----------------------

# 五、学习资料
* [中文文档](https://cn.rx.js.org/manual/overview.html#h11)
* [英文文档](https://rxjs.dev/api)
* [弹珠图](https://rxviz.com/examples/custom-operator)
* [redux-observable](https://github.com/redux-observable/redux-observable)

----------------------
本文部分内容参考自程墨的 《RxJS 深入浅出》，建议大家有时间亲自读一下这本书。
本文内容如有错误或不妥，欢迎交流指正。
