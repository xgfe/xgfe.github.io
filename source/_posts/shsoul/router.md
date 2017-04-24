title: 如何实现一套iOS-router
date: 2017-04-21 12:10:21
categories: shsoul
tags: 
- iOS
- router
---

### 概述
本文主要是提供一套iOS-router的解决方案。

<!-- more -->


### router是什么？
简单的说，router就是用url跟一些操作绑定，我们可以通过我们设定的url，执行设定的操作，如打开某个页面。看图：

![](https://p0.meituan.net/dpnewvc/e4c8706c48fdac66aff949f38b599a0015251.png)

### 为什么要router？

随着我们的项目越来越大，界面越来越多，逻辑越来越复杂。界面间的路由也变得越来越臃肿，耦合越来越大。我们需要一套框架来解决和简化这些问题。也就是说我们需要router。router主要作用：

1. 解耦界面间的越来越复杂的依赖关系。
2. 统一接口.
3. 实现router拦截器。集中处理需要拦截的需求，如登录拦截。也方便埋点。
4. 方便和其他app的通信，方便处理web跳转到app的逻辑。

举个例子：

```
//使用router前，这里必须在Viewcontroller调用。

UIViewController *main = [[UIViewController alloc] initWithxxx:(id)xxx];
[self.navigationController pushViewController:main animated:YES];

//使用router后，这里可以任何地方调用。

Router.router.build("/main").withAnimated(YES).withObject(@"key", value).navigate();

```


### 如何实现router

1. 明确我们需要做什么。
	* 我们需要一个register来注册我们的类，如ViewController。绑定url和类。
	* 我们需要一个router来处理我们所有的路由逻辑。因此要定义好router的接口。
	* 我们需要拦截器。因此要定义好拦截器接口。
	* 我们需要至少支持push和present两种模式。

2. 实现方案
![](https://p0.meituan.net/dpnewvc/c501389026c246735b894934a7cf436a10727.png)
	* 在register模块上，保存url和类的映射关系。并保存所有的拦截器。
	* 在router模块：
		- 由于有两种模式，因此得有两个方法调用present和push（个人感觉navigate更合适，因为可以往前或往后导航）
		- 由于可以前后导航，因此得自定义的vc类中，得定义两个接口，init和update。
		- 维护路由堆栈，加入新的用init，导航到堆栈中存在的就调update。
	* 在跳转之前，调用所有的拦截器，根据拦截器返回的结果再做真正的跳转操作。
	* 用的是字典传参。
	* 由于用的是字典传参，最好加入依赖注入方案。

### 先假想使用router，再思考封装router。

在上面的方案中，我们已经定义好了我们的router中的一些内容，大概构思了一个方案。我们先想想如果我们已经有了一套router，我们该怎么使用才满足我们的需求还有体验。（我的想法）

1. 首先我们自定义一个vc，实现init和update协议。有依赖注入肯定最好，直接调用注入的方法，不用逐一赋值。
2. 在register模块上注册我们的vc。有拦截器加拦截器。
3. 最后调用router相应的方法传参和跳转到我们定义的vc吧。为了更好的使用体验(参数的不确定)，用builder模式好一点。

```
Router.router.build("/main").withAnimated(YES).withObject(@"key", value).navigate();

Router.router.build("/login").withAnimated(YES).withObject(@"key", value).present();

```

### 总结

 以上是我对router的一些想法，也按照这个想法实现了一套router。再也不用关注路由的关系了，只需关注本身页面的构造。达到解耦的效果。特别在嵌套很深的界面中，路由可直接在操作中进行，再也不用回调到外面的controller进行跳转。总的来说，效果不错。
 
 ![](https://p0.meituan.net/dpnewvc/e4c8706c48fdac66aff949f38b599a0015251.png)

