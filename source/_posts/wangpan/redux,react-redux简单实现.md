title: redux,react-redux简单实现
date: 2018-05-01
categories: wangpan
tags:
- react
- redux
---
## 简介 
redux解决了react只专注view层却没有涉及到的 代码结构 和组件通信的关键问题，本文主要目的是实现一个简单的redux和react-redux并且实现其middleware中间件机制。

<!--more-->

### 前言
在react项目中，如果你的UI层非常简单，没有很多的互动，那么redux是没有必要的。
redux是一个有用状态架构，所有的状态保存在一个对象中，对于大型的复杂应用， 代码结构和组件通信是极为关键的，而redux就是解决这两方面的问题。
### 一、redux使用场景
**适用redux的场景**：
* 用户的使用方式复杂
* 不同身份的用户有不同的使用方式（比如普通用户和管理员）
* 多个用户之间可以协作
* 与服务器大量交互，或者使用了WebSocket
* View要从多个来源获取数据

**从组件角度看**:
* 某个组件的状态，需要共享
* 某个状态需要在任何地方都可以拿到
* 一个组件需要改变全局状态
* 一个组件需要改变另一个组件的状态

### 二、redux常用API
* createStore<store>()    创建stroe 返回store对象
* store.getState<state>() 返回state
* store.subscribe()       订阅store
* store.dispatch()        提交状态变更的申请


### 三、redux简单实现

整体架构
```javascript
export function createStore(reducer) {
    let currentState = {}
    let currentListeners = []

    function getState() {
        return currentState
    }
    function subscirbe(listener) {}
    function dispatch (action) {}
    // 初始执行一次，获得初始化状态
    dispatch({ type: '@first_init@wangpan' })

    return {
        getState, subscribe, dispatch
    }
}

function bindActionCreator (creator, dispatch) {
    return (...args) => dispatch(creator(...args))
}

export bindAcitonCreators(creators, dispatch) {
    let bound = {}
    Object.keys(creators).forEach(v => {
        let creator = creators[v]
        bound[v] = bindActionCreator(creator, dispatch)
    })
}
```
subcribe函数，传入监听函数，注意对参数校验，因为只是简单实现，我这就不写啦
```javascript
// subscribe订阅函数 传入listener函数
function subscribe (listenr) {
    currentListeners.push(listener)
}
```
dispatch函数，传入action,同样可以对参数进行校验
```javascript
function dispatch (action) {
    currentState = reducer(currentState, aciton)
    // state改变，执行订阅函数，这就是一个最基本的发布者订阅者模式
    currentListeners.forEach(v => v())
    return aciton
}
```
以上一个最简单的redux就是实现了，现在暂且不实现redux中间件，下面我们看看react-redux实现

### 四、react-redux简单实现
在实现react-redux之前，先来看看react的context,这是实现react-redux的关键
在react父子组件通信是非常简单的，通过props就可以实现，但是在多层级的场景下通信通过props一层一层传递是非常麻烦而且不友好的,所以react提供context实现组件的跨多层级通信。



react-redux基本架构
```javascript
import React from 'react'
import Proptypes from 'prop-types'
import { bindAcitonCreators } from 'redux'
// 负责链接组件，将redux中的数据放入组件
// 高阶组件
export const connect(mapStateToProps = state => state, mapDispatchToProps = {}) =>(WrapComponent) => {
    return class ConnectComponent extends React.Component {
        static contextTypes = {
            store: PropTpes.object
        }
        constructor (props, context) {
            super(props)
            this.state = {
                props: {}
            }
        }

        componentDidMount() {
            this.update()
            const { store } = this.context
            store.subscribe(() => this.update())
            this.update()
        }

        update () {
            const { store } = this.context
            const stateProps = mapStateToProps(store.getState())
            const dispatchProps = bindAcitonCreators(mapDispatchToProps, store.dispatch)
            this.setState({
                props: {
                    ...this.state.props
                    ...stateProps
                    ...dispatchProps
                }
            })
        }

        render() {
            return <WrapComponent {...this.state.props} />
        }
    }
}
// Provider组件，把strore放入context中，所有子元素可以直接去到store
export class Provider extends React.Component {
    static childContextTypes = {
        store: Proptypes.object
    }
    getchildContext () {
        return {
            store: this.store
        }
    }
    constructor (props, context) {
        super(props, context)
        this.store = props.store
    }
    render () {
        return this.props.children
    }
}
```

### 五、中间件机制
在之前的redux基础上添加applyMiddleware函数，并且扩展crateStore函数
```javascript
export function createStore (reducer, enhancer) {
    // 如果中间件存在
    if (enhancer) {
        return enhancer(createStore)(reducer)
    }
    ...
}

export function applyMiddleware(middleware) {
    return createStore => (...args) => {
        const store = createStore(...args)
        const dispatch = store.dispatch

        const midApi = {
            getState: store.getState,
            dispatch: (...args) => dispatch(...args)
        }

        dispatch = middleware(midApi)(store, dispatch)

        return {
            ...store,
            dispatch
        }
    }
}
```

### 六、redux-thunk简单实现
```javascript
const thunk = ({dispatch, getState}) => next => action => {
    if (typeof action === function) {
        return action(dispatch, getState)
    }
    return next(action)
}
export default thunk
```
以上就基本实现了一个最简单的redux和react-redux