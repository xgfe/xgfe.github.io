title: 实现一个React 组件
date: 2018.03.04 14:00:00
categories: zhouyinian
tags:
- React 
- component
---
本文简单介绍了如何在React中编写组件。
<!--more-->

### 项目的搭建
为了加快演示，用react-create-app快速搭建项目

```
npm install -g create-react-app
```

```
create-react-app react-learn-component
cd react-learn-component
```
```
npm run start
```
浏览器会自动打开如下页面

<img src="//ww1.sinaimg.cn/large/933205a1ly1fp01hatymlj20y60hg75l.jpg"/>

更多关于react-create-app介绍：[传送门](//github.com/facebook/create-react-app)

### 组件的介绍

> Components let you split the UI into independent, reusable pieces, and think about each piece in isolation.

组件可以让你把UI切分成独立的、可复用的块去单独的考虑和开发。

### React中组件的分类

#### 展示型组件（presentational）

展示型组件是用来展示样式的，他们对应用的其余部分没有依赖性，会通过props明确地接收数据，可以写成函数的形式。如下的BlogList组件只是接收一个`bolglist`数组，便能展示博客列表，相同的输入会有相同的输出。

```
import React from "react";
export const BlogList = bloglist => (  
    <ul>
        {
            bloglist.map(({ body,author,id }) =>      
                <li key={id}>{body}-{author}</li> 
            )
        }     
    </ul>
)

```
#### 容器型组件(container)

容器型组件关心组件如何工作，可以为展示组件或其他容器组件提供数据，通常是有状态的。

```
import React,{Component} from "react";
import {BlogList} from '../BlogList/BlogList'
class Blog extends Component {
    constructor(props){
        super(props)
        this.state = {
            blogList:[]
        }
        this.showBlodList = this.showBlodList.bind(this)
    }
    componentDidMount(){
        const blogList = [
            {
                id:1,
                author:'zyn',
                body:'这是blog内容111'
            },
            {
                id:2,
                author:'zyn',
                body:'这是blog内容222'
            }
        ]
        this.setState({
            blogList
        })
    }
    showBlodList(){
        console.log(this.state.blogList)
    }
    render(){
        const {blogList} = this.state
        return(
            <div>
                {BlogList(blogList)}
                <button type="button" onClick={this.showBlodList}>点击我</button>
            </div>
        )
    }
}
export default Blog

```
显示效果如图

<img src="//ww1.sinaimg.cn/large/933205a1ly1fp020d7trzj21vi0okdl3.jpg"/>

### 编写一个复选框组件

最近用了AngularJS 和 Vue, 在写表单的时候基于双向数据绑定，写起来是相当的happy，当然React的单向数据流也有着自己的优点。基于此我们可以对项目中常用的表单控件进行组件的封装，下面以复选框为例。

#### 第一步，创建文件
首先我们在 components 文件夹下面创建Checkbox文件夹以及Checkbox.js 文件,先写一个无状态组件。

```
// CheckBox.js

import React, { Component } from 'react';
class CheckBox extends Component {
    render() {
        return (
            <label><input type="checkbox" />点击我</label>
        )
    }
}
export default CheckBox

```

```
// App.js
import React, { Component } from 'react';
import logo from './logo.svg';
import './App.css';
import Blog from './components/Blog/Blog'
import CheckBox from './components/CheckBox/CheckBox'
class App extends Component {
  render() {
    return (
      <div className="App">
        <header className="App-header">
          <img src={logo} className="App-logo" alt="logo" />
          <h1 className="App-title">Welcome to React</h1>
        </header>
        <p className="App-intro">
          To get started, edit <code>src/App.js</code> and save to reload.
        </p>
        <Blog/>
        <CheckBox/>
      </div>
    );
  }
}

export default App;

```

如图，会出现一个`点击我`的复选框

<img src="//ww1.sinaimg.cn/large/933205a1ly1fp02g9zniej21aq0pedi9.jpg"/>

#### 第二步，实现label的可配置

我们会发现复选框的 `label` 的文字 `点击我` 是写死的，那么怎么让 `label` 的动态传入呢？

```
//Checkbox.js
import React, { Component } from 'react';
class CheckBox extends Component {
    render() {
        return (
            <label>
                <input type="checkbox" />

                //这里由‘点击我’换成了如下代码
                {this.props.children !== undefined ? this.props.children : null}
            </label>
        )
    }
}
export default CheckBox

```

这里要注意`this.props.children` 表示当前组件的所有子节点。`this.props.children` 的值有三种可能：如果当前组件没有子节点，它就是 `undefined` ;如果有一个子节点，数据类型是 `object` ；如果有多个子节点，数据类型就是 `array` 。

```
//App.js
import React, { Component } from 'react';
import logo from './logo.svg';
import './App.css';
import Blog from './components/Blog/Blog'
import CheckBox from './components/CheckBox/CheckBox'
class App extends Component {
  render() {
    return (
      <div className="App">
        <header className="App-header">
          <img src={logo} className="App-logo" alt="logo" />
          <h1 className="App-title">Welcome to React</h1>
        </header>
        <p className="App-intro">
          To get started, edit <code>src/App.js</code> and save to reload.
        </p>
        <Blog/>
        <CheckBox>按钮1</CheckBox>
        <CheckBox>按钮2</CheckBox>
      </div>
    );
  }
}

export default App;

```

查看浏览器，可以看到按钮的label已经变成可以配置的了。

<img src="//ww1.sinaimg.cn/large/933205a1ly1fp02tjojipj21ai0mo0vb.jpg"/>

#### 第三步，实现可控组件及获值
现在的复选框的选中状态是由自身去控制的，也就是说现在还无法去动态控制复选框的选中状态。同时，在业务需求中，如果有多个复选框，我们希望可以获得选中的复选框的数据。

```
// Checkbox.js

import React from "react";
class CheckBox extends React.Component {
    constructor(props) {
        super(props)
        this.checkCheckBox = this.checkCheckBox.bind(this);
        this.state = {
            is_checked: props.checked || false,
            value: props.value || ''
        }
    }
    componentWillReceiveProps(nextProps){
        if('checked' in nextProps){
            this.setState({
                is_checked:nextProps.checked || false
            })
        }
    }
    checkCheckBox() {
        const onChange = this.props.onChange;
        const value = this.props.value;
        if (onChange) {
            onChange(value);
        }
    }
    render() {
        let { is_checked, value } = this.state;
        return (
            <label>
                <input value={value} type="checkbox" onClick={this.checkCheckBox} checked={is_checked} />
                {this.props.children !== undefined ? this.props.children : null}
            </label>
        )
    }
}
export default CheckBox;

```

```
//App.js

import React, { Component } from 'react';
import logo from './logo.svg';
import './App.css';
import Blog from './components/Blog/Blog'
import CheckBox from './components/CheckBox/CheckBox'
class App extends Component {
  state = {
    checkedList: []
  }

  changeCheckBox = (value) => {
    const valueIndex = this.state.checkedList.indexOf(value)
    const checkedList = [...this.state.checkedList]
    if (valueIndex === -1) {
      checkedList.push(value);
    } else {
      checkedList.splice(valueIndex, 1);
    }
    this.setState({
      checkedList
    })
  }

  getChecked = (value) => {
    const valueIndex = this.state.checkedList.indexOf(value)
    if (valueIndex === -1) {
      return false
    }
    return true
  }

  render() {
    console.log('当前点击', this.state.checkedList)
    console.log('当前点击', this.getChecked('按钮1'))
    return (
      <div className="App">
        <header className="App-header">
          <img src={logo} className="App-logo" alt="logo" />
          <h1 className="App-title">Welcome to React</h1>
        </header>
        <p className="App-intro">
          To get started, edit <code>src/App.js</code> and save to reload.
        </p>
        <Blog />
        <CheckBox key="1" value="按钮1" checked={this.getChecked('按钮1')} onChange={this.changeCheckBox}>按钮1</CheckBox>
        <CheckBox key="2" value="按钮2" checked={this.getChecked('按钮2')} onChange={this.changeCheckBox}>按钮2</CheckBox>
      </div>
    );
  }
}

export default App;

```
<img src="http://ww1.sinaimg.cn/large/933205a1ly1fp03zn79w8j21m60osaea.jpg"/>
上述代码，复选框增加了自身的状态，初始的`state`默认从`props`中读取，再在`onChange`的时候，再把组件的`value` 值传上去，然后在父组件中获取，从而实现复选框的可控制，并且可以在控制台中获取到了我们想要的值。

#### 第四步，封装CheckBoxGroup组件
通过第三步，我们基本实现了我们的需求，但是App.js 文件里面操控复选框组件的逻辑代码太多了，影响了组件的简洁和使用。所以我们打算封装CheckBoxGroup 来包裹我们的复选框组件，把App.js中的逻辑抽离到CheckBoxGroup 组件上。

首先创建CheckBoxGroup.js 文件

```
// CheckBoxGroup.js
import React from "react"
import PropTypes from 'prop-types';
class CheckBoxGroup extends React.Component {
    constructor(props) {
        super(props)
        this.state = {
            value: props.value || props.defaultValue || [],
        };
        this.toggleOption = this.toggleOption.bind(this);
    }
    componentWillReceiveProps(nextProps) {
        if ('value' in nextProps) {
            this.setState({
                value: nextProps.value || [],
            });
        }
    }
    getChildContext() {
        return {
            checkboxGroup: {
                toggleOption: this.toggleOption,
                value: this.state.value,
            },
        };
    }

    toggleOption(option) {
        const optionIndex = this.state.value.indexOf(option.value);
        const value = [...this.state.value];
        if (optionIndex === -1) {
            value.push(option.value);
        } else {
            value.splice(optionIndex, 1);
        }
        if (!('value' in this.props)) {
            this.setState({ value });
        }
        const onChange = this.props.onChange;
        if (onChange) {
            onChange(value);
        }
    }
    render() {
        const { children, className } = this.props
        return (
            <div className={className}>
                {children}
            </div>
        )
    }
}
CheckBoxGroup.childContextTypes = {
    checkboxGroup: PropTypes.any,
};
export default CheckBoxGroup

```
代码分析：首先从`render` 开始

```
render() {
        const { children, className } = this.props
        return (
            <div className={className}>
                {children}
            </div>
        )
    }
```
这块代码和上面`BlodList`那里一样，也是通过`this.props.children` 加载子节点。

```
 getChildContext() {
        return {
            checkboxGroup: {
                toggleOption: this.toggleOption,
                value: this.state.value,
            },
        };
    }
```
子组件可以通过设置`contextTypes`类型后在`this.content`访问到父组件的`getChildContext`函数返回的对象属性，需要注意的是，getChildContext 指定的传递给子组件的属性需要先通过 childContextTypes 来指定，不然会产生错误。

同时，在子组件要把受控状态转移到`this.content`监听的对象中。

```
//CheckBox.js
import React from "react"
import PropTypes from 'prop-types';
import CheckBoxGroup from '../CheckBoxGroup/CheckBoxGroup'
class CheckBox extends React.Component {
    constructor(props) {
        super(props)
        this.checkCheckBox = this.checkCheckBox.bind(this);
        this.state = {
            is_checked: props.checked || false,
            value: props.value || ''
        }
    }
    checkCheckBox() {
        const { checkboxGroup } = this.context;
        if (checkboxGroup) {
            checkboxGroup.toggleOption({ label: this.props.children, value: this.props.value })
        } else {
            const onChange = this.props.onChange;
            const value = this.props.value;
            if (onChange) {
                onChange(value);
            }
        }
    }
    render() {
        let { is_checked, value } = this.state;
        const { checkboxGroup } = this.context;
        if (checkboxGroup) {
            is_checked = checkboxGroup.value.indexOf(this.props.value) !== -1;
        }
        return (
            <label>
                <input value={value} type="checkbox" checked={is_checked}
                    onClick={this.checkCheckBox} />
                {this.props.children !== undefined ? this.props.children : null}
            </label>
        )
    }
}
CheckBox.Group = CheckBoxGroup;
CheckBox.contextTypes = {
    checkboxGroup: PropTypes.any,
}
export default CheckBox;

```

子组件在点击的时候，会先判断是否有包裹的`this.content.checkboxGroup` 属性。如果有，就把状态转移到包裹的组件去管理。
`CheckBox.Group = CheckboxGroup` 这段代码方便外部调用组件，即想引用CheckBoxGroup组件可以写成

```
import CheckBox from './components/CheckBox/CheckBox'
const CheckBoxGroup = CheckBox.Group;
```
然后在App.js 中引入
```
//App.js
import React, { Component } from 'react';
import logo from './logo.svg';
import './App.css';
import Blog from './components/Blog/Blog'
import CheckBox from './components/CheckBox/CheckBox'
const CheckBoxGroup = CheckBox.Group;

class App extends Component {
  state={
    checkList:[]
  }
  selectCheckBtn=(values)=>{
    console.log(values)
    this.setState({
      checkList:values
    })
  }
    render() {
    const {checkList} = this.state
    return (
      <div className="App">
        <header className="App-header"> 
         <img src={logo} className="App-logo" alt="logo" />  
         <h1 className="App-title">Welcome to React</h1>
        </header> 
        <p className="App-intro">
          To get started, edit <code>src/App.js</code> and save to reload.
        </p>
        <Blog/>
        <CheckBoxGroup value={checkList} onChange={this.selectCheckBtn}> 
          <CheckBox value={'1'}>按钮1</CheckBox>
          <CheckBox value={'2'}>按钮2</CheckBox>
          <CheckBox value={'3'}>按钮3</CheckBox>
          <CheckBox value={'4'}>按钮4</CheckBox>
        </CheckBoxGroup>
      </div>
    );
  }}
export default App;

```

最后在浏览器点击复选框

<img src="//ww1.sinaimg.cn/large/933205a1ly1fp04zmphioj21py0pygpy.jpg"/>

现在，我们就完成了一个复选框组件，可以给组件加上一些样式美化一下，然后在需要的时候直接引用就好了。

### 最后

写一个组件很容易，但是写好一个组件就不是那么容易的事了，React也有一些现在比较成熟的UI组件库，比如蚂蚁金服的Antd Design [传送门](//github.com/ant-design/ant-design/) ，可以打开看看里面的源码学习一下。




