title: React-Native 触摸与动画
date: 2016-08-21 12:48:00
categories: lulutia
tags: 
- React Native
- touches
- animation

---
# React-Native触摸
  在移动应用开发中，触摸和动画是不可忽视的两个方面。React-Native针对手势处理，提供了几组API，为基本的点击手势和复杂的滑动等都提供了相应的解决方案。
  相比web端的手势，React-Native应用中的手势要复杂很多。在初次进行React-Native的组件[Picker](https://github.com/xgfe/react-native-picker-xg)封装时，需要涉及到模拟原生iOS滚轮的行为实现，针对这部分需要涉及到React-Native中的触摸实现，此作为选题的初衷。如果刚刚接触要搭建环境balabala，可以参考[基本环境搭建](http://memory.lulutia.com/2016/05/27/RN/)。

<!-- more -->

## Touch 手势
  在web开发中click操作是最常用的一个行为，其对应到移动端的开发中即是touch手势。在web开发中，浏览器内部实现了click事件，我们只需要使用```onclick```或者```addEventListener('click', callback)```来进行click事件的绑定。在React-Native中，其也提供了四个与touch相关的组件来实现基本的touch行为。

### TouchableHighlight
* 本组件用于封装视图，使其可以正确响应触摸操作。当按下的时候，封装的视图的不透明度会降低，同时会有一个底层的颜色透过而被用户看到，使得视图变暗或变亮。
* 在底层实现上，实际会创建一个新的视图到视图层级中。
* ```TouchableHighlight```只支持一个子节点，如果你希望包含多个子组件，用一个View来包装它们
* 本组件继承了所有```TouchableWithoutFeedback```的属性。
	
### TouchableNativeFeedback
* 本组件用于封装视图，使其可以正确响应触摸操作（仅限Android平台）。
* 底层实现上，实际会创建一个新的```RCTView```结点替换当前的子View，并附带一些额外的属性。
* 只支持一个单独的View实例作为子节点。
* 本组件继承了所有```TouchableWithoutFeedback```的属性
	
### TouchableOpacity
* 本组件用于封装视图，使其可以正确响应触摸操作。
* 当按下的时候，封装的视图的不透明度会降低。(此组件与```TouchableHighlight```的区别在于并没有额外的颜色变化，更适于一般场景)
* 本组件继承了所有```TouchableWithoutFeedback```的属性
	
### TouchableWithoutFeedback
* 除非你有一个很好的理由，否则不要用这个组件。(因为此组件对响应触屏操作的元素在触屏后没有任何视觉反馈)
* ```TouchableWithoutFeedback```只支持一个子节点

### 分析
使用以上四个组件我们可以实现一个简单例子如下：

~~~ js
import React, { Component } from 'react';
import {
  AppRegistry,
  StyleSheet,
  Text,
  View,
  TouchableHighlight,
  TouchableWithoutFeedback,
  TouchableNativeFeedback,
  TouchableOpacity 
} from 'react-native';

let start = '';

class touch extends Component {
  _onPressIn(){
     start = Date.now();
     console.log(start);
     console.log("press in")
   };
   _onPressOut(){
     console.log("press out");
     console.log("pressout "+(Date.now()-start))
   };
   _onPress(){
     console.log("press")
   };
   _onLonePress(){
     console.log("long press "+(Date.now()-start))
   };
  render() {
    console.log("begin render");
    return (
     <View style={styles.container}>
        <TouchableWithoutFeedback
         style={styles.touchable}
        onPressIn={this._onPressIn}
        onPressOut={this._onPressOut}
        onPress={this._onPress}
        onLongPress={this._onLonePress}>
          <View style={[styles.button, styles.test1]}>
          <Text>TouchableWithoutFeedback</Text></View>
        </TouchableWithoutFeedback>

        <TouchableNativeFeedback
       ......
         >
          <View style={[styles.button, styles.test2]}>
          <Text>TouchableNativeFeedback</Text></View>
        </TouchableNativeFeedback>

        <TouchableOpacity 
       ......
         >
          <View style={styles.button}>
          <Text>TouchableOpacity</Text></View>
        </TouchableOpacity>

        <TouchableHighlight
        ......
         >
          <View style={styles.button}>
          <Text>TouchableHighlight</Text></View>
        </TouchableHighlight>
      </View>
    );
  }
}
......
AppRegistry.registerComponent('touch', () => touch);

~~~

上面代码中，我们将一个View作为容器，然后分别设置了四个view作为按钮，为了给按钮绑定touch手势，我们将上述四个和touch相关的组件分别作为按钮的包裹层。效果如下：

![](https://raw.githubusercontent.com/lulutia/images/master/reactnative-touch/init.png)

上面代码中，我们分别为每个组件绑定了以下四个方法(这四个方法是React-Native帮助用户实现的):

* onPress
* onPressIn
* onPressOut
* onLongPress

当我们分别点击这四个按钮是，会发生以下几个事情：

![](https://raw.githubusercontent.com/lulutia/images/master/reactnative-touch/show.png)

* 在模拟机上```TouchableWithoutFeedback```和```TouchableOpacity```进行快速点击会触发整个pressIn -> pressOut -> press过程。
* 在模拟机上```TouchableNativeFeedback```和```TouchableHight```进行快速点击则会在pressIn -> pressOut -> press过程和直接press中不定期切换。

![](https://raw.githubusercontent.com/lulutia/images/master/reactnative-touch/strange.png)

* 在真机上，所有的按钮均会触发整个press in -> press out ->press过程。

针对以上情况，我们通过打点计时的方式可以看出以下几点:

* 对于```TouchableNativeFeedback```和```TouchableHight```，当pressIn和pressOut的时间差小于某个阈值的时候会直接触发press事件。而```TouchableWithoutFeedback```和```TouchableOpacity```似乎不存在这个阈值，或者说至少这个阈值相当容易超过。简单而言，对于快速点击的“快”，这几个组件的内部处理估计有所差异。
* 对```TouchableNativeFeedback```和```TouchableHight```的touch与对```TouchableWithoutFeedback```和```TouchableOpacity```的touch的反应速度是不一样的。
* 模拟机的反应速度与真机的反应速度存在一定的差距。
* 在进行事件绑定时如果对```TouchableNativeFeedback```和```TouchableHight```只进行pressIn或者pressOut的绑定，则实际上有可能是不会触发的。
* 在对这几个组件点击时有一个比较明显的“按”的操作，则一定会触发pressIn事件，如果绑定了longPress事件，则同时会触发longPress事件，此时不会触发press事件，此时的流程是pressIn -> longPress -> pressOut。如果没有绑定longPress事件，则会触发press事件，此时的流程是pressIn -> pressOut -> press。


以上情况主要是针对“点击态”进行分析，但实际上原生应用还有一个很重要的部分即：选择中途撤销触摸事件。最简单的例子是，我们按住了一个按钮，此时我们改变主意并不想按这个按钮了，我们可以比平时多按一会儿，接着将手指划开，此时就撤销了刚才的事件，就像我们根本没点击过一样。我们对上述组件分别进行此操作均得出结果如下：

![](https://raw.githubusercontent.com/lulutia/images/master/reactnative-touch/move.png)

* 如果同时绑定了pressIn, pressOut和press事件， 并且没有绑定longPress事件，则当pressIn事件触发后，如果用户的手指在绑定的组件中释放，那么会连续触发pressIn -> pressOut ->press事件，如果用户的手指是在绑定的组件外部释放，则在手指移出边界的瞬间就会触发pressOut事件，并且此时不会触发press事件，相当于操作被取消了。
* 如果在绑定了pressIn, pressOut, press的同时还绑定了longPress事件，则用户的手指在绑定的组件中释放会触发事件的流程是pressIn -> longPress -> pressOut， 如果用户的手指是在绑定的组件外部释放，则其触发的事件流程为pressIn -> longPress ->pressOut(在移出的瞬间触发)。
* 通过打点计时会发现，longPress的触发也呈现出```TouchableNativeFeedback```和```TouchableHight```比较接近，```TouchableWithoutFeedback```和```TouchableOpacity```比较接近的特征。

## gesture responder system
对于大部分交互来说，可以运用上述的四个touch组件进行实现，但是如果交互比较复杂，则需要引入React-Native的gesture responder system

### responder
是React-Native中响应手势的基本单位。具体来说，就是view组件，任何一个view组件都是一个潜在的responder。在一个React-Native应用中只能存在一个responder。

### responder如何响应手势操作
* 激活某个responder由```onStartShouldSetResponder```以及```onMoveShouldSetResponder```两个方法来操作，当用户通过触摸或者滑动来开始事件时，上面两个方法需要返回true。
* 如果组件被激活，此时```onResponderGrant```方法被调用。为了良好的反馈，此时最好去改变组件的颜色或者透明度来提示用户此组件被激活了。
* 用户滑动手指，```onResponderMove```方法被调用。
* 用户的手指离开屏幕，```onResponderRelease```方法被调用，此时组件其自身样式复原以提示操作完成。
* 到现在为止，整个流程为: 响应touch或者move手势 -> grant被激活 -> move -> release

示例代码如下(当然这里代码写的比较随意，但功能是能实现的)：

~~~ js
import React, { Component } from 'react';
import {
  AppRegistry,
  StyleSheet,
  Text,
  View
} from 'react-native';

let gestureHandlers = {};

class touch extends Component {
  constructor(props, context) {
    super(props, context);
    this.config = {
      changeX: 0,
      changeY: 0,
      xDiff: 0,
      yDiff: 0
    }
    this.state = {
      bg: 'white',
      left: 0,
      top: 0
    }
  }
  componentWillMount(){
    gestureHandlers = {
    onStartShouldSetResponder: (e) => {
      console.log(e.nativeEvent); 
      console.log("start");
      return true
    },
    onMoveShouldSetResponder: (e) => {console.log("move begin"); return true},
    onResponderGrant: (e) => {
      console.log("grant");
      this.config.changeY = e.nativeEvent.pageY;
      this.config.changeX = e.nativeEvent.pageX;
      this.setState({bg: 'red'});
    },
    onResponderMove: (e) => {
      console.log("moving"); 
      this.config.yDiff = e.nativeEvent.pageY - this.config.changeY;
      this.config.xDiff = e.nativeEvent.pageX - this.config.changeX;
      this.state.left = this.state.left + this.config.xDiff;
      this.state.top = this.state.top + this.config.yDiff;
      this.config.changeY = e.nativeEvent.pageY;
      this.config.changeX = e.nativeEvent.pageX;
      this.setState({left: this.state.left, top: this.state.top});
    },
    onResponderRelease: (e) => {console.log("release"); this.setState({bg: 'white'})}
  }
}
 
  render() {
    console.log("begin render");
    return (
     <View style={styles.container}>
      <Text>Begin</Text>
       <View
         {...gestureHandlers}
         style={[styles.rect, {
          "backgroundColor": this.state.bg,
          "left": this.state.left,
          "top": this.state.top        
         }]}>
       </View>
      </View>
    );
  }
}

const styles = StyleSheet.create({
 container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#F5FCFF',
  },
  rect: {
    width: 200,
    height: 200,
    borderWidth: 1,
    borderColor: 'black',
    position: 'absolute'
  }
});

AppRegistry.registerComponent('touch', () => touch);
~~~

在上面这段代码中，其执行顺序如下：

* 界面初次渲染
* 当我们点击白色的正方形时，会调用```onStartShouldSetResponder```方法，此时返回true，表示其被激活
* 因为其被激活，所以调用```onResponderGrant```方法，颜色变为红色，记录touch相对于root element的位置，然后重新渲染
* 开始移动，调用```onResponderMove```方法，计算移动的距离，改变布局，然后重新渲染 (此过程会不断重复)
* 手指松开，调用```onResponderRelease```方法，颜色变白，重新渲染，事件结束

在上述的几个方法中，都提供了一个参数evt，evt是一个touch事件，其下面的nativeEvent是一个对象，里面记录的信息对于进行复杂手势的合成相当有用。具体而言它主要提供了下述信息：

* changedTouches: 一个数组保存着自上次事件后所有有变化的touch事件
* identifier: touch的ID
* locationX: 相对于当前元素的touch的X位置
* locationY: 相对于当前元素的touch的Y位置
* pageX: 相对于根元素的touch的X位置
* pageY: 相对于根元素的touch的Y位置
* target: 接受touch事件的元素的节点id
* timestamp: touch的时间标示
* touches: 一个数组保存着现在屏幕上的所有touch

### 处理冲突
#### 情况一
考虑一个情况，应用中存在多个responder，已经激活了一个而且没释放时又想去激活另外一个，注意在一个React-Native应用中只能存在一个responder。所以此时，就存在一个协商的过程。对于这种情况，React-Native提供了一个```onResponderTerminationRequest```方法。

* 已经激活的responder不愿意放弃主动权，此时```onResponderTerminationRequest```返回false，待激活的responder的```onResponderReject```方法会被调用，其保持不被激活的状态进行等待

![](https://raw.githubusercontent.com/lulutia/images/master/reactnative-touch/release.png)

* 已经激活的responder愿意放弃主动权，此时```onResponderTerminationRequest```返回true，待激活的responder的```onResponderGrant```方法会被调用变为激活状态，而之前激活的responder的```onResponderTerminate```方法会被调用，其被释放。

![](https://raw.githubusercontent.com/lulutia/images/master/reactnative-touch/release2.png)

* 注意这种responder锁的转移只能在increasingly "higher" views上执行，即现在responder的祖先元素上。
* 现阶段这部分有个[onResponderGrant called before onResponderTerminate的问题](https://github.com/facebook/react/issues/6217)，因为在实现方式上有所争议，所以如果使用这两个方法最好注意下顺序的问题。
* Touch starts，moves，scolls能够生成一个responder的ID。
* 通过capture/bubble来```startShouldSetResponder```/```moveShouldSetResponder``` 一个合适的地方。
* 如果当前没有responder，那么这个合适的地方就是初始事件的targetID。
* 协商过程发生，具体如下图所示。
* 滚动的views会自动成为responder。因为不是构建在responer system基础上的平台层面的滚动view开始后，激活状态的responder必须被告知现在responder锁并不在其上了，系统已经接管了。
* 注意在responder的转移过程中，如果之前sponder手势没有释放，则此时虽然新的responder可以触发，也没法释放(因为此时没释放的touch处于现在responder的后代元素里)。```onResponderRelease```事件会在当前responder的实例及其后代都没touch时触发，并且释放掉responder锁。

总的流程图：

	~~~ 
	    Negotiation Performed
	                                             +-----------------------+
	                                            /                         \
	Process low level events to    +     Current Responder      +   wantsResponderID
	determine who to perform negot-|   (if any exists at all)   |
	iation/transition              | Otherwise just pass through|
	-------------------------------+----------------------------+------------------+
	Bubble to find first ID        |                            |
	to return true:wantsResponderID|                            |
	                               |                            |
	     +-------------+           |                            |
	     | onTouchStart|           |                            |
	     +------+------+     none  |                            |
	            |            return|                            |
	+-----------v-------------+true| +------------------------+ |
	|onStartShouldSetResponder|----->|onResponderStart (cur)  |<-----------+
	+-----------+-------------+    | +------------------------+ |          |
	            |                  |                            | +--------+-------+
	            | returned true for|       false:REJECT +-------->|onResponderReject
	            | wantsResponderID |                    |       | +----------------+
	            | (now attempt     | +------------------+-----+ |
	            |  handoff)        | |   onResponder          | |
	            +------------------->|      TerminationRequest| |
	                               | +------------------+-----+ |
	                               |                    |       | +----------------+
	                               |         true:GRANT +-------->|onResponderGrant|
	                               |                            | +--------+-------+
	                               | +------------------------+ |          |
	                               | |   onResponderTerminate |<-----------+
	                               | +------------------+-----+ |
	                               |                    |       | +----------------+
	                               |                    +-------->|onResponderStart|
	                               |                            | +----------------+
	Bubble to find first ID        |                            |
	to return true:wantsResponderID|                            |
	                               |                            |
	     +-------------+           |                            |
	     | onTouchMove |           |                            |
	     +------+------+     none  |                            |
	            |            return|                            |
	+-----------v-------------+true| +------------------------+ |
	|onMoveShouldSetResponder |----->|onResponderMove (cur)   |<-----------+
	+-----------+-------------+    | +------------------------+ |          |
	            |                  |                            | +--------+-------+
	            | returned true for|       false:REJECT +-------->|onResponderRejec|
	            | wantsResponderID |                    |       | +----------------+
	            | (now attempt     | +------------------+-----+ |
	            |  handoff)        | |   onResponder          | |
	            +------------------->|      TerminationRequest| |
	                               | +------------------+-----+ |
	                               |                    |       | +----------------+
	                               |         true:GRANT +-------->|onResponderGrant|
	                               |                            | +--------+-------+
	                               | +------------------------+ |          |
	                               | |   onResponderTerminate |<-----------+
	                               | +------------------+-----+ |
	                               |                    |       | +----------------+
	                               |                    +-------->|onResponderMove |
	                               |                            | +----------------+
	                               |                            |
	                               |                            |
	      Some active touch started|                            |
	      inside current responder | +------------------------+ |
	      +------------------------->|      onResponderEnd    | |
	      |                        | +------------------------+ |
	  +---+---------+              |                            |
	  | onTouchEnd  |              |                            |
	  +---+---------+              |                            |
	      |                        | +------------------------+ |
	      +------------------------->|     onResponderEnd     | |
	      No active touches started| +-----------+------------+ |
	      inside current responder |             |              |
	                               |             v              |
	                               | +------------------------+ |
	                               | |    onResponderRelease  | |
	                               | +------------------------+ |
	                               |                            |
	                               +                            + *
	
  ~~~

#### 情况二

再考虑一个情况，```onStartShouldSetResponder```和```onMoveShouldSetResponder```都遵循冒泡机制，最顶部的responder会进行事件响应。这就意味着当有多个view对于```*ShouldSetResponder```返回true时，实际上是最顶层的组件将会成为被激活的responder，但如果我们不希望这样呢，此时我们希望自定义响应事件的responder。React-Native针对此种情况提供了```onStartShouldSetResponderCapture```和```onMoveShouldSetResponderCapture```两个方法。当我们希望的responder的这两个方法中任意一个返回true时，即使它并不在最顶层，唯一一个responder的位置也会被它占据。


~~~ js
...
class touch extends Component {
  constructor(props, context) {
    super(props, context);
    this.state = {
      bg: 'red',
      bg1: 'pink'
    }
  }
  componentWillMount(){
    this.gestureHandlers = {
      onStartShouldSetResponder: (e) => {
        console.log("start");
        return true
    },
      onMoveShouldSetResponder: (e) => {console.log("move begin"); return true},
      onResponderGrant: (e) => {
        console.log("grant");
        this.setState({bg: 'orange'});
    },
      onResponderMove: (e) => {
        console.log("moving"); 
    },
      onResponderRelease: (e) => {
        console.log("release"); 
        this.setState({bg: 'red'})
      }
      //最关键的两句：加上下面两句则响应者会变化
      onStartShouldSetResponderCapture: () => true,
      onMoveShouldSetResponderCapture: ()=> true

  };

  this.gestureHandlers2 = {
      onStartShouldSetResponder: (e) => {
        console.log("start1");
        return true
    },
      onMoveShouldSetResponder: (e) => {console.log("move begin"); return true},
      onResponderGrant: (e) => {
        console.log("grant1");
        this.setState({bg1: 'red'});
    },
      onResponderMove: (e) => {
        console.log("moving1"); 
    },
      onResponderRelease: (e) => {
        console.log("release1"); 
        this.setState({bg1: 'pink'})
      },

  };
}
 
  render() {
    return (
     <View style={styles.container}>
       <View 
        {...this.gestureHandlers}
        style={[styles.rectBig, {
          "backgroundColor": this.state.bg
        }]}>
        <View
         {...this.gestureHandlers2}
         style={[styles.rect,  {
          "backgroundColor": this.state.bg1    
         }]}>
        </View>
        </View>
      
        </View>
    );
  }
}

const styles = StyleSheet.create({
 container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#F5FCFF',
  },
  rect: {
    width: 100,
    height: 100,
   
  },
  rectBig: {
    width: 200,
    height: 200,
    justifyContent: 'center',
    alignItems: 'center',
  }
});

AppRegistry.registerComponent('touch', () => touch);
~~~

### 其他注意点
* ```onResponderRelease```方法其实响应的是touchUp，这就意味着它只监听手指的抬起，对于组件上的越界等并没有监测。所以如果在触发的responder上进行滑动，手指划出其边界后继续滑动如果不进行判定的话，并不会自动拦截事件。
* e.nativeEvent其中的pageX和pageY在滑动时是会实时变化的，但是locationX和locationY并不会。
* 如果组件一设置了```onStartShouldSetResponder```与```onResponderTerminationRequest```返回true，组件二设置了```onMoveShouldSetResponder```，则在组件一中点击且滑动会触发组件二的行为。因此要特别注意```onStartShouldSetResponder```与```onMoveShouldSetResponder```的同时使用。

## PanResponder
PanResponder是React－Native提供的一套抽象方法，和gesture responder system比起来，其抽象程度更高，使用起来更加方便。具体的说它在基本的evt参数之外，还提供了另外一个参数gestureState。gestureState是一个对象，包含了以下信息：

* stateID: gestureState的ID，在屏幕上保持至少一个触发动作的时间
* moveX: 最近动态触发的最新的屏幕坐标
* x0: 应答器横向的屏幕坐标
* y0: 应答器纵向的屏幕坐标
* dx: 触发开始后累积的横向动作距离
* dy: 触发开始后累积的纵向动作距离
* vx: 当前手势的纵向速度
* vy: 当前手势的纵向速度
* numberActiveTouch: numberActiveTouch

PanResponder可以将几个触发调节为一个单一的触发动作，可以用来识别简单的多点触发动作。
我们来举个栗子～尝试实现一个基于React-Native的多点触摸的Zoom的功能，这里只是为了说明功能而进行的简单示例，要实现一个性能功能完好的Zoom还是不容易滴。

~~~js
import React, { Component } from 'react';
import {
  AppRegistry,
  StyleSheet,
  Text,
  PanResponder,
  View
} from 'react-native';

class touch extends Component {
  constructor(props, context) {
    super(props, context);
    this.state = {
        bg: 'red',
        bg1: 'pink',
        width: 300,
        height: 300,
        distant: 0,
    }
  }
  componentWillMount(){
    this.gestureHandlers = PanResponder.create({
      onStartShouldSetPanResponder: this._handleStartShouldSetPanResponder.bind(this),
      onMoveShouldSetPanResponder: this._handleMoveShouldSetPanResponder.bind(this),
      onPanResponderGrant: this._handlePanResponderGrant.bind(this),
      onPanResponderMove: this._handlePanResponderMove.bind(this),
      onPanResponderRelease: this._handlePanResponderEnd.bind(this),
      onPanResponderTerminate: this._handlePanResponderEnd.bind(this),
    })
}

  _handleStartShouldSetPanResponder(e, gestureState){
    console.log("start" + " " + gestureState.numberActiveTouches);
    return gestureState.numberActiveTouches === 2;
  }
 
  _handleMoveShouldSetPanResponder(e, gestureState){
    console.log("move start" + " " + gestureState.numberActiveTouches);
    return gestureState.numberActiveTouches === 2;
  }

  _handlePanResponderGrant(e, gestureState){
    console.log("grant" + " " + gestureState.numberActiveTouches);
    if (gestureState.numberActiveTouches === 2) {
      this.setState({bg: 'orange'});
    }
  }

  _handlePanResponderEnd(e, gestureState){
    this.setState({bg: 'red'});
    console.log(gestureState);
  }
  
  _handlePanResponderMove(e, gestureState){
    console.log(gestureState.numberActiveTouches + " " + e.nativeEvent.touches.length);
    if (gestureState.numberActiveTouches === 2) {
          this.setState({bg: 'orange'});
          var dx = Math.abs(e.nativeEvent.touches[0].pageX - e.nativeEvent.touches[1].pageX);
          var dy = Math.abs(e.nativeEvent.touches[0].pageY - e.nativeEvent.touches[1].pageY);
          var distant = Math.sqrt(dx*dx + dy*dy);
          if (distant > this.state.distant) {
            console.log("bigger");
          } else {
            console.log("smaller");
          }
          this.setState({distant: distant});
        }
  }

  render() {
    return (
     <View style={styles.container}>
       <View 
        {...this.gestureHandlers.panHandlers}
        style={[styles.rectBig, {
          "backgroundColor": this.state.bg,
          "width": this.state.width,
          "height": this.state.height
        }]}>
        </View> 
    </View>
    );
  }
}

const styles = StyleSheet.create({
 container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#F5FCFF',
  },
  rectBig: {
    justifyContent: 'center',
    alignItems: 'center',
  }
});

AppRegistry.registerComponent('touch', () => touch);
~~~
结果如下：

![](https://raw.githubusercontent.com/lulutia/images/master/reactnative-touch/multiple.png)

通过代码可以看出：

* 在```onStartShouldSetPanResponder```方法里我们判断了激活的touches的数量，我们希望Zoom是由两个触发源共同构建的，所以只有当前界面touches为2时才会返回true，也才会触发```onPanResponderGrant```方法。
* 接着在```onPanResponderGrant```方法里，我们改变背景色，注意提供用户友好的touch反馈是值得推荐的。
* 接下去，当我们移动时，触发```onPanResponderMove```方法，我们可以通过evt.nativeEvent.touches获取两个触发源及其位置。然后我们计算它们的相对位置，只要两者之间的距离缩短则表示缩小，两者的距离扩大则表示放大。[以上可以通过log看出大小变化，实际的放大缩小还需要实时变换style来实现]
* 这里注意，当我们在```onStartShouldSetPanResponder```里返回true后```onPanResponderGrant```方法调用，且```onPanResponderRelease```没调用时，我们增加触发源并不会调用```onStartShouldSetPanResponder```。相反，只要```onStartShouldSetPanResponder```没返回true，每增加一个触发源都会调用```onStartShouldSetPanResponder```。

### 其他注意点
* 如果触发源比较多，我们可以使用evt.nativeEvent.touches[i].identifier来进行标示
* 通过gestureState.vx和gestureState.vy，我们可以更好的模拟物理世界，为我们结合动画的制作提供了便利。
* 模拟机上快速点击(比如触摸板上的快速点击)，触发整个流程的速度特别快，中间过程的变化可能肉眼看不出来(比如```onPanResponderGrant```颜色改变之后又```onPanResponderRelease```复原这种)。
* *如果是带borderRadius样式的元素绑定事件，其原有区域也能触发事件(关于这部分没找到特别好的解决办法，react native自带的四种组件也会有这个问题)。*
* React-Native的触摸都是在JS线程里面进行的，而原生的都是在UI线程上进行的，所以不可避免的运用React-Native来实现触摸性能上不如原生的。

# React－Native动画
上面介绍的主要是React－Native的触摸部分，对于手机应用而言，除了触摸之外，动画也是相当重要的一部分，并且触摸加动画能够实现很多很赞的效果，接下来我们就来看下React-Native中的动画。总的来说，React-Native中关于动画有三个系统，分别为Animated，LayoutAnimation，导航器场景切换(此部分与具体组件层面挂钩，这里暂时不做讨论)。
## Animated
### 用途
用于创建更精细的交互控制的动画
### 特点
* 容易实现各种动画和交互
* 具备极高的性能
* 仅关注动画的输入和输出声明
* 配置是声明式的，序列化好配置，可在高优先级的线程执行动画
* 动画的顺序执行由start/stop方法来控制

### 核心API
Animated提供了三个动画组件，分别是Animated.View, Animated.Text, Animated.Image

* 值类型：
	* Value：用于单个值
		* new Animated.Value(0): 可以作为属性传递给动画组件，但属性只能收取基本类型的值
		* setVAlue: new Animated.Value()实例上的方法，允许外部代码控制实例内部的值并且不触发中间状态的动画，如果中间使用了插值计算则会得到正确的值但依然不会触发动画
		* interpolate: 插值计算时使用(注意其中的inputRange必须是升序)
			* clamp: 不会超过边界值
			* identity: 超过边界值后直接变为input的值
			* extend(default): 会超过边界值
			* 注意用插值进行颜色转换时对hex没用，只对rgb, rgba, hsl和其他数字格式。
			* 插值还可以进行角度转换比如```outputRange['0deg`, `15deg`]```，也可运用```outputRange: ['0rad`, `0.0872665rad`]```，1弧度大概等于57.2958度。		
    		
        ~~~js
    		this._animatedValue = new Animated.ValueXY();
    		this._opacityAnimation = this._animatedValue.x.interpolate({
    		    inputRange: [0, 150],
    		    outputRange: [1, .2],
    		    extrapolate: 'clamp'
    		});
    		~~~
		* addListener: 动画是异步的，但可以通过此方法监听动画值的改变，但记得不使用时remove掉
		* removeListener: 取消监听，传入的参数是addListener返回的string

    		~~~js
    		this._animatedValue = new Animated.Value(0);
    		var animatedListenerId = this._animatedValue.addListener(({value}) => this._value = value);
    		this._animatedValue.removeListener(animatedListenerId);
    		~~~
		* removeAllListeners: 取消所有监听
		* stopAnimation: 终止动画，回调里面有当前动画停止时的值
		
	* ValueXY：用于向量值，一般要处理位置或者手势时使用
		* new Animated.ValueXY(): 初始值是{x:0, y:0}
		* getLayout: 将{x, y}转换为{left, top}以便用于style，当使用这个方法时，组件的position必须为absolute
		* getTranslateTransform: 将一个{x, y} 组合转换为一个可用的位移变换(translation transform), 不必关心其现在的布局
		* setOffset: 在设定的值上的偏移
		* flattenOffset: 获取offset内的值并将它加到animated value的base上然后重置offset为0
* 动画类型：
	* spring(friction:摩擦力{7}, tension:张力{40}): 基础的单次弹跳物理模型
	* decay(velocity:起始速度, deceleration:速度衰减比例{0.997}): 以一个初始速度开始并且逐渐减慢停止，此部分与PanResponder很好结合
	
  	~~~js
  	this._animatedValue = new Animated.ValueXY();

  	Animated.decay(this._animatedValue, {   // coast to a stop
  	    velocity: {x: gestureState.vx, y: gestureState.vy}, // velocity from gesture release
  	    deceleration: 0.997,
  	})
    ~~~
	* timing(duration:动画持续时间{500毫秒}, easing:渐变函数，delay:延迟开始动画{0}): 时间范围映射到渐变的值 [easing可以选择的值](https://github.com/facebook/react-native/blob/master/Libraries/Animated/src/Easing.js)
	
### 动画过程
* 动画开始: 调用start方法(里面允许回调，因此可以实现循环动画，这里使用了interpolate实际只有一个变量)

~~~js
_rotateTime() {
    this._animatedValue.setValue({x:0,y:0});
    Animated.timing(this._animatedValue, {
      toValue: 360,
      duration: 1500,
      easing: Easing.linear
    }).start(() => {this._rotateTime()});
  }
~~~

![](https://raw.githubusercontent.com/lulutia/images/master/reactnative-touch/doge.gif)

* 动画正常结束: 回调函数调用时的参数为{finished: true}
* 动画正常结束之前调用stop结束: 回调函数调用时的参数为{finished: false}

### 组合动画
* parallel(同时执行)
* sequence(顺序执行)

~~~js
this._opacityAnimationValue = new Animated.Value(1);
this._moveAnimationValue = new Animated.ValueXY();
Animated.sequence([
    Animated.timing(this._moveAnimationValue, {
        toValue: 100,
        duration: 500
    }),
    Animated.timing(this._opacityAnimationValue, {
        toValue: 0,
        duration: 200
    })
]).start()
<Animated.View style={{opacity: this._opacityAnimationValue, transform: this._moveAnimationValue.getTranslateTransform()}} />
~~~

* stagger(错峰执行)

~~~js
this._opacityAnimationValue = new Animated.Value(1);
this._moveAnimationValue = new Animated.ValueXY();
Animated.stagger(100, [
    Animated.timing(this._moveAnimationValue, {
        toValue: 100,
        duration: 500
    }),
    Animated.timing(this._opacityAnimationValue, {
        toValue: 0,
        duration: 200
    })
]).start()
<Animated.View style={{opacity: this._opacityAnimationValue, transform: this._moveAnimationValue.getTranslateTransform()}} />
~~~

* delay(延迟执行)
* 默认情况下，如果任何一个动画被停止或中断了，组内所有其它的动画也会被停止。Parallel有一个stopTogether属性，如果设置为false，可以禁用自动停止

### Animated.event输入事件
* 允许手势或其他事件直接绑定到动态值上
* 结构化的映射语法，使得复杂事件对象中的值被正确的解开

~~~js
onScroll={Animated.event(
  [{nativeEvent: {contentOffset: {x: scrollX}}}]   // scrollX = e.nativeEvent.contentOffset.x
)}
onPanResponderMove={Animated.event([
  null,                                          // 忽略原生事件
  {dx: pan.x, dy: pan.y}                         // 从gestureState中解析出dx和dy的值
]);
~~~
### 创建动画组件
* 原生支持的组件类型： View Text Image
* 将其他组件转换为Animated组件：createAnimatedComponent

~~~js
var AnimatedScrollView = Animated.createAnimatedComponent(ScrollView)
~~~
### 动画结合PanResponder
我们继续来举个栗子

~~~js
import React, { Component } from 'react';
import {
  AppRegistry,
  StyleSheet,
  Text,
  View,
  PanResponder,
  Animated,
  Dimensions
} from 'react-native';

var {
  height: deviceHeight,
  width: deviceWidth
} = Dimensions.get('window');

class touch extends Component{

  componentWillMount() {
    this._animatedValue = new Animated.ValueXY()
    this._value = {x: 0, y: 0}

    this._animatedValue.addListener((value) => this._value = value);
    this._panResponder = PanResponder.create({
      onStartShouldSetPanResponder: this._handleStartShouldSetPanResponder.bind(this),
      onMoveShouldSetPanResponder: this._handleMoveShouldSetPanResponder.bind(this),
      onPanResponderGrant: this._handlePanResponderGrant.bind(this),
      onPanResponderMove: Animated.event([
        null, {dx: this._animatedValue.x, dy: this._animatedValue.y}
      ]),
      onPanResponderRelease: this._handlePanResponderEnd.bind(this),
      onPanResponderTerminate: this._handlePanResponderEnd.bind(this),
      });
  }

  _handleStartShouldSetPanResponder(e, gestureState){
    return true;
  }

  _handleMoveShouldSetPanResponder(e, gestureState){
    return true;
  }

  _handlePanResponderGrant(e, gestureState){
    this._animatedValue.setOffset({x: this._value.x, y: this._value.y});
    this._animatedValue.setValue({x: 0, y: 0});
  }

  _handlePanResponderEnd(e, gestureState){
    Animated.spring(this._animatedValue, {
      toValue: 0,
      tension: 80
    }).start();
  }

  
  render() {
    var interpolatedColorAnimation = this._animatedValue.y.interpolate({
      inputRange: [- deviceHeight, deviceHeight],
      outputRange: ['rgba(225,0,0,1)', 'rgba(225,0,225,1)'],
      extrapolate: 'clamp'
    });

    var interpolatedRotateAnimation = this._animatedValue.x.interpolate({
      inputRange: [0, deviceWidth/2, deviceWidth],
      outputRange: ['-360deg', '0deg', '360deg']
    });

    return (
      <View style={styles.container}>
        <Animated.View 
          style={[
              styles.box, 
              {
                transform: [
                  {translateX: this._animatedValue.x},
                  {translateY: this._animatedValue.y},
                  {rotate: interpolatedRotateAnimation}
                ],
                backgroundColor: interpolatedColorAnimation
              }
            ]} 
            {...this._panResponder.panHandlers} 
          />
      </View>
    );
  }
}

var styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center'
  },
  box: {
    width: 100,
    height: 100
  }
});


AppRegistry.registerComponent('touch', () => touch);
~~~
上面例子实现的就是随着我们手指的移动，方块的位置和颜色及旋转角度都会发上变化。当然结合PanResponder和Animated还可以创造出很多效果，这个就留个大家自己去玩了吧。

![](https://raw.githubusercontent.com/lulutia/images/master/reactnative-touch/animation3.gif)


*注意：如果用真机调试，在执行动画时可能会发现最后的复位相当的卡，那是因为你开启了远程调试，关掉就是正常速度了。虚拟机上没这个问题。*
## LayoutAnimation
### 用途
在全局范围内创建和更新动画，这些动画会在下一次渲染或布局周期运行
### 特点
* 常用来更新flexbox的布局
* 对动画本身粒度控制没有Animated等细
* 无需测量或者计算特定属性就能产生动画
* 如果要在Android上使用LayoutAnimation，那么目前还需要在UIManager中启用

~~~js
if (Platform.OS === 'android') {
  UIManager.setLayoutAnimationEnabledExperimental(true)
}
~~~

### 具体使用
* 调用```LayoutAnimation.configureNext```, 然后调用setState。
我们来继续举个栗子～～

~~~js
import React, { Component } from 'react';
import {
  AppRegistry,
  StyleSheet,
  Text,
  View,
  TouchableOpacity,
  Platform,
  LayoutAnimation,
  UIManager
} from 'react-native';
if (Platform.OS === 'android') {
  UIManager.setLayoutAnimationEnabledExperimental(true)
}
var CustomLayoutAnimation = {
  duration: 200,
  create: {
    type: LayoutAnimation.Types.linear,
    property: LayoutAnimation.Properties.opacity,
  },
  update: {
    type: LayoutAnimation.Types.easeInEaseOut,
  },
};

class touch extends Component {
  constructor() {
    super();
    this.state = {
      index: 0,
    }
  }

  onPress(index) {
    LayoutAnimation.configureNext(LayoutAnimation.Presets.spring);
    //LayoutAnimation.configureNext(CustomLayoutAnimation);
    this.setState({index: index});
  }

  renderButton(index) {
    return (
      <TouchableOpacity key={'button' + index} style={styles.button} onPress={() => this.onPress(index)}>
        <Text>{index}</Text>
      </TouchableOpacity>
    );
  }

  render() {
    var leftStyle = this.state.index === 0 ? {flex: 1} : {width: 20};
    var middleStyle = this.state.index === 2 ? {width: 20} : {flex: 1};
    var rightStyle = {flex: 1};

    return (
      <View style={styles.container}>
        <View style={styles.topButtons}>
          {this.renderButton(0)}
          {this.renderButton(1)}
          {this.renderButton(2)}
        </View>
        <View style={styles.content}>
          <View style={{flexDirection: 'row', height: 50}}>
            <View style={[leftStyle, {backgroundColor: '#f1c40f'}]}/>
            <View style={[middleStyle, {backgroundColor: '#e67e22'}]}/>
            <View style={[rightStyle, {backgroundColor: '#e74c3c'}]}/>
          </View>
        </View>
      </View>
    );
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#34495e',
  },
  topButtons: {
    marginTop: 22,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    alignSelf: 'stretch'
  },
  button: {
    flex: 1,
    height: 30,
    alignSelf: 'stretch',
    backgroundColor: 'white',
    alignItems: 'center',
    justifyContent: 'center',
    margin: 8
  },
  content: {
    flex: 1,
    alignSelf: 'stretch',
    marginTop: 100
  }
});

AppRegistry.registerComponent('touch', () => touch);
~~~

![](https://raw.githubusercontent.com/lulutia/images/master/reactnative-touch/animation.gif)
![](https://raw.githubusercontent.com/lulutia/images/master/reactnative-touch/animation2.gif)

* ```LayoutAnimation.configureNext```可以接收一个config参数，在iOS平台下还可以接收一个onAnimationDidEnd的回调来提示动画已经完成。同样，在iOS平台下还会有一个onError的回调来提示错误。
* 上述的config用来配置动画的属性，具体参数如下：
	* duration: 动画时间
	* create: 新views下的动画配置
	* update: views更细状况下的动画配置
* 程序内部会对config的type进行监测，现阶段支持以下几个：[spring, linear, easeInEaseOut, easeIn, easeOut, keyboard]
* 程序内部也会对property进行监测，现阶段支持opacity与scaleXY两个。

## 具体分析(基于Christopher Chedeau的演讲)
**这部分主要基于react native animated的作者Christopher Chedeau的演讲，后面也附有链接地址，大家想练练听力的话可以去瞅瞅[doge之微笑]**

* 让我们回归动画的本质，试想下一个最基本的最简单的最暴力的动画的形成
	* React native有一个```requestAnimationFrame(fn)```方法用来执行在一段时间内控制视图动画的代码，它会在每刷新一帧后调用一次，和```setTimeout(fn, 0)```有点类似
	* 所以，如果我们在每帧刷新后触发一个onChange函数然后把动画变化的值修改并传递过去就行了，就像下面这样
	
	~~~js
		getInitialState() {
		    return {left: 0};
		  }
	  	render() {
	    	return (
	      	<div style={{left: this.state.left}}>
	        	<Child />
	      	</div>
	      	);
	  	}
	  	onChange(value) {
	    	this.setState({left: value});
	  	}
	~~~

	* 但是！上面这种做法会有一个问题，对div的setState会同时导致其子元素的重新渲染。啥概念，一个动画以毫秒级的速度调用setState，从而调用render方法，然后去遍历其子元素进行渲染。这个计算量和UI渲染量大家可以自己体会下。那么怎么办呢？
* ShouldComponentUpdate
	* React-Native的官方文档上是推荐这个方法，当我们渲染某个节点时，其并不受影响的子元素可以在这个方法里面返回false，这意味着它们不会受其影响，不会进行重新渲染，计算量和UI渲染量瞬间下降。
	* 但是！上面这种做法会有个问题，往往我们的app不是单独的，它是由很多组件构成的，我们应该保持每个组件的相对独立性，而且，还有可能你在这里引用了第三方的组件。这意味着我们没法随心所欲的运用这个方法，除非你愿意去改第三方组件的源码，简单的说我们应该维持组件之间的隔离性，只通过接口来进行通信，父级组件的动画的实现不应该去修改其子组件，毕竟不说性能光这个工作量就够呛。[继续doge之微笑]。那么怎么办呢？
* StaticContainer 静态容器
	* 上个问题的原因是ShouldComponentUpdate在子组件里面，如果我们把它上移到父级呢？这样子元素对这部分就不用负责任了。那关于这个想法的实现可以运用React-Native提供的StaticContainer这个组件。具体如下，我们用StaticContainer把不会变动的子元素包裹起来，然后通过一个参数来控制它的重新渲染。这种方法的确是一个做法，但并不是React实际使用来达到其效率的一个办法。那还有啥其他办法呢？
	
	~~~js
		render() {
	    return (
	      <div style={{left: this.state.left}}>
	        <StaticContainer
	          shouldUpdate={!this.state.isAnimation}>
	          <ExpensiveChild />
	        </StaticContainer>
	      </div>
	      )
	  }
	  
	   class StaticContainer extends React.Component {
	    render() {
	      return this.props.children;
	    }
	    shouldComponentUpdate(nextProps) {
	      return nextProps.shouldUpdate;
	    }
	  }
	~~~
		
* Element Caching 缓存元素
	* 我们可以缓存子元素的渲染结果到局地变量，缓存之后，每次setState时，React通过DOM Diff就不再渲染子元素了(因为React内部优化机制，只要两个元素完全一样就不会进行重新渲染)
	
	~~~js
	render(){
    this._child = this._child || <ExpensiveChild />;
    return (
        <div style={{left:this.state.left}}>
            {this._child}
        </div>
    );
	}
	~~~
	* 上面几种可用的方法都会导致一个问题条件竞争。当动画在进行的时候，子元素恰好获得了新的state，而这时候动画无视了这个更新，最后就会导致状态不一致。那么怎么办呢？让我们再回到问题的本质上去考虑这个问题。
* Raw DOM Mutation 原生DOM操作
	* 实际上我们需要做的事情只是找到某个节点改变其left值，我们并不需要重新渲染啊blabla一大堆东西。那我们就不走React这套，直接改变它dom不就好了嘛。
	
		~~~js
		render() {
		return (
		  <div
		    style={{left: this.state.left}}>
		    <ExpensiveChild />
		  </div>
		  );
		}
		onUpdate(value) {
		React.findDOMNode(this).style.left = value + 'px';
		}
		~~~
	* 但是！这样我们不就违背了React的初衷了嘛？尽量不要去自己操作dom，React如是说。而且，在这种情况下条件竞争问题依然存在。同时如果这个组件unmount之后，动画就报错了。
```Uncaught Exception: Cannot call ‘style’ of null``。所以现在怎么办呢？

* 数据绑定
	* React并不提倡数据绑定，因为在app启动的时候每个model都需要内存和初始化(绑定啊监听啊blabla的)，当然它的更新是很快的。可是作为一个app，如果你启动就耗时很多了，这个是不理想的状态，而且其实很多元素啊啥的是不需要展示的，但绑定了会耗费大量的内存。
	* 但是！animation可以这样搞，因为它的属性不多，而且它需要每帧刷新的时候有最好的性能，而且它提供了这个时间来做绑定啊这些初始化行为，所以可以用。
	* 因此官方提供了我们上面说的几种组件，在内部，它们都是执行了数据绑定等一系列操作的。同时提高了新的数据类型来增加可扩展性。

	~~~js
	 Animated.div = class extends React.Component{
    componentWillUnmount() {
        nextProps.style.left.removeAllListeners();
    },
    // componentWillMount需要完成与componentWillReceiveProps同样的操作
    // 遍历传入的props，查找是否有Animated.Value的实例，并绑定相应的DOM操作
    componentWillReceiveProps(nextProps) {
        nextProps.style.left.removeAllListeners();//如果没有这句可能会内存溢出或者条件竞争
        nextProps.style.left.onChange(value => {
            React.findDOMNode(this).style.left = value + 'px';
        });
        
        // 将动画值解析为普通数值传给原生div，因为原生的div不懂这种数据格式
        this._props = React.addons.update(
            nextProps,
            {style:{left:{$set: nextProps.style.left.getValue()}}}
        );
    },
    render() {
        return <div ...{this._props} />;
    }
}
	~~~

# 参考文献
* [“指尖上的魔法” -- 谈谈React-Native中的手势](https://github.com/jabez128/jabez128.github.io/issues/1)
* [React Native 浅入门 —— 交互篇](http://leowang721.github.io/2015/08/12/learning/react-native/interactive/#comments)
* [React Native官方文档 手势响应系统](http://reactnative.cn/docs/0.31/gesture-responder-system.html#content)
* [React Native官方文档 PanResponder](http://reactnative.cn/docs/0.31/panresponder.html)
* [React Native 触摸事件处理详解](http://www.race604.com/react-native-touch-event/)
* [facebook/react源码注解](https://github.com/facebook/react/commit/6ec3b651690befb4226230855fa2e102654ad35f#commitcomment-16569138)
* [Gesture detection in React Native](http://blog.lum.pe/gesture-detection-in-react-native/)
* [Learning React Native](https://books.google.com.hk/books?id=274fCwAAQBAJ&pg=PA55&lpg=PA55&dq=PanResponder+multiple+touches&source=bl&ots=tEwhbCh3l1&sig=iregshh4GH0H89jzURAYSyB0pPM&hl=zh-CN&sa=X&ved=0ahUKEwikgJ7T8MTOAhVCKJQKHebqBOoQ6AEIUDAG#v=onepage&q=PanResponder%20multiple%20touches&f=false)
* [React Native API模块之LayoutAnimation布局动画详解-Android/iOS通用](http://www.lcode.org/react-native-api%E6%A8%A1%E5%9D%97%E4%B9%8Blayoutanimation%E5%B8%83%E5%B1%80%E5%8A%A8%E7%94%BB%E8%AF%A6%E8%A7%A3-androidios%E9%80%9A%E7%94%A862/)
* [React Native’s LayoutAnimation is Awesome](https://medium.com/@Jpoliachik/react-native-s-layoutanimation-is-awesome-4a4d317afd3e#.xyb7msatl)
* [React Native Animation Book](http://browniefed.com/react-native-animation-book/)
* [react-native LayoutAnimation.js源码](https://github.com/facebook/react-native/blob/d4e7c8a0550891208284bd1d900bd9721d899f8f/Libraries/LayoutAnimation/LayoutAnimation.js)
* [react-native Easing.js源码](https://github.com/facebook/react-native/blob/master/Libraries/Animated/src/Easing.js)
* [React Native官方文档 Animated](http://reactnative.cn/docs/0.31/animations.html#content)
* [Christopher Chedeau - Animated](https://www.youtube.com/watch?v=xtqUJVqpKNo)
* [ReactNative Animated动画详解](http://www.alloyteam.com/2016/01/reactnative-animated/)
* [React Native动画研究和对比](http://tw93.github.io/2016-04-05/the-thinking-about-react-native-animated.html)
