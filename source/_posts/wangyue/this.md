title: this：我们不一样！
date: 2017-11-16
categories: wangyue
tags: 
- this
- 词法作用域
- 关键字
---

本文主要介绍了JS中的词法作用域及this的特殊性和一个小彩蛋。

<!--more-->

我们知道，JS中变量的作用域是「词法作用域」。所谓词法作用域是指作用域在词法解析阶段既确定了，不会改变(这也是闭包成立的基础)。与之对应的是动态作用域，动态作用域是在运行时确定的，其作用域链基于运行时的调用栈。如果想了解更多关于词法作用域的事情，[点击这里](http://www.jianshu.com/p/70b38c7ab69c)。

##### 不一样的`this`
显然，`this`是不符合词法作用域的，`this`的指向并不能在函数声明时确定，而与函数运行时的调用栈密切相关。

##### this指向的一般规律
一句话说完，JS函数中this指向函数的直接调用者。
这里有两个默认的约定
- 原生的dom事件绑定的函数，直接调用者为该dom节点
- 直接执行一个函数，在非严格模式下，直接调用者为window(浏览器下)，严格模式下，直接调用者为`undefined`

##### this指向的例外情况
- [`call`](https://developer.mozilla.org/zh-CN/docs/Web/JavaScript/Reference/Global_Objects/Function/call)/[`apply`](https://developer.mozilla.org/zh-CN/docs/Web/JavaScript/Reference/Global_Objects/Function/apply)
  `fun.call(thisArg, arg1, arg2, ...)`以指定的`this`值来调用函数
  
- [`bind `](https://developer.mozilla.org/zh-CN/docs/Web/JavaScript/Reference/Global_Objects/Function/bind)：
  `fun.bind(thisArg[, arg1[, arg2[, ...]]])`  方法创建一个新的函数, 当被调用时，将其this关键字设置为提供的值，在调用新函数时，在实参之前提供一个给定的参数序列。
  
- 数组迭代方法中的[`thisArg`](https://developer.mozilla.org/zh-CN/docs/Web/JavaScript/Reference/Global_Objects/Array/forEach)
  `array.forEach(callback[, thisArg])` `thisArg`为`callback`中的`this`值。

##### 在声明函数时确定`this`的指向
  我们可以通过`fun = fun.bind(this)`来使函数中的this指向固定。
  React中经常会这么做：![React 中通常会在constructor里绑定this](http://p0.meituan.net/xgfe/ab34cfa7f56368b1a1f5cdc10f8ca0aa457647.png)

#### 总结
- 普通变量：词法作用域 | 例外：`this`
- `this`指向的规律：指向直接调用者(dom/strict mode)  
- `this`指向的例外：`bind`、`apply/call`、数组遍历方法`thisArg`
- 通过例外的例外使例外符合一般规律：`this.fn = this.fn.bind(this)`

#### one more thing
  在验证`this`指向的例外情况时，我试了下`with`会不会影响`this`的指向，结果是不会。不过，倒是发现了一点其他奇怪的情况，放个图大家看吧：![with的奇怪情况](http://p0.meituan.net/xgfe/ff3cb88b203bcfbd8e432d5b67365ade127542.png)
  究其原因，应该是`null`是一个字面量，不可被赋值。`undefined`是一个特殊的预定义的全局变量，可以被赋值，不过正常情况下赋值会静默失败。而`let`根本就不是关键字，是合法的变量名。但是即使`let`被赋值，也不会影响它正常工作（`let`居然不是关键字！！！）。![](http://p1.meituan.net/xgfe/8fedaea7d3fbd2b0770cc5f390824ee679269.png)
  另一个彩蛋：
  ![undefined ?](http://p1.meituan.net/xgfe/bd8b5379a0ce56a2640c860a60eb85be99091.png)