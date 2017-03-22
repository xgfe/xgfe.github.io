title: Electron开发跨平台桌面应用
date: 2017-03-16 11:25:57
categories: TinySymphony
tags:
  - electron
  - atom
---


在国内`All in mobile`的风气下谈论桌面客户端开发似乎是个很非主流的行为，但是作为JavaScript在桌面端伸出的利爪，`Electron`不仅仅是快速开发跨平台桌面客户端的一个技术选型，也有着其独特的象征意义~

本文主要介绍`Electron`的应用结构、开发方式以及优缺点。在重温Electron开发的过程中写了个山寨的Mac版网易云音乐，这是[demo地址](https://github.com/Tinysymphony/electronic-netease-music)

<!--  more -->

最早接触`Electron`的时候还是`0.3x`版本，转眼已经`1.6.2`，相比同是跨平台开发的`React Native`，Electron更早地完成“从0到1”的一步。在过去的2016年，Electron是Github上最热门的仓库之一。

言归正传...

### Electron是什么

由Github出品、维护的跨平台桌面应用开发框架。

说白了就是剥离Chromium内核拿来写桌面应用，应用的大部分UI就是web页面，也就是我们前端熟悉的dom. 交互逻辑全部是js，样式还是css写，相当于给用户一个浏览器去渲染应用……看到这里想必读者老爷会骂娘（这不就是web么？要这么折腾还不如直接写个网页）

Electron的本质目的还是利用js构建跨平台的桌面端应用，个人认为它的使用场景主要是一些需要原生功能支持、有离线使用需求、迭代速度较快、对下载安装不太敏感同时桌面端开发人员不足的项目。Electron不仅仅是个“浏览器”，它也封装了一些原生系统的功能，提供给js开发者，比如可以简单地使用js定制不同系统的菜单栏、应用图标、任务栏，控制应用窗口的大小和位置，调用本地的程序等。相比web应用，开发者摆脱了来自浏览器的限制、并可以间接地和原生打交道。

目前基于Electron最著名的桌面端应用是: `Atom编辑器`、`VS Code编辑器`、`Slack`、`Postman桌面版`、`Wordpress桌面版`等等，基本上都是国外公司在使用。

`Electron`源于Gihub开发`Atom`的技术选型，`Atom`开发初期使用的Cococa原生的开发方式；后来使用了`node-webkit`（后面略称NW，也是使用浏览器渲染开发的方式）；之后由于一些技术限制（如多窗口支持和性能原因）决定自行开发一套开发工具，即Electron。Electron最主要的贡献者也是目前的维护者是工作于Github的@zcbenz（国人骄傲~），关于他和NW的爱恨情仇这里略过不谈……


### Electron原理

从分享的keynote里面截了一张图过来（[keynote下载地址](https://pan.baidu.com/s/1qXIMd8w#list/path=%2Felectron-demo)）：

![](http://7xjgb0.com1.z0.glb.clouddn.com/electron-structure.png)

Electron运行时分为两个进程：主进程和渲染进程。主进程是启动app时创建的，主要负责app如何调用原生、如何创建并管理新窗口（页面）以及各种和原生相关的逻辑，可粗略理解为跑了个node；渲染进程负责所有页面的绘制（使用Chromium内核）、及其前端js的解析和运行，粗略理解为“前端”。两个进程通过ipc（跨进程交互）通信，窗口之间可以有附属关系，也可以使用消息机制互相通信。

Electron帮开发者完成和原生的连接，和现在Facebook推出的`React Native`一样，开发者所需要做的无非是阅读文档、通过js调用封装好的接口，无需直接和原生打交道（写原生代码）

### Electron开发的诱惑

谈谈开发时感觉很棒的几点以及注意事项：

#### 渲染进程中的页面js运行环境实际上是结合了node环境和浏览器环境

直接可以使用node相关api和第三方库，例如`require('child_process')`、`require('request')`；

需要注意的是`require('electron')`在不同进程（主进程/渲染进程）中暴露的API是不一样的，具体看文档，例如`BrowserWindow`和`ipcMain`是主进程特有的API

#### 简单地实现很“Native”的功能

用最近做的山寨云音乐举几个例子（目前只针对mac版开发）

-------

##### 栗子1.利用`node-notifier`定制系统提醒

当然也可以直接选择使用HTML5的 `Notification` API，不过相对来说用这个第三方模块可定制性会更高，而且多平台兼容性也不错。

至于如何定制弹框的icon，可以看这个[issue]( https://github.com/mikaelbr/node-notifier/issues/71)里@mbushpilot2b提供的解决方案。

<!-- ![](http://7xjgb0.com1.z0.glb.clouddn.com/notify-window.png) -->
<img src="http://7xjgb0.com1.z0.glb.clouddn.com/notify-window.png" width="500"/>

##### 栗子2.利用`Menu`API定制程序的菜单栏和快捷键

<!-- ![](http://7xjgb0.com1.z0.glb.clouddn.com/top-menu.png) -->

<img src="http://7xjgb0.com1.z0.glb.clouddn.com/top-menu.png" width="500"/>

##### 栗子3.利用`remote`API在渲染进程中定义鼠标右键菜单

web开发中我们写的右键菜单肯定是dom模拟的，但这里我们可以用js简单地写出原生的菜单，并且能有一定的层级。

<img src="http://7xjgb0.com1.z0.glb.clouddn.com/context-menu.png" width="900"/>

##### 栗子4.自定义窗口

这个例子是主窗口缩小成迷你播放器并开启歌词窗口（歌词窗口可以设置成常驻最顶层，不被其他应用窗口覆盖）

<img src="http://7xjgb0.com1.z0.glb.clouddn.com/music.png" width="500"/>

仔细观察上面的截图可以发现，窗口中使用了mac原生的毛玻璃模糊效果。而且和一般mac程序的窗口不同，没有顶部栏。

--------

简而言之，好好读文档，随着Electron社区对项目的迭代，各种原生的功能触手(js)可及。

#### 进程间的交互可以使用`ipc`或者`remote`API

前端的逻辑可以使用进程间通信传递给app主进程，可以做一些类似原生应用才有的交互，如上面的迷你播放器，在dom上自定了关闭按钮，触发点击事件时，通过ipc传递给主进程，主进程控制当前窗口关闭。

渲染进程可以使用`remote`API调用一些主进程才有的API，例如`remote.BrowserWindow`，可不用ipc完成进程间的通信（还是迷你播放器关闭按钮的例子，另一种方式是直接使用remote隐藏掉当前窗口）

注意事项：最好统一管理ipc，避免信号重复；ipc监听过多时复杂的逻辑和时序问题需要考虑。

#### 没有跨域

前端的各种跨域对于初级开发者来说简直是一个噩梦，然而因为有node的存在，摆脱了浏览器的束缚，请求可以用各种姿势完成。

#### 兼容性 & Write once, run every where

因为本身UI是浏览器产出的，各个平台同用的Chromium，不需要考虑兼容性问题，浏览器前缀也只保留`-webkit`即可。用js写的逻辑基本上直接打包编译一波就能在windows/linux/mac三端安装使用。

在开发时真正需要注意的是“跨平台兼容性”，不同的功能可能在不同平台上实现不同，或者未完全实现。这个时候就需要做一些妥协和让步，或者使用一些tricky的方法让大家保持一致。大部分问题活跃的社区都能给出方案~

#### 热更新

这个热更新和前端开发时避免疯狂刷新页面不同，是应用的热更新。桌面应用被web应用不断替代的原因便是更新速度的缓慢及繁琐，web页面的上线便是开销非常小的“客户端更新”，用户几乎没有感知到文件变化（如css/js/html缓存失效重新加载）带来的延迟，保证了较好的体验。

不过这里说的也不是在Electron中使用一个远程url渲染页面的方式（尽管这是可行的），而是整个应用的逻辑更新。Electron自带的auto updater按文档的意思是可以根据Github的release包自动更新应用，具体使用暂时没有经验……不过我的Atom编辑器确确实实无痕地在升级。



### Electron的打包发布

在整个项目打包前，要做的是对主进程和渲染进程代码的打包、压缩、混淆，这里可以使用webpack之类的工程化工具。

而后真正打包成应用时需要结合Electron的内核。目前有两种方式：一种是使用`electron-packager`，直接打包成可运行的程序，基本在100mb+（体积相对正常原生应用偏大，主要是内核的原因）；另一种是使用`electron-builder`制作压缩安装包，可以打成`deb`/`msi`/`dmg`等格式，基本40mb+，不过`electron-builder`的文档真心非常非常烂，折腾了好久才配置出来（连一个完整示范和配置项对象的结构都没注明）

我目前是两者都在使用，一个打包一个压缩。

### End

没打算贴代码教程，文档上对API的功能介绍得比较详细，入门级别的例子google上也能搜到不少。需要注意的是一些文章中借用第三方实现的功能可能已经被Electron支持，推荐还是使用官方的做法。

想看云音乐的开发demo可以到[Github](https://github.com/Tinysymphony/electronic-netease-music)上下载、build、然后安装，不过仍在开发中。
