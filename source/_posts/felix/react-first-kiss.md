title: React入门
date: 2015-12-21 21:47:00
categories: felix
tags: 
- react
---

<a href="/uploads/felix/react/react-first-kiss.pdf" target="_blank">React入门分享PPT下载</a>  
React 起源于 Facebook 的内部项目，因为该公司对市场上所有 JavaScript MVC 框架，都不满意，就决定自己写一套，用来架设Instagram 的网站。由于 React 的设计思想极其独特，属于革命性创新，性能出众，代码逻辑却非常简单。React的虚拟DOM的特性使得他可以多端渲染，甚至直接渲染到Canvas。

<!-- more -->

## 框架特色
* 类似于web component的组件封装，面向未来
* 可复用，可组合的组件架构
* 数据驱动，UI自动更新，解放DOM操作  
* JSX语法使得代码看起来简洁清晰
* 单向数据流: 使得组件行为更可预测
* Virtual DOM: 虚拟DOM的抽象使得React 组件可以跨端渲染
* React Native App开发
* 至今未发1.0，API有可能有较大改变

## 如何使用：babel  
* react.js：react的核心库
* react-dom.js：提供与DOM相关的功能
* Jsx：【HTML 语言直接写在 JavaScript 语言之中，不加任何引号】需要babel编译
    * 浏览器端使用babel browser.js，由于编译过程比较慢，一般仅在开发时候使用
    * 也可使用babel预编译，在发布时完成编译 
            
            babel src —out-dir build
    * JSX 的基本语法规则：HTML 语言直接写在 JavaScript 语言之中，不加任何引号，这就是JSX语法。遇到 HTML 标签（以 < 开头），就用 HTML 规则解析；遇到代码块（以 { 开头），就用 JavaScript 规则解析
        * 在javascript中写XML，不是模板引擎       * HTML元素必须用一个元素包裹
        * 默认进行字符转义，防XSS攻击(dangerouslySetInnerHTML)
        * ‘{}’包裹js表达式：简单变量，数组
        * 分支：预定义变量，三元表达式，自执行函数
        * 数组循环：arr.map(function() {})
    * [babel JSX在线编译器](https://babeljs.io/repl/#?experimental=false&evaluate=true&loose=false&spec=false&code=)

## 组件
* 组件声明
   
        var HelloMessage = React.createClass({});
* 组件必须有自己的render方法
* 组件使用：模板中直接作为标签名(标签必须闭合，自闭合和配套闭合都可以)使用，自定义标签必须大写
    
        <HelloMessage />
        // 或者
        <HelloMessage></HelloMessage>
* 通过 `this.props` 可访问标签上定义的所有属性  
注意：`class` 属性需要写成 `className` ，`for` 属性需要写成 `htmlFor` ，这是因为 `class` 和 `for` 是 JavaScript 的保留字
    * `this.props.children` 属性表示组件的所有子节点[array | object | string | undefined]，因此可直接使用React.Children提供的各种工具方法来操作，如map

            // 使用React.Children提供的工具方法使得我们可以不去考虑children的数据类型
            React.Children.map(this.props.children, function(child) {
        
            });
* PropTypes:   
组件的属性可以接受任意值，字符串、对象、函数等等都可以。有时，我们需要一种机制，验证别人使用组件时，提供的参数是否符合要求。  
组件类的PropTypes属性，就是用来验证组件实例的属性是否符合要求

        var MyTitle = React.createClass({
            propTypes: {
                title: React.PropTypes.string.isRequired,
            },

            render: function() {
                return <h1> {this.props.title} </h1>;
            }
        });
更多PropTypes验证可参考[官方文档](https://facebook.github.io/react/docs/reusable-components-zh-CN.html)。
* getDefaultProps:  
此方法可用于设置组件属性的默认值。
* ref:  
用于获取真实的DOM节点。获取用户的输入。这时就必须获取真实的 DOM 节点，虚拟 DOM 是拿不到用户输入的。为了做到这一点，文本输入框必须有一个 ref 属性，然后 this.refs.[refName] 就会返回这个真实的 DOM 节点。
* 事件  
React 组件支持很多事件，除了 Click 事件以外，还有 KeyDown 、Copy、Scroll 等，完整的事件清单请查看[官方文档](http://facebook.github.io/react/docs/events-zh-CN.html#supported-events)。所有事件都在冒泡阶段触发。
* state:  getInitialState, this.setState
可将组件看做一个状态机，一开始有一个初始状态，然后用户互动，导致状态变化，从而触发重新渲染 UI。  
当用户点击组件，导致状态变化，this.setState 方法就修改状态值，每次修改以后，自动调用 this.render 方法，再次渲染组件。
* 表单交互：
    * value, checked, selected，使得组件受限，必须通过onChage事件改变值
    * 仅仅设置默认值可以用：defaultValue, defaultChecked, defaultValue
* 组件样式style写法
        
        {% raw %}style={{opacity: this.state.opacity}}{% endraw %}
这是因为 React 组件样式是一个对象，所以第一重大括号表示这是 JavaScript 语法，第二重大括号表示样式对象。 
* 大写就是自定义的组件，小写就是react内部的dom组件
* 组件生命周期  
组件并不是真实的 DOM 节点，而是存在于内存之中的一种数据结构，叫做虚拟 DOM （virtual DOM）。只有当它插入文档以后，才会变成真实的 DOM 。根据 React 的设计，所有的 DOM 变动，都先在虚拟 DOM 上发生，然后再将实际发生变动的部分，反映在真实 DOM上，这种算法叫做 [DOM diff](http://calendar.perfplanet.com/2013/diff/) ，它可以极大提高网页的性能表现。
    * 生命周期的三个状态
        * Mounting: 已插入真实 DOM
        * Updating: 正在被重新渲染
        * Unmounting: 已移出真实 DOM
    * React为每个状态提供两种处理函数，will（进入状态前调用）/did（进入状态后调用），共5个处理函数
        * componentWillMount()
        * componentDidMount()
        * componentWillUpdate(object nextProps, object nextState)
        * componentDidUpdate(object prevProps, object prevState)
        * componentWillUnmount()
    * 此外，React 还提供两种特殊状态的处理函数。
        * componentWillReceiveProps(object nextProps)：已加载组件收到新的参数时调用 
        * shouldComponentUpdate(object nextProps, object nextState)：组件判断是否重新渲染时调用
    * mixins(array): 定义复杂组件间的共用功能。关于 mixin 值得一提的优点是，如果一个组件使用了多个 mixin，并用有多个 mixin 定义了同样的生命周期方法（如：多个 mixin 都需要在组件销毁时做资源清理操作），所有这些生命周期方法都保证会被执行到。方法执行顺序是：首先按 mixin 引入顺序执行 mixin 里方法，最后执行组件内定义的方法。
    * setState是异步操作
    
            this.setState(
                function(state, props) | object state,
                [function callback]
            )

    ![](/uploads/felix/react/life-cycle.png)
* 组件通信
    * 父子组件通信：  
    子组件通过props可以访问父组件的属性和方法
    * 非父子组件通信：  
    使用全局事件 Pub/Sub 模式，在 componentDidMount 里面订阅事件，在 componentWillUnmount 里面取消订阅，当收到事件触发的时候调用 setState 更新 UI。这种模式在复杂的系统里面可能会变得难以维护，对于比较复杂的应用，推荐使用类似 Flux 这种单项数据流架构。
* [JSX语法](https://facebook.github.io/react/docs/jsx-in-depth-zh-CN.html): 仅仅是方法和对象的语法糖
    * 渲染DOM时元素属性会做过滤，只会部分属性，如className, id, data-*...当然组件中的this.props能拿到所有属性
    * 变量取值
    
            <input type="text" value={this.state.inputValue} onChange={this.handleChange}/>
    * 分支
    没有if语句，可以用三元元算符，也可以在componentWillMounting函数中定义变量来实现,但可以在自执行函数里面写。
    
            {function(){
                if (true){ 
                    return <h3>true 分支</h3>
                } else {
                    return <h3>false 分支</h3>
                }
            }()}
    * 循环
    数组循环用.map；对象循环只能用自执行函数了  
    参考：[HTML扩展](https://facebook.github.io/react/docs/jsx-gotchas-zh-CN.html)
* {...this.props}会把父组件的所以props赋值到子组件上

## 辅助
* Flux  
React 标榜自己是 MVC 里面 V 的部分，那么 Flux 就相当于添加 M 和 C 的部分。  
Flux 是 Facebook 使用的一套前端应用的架构模式。  
实现库：[Facebook Flux](http://facebook.github.io/flux/docs/overview.html), [Redux](http://redux.js.org/), [Reflux](https://github.com/reflux) 
[Flux-demos](https://github.com/facebook/flux/tree/master/examples)
* chrom插件：React Developer Tools
* sublime 使用JSX
    * [语法高亮Babel](https://github.com/babel/babel-sublime)
    * [在JSX文件中使用Emmet](https://gist.github.com/neilcarpenter/8979ea9ed91b10e36af9)
    * [常用代码片段](https://github.com/reactjs/sublime-react)

## 参考链接
* [官方文档](https://facebook.github.io/react/docs/getting-started-zh-CN.html)(中文没有入口,可自行添加-zh-CN查看)
* [react-demos](https://github.com/felixyuebin/react-demos)
* [React入门实例教程](http://www.ruanyifeng.com/blog/2015/03/react.html)