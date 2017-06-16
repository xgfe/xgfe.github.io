title: 理解Virtual DOM
date: 2017-05-04 12:30:13
categories: y8n
tags:
- virtual dom
- react
---
## 前言
使用过React的同学对于Virtual DOM并不陌生，作为React的重要核心概念，Virtual DOM凭借其高效的diff算法，让我们不用关心应用的性能问题，毫无顾忌地修改各种数据状态。在实际的开发中，我们并不需要关注Virtual DOM在一个框架中是如何运行的，但是理解Virtual DOM的实现原理却是非常有必要的，同时也有助于我们更加深入React。
<!--more-->
## 一、前端应用状态管理
在日益复杂的前端应用中，状态管理是一个经常被提及的话题，从早期的刀耕火种时代到jQuery，再到现在流行的MVVM时代，状态管理的形式发生了翻天覆地的变化，我们再也不用维护茫茫多的事件回调、监听来更新视图，转而使用使用双向数据绑定，只需要维护相应的数据状态，就可以自动更新视图，极大提高开发效率。

但是，双向数据绑定也并不是唯一的办法，还有一个非常粗暴有效的方式：一旦数据发生变化，重新绘制**整个视图**，也就是重新设置一下innerHTML。这样的做法确实简单、粗暴、有效，但是如果只是因为局部一个小的数据发生变化而更新整个视图，性价比未免太低了，而且，像事件，获取焦点的输入框等，都需要重新处理。所以，对于小的应用或者说局部的小视图，这样处理完全是可以的，但是面对复杂的大型应用，这样的做法不可取。

说到这里，你会说这跟Virtual DOM有什么关系呢？其实Virtual DOM就是这么做的，只是在高效的diff算法计算下，避免对整棵DOM树进行变更，而是进行针对性的视图变更，将效率做到最优化。

## 二、什么是Virtual DOM
Virtual DOM的概念有很多解释，从我的理解来看，主要是三个方面，分别是：一个对象，两个前提，三个步骤。

一个对象指的是Virtual DOM是一个基本的JavaScript对象，也是整个Virtual DOM树的基本。

两个前提分别是JavaScript很快和直接操作DOM很慢，这是Virtual DOM得以实现的两个基本前提。得益于V8引擎的出现，让JavaScript可以高效地运行，在性能上有了极大的提高。直接操作DOM的低效和JavaScript的高效相对比，为Virtual DOM的产生提供了大前提。

三个步骤指的是Virtual DOM的三个重要步骤，分别是：生成Virtual DOM树、对比两棵树的差异、更新视图。这三个步骤的具体实现也是本文将简述的一大重点。

## 三、Virtual DOM三板斧
下面就将介绍Virtual DOM的三个步骤具体的含义以及实现思路。

### 1、生成Virtual DOM树
DOM是前端工程师最常接触的内容之一，一个DOM节点包含了很多的内容，但是一个抽象出一个DOM节点却只需要三部分：节点类型，节点属性、子节点。所以围绕这三个部分，我们可以使用JavaScript简单地实现一棵DOM树，然后给节点实现渲染方法，就可以实现虚拟节点到真是DOM的转化。

![DOM树的状态转化][1]

### 2、对比两棵树的差异
比较两棵DOM树的差异是Virtual DOM算法最核心的部分，这也是我们常说的的 Virtual DOM的diff算法。在比较的过程中，我们只比较同级的节点，非同级的节点不在我们的比较范围内，这样既可以满足我们的需求，又可以简化算法实现。

![diff][2]

比较“树”的差异，首先是要对树进行遍历，常用的有两种遍历算法，分别是深度优先遍历和广度优先遍历，一般的diff算法中都采用的是深度优先遍历。对新旧两棵树进行一次深度优先的遍历，这样每个节点都会有一个唯一的标记。在遍历的时候，每遍历到一个节点就把该节点和新的树的同一个位置的节点进行对比，如果有差异的话就记录到一个对象里面。

![深度优先遍历][3]

例如，上面的div和新的div有差异，当前的标记是0，那么：`patches[0] = [{difference}, {difference}, ...]`同理`p`是`patches[1]`，`ul`是`patches[3]`，以此类推。这样当遍历完整棵树的时候，就可以获得一个完整的差异对象。

在这个差异对象中记录了有改变的节点，每一个发生改变的内容也不尽相同，但也是有迹可循，常见的差异包括四种，分别是：

- 替换节点
- 增加/删除子节点
- 修改节点属性
- 改变文本内容

所以在记录差异的时候要根据不同的差异类型，记录不同的内容。

### 3、更新视图
在第二步得到整棵树的差异之后，就可以根据这些差异的不同类型，对DOM进行针对性的更新。与四种差异类型相对应的，是更新视图时具体的更新方法，分别是：

- `replaceChild()`
- `appendChild()`/`removeChild()`
- `setAttribute()`/`removeAttribute()`
- `textContent`

![更新视图][4]

## 四、动手实现Virtual DOM
对原理有了一定的认识之后，自然是动手实现一番了，GitHub上有很多对Virtual DOM的实现，比如[https://github.com/livoras/simple-virtual-dom/](https://github.com/livoras/simple-virtual-dom/)、[https://github.com/Matt-Esch/virtual-dom](https://github.com/Matt-Esch/virtual-dom)等，我也对其进行了一个基本的实现，比较简陋，[传送门](https://github.com/y8n/simple-virtual-dom)。

## 五、进一步思考
Virtual DOM的原理和实现的说明已经结束了，但是对于Virtual DOM的思考远没有结束，Virtual DOM 对前端开发的影响难道就只是一堆算法吗？

### 1、性能对比
首先，先来看一下性能，在诸多的Virtual DOM实现中，都会强调算法的高效，那么在实际的使用中，Virtual DOM的性能到底如何呢？

![简单性能对比][5]

上图是对一个简单的DOM树进行不同方式的操作，由左边的结构更新为右边的结构，通过原生操作、jQuery、Virtual DOM和React四种方式，在Chrome的timeline中得到的性能对比，在这个图中，我们并没有看出Virtual DOM或者React的优势，通过对比我们发现，原生的操作要比其他三种方式快，而其他三种方式就相差无几了。当然，这样一个简单测试并没有说明什么，测试的DOM结构简单，和我们平时面对的业务场景不是一个量级，代表不了什么，但是起码我们可以看到，这种情况下好像Virtual DOM并没有我们想象的性能优势。

![复杂性能对比][6]

在接下来的测试中我们增加测试量。上图分别是使用原生操作、Virtual DOM和React三种方式进行两类测试：插入10000个节点100次和修改3000个节点的属性100次。分别取这100次的耗时最大值、最小值和平均值。从图中我们可以看到明显的差异，Virtual DOM和React的差异可以理解，毕竟我们自己实现的Virtual DOM没有那么庞大，只是针对虚拟DOM而实现的，比React快一点可以理解，但是原生的操作比Virtual DOM和React都要快得多，这又是怎么一回事，好像和我们预想的不一样，回到最初，我们提到，Virtual DOM的产生前提之一就是直接操作DOM很**慢**，现在看来直接操作不但不慢，反而快了很多，这不得不让我产生了怀疑，是我对Virtual DOM的理解有误还是对DOM的理解有误呢？

### 2、再次审视Virtual DOM
框架存在的意义是什么？是提高性能？提高开发效率？亦或是其他用途，每个人对框架的理解不同，答案也不尽相同。但是不得不承认，存在框架的情况下，项目的可维护性有了极大的提高，而对于其他方面就要做出牺牲，比如性能。在上面的性能测试中，其实完全走入了一个误区，在测试中我们用到的原生的操作其实是“人为”地对操作进行优化之后的结果，而如果抛开人为优化的前提，最终的结果可能就不是这样了。**Virtual DOM的优势不在于单次的操作，而是在大量、频繁的数据更新下，能够对视图进行合理、高效的更新。**这一点是原生操作远远无法替代的。

到此为止，再次审视Virtual DOM，可以简单得出如下结论：

- Virtual DOM 在牺牲部分性能的前提下，增加了可维护性，这也是很多框架的通性
- 实现了对DOM的集中化操作，在数据改变时先对虚拟DOM进行修改，再反映到真实的DOM中，用最小的代价来更新DOM，提高效率
- 打开了函数式UI编程的大门
- **可以渲染到DOM以外的端，比如ReactNative**

## 六、结语
本文对Virtual DOM有一个简单的介绍，包括实现的部分也很简单，甚至对列表的diff算法也偷工减料，跟多高级的特性也没有涉及，比如事件绑定、生命周期、JSX语法等，如果加上这些内容，就是一个小型版的React了。

本文旨在让大家了解并认识Virtual DOM的基本概念、组成和实现，同时对Virtual DOM更深层的意义有所了解，这样在以后用到相关的框架的时候也不会两眼一抹黑了，起码在性能优化上有点认识，比如列表要带上`key`这样基本的优化操作。


## 七、参考资料

- [Levenshtein distance算法](https://en.wikipedia.org/wiki/Levenshtein_distance)
- [深度剖析：如何实现一个 Virtual DOM 算法](https://github.com/livoras/blog/issues/13)
- [50行代码实现Virtual DOM](http://www.jianshu.com/p/cbb7d7094fb9)
- [Performance Comparison for React, Angular and Knockout](http://chrisharrington.github.io/demos/performance/)
- [网上都说操作真实 DOM 慢，但测试结果却比 React 更快，为什么？](https://www.zhihu.com/question/31809713)


[1]: https://cloud.githubusercontent.com/assets/8521368/25689709/3fe7eaa8-30bd-11e7-8e00-45ec2e40726e.png
[2]: https://cloud.githubusercontent.com/assets/8521368/25689831/fe51cf0e-30bd-11e7-92fc-6fc69bcab700.png
[3]: https://cloud.githubusercontent.com/assets/8521368/25689882/5decd9ea-30be-11e7-8252-b164d6a642ae.png
[4]: https://cloud.githubusercontent.com/assets/8521368/25689889/6922dddc-30be-11e7-882d-94c47f9c6390.png
[5]: https://cloud.githubusercontent.com/assets/8521368/25689892/72533f28-30be-11e7-8d67-8fa3fb8ae26b.png
[6]: https://cloud.githubusercontent.com/assets/8521368/25689897/7b4fbb88-30be-11e7-85f5-9fb4cc423149.png







