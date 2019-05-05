title: 浅谈当Swift中defer和inout同时起作用
date: 2019-02-20
categories: wangqing28
tags:
- iOS
- Swift

---
本文针对 `Swift` 中 `defer`、`inout` 以及 `return` 时相互影响的时候的情况进行简单的分析，目的是更好的理解 `defer`、`inout` 原理以及使用场合，减少踩坑和提高`debug`效率。

> 本文中的示例代码，均为 `Swift 4.2` 版本

<!-- more -->
## inout和defer
### inout
有关 `inout` 关键字苹果官方描述
> If you want a function to modify a parameter’s value, and you want those changes to persist after the function call has ended, define that parameter as an in-out parameter instead.

我们可以了解到，`inout` 关键字，有点类似于 `C` 语言中的引用传递或指针传递，目的是为了对入参进行修改。 但实际上 `inout` 的机制并不是引用传递，或者是指针传递。

以下是两段比较详细的苹果官方描述，摘出来看比较清晰：

> You write an in-out parameter by placing the inout keyword right before a parameter’s type. An in-out parameter has a value that is passed in to the function, is modified by the function, and is passed back out of the function to replace the original value. 

> in-out parameters are passed as follows:
> When the function is called, the value of the argument is copied.
> In the body of the function, the copy is modified.
> When the function returns, the copy’s value is assigned to the original argument.
> This behavior is known as copy-in copy-out or call by value result. 

从这两段我们可以看出，`inout` 的实现原理是：
1. 参数传入，拷贝一份 **临时变量**
2. 函数体中，修改的是这一份 **临时变量**
3. 函数返回时，这份 **临时变量** 被赋予给 **原始参数**

所以，是先拷贝，再修改，再拷贝回去的逻辑。这一点至关重要。

使用示例：
```Swift
func f(x: inout Int) {
    x += 1
}

var a = 10
f(x: &a)
print(a) // 结果为 11
```

> 对于对象，即非 `Swift` 类型的，因为本身即为指针，所以本身就是指针传递，函数内部调用对象方法进行操作进而导致对象内部值的变化时，并不需要 `inout` 关键字。但是如果你想对这个对象变量整体进行的赋值替换操作，并且能反应到外部时，就需要 `inout`。
> 本文为了方便讨论，此处以及后续将仅仅以 `Swift` 原生类型作为例子。

### defer
有关 `defer` 关键字苹果官方的描述

> A defer statement is used for executing code just before transferring program control outside of the scope that the defer statement appears in.

> This means that a defer statement can be used, for example, to perform manual resource management such as closing file descriptors, and to perform actions that need to happen even if an error is thrown.

简单说来， `defer` 是用来定义一段代码，用来在 **离开** 所在 `scope` 的时候执行。 苹果官方对 `defer` 的建议，也是用来关闭描述符、处理一些错误等等。

使用示例
```Swift
func g() {
    defer {
        print("do defer")
    }
    print("do func")
    print("func done")
}
g()
/* 输出结果
do func
func done
do defer
*/
```

这里注意一下， `defer` 的生效时机是 `scope` 离开的时候，而 **不是函数执行完毕** 的时候。 所以如果 `defer` 写在 `if` 或者 `for` 的内部， 会在 `if` 结束的时候立刻执行。

## 问题

因为很多写 `Swift` 的同学都是从 `Objective-C` 过来的，从使用习惯上来说，用 `inout` 会多一些， `defer` 并不太多。 但是当 `inout` 和 `defer` 以及 `return` 共同起作用的时候往往会有一些微妙的问题。

1. `defer` 本身是个 `block`，他内部也是可以修改变量。比如：
`defer { x += 1 }`
2. `return` 的时候，也是可以执行一个 `block` 的。 比如 `return { x + 1 }()`，同时自身也会往栈上压入值
3. `inout` 也是会改变入参的值。（再强调下，是复制->修改->写回，而不是原地修改）



假如一个 `inout` 入参，在 `defer` 中被修改，在 `return` 的 `block` 中被修改。 那么问题来了：
1. 这几处修改的生效顺序是什么
2. 对于 `inout` 和 `return` 而言，外界拿到的是什么时候的什么值

用代码来举例子
```Swift
func fdo(x: inout Int) -> Int {
    defer {
        x += 1
    }
    x += 1
    return {
        x += 1
        return x
    }()
}
var outX: Int = 10;
print("ret: \( fdo(x: &outX) )")
print("after-ret: \( outX )")
```

问题：
1. 几处修改何时生效
2. `fdo` 返回的值是多少
3. 最后的 `outX` 值又是多少

## 分析

为了能知道结果，对上述代码进行扩充
```Swift
func print(tag: String,  v:Int) {
    print("\(tag):\t\(v)")
}

func fdo(x: inout Int) -> Int {
    defer {
        print(tag: "st-def", v: x)
        x += 1
        print(tag: "ed-def", v: x)
    }
    print(tag: "st-fdo", v: x)
    x += 1
    print(tag: "ed-fdo", v: x)
    return {
        print(tag: "st-ret", v: x)
        x += 1
        print(tag: "ed-ret", v: x)
        return x
    }()
}

var outX: Int = 10
print(tag: "x-before", v: outX)
print(tag: "v-return", v: fdo(x: &outX)) // 如果代码改成 outX = fdo(x: &outX)，下一行会如何？ 和现在会一样吗
print(tag: "x-after", v: outX)
```

输出如下：
```
x-before:	10	
st-fdo:	10	
ed-fdo:	11	
st-ret:	11	
ed-ret:	12	
st-def:	12	
ed-def:	13	
v-return:	12	
x-after:	13	
// 如果代码改动 outX = fdo(x: &outX)
// 结果将是  x-after:	12
```

几个关注点
1. 打印顺序
2. 各个节点的值
3. `Swift` 执行的是写时拷贝

> 除了打日志分析之外，也可以检查汇编代码。

简单分析一下可知如下执行顺序：
1. 正常调用
    1. 此时内部生成临时变量 `x'`，后续均操作此 `x'`
2. `return` 中 `block` 执行
3. `defer` 执行 （如果多个，按倒序）
4. `return` 返回
    1. 此时返回出来的是 **临时变量**
    2. 只是返回，**函数调用** 所在的整个语句并未执行
5. `inout` 生效
    1. 用内部生成 `x'` 回填栈顶，即将入参的 `x` 替换成 `x'`，调用方取回
6. **函数调用** 所在的代码行生效，使用 `return` 返回的值对外操作，如外赋值、打印等等

## 总结
从实际的实现角度来说，执行顺序是:
**return中代码** -> `defer` -> `return` -> `inout` -> **调用处代码**

从变量和内存的角度考虑
1. `Swift` 是写时拷贝
2. `inout` 是创建临时变量 -> 返回时用临时变量覆盖传入变量，而不是原地修改

从实际使用来说
1. 对于 `defer` 使用，应遵循苹果的官方建议，主要用于关闭描述符、处理一些错误。虽然可以做一些额外的副作用，甚至可以根据执行的特性，来在 `return` 之后再影响外部的一些东东，但是不建议做这些操作。
2. 对于 `inout` ，需要了解执行的机制，不能根据现象对机制有所误判。
3. 建议尽量少用 **副作用** 来达成一些预期，如在函数中过多的对外部变量进行修改，尤其是值类型的变量。

## 参考
* [关于 Swift defer 的正确使用](https://onevcat.com/2018/11/defer/)
* [Swift Language Guide](https://docs.swift.org/swift-book/LanguageGuide/Functions.html)
* [Swift Language Reference - Statements - defer](https://docs.swift.org/swift-book/ReferenceManual/Statements.html#grammar_defer-statement)
* [Swift Language Reference - Declarations - In-Out Parameters](https://docs.swift.org/swift-book/ReferenceManual/Declarations.html#ID545)