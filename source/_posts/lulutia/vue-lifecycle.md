title: Vue生命周期总结
date: 2017-10-31 15:04:00
categories: lulutia
tags: 
- Vue
---
本文主要总结了vue中涉及到的生命周期，并且通过实际尝试得出了其执行顺序。

<!-- more -->

在进行Vue项目开发的过程中，会不可避免的接触它的生命周期。了解每个生命周期的特性及其使用场景对于快速进行项目开发相当重要。

### 全局守卫
一般基于Vue全家桶进行开发的项目都会采用vue-router来进行路由处理。在这种情况下，全局路由钩子将会是我们接触的生命周期第一站。这块主要涉及到以下两个方法：

* 使用router.beforeEach注册一个全局前置守卫。直白的说就是当一个导航触发时，会按照顺序执行完毕此方法里的内容后再进行跳转[resolve后]。因此，在这个周期内特别适合做**全局拦截**，比如判断登陆状态。这个方法接受三个参数(from, to, next)，并且以调用next方法来作为resolve的标志。next方法可以传入以下几种参数：

	* 不传参数如next()：进行管道中的下一个钩子，执行完后成为resolve状态，进行正常跳转
	* 传入具体的路径如next('/'): 直接跳转到传入的地址，当前导航会被中断，进行新的导航
	* 传入false如next(false): 中断当前导航，保持在当前的页面
	* 传入error如next(error): error是一个Error实例，导航会被终止且该错误会被传递给router.onError()注册过的回调

```js
router.beforeEach((to, from, next) => {
  console.log('router.beforeEach')
  next()
})
```
* 使用router.afterEach注册一个全局后置钩子，接受两个参数(from, to)。不接受next，也不改变导航状态

```js
router.afterEach((to, from, next) => {
  console.log('router.afterEach')
})
```

### 根组件
按照正常思维来思考，当路由确定后就涉及到具体页面的渲染。因此这部分涉及到以下几个实例的生命周期：

* beforeCreate：这个阶段主要执行初始化。可以访问实例本身，但是因为实例的配置还没完成，因此**访问data或者method都是没用的**。
* created：这个阶段已经进行了实例的配置，因此可以访问data、method和computed等了。但是因为挂载还没完成，所以**直接访问this.$el是没用的**
* beforeMount：这个阶段是在挂载开始之前执行，之后就会走正常的渲染逻辑
* mounted：在这个阶段挂载已经完成，所以**访问this.$el已经能够拿到元素了**
* beforeDestroy：这个阶段在实例销毁之前调用，因为是之前，所以在这个阶段还能够访问实例本身
* destroyed：这个阶段表示实例已经被销毁完成了。因此所有自己本身及其子组件的绑定，监听都会销毁

上面是一个最基本的流程。加上前面的全局路由。我们可以看见其执行先后顺序如下：

![](http://okzzg7ifm.bkt.clouddn.com/timeline1.png)

通过上面的展示，我们得到注意点，在从A页面跳转到B页面时，**A页面的beforeDestroy和destroyed方法是比全局路由的beforeEach和afterEach执行的晚的**。

除了上面一个最基本的流程外，还有一个很重要的环节就是**更新**。关于这个，有下面两个生命周期阶段：

* beforeUpdate：数据更新时调用，发生在virtual dom进行对比和渲染之前。因此在这个阶段继续更改数据不会触发重新的渲染。但是这里有几个需要注意的地方如下：
	* 如果只是单纯的数据变化，而这个变化并没有在template里面使用，则这个函数也不会触发。
	* 在beforeUpdate里面进行的数据更新，如果与之前的一样，则virtual dom对比结果为一样，此时不会重新触发beforeUpdate和updated；如果不一样，则会触发beforeUpdate和updated，但实际updated时更新的数据为后面的，证明在这个阶段继续更改数据不会触发重新的渲染；但是如果这个阶段的数据更新是异步的，比如延迟一秒更新，实际updated会触发两次并且数据不一样，表明触发了新的绘制
	* 在beforeUpdate里面重复修改同一个数据可能导致beforeUpdate函数的无限循环，应尽量避免
* updated：virtual dom重新渲染和打补丁之后调用。所以如果在这个阶段再进行数据的更改会又重新触发beforeUpdate，恰巧如果beforeUpdate里面有同一数据的修改则很容易导致无限循环，所以最好避免这种事情发生。这个环节后，可以使用更新后的dom。

在添加了上面两个方法后，现在我们可以看其执行顺序如下：

![](http://okzzg7ifm.bkt.clouddn.com/timeline02.png)

### 子组件
根组件的基本生命周期探讨到一阶段了，因为现在都是组件化的思维，因此现在很自然的就会想到子组件的生命周期在全局是处于何种位置的。
与根组件一样，子组件也拥有beforeCreate、created、beforeMount、mounted、beforeUpdate、updated、beforeDestroy、destroyed这几个生命阶段。现在我们来看在**不执行更新操作**时的执行顺序：

![](http://okzzg7ifm.bkt.clouddn.com/timeline03.png)

由上可知:

* 子组件的初始化晚于根组件，但是其挂载早于根组件，即当子组件都mounted后，根组件才会mounted。具体子组件的beforeCreated时间是在根组件的beforeMount之后
* 子组件的销毁开始时间也晚于根组件，但是只有当子组件都destroyed后，根组件才destroyed了

那加上更新操作时会怎样呢？我们构造了一个子组件，将根组件的msg作为props传入进去，然后根据这个prop构造一个计算属性，来作为子组件的template中的一个参数。注意这里一定要使用计算属性，如果直接使用data的话，是不会更新的：

```js
<smallcomponent :msg="msg"/>
..........HelloWorld.vue.........
 <template>
  <div>
    <h1>{{componentInfo}}</h1>
  </div>
</template>
...
 props: {
      msg: {
        type: String
      }
    },
    computed: {
      componentInfo () {
        return this.msg
      }
    },
..........Time.vue........

```
在上面这种情况下，我们可以得出其生命周期如下，很明显，根组件是在子组件更新完毕后才更新完毕的：

![](http://okzzg7ifm.bkt.clouddn.com/time04.png)
 
### 指令
除了上面所说的子组件，根组件里面可能还会有指令存在，总的来说指令也会有其对应的生命周期，如下来自[vue官方文档](https://cn.vuejs.org/v2/guide/custom-directive.html#main)：

* bind：只调用一次，指令第一次绑定到元素时调用，用这个钩子函数可以定义一个在绑定时执行一次的初始化动作
* inserted：被绑定元素插入父节点时调用 (父节点存在即可调用，不必存在于 document 中)
* update：所在组件的VNode更新时调用，但是可能发生在其孩子的VNode更新之前
* componentUpdated：所在组件的VNode及其孩子的VNode全部更新时调用
* unbind：只调用一次，指令与元素解绑时调用

我们实现了一个指令，将根组件的msg作为值传入指令中，在最基本的状态下，他们的生命周期流程如下：

![](http://okzzg7ifm.bkt.clouddn.com/timeline05.png)

看来指令和子组件的状态十分类似，也是在根组件beforeMount后进行bind与inserted，然后根组件才执行mounted；在解绑时，也是在根组件beforeDestroy后执行，执行完后根组件才可能执行destroyed

同样，如果这时，加上更新操作，其生命流程会如下所示，很明显，根组件是在指令更新完毕后才更新完毕的：

![](http://okzzg7ifm.bkt.clouddn.com/timeline06.png)

之前我们单独的讨论了子组件和指令，那么如果它们在一起时生命周期的顺序又是怎样呢？通过实际实验，我们得出其顺序如下，当我们在根组件里先引入子组件再引入指令时其顺序如下左图，当我们先引人指令再引人子组件时其顺序如下右图：

![](http://okzzg7ifm.bkt.clouddn.com/timeline09.png)

很明显，这个顺序是和引人组件或者指令的先后顺序有关～

* 销毁阶段谁先引入谁先销毁
* 更新阶段，都是指令的更新靠前
* 创建阶段，谁先引入谁先进行初始化，但总的来说挂载都在初始化之后[无论谁的初始化]

### 组件内的守卫
在前面我们已经讨论过全局守卫、根组件、子组件和指令了。但实际上对于组件而言，它还存在组件内的守卫，[如下](https://router.vuejs.org/zh-cn/advanced/navigation-guards.html)：

* beforeRouteEnter：在渲染该组件的对应路由被 confirm 前调用，**不能**获取组件实例 this，因为当守卫执行前，组件实例还没被创建
* beforeRouteUpdate：在当前路由改变，但是该组件被复用时调用，可以访问组件实例this
* beforeRouteLeave：导航离开该组件的对应路由时调用，可以访问组件实例this

我们在根组件添加了以上几个方法，可以看见整个生命周期如下所示：

![](http://okzzg7ifm.bkt.clouddn.com/timeline10.png)

由上可知，beforeRouteEnter是在全局守卫之后调用，而beforeRouteLeave是在全局守卫之前调用。上面我们说到在beforeRouteEnter阶段是没法访问到this的，为了解决这个问题，可以通过传一个回调给next来访问组件实例。在导航被确认的时候执行回调，并且把组件实例作为回调方法的参数。

```js
beforeRouteEnter (to, from, next) {
    console.log('beforeRouteEnter')
    next(vm => {
      console.log('beforeRouteEnter的next')
    })
  },
```
那么这个的触发又是在生命周期的那一环呢？

![](http://okzzg7ifm.bkt.clouddn.com/timeline11.png)

很明显它会在完成mounted后马上触发。所以虽然beforeRouteEnter的执行时间很早，但是它的回调执行的时间比较晚，算是最接近dom渲染的一个周期了

### 路由独享的守卫
除了上面我们讨论的全局守卫和组件内的守卫，实际还有一个路由独享的守卫，即可以在路由配置上直接定义beforeEnter守卫。具体使用如下：

```js
const router = new Router({
  routes: [
    {
      path: '/',
      name: 'Hello',
      component: HelloWorld,
      beforeEnter: (to, from, next) => {
        console.log('Exclusive beforeEnter')
        next()
      }
    },
    {
      path: '/world',
      name: 'World',
      component: Page2
    }
  ]
})
```
通过实际情况我们可以得知，这个方法的调用会在全局守卫的beforeEach之后，而在组件内守卫的beforeRouteEnter之前，如下：

![](http://okzzg7ifm.bkt.clouddn.com/timeline12.png)

### Vue.nextTick & vm.$nextTick
除了上面讨论的，还有两个和生命周期有关系的方法，如下：

* [Vue.nextTick](https://cn.vuejs.org/v2/api/index.html#Vue-nextTick)：这是个全局API，在下次DOM更新循环结束之后执行延迟回调。在修改数据之后立即使用这个方法，获取更新后的DOM
* [vm.$nextTick](https://cn.vuejs.org/v2/api/index.html#vm-nextTick): 将回调延迟到下次DOM更新循环之后执行。在修改数据之后立即使用它，然后等待DOM更新。它跟全局方法Vue.nextTick一样，不同的是回调的this自动绑定到调用它的实例上

我们将这部分加上去，得到整个这篇文章探讨的生命周期过程如下：

![](http://okzzg7ifm.bkt.clouddn.com/timeline13.png)

### 参考
* [Vue.js官方文档](https://cn.vuejs.org/)
* [vue-router官方文档](https://router.vuejs.org/zh-cn/index.html)
* [vue生命周期探究（一）](https://segmentfault.com/a/1190000008879966)

