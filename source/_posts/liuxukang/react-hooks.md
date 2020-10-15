title: React Hooks总结与useState模拟实现
date: 2020-10-10
categories:
- Liuxukang
tags:
- react
- hooks
---
本文主要针对react @16.8版本新加的Hook进行介绍总结与简单原理分析。

<!--more-->

## 前言
在进入本文之前，让我们先了解一下Hook，官方文档是这样写的 ***“Hook 是 React 16.8 的新增特性。它可以让你在不编写 class 的情况下使用 state 以及其他的 React 特性。”***

请记住Hook是：
  >1.完全可选的： 你无需重写任何已有代码就可以在一些组件中尝试 Hook。但是如果你不想，你不必现在就去学习或使用 Hook。
  >2.100%向后兼容的
  >3.现在可用 v16.8.0

官方没有计划从React中移除class

## Hook的概念

Hook是一些可以让你在函数组件里 "钩入" react state 及生命周期特性的函数，其中内置了许多Hook使用
Hook 是一个特殊的函数，它可以让你“钩入” React 的特性。例如，useState 是允许你在 React 函数组件中添加 state 的 Hook。

什么时候我会用 Hook？
 如果你在编写函数组件并意识到需要向其添加一些 state，以前的做法是必须将其它转化为 class。现在你可以在现有的函数组件中使用 Hook。

## 使用Hook的目的和作用

1. 使用 Hook 从组件中提取状态逻辑，使得这些逻辑可以单独测试并复用
2. 每个生命周期常常包含一些不相关的逻辑，但又把相关逻辑分离到了几个不同方法中；Hook可以将组件中相互关联的部分拆成更小的函数
3. class需要去理解，Hook 使你在非 class 的情况下可以使用更多的 React 特性

## React内置的Hook

**useState ：**
通过在函数组件中调用它，来给组件添加一些内部state，可以在一个组件中多次使用
  * 入参： 一个初始的state值
  * 返回值 ：一对值， 当前状态 和一个让你更新它的函数
  * 使用例子： const [ count,setCount] = useState(0)
  * 和在class中使用state的区别： 1.更新state时候，总是替换，不是合并

**useEffet：**
可以让你的函数组件，执行副作用操作，此hook告诉react组件，在完成渲染或更新后运行里面的代码。可以多次使用
  * 副作用 ：数据获取，设置订阅以及手动更改 React 组件中的 DOM 都属于副作用
  * 入参：第一个参数为需要执行的函数 ，第二个参数为一个数组，代表一些state，当这些state本次更新都没有变化时，将跳过对effet的调用；如果只想执行一次 effet 则传第二参数为 []
  * 返回值：一个函数，用来表示在组件销毁时，应该触发的函数
  * 它会在调用一个新的 effect 之前对前一个 effect 进行清理,并触发return的函数
  * 优化：https://zh-hans.reactjs.org/docs/hooks-faq.html#what-can-i-do-if-my-effect-dependencies-change-too-often

**useCallback：**
https://zh-hans.reactjs.org/docs/hooks-reference.html#usecallback

**useMemo：**
https://zh-hans.reactjs.org/docs/hooks-reference.html#usememo

## Hook的使用规则
1. 只能在函数最外层调用hook；不要在循环、条件判断、或者子函数中使用
描述：遵守这条规则，你就能确保 Hook 在每一次渲染中都按照同样的顺序被调用。这让 React 能够在多次的 useState 和 useEffect 调用之间保持 hook 状态的正确
2. 只能在react组件函数中 使用；不要在js的其他函数中使用

## 底层实现原理
  1. React 是如何把对 Hook 的调用和组件联系起来的？
每个组件内部都有一个「记忆单元格」列表。它们只不过是我们用来存储一些数据的 JavaScript 对象。当你用 useState() 调用一个 Hook 的时候，它会读取当前的单元格（或在首次渲染时将其初始化），然后把指针移动到下一个。这就是多个 useState() 调用会得到各自独立的本地 state 的原因。

  2. useState实现原理
     分析功能
     入参：一个state的初始值
     返回值：一个包含 (变量，函数 )的元数组 [ state, setState]
     处理的功能：setState的函数，会触发重新渲染UI的render
     基本实现：
     ```
       function render() {
         ReactDOM.render(<App />, document.getElementById("root"));
       }
  
       let state: any; // state应该是一个全局变量
  
       function useState<T>(initialState: T): [T, (newState: T) => void] {
          state = state || initialState;
  
          function setState(newState: T) {
             state = newState;
             render(); // 每次setState需要更新视图
          }
  
          return [state, setState];
        }
  
        render(); // 首次渲染
     ```
上面是最基本的useState函数实现，但是使用原则里，有一条是---不要在循环、条件判断、或者子函数中使用，这是因为useState可以在一个函数组件中重复使用，并且使用原则是需要保证每次useState顺序一致；
实现原理是:
      1. 采用数组去保存 state的状态,并且有一个 cursor下标，用来让每个 useState 拿到 对应的 值 和 更新函数
      2. 更新state，再次render的时候，cursor需要被置为 0，按照useState声明的顺序，依次拿出最新的state，视图完成更新
   所以上面基本版本修改为 ：
    ```
    const states: any[] = []; // 使用数组来保存state
    let cursor: number = 0; // 下标指针，用来处理多个useState时，表明每个顺序

    function useState<T>(initialState: T): [T, (newState: T) => void] {
        const currenCursor = cursor;
        states[currenCursor] = states[currenCursor] || initialState; // 检查是否渲染过

        function setState(newState: T) {
            states[currenCursor] = newState;
            render();
        }

        cursor++; // update: cursor  每次使用useState需要将 cursor加1
        return [states[currenCursor], setState];
    }

    function render() {
        ReactDOM.render(<App />, document.getElementById("root"));
        cursor = 0; // 重置cursor
    }
    render(); // 首次渲染
    ```
## 节流在Hook中的一个坑
在hooks中 使用throttle时，会像如下使用：
```
  const handleBoxClick = throttle(() => {
    console.log(11111)
    if (hasRFID) {
      onClick(type)
    }
  }, 2000)

  return (
    <div className="box-block">
      <div
        className={cx('box', {
          [`box-${type}`]: true,
          [`box-${type}-disable`]: !isDoing,
          [`box-error`]: workingAndHasError
        })}
        onClick={handleBoxClick}
      ></div>
   </div>
```
tip：但是throttle的原理，会使用到闭包，保存一个time的时间戳，hooks组件在每次状态发生变化的时候，都会重新定义函数，这样这个pre就又是最新的值了，所以每次都会进入if的逻辑，执行函数。
解决办法：使用useCallback 让函数只定义一次
```
// 简易版
// 节流  在n秒内，只能有一次触发事件的回调函数执行,
      function throttle(fn, time) {
        let pre = 0;
        return function (...args) {
          let now = Date.now();
          if (now - pre >= time || !pre) {
            fn.call(this, ...args);
            pre = now;
          }
        };
      }
```



## 参考链接
Hook简介 https://zh-hans.reactjs.org/docs/hooks-intro.html



