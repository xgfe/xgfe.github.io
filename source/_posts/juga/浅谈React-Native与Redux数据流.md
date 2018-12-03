title: 浅谈React-Native与Redux数据流
date: 2018-11-25
categories: juga
tags:
- React-Native
- Redux

---
本文是对 React-Native 组件和模块开发的一个简单的介绍，以及对于Redux单向数据流的深入学习。

<!-- more -->

#### React-Native 介绍
* React-Native 在官网上给的定义是:使用 JavaScript 和 React 编写原生移动应用。在设计原理上是和 React 一致的，可以通过生命是的组件机制来搭建丰富多彩的用户界面。RN产出的不是“网页应用”，或者“HTML5应用”，RN所产出的其实是一个真正的移动应用。从感受上来说和 Objective-C 或 Java 编写的应用基本是一样的。

* [RN官网](https://reactnative.cn/)

#### 组件开发
* 官网上有教大家如何构建一个新的 React-Native 应用，这里就不多说了，这里直接切入组件的开发。可以在项目里面新建一个 Component 组件文件夹，专门用来存放组件。在该文件家里面建一个 TestComponen 子文件夹，然后在此子文件下面再建 TestComponent.js 和 TestComponentStyle.js 两个文件夹，组件的逻辑写在TestComponent.js文件下，样式写在 TestComponentStyle.js 文件下。
![文件结构](https://wx4.sinaimg.cn/mw690/ba56005dgy1fxkcvc82f8j20hk03uaaa.jpg)

* JS文件分析

```js
import React, {Component} from 'react'; //引入Component
import {
  View,
  Text,
  Button
} from 'react-native'; //引入RN原生组件
import {Style} from './TestComponentStyle'; //引入样式
```

* 简单的计数器实现

![计数器](https://wx4.sinaimg.cn/mw690/ba56005dgy1fxkcvc2m1qj207g010dfq.jpg)

点击加号数字动态变化+1，点击减号数字动态-1。首先这个组件由一个 Text 和两个  Button 组件组成，其中 Text 组件中有两个变量，children 作为对外暴露的属性，写在this.props 里面，state 是组件内部的可变化的状态，写在this.state里面。
官网上是这样描述 props 和 state：我们使用两种数据来控制一个组件：props 和 state.props 是在父组件中指定，而且一经指定，在被指定的组件的生命周期中则不再改变。对于需要改变的数据，我们需要使用 state 。
这里先介绍一下 render 函数部分:

```js
render() { //渲染函数
    const { 
      children
    } = this.props; //组件对外暴露的属性
    const {num} = this.state; //组件内部的状态
    return ( //返回要渲染的组件
      <View style={Style.container}>
        <Text style={Style.txt}>{`${children} ${num}`}</Text>
        <Button title={'-'} color={'red'} onPress={this.clickBtnSub}/>
        <Button title={'+'} color={'blue'} onPress={this.clickBtnAdd}/>
      </View>
    );
  }
```
可以看到，组件的结构由一个 View 组件包裹一个 Text ，两个 Button 组件。Text 组件为展示的数字名和数字大小，Button 则是两个加减按钮。

然后可以看到Style.container和Style.txt都是引自 TestComponentStyle.js文件。接下来我们看一下该文件。
```js
import {StyleSheet} from 'react-native';

export const Style = StyleSheet.create({
	// styles
  container: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-around',
    width: 200,
    height: 80
  },
  txt: {
    fontSize: 20
  }
});
```
这个是RN样式的基本写法，这个文件专门放css层的东西。这里要注意的是css的属性值接受的是字符串形式，在RN里面的 css 很多样式的值都被阉割了，所以这点要特别注意，这里有个推荐的网站可以看常用的RN样式:
[RN css样式](https://shenbao.github.io/ishehui/html/RN%20%E5%9F%BA%E7%A1%80/React%20Native%20%E6%A0%B7%E5%BC%8F%E8%A1%A8%E6%8C%87%E5%8D%97.html)

然后可以看到 Button 组件里面分别有一个点击事件。clickBtnSub事件处理减1，clickBtnAdd 处理加1。
这里我推荐是使用箭头函数来定义函数，就可以在该组件的作用域里面直接调用。
```js
 clickBtnSub = () => {
    const {num} = this.state;
    this.setState({num: num - 1});//调用setState()函数，改变组件内部的状态
  }

  clickBtnAdd = () => {
    const {num} = this.state;
    this.setState({num: num + 1});
  }
```

#### 模块开发
组件写好之后可以引入到某个功能模块中使用。这里我们可以建一个 TestModule 文件夹来存放模块文件，里面可以建这么几个文件。如下图
![文件结构](https://wx2.sinaimg.cn/mw690/ba56005dgy1fxkcvcd0coj20ia08o755.jpg)
接下来我们一个一个来介绍这几个文件的用处。
其实上面的组件计数器，除了使用 setState 来改变数字还可以使用 Redux 来完成这件事。
接下来就让我们来看看如何使用 Redux 完成
* TestModule.js文件
```js
//import部分省略

class TestModule extends Component {
  constructor(props) {
    super(props);
  }

  _renderTitle = () => {
    return (
      <Text>计数器</Text>
    )
  }

 render() {
    const {num} = this.props.data //从store取得的数据，在reducer里面初始化
    return (
      <View>
        {/*引入计数器组件*/}
        <View style={Style.container}>
          {this._renderTitle()}
          <TestComponent children={'数字: '} />
        </View>
        {/*使用Redux完成的计数器*/}
        <View>
          {this._renderTitle()}
          <Text>{num}</Text>
          <Button title={'-'} color={'red'} onPress={() => this.props.sub(num)} />
          <Button title={'+'} color={'blue'} onPress={() => this.props.add(num)} />
        </View>
      </View>
    );
  }
}

export default connect(
  (state) => ({ //state其实就是store.getState()，得到数据
    data: state.modules[CONSTANTS.NAME]
  }),
  (dispatch) => ({ //dispatch是一个发布器他需要接受一个对象用于触发reducer
    // actions
    add: (num) => dispatch(actions.add(num)),
    sub: (num) => dispatch(actions.sub(num))
  })
)(TestModule);
```
模块的主要页面内容都是写在这个文件里面，这里我们直接从 components 引入了 TestComponent 组件进行使用。直接将组件当成标签名使用 <TestComponent />。这就是自定义组件方便的地方。中间可以看到组件渲染不一定要都放在 render()里面，可以利用一个渲染函数，单独抽出来，这样可以让程序的结构上看起来更加明了，不要让所有的子组件都堆积在 render()函数中。当然如果抽出来的组件内容太少，就没必要抽了。
这个文件的最下面 connect 函数是 Provider 提供的一种 store 注入方式，其中封装了两个函数，第一个函数其实是 store.getState()，是从 store 得到数据的。
第二个函数 dispatch 是一个触发器，在里面写 action 函数来触发 reducer 来对数据进行所需要的操作。dispatch 触发 TestModuleActions.js 里面的函数。下面就介绍一下 TestModuleActions.js 文件
这里我们写了一个加一个减函数，接着在 actions.js 文件里定义这两个 action 函数。

* TestModuleActios.js文件
```js
import {
  ADD,
  SUB
} from './TestModuleConstants';

export const add = (num) => {
  return (dispatch) => {
    dispatch({
      type: ADD, //必填type类型
      payload: {
        num: num
      } //数据传到reducer去处理
    });
  };
};

export const sub = (num) => {
  return (dispatch) => {
    dispatch({
      type: SUB, //必填type类型
      payload: {
        num: num
      } //数据传到reducer去处理
    });
  };
};
```
这个文件主要是写 actions 的文件，定义 action，dispatch中根据 type 类型去 TestModuleReducers.js那处理数据。通过 payload 把数据传到 reducer 里面。

* TestModuleConstants.js文件
```js
export const NAME = 'testmodule';

// action types
export const ADD = `${NAME}/ADD`;
export const SUB = `${NAME}/SUB`;
```
这个文件用来放全局常量。这里定义了ADD和SUB。

* TestModuleReducer.js文件
```js
import {handleActions} from 'redux-actions';
import {ADD, SUB} from './TestModuleConstants';

const initialState = { //初始化数据的地方
  num: 0
};

export default handleActions({ //处理数据的地方
  // actions
  [ADD]: (state, action) => {
    const {num} = action.payload; //action里面传来的值
    return { //返回处理后的数据
      ...state,
      num: num + 1
    };
  },
  [SUB]: (state, action) => {
    const {num} = action.payload; //action里面传来的值
    return { //返回处理后的数据
      ...state,
      num: num - 1
    };
  }
}, initialState);
```
reducer 利用 action.payload 拿到从 action 传来的数据，处理数据，处理完返回。
这里就要说一下Redux的数据流了，请先看一下下图:
![Redux Flow](https://wx3.sinaimg.cn/mw690/ba56005dgy1fxkcvc6dthj20xm0mk77l.jpg)

(图片来自网上)
这里我们在TestModule.js文件中的 connect 中 dispatch(action) ，把原先的计数器中数字 num (图中 previousState )，和 action ( ADD 或 SUB )传到了 reducer 里面，根据 actions 文件里面的 action 的 TYPE 来执行各自的数据处理。处理完之后就有新的 newState 传到 Store，再传到组件中，驱动组件改变状态重新渲染。

* index.js文件
```js
import module from './TestModule';
import reducer from './TestModuleReducer';
import * as actions from './TestModuleActions';
import {NAME} from './TestModuleConstants';

export default {
  NAME,
  module,
  reducer,
  actions
};
```
这个文件将 NAME，module，reducer，actions 暴露出去。

#### 总结
使用 RN+Redux 为基础框架开发已有三个多月，很多东西都还需要多加学习研究，这只是最基础的组件和模块开发。

组件开发总的时间为十的话，一定要思考占七，动手写占三，认真的多思考组件的构造，这样在动手写的时候才能尽量的避免结构的冗余，或者是样式的冗余，而且要想为什么做这个组件，必需能在某个项目中能多次的使用该组件，这样组件的开发才会变得有意义，不然一个组件只用一次的话，就没有必要单独拿出来封装成一个组件。另外就是组件写的过程尽量的思考拓展性，很多结构不要写死了，这次组件可能只需要展示2个 tab，但是下一次就不一定了，所以写的时候要多想。

模块开发的时候，尽量保持结构层次的清晰，这样的话代码的维护就会得比较轻松，模块里有很多独立的功能部分可以单抽出来做成一个渲染函数，这样就能让 render 函数看起来没那么的冗余，且结构不会过于复杂。一些点击事件和逻辑功能也是能单独抽出来写成事件函数，这样的话，调试出问题的时候就可以快速定位到问题代码块。还有就是尽量避免写一些重复的组件，能简化的就简化，可以考虑使用map函数来渲染重复的组件。

虽然这里用 Redux 也实现了计数器，但是其实是杀鸡用牛刀了，这样的简单的数据重新渲染其实大可不必，用 setState 就可以了，当然 Redux 也有其优点，他让数据和我们的组件模块解耦，数据单独处理了，不需要在每一个组件中来对 state 进行管理，需要的数据从上游作为 props 传进来了。不过经常可以看到这么一句话，如果你不知道你为什么需要 Redux，那你就是不需要 Redux..   (=. = redux 对于新手真的有点不友好)

#### 参考
* [Redux 的数据流](https://blog.csdn.net/Helloyongwei/article/details/82937808)
* [看了我这篇 RN 你就入门了](https://www.jianshu.com/p/2a20c8485a90)