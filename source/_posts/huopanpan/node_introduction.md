title: Node学习之路-Node简介
date: 2017-12-28
categories: huopanpan
tags: 
- Node
---

本文主要介绍Node的诞生历程、命名与起源、Node给JavaScript带来的意义、Node的特点、Node的应用场景以及Node的使用者。

<!--more-->
**前提**：已安装Node.js和npm

**开发环境**：推荐Visual Studio Code

### Node的诞生历程
* 2009年3月，Ryan Dahl在其博客上宣布准备基于V8c创建一个轻量级的Web服务器并提供一套库
* 2009年5月，Ryan Dahl在GitHub上发布了最初的版本
* 2009年12月和2010年4月，两届JSConf大会都安排了Node的讲座
* 2010年年底，Node获得硅谷云计算服务商Joyent公司的资助，其创始人Ryan Dahl加入Joyent公司全职负责Node的发展
* 2011年7月，Node在微软的支持下发布了其Windows版本
* 2011年11月，成为GitHub上关注度最高的项目
* 2012年1月底，Ryan Dahl将掌门人身份交给NPM的作者Isaac Z.Schlueter
* 2013年7月，发布Node的稳定版本v0.10.13
* 随后，Node的发布计划主要集中在性能提升上，在v0.14之后，正式发布v1.0版本

### Node的命名与起源
1. 为什么是JavaScript
  * 高性能（Chrome浏览器的JavaScript引擎V8在浏览器中摘得性能第一的桂冠）
  * 符合事件驱动（JavaScript在浏览器中有广泛的事件驱动方面的应用）
  * 没有历史包袱（导入非阻塞I/O库没有额外阻力）
2. 为什么叫Node   
每一个Node进程都构成这个网络应用中的一个节点，这事它名字所含意义的真谛。

### Node给JavaScript带来的意义
1. Node结构与Chrome十分相似，基于事件驱动的异步架构
2. Node中JavaScript可以访问本地文件，搭建服务器，连接数据库
3. Node打破了过去JavaScript只能在浏览器红运行的局面，前后端统一

### Node的特点
1. 异步I/O  
	在Node中，绝大多数的操作都以异步的方式进行调用。这样做的意义在于，在Node中，我们可以从语言层面很自然地进行并行I/O操作。每个调用之间无须等待之前的I/O调用结束。
2. 事件与回调函数   
   在Node中，事件的编程方式具有轻量级、松耦合、只关注事务点等优势。   
   回调函数是最好的接受异步调用返回数据的方式。
3. 单线程   
   child_process：通过将计算分发到各个子进程，可以将大量的计算分解掉，然后通过进程之间的事件消息来传递结果，可以很好地保持应用模型的简单和低依赖。   
   Master-Worker：管理各个工作进程，以达到更高的健壮性。
4. 跨平台   
   兼容Windows和*nix平台。    
   Node在架构层面进行改动，在操作系统与Node上层模块系统之间构建了一层平台层架构，即libuv。

### Node的应用场景
1. I/O密集型   
   I/O密集的优势主要在于Node利用事件循环的处理能力，而不是启动每一个线程为每一个请求服务，资源占用极少。
2. 是否不擅长CPU密集型业务  
   不是很擅长CPU密集型业务，但是可以合理调度。   
   a. Node可以通过编写C/C++扩展的方式更有效地利用CPU，将一些V8不能做到性能极致的地方通过C/C++来实现。   
   b. 如果单线程的Node不能满足需求，甚至用了C/C++扩展后还觉得不够，那么通过子进程的方式，将计算与I/O分离，这样还能充分利用到多CPU。
3. 与遗留系统和平共处
4. 分布式应用

### Node的使用者     
* 前后端编程语言环境统一：雅虎开放了Cocktail框架
* Node带来的高性能I/O用于实时应用：Voxer和腾讯
* 并行I/O使得使用者可以更高效地利用分布式环境：阿里巴巴和eBay
* 并行I/O，有效利用稳定接口提升Web渲染能力：雪球财经和Linkedln
* 云计算平台提供Node支持
* 游戏开发领域：网易的pomelo实时框架
* 工具类应用

> 参考  
>《深入浅出Node.js》  
>[《深入浅出Node.js》相关博客 ](https://www.cnblogs.com/wawahaha/p/4391388.html)    
> [Node.js官方API文档](https://nodejs.org/dist/latest-v8.x/docs/api/)  
> [廖雪峰的官方网站](https://www.liaoxuefeng.com/wiki/001434446689867b27157e896e74d51a89c25cc8b43bdb3000/001434501245426ad4b91f2b880464ba876a8e3043fc8ef000)  















