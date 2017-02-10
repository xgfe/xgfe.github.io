title: Coordinators探险——Fragment和ViewGroup的抉择
date: 2017.02.08 16:54:39
updated: 2017.02.08 16:54:39
categories:
- zhiqin
tags:
- Android
- Coordinators
- Fragment
- MVWhatever
---


Coordinators简介
----------------

2个月前，square开源了[Coordinators](https://github.com/square/coordinators)。这个项目的作用在主页的第一句话写得很清楚：

> Simple lifecycle for your MVWhatever on Android. No kidding.

> 讲真，简化Android开发中MV**模式里的生命周期。

<!--more-->

项目的使用也十分简单,首先让你的界面控制层继承`Coordinator`。

*控制层：MVVM里就是ViewModel，MVP里就是Presenter*

```
class Whaterver extends Coordinator {

  @Override public void attach(View view) {
    // Attach listeners, load state, whatever.
  }

  @Override public void detach(View view) {
    // Unbind listeners, save state, go nuts.
  }
}

```

然后把你的控制层和界面进行绑定：

```
// Create a factory for your Coordinators.
CoordinatorProvider coordinatorProvider; // @Nullable (View) -> Coordinator

// Bind a Coordinator to a View.
Coordinators.bind(view, coordinatorProvider);

// Bind a Coordinator to any child View added to a group.
Coordinators.installBinder(viewGroup, coordinatorProvider);

```

绑定方法可以看见，绑定的对象不是比较高级页面对象`Activity`或`Fragment`，而是更底层的`View`或者`ViewGroup`。

Android的界面显示组件
-------------------

首先简单介绍一下Android的各个界面显示组件：

1.`Activity`
Android里最基本的页面组件，基本上每一个全屏页面都是一个`Activity`。`Activity`并不显示具体的内容，而只是一个简单的容器，容器内部包含了各种`View`和`ViewGroup`。

2.`View`和`ViewGroup`

- `View`就是显示的基本控件，包括按钮，文本框，图片框等等。

- `ViewGroup`的性质类似html中的div,其内部包含了各种`View`和`ViewGroup`。然后整体被放进了`Activity`中:

```
+------------------+
|    Activity      |
|                  |
|    +-------+     |
|    | View  |     |
|    | Group |     |
|    +-------+     |
|                  |
+------------------+
```

最初Android的展示界面就是这两种。随着应用界面的复杂度不断升高，加上单页应用的体验比多页更加优秀，Activity内代码也随之不断增多。

3.`Fragmnet`
为此，谷歌推出了Fragment，这个组件可以像Activity一样包含ViewGroup，同时又能像ViewGroup一样被添加到Activity中。这样开发者只需要把原来继承Activity的内容修改为继承Fragment，然后通过配套的Api把多个Fragment添加到一个Activity中。就能快速的将一个多页应用改造成一个单页应用。


```
+--------------------+
|     Activity       |
|                    |
|    +----------+    |
|    | Fragment |    |
|    +----------+    |
|                    |
+--------------------+

+------------------+
|    Fragment      |
|                  |
|    +-------+     |
|    | View  |     |
|    | Group |     |
|    +-------+     |
|                  |
+------------------+
```

同时开发者依然可以遵循原来的Activity开发习惯，继续基于Fragment开发应用。

这看起来很美妙，但Android存在一个令人抓狂的概念——`生命周期`

生命周期
-------

声明周期描述的是一个页面从打开到销毁经历的各个过程，在各个过程里系统都会通过方法告知开发者。就Activity来说，开发者主要关心的方法**大概**有：

```
onCreate() // 界面创建
    ↓
onResume() // 准备显示
    ↓
onPostResume() // 显示完成
    ↓
onPause() // 从屏幕消失
    ↓
onDestory() // 被系统销毁
```

这只是大概，还有一些特殊情况，例如在被系统销毁前再次打开应用，还会多触发一些事件。但这种复杂度对于大多数人还在可以接受范围内。

但是，在引入Fragment之后，

首先Fragment和Activity并不完全相同，在使用方面会有一些坑需要躲避；

其次由于Fragment也有生命周期的概念，一方面，Fragment需要跟随Activity进行显示隐藏；另一方面Fragment会被开发者动态的添加/移除，因此他又有自己需要独立的生命周期事件：

有一个专门的github项目[android-lifecycle](https://github.com/xxv/android-lifecycle)整理了各个生命周期的关系

来感受一下：

![https://github.com/xxv/android-lifecycle](https://github.com/xxv/android-lifecycle/raw/master/complete_android_fragment_lifecycle.png)

对于生命周期，大部分情况下，开发者仅仅关注应用的打开和关闭事件。但引入Fragment后需要增加更多的开发测试成本。例如Fragment如果存在于翻页组件中，当前页被翻走后，我们可能会认为将会触发Fragment的onPause事件，而实际上，触发的是onHiddenChange事件。

封装ViewGroup
-------------

回到最初Activity遇到的问题。我们不引入Fragment，而直接使用ViewGroup


```
+------------------+
|    Activity      |
|                  |
|    +-------+     |
|    | View  |     |
|    | Group |     |
|    +-------+     |
|                  |
+------------------+

+------------------+
|    ViewGroup     |
|                  |
|    +-------+     |
|    | View  |     |
|    | Group |     |
|    +-------+     |
|                  |
+------------------+
```

并且从面向Activity开发转为面向ViewGroup开发。ViewGroup的生命周期事件只有两个:`onAttach`和`onDetach`，分别在被添加到屏幕和被移除时调用。而遇到特殊的事件，我们就需要通过手动的方式从Activity中往ViewGroup里传递。对比Fragment

缺点：

- 旧的Activity无法方便迁移到Fragment里
- 需要手动传递特殊的声明周期事件（例如onActivityResult）

优点：

- 因为仅有最简单的生命周期，所以完全不会造成迷惑
- 不需要学习Fragment复杂的生命周期和Api

Coordinators
------------

Coordinators项目实际上只有5个小文件，他做的仅仅是把ViewGroup的两个生命周期提取到他的Coordinator类里，让开发者面向Coordinator类来进行开发。

所以与其说他是一个框架，不如说是一种约束: 既然Activity里内容太多，那就只提供一个能把Activity中内容分隔开的组件，这个组件不需要有太复杂太全面的功能，而仅仅是一个引导的作用。经过他的约束，开发者自然会规范自己的代码。

![Coordinators安利图](https://cdn-images-1.medium.com/max/800/1*BZL5rIv7GVl8V0s0RWH4Pg.jpeg)

总结
----

使用Fragment或者ViewGroup孰优孰劣实际上还是需要具体场景结合分析。

Fragment是官方推出的框架，他的特点就是大、全、严谨；而Coordinators更像一个规范代码的工具类。都可以解决显示组件模块化问题。

我们在开发中往往也会遇到类似的代码框架上的问题，为了修复这些问题，或许我们也会去考虑写一个更完善的框架，或者引入一个新的概念和组件。

而Coordinators告诉我们，当遇到这种问题我们或许可以通过代码约束的角度来解决。设计一些方法对出现问题的根本进行约束，或许在功能上有所损失，但对于使用者来说，学习成本降低或许能带来更好的效果。





相关阅读：

- http://stackoverflow.com/questions/19927452/to-fragment-or-not-to-fragment-nested-fragments-against-activities-why-should

- https://hackernoon.com/coordinators-solving-a-problem-you-didnt-even-know-you-had-e86623f15ebf#.3lrkfg5md

- https://medium.com/square-corner-blog/advocating-against-android-fragments-81fd0b462c97#.w3lofag06

