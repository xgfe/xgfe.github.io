title: web worker详解
date: 2017-05-03 11:30:00
categories: LexHuang
tags: 
- javascript
- web api

---
![](http://p0.meituan.net/kuailv/678b764c4d0bff4629f20e748357481c29564.jpg "web worker")
Web Workers 是一种不在页面线程而是在后台线程中执行脚本的技术。Web Workers 的优点在于可以将计算密集型和I/O密集型的操作放在一个单独的后台线程中执行，进而使得主线程（通常是UI线程）能够不被阻塞，也不会被减缓。

本博客主要内容分为七部分：

- Web Worker 概念及使用
- Web worker的生命周期和处理模型
- 错误处理
- 数据传输
- 线程安全
- 内容安全策略

<!-- more -->

## Web Workers 概念

所谓的 worker 就是用一个构造器创建的（例如[Worker()](https://developer.mozilla.org/zh-CN/docs/Web/API/Worker/Worker)） ，用来运行一个 JavaScript 文件的函数 — 这个文件包含了将要在 worker 线程中执行的代码
```javascript
worker = new Worker(scriptURL [, options ])
```

[options](https://html.spec.whatwg.org/multipage/workers.html#dedicated-workers-and-the-worker-interface)可以被用来确保worker的全局环境是否支持Javascript模块{type:'module'}，默认为'class'。在共享worker中还可以通过指定**credentials**来制定**scriptURL**的被获取方式。

worker 脚本将在一个与当前 window 对象不同的全局上下文环境中运行，根据检测到的 worker 的类型有所不同,会生成不同的上下文对象。在``专属worker``(Dedicated Worker)中这个上下文环境由一个叫做 [DedicatedWorkerGlobalScope](https://developer.mozilla.org/zh-CN/docs/Web/API/DedicatedWorkerGlobalScope) 的对象来表示。在``共享worker``（Shared Worker）则会使用[SharedWorkerGlobalScope](https://developer.mozilla.org/en-US/docs/Web/API/SharedWorkerGlobalScope)。所有上下文对象都继承于[WorkerGlobalScope](https://developer.mozilla.org/en-US/docs/Web/API/WorkerGlobalScope)

你可以在你的 worker 线程中运行任意的javascript代码，除某些特殊情况外。比如，你不能直接在 worker 线程中操纵 DOM 元素, 或者使用某些 window 对象中默认的方法和属性。 但是 window 对象中很多的方法和属性你是可以使用的，包括 WebSockets，以及诸如 IndexedDB 和 FireFox OS 中独有的 Data Store API 这一类数据存储机制。具体的可用api和函数列表如下：

* 对比不同类型的workers所拥有的属性和类型:

| function        | Dedicated workers                  | Shared workers            |
|-----------------|------------------------------------|---------------------------|
| atob()          | yes, on WorkerGlobalScope          | yes, on WorkerGlobalScope |
| btoa()          | yes, on WorkerGlobalScope          | yes, on WorkerGlobalScope |
| clearInterval() | yes, on WorkerGlobalScope          | yes, on WorkerGlobalScope |
| clearTimeout()  | yes, on WorkerGlobalScope          | yes, on WorkerGlobalScope |
| dump()          | yes, on WorkerGlobalScope          | yes, on WorkerGlobalScope |
| setInterval()   | yes, on WorkerGlobalScope          | yes, on WorkerGlobalScope |
| setTimeout()    | yes, on WorkerGlobalScope          | yes, on WorkerGlobalScope |
| importScripts() | yes, on WorkerGlobalScope          | yes, on WorkerGlobalScope |
| close()         | yes, on WorkerGlobalScope          | yes, on WorkerGlobalScope |
| postMessage()   | yes, on DedicatedWorkerGlobalScope | no                        |

* worker中可用的web API：
    * Channel Messaging API
    * Console API
    * CustomEvent
    * DOMRequest and DOMCursor
    * FileReader
    * FileReaderSync
    * FormData
    * ImageData
    * IndexedDB
    * Notifications
    * Performance
    * Promise
    * Worker
    * WorkerGlobalScope
    * WorkerLocation
    * WorkerNavigator
    * XMLHttpReques

可见，web worker可以执行所有常见的I/O操作。
***
以上api去除了实验阶段api和非w3c标准api。
***

 在专属worker里，主线程和 worker 线程之间通过消息机制来互相传输信息：两端都使用 postMessage() 方法来发送信息, 并且通过 onmessage 这个事件处理函数来接收信息。 （传递的信息包含在 Message 这个事件的数据属性内) 。数据的交互是通过传递副本，而不是直接共享数据。


 共享worker［Shared workers ］指的是那些可以被多个运行在不同窗口的脚本所共享的worker，比如IFrames等，只要这些窗口和该共享worder同源。该类worker比专属workers更复杂些————脚本们利用处于活动中的端口与主线程们进行通信。

***
 本质上专属worker也是通过端口来与主线程进行通信，但是由于双方端口是一致的，因此将此特性隐藏了。
***

 一个 worker 也可以生成新的 worker，只要这些 worker 和它们父页面的宿主同源。  此外，worker 可以通过 XMLHttpRequest 来进行网络通信，只是 XMLHttpRequest 的 responseXML 和 channel 这两个属性的值将总是 null 。



## 使用web worker

***
随着多核计算机逐渐普及，将复杂计算的任务拆解成多个子任务分配给worker是一个非常有效的办法，这样可以在多处理器内核上运算这些任务。
***

### Worker 特征检测
```javascript
    if (window.Worker) {
    ...
    }
```

### 专属worker
以下以MDN的[Basic dedicated worker example](https://mdn.github.io/simple-web-worker/)为例。它允许你输入两个数字相乘。两个乘数被送到一个专属worker中，运算得到乘积后，在返回到原页面并展示出来。

####  生成一个专属worker
创建一个新的 **专属worker** 很简单。你只需要调用 Worker() 构造器, 并指定一个worker线程需要执行的脚本的URI:
```javascript
/**main.js**/
var myWorker = new Worker("worker.js");
```

####  往dedicated worker里发送消息以及从dedicated worker发出消息
worker的奇妙之处在于 postMessage()方法和onmessage 事件处理程序。当你想要传递一个消息到worker,你需要像这样传递消息:

```javascript
/**main.js**/
first.onchange = function() {
  myWorker.postMessage([first.value,second.value]);
  console.log('Message posted to worker');
}
second.onchange = function() {
  myWorker.postMessage([first.value,second.value]);
  console.log('Message posted to worker');
}
```

这里我们有两个`` <input> ``元素来代表两个乘数; 当它们的值变化时, 会通过myWorker.postMessage([first.value,second.value])传递新值给worker, 数组意味着. 你可以往消息里塞入非常多的信息。
在worker里,我们可以通过编写一个事件回调函数来响应接受到的消息:

```javascript
/**worker.js**/
onmessage = function(e) {
  console.log('Message received from main script');
  var workerResult = 'Result: ' + (e.data[0] * e.data[1]);
  console.log('Posting message back to main script');
  postMessage(workerResult);
}
```

onmessage 处理程序允许我们在接受消息时运行一些代码，并在事件对象的data属性里访问传入的消息。这里我们简单的讲两个数字相乘，并再次使用postMessage()来回传结果回主线程。

回到主线程，我们再次使用onmessage 来响应来自于worker的消息：
```javascript
/**main.js**/
myWorker.onmessage = function(e) {
  result.textContent = e.data;
  console.log('Message received from worker');
}
```
    
这里我们抓取事件data属性里的消息并设置到文档内容上展示出来。

***
* 注意: 传入到Worker 构造器里的参数必须遵循同源策略。
    
    浏览器制造商对于“同源”所包含的概念有争议；Gecko 10.0 (Firefox 10.0 / Thunderbird 10.0 / SeaMonkey 2.7) 以及之后的版本允许 data URIs，而Internet Explorer 10禁止Blob URIs作为用于worker的合法的脚本。
* 注意:  注意到，再主线程里onmessage 和postMessage()必须挂在Worker对象上 ，但是在worker内部不需要。这是因为在worker内部，该worker本身就有效的充当了全局作用域

* 注意: 当主线程和worker之间传递消息时，传递的是消息的副本，而不是共享该消息。

***


#### 关闭一个 worker
* terminate()

    如果想在主线程里立刻关闭正在运行的worker，只要调用worker的terminate 方法就行：
    ```javascript
    /**main.js**/
    myWorker.terminate();
    ```
    该worker线程会被立刻杀死而不会获得任何完成操作或者垃圾回收的机会。
    
* close()

    在 worker 线程内部, workers 可以通过调用自己全局作用域下的close 方法来关闭自身:
    ```javascript
    /**worker.js**/
    self.close();
    ```

尽量使用close在worker内关闭自己，这样可以让线程被安全关闭且更适当地释放资源。具体算法参考下一节。

#### 生成子worker
如果需要，worker可以产生更多的worker。所谓的子worker必须是和父页面同源。而且，该子worker的URIs 的解析是相对于父worker的地址而不是其所属页面的。这简化了worker的依赖追踪。

#### 引入脚本和库
Worker现场可以访问全局函数，importScripts()，让worker引入脚本。它接受0个或者更多要导入的资源的URI作为参数；以下所有例子都是有效的：

```javascript
importScripts();                         /* imports nothing */
importScripts('foo.js');                 /* imports just "foo.js" */
importScripts('foo.js', 'bar.js');       /* imports two scripts */
importScripts('//example.com/hello.js'); /* You can import scripts from other origins */
```

浏览器加载列出的所有脚本并且执行它们。之后所有脚本里的全局对象都能被worker所使用。如果脚本加载失败则会抛出一个``NETWORK_ERROR``错误，并且之后的代码将不会被执行。之前已经执行的代码（包括使用 window.setTimeout()延迟执行的代码）将继续执行。在importScripts() 方法之后的函数声明会被保留，因为它们始终比其他代码先解析。

____
* 注意: 脚本下载是无序的，但是执行顺序则根据传递到importScripts()里的顺序。这是异步完成的；在所有脚本都被下载和执行前，importScripts()不会返回。

____

### 共享worker
一个 **共享worker** 可以被多个脚本所访问 — 即使它们正在被多个不同的窗口访问着, 多个iframe乃至多个worker. 在这一节我们将会讨论 [Basic shared worker example](https://mdn.github.io/simple-shared-worker/)里的代码: 它和基础专属worker的例子很类似,除了它有两个函数可以被不同的脚本文件处理：两数相乘和平方一个数字。两个脚本使用同一个worker 来完成所需的实际计算。

这里我们将重点分析专属和共享worker之间的不同。注意到在这个例子里我们有两个HTML页面，每个页面都有JavaScript 访问同一个worker文件。

____
* 注意: 如果共享worker可以被来自不同的浏览上下文所访问，那这些浏览上下文必须时完全同源的（同协议、域名和端口）。
* 注意: 在火狐里,共享worker不能在一个隐私模式下的窗口和一个非隐私模式下的窗口之间共享 ([bug 1177621](https://bugzilla.mozilla.org/show_bug.cgi?id=1177621))。

____

#### 生成一个 shared worker
与生成一个新dedicated worker类似, 但是不同的是构造器的名称是``SharedWorker`` — 每个都得使用与下面类似的方式启动worker:
```javascript
var myWorker = new SharedWorker("worker.js");
```

一个最大的不同点在于使用共享worker你必须通过一个``port对象``来通信——明确指定一个的端口，这样脚本们可以通过它来与worker通信。(在专属worker偷偷完成了这一点)。
    
端口链接需要通过隐式地使用``onmessage``事件处理程序或者显式地在传递任何消息前使用 start()方法。只有当消息事件通过是addEventListener()接通的情况下需要调用start()。

当使用``start()``方法来开启端口连接时, 如果需要双向通信，则该方法既要在主线程中调用，也需要在woker线程中调用。
```javascript
// called in parent thread
myWorker.port.start();

// called in worker thread, assuming the port variable references a port
port.start();  
```

#### 往shared worker里发送消息以及从shared worker发出消息
现在消息可以像之前一样传递到worker里了,但是postMessage() 方法必须通过port对象来调用 :

```javascript
squareNumber.onchange = function() {
  myWorker.port.postMessage([squareNumber.value,squareNumber.value]);
  console.log('Message posted to worker');
}
```

现在, 将目光转向我们的worker。这里也发生了些复杂的事情:
```javascript
/**worker.js**/
onconnect = function(e) {
    var port = e.ports[0];

    port.onmessage = function(e) {
        var workerResult = 'Result: ' + (e.data[0] * e.data[1]);
        port.postMessage(workerResult);
    }
}
```

首先, 我们使用一个``onconnect事件处理程序``来在发生一个端口连接的时候去激活代码(比如，当父线程里设置了一个``onmessage事件处理程序``，或者在父线程里``start()``方法被显式调用)。

我们使用该事件的``ports属性``来获取端口并且将它存到一个变量里。

之后，我们增加一个消息处理程序在该端口上来做计算并返回给主线程。设置该消息处理程序在worker线程里同样隐式打开了到父线程的端口连接，所以无需调用 ``port.start()``。

最后, 回到main 脚本, 我们处理worker返回的消息:

```javascript
myWorker.port.onmessage = function(e) {
  result2.textContent = e.data;
  console.log('Message received from worker');
}
```


当一个消息通过端口回到主线程时，我们检查结果类型，然后插入到文档里显示出来。


## web worker的生命周期和处理模型

### 生命周期
web worker之间的通信必须依赖于浏览器的上下文环境，并且通过它们的 MessagePort 对象实例传递消息。每个web worker的全局作用域都拥有这些线程的端口列表，这些列表包括了所有线程使用到的 MessagePort 对象。在专用线程的情况下，这个列表还会包含隐式的 MessagePort 对象。

每个web worker的全局作用域对象 WorkerGlobalScope 还会有一个web worker的线程列表，在初始化时这个列表为空。当web worker被创建的时候或者拥有父web worker的时候，它们就会被填充进来。

最后，每个web worker的全局作用域对象 WorkerGlobalScope 还拥有这个线程的文档对象列表，在初始化时这个列表为空。当web worker被创建的时候，文档对象就会被填充进来。无论何时当一个文档对象被丢弃的时候，它就要从这个文档对象列举里面删除出来。
在web worker的生命周期中，定义了下面四种不同类型的线程名称，用以标识它们在线程的整个生命周期中的不同状态：

* 当一个web worker的``文档列表``不为空的时候，这个web worker会被称之为``许可线程``。
* 当一个web worker的``文档列表``中的任何一个对象都是处于完全活动状态的时候，这个web worker会被称之为``需要激活线程``。
* 当一个web worker是许可线程并且拥有计数器或者拥有数据库事务或者拥有网络连接或者它的web worker列表不为空的时候，这个web worker会被称之为``受保护的线程``。
* 当一个web worker是一个非需要激活线程同时又是一个许可线程的时候，这个web worker会被称之为``可挂起线程``。

由于 W3C 的 Web Worker 规范目前还是处于完善阶段，没有形成最终的规范。

### 处理模型
![](http://p1.meituan.net/kuailv/1aae5f5a2fd5220d14bf377ffd82937840137.png "web worker执行模型")

当web worker被一个具有 URL 参数的构造函数创建的时候，它需要有一系列的处理流程来处理和记录它本身的数据和状态。[W3C的web worker的处理模型](https://html.spec.whatwg.org/multipage/workers.html#worker-processing-model)如下：

>当一个用户代理将要通过：Worker 或者 SharedWorker等worker对象、[URL](https://url.spec.whatwg.org/#concept-url) url, [环境设置对象](https://html.spec.whatwg.org/multipage/webappapis.html#environment-settings-object)``外部设置``, [MessagePort](https://html.spec.whatwg.org/multipage/comms.html#messageport) ``外部端口``, 一个[WorkerOptions](https://html.spec.whatwg.org/multipage/workers.html#workeroptions) 字典 ``options参数``, 和一个可选字符串``name`` 来为一个脚本 **运行一个线程** 时，它必须执行以下步骤：（当worker是一个共享worker时，name始终会被提供。）
>
>1. 创建一个独立的并行处理环境，并且在这个环境里面异步的运行下面的步骤。
>   ***
>   对于那些用于计时的API来说，这是官方规定的worker创建时刻。
>   ***
>2. 让``is shared``设置为true如果worker是一个 ``SharedWorker`` 对象, 反之为 false。
>3. 让``docs``为[相关的Document对象组成的列表](https://html.spec.whatwg.org/multipage/workers.html#list-of-relevant-document-objects-to-add)并用来添加给定的外部设置。
>4. 让父 worker 的``parent worker global scope``为 null.
>5. 如果外部设置的[全局对象](https://html.spec.whatwg.org/multipage/webappapis.html#concept-settings-object-global)(即[环境设置对象](https://html.spec.whatwg.org/multipage/webappapis.html#environment-settings-object))是一个 WorkerGlobalScope 对象（比如我们在创建嵌套worker时），设置``parent worker global scope``到外部设置的[全局对象上](https://html.spec.whatwg.org/multipage/webappapis.html#concept-settings-object-global)。
>6. 通过以下自定义项来调用JavaScript [InitializeHostDefinedRealm()](https://tc39.github.io/ecma262/#sec-initializehostdefinedrealm)抽象操作 
>     * 对于全局对象，如果``is shared``是true,创建一个新 SharedWorkerGlobalScope对象。否则，创建一个新DedicatedWorkerGlobalScope对象。并使其成为该worker的全局作用域对象。
>    
>     * 让区域执行上下文（[realm execution context](https://tc39.github.io/ecma262/#realm),概念上类似于一个ECMAScript 全局环境）成为所创建的[JavaScript执行上下文](https://tc39.github.io/ecma262/#sec-execution-contexts)。
>7. 利用上述的区域执行上下文和外部设置来[初始化一个worker环境设置对象](https://html.spec.whatwg.org/multipage/workers.html#set-up-a-worker-environment-settings-object)，并且将返回的设置对象设置为``内部设置``。
>8. 如果``is shared``为true, 则:
>     1. 设置worker全局作用域的[constructor origin属性](https://html.spec.whatwg.org/multipage/workers.html#concept-sharedworkerglobalscope-constructor-origin)值为外部设置的源。
>     2. 设置worker全局作用域的[constructor url属性](https://html.spec.whatwg.org/multipage/workers.html#concept-sharedworkerglobalscope-constructor-url)的值为外部设置的url。
>     3. 设置worker全局作用域的[name属性](https://html.spec.whatwg.org/multipage/workers.html#concept-sharedworkerglobalscope-constructor-url)的值为外部设置的name。
>9. 把[destination](https://fetch.spec.whatwg.org/#concept-request-destination)值设置为"sharedworker"如果``is shared``为true，否则为"worker"。
>10. 通过options参数的type成员的值来获取脚本:
>
>     * "classic"
        利用指定的url来获取经典的worker脚本、外部设置、 destination和内部设置。
>
>     * "module"
     利用指定的url来获取脚本图、外部设置、 destination、options参数的credentials成员值和``内部设置``。
>        
>     两种情况下，对请求[执行fetch操作](https://html.spec.whatwg.org/multipage/webappapis.html#fetching-scripts-perform-fetch)，在[is top-level flag](https://html.spec.whatwg.org/multipage/webappapis.html#fetching-scripts-is-top-level)被设置后将以下步骤：
>          
>     1. 设置请求的 [reserved client](https://fetch.spec.whatwg.org/#concept-request-reserved-client)（即环境） 为``内部设置``。
>     2. [Fetch](https://fetch.spec.whatwg.org/#concept-fetch) 请求,并且为了执行残留的步骤而异步等待，残留的步骤作为fetch的[process response](https://fetch.spec.whatwg.org/#concept-response-url)对应[response](https://fetch.spec.whatwg.org/#concept-response)（fetch的结果）的一部分。
>     3. 设置``worker全局作用域``的 [url](https://html.spec.whatwg.org/multipage/workers.html#concept-workerglobalscope-url) 为响应的 [url](https://fetch.spec.whatwg.org/#concept-response-url)。
>     4. 设置 ``worker 全局作用域``的 [HTTPS 状态](https://html.spec.whatwg.org/multipage/workers.html#concept-workerglobalscope-https-state)为响应的 [HTTPS 状态](https://fetch.spec.whatwg.org/#concept-response-https-state)。
>     5. 设置 ``worker 全局作用域``的 referrer policy 为处理响应报文头部的`Referrer-Policy`字段所的到结果。
>     6. 在``worker的全局作用域``和响应上执行[初始化全局对象的CSP列表](https://w3c.github.io/webappsec-csp/#initialize-global-object-csp)算法。[[CSP(内容安全策略)](https://html.spec.whatwg.org/multipage/references.html#refsCSP)]
>     7. 异步地利用响应来完成[执行fetch操作](https://html.spec.whatwg.org/multipage/webappapis.html#fetching-scripts-perform-fetch)步骤。
>
>     如果异步执行该算法得到的结果为null，则排队一个任务来发射一个error事件，并且放弃这些步骤。否则，在该算法异步执行完后继续执行之后的步骤。
>11. 将worker和worker全局作用域关联起来。
>12. [创建一个新MessagePort对象](https://html.spec.whatwg.org/multipage/comms.html#create-a-new-messageport-object)，其[所有者](https://html.spec.whatwg.org/multipage/comms.html#concept-port-owner)是``内部设置``。让``内部端口``为新建的对象。
>13. 将 ``内部端口`` 和 worker 全局作用域关联起来.
>14. 将``外部端口``和``内部端口``牵连起来。
>15. 将``文档``的[Document](https://html.spec.whatwg.org/multipage/dom.html#document)对象[添加到``worker的全局作用域``下的``文档列表``里](https://html.spec.whatwg.org/multipage/workers.html#add-a-document-to-the-worker's-documents)。
>16. 如果``parent worker global scope``不是null，则添加该worker的``worker的全局作用域``到``parent worker global scope``的[workers列表](https://html.spec.whatwg.org/multipage/workers.html#the-worker's-workers)里。
>17. 设置 ``worker的全局作用域``的 [type](https://html.spec.whatwg.org/multipage/workers.html#concept-workerglobalscope-type) 为``options``的type成员的值。
>18. 创建一个新[WorkerLocation](https://html.spec.whatwg.org/multipage/workers.html#workerlocation)对象并且将它和``worker的全局作用域``关联。
>19. **关闭孤儿worker**: 开始监控线程，在晚于其不再是一个``受保护线程``且早于它不再是一个``许可线程``时，设置``worker的全局作用域``的[closing](https://html.spec.whatwg.org/multipage/workers.html#dom-workerglobalscope-closing) flag为true。
>20. **挂起线程**: 开始监控线程，在worker全局作用域的[closing](https://html.spec.whatwg.org/multipage/workers.html#dom-workerglobalscope-closing) flag为false并且worker是一个[可挂起线程](https://html.spec.whatwg.org/multipage/workers.html#suspendable-worker)时，用户代理挂起该线程的脚本的执行直到[closing](https://html.spec.whatwg.org/multipage/workers.html#dom-workerglobalscope-closing) flag为true或者worker不再是一个[可挂起线程](https://html.spec.whatwg.org/multipage/workers.html#suspendable-worker)。
>21. 设置 ``内部设置``的[execution ready flag](https://html.spec.whatwg.org/multipage/webappapis.html#concept-environment-execution-ready-flag)。
>22. 如果脚本是一个[经典脚本](https://html.spec.whatwg.org/multipage/webappapis.html#classic-script)，则[执行该经典脚本](https://html.spec.whatwg.org/multipage/webappapis.html#run-a-classic-script)操作。否则，该脚本就是一个[模块脚本](https://html.spec.whatwg.org/multipage/webappapis.html#module-script)并[执行模块脚本](https://html.spec.whatwg.org/multipage/webappapis.html#run-a-module-script)操作
>
>     除了返回一个值或者由于异常而失败之外，这也可能由于下面定义的"[杀死一个worker线程](https://html.spec.whatwg.org/multipage/workers.html#kill-a-worker)"或者"[结束一个worker线程](https://html.spec.whatwg.org/multipage/workers.html#terminate-a-worker)"算法而被提前放弃。
>    
>23. 启动``外部端口``的[端口消息队列](https://html.spec.whatwg.org/multipage/comms.html#port-message-queue)。
>
>24. 如果``is shared``为false，则开启worker的隐藏端口的[端口消息队列](https://html.spec.whatwg.org/multipage/comms.html#port-message-queue)。
>25. 如果``is shared``为true, 则排队一个任务, 在``worker的全局作用域``中使用[the DOM manipulation task source](https://html.spec.whatwg.org/multipage/webappapis.html#dom-manipulation-task-source)来发射一个名为[connect](https://html.spec.whatwg.org/multipage/indices.html#event-workerglobalscope-connect)的事件，使用[MessageEvent](https://html.spec.whatwg.org/multipage/comms.html#messageevent)，并将其[data](https://html.spec.whatwg.org/multipage/comms.html#dom-messageevent-data)特性初始化为空字符串,[ports]()特性初始化为一个包含着``内部端口``的新[frozen array](https://heycam.github.io/webidl/#dfn-frozen-array-type)，并且[source](https://html.spec.whatwg.org/multipage/comms.html#dom-messageevent-source)特性初始化为``内部端口``
>26. 启动[ServiceWorkerContainer](https://w3c.github.io/ServiceWorker/#serviceworkercontainer)对象的[客户端消息队列](https://w3c.github.io/ServiceWorker/#dfn-client-message-queue)，[ServiceWorkerContainer](https://w3c.github.io/ServiceWorker/#serviceworkercontainer)对象相关的[service worker client](https://w3c.github.io/ServiceWorker/#serviceworkercontainer-service-worker-client)是worker全局作用域的[相关设置对象](https://html.spec.whatwg.org/multipage/webappapis.html#relevant-settings-object)。
>27. **Event loop**: 执行由内部配置指定的[responsible event loop](https://html.spec.whatwg.org/multipage/webappapis.html#responsible-event-loop)直到其被摧毁。
    ***
    responsible event loop:不会被使用该event loop的环境立刻回收的event loop。
    ***
>   由event loop运行的事件的处理或者[任务](https://html.spec.whatwg.org/multipage/webappapis.html#concept-task)的回调函数的执行可能由于下面定义的"[杀死一个worker线程](https://html.spec.whatwg.org/multipage/workers.html#kill-a-worker)"或者"[结束一个worker线程](https://html.spec.whatwg.org/multipage/workers.html#terminate-a-worker)"算法而被提前抛弃。
    该worker处理模型将会循环这些步骤直到event loop被摧毁，这发生在[closing](https://html.spec.whatwg.org/multipage/workers.html#dom-workerglobalscope-closing) flag被设置为true之后,正如[event loop](https://html.spec.whatwg.org/multipage/webappapis.html#event-loop)处理模型里定义的那样。
>28. 清空该worker全局作用域下的活动中的计时器的列表。
>29. 释放worker的端口列表中的所有端口
>30. 清空worker的文档列表。
>
>当一个用户代理将要 **杀死一个worker线程**，它必须并行于worker的主循环来执行以下步骤:
>
>    1. 设置该 worker的 WorkerGlobalScope 对象的closing flag 为true.
>    2. 如果 WorkerGlobalScope 对象的event loop里的任务队列里还有任务在排队，则直接抛弃它们而不执行。
>    3. 等待一段由用户代理定义的时间。
>    4. 终止worker中正在执行的脚本
>    
>     用户代理可以在任意时刻请求“杀死一个worker”处理模型，比如用户请求，cpu配额管理，或者当一个worker不再是一个``需要激活线程``而该worker在其``closing flag``被设置为``true``后仍然继续执行时。
>
>当用户代理要 **结束一个worker线程**，它必须并行于worker的主循环来执行以下步骤:
>
>    1. 设置该 worker的 WorkerGlobalScope 对象的closing flag 为true.
>    2. 如果 WorkerGlobalScope 对象的event loop里的任务队列里还有任务在排队，则直接抛弃它们而不执行。
>    3. 等待一段由用户代理定义的时间。
>    4. 如果该worker的 WorkerGlobalScope对象是一个DedicatedWorkerGlobalScope对象（比如该worker是一个dedicated worker），则清空该worker的隐藏端口所对应的端口的端口消息队列。

___
注意：由于 whatwg 中web worker的规范依然在更新，您读到这篇文章的时候可能看到已不是最新的处理模型，建议参考 W3C 中的最新规范。

___


## 错误处理
当worker内出现了一个运行时错误，它的onerror 事件处理程序会被调用。该事件处理程序会收到一个名为error的事件，它实现了ErrorEvent 接口。
该事件可以被取消但是不会冒泡；为了阻止默认行为的发生，该worker可以调用错误事件的preventDefault() 方法。
错误事件有以下三个域:
* message
    一个人工可读的错误消息。
* filename
    发生错误的脚本文件的名字。
* lineno
    发生错误的代码在脚本文件中的行数。

### 深入规范
当worker的脚本发生运行时错误时,如果错误没有在处理上一个错误期间发生，则用户代理必需为该脚本所发生的错误, 带上发生错误的代码位置信息（行数和列数）, 使用 WorkerGlobalScope 对象作为目标。

对于共享worker， 如果错误在之后仍未被处理， 则错误可能会被报告给用户。

对于专属worker，如果该错误在之后仍未被处理，则用户代理必需排队一个任务来以发射出一个使用ErrorEvent接口实现的受信任的名为error的事件，并带上其消息、文件名、行数、列数和被恰当初始化过的特性，并且错误特性被初始化为null，且该事件不冒泡并且可以在该worker对应的Worker对象上被取消。如果事件没被取消，则用户代理必需表现得像一个未处理的运行时错误发生在Worker对象的全局作用域下那样，逐级往上地重复整个运行时脚本错误报告处理流程。

如果该worker正在连接着的隐藏端口已经被释放了（比如，如果父worker已经被结束），则该用户代理必需表现的像该the Workerobject没有错误事件处理函数并且该worker的onerror特性是null那样。如果端口未被释放，则执行前述的流程。

***
因此，错误报告会从专属worker链一直冒泡到主文档，即使整条链上的一些worker已经被结束并且被垃圾回收。而错误事件则不会冒泡。
***


## 数据传输
主线程与子线程数据通信方式有多种，通信内容，可以是文本，也可以是对象。主线程与子线程之间也可以交换二进制数据，比如File、Blob、ArrayBuffer等对象，也可以在线程之间发送。比如，主线程向子线程发送一个50MB文件，默认情况下浏览器会生成一个原文件的拷贝。

### 通过 [cloneable objects](http://w3c.github.io/html/infrastructure.html#safe-passing-of-structured-data)传输数据
这种通信是深拷贝关系， 即是传值而不是地址，子线程对通信内容的修改，不会影响到主线程。
在传输过程中使用的克隆算法叫[structured clone algorithm](http://w3c.github.io/html/infrastructure.html#structuredclone),这种算法允许传输大部分类型，包括：
* 正则对象。
*  Blob、 File 和 FileList 对象。
*  ImageData对象。
*  unJSON-safe的对象。

***
早期浏览器内部的运行机制是，先将通信内容串行化，然后把串行化后的字符串发给子线程，后者再将它还原。
***

不能传输的数据有：
* Error和Function对象，尝试克隆会抛出``DATA_CLONE_ERR``错误。
* DOM节点，尝试克隆会抛出``DATA_CLONE_ERR``错误。
* 对象的特定参数不会被保留：
    * RegExp对象的lastIndex 域不会被保留。
    * 属性描述符、数据描述符不会被复制。
    * 原型链不会被遍历和复制。

### 通过 [transferable objects](http://www.w3.org/html/wg/drafts/html/master/infrastructure.html#transferable-objects)传输数据
但是，用拷贝方式发送二进制数据，会造成性能问题。为了解决这个问题，规范定义了``Transferable objects``，通过控制权移交的方式，将对象从主线程直接转移给子线程，转移后主线程无法再使用这些数据，这是为了防止出现多个线程同时修改数据的问题。

```javascript
   // Create a 32MB "file" and fill it.
   var uInt8Array = new Uint8Array(1024*1024*32); // 32MB
   for (var i = 0; i < uInt8Array .length; ++i) {
       uInt8Array[i] = i;
   }
   worker.postMessage(uInt8Array.buffer, [uInt8Array.buffer]);
```



## 关于线程安全
Worker接口生成真正的系统级别的线程，有心的程序员会想到如果不太小心，那么并发会对你的代码产生有趣的影响。

然而，对于 web worker 来说，与其他线程的通信点会被很小心的控制，这意味着你很难引起并发问题。你没有办法去访问非线程安全的组件或者是 DOM，此外你还需要通过序列化对象作为数据来在线程间传递。所以你要是不费点劲儿，还真搞不出错误来。


## 内容安全策略
Worker们被视为有它们自己的执行上下文，不同于创建它们的文档。出于这个原因，一般而言，worker不受创建它们的文档（或者父worker）的内容安全策略所约束。所以，举个例子，假设一个服务端返回的文档有如下的头部：
```
Content-Security-Policy: script-src 'self'
```
这将会阻止它所包含的任何脚本执行eval()。但是，如果脚本构造了一个worker，在worker上下文中运行的代码将会被允许使用eval()。
为了给worker指定内容安全策略，需要为请求的worker脚本的响应报文设置一个  Content-Security-Policy 响应头部。
例外，在worker脚本的源是全局唯一标识（比如，当它的URL有一个 Data URI scheme或者blob）的时候，这周情况下，该worker就会继承创建它的文档或者worker的内容安全策略。


## [浏览器支持](http://caniuse.com/#search=web%20worker)

![](http://p0.meituan.net/kuailv/2eeab3203902eee3bf8565f7fbedaace198201.png "浏览器支持")


## 参考资料
* [HTML living standard — Last Updated 13 April 2017](https://html.spec.whatwg.org/multipage/workers.html)
* [HTML 5.2 Editor’s Draft, 9 April 2017](http://w3c.github.io/html/infrastructure.html#transferable-objects)
* [MDN - Web Workers API](https://developer.mozilla.org/en-US/docs/Web/API/Web_Workers_API)
* [MDN - AbstractWorker](https://developer.mozilla.org/en-US/docs/Web/API/AbstractWorker)
* [MDN - Worker](https://developer.mozilla.org/en-US/docs/Web/API/Worker)
* [MDN - SharedWorker](https://developer.mozilla.org/en-US/docs/Web/API/SharedWorker)
* [MDN - WorkerGlobalScope](https://developer.mozilla.org/en-US/docs/Web/API/WorkerGlobalScope)
* [MDN - DedicatedWorkerGlobalScope](https://developer.mozilla.org/en-US/docs/Web/API/DedicatedWorkerGlobalScope)
* [MDN - SharedWorkerGlobalScope](https://developer.mozilla.org/en-US/docs/Web/API/SharedWorkerGlobalScope)
