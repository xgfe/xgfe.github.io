title: 【浅度解析】new Vue() 源码结构梳理
date: 2019-07-23 13:47:00
categories: luoyu
tags: 
- vue
---

new Vue() 源码结构浅度解析梳理😁
<!--more-->
# 为什么是浅度解析？

因为深度解析网上太多了，需要的话有太多资源，本文主要是为了帮助理解new Vue()时部分源码结构。

# 本文适用人群？
<img src="https://km.sankuai.com/api/file/cdn/176152462/176153325?contentType=1&amp;isNewContent=false" width="300px" height="300px">

大概知道Vue生命周期是怎么回事且琢磨过上面这张图的可放心食用。

当然了，没琢磨过也没有关系。

如果您有一定的vue开发经验以及理解可以直接Command+W 😁。

---


# 文件结构

首先Git克隆项目源码

代码块

    git clone https://github.com/vuejs/vue.git

然后进入到路径：src/core/instance，可以看到如下文件：
<img src="https://km.sankuai.com/api/file/cdn/176152462/176575345?contentType=1&amp;isNewContent=false" width="500px" height="500px">

再来看看index.js做了什么，引入各部分初始化Mixin函数，在Vue函数中执行init.js的ths._init()函数。

```
    import { initMixin } from './init'
    import { stateMixin } from './state'
    import { renderMixin } from './render'
    import { eventsMixin } from './events'
    import { lifecycleMixin } from './lifecycle'
    import { warn } from '../util/index'
	
    function Vue (options) {
      if (process.env.NODE_ENV !== 'production' &&
        !(this instanceof Vue)
      ) {
        warn('Vue is a constructor and should be called with the `new` keyword')
      }
      this._init(options)
    }

    initMixin(Vue)
    stateMixin(Vue)
    eventsMixin(Vue)
    lifecycleMixin(Vue)
    renderMixin(Vue)
    export default Vue
```

所以，这几个文件的逻辑：
<img src="https://km.sankuai.com/api/file/cdn/176152462/176154276?contentType=1&amp;isNewContent=false" width="500px" height="500px">

# _init逻辑及具体模块

那么 _init 函数做了些什么呢？
<img src="https://km.sankuai.com/api/file/cdn/176152462/176566742?contentType=1&amp;isNewContent=false" width="300px" height="300px">

## 性能检测：开发环境下，标记时间

	startTag = `vue-perf-start:${vm._uid}`

	endTag = `vue-perf-end:${vm._uid}`

	**mark**(startTag)

## 合并方案：存在option且有子组件？

	Y:因为Vue动态合并策略非常慢，并且内部组件的选项都不需要特殊处理。initInternalComponent，内部组件调用此快捷方法，内部组件实例化。

	N:策略合并options vm.$options = mergeOptions(resolveConstructorOptions(vm.constructor),options || {},vm)

	详细解读可转至 https://github.com/CommanderXL/biu-blog/issues/20

## 代理方案：

	当前环境是开发环境，则调用initProxy方法

	如果不是开发环境，则vue实例的_renderProxy属性指向vue实例本身。

	详细解读可看 

## initLifecycle

	向上循环找到第一个非抽象父组件对象，然后把当前vm实例push到定位的第一个非抽象parent的$children属性上，什么叫非抽象组件，比如transition和keep-alive。

	然后进行属性赋值

	详细解读可看 [https://juejin.im/post/5b1b4acf6fb9a01e573c3fcf](https://juejin.im/post/5b1b4acf6fb9a01e573c3fcf)
<img src="https://km.sankuai.com/api/file/cdn/176152462/176592301?contentType=1&amp;isNewContent=false&amp;isNewContent=false" width="1000px" height="500px">

## initEvents

初始化父组件事件，updateListeners：遍历父组件事件组，迭代到当前组件上
<img src="https://km.sankuai.com/api/file/cdn/176152462/176592946?contentType=1&amp;isNewContent=false&amp;isNewContent=false" width="1000px" height="500px">

## initRender

	定义了各类渲染选项，并且对 （$attrs--继承所有的父组件属性）、（$listeners--子组件继承父组件的事件）进行，同时定义两个createElement方法：
<img src="https://km.sankuai.com/api/file/cdn/176152462/178851415?contentType=1&amp;isNewContent=false&amp;isNewContent=false" width="1000px" height="500px">

## callHook(vm, 'beforeCreate')

	很好理解，触发beforeCreate钩子函数

## initInjections

	将祖先元素的
<img src="https://km.sankuai.com/api/file/cdn/176152462/178660104?contentType=1&amp;isNewContent=false&amp;isNewContent=false" width="1000px" height="500px">

## initState

	创建数据，初始化

	initProps：简单地说，遍历 props，给 props 设置响应式，给 props 设置代理，详细可见

	initMethods：这里主要是一串检测，然后绑定函数

	initData：挂载data

	initComputed：挂载Computed

	initWatch：挂载watch
<img src="https://km.sankuai.com/api/file/cdn/176152462/179281438?contentType=1&amp;isNewContent=false&amp;isNewContent=false" width="1000px" height="500px">

## initProvide

	这里很简单,数据挂载后初始化Provide,如果时函数则call再挂在至_provided
<img src="https://km.sankuai.com/api/file/cdn/176152462/179310335?contentType=1&amp;isNewContent=false&amp;isNewContent=false" width="1000px" height="500px">

## callHook(vm, 'created')

	触发created钩子函数

## mark(endTag)

	注意，created之后，计时结束

## vm.$mount(vm.$options.el)

	如果存在元素,则触发mounted钩子函数
<img src="https://km.sankuai.com/api/file/cdn/176152462/179284934?contentType=1&amp;isNewContent=false&amp;isNewContent=false" width="1000px" height="500px">

# Minxin funs
 
## initMixin
  混入init函数，执行各部分初始化操作
## stateMixin
  设置data和props的setter，getter，并且在原型上定义其，同时定义$watch函数
## eventsMixin
  主要是在原型上定义事件的几种启动关闭方法
## lifecycleMixin
  主要是定义原型的_update，$forceUpdate，$destroy方法，其中beforeDestroy和destroyed周期函数在此触发
## renderMixin
  首先通过installRenderHelpers安装一系列渲染函数，然后定义$nextTick和_render
<img src="https://km.sankuai.com/api/file/cdn/176152462/179524445?contentType=1&isNewContent=false&isNewContent=false" width="1000px" height="500px">


# 整体关系图


<img src="https://km.sankuai.com/api/file/cdn/176152462/179544320?contentType=1&isNewContent=false&isNewContent=false" width="1500px" height="500px">
