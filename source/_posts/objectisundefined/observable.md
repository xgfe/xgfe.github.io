title: 谈谈Observable
date: 2018-08-23 12:00:00
categories:
- tianzhen
- Observable
tags: 
- Observable
- RxJS
- Functional Reactive Programming
---

## Observable是什么
数据处理过程中，存在数据的生产者 (Producer) 和数据的消费者 (Consumer) ，处理方式基本分为拉取 (Pull) 和 推送 (Push)两种。

| |	生产者 | 消费者 |
| --- | --- | --- |
| **拉取** | **被动的:** 当被请求时产生数据。 |	**主动的:** 决定何时请求数据。|
| **推送** | **主动的:** 按自己的节奏产生数据。 |	**被动的:** 对收到的数据做出反应。|

在拉取体系中，由消费者来决定何时从生产者那里接收数据。生产者本身不知道数据是何时交付到消费者手中的。每个 JavaScript 函数都是拉取体系。函数是数据的生产者，调用该函数的代码通过从函数调用中“取出”一个单个返回值来对该函数进行消费。ES2015 引入了一种新的的拉取体系, generator 和 iterator。由消费者调用 iterator.next() 从 iterator(生产者) 那“取出”值。

在推送体系中，由生产者来决定何时把数据发送给消费者。消费者本身不知道何时会接收到数据。在当今的 JavaScript 世界中，Promise 是最常见的推送类型。Promise(生产者) 将一个 resolve 过的值传递给已注册的回调函数(消费者)，但不同于函数的是，由 Promise 来决定何时把值“推送”给回调函数。

**Observable 是多个值的生产者，并将值“推送”给观察者(消费者)。**

    Function 是惰性的评估运算，调用时会同步地返回一个单一值。
    Generator 是惰性的评估运算，调用时会同步地返回零到(有可能的)无限多个值。
    Promise 是最终可能(或可能不)返回单个值的运算。
    Observable 是惰性的评估运算，它可以从它被调用的时刻起同步或异步地返回零到(有可能的)无限多个值。

**Observable 像是没有参数, 但可以泛化为多个值的函数。**

考虑如下代码：
```js
function foo() {
  console.log('Hello');
  return 42;
}

var x = foo.call(); // 等同于 foo()
console.log(x);
var y = foo.call(); // 等同于 foo()
console.log(y);
```
我们期待看到的输出：
```
"Hello"
42
"Hello"
42
```
使用Rx.js，你可以使用 Observable 重写上面的代码：
```js
var foo = Rx.Observable.create(function (observer) {
  console.log('Hello');
  observer.next(42);
});

foo.subscribe(function (x) {
  console.log(x);
});
foo.subscribe(function (y) {
  console.log(y);
});
```
输出是一样的:
```js
"Hello"
42
"Hello"
42
```
这是因为函数和 Observable 都是惰性运算。如果你不调用函数，console.log('Hello') 就不会执行。Observable 也是如此，如果你不“调用”它(使用 subscribe)，console.log('Hello') 也不会执行。此外，“调用”或“订阅”是独立的操作：两个函数调用会触发两个单独的副作用，两个 Observable 订阅同样也是触发两个单独的副作用。EventEmitters 共享副作用并且无论是否存在订阅者都会尽早执行，Observable 与之相反，不会共享副作用并且是延迟执行。

订阅 Observable 类似于调用函数。

如果你使用console.log包围一个函数调用，像这样：
```js
console.log('before');
console.log(foo.call());
console.log('after');
```
你会看到这样的输出:
```
"before"
"Hello"
42
"after"
```
使用 Observable 来做同样的事：
```js
console.log('before');
foo.subscribe(function (x) {
  console.log(x);
});
console.log('after');
```
输出是：
```
"before"
"Hello"
42
"after"
```
这证明了 foo 的订阅完全是同步的，就像函数一样。Observable 传递值可以是同步的，也可以是异步的。
那么 Observable 和 函数的区别是什么呢？Observable 可以随着时间的推移“返回”多个值，这是函数所做不到的。你无法这样：
```js
function foo() {
  console.log('Hello');
  return 42;
  return 100; // 死代码，永远不会执行
}
```
函数只能返回一个值。但 Observable 可以这样：
```js
var foo = Rx.Observable.create(function (observer) {
  console.log('Hello');
  observer.next(42);
  observer.next(100); // “返回”另外一个值
  observer.next(200); // 还可以再“返回”值
});

console.log('before');
foo.subscribe(function (x) {
  console.log(x);
});
console.log('after');
```
同步输出：
```
"before"
"Hello"
42
100
200
"after"
```
但你也可以异步地“返回”值：

```js
var foo = Rx.Observable.create(function (observer) {
  console.log('Hello');
  observer.next(42);
  observer.next(100);
  observer.next(200);
  setTimeout(() => {
    observer.next(300); // 异步执行
  }, 1000);
});

console.log('before');
foo.subscribe(function (x) {
  console.log(x);
});
console.log('after');
```
输出：
```
"before"
"Hello"
42
100
200
"after"
300
```
结论:

    func.call() 意思是 "同步地给我一个值"
    observable.subscribe() 意思是 "给我任意数量的值，无论是同步还是异步"


## 创建Observable
```js
const once = f => {
  let called = false

  return (...args) => {
    if (called) {
      return
    }

    called = true
    f(...args)
  }
}

function create (f) {
  // just return a subscribe function
  // error and complete can be invoked just once
  return (next, error, complete) => {
    let finished = false

    const unsubscribe = f({
      next: (val) => {
        if (finished) {
          return
        }

        next(val)
      },
      error: once(err => {
        if (finished) {
          return
        }

        finished = true

        error && error(err)
      }),
      complete: once(() => {
        if (finished) {
          return
        }

        finished = true

        complete && complete()
      })
    })

    // should return a dispose function
    // think case like timeout, interval, websocket connection...
    return () => {
      finished = true

      unsubscribe && unsubscribe()
    }
  }
}

// test
const number$ = create(observer => {
  observer.next(1)
  observer.next(2)

  observer.error(Error('crash'))

  observer.next(3)
})

// subscribe
number$(
  val => console.log('next:', val),
  err => console.log('error:', err),
  () => console.log('completed')
)

// next: 1
// next: 2
// error: Error: crash

const interval = delay => create(observer => {
  let i = 0

  let timer = setInterval(() => observer.next(i++), delay)

  return () => {
    observer.complete()

    clearInterval(timer)
    timer = null
  }
})

const interval$ = interval(200)

const unsubscribe = interval$(
  val => console.log('next:', val),
  err => console.log('error:', err),
  () => console.log('completed')
)

// next: 0
// next: 1
// next: 2
// next: 3
// completed

setTimeout(unsubscribe, 1000)
```

## 操作符
Observable 作为多个值的生产者这样的数据抽象，在使用时，我们还需要操作符。操作符是允许复杂的异步代码以声明式的方式进行轻松组合的基础代码单元。操作符本质上是一个纯函数 (pure function)，它接收一个 Observable 作为输入，并生成一个新的 Observable 作为输出。

<img src="https://cn.rx.js.org/img/map.png">
```js
const map = f => observable => create(observer => {
  observable(
    x => {
      observer.next(f(x))
    },
    observer.error,
    observer.complete
  )
})
```

<img src="https://cn.rx.js.org/img/filter.png">
```js
const filter = f => observable => create(observer => {
  observable(
    x => {
      f(x) && observer.next(x)
    },
    observer.error,
    observer.complete
  )
})
```

<img src="https://cn.rx.js.org/img/merge.png">
```js
const merge = (...observables) => create(observer => {
  const l = observables.length
  let i = 0

  observables.forEach(observable => {
    observable(
      x => observer.next(x),
      observer.error,
      () => {
        i += 1

        i === l && observer.complete()
      }
    )
  })
})
```

<img src="https://cn.rx.js.org/img/combineLatest.png">
```js
const combineLatest = (...observables) => create(observer => {
  const l = observables.length

  let arr = []
  let k = 0
  let n = 0

  observables.forEach((observable, i) => {
    observable(
      x => {
        !(i in arr) && (k += 1)
        arr[i] = x

        k === l && observer.next(arr)
      },
      observer.error,
      () => {
        n += 1

        n === l && observer.complete()
      }
    )
  })
})
```

<img src="https://cn.rx.js.org/img/combineAll.png">
```js
const combineAll = (...observables) => observer => {
  const l = observables.length

  let arr = []
  let n = 0

  observables.forEach((observable, i) => {
    observable(x => {
      !(i in arr) && (n += 1)
      arr[i] = x

      n === l && observer(arr)
    })
  })
}
```

<img src="https://cn.rx.js.org/img/share.png">
```js
const share = observable => {
  let finished = false
  let obs = []

  const start = () => observable(
    x => obs.forEach(ob => ob.next(x)),
    err => obs.forEach(ob => ob.error(err)),
    () => {
      finished = true

      obs.forEach(ob => ob.complete())
      obs = null
    }
  )

  return create(observer => {
    if (finished || obs.indexOf(observer) !== -1) {
      return
    }

    obs.push(observer)

    // lazy subscribe until the first observer occurs
    obs.length === 1 && start()
  })
}
```

<img src="https://cn.rx.js.org/img/take.png">
```js
const take = n => observable => create(observer => {
  if (n <= 0) {
    observer.complete()
    return
  }

  const unsubscribe = observable(
    x => {
      observer.next(x)

      n--
      if (n <= 0) {
        unsubscribe()
        observer.complete()
      }
    },
    observer.error,
    observer.complete
  )
})
```

<img src="https://cn.rx.js.org/img/concat.png">
```js
const concat = (...observables) => create(observer => {
  const l = observables.length

  const f = n => {
    if (n >= l) {
      return observer.complete()
    }

    observables[n](
      x => observer.next(x),
      observer.error,
      () => {
        f(n + 1)
      }
    )
  }

  f(0)
})
```

<img src="https://cn.rx.js.org/img/concatMap.png">
```js
const concatMap = f => observable => create(observer => {
  let observables = []

  let c = false
  let flushing = false

  const g = () => {
    if (flushing || !observables.length) {
      return
    }

    flushing = true

    const observable = observables.shift()

    observable(
      x => {
        observer.next(x)
      },
      observer.error,
      () => {
        flushing = false

        if (c) {
          observables = null
          return observer.complete()
        }

        g()
      }
    )
  }

  observable(
    x => {
      if (c) {
        return
      }

      observables.push(f(x))
      g()
    },
    observer.error,
    () => {
      c = true
    }
  )
})
```

<img src="https://cn.rx.js.org/img/switchMap.png">
```js
const switchMap = f => observable => create(observer => {
  let current
  let unsubscribe

  observable(
    x => {
      if (unsubscribe) {
        unsubscribe()
      }

      current = f(x)

      unsubscribe = current(
        x => observer.next(x),
        (err) => {
          observer.error(err)

          unsubscribe()
          unsubscribe = null
        },
        () => {
          observer.complete()

          unsubscribe()
          unsubscribe = null
        }
      )
    }
  )
})
```

## 总结
我们从数据处理的拉取和推送的方式着手，了解了 Observable 是基于推送模型的多值生产者的抽象，像是没有参数, 但可以泛化为多个值的函数。通过代码实现了一个 Observable 的创建函数，还实现了很多操作符。这只是个开始，在工作和学习中，你要认真思考自己的场景，观察这个场景中是不是存在着类似多个管道产生值，这些管道也存在着组合变换的逻辑，这时候，Observable 就可以大显身手了。从编程范式上来讲，使用 Observable，其实是 反应式编程（Reactive Programming） 的思维，它可以帮助我们摆脱命令式的状态处理，状态和逻辑杂合在一起，用声明式的方式去组合我们的逻辑，希望你能去探索下 Reactive Programming 和 Functional Reactive Programming的世界。

## 参考

  - [The introduction to Reactive Programming you've been missing](https://gist.github.com/staltz/868e7e9bc2a7b8c1f754)
  - [谈谈FRP和Observable（一）](https://zhuanlan.zhihu.com/p/20213244)
  - [RxJS 实战篇（一）拖拽](http://jerryzou.com/posts/rxjs-practice-01/)
  - [http://reactivex.io/rxjs/](http://reactivex.io/rxjs/)
  - [cn.rx.js.org](https://cn.rx.js.org/manual/overview.html)
  - [learn-rxjs](https://github.com/btroncone/learn-rxjs)
  - [awesome-rxjs](https://github.com/ichpuchtli/awesome-rxjs)
  - [xstream](https://github.com/staltz/xstream)
  - [flyd](https://github.com/paldepind/flyd)
  - [callbag-basics](https://github.com/staltz/callbag-basics/)

