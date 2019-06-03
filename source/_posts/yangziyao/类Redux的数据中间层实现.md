title: 类Redux的数据中间层的实现               
date: 2019-05-26 10:00:00                   
categories: yangziyao                                                     
tags:         
- javascript                             
- redux
---
关于全局单项数据流+视图层computed属性的一个简单实现。

<!--more-->
# 数据中间层简介
在上家公司工作时，由于使用自研框架比较陈旧，不支持全局的跨视图的数据复用。又由于当时react的BSD+Patents证书事件，团队决定放弃引入开源……于是就自己造了一个支持单项数据流的轮子，就是本文介绍的数据中间层。在视图数据层面，也实现了类似vue的computed属性来优化开发体验。

# 模块结构
![](https://github.com/zero-yang/assets/blob/master/data-midware.png?raw=true)

## Store

Store模块负责存储全局数据和定义操作数据的actions。

## ViewModel
ViewModel模块负责维护视图自身的数据，接收来自Store的change事件以响应Store数据变更，通过dispatch action操作Store中的数据。

## Updater
Updater模块定义了数据的操作，包括set，get，assign等，可以通过指定数据源对Store或者ViewModel的实例进行操作。同时也定义了dispatch操作。

# 代码实现

由于这是一年半前写的代码，还有种种原因不，这里只介绍主要的实现思路，具体实现还需要考虑很多边界场景，这里就不细说了。

## Store

Store的代码实现很简单，主要包含存储数据的对象，定义action对象的数组，以及注册action的方法。

```javascript
const Store = {
    state: {}, 
    actions: [
        {
            name: 'setFormData',
            async method() {
                // ...
            }
        }
    ],
    addAction(actionList) {
        this.actions.concat(actionList);
    }
};
```

其中，action对象中的name类似于redux中的常量，method类似于reducer，可以是异步方法。不同业务模块的action可以维护在独立的模块中，通过Store.addAction注册到Store中。

## Updater

Updater负责数据的操作和不同数据实体间的交互，是三个模块中最核心的模块。包含了数据操作的set，get和assign，处理action的dispatch。还有一个buildFactory方法，是为了保证在执行action的过程中对Store数据操作的原子性。

```javascript
const Updater = {
    find(source = {}, path, create) {
        // ...
    },
    assign(source, path, value) {
    	 // ...
    },
    set(source, path, value) {
        // ...
    },
    get(source, path) {
        // ...

    },
    async dispatch(source, action) {
        // ...

    },
    buildFactory(source) {
        // ...
    }
}
```

下面我们来详细介绍这几个方法。

### find

对指定数据源和路径进行查找，返回对应字段的父级和对应字段的key，可指定路径中的属性不存在是否创建。

```javascript
find(source = {}, path, create) {
    const tmp = path.split('.');

    for (let i = 0; i < tmp.length - 1; i ++) {
        let next = source[tmp[i]];

        if (!next && create) {
            source[tmp[i]] = {};
        }

        source = next || {};
    }

    return {
        key: tmp[tmp.length - 1],
        source
    };
}
```

### set

设置指定数据源对应路径的值。

```javascript
set(source, path, value) {
    const setObj = this.find(source, path, true);

    setObj.source[setObj.key] = value;

    return path;
}
```

### assign

跟set类似，只不过是将赋值变成对象合并。


### get 

获取指定数据源对应路径的数据。

```javascript
get(source, path) {
    const result = this.find(source, path);

    return result.source[result.key];
}
```

### dispatch

执行action，在执行完成后触发storeChange事件。为了保证action对Store写操作的原子性，在执行action过程中，将所有写操作先以指令的形式储存在通过buildFactory方法创建的一个factory里，再一次性进行写入操作。

```javascript
async dispatch(source, action) {
    const factory = this.buildFactory(source);
    const handler = Store.actions[action];

    await handler(factory.get, factory.set, factory.assign);

    const diff = factory.applyDirective();
    
    if (diff.length > 0) {
        Event.emit('storeChange', {
            diff
        });
    }
}
```

### buildFactory

创建指令工厂对象，提供所有Store写操作的mock方法，mock方法将所有操作以指令形式保存在fatory里，通过applyDirective方法一次执行，并返回操作的结果。

```javascript
buildFactory(source) {
    const factory = {
        directives: [],
        source
    };

    ['set', 'assign'].reduce((fac, key) => {
        fac[key] = (path, value) => {
            fac.directives.push({
                type: key,
                path,
                value
            });
        }
    }, factory);

    factory.get = path => {
        return this.get(factory.source, path);
    }

    factory.applyDirective = () => {
        let diff = [];

        factory.directives.forEach(directive => {
           diff = diff.concat(this[directive[key]](factory.source, directive[path], directive[value]));
        });

        return diff;
    }
}
```

## ViewModel

ViewModel负责维护视图的数据，提供了类似vue的computed属性，并通过computed属性维护ViewModel实例到Store的数据依赖关系。

```javascript
class ViewModel {
    constructor() {
        // ...
    }
    calDiff(diffFromStore) {
        // ...
    }
    initComputed() {
        // ...
    }
}
```

### constructor

监听storeChange事件，根据diff计算自身的数据变更。

```javascript
constructor() {
    Event.on('storeChange', diff => {
        this.emit('change', this.calDiff(diff));
    })
}
```

### initComputed

初始化computed属性，建立computed属性对自身数据字段以及Store数据字段的依赖关系。

```javascript
initComputed() {
    Object.keys(this.computed).forEach(key => {
        this.computed[key](
            path => {
                //从自身state里获取数据方法
                if (!this.__bindWithState__[path]) {
                    this.__bindWithState__[path] = [];
                }

                this.__bindWithState__[path].push(key);

                return Updater.get(this.state, path);
            },

            path => {
                //从全局store里获取数据方法
                if(!this.__bindWithStore__[path]) {
                    this.__bindWithStore__[path] = [];
                }

                this.__bindWithStore__[path].push(key);

                return Updater.get(store, path);
            }
        );
    });
}
```

### calDiff

根据Store数据的diff计算自身数据的变更。

```javascript
calDiff(diffFromStore) {
    let stateDiff = [];

    diffFromStore.forEach(diffPath => {
        if (this.__bindWithStore__[diffPath]) {
            stateDiff = stateDiff.concat(this.__bindWithStore__[diffPath]);
        }
    });

    let diffDueToState = [];

    stateDiff.forEach(diffPath => {
        if (this.__bindWithState__[diffPath]) {
            diffDueToState = diffDueToState.concat(this.__bindWithState__[diffPath]);
        }
    });

    return Array.from(new Set(stateDiff.concat(diffDueToState)));
}
```

### 环依赖检测

为了避免在computed属性里遇到环依赖的情况，因此需要一个环依赖检测的方法。depTree为ViewModel实例里的__bindWithStore__或者__bindWithState__对象。

```javascript
function circleDetection(depTree) {
    const root = Object.keys(depTree);

    function doDetection(node, parentSet) {
        const deps = depTree[node];
    
        if (!deps || deps.length === 0) {
            return true;
        }
    
        for (let i = 0; i < deps.length; i ++) {
            const depNode = deps[i];
    
            if (parentSet.has(depNode)) {
                return false;
            } else {
                return doDetection(depNode, parentSet);
            }
        }
    }

    for (let i = 0; i < root.length; i ++) {
        const pSet = new Set();
        const rNode = root[i];

        pSet.add(rNode);

        if(!doDetection(rNode, pSet)) {
            return false;
        }
    }

    return true;
}
```

# 总结

以上就是数据中间层实现的一个大致的思路，希望能对大家有帮助，有问题欢迎指正~