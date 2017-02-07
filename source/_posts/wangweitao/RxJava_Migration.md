title: The Next Step for Reactive Android Programming（译文）
date: 2017-02-4
categories: wangweitao
tags:
- andorid
- rxjava
---
“The Next Step for Reactive Android Programming”一文主要讲述在已有的android项目中将rxjava1升级到rxjava2的一些优缺点和可能遇到的困难。

<!--more-->

## The Next Step for Reactive Android Programming（译文）

 原文地址：[The Next Step for Reactive Android Programming](http://futurice.com/blog/the-next-step-for-reactive-android-programming)


 RxJava2已经出来了。如果项目还在使用RxJava1,则需要考虑升级版本。在升级之前，要仔细考虑升级的投入回报，需要花费的时间以及短期和长期的收益。

### 升级的好处

#### 支持Reactive Streams

 支持Reactive Streams是rxjava2架构上的一个变动。rxjava2重写了一套代码来支持它。Reactive Streams提供了通俗易懂的api来理解reactive库的工作过程。使我们能方便的使用不同的库。以reactor3库为例，该库与rxjava非常相似。如果你是一个android开发者，那么就不能使用它了。毕竟它是基于java 8及其以上的版本。

 在两个版本库升级reactive流是一件很容易的事。![](https://p1.meituan.net/dpnewvc/c794e0b2f98fbfa363a6d0f381c6ed7f33970.gif)
reactor3的性能比rxjava2提升10%～50%。很遗憾它不能使用在android上。
据我所知，rxjava2是目前android中惟一支持reactive streams的库。这表明当下升级rxjava2的回报并不高。

#### backpressure - observable/flowable
 
 rxjava2有一个叫做flowable的新类型.它与rxjava1中的observable非常的相似。它们最大的不同就是在rxjava2中，flowable支持backpressure.

 先解释一下backpressure的含义。不熟悉rxjava2的人听到“flowable支持backpressure”经常会问“支持backpressure是不是意味着不会收到任何MissBackpressureException”。答案是：不。
 
 支持backpressure表示处理事件的消费者没有及时保存事件，那么它有一套策略去处理它们。需要你去指定这个策略。

#### flowable

 在使用flowables时，你需要制定它的一些行为策略，包括：
 - 缓存：处理线程不能及时处理的事件会被缓存起来，当处理线程空闲时将发送缓存的事件。
 - 丢弃：当处理线程处理缓慢时，它会忽略所有的时间。一旦处理线程空闲，将会处理最近产生的事件。
 - 错误：处理线程会抛出MissingBackpressureException

 实际上来说，你在app中容易遇到backpressure吗？我对此非常怀疑。因此，我写了一个读取加速度传感器的flowable。把读出的数据打印在屏幕上：![](https://p1.meituan.net/dpnewvc/f24760ea5ba6992b6996cf03ba811357226254.gif)
 
 android中的加速度计每秒读取50次，将这些数据展示在屏幕上还不足以遇到backpressure问题。实际上，这些取决于reactive流的处理过程。但是它能够表明，backpressure并不是经常发生的问题。
 
#### observable

 observable并不支持backpressure.这表明它们从来不会发出MissingBackpressureException。如果消费者线程不能够及时处理这些事件，它们会缓存事件并稍后重新发射。
 
 那么什么时候该使用flowable，什么时候该使用observable呢？
 
 当能够明确知道backpressure在某些特定的条件下产生，如果不处理该backpressure会出现问题的时候，使用flowable.对于加速度计，如果我们需要使用它的数据而不是简单的打印出来，那么则可能出现backpressure,我也会使用flowable。
 
 observable则在不太可能出现backpressure的情况下使用。比如用户频繁的点击按钮，那么完全可以让它们缓存着。
 
 值得一提的是，如果你使用了observable,并且在短时间内出现了大量的缓存事件，那么整个程序可能会崩溃。
 
 我的一般原则是使用observable,对于以下几种类型的事件可以如此处理。
 - 按钮点击事件：每秒按钮点击事件次数有限，使用observable.
 - 光或者加速度传感器：每秒有数十次事件，使用flowable。

 需要记住的是如果你在按钮的点击事件中花费大量时间，也会导致backpressure。
 
#### 性能

 rxjava2的性能要比之前版本高。使用高性能的库是一件很棒的事。但是你需要知道项目性能的瓶颈是不是rxjava.很多时候你会看着代码思考是不是flatmap的速度太慢了。在android程序中，计算通常都不是问题。大多数时候瓶颈是在ui渲染上。
 
 我们并不是因为太多东西出现在计算线程上而导致掉帧，而是因为太复杂的布局，忘记在后台线程访问数据或者渲染时创建bitmap而导致的掉帧。
 
### 升级的挑战

#### 再见nulls

 近几年对nulls的敌意越来越多。即使是null引用的发明者也说这是一个“10亿美元的错误”。在rxjava1中你可以使用null值。但是在最新版本中，则不能使用nulls。null值在steam中被禁止。如果你在项目中使用了null,那么将会有大量的升级工作要做。你可能需要一些null objects pattern或者optionals来表示那些缺失的值。
 
#### dex容量限制

 你是否尝试过相函数式编程人员解释android中函数数量的限制？你可以尝试一下，它们的反应会很有趣。
 
 遗憾的是一个dex中我们能够写65000左右的方法。rxjava1大概含有5500的方法。这已经不小了。现在rxjava2含有超过9200个方法。增加的4000个方法很容易理解，毕竟它添加了很多功能。但是你升级项目很可能需要一步一步的完成，在升级时需要包括两个库。也就是总计15000方法，占dex方法总数的22%。
 
 如果你的方法数已经超过限制，那么这不是一个问题。但是如果你的方法快要超过限制，那么这就是升级的另一个问题。
 
#### 自定义operators

 rxjava中现有的operators也许不够使用。你可能需要一些自定义的行为。在这种情况下，你会尝试编写自己的operator.
 
 这些在rxjava1中是微不足道的一件小事。因为你只需要考虑多线程和backpressure支持即可。
 
 但是在rxjava2中就变得严重了。首先，你创建operator的方式变了。在rxjava1中你使用臭名昭著的create方法即可。但是在rxjava2中，你不仅要考虑多线程访问、backpressure、取消以及其他方面，还要考虑第四个特性Operator Fusion。这个会提高operator的性能，同时也会更加复杂。
 
 那么，真的值得去写自定义的operator吗？除非你去写rxjava2中已有的库或者其他reactive库中有的operator,否则我建议你去找另一条解决方法。
 
 首先，检查现有operator的组合是否能满足需求。其次，可以考虑使用transformer。它们不会像operator那样个性化，但容易编写。此外它们拥有更高的性能。最后一点，在android中瓶颈问题通常都是ui.
 
### 结论

 
 以上都是对升级到rxjava2的分析。最总都取决于你认为升级工作是否值得。
 
 就目前而言，使用rxjava1还是不错的。rxjava1目前依旧被支持。如果rxjava1不再被支持，那么升级到下一版本就很有必要。
 
 如果你的项目持续超过一年的时间，你需要考虑升级，否则保持在rxjava1会更好。

