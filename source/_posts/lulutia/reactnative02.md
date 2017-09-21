title: React Native 学习系列二
date: 2015-06-28 22:03:12
categories: lulutia
tags: 
- React Native
---
本文是React Native学习系列的第二篇，主要介绍了JSX、生命周期、以ScrollView为例讲解了官方组件、以BackHandler为例讲解了官方API。

<!-- more -->

### JSX
* 什么是JSX

	>It is called JSX, and it is a syntax extension to JavaScript. We recommend using it with React to describe what the UI should look like. JSX may remind you of a template language, but it comes with the full power of JavaScript.JSX produces React "elements".
	
	* 我们可以看见两个关键点：
		1. 它是JS的语法扩展(我们可以理解我为它就是一个比较高级的语法糖)
		2. 与模板语言不一样，它能利用JS自带的语法和特性。因此基本会写JS就能写JSX，学习成本低，并且能利用JS本身的语法
		3. React基于Virtual DOM创造的JSX，JSX创造的是React element，它不是真正的DOM，因此也意味着在没有真正DOM的情况下，它也能模拟DOM的行为(React-Native中实际也没有真正的DOM)
	* 具体行为
		* 以react举例下面两段代码完全一致：
	
			```js
			var p1 = React.createElement('p', null, 'my test')
			var root = React.createElement('div', { className: 'root-div' }, p1);
			```
			```js
			var root = (
				<div className='root-div'>
					<p>my test</p>
				</div>
			)
			```

		* JSX之后会被专门的解释器解释为JS(在打包阶段就完成了，因此不会有性能上的问题)再执行
* JSX语法
	* 在JSX中你可以使用{}来包裹JS表达式，下面以RN来举例
		
		```js
		{refundDetailData.return.returnPics && <View style={[Style.basicLayout, Style.image]}>
	    	<Text style={[Style.textColor, Style.navTitle]}>图片信息:</Text>
	    	<ImageShow picUrls={refundDetailData.return.returnPics}/>
	  	</View>}
		```
	* JSX本身也是一种表达式，因此可以在if语句，for循环等各种场合中使用

		```js
		dataList.map((item, index) => (
		  <TouchableHighlight key={index}>
		    <View>
		      <Text>{item.contactName}</Text>
		      <Text>{item.contactTel}</Text>
		    </View>
		  </TouchableHighlight>
		));
		```

	* JSX可以定义属性，一般每个组件都会接受一组属性(props)
		* 属性的名字可以自定义
		* 属性的值能够是变量，当属性值是变量时需要通过{}包裹起来，此时注意如果在这个大括号外层用双引号包裹，则此时整条语句会作为字符串进行解析，而不是变量了
		* 虽然JSX与HTML有很多类似处，但是其最后还是编译为JS的，因此，在React DOM中的属性名是遵循驼峰命名法的
		* 当忽略属性的值时，JSX会按照true来对待它。而不使用属性时，其对应的值与组件实现内部默认值有关
			
			```js
				{/*下面两条代码实现的效果一样*/}
				<Input type="button" disabled />;
				<Input type="button" disabled={true} />;
				
				{/*下面两条代码实现的效果一样*/}
				<Input type="button" />;
				<Input type="button" disabled={false} />;
			```
	* JSX标签能够包含子元素就如HTML一样，而且其子元素也可以运用JS的语法进行构建
	* JSX中的注释就如JS类似，但是需要注意当在子元素中进行注释时，需要用{}将注释包裹起来
	
		```js
		<Nav>
	    {/* child comment, put {} around */}
	    <Person
	      /* multi
	         line
	         comment */
	      name={window.isLoggedIn ? window.name : ''} // end of line comment
	    />
	  </Nav>
		```
	* JSX中的事件处理是直接绑定在组件上的，下面以RN为例
	
		```js
		<TouchableHighlight style={Style.tabBtn} underlayColor={Colors.yellowLighten}onPress={this.goToReturnList}>
		  <Text style={Style.tabBtnText}>退货单</Text>
		</TouchableHighlight>
		```
		* 相比于使用下面这种方式，界面元素和业务逻辑的耦合会更加明显
		
		```js
		$('#my-button').on('click', this.checkAndSubmit.bind(this));
		```
		* 在JSX中，需要注意事件名依然按照驼峰命名法来进行，而大括号中就是事件触发时返回的事件处理函数。JSX中绑定的事件自动进行了解绑处理，当对应的DOM不存在时，其绑定的事件就自动解绑了。
		*  React有一个模拟事件系统。它并不会将事件绑定到真正的节点上，当React启动时，他开始在顶层用一个单独的事件监听器来监听所有的事件。当一个组件加载或者移除时，它绑定的事件将在一个内置的映射上被添加或者移除。当事件真正触发时，React知道如何运用这个映射来dispatch这个事件。
		*  虽然整个事件系统由React来管理了，但是其API和使用方法与原生事件一致。因此做到了浏览器的兼容。

### 生命周期
* 在React中，组件只是一种状态机，整个UI的渲染可以算做是状态驱动的。你更新一个组件的状态，然后根据新的状态渲染UI，React会以一种最效率的方式来更新DOM
* 大多数组件只需要根据传入的props里面的数据进行渲染，属性是在组件初始化之后就从父级组件带入到组件内部。我们无法在使用的过程中对组件的属性进行修改。但是当需要对用户输入，时间的流逝，服务端请求作出反应时，需要用state来进行状态记录，state是实际上组件中使用的数据，它可以被修改
* 在React中，通过调用setState(data, callback)来告诉它数据变动了，这个方法将data合并进this.state，之后告诉组件状态变动了需要进行重新渲染，callback会在重新渲染完毕后被调用。注意setState()这个方法是异步的，同步的多个setState方法只会触发一次实际render
* 组件在实例化之后就开始了它的生命周期过程。它的整个生命周期主要由以下几个部分组成:
	* getDefaultProps():在组件类创建的时候调用**一次**，然后返回值被缓存下来, 它返回的任何复杂对象用于设置默认的props, 并且这些将会在实例间共享，而不是每个实例拥有一份拷贝，具体使用见[这里](https://facebook.github.io/react/docs/react-without-es6.html#declaring-prop-types-and-default-props)。注意只能在子组件或组件树上调用setProps[已经deprecated了](https://facebook.github.io/react/blog/2015/10/07/react-v0.14.html#new-deprecations-introduced-with-a-warning)。别调用this.setProps或者直接修改this.props。可以通propTypes对props的类型进行验证
	
	```js
	static propTypes = {
	   data: PropTypes.object,
	   pickerNameStyle: Text.propTypes.style
   };
	```
	* getInitialState():在组件挂载之前调用**一次**。返回值将会作为 this.state的初始值。这个方法执行时已经可以访问组件的props。注意state是每个组件自带的，而props是所有实例共享的
	* componentWillMount():在初始化渲染执行之前立刻调用，且只调用一次，这是渲染前最后修改state的机会
	* render():render方法返回的结果并不是真正的DOM元素，而是一个虚拟的表现，类似于一个DOM tree的结构的对象。它是唯一一个必须的方法。在这个方法中，会检测this.props和this.state，返回一个单子级组件,当然也可以返回null或者false。render函数不应该修改state,操作DOM或者与浏览器交互
	* componentDidMount():在初始化渲染执行之后立刻调用一次,在生命周期中的这个时间点，组件拥有一个DOM展现[即虚拟DOM构建完毕]，你可以通过this.getDOMNode()来获取相应DOM节点。当需要从组件获取真实DOM的节点，可以使用ref属性。注意在RN中，是先调用子组件的componentDidMount()，然后调用父组件的函数。这个函数之后，就进入了稳定运行状态，等待事件触发
	
	```js
	......
	return <canvas ref='mainCanvas'>
	......
	componentDidMount: function(){
	    var canvas = this.refs.mainCanvas.getDOMNode();
	    //可以访问到 Canvas 节点
	}
	```
	* componentWillReceiveProps():用此函数可以作为react在props传入之后，render()渲染之前更新state的机会,新的props是传入的,老的props可以通过this.props来获取。注意在该函数中调用this.setState()将不会引起二次渲染
	
	```js
	componentWillReceiveProps: function(nextProps) {
		this.setState({
		    likesIncreasing: nextProps.likeCount > this.props.likeCount
		});
	}
	```
	* shouldComponentUpdate():在接收到新的props或者state,将要渲染之前调用。如果shouldComponentUpdate返回false,则render()将不会执行,直到下一次state改变。(通过此函数可以提高性能)
	* componentWillUpdate():和componentWillMount类似,在组件接收到了新的props或者state即将进行重新渲染前调用,注意你不能在该方法中使用this.setState()。如果需要更新state来响应某个prop的改变,请使用componentWillReceiveProps。紧接着这个函数，就会调用render()来更新界面了
	* componentDidUpdate():和componentDidMount类似,使用该方法可以在组件更新之后操作DOM元素
	* componentWillUnmount():当组件从DOM中移除的时候立刻调用来完成所有的清理和销毁工作,在conponentDidMount中添加的任务都需要再该方法中撤销,如创建的定时器或事件监听器

	![lifeCycle](http://okzzg7ifm.bkt.clouddn.com/reactlife.png)
	
### 运行组件UI example
* 运行官方案例(即在虚拟机上查看RN各个组件的实际效果)
	* [运行方法](https://github.com/facebook/react-native#examples)
	* 运行过程中可能出现的问题
		* What went wrong: Execution failed for task ':ReactAndroid:buildReactNdkLib'. 
			* [解决办法](http://stackoverflow.com/questions/36209774/unable-to-run-react-native-uiexplorer-example-project)
		* 安卓新项目起不来
			* 解决办法: 注意下是不是老项目的shell还在运行，需要重新编译链接一次

### 官方组件举例
* ScrollView
	* ScrollView是一个普通的可滚动容器，它能包含多个组件和View。
	* ScrollView能纵向滚动也能横向滚动
	* ScrollView一般用来展示限制尺寸的少量东西。因为所有ScrollView里面的元素和组件都会被渲染，不管它当前是否展示在屏幕上。
	* ScrollView必须有一个确定的高度才能正常工作，因为滚动的本质就是将一系列不确定高度的子组件装进一个确定高度的容器
	* 属性
		* contentContainerStyle：传入的样式属性，其作为样式会应用在包裹所有子元素的内容元素容器上
		* horizontal：确定横向还是纵向滚动，默认为false，即默认纵向滚动
		
		```js
		<ScrollView style={styles.listTab} horizontal> 
        {this.level.map((item, index) => {
          return (
            <View style={styles.tabTextContainer} key={index}>
              <Text>{item}</Text>
            </View>
            )
        })}         
       </ScrollView>
		```
		* keyboardDismissMode：决定当拖拽时，键盘是否消失
			* none：默认，拖拽不会让键盘消失
			* on-drag：当拖拽开始时，键盘消失
			* interactive：安卓上不支持，键盘伴随拖拽操作同步地消失，并且如果往上滑动会恢复键盘
		* keyboardShouldPersistTaps：决定当点击时，键盘是否可见。这个属性特别重要。比如ScrollView里面有很多输入框时，我们希望点击输入框是输入框本身拿到事件，而键盘并不会在切换时进行关闭再打开的操作。
			* never：默认，当点击文本输入框之外时，如果键盘是打开的则关闭键盘。当这个发生时，子元素将不会接收到点击事件
			* always：键盘将不会自动关闭，并且scroll view不会捕捉到点击事件，但是子元素能够捕捉到点击事件
			* handle：键盘将不会自动关闭当点击是由子元素触发的
			* false：用never替代
			* true：用always替代
		* onContentSizeChange：当滚动视图的内容尺寸大小发生变化的时候调用

			```js
			this.level = ['我常买', '热卖', '一级类目', '鸡腿系列', '海鲜系列', '鸭制品系列'];
			...
			<TouchableHighlight onPress={() => {this.level.pop(); this.forceUpdate();}}>
		      <View style={styles.button} >
		        <Text style={styles.add}>+</Text>
		      </View>
		    </TouchableHighlight>
		    ...
		    <ScrollView style={styles.listTab} horizontal onContentSizeChange={(contentWidth, contentHeight) => {console.debug(contentWidth, contentHeight);}}> 
	        {this.level.map((item, index) => {
	          return (
	            <View style={styles.tabTextContainer} key={index}>
	              <Text>{item}</Text>
	            </View>
	            )
	        })}         
	        </ScrollView>
			```
			![life](http://okzzg7ifm.bkt.clouddn.com/contentSizechange.png)
		* onScroll：该方法在滚动的时候每frame(帧)调用一次，调用的频率可以用scrollEventThrottle属性来控制。当滚动到边界后无法触发
		* refreshControl：一个refreshControl组件，主要在下拉刷新时使用
		* pagingEnabled：默认false，当为true时，scroll view会停留在其尺寸的倍数的位置。这个能够被用在在横向翻页。具体表现就是，超过Scroll View尺寸一点时页面会自动会回退回去，超过很多但是尚未到达其尺寸两倍的位置，则会向前到达其两倍尺寸的位置，之后如此类推
		* removeClippedSubviews：默认为true，在ScrollView视图之外的子视图(该视图的overflow属性值必须要为hidden)会被暂时移除，该设置可以提高滚动的性能
		* scrollEnabled：默认true，当为false时，内容不会滚动
		* showsHorizontalScrollIndicator：默认true，当为true时，横向滚动会展示滑条
		* showsVerticalScrollIndicator：默认true，当为true时，纵向滚动会展示滑条
	* 仅Android支持的属性:
		* endFillColor：当滚动内容没填充满Scroll View时设定填充不满的区域
		* scrollPerfTag：在Scroll View上记录滚动性能的标签
	* 仅iOS支持的属性:
		* alwaysBounceHorizontal：横向弹簧效果，当horizontal ={true}默认是true，horizontal={false}默认是false
		* alwaysBounceVertical：纵向弹簧效果，当horizontal ={true}默认是false，horizontal={false}默认是true
		* automaticallyAdjustContentInsets：默认true，自动调节内容内偏移，控制是否自动调节内容内偏移以便于一个navigation bar或者tab bar或者toolbar不挡住Scrollview中的内容
		* bounces：默认true，控制水平方向与垂直方向的弹簧效果，优先级比alwaysBounce* 属性高
		* bouncesZoom：控制拉近与缩小超过限制时是否有弹性动画，当为true时有
		* canCancelContentTouches：默认true，控制ScrollView是否可以拖动，如果为false不能拖动
		* centerContent：默认false，为true时如果ScrollView中内容小于ScrollView的边界，则它们自动居中，超过边界时无效
		* contentInset：内部内容距离ScrollView边界的内偏移量，默认为{top: 0, left: 0, bottom: 0, right: 0}
		* contentOffset：用来手动设置起始滚动偏移量。默认为 {x: 0,y: 0} 
		* decelerationRate：指定手指抬起减速速率
			* normal: 0.998，为默认
			* fast: 0.99
			* 也可以指定一个浮点数，确定减速快慢
		* directionalLockEnabled：默认false，为true时控制只有一个方向可以滚动当拖拽
		* indicatorStyle：指示器样式，default与black相同，black与白色背景搭配，white与黑色背景搭配
		* maximumZoomScale：默认是1.0，放大的最大系数
		* minimumZoomScale：默认是1.0，缩小的最大系数
		* onScrollAnimationEnd：滚动动画完成后触发
		* scrollEventThrottle：控制滚动时滚动事件触发频率
		* scrollIndicatorInsets： {top: number, left: number, bottom: number, right: number}，指定指示器内偏移量，应与contentInset值相同，默认{0, 0, 0, 0}
		* scrollsToTop：默认true，默认true时，Scroll View滚动到顶部当状态条被点击时
		* snapToAlignment：当snapToInterval指定时，这个属性定义这个停驻点相对于Scroll View的关系。
			* start (默认) 会将停驻点对齐在左侧（水平）或顶部（垂直）
			* center 会将停驻点对齐到中间
			* end 会将停驻点对齐到右侧（水平）或底部（垂直）
		* snapToInterval：当指定时，会导致Scroll View停留在这个参数的倍数的位置。这个属性一般与snapToAlignment一起用
		* stickyHeaderIndices：子元素索引构成的数组，用来指定滚动时这些元素停靠到界面的顶部，比如传递stickyHeaderIndices={[0]}将让第一个子元素固定到Scroll View的顶部。当horizontal={true}时，这个属性不支持
		* zoomScale：当前Scroll View内容的缩放比例
	* 方法
		* scrollTo()：例如scrollTo({x: 0; y: 0; animated: true})，滚动到指定的x, y偏移处。第三个参数为是否启用平滑滚动动画
		* scrollToEnd()：如果是纵向的滚动，则滚动到底部，如果是横向，则滚动到右部

### 官方API举例
* BackHandler
	* 监听硬件的back键操作。如果没有任何监听函数，或者监听函数的返回值不是true，则会调用默认的back键功能来退出应用
	```js	
		this.backAndroidListener = BackHandler.addEventListener('hardwareBackPress', () => {
			if (navigator.getCurrentRoutes().length > 1) {
				navigator.pop();
				return true;
			}
			return this.onExitApp();
	    });
    ```
	* 方法：
		* exitApp：当你在监听里面无法立刻判断是否要退出，比如你需要获取异步操作执行成功后再调用，此时可以用这个函数来退出
		* addEventListener：绑定监听函数
		* removeEventListener：移除监听函数

	
### 参考
* [Change And Its Detection In JavaScript Frameworks](http://teropa.info/blog/2015/03/02/change-and-its-detection-in-javascript-frameworks.html)
* [React Native 中组件的生命周期](http://www.race604.com/react-native-component-lifecycle/)
* [How JavaScript Event Delegation Works](https://davidwalsh.name/event-delegate)
* [深入浅出React（三）：理解JSX和组件](http://www.infoq.com/cn/articles/react-jsx-and-component)