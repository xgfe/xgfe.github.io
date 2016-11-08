title: Vue实战（二）—— 在项目中的实践
date: 2016-11-08
categories: yangjiyuan
tags: 
- Vue
---

## 前言
在上一篇中介绍了Vue的基本用法，同时我们也明白了Vue在webApp开发中提供的巨大便利性，那么，如何将Vue应用在项目中呢？这就是本篇文章我们将要讨论的内容

<!-- more -->

## 初期的尝试
### 刀耕火种的时期
我们很早做过一个微信端的WebApp，采用的框架是require+Zepto+underscore，requirejs管理模块，Zepto操作DOM以及数据交互，underscore提供常用的工具函数以及渲染模板。整个SPA中有10个页面左右，但是不存在路由的概念，多个页面在切换的时候就像是“千层饼”一样，一层盖一层，用哪一层显示哪一层，其余全部隐藏。这种结构的页面在项目不复杂的时候还能勉强应付，但是随着业务的扩大和场景复杂性增加，项目中的问题也一点点暴露出来了。比如:

- 没有路由的概念，页面跳转混乱
- 代码复用率低
- 模块耦合度较高，一个页面通常包括html、css和js三个文件，在复杂的页面中js最多的有近1000行，维护成本很高
- 代码分层不清晰，数据复杂，牵一发而动全身

### 引入Vue
在上述诸多问题的折磨下，最终决定引入更敏捷、高效、可维护性强的工具/库，调研之后决定采用Vue.js进行部分代码重构，选择Vue主要是出于以下考虑：

- Vue是一个很轻量简洁的框架，当时使用的是0.12.9版本，~24kb min+gzip
- 数据驱动机制，支持双向绑定，DOM更新快速有效
- 组件化，可以提高到代码的复用率
- 将页面的不同部分拆分成子模块，降低耦合度

最终我们将部分页面或某些功能拆分成一个个Vue实例进行管理，从某种程度上来说，开发效率和可维护性确实有所提高。比如下图一中的地址选择部分，图二的整个页面，就是用Vue完成的。

![页面部分区域使用Vue](http://p0.meituan.net/dpnewvc/4cf750c891c38bd48c069952bf93cf9b64372.jpg)
![整个页面使用Vue](http://p0.meituan.net/dpnewvc/51809f4e59cb884bb514e5d364eafc2433788.png)


### 再次出现的问题
引入Vue之后，解决了部分问题，但是同时又出现了新的问题（围笑脸），比如

- 图一的模式会导致模板文件分割，因为采用了不同的渲染模板的方式（underscore+vue），这样反而分割了页面
- 数据通信复杂，包括跨组件的，跨页面的
- 并没有完全利用到Vue的优势，感觉像是在马车上装了发动机（队友太菜，带不动╮(╯_╰)╭）

最终，我们决定对整个项目进行重构，就开始了Vue项目实践的第二阶段

## Vue项目实践的第二阶段

### 问题回顾
回顾一下在没使用Vue和初次尝试Vue之后解决的和未解决的问题：

#### 解决的问题

- 数据绑定机制很好用，声明式的模板用起来很顺手
- 简化了DOM操作，不用再`$('xx').parent().parent().next().siblings()`了，提供了良好的事件绑定/解绑机制
- 部分代码实现了复用

#### 未解决/新的问题

- 分割的HTML模板和杂糅的逻辑，页面的逻辑和Vue实例的逻辑混在一起，但是模板却两地分居
- **组件间数据通信**亟待解决，不然页面中数据传递比较麻烦，尤其是跨页面或组件的
- 路由
- 较大的js文件没有解耦

### 新的解决方案
#### 使用Vue进行**组件化**重构
全部采用Vue重构，就不存在同一个项目使用两种或多种模板解析工具了，逻辑代码和模板可以一一对应起来。同时，顺应时代潮流，实行组件化开发模式，对不同的业务逻辑进行梳理分析，形成不同层次的封装，实现**分而治之**，对基础的控件也能实现基本的**复用**。
#### 路由器：[vue-router](https://github.com/vuejs/vue-router)

vue-router是官方提供的基于Vue的路由器，和Vue深度集成，使得构建单页面应用变得非常简单，开发者可以更加把精力放在主要的业务逻辑上，只需要进行简单的组件配置和路由映射即可。

#### 数据状态管理：[vuex](https://github.com/vuejs/vuex)
官方对于vuex的解释如下
> Vuex is a state management pattern + library for Vue.js applications. It serves as a centralized store for all the components in an application, with rules ensuring that the state can only be mutated in a predictable fashion. It also integrates with Vue's official devtools extension to provide advanced features such as zero-config time-travel debugging and state snapshot export / import.
	
熟悉React的同学应该都知道[Flux](https://github.com/facebook/flux)和[Redux](https://github.com/reactjs/redux)，非常有名的数据状态管理工具，将整个应用的状态数据存储在一个单例store中，通过约定的方式进行获取，修改，这样整个数据流就变得非常清晰。vuex就是借鉴的这种思想。

#### 其他工具：[vue-resource](https://github.com/vuejs/vue-resource)和[vue-devtools](https://chrome.google.com/webstore/detail/vuejs-devtools/nhdogjmejiglipccpnnnanhbledajbpd)
vue-resource是提供异步请求的插件，可以使用XMLHttpRequest或JSONP发送请求，并且支持Promise和请求拦截。  

vue-devtools是用于调试Vue应用的Chrome插件，可以实时查看组件的状态，如果使用Vuex的话，还能随时查看store的各种状态。

### 组织目录结构
#### 组件化和数据流
前端组件化是最近今年非常火的话题，好像有了组件化，PM再提需求，拿出一个现成的组件就可以搞定他，然后笑看后端加班......但现实往往很残酷，组件化并不是万能灵药，不然我们也要失业了。

组件化仍然面临很多问题，比如，组件的拆分，哪些需要做成组件，哪些不需要呢？拆的不细，那等于没组件化，拆的太细，维护成本也会增加，所以需要把握组件化的平衡，既能合理的“分治”，又能保证可靠的“复用”。

再比如组件通信方式，目前阶段的组件化其实就是标签化，存在大量嵌套的组件，父子组件，兄弟组件之间的数据如何有效地通信。

常用的方式有标签属性触发回调，事件。用标签属性的话，代码会像下面这样：

```
<root>
    <goods-list onItemChange="onItemChangeHandler">
        <goods-item onCountChange="onCountChangeHandler"></goods-item>
        ...
    </goods-list>
    <footer goods-count="xxx">
        <shopping-cart goods-count="yyy"></shopping-cart>
    </footer>
</root>
```
模拟一个简单的购物车，包含基本的商品列表`goods-list`、商品项目`goods-item`、页面底部组件`footer`和展示当前选择数量的购物车组件`shopping-cart`。如果现在修改了商品数量，要实时反映到购物车的话，整个流程是这样的：  

1. `goods-item`组件修改数量，通知其父组件`goods-list`，即触发自身的`onCountChange`属性，进而调用父组件的`onCountChangeHandler`函数
2. 在`onCountChangeHandler`中触发`goods-list`的`onItemChange`属性，调用其父组件的`onItemChangeHandler`函数
3. `root`组件这时已经能获取到变化的商品或数量之类的信息了，再通知`goods-list`的兄弟组件`footer`渲染DOM
4. `footer`获取到变化之后再通知`shopping-cart`，渲染出最终的结果

这样一个流程下来，程序猿已经快疯了 (╯°□°）╯︵┻━┻

还有一种方式，也就是用事件，同样的场景，可以在`root`中监听一个商品数量变化的事件，当`goods-item`修改数量，触发这个事件的时候，`root`就能监听到变化，然后root再触发一个事件分发到子组件，`shopping-cart`也就能监听到变化了，实现了组件间通信。

以上两种方法各有利弊，但当项目逐渐复杂的时候，弊端是越来越明显：第一种方式会出现大量的属性以及方法回调，第二种方式会出现大量的事件监听，而且是汇聚到组件树的根节点，非常不利于维护。现在这种问题已经有了比较好的解决方案，即单向数据流，具体是实现有很多，比如基于React的Flux，Redux，基于Vue的Vuex等。

单向数据流使得数据更方便维护和跟踪，流动单一，缺点是写起来比较麻烦，要改变DOM的话必须维护相应的action和state，比双向数据绑定麻烦一些，而双向数据流就更简单，更容易理解，但是数据问题的源头难以追踪，组件通信也是大问题。
	
#### 工程化
目前Vue项目中工程化多采用webpack+vue-loader的方式，每一个.vue文件就是一个组件，这也是官方推荐的方式，单个组件维护起来更加方便。也可以采取别的方式，我并没有使用webpack和vue-loader，而是用传统的方式，即每个组件是一个目录，存放相应的模板、样式和逻辑，最后通过gulp或xg等工具进行构建。

<img alt="项目目录结构" width="200" src="http://p1.meituan.net/dpnewvc/7376ee3db58451e9e289a6550c3c0389155269.png"/>

#### 基础组件库
现在已经有很多优秀的Vue组件库了，比如微信UI风格的[Vux(2570stars)](https://github.com/airyland/vux)，bootstrap风格的[vue-strap(2673stars)](https://github.com/yuche/vue-strap)，material风格的[vue-mdl(638stars)](https://github.com/posva/vue-mdl)和[Keen-UI(1146stars)](https://github.com/JosephusPaye/Keen-UI)，eleme团队的[mint-ui(2977stars)](https://github.com/ElemeFE/mint-ui)等。  

当然，是否引入组件库也要视情况而定，如果项目结构简单或者有固定的UI规范，就没必要引入第三方组件，完全可以自己写一套CSS组件，因为Vue已经非常强大，仅仅需要配合一些基础的样式组件就可以完成一个完整的应用了，我们之前做过一个基于移动端的样式库fuguUI，目前是个半成品，如果能进一步完善，就可以作为基础的样式组件库应用到项目中了，其他优秀的移动端样式库还有[FrozenUI(1776stars)](http://frozenui.github.io/start.html)，[Skeleton(12880stars)](https://github.com/dhg/Skeleton)等。当然，适合自己的才是最好的，如果条件允许的话，最好能开发自己的组件库。

## 项目实战展示
[kuailv-mall-vue(内网访问)](http://git.sankuai.com/users/yangjiyuan/repos/kuailv-mall-vue/browse)