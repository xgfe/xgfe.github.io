title: JavaScript 异步
date: 2019.7.29
categories: hardhpp
tags:

- JavaScript
- 异步
---



介绍JavaScript异步的四种实现方式：1>回调函数；2>Promise；3>生成器Gererator；4>Async/Await。

<!-- more -->

**异步编程的核心：处理程序中现在运行的部分和将来运行的部分之间的关系。**

## 方法一：回调函数

回调是JavaScript中最基础的异步模式，常见于一个耗时操作后执行某个函数。

### 例1: 一个定时器，定时器中的匿名函数就是回调函数，在1000ms后执行该函数

```
setTimeout( function() {
  console.log('Time out');
}, 1000);
```

### 例2: 异步读取文件后执行回调函数

```
var fs = require('fs'); 
fs.readFile('./text1.txt', 'utf8', function(err, data){
  if (err){
    throw err;
  }
  console.log(data);
});
```

### 应用

下面，我们使用回调函数实现一个简单的需求：某应用希望根据登录人的信息，获取不同的筛选项，再根据筛选项获取到相应的数据。

整个过程分为3步：

1. 调用获取登录人岗位接口，获取登录人信息
2. 根据登录人的信息，获取相应的筛选项
3. 根据筛选项信息，获取该登录人默认查看的信息

```
let position, filter, source;

$.ajax({
    type: 'get',
    url: 'http://xx/getPosition',
    success: function (data) {
        position = data;
        $.ajax({
            type: 'get',
            url: 'http://xx/getFilter',
            data: {
                position
            },
            success: function (data) {
                filter = data;
                $.ajax({
                    type: 'get',
                    url: 'http://xx/getSource',
                    data: {
                        filter
                    },
                    success: function (data) {
                        console.log('查看数据：', data);
                    },
                    error: function (err) {
                        console.log(err);
                    }
                });
            },
            error: function (err) {
                console.log(err);
            }
        });
    },
    error: function (err) {
        console.log(err);
    }
});
```

以上代码存在两个问题：

1. 回调嵌套层数过多，调试困难，如果需求增加或者改变，代码难以维护和更新，即回调地狱

2. 控制反转，即把sucess 和 error函数的执行控制交付给了第三方的ajax(..)，无法控制第三方工具的执行且第三方工具可能会出错

**控制反转(inversion of control)**：把自己程序一部分的执行控制交给某个第三方。在你的代码和第三方工具(一组你希望有人维护的东西)之间有一份并没有明确表达的契约。

以下列出了三方工具可能出错的情况:

- 调用回调过早(在追踪之前);
- 调用回调过晚(或没有调用);
- 调用回调的次数太少或太多(就像你遇到过的问题!);
- 没有把所需的环境 / 参数成功传给你的回调函数;
- 吞掉可能出现的错误或异常;
- ......

**总结：回调函数存在的主要缺陷:缺乏顺序性和可信任性。**



## 方法二：Promise

1.Promise解决回调函数中的信任问题，不是将自己的程序交给第三方，而是希望第三方给我们提供了解其任务何时结束的能力，然后由我们自己的代码来决定下一步做什么。

2.链式的写法，能够使得代码表达的有顺序性。

### promise解决信任问题

**1>调用过早**

根据定义，Promise 就不必担心这种问题，因为即使是立即完成的 Promise(类似于 new Promise(function(resolve){ resolve(42); }))也无法被同步观察到。

也就是说，对一个 Promise 调用 then(..) 的时候，即使这个 Promise 已经决议，提供给then(..) 的回调也总会被异步调用。



**2>调用过晚**

和前面一点类似，Promise 创建对象调用 resolve(..) 或 reject(..) 时，这个 Promise 的then(..) 注册的观察回调就会被自动调度。可以确信，这些被调度的回调在下一个异步事件点上一定会被触发。



**3>回调未调用**

首先，没有任何东西(甚至 JavaScript 错误)能阻止 Promise 向你通知它的决议(如果它决议了的话)。如果你对一个 Promise 注册了一个完成回调和一个拒绝回调，那么 Promise在决议时总是会调用其中的一个。



**4>调用次数过少或过多**
根据定义，回调被调用的正确次数应该是 1。“过少”的情况就是调用 0 次，和前面解释过的“未被”调用是同一种情况。

“过多”的情况很容易解释。Promise 的定义方式使得它只能被决议一次。如果出于某种原因，Promise 创建代码试图调用 resolve(..) 或 reject(..) 多次，或者试图两者都调用，那么这个 Promise 将只会接受第一次决议，并默默地忽略任何后续调用。

由于 Promise 只能被决议一次，所以任何通过 then(..) 注册的(每个)回调就只会被调用一次。

当然，如果你把同一个回调注册了不止一次(比如p.then(f); p.then(f);)，那它被调用的次数就会和注册次数相同。响应函数只会被调用一次，但这个保证并不能预防你搬起石头砸自己的脚。



**5>未能传递参数 / 环境值**

Promise 至多只能有一个决议值(完成或拒绝)。如果你没有用任何值显式决议，那么这个值就是 undefined，这是 JavaScript 常见的处理方式。但不管这个值是什么，无论当前或未来，它都会被传给所有注册的(且适当的完成或拒绝)回调。

还有一点需要清楚:如果使用多个参数调用 resovle(..) 或者 reject(..)，第一个参数之后的所有参数都会被默默忽略。这看起来似乎违背了我们前面介绍的保证，但实际上并没有，因为这是对 Promise 机制的无效使用。对于这组 API 的其他无效使用(比如多次重复调用 resolve(..))，也是类似的保护处理，所以这里的 Promise 行为是一致的(如果不是有点令人沮丧的话)。

如果要传递多个值，你就必须要把它们封装在单个值中传递，比如通过一个数组或对象。对环境来说，JavaScript 中的函数总是保持其定义所在的作用域的闭包(参见《你不知道的 JavaScript(上卷)》的“作用域和闭包”部分)，所以它们当然可以继续访问你提供的环境状态。当然，对于只用回调的设计也是这样，因此这并不是 Promise 特有的优点——但不管怎样，这仍是我们可以依靠的一个保证。



**6> 吞掉错误或者异常**

如果在Promise的创建过程或在查看其决议结果过程中的任何时间点上出现了一个JavaScript异常错误，比如一个TypeError或RerenceError，那这个异常就会被捕获，并且会使这个Promise被拒绝。

### 链式流

Promise 固有行为特性:

- 每次你对 Promise 调用 then(..)，它都会创建并返回一个新的 Promise，我们可以将其链接起来;

- 不管从 then(..) 调用的完成回调(第一个参数)返回的值是什么，它都会被自动设置为被链接 Promise(第一点中的)的完成;

  ```
  var p = Promise.resolve( 21 );
  var p2 = p.then( function(v){
    console.log( v );
    // 用值42填充p2
    return v * 2;
  });
  // 连接p2
  p2.then( function(v){
      console.log( v ); // 42
  });
  ```



  ### 应用

  改写上面应用中回调函数实现的写法。

  ```
  let getPositionPromise = function () {
      return new Promsie(function (resolve, reject) {
          $.ajax({
              type: 'get',
              url: 'http://xx/getPosition',
              success: function (data) {
                 resolve(data);         
              },
              error: function (err) {
                  reject(err);
              }
          });
      });
  };
  
  let getFilterPromise = function (params) {
      return new Promsie(function (resolve, reject) {
          $.ajax({
              type: 'get',
              url: 'http://xx/getFilter',
              data: params,
              success: function (data) {
                  resolve(data);         
              },
              error: function (err) {
                  reject(err);
              }
          });
      });
  };
  
  let getListPromise = function (params) {
      return new Promsie(function (resolve, reject) {
          $.ajax({
              type: 'get',
              url: 'http://xx/getSource',
              data: params,
              success: function (data) {
                  resolve(data);         
              },
              error: function (err) {
                  reject(err);
              }
          });
      });
  };
  
  getPositionPromise()
      .then(function (data) {
          return getTokenPromise({position: data});
      })
      .then(function (data) {
          return getDataPromise({filter: data});
      })
      .then(function (data) {
          console.log('数据：', data);
      })
      .catch(function (err) {
          console.log(err);
      }); 
  ```



## 方法三：生成器Gererator

**ES6中的生成器（Gererator）是**一种顺序、看似同步的异步流程控制表达风格。

### 可迭代协议和迭代器协议

**可迭代协议**运行JavaScript对象去定义或定制它们的迭代行为，例如（定义）在一个for...of结构中什么值可以被循环（得到）。以下内置类型都是内置的可迭代对象并且有默认的迭代行为：

1. Array
2. Map
3. Set
4. String
5. TypedArray
6. 函数的Arguments对象
7. NodeList对象

**注意，Object不符合可迭代协议**。

为了变成可迭代对象，一个对象必须实现@@iterator方法，意思是这个对象（或者它原型链prototype chain上的某个对象）必须有一个名字是Symbol.iterator的属性：

| 属性              | 值                                               |
| ----------------- | ------------------------------------------------ |
| [Symbol.iterator] | 返回一个对象的无参函数，被返回对象符合迭代器协议 |

当一个对象需要被迭代的时候（比如开始用于一个for...of循环中），它的@@iterator方法被调用并且无参数，然后返回一个用于在迭代中获得值的迭代器。

**迭代器协议**定义了一种标准的方式来产生一个有限或无限序列的值。
当一个对象被认为是一个迭代器时，它实现了一个next()的方法并且拥有以下含义：

| 属性 | 值                                                           |
| ---- | ------------------------------------------------------------ |
| next | 返回一个对象的无参函数，被返回对象拥有两个属性：<br /> **1. done（boolean）** - 如果迭代器已经经过了被迭代序列时为true。这时value可能描述了该迭代器的返回值  - 如果迭代器可以产生序列中的下一个值，则为false。这等效于连同done属性也不指定。<br />**2. value** - 迭代器返回的任何JavaScript值。done为true时可以忽略。 |

使用可迭代协议和迭代器协议的例子：

代码块

```
var str = 'hello'; 

// 可迭代协议使用for...of访问
typeof str[Symbol.iterator]; // 'function' 
for (var s of str) {
  console.log(s); // 分别打印 'h'、'e'、'l'、'l'、'o'
}

// 迭代器协议next方法
var iterator = str[Symbol.iterator]();
iterator.next(); // {value: "h", done: false}
iterator.next(); // {value: "e", done: false}
iterator.next(); // {value: "l", done: false}
iterator.next(); // {value: "l", done: false}
iterator.next(); // {value: "o", done: false}
iterator.next(); // {value: undefined, done: true}
```

**用Generator实现异步**

### 应用

如果我们用Generator改写上面回调嵌套的例子会是什么样的呢？见代码：

```
function getPosition () {
    $.ajax({
        type: 'get',
        url: 'http://xx/getPosition',
        success: function (data) {
            it.next(data);
        }
        error: function (err) {
            console.log(err);
        }
    });
}

function getFilter (params) {
    $.ajax({
        type: 'get',
        url: 'http://xx/getFilter',
        data: params,
        success: function (data) {
            it.next(data);
        }
        error: function (err) {
            console.log(err);
        }
    });
}

function getList (params) {
    $.ajax({
        type: 'get',
        url: 'http://xx/getList',
        data: params,
        success: function (data) {
            it.next(data);
        }
        error: function (err) {
            console.log(err);
        }
    });
}

function *main () {
    let position = yield getPosition();
    let filter = yield getFilter({position: position });
    let List = yield getList({filter: filter});
    console.log('列表数据：', List);
}

// 生成迭代器实例
var it = main();

// 运行第一步
it.next();
console.log('不影响主线程执行');
```



我们注意*main()生成器内部的代码，不看yield关键字的话，是完全符合大脑思维习惯的同步书写形式，把异步的流程封装到外面，在成功的回调函数里面调用it.next()，将传回的数据放到任务队列里进行排队，当JavaScript主线程空闲的时候会从任务队列里依次取出回调任务执行。

如果我们一直占用JavaScript主线程的话，是没有时间去执行任务队列中的任务：

```
// 运行第一步
it.next();

// 持续占用JavaScript主线程
while(1) {};// 这里是拿不到异步数据的，因为没有机会去任务队列里取任务执行
```
综上，生成器Generator解决了回调函数处理异步流程的**第一个问题：不符合大脑顺序、线性的思维方式。**。

## 方法四：Async/Await

Promise和Generator这两者结合起来，就是Async/Await。

Generator的缺点是还需要我们手动控制next()执行，使用Async/Await的时候，只要await后面跟着一个Promise，它会自动等到Promise决议以后的返回值，resolve(...)或者reject(...)都可以。

我们把最开始的例子用Async/Await的方式改写：

```
let getPositionPromise = function () {
    return new Promsie(function (resolve, reject) {
        $.ajax({
            type: 'get',
            url: 'http://xx/getPosition',
            success: function (data) {
               resolve(data);         
            },
            error: function (err) {
                reject(err);
            }
        });
    });
};

let getFilterPromise = function (params) {
    return new Promsie(function (resolve, reject) {
        $.ajax({
            type: 'get',
            url: 'http://xx/getFilter',
            data: params,
            success: function (data) {
                resolve(data);         
            },
            error: function (err) {
                reject(err);
            }
        });
    });
};

let getListPromise = function (params) {
    return new Promsie(function (resolve, reject) {
        $.ajax({
            type: 'get',
            url: 'http://xx/getList',
            data: params,
            success: function (data) {
                resolve(data);         
            },
            error: function (err) {
                reject(err);
            }
        });
    });
};

async function main () {
    let position = await getPosition();
    let filter = await getFilter({position: position });
    let List = await getList({filter: filter});
    console.log('列表数据：', List);
}

main();

console.log('不影响主线程执行');
```



可以看到，使用Async/Await，完全就是同步的书写方式，逻辑和数据依赖都非常清楚，只需要把异步的东西用Promise封装出去，然后使用await调用就可以了，也不需要像Generator一样需要手动控制next()执行。

**Async/Await是Generator和Promise的组合，完全解决了基于回调的异步流程存在的两个问题，可能是现在最好的JavaScript处理异步的方式了。**

## 总结

本文通过四个阶段来讲述JavaScript异步编程的发展历程：

1. **第一个阶段 - 回调函数**，但会导致两个问题:
   - 缺乏顺序性： 回调地狱导致的调试困难，和大脑的思维方式不符
   - 缺乏可信任性： 控制反转导致的一系列信任问题
2. **第二个阶段 - Promise**，Promise是基于PromiseA+规范的实现，它很好的解决了控制反转导致的信任问题，将代码执行的主动权重新拿了回来。
3. **第三个阶段 - 生成器函数Generator**，使用Generator，可以让我们用同步的方式来书写代码，解决了顺序性的问题，但是需要手动去控制next(...)，将回调成功返回的数据送回JavaScript主流程中。
4. **第四个阶段 - Async/Await**，Async/Await结合了Promise和Generator，在await后面跟一个Promise，它会自动等待Promise的决议值，解决了Generator需要手动控制next(...)执行的问题，真正实现了**用同步的方式书写异步代码**。




> 相关参考  
> [JavaScript异步编程](https://segmentfault.com/a/1190000015711829)


















