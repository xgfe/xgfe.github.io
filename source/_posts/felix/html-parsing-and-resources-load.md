title: HTML解析和资源加载
date: 2017-09-07 11:00:00
categories: felix
tags:
- html
---

学习浏览器的内部工作原理将有助于您作出更明智的决策，并理解那些最佳开发实践的个中缘由。

本文主要针对WebKit内核的浏览器。

<!-- more -->

## 渲染引擎工作流

![](http://p1.meituan.net/xgfe/6112586223b0a8894049a9ece14c0201173121.png)


## HTML并行加载和解析
* js是单线程的，浏览器是多线程的，chrome是多进程的
* 浏览器的多线程：
    * GUI渲染线程
    * javascript引擎线程
    * 定时器触发器线程
    * 事件触发线程
    * 异步http请求线程
    * js引擎线程和GUI渲染线程互斥
* 浏览器加载、解析和渲染同时进行

## 浏览器并发请求限制

* webkit 同域并发请求限制为6

## 外部资源的加载规则

1. HTML【highest】：iframe，非阻塞
2. css【highest】
    * css文件异步加载和解析，不影响HTML文档的解析和DOMContentLoaded事件，但是会阻塞**整个**DOM的渲染
    * css文件的加载和解析会阻塞后续js文件的执行
    * 内部import的css文件，立即加入请求队伍并继续阻塞后续js文件的执行
3. javascript
    * js文件的加载和解析会阻塞**后续**DOM的解析和渲染[阻塞主线程]
    * head里面的js文件【high】
    * body末尾的js文件【medium】
    * async和defer的js文件不阻塞主线程【low】
4. 图片【low】:非阻塞
6. 字体文件【highest】:非阻塞
7. 其他资源基本都是非阻塞且低优先级的
8. preload和prefetch(可能被浏览器忽略)不改变优先级

**【预解析】当主线程被阻碍时，WebKit会启动另外一个线程去遍历后面的HTML网页，收集需要的资源URL，然后发送请求，这样就可以避免被阻碍。实现资源的并发下载，包括js文件。**

## [DOMContentLoaded](https://developer.mozilla.org/zh-CN/docs/Web/Events/DOMContentLoaded) 和 [load](https://developer.mozilla.org/en-US/docs/Web/Events/load)事件

* 初始HTML文档被完全加载和解析完成之后，DOMContentLoaded 事件被触发，而无需等待**样式表**、**图像**和**子框架**完成加载；[完成DOMTree]
* 当一个资源及其依赖资源已完成加载时，将触发load事件。

## js文件非阻塞加载

* script[async]
    * js文件异步加载，不阻塞主线程(HTML解析，其他js执行)
    * js文件的执行时间不可预期，不对其它流程产生影响
* script[defer]
    * js文件异步加载，不阻塞主线程(HTML解析，其他js执行)
    * js文件的执行在HTML解析完成之后，所有defer js文件按顺序先后执行
        * FF在DOMContentLoaded事件之前（defer的js文件会延迟DOMContentLoaded事件）
        * WebKit内核中不影响DOMContentLoaded事件
* XHR异步请求然后eval()执行
* 动态插入script标签
    * document.write()：同script标签，但不会阻塞当前脚本后续执行
    * 动态创建script标签，再append到DOM中：同script[async]


## 扩展阅读

* [浏览器的工作原理：新式网络浏览器幕后揭秘](https://www.html5rocks.com/zh/tutorials/internals/howbrowserswork/)