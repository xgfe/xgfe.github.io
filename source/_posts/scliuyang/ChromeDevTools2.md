title: Chrome Developers Tools调试篇
date: 2016-5-16 16:32:00
categories: scliuyang
tags:
- Chrome Developers Tools
- Debug
- DevTools
---
带领大家进入一个不一样的DEBUG世界

<!--more-->

# Chrome开发工具调试篇
上一篇给大家介绍了一下Chrome Dev Tools的基本用法，这篇交大家如何调试javascript程序

## 目录面板

<img src='/uploads/scliuyang/ChromeDevTools/21.png' style="width:500px;">
可以看到上图有3个导航条，他们都存有不同域名和环境下的js和css文件。
Sources:包含当前网页用到的资源目录
Content scripts: 插件程序所在的位置
Snippets: 它的主要作用可以使得我们编写一些项目的测试代码时提供便捷，你知道，如果你在编辑器上编写这些代码，在发布时你必须为它们添加注释符号或者手动删除它们，而在浏览器上编写就不需要这样繁琐了。

还有一个很有用的特性就是：Workspace，这个特性可以把dev tools变成代码编辑工具，首先我们来看看怎么使用这个特性
<img src='/uploads/scliuyang/ChromeDevTools/30.gif' style="width:500px;">
1. 在sources面板右键，选择add folder to workspace,选中项目目录
2. 随便选择一个项目文件，右键选择map to file system resource，选中相应的文件，这样所有的文件都会根据目录依次对应起来。

这样几步后workspace特性就算使用起来了，现在编辑文件都会保存到文件当中非常方便，而且当你在elemnt面板调试css时也会同步将值保存到文件当中。


## 调试面板

### 断点方式
打开需要调试的js文件，并且在对应的行数上右键可以看到以下选择项
<img src='/uploads/scliuyang/ChromeDevTools/22.png' style="width:500px;">
下面来依次说明选项的作用：
1.Blackbox Script : 黑盒文件调试法，将此文件设置为黑盒，这样在调试时将不会进入这个文件
<img src='/uploads/scliuyang/ChromeDevTools/23.gif' style="width:500px;">
<img src='/uploads/scliuyang/ChromeDevTools/24.gif' style="width:500px;">
可以看到，黑盒模式下的文件用户是无法进入的，所以在调试时可以将一些库文件设置为黑盒模式，这样调试将会清爽很多。
2.Add breakpoint ： 在这行添加断电
3.Add conditional breakpoint : 添加条件断点，只有在满足此条件的情况下才会断住程序
<img src='/uploads/scliuyang/ChromeDevTools/25.png' style="width:500px;">

### 断点信息

<img src='/uploads/scliuyang/ChromeDevTools/26.png' style="width:300px;">
最上面一排按钮是控制当前断点，他们分别代表
1、停止断点调试
2、不跳入函数中去，继续执行下一行代码（F10）
3、跳入函数中去（F11）
4、从执行的函数中跳出
5、禁用所有的断点，不做任何调试
6、程序运行时遇到异常时是否中断的开关
7、断点是处以异步操作内部时比如ajax请求，是否记录异步操作之前的堆栈信息

watch面板，可以自定义表达式并查看结果
<img src='/uploads/scliuyang/ChromeDevTools/27.png' style="width:300px;">

call stack面板，记录当前断点的堆栈信息，并且可以通过点击堆栈还原到上一个调用现场.
<img src='/uploads/scliuyang/ChromeDevTools/28.gif' style="width:500px;">
这里也可以配合黑盒模式，去掉jquery库的干扰信息
<img src='/uploads/scliuyang/ChromeDevTools/29.gif' style="width:500px;">

Scope，记录当前断点变量的值
Breakponts,记录所有断点的位置
Dom breakpoints,添加的Dom监控信息。
XHR breakpoints 击+ 并输入 URL 包含的字符串即可监听该 URL 的 Ajax 请求，输入内容就相当于 URL 的过滤器。如果什么都不填，那么就监听所有 XHR 请求。一旦 XHR 调用触发时就会在 request.send() 的地方中断。
Event Listener Breakpoints 为网页添加各种类型的断点信息。如选中了Mouse中的某一项（click），当你在网页上出发这个动作（单击网页任意地方），你浏览器就是立刻断点监控该事件
