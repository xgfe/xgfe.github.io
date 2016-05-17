title: 内存泄露分析
date: 2016-5-16 16:32:00
categories: scliuyang
tags:
- Chrome Developers Tools
- Debug
- DevTools
---
通过Devtools判断页面的内存泄露

<!--more-->

# 判断页面是否引起内存泄露
通过上一节的timeline，并且勾上`Memory`选项，多运行几次如下代码,[github](https://github.com/GoogleChrome/devtools-docs/blob/master/docs/demos/memory/example1.html)

```
var x = [];

function createSomeNodes() {
    var div,
        i = 100,
        frag = document.createDocumentFragment();
    for (;i > 0; i--) {
        div = document.createElement("div");
        div.appendChild(document.createTextNode(i + " - "+ new Date().toTimeString()));
        frag.appendChild(div);
    }
    document.getElementById("nodes").appendChild(frag);
}
function grow() {
    x.push(new Array(1000000).join('x'));
    createSomeNodes();
    setTimeout(grow,1000);
}

```
我们来看看点击了无数次后内存占用情况
<img src='/uploads/scliuyang/ChromeDevTools/40.png'>
然后我们来看一张正常的内存图
<img src='/uploads/scliuyang/ChromeDevTools/41.png'>

通过对比我们可以看到内存泄露有一个很明显的上扬曲线，而且不会随着时间和垃圾回收下降，这就证明有内存泄露的存在。

或者也可以通过`profiles`面板的Record Heap Allocations来观察内存泄露情况
<img src='/uploads/scliuyang/ChromeDevTools/42.gif'>
可以看到很多蓝色的柱子，而蓝色的柱子代表此次垃圾回收没有回收掉的内存部分，蓝色柱子越大越多代表内存泄露越严重

# 定位问题

打开`profiles`面板，在运行程序前先获取一次内存快照,接着运行程序等待一段时间在多获取几次内存快照。
<img src='/uploads/scliuyang/ChromeDevTools/43.gif'>

我们首先解释下内存快照里的意思
<img src='/uploads/scliuyang/ChromeDevTools/44.png'>

1. constructor 构造函数对象的名称
2. distance 对象到回收根的距离
3. Objects Count 对象数量
4. Shallow Size Shallow Size代表了对象直接持有的内存大小。一个标准的JS对象通常会持有用于描述自身逻辑和存储直接值（属性值）的内存。 通常情况下应该只有字符串和数组类型可能拥有一个较大的Shallow Size。
5. Retained Size Retained Size代表了当前对象所引用的其他对象占用的内存大小. 当当前对象被销毁时, 这一部分的内存会被释放.

然后我们点击Summary 选择 Comparison(对比)
<img src='/uploads/scliuyang/ChromeDevTools/45.png'>
可以看到String&HTMLDivElement占有极大的内存,对比我们的代码确实是字符串和div的长期持有导致内存泄露

我们点击String中的一条
<img src='/uploads/scliuyang/ChromeDevTools/46.png'>
可以看到 `x in Window / localhost:63342 @473517` 可以定位到window上的x变量导致的内存泄露

# 总结
内存泄露问题一般表现在使用一段时间后页面卡顿，在复现场景后通过timeline来确定问题的，然后结合内存快照定位到具体的泄露点。