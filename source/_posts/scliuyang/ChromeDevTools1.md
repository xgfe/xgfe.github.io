title: Chrome Developers Tools基础篇
date: 2016-5-16 16:32:00
categories: scliuyang
tags:
- Chrome Developers Tools
- Debug
- DevTools
---
Chrome开发工具(简称DevTools),是一组内置Google Chrome网页编辑和调试工具。DevTools提供web开发人员进入浏览器和web应用程序代码内部深处。使用DevTools有效追踪布局问题,设置JavaScript断点,获得代码优化的建议。

<!--more-->

# Chrome开发工具基础篇

## 第一部分 Elements

在Elements面板中主要分为两大部分
1. HTML DOM结构面板
2. 查看和操作DOM样式，结构面板
<img src='/uploads/scliuyang/ChromeDevTools/4.png' style='width:500px;'>
在DOM结构面板中，每当你的鼠标移动到任何一个元素上，对应HTML视图中会高亮显示对应的元素，方便开发者查看
<img src='/uploads/scliuyang/ChromeDevTools/5.png' style='width:500px;'>
而且选中的元素会在dev工具下面列出该元素在DOM结构中的关系
<img src='/uploads/scliuyang/ChromeDevTools/6.png' style='width:500px;'>
选中DOM元素后，在属性栏中会列出该元素所有的CSS属性，
1. 可以输入属性名进行筛选，这样可以只看关注的属性名
2. 可以模拟元素的伪状态，方便调试
3. 属性定义的位置，点击可以跳转到源文件
4. 双击可以修改属性值，方便调试

<img src='/uploads/scliuyang/ChromeDevTools/7.png' style='width:500px;'>
Event Listeners面板可以查看当前DOM节点上绑定的事件，上面每个功能点意义如下
1. Ancestors 是否显示祖先上绑定的事件，不选中时click下面的body项会消失
2. Framework listeners (建议勾上)勾上后浏览器会处理主流框架的绑定事件，这样第4部分显示位置更加准确。
3. 该事件监听的元素
4. 事件定义的位置，点击可以跳转到源码
5. 是否是捕获阶段触发
6. 事件响应函数，鼠标放上去可以显示源码

## 第二部分 Console
Console控制台搜集程序运行信息，使用得当可以有如下功效
- 更高「逼格」更快「开发调试」更强「进阶级的Frontender」
- Bug无处遁形「Console大法好」

### console.log
大家都会用log，但鲜有人很好地利用console.error , console.warn 等将输出到控制台的信息进行分类整理。
他们功能区别不大，意义在于将输出到控制台的信息进行归类，或者说让它们更语义化。
各个所代表的语义如下：
- console.log：普通信息
- console.info：提示类信息
- console.error：错误信息
- console.warn：警示信息

当合理使用上述log方法后，可以很方便地在控制台选择查看特定类型的信息。
<img src='/uploads/scliuyang/ChromeDevTools/9.png' style='width:500px;'>
如果再配合console.group 与console.groupEnd，可以将这种分类管理的思想发挥到极致。这适合于在开发一个规模很大模块很多很复杂的Web APP时，将各自的log信息分组到以各自命名空间为名称的组里面。
<img src='/uploads/scliuyang/ChromeDevTools/10.png' style='width:500px;'>
而关于console.log，早已被玩儿坏了。一切都源于Chrome提供了这么一个API：第一个参数可以包含一些格式化的指令比如%c。

比如给hello world 做件漂亮的嫁衣再拉出来见人：
<img src='/uploads/scliuyang/ChromeDevTools/11.png' style='width:500px;'>
除此，console.table 更是直接以表格的形式将数据输出
<img src='/uploads/scliuyang/ChromeDevTools/12.png' style='width:500px;'>

### console.dir
将DOM结点以JavaScript对象的形式输出到控制台
而console.log是直接将该DOM结点以DOM树的结构进行输出，与在元素审查时看到的结构是一致的。不同的展现形式，同样的优雅
<img src='/uploads/scliuyang/ChromeDevTools/13.png' style='width:500px;'>

### console.time & console.timeEnd
当做一些性能测试时，同样可以在这里很方便地进行。
比如需要考量一段代码执行的耗时情况时，可以用console.time与 console.timeEnd来做此事。

这里借用官方文档的例子：

```
console.time("Array initialize");
var array= new Array(1000000);
for (var i = array.length - 1; i >= 0; i--) {
    array[i] = new Object();
};
console.timeEnd("Array initialize");
```
<img src='/uploads/scliuyang/ChromeDevTools/14.png' style='width:500px;'>

### console.profile & console.timeLime

当想要查看CPU使用相关的信息时，可以使用console.profile配合 console.profileEnd来完成这个需求。
这一功能可以通过UI界面来完成，Chrome 开发者工具里面有个tab便是Profile。

与此类似的功能还有console.timeLine配合 console.timeLineEnd,它的作用是开始记录一段时间轴，同样可以通过Chrome开发者工具里的Timeline 标签来进行相应操作。

所以在我看来这两个方法有点鸡肋，因为都可以通过操作界面来完成。但至少他提供了一种命令行方式的交互，还是多了种姿势供选择吧。

### console.trace

堆栈跟踪相关的调试可以使用console.trace。这个同样可以通过UI界面完成。当代码被打断点后，可以在Call Stack面板中查看相关堆栈信息。

上面介绍的都是挂在window.console这个对象下面的方法，统称为[Console API](https://developer.chrome.com/devtools/docs/console-api)，接下来的这些方法确切地说应该叫命令，是Chrome内置提供，在控制台中使用的，他们统称为[Command Line API](https://developer.chrome.com/devtools/docs/commandline-api)。

### $_
代表着最近一次命令返回的结果，并且可以作为一个变量使用在接下来的表达式中：
<img src='/uploads/scliuyang/ChromeDevTools/15.png' style='width:500px;'>

### $0-$4
$0~$4则代表了最近5个你选择过的DOM节点
在页面右击选择审查元素，然后在弹出来的DOM结点树上面随便点选，这些被点过的节点会被记录下来，而$0会返回最近一次点选的DOM结点，以此类推，$1返回的是上上次点选的DOM节点，最多保存了5个，如果不够5个，则返回undefined。
<img src='/uploads/scliuyang/ChromeDevTools/16.gif' style='width:500px;'>

### $
$其实是document.querySelector()的别称，返回第一个选中的DOM节点
### $$
$$调用document.querySelectorAll()函数，返回一个数组形式的DOM节点
### copy
通过此命令可以将在控制台获取到的内容复制到剪贴板。
### inspect
传入一个DOM节点，自动转到Elements面板中对应node的位置，是不是很方便呐
<img src='/uploads/scliuyang/ChromeDevTools/17.png' style='width:500px;'>

## Resources
Resources部分较简单，他主要向我们展示了本界面所加载的资源列表。还有cookie和local storage 、SESSION 等本地存储信息，在这里，我们可以自由地修改、增加、删除本地存储。
<img src='/uploads/scliuyang/ChromeDevTools/18.png' style='width:500px;'>

## Network
Network是一个监控当前网页所有的http请求的面版，它主体部分展示的是每个http请求，每个字段表示着该请求的不同属性和状态
<img src='/uploads/scliuyang/ChromeDevTools/19.png' style='width:500px;'>
- Name：请求文件名称
- Method：方法（常见的是get post）
- Status：请求完成的状态
- Type：请求的类型
- Initiator：请求源也就是说该链接通过什么发送（常见的是Parser、Script）
- Size：下载文件或者请求占的资源大小
- Time：请求或下载的时间
- Timeline：该链接在发送过程中的时间状态轴（我们可以把鼠标移动到这些红红绿绿的时间轴上，对应的会有它的详细信息：开始下载时间，等待加载时间，自身下载耗时）


<img src='/uploads/scliuyang/ChromeDevTools/20.png' style='width:500px;'>
- Stalled: 即请求处于阻塞状态, 如之前有很多请求没处理完，而浏览器对同域并发请求有限制，导致后面的请求处于阻塞状态
- Proxy negotiation: 与代理服务器的连接通信阶段
- DNS Lookup: DNS查找阶段（本请求未涉及，只有在首次访问一个新的域名的时候才会有该阶段）
- Initial Connection / connecting: 建立连接的过程，包含TCP握手/重试，商定SSL
- SSL: 完成SSL握手阶段
- Request sent: 发送请求，通常只要不到1ms的时间
- Waiting(TTFB): 发出请求后等待服务端响应的时间，响应时间极为第一个字节发送过来的时间
- Content Download: 接收响应数据的时间
