title: 基于React-Native及Redux的Immutable.js引入
categories: lulutia
tags: 
- React Native
- React
- optimization
---
本文主要介绍了如何对RN项目进行render count的优化，着重介绍了Immutable.js及其如何与Redux和React Native融合。

<!-- more -->

#### 前菜之背景介绍
话说某天，楼主吃着火锅唱着歌，逛到了React的Performance Tools版块，心血来潮，放到了手上的项目里面玩了玩，看完后整个人都不太好了，数据如下(我一页屏幕都截不完......)：
![性能图](http://okzzg7ifm.bkt.clouddn.com/immutable-oldPref.png?)
但实际上我所执行的操作仅仅只是为颜色外观打了个分，如下所示：
![操作图](http://okzzg7ifm.bkt.clouddn.com/immutable-coperation.png)

根据上面的统计数据，初略计算了下，一个打分操作render count为293。一个页面必填5个打分项，如此一来总共render count  >= 1465，其中还排除了用户打分完毕后继续修改的情况。不用我说，大家也能看出这是一个相当不合理的数字。因为就理想状况而言，打分操作最多只影响当前的打分项，一个打分组件五颗星，其具体结构如下所示:

```js
	<View key={i}>
	      <TouchableOpacity
	        style={{marginTop: 5, marginRight: 5}}
	        onPress={() =>{......}
	        >
	        <IconFont name="star" size={StyleSheet.r(22)} color={color}/>
	      </TouchableOpacity>
	 </View>

```
因此直接改变量为3*5=15是比较合理，再加上全局的Navar以及connect等操作，render count达到293也是绝对不合理且，通过分析，我们可以看到有很多数据根本没改变的组件也被重新渲染了的，这部分开销完全是不必要且有相当大的改进空间的。既然如此，我们来改进下吧~

为了减少环境变量且便于修改与测试，我们基于种子项目来模拟当前的状况。种子项目在React Native官方项目基础上集成了Redux进行数据处理，除此之外还提供了一些基本的工具函数及路由封装。
我们构造了两个页面，点击第一个页面的button会跳转到第二个页面，在第二个页面会从服务器端获取数据，渲染成列表形式，除此之外在列表上方有一个button，它会记录点击次数并且展示出来。大概布局如下：
![demo图](http://okzzg7ifm.bkt.clouddn.com/immutable-exampleLayout.png?imageView2/2/w/500/h/500/q/100|watermark/2/text/bHVsdXRpYQ==/font/5a6L5L2T/fontsize/240/fill/IzAwMDAwMA==/dissolve/20/gravity/SouthEast/dx/10/dy/10|imageslim)

既然是模拟前文的情况，那我们可以预测点击addCount button后，整个列表应该是被重新渲染了的，虽然他的数据实际上并没有变化，讲道理是不应该重新渲染的。实际结果如下图所示，的确和我们的预测一样，List下的Text render count是不必要的。
![demo性能图](http://okzzg7ifm.bkt.clouddn.com/immutable-examplePref.png?)

这里有一个点要注意，所谓的重新渲染指的是在virtual dom层面的。下图是整个渲染过程开始到结束的主要流程，而本文关心的是下图黄色框中的部分，而重中之重是黄色框中的第三部: 其后代组件执行Update。
![渲染过程](http://okzzg7ifm.bkt.clouddn.com/immutable-setstate.png?)

因为我们采用Redux进行数据处理，每个页面的initailState为一个对象，而从不直接修改state 是Redux 的核心理念之一，所以触发action后reducer返回的是一个新的对象。这一流程相当于执行了setState操作，因此整个页面开始执行dirty的标记，因为是新对象，所以几乎所有与state相关的组件及其后代组件都要执行Update的流程，如果我们不对Update的流程进行特殊定制，则shouldComponentUpdate默认返回true，之后执行render函数。因此，出现了上述中多次不必要render的情况。
所以，首要任务是添加shouldComponentUpdate函数进行处理。但是这里会有两个明显的问题：

* 每个页面，甚至每个组件的state，props结构不一样，很难有统一的对比函数
* state，props的结构可能很复杂，一步步的循环迭代对比对性能的消耗可能很大

针对shouldComponentUpdate，React提供了PureRenderMixin的方式来进行处理，但是这种方式其进行的只是浅对比，如果是复杂数据结构的深层次不一样，它也可能返回false。因此只能处理简单的数据结构，或者针对开发者对整个state层次有完全的把握，能够在深层次变化后显示调用this.forceUpdate()的情况。显然与我们的需求不符。此时，本文的主题Immutable.js终于要出场了。

#### 主菜之Immutable.js介绍
讨论Immutable.js之前，我们首先看看啥叫Immutable。来，看看维基百科的定义：

>In object-oriented and functional programming, an immutable object is an object whose state cannot be modified after it is created.This is in contrast to a mutable object (changeable object), which can be modified after it is created.

* 需要解决的问题
	* 减少复杂性，增加代码的可控性

		对于immutable object在创建后就再也不能修改了，而mutable object却可以修改，举个很简单的栗子：
		
		```js
		let fruit = {apple: 1};
		friuit.apple = 2;
		fruit; // {apple: 2}
		
		```
		上面这种特性在频繁需要修改原对象的时候特别好用，可以节约内存。但是这种灵活性往往以可控性为代价，多处使用中的任意一处修改都会影响所有的使用，比如下面的栗子：
		
		```js
		let animal = {dog: 1};
		changeAnimalCount(animal);
		animal; // ?
		
		```
		经过函数调用后，我们谁都不知道animal变成了啥样 = =。处理这种情况，我们往往需要执行深拷贝，然后在拷贝出的对象上执行操作，这样可以保证数据的可控性，但这个又往往以内存的大量使用为代价。特别不巧的是，我们的项目中还真的有很多地方用到了深拷贝，并且为了这个操作引入了extend库。因此，如何在花费很少的情况下对state的状态做一个很好的记录成为了一个问题。

	* 减少UI框架中View层与Model层的耦合
	
		在我们进行应用交互时，我们相当关注状态的改变，因为状态的改变意味着我们需要做哪些UI层面的变动，这部分是数据驱动的。简单的说，我们可能实现下面的代码：
		
		```js
		let storeData = {key: 'before'};
		renderUI(storeData);
		getDataFromServer(url, ()=>{
			renderUI(storeData);
		})
		```
		但是上面这种情况造成的问题是，也许和服务器交互后的数据根本没有改变，然而我们要执行UI渲染。或者的确执行了UI渲染，但是我们并不知道是具体的哪块数据进行了变动。因此我们可能改良出下面的代码：
		
		```js
		let storeData = {key: 'before'};
		renderUI(storeData);
		Object.observer(storeData, (changes) => {
			renderUI(storeData, changes);
		})
		getDataFromServer(url);
		```
		这种情况下，我们通过Object.observer()来对数据进行监听，这样至少我们知道哪些数据进行了变化。但是这种情况下依然有问题，因为Object.observer()执行的只是第一层的比较，因此如果是深层次的变化它依然没法处理。同时，如果数据变化频繁的情况下，它也做了很多的无用功，毕竟我们只关心最后的状态。因此现在的做法基本是使用如下所示的：
		
		```js
		let data = {
			dirty: false,
			_raw: {key: 'value'},
			get: function (key) {
				...
			},
			set: function (key, newValue) {
				...
				this.dirty = true;
			}
		}
		function renderUI(data) {
			if (!data.dirty) {return;}
			data.dirty = false;
			...
		}
		```
		但是这种情况如果同时对一个状态进行多种渲染，因为在第一个渲染中已经改变了dirty的状态，这样并不会调用第二个渲染，如下：
		
		```js
		...
		renderTop(data);
		renderBottom(data);
		```
		因此，既然每一个render都要执行dirty状态的检测，所以可以建立一个UI框架，将这层检测包裹进去，而不用使用者自己来做。但这样一来Model层和View层就耦合了。因此，如何在不对MV进行强耦合的情况下对数据的变化进行监听成为了一个问题。
	
	* 处理缓存
	
		当我们在处理一些消耗很大的操作时，我们可能希望将之前的结果存储起来而不是每一次都重新计算。比如像下面这样：
		
		```js
		function expensiveCoperation() {
			...
		}
		let data = memorize(expensiveCoperation);
		let initialData = ...;
		data(initialData);
		```
		市面上有很多对于memorize的实现，比如下面这个：
		
		```js
		function memorize(fn) {
			let cache = {};
			return function(arg) {
				let hash = arg === Object(arg) ? JSON.stringify(arg) : currentArg;
				return hash in cache ? cache[hash] : (cache[hash] = fn.call(this, arg));
			}
		}
		```
		但是上面这种实现里面的JSON.stringify()是一个O(n)的操作，当数据量够大时，执行这个函数的操作说不定还没有不执行的快。在具体实现中也许我们可以简化这个操作，只对比前一次的输入和这一次的输入，只关心前一次的结果和这一次的结果。此时我们便可以不必使用JSON.stringify了。实际上React中的shouldComponentUpdate就是只对前一次状态和这一次状态进行对比。但对比时我们其实进行的是值的对比而不是引用的对比。所以缓存性能的提高最后落脚点到如何快速进行值的比较。因此，如何对复杂结构的值进行对比成为了一个问题。

* 解决办法

	针对以上问题，Immutable.js提出了一下几个解决方案：
	* 持久化结构数据
	
	所谓持久化结构数据即Persistent data structire，我们来看维基百科的定义：
	
	> In computing, a persistent data structure is a data structure that always preserves the previous version of itself when it is modified. Such data structures are effectively immutable, as their operations do not (visibly) update the structure in-place, but instead always yield a new updated structure.
	
	我们如果用时间流的概念来看这个问题，即每一次改变都保存了一个类似快照的东西，之后的改变并不会影响之前的快照。这样我们就能够对state的变化做一个很好的记录，解决了上面的第一个问题。但是你可能会担心这样等于说是进行拷贝，会耗费很多内存，因此请看下面的解决方案。
	
	* 结构共享
	
	当我们使用一个新的值时，我们希望能够尽量复用老值不变的部分，因为这样意味着少量的copy操作和少量的内存使用。数据结构中的有向无环图可以实现这个需求。但是JS中基本的数据结构Array和Object显然都不是用DAG[Directed Acyclic Graph]实现的。因此Immutable.js等于用Trie自己实现了一套数据结构。基本的思路如下：
	
	![结构共享](http://okzzg7ifm.bkt.clouddn.com/immutable-share.png)
	每个节点都有自己的hashCode，因此比较两个对象时，实际就是比较其hashCode，这样就避免了深度遍历。
	
	* 惰性加载

	在Immutable.js中提供了Seq来执行惰性加载。Seq执行最小的工作来对任何方法作出反应。比如：
	
	```js
	const oddSquares = Seq([ 1, 2, 3, 4, 5, 6, 7, 8 ])
	  .filter(x => x % 2)
	  .map(x => x * x)
	  console.log(oddSquares.get(1)); //9
	```
	上面这个例子filter将只会执行三次，而map只会执行一次。这种特性对于处理大型数据相当有用。

	* 其他
	
		Immutable的特性意味着它特别适合用于多线程开发，它避免了很多不必要的锁的存在。虽然这点对于现在的JS没啥作用，但谁知道未来呢，毕竟多核已经越来越普遍。
		
* 基本API

	Immutable.js主要提供了下面几种数据类型：
	
	* List：类似Array
	* Map：类似Object
	* OrderedMap：在Map的基础上根据set顺序进行排序
	* Set： 类似ES6中的Set
	* OrderedSet：在Set的基础上根据add顺序进行排序
	* Stack：有序集合，进行unshift和shift的操作复杂度为O(1)
	* Range(start, end, step)：返回Seq.Indexed类型数据的集合
	* Repeat(value, times)：返回Seq.Indexed类型的数据集合，重复times生成value值
	* Record：；类似ES6中的Class，细节上不同
	* Seq：序列
	* Iterable：可以被迭代的key，value集合，是其他所有集合的基类
	* Collection：抽象类，无法直接构建此类型
	
	其中最常用的是List和Map。
	
	* 常用API：
		* fromJS(): 最常用的将原生JS数据转换为Immutable数据的转换方法
		
		```js
		const data = Immutable.from({a: {b: [10, 11]}});
		```
		* toJS(): 将Immutable数据转换为原生JS
		* set()
	
		```js
		const originalList = List([ 0 ]);
		// List [ 0 ]
		originalList.set(1, 1);
		// List [ 0, 1 ]		
		List().set(50000, 'value').size;
		// 50001
		```
		* setIn(): 进行深度赋值
	
		```js
		const list = List([ 0, 1, 2, List([ 3, 4 ])])
		list.setIn([3, 0], 999);
		// List [ 0, 1, 2, List [ 999, 4 ] ]
		```
		* get()
	
		```js
		const list = List([ 0 ]);
		let value = list.get(0); // 0
		```
		* getIn(): 进行深度取值
	
		```js
		const list = List([ 0, 1, 2, List([ 3, 4 ])]);
		let value = list.getIn([3, 0]); // 3
		```

		* is(): 进行值对比[对于复杂对象其实是hashCode的对比]
		
		```js
		const map1 = Map({ a: 1, b: 1, c: 1 })
		const map2 = Map({ a: 1, b: 1, c: 1 })
		assert(map1 !== map2)
		assert(Object.is(map1, map2) === false)
		assert(is(map1, map2) === true)
		```
		除了上面这些，Immutable.js基本提供了所有的对应原生操作的方法，具体见[这里](https://facebook.github.io/immutable-js/docs/#/List/getIn)

#### 甜点之具体集成到RN+Redux的项目中
在第一点中我们分析了遇到的优化点，在第二点中我们讲解了能进行优化的工具，现在我们来进行具体的优化。

* combineReducers的切换
	我们之前combineReducers用的是Redux提供的，但是它只能处理原生JS，所以我们需要引入redux-immutable，它提供的combineReducers可以处理Immutable数据
	
	```js
	import {createStore, applyMiddleware, compose} from 'redux';
	import {combineReducers} from 'redux-immutable';
	...
	export default (data = Immutable.Map({})) => {
	  const rootReducer = combineReducers({
	    route: routeReducer,
	    modules: combineReducers(reducers)
	  });
	
	  return createStore(rootReducer, data, middleware);
	};
	```

* 每个Reducer的初始化数据也应该采用Immutable数据

	```js
	const initialState = Immutable.Map({
	  dataList: Immutable.List([]),
	  count1: 0
	});
	```
* 与服务端数据的交互在第获取一时间转换为Immutable数据，在发送第一时间转化为原生数据

	```js
	return fetch(url).then((res) => {
      return res.json();
    }, (er) => {console.log(er);}).then((data) => {
      data = Immutable.fromJS(data || {});
      dispatch({
        type: GETDATA_END,
        payload: {
          dataList: data.get('data')
        }
      });
    }, (error) => {
      console.log(error);
      dispatch({
        type: GETDATA_BEGIN
      });
    });
	```
	这里需要注意以下两点：
	
	* 如果使用安卓模拟器，且使用localhost的数据，需要直接填写localhost的ip地址。因为模拟器有自己的localhost ip，如果直接用localhost就指向了它提供的地址，而不是本机的地址了
	* 如果使用iOS模拟器，其请求的是http协议的地址，需要在info.plist开启对http的支持，如下：

		```json
		<key>NSAppTransportSecurity</key>
		    <dict>
		      <key>NSAllowsArbitraryLoads</key>
		      <true/>
		     </dict>
	    ```

* 因为Persistent data structire，Reducer返回的数据不用新建一个对象了

	```js
	[GETDATA_END]: (state, action) => {
    const {dataList} = action.payload;
    return state.set('dataList', dataList);
  },
	```
* shouldComponentUpdate可以进行统一处理了

```js
  shouldComponentUpdate(nextProps, nextState) {
    const thisProps = this.props || {};
    const thisState = this.state || {};
    nextState = nextState || {};
    nextProps = nextProps || {};

    if (Object.keys(thisProps).length !== Object.keys(nextProps).length ||
      Object.keys(thisState).length !== Object.keys(nextState).length) {
      return true;
    }

    for (const key in nextProps) {
      if (!Immutable.is(thisProps[key], nextProps[key])) {
        return true;
      }
    }

    for (const key in nextState) {
      if (!Immutable.is(thisState[key], nextState[key])) {
        return true;
      }
    }
    return false;
  }
```
* 函数的传递方式需要注意

	如果每次render时都是重新声明的函数，则其对比会有问题，因为is()内部对函数的对比是基于ValueOf的，所以将下面的第一种方式改为第二种方式：
	
	```js
	<TouchableOpacity onPress={() => this.addCount()} style={Style.btnContainer}>
      <Text style={Style.btnWord}>addCount</Text>
  </TouchableOpacity>
	```
	```js
	<TouchableOpacity onPress={this.addCount} style={Style.btnContainer}>
	      <Text style={Style.btnWord}>addCount</Text>
	  </TouchableOpacity>
	```

经过上面这些改造后，我们的demo文件Render count如下所示，很好，楼主又可以欢快的吃火锅啦：
![优化之后](http://okzzg7ifm.bkt.clouddn.com/immutable-after.png?)
#### 酒水之利弊介绍
* 优
	* 能便利的进行时间溯洄，便于状态的把控与调试
	* 结构共享，节约内存
	* 并发安全
	* 能抽象出统一的对比函数
	* Model与View耦合度不高
* 缺
	* 有学习成本
	* 容易与原生函数混淆，并且原生函数一旦重写可能会导致问题
	* 资源大小增加
	* 跨页面数据同步方式会有变动，之前页面间进行引用传递，在B页面进行的修改会自动呈现到A页面，但是现在是Persistent data structire，因此B页面的改动A页面无感，需要特殊的触发机制来进行状态同步
	* 因为并非原生的数据结构，所以像解构这种用法需要引入特殊的库后才能使用

#### 参考
* [React.js Conf 2015 - Immutable Data and React](https://www.youtube.com/watch?v=I7IdS-PbEgI&feature=youtu.be)
* [Optimizing Performance](https://facebook.github.io/react/docs/optimizing-performance.html)
* [Immutable.js](http://facebook.github.io/immutable-js/)
* [Immutable.js 以及在 react+redux 项目中的实践](https://juejin.im/post/5948985ea0bb9f006bed7472)
* [Immutable 详解及 React 中实践](https://zhuanlan.zhihu.com/p/20295971?columnSlug=purerender)
* [从 React 的组件更新谈 Immutable 的应用](http://stylechen.com/react-and-immutable.html)