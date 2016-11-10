title: Vue实战(一) -- Vue基础总结
date: 2016-11-09 12:00:00
categories: zhouxiong
tags:
- Vue.js
---
Vue作为一个前端轻量级的MVVM框架有其独到之处,本文主要针对Vue1.0版本的官方文档进行梳理总结,主要包括以下几个方面:
1.数据绑定
2.指令
3.组件
4.事件
5.过滤器


<!-- more -->
## Vue基础

### Vue实例

#### 构造器
通过构造函数可以创建一个Vue的根实例：

```
var vm = new Vue({
  // 选项
});
```
一个Vue的实例是MVVM模型中的ViewModel，在实例化时，需要传入一个选项对象，其中包括挂载元素、数据、模板、方法，生命周期的钩子函数等

#### 实例生命周期

![实例生命周期](/uploads/zhouxiong/vue-in-action-vue-basis/lifecycle.png)

### 数据绑定

Vue.js的模板是基于DOM实现的，Vue的模板都是可解析的有效HTML，且通过一些特性做了增强。

#### 插值

- 文本

最基本的数据绑定形式就是文本插值，使用Mustache语法-双大括号：

```
<span>Message: {{ msg }}</span>
```
Mustache标签会被数据对象中的msg值替换，每当属性值发生变化对应也会更新到DOM上

- 原始的HTML

有的时候要输出真正的HTML字符串，则需要用到三Mustache标签，此时的数据绑定会被忽略

```
<div>{{{ raw_html }}}</div>
```
**注意：在网站上动态渲染任意的HTML是非常危险的，容易导致XSS攻击。因此只对可信的HTML使用插值，永不用于用户提交的内容**

- HTML特性

Mustache标签也可以用在HTML属性中

```
<div id="item-{{ id }}"></div>
```
但是在Vue.js指令和特殊特性内不能使用插值

#### 绑定表达式

放在Mustache标签内的文本成为绑定表达式，可以由一个简单的Javascript表达式和可选的一个或多个过滤器组成

- javascript表达式

 ```
	{{ number + 1 }}
	
	{{ ok ? 'YES' : 'NO' }}
	
	{{ message.split('').reverse().join('') }}

 ```
 
#### 过滤器

Vue.js允许在表达式后添加可选的过滤器，以‘管道符’形式

```
{{ message | capitalize }}
```
上述语句表示将`message`的值通过内置的`capitalize`过滤器，这个过滤器其实是一个函数，返回大写的值

过滤器可以串联

 ```
{{ message | filterA | filterB }}
 ```

同时可以接收参数

```
{{ message | filterA 'arg1' arg2 }}
```
过滤器函数始终以表达式的值作为第一个参数。带引号的参数视为字符串，而不带引号的参数按表达式计算。这里，字符串 'arg1' 将传给过滤器作为第二个参数，表达式 arg2 的值在计算出来之后作为第三个参数。


### 指令

指令是特殊的带有前缀`v-`特性。指令的值限定为**绑定表达式**，它的职责是当其表达式的值改变时把某些行为应用到DOM上。

- v-if、v-show与v-else

 ```
<p v-if="greeting">Hello!</p>
 ```
 这里通过`v-if`指令将表达式`greeting`的值真假插入/删除p元素。


 上述指令用于条件渲染，根据绑定的表达式结果确定是否要渲染HTML元素。`v-else` 元素必须立即跟在 `v-if` 或 `v-show` 元素的后面——否则它不能被识别。
 
 - 区别
  
 `v-if` 是真实的条件渲染，因为它会确保条件块在切换当中合适地销毁与重建条件块内的事件监听器和子组件
  
 `v-show` 绑定的元素始终被编译并保留，只是简单地基于 CSS 切换，另外它不支持`<template>`标签
  
   一般来说，`v-if` 有更高的切换消耗而 `v-show `有更高的初始渲染消耗。因此，如果需要频繁切换 `v-show` 较好，如果在运行时条件不大可能改变 `v-if` 较好
  

 
- v-on

  利用`v-on`指令用于监听DOM事件，例如：`<a v-on:click="doSomething">`
 
  另外`v-on`指令还可以缩写成`@`符号表示：
 
 ```
	<!-- 完整语法 -->
	<a v-on:click="doSomething"></a>
	
	<!-- 缩写 -->
	<a @click="doSomething"></a>
  ```
 
- v-bind
 
 利用`v-bind`指令用于响应的更新HTML属性，例如：`<a v-bind:href="url"></a>`
 
 另外`v-bind`指令还可以缩写为`:`表示：

 ```
	<!-- 完整语法 -->
	<a v-bind:href="url"></a>
	
	<!-- 缩写 -->
	<a :href="url"></a>
	
	<!-- 完整语法 -->
	<button v-bind:disabled="someDynamicCondition">Button</button>
	
	<!-- 缩写 -->
	<button :disabled="someDynamicCondition">Button</button>
 ```
 
- v-model

 此指令用于表单元素上，例如常见的input，select，textarea，radio，checkbox等
 
  ```
   <select v-model="selected" multiple>
	  <option selected>A</option>
	  <option>B</option>
	  <option>C</option>
  </select>
  <br>
  <span>Selected: {{ selected | json }}</span>
  ```
 
- v-for

 `v-for`指令基于一个数组渲染一个列表。还有一个特殊的变量`$index`，它是当前数组元素的索引
 
  ```
  <ul id="example-1">
	  <li v-for="item in items">
	     {{ parentMessage }} - {{ $index }} - {{ item.message }}
	  </li>
 </ul>

 var example1 = new Vue({
	  el: '#example-1',
	  data: {
	    items: [
	      { message: 'Foo' },
	      { message: 'Bar' }
	    ]
	  }
 })
  ```
  
 Vue.js封装了数组的变异方法，例如`push`,`pop`,`shift`, `unshift`等和非变异方法，例如`filter`,`concat`等，如果是非变异的方法，则只需要直接使用返回的新数组替换原来的数组即可
 
  ```
  example1.items = example1.items.filter(function (item) {
       return item.message.match(/Foo/)
  })
  ```
 
 - track-by

  列表在渲染的过程中通过唯一的键进行追踪，可以通过数组中每个值的唯一id进行标识或者通过`$index`，这种模式下可以处理数组中重复的值
  
   ```
    <div v-for="item in items" track-by="$index">
	  <!-- content -->
   </div>
   ```
 
### 计算属性
在Vue.js中将绑定表达式限定为一个表达式，如果需要多余一个表达式的逻辑，应当使用计算属性。一个比较常见的应用方式是b属性的值依赖于a属性的值，则b应当设置为计算属性。计算属性同样具有getter和setter方法

 ```
var vm = new Vue({
  data: {
    firstName: 'Foo',
    lastName: 'Bar'
  },
  computed: {
      fullName: {
	    // getter
	    get: function () {
	     	return this.firstName + ' ' + this.lastName
	    },
	    // setter
	    set: function (newValue) {
	        var names = newValue.split(' ')
	        this.firstName = names[0]
	        this.lastName = names[names.length - 1]
	    }
     }
  }
})
 ```
此时的`vm. fullName`依赖于`vm. firstName `和`vm. lastName`，所以当`vm. firstName`和`vm. lastName`的值改变的时候，`vm. fullName`值也会相应的进行改变。同样的如果调用`vm.fullName = 'John Doe'` 时，setter 会被调用，`vm.firstName` 和 `vm.lastName` 也会有相应更新
 
### Class与style绑定
数据绑定的一个常见需求是操作元素的class和它的内联样式。因为它们都是HTML元素的属性，可以用`v-bind`来处理它们：只需要计算出表达式最终字符串。在`v-bind`用于绑定class和style时，Vue.js专门对其进行增强，使得表达式的结果类型除了字符串外，还可以是对象或者数组。

**注意：尽管可以用Mustache标签绑定class，例如class={{className}}，但是不推荐和v-bind:class=className这种方式混用。两者只能选其一**

#### 绑定class

- 对象语法

可以给`v-bind:class`传递一个对象，以动态的切换class。注意`v-bind:class`可以和普通的`class`共存。

```
<div class="static" v-bind:class="{ 'class-a': isA, 'class-b': isB }"></div>

```

```
data: {
  isA: true,
  isB: false
}
```
渲染为：

```
<div class="static class-a"></div>
```

- 数组语法

可以把一个数组传递给`v-bind:class`，以应用一个class列表

```
<div v-bind:class="[classA, classB]">
``` 
```
 data: {
  classA: 'class-a',
  classB: 'class-b'
}
```
渲染为：

```
<div class="class-a class-b"></div>
```

#### 绑定style内联样式
`v-bind:style`与`v-bind:class`使用方式相同，可以使用对象语法和数组语法。css属性名可以采用驼峰式或者短横线分割命名。

- 对象语法

 ```
 <div v-bind:style="styleObject"></div>
 ```
 ```
  data: {
	  styleObject: {
	      color: 'red',
	      fontSize: '13px'
	  }
}
 ```
 
- 数组语法

 可以将多个样式对象应用到一个元素上
 `<div v-bind:style="[AStyle, BStyle]">`
 
 ```
  AStyle: {
        color: 'red'
    },
    BStyle: {
        fontSize: '22px'
    }
 ```
 
### 表单控件绑定

可以通过`v-model`指令在表单元素上创建双向数据绑定

#### Text

```
<span>Message is: {{ message }}</span>
<br>
<input type="text" v-model="message" placeholder="edit me">

```

#### Checkbox

多个复选框，绑定到同一个数组

```
<input type="checkbox" id="jack" value="Jack" v-model="checkedNames">
<label for="jack">Jack</label>
<input type="checkbox" id="john" value="John" v-model="checkedNames">
<label for="john">John</label>
<input type="checkbox" id="mike" value="Mike" v-model="checkedNames">
<label for="mike">Mike</label>
<br>
<span>Checked names: {{ checkedNames | json }}</span>
```

```
new Vue({
  el: '...',
  data: {
    checkedNames: []
  }
})
```

#### Radio

```
<input type="radio" id="one" value="One" v-model="picked">
<label for="one">One</label>
<br>
<input type="radio" id="two" value="Two" v-model="picked">
<label for="two">Two</label>
<br>
<span>Picked: {{ picked }}</span>
```

#### Select
 
 - 单选，value为单个字符串

 ```
<select v-model="selected">
	  <option selected>A</option>
	  <option>B</option>
	  <option>C</option>
</select>
<span>Selected: {{ selected }}</span>
 ```
 
 - 多选，value为一个数组

 ```
 <select v-model="selected" multiple>
	  <option selected>A</option>
	  <option>B</option>
	  <option>C</option>
</select>
<br>
<span>Selected: {{ selected | json }}</span>
 ```
 
#### 参数特性
 
 - lazy

 在默认情况下，`v-model`是在`input`事件中同步输入框值和数据，可以添加一个`lazy`属性，从而在`change`事件中同步
 
 ```
<!-- 在 "change" 而不是 "input" 事件中更新 -->
<input v-model="msg" lazy>
 ```

- debounce

 `debounce`设置一个最小延时，在每次敲击后延时同步输入框和数据，例如在输入过程中发送ajax请求时比较有用。`debounce`延迟写入底层数据，应当用`vm.$watch()`监听数据的变化。

 ```
 <input v-model="msg" debounce="500">
 ```
 
 `debounce`参数不会延迟DOM，若想延迟DOM事件，应当使用`debounce过滤器`。包装处理器，让它延迟执行，包装后的处理器将延迟`x`ms（默认为300ms）后执行，如果在延迟结束前再次调用，延时时长重置为`x`ms
 
 ```
 <input @keyup="onKeyup | debounce 500">
 ```
 
### 方法和事件处理器

#### 方法处理器

可以通过`v-on`指令监听DOM事件，事件监听程序都是写在`methods`属性中。在绑定方的时候，还可以传递参数，包括event对象，在HTML语句中需要使用`$event`进行传递。并且这个`$event`是原生的event对象，包含原生的event事件属性和方法。

```
<div id="example">
  <button v-on:click="greet($event, 'Vue.js')">Greet</button>
</div>
```

绑定一个事件处理方法`greet`

```
var vm = new Vue({
  el: '#example',
  // 在 `methods` 对象中定义方法
  methods: {
    greet: function (event, msg) {
      // 方法内 `this` 指向 vm
      alert('Hello ' + msg + '!')
      // `event` 是原生 DOM 事件
      alert(event.target.tagName)
    }
  }
})

// 也可以在 JavaScript 代码中调用方法
vm.greet() // -> 'Hello Vue.js!'
```
#### 事件修饰符

在事件处理器中，通常需要使用到`event.stopPropagation()`和`event.preventDefault()`，在Vue.js中为`v-on`指令添加了`.stop`和`.prevent`两个命令修饰符

```
<!-- 阻止单击事件冒泡 -->
<a v-on:click.stop="doThis"></a>

<!-- 提交事件不再重载页面 -->
<form v-on:submit.prevent="onSubmit"></form>

<!-- 修饰符可以串联 -->
<a v-on:click.stop.prevent="doThat">

<!-- 只有修饰符 -->
<form v-on:submit.prevent></form>

<!-- 添加事件侦听器时使用 capture 模式 -->
<div v-on:click.capture="doThis">...</div>

<!-- 只当事件在该元素本身（而不是子元素）触发时触发回调 -->
<div v-on:click.self="doThat">...</div>
```

#### 按键修饰符

在监听键盘事件时，经常需要检测keyCode。Vue.js允许为`v-on`添加按键修饰符

```
<!-- 同上 -->
<input v-on:keyup.enter="submit">

<!-- 缩写语法 -->
<input @keyup.enter="submit">
```
全部按键的别名包括：

- enter
- tab
- delete
- esc
- space
- up
- down
- left
- right

### 组件

组件（component）是Vue.js最强大的功能之一。组件可以扩展HTML元素，封装可重用的代码。组件的使用过程包括定义和注册的过程。组件在注册之后便可以在父实例中以自定义的元素的形式使用，不过要确保在初始化根实例之前注册了组件。而且自定义元素只是作为一个挂载点

```
<div id="example">
  <my-component></my-component>
</div>
```
```
// 定义
var MyComponent = Vue.extend({
  template: '<div>A custom component!</div>'
})

// 注册
Vue.component('my-component', MyComponent)

// 创建根实例
new Vue({
  el: '#example'
})
```
渲染为：

```
<div id="example">
  <div>A custom component!</div>
</div>
```

#### 局部注册

有点时候并不需要注册全局组件，可以只让组件用在其他组件内部，用`components`进行注册

```
//定义子组件
var child = Vue.extend({
    template: '<div>this is child component </div>'
});

//定义父组件
var parent = Vue.extend({
    template: '<div>this is parent component <child-component></child-component> </div>',
    components: {
        //此时子组件child-component只能在父组件中使用
        'child-component': child
    }
});

//注册父组件
Vue.component('parent-component', parent);
```

#### 模板解析

Vue模板是DOM模板，使用浏览器原生的解析器而不是自己实现一个，所以HTML元素对什么元素可以放在它里面是有限制的。常见的限制如下：

- a 不能包含其它的交互元素（如按钮，链接）
- ul 和 ol 只能直接包含 li
- select 只能包含 option 和 optgroup
- table 只能直接包含 thead, tbody, tfoot, tr, caption, col, colgroup
- tr 只能直接包含 th 和 td

#### 组件选项

在组件内部也会使用数据变量，变量值也会存在data选项中，但是不同于Vue实例的data属性，组件内部的data属性应该是一个函数，在这个函数中返回一个新的对象，其中包含需要的属性名和属性值。

 ```
var MyComponent = Vue.extend({
  data: function () {
    return { a: 1 }
  }
})
 ```

#### 使用props进行传值

组件实例的作用域是孤立的，在子组件中不能直接使用父组件中的属性。可以使用props属性将数据传递给子组件。是传递字面量还是动态值通过是否使用`v-bind`指令来确定。

```
var child = Vue.extend({
    template: '<div>this is child component  {{attrA}} {{attrB}}</div>',
    props: ['attrA', 'attrB']
});

var parent = Vue.extend({
    template: '<div>this is parent component {{a}} ' +
              '<child-component v-bind:a="aa" attr-a="attrA" v-bind:attr-b="attrB"></child-component>' +
              '</div>',
    components: {
        'child-component': child
    },
    data: function () {
        return {
            attrA: dynamic  attrA',
            attrB: 'dynamic attrB'
        }
    }
});
```
 
渲染为：

```
<div>this is child component  attrA dynamic attrB</div>
```
**注意：子组件内部具有的属性不能和继承的属性相同，即不能在子组件的data和props中出现相同的变量名，否则程序会报错**

#### 父子组件通信

子组件可以通过`this.$parent`访问它的父组件，父组件有一个`this.$children`，包含子组件的列表。根实例的后代通过`this.$root`访问它。

尽管可以访问到父链上的任意实例，不过子组件应该避免直接依赖父组件的数据，而是通过props属性进行传递，而且在子组件中也不要修改父组件中的状态，理想情况下只有组件自己才可以修改它的状态。

#### 自定义事件

Vue.js实现了一个自定义的事件接口，用于在组件树中通信。这个事件系统独立于原声DOM事件，用法也不同。

每个Vue实例都是一个事件触发器

- 使用`$on`监听事件
- 使用`$emit`在它上面触发事件
- 使用`$dispatch`派发事件，事件沿着父链冒泡。**不同于DOM原生事件，Vue事件在冒泡过程中第一次触发回调后自动停止冒泡，除非回调函数明确返回`true`**
- 使用`$broadcast`广播事件，事件向下传导给所有后代

```
<!-- 子组件模板 -->
<template id="child-template">
  <input v-model="msg">
  <button v-on:click="notify">Dispatch Event</button>
</template>

<!-- 父组件模板 -->
<div id="events-example">
  <p>Messages: {{ messages | json }}</p>
  <child></child>
</div>
```

```
// 注册子组件
// 将当前消息派发出去
Vue.component('child', {
  template: '#child-template',
  data: function () {
    return { msg: 'hello' }
  },
  methods: {
    notify: function () {
      if (this.msg.trim()) {
        this.$dispatch('child-msg', this.msg)
        this.msg = ''
      }
    }
  }
})

// 初始化父组件
// 将收到消息时将事件推入一个数组
var parent = new Vue({
  el: '#events-example',
  data: {
    messages: []
  },
  // 在创建实例时 `events` 选项简单地调用 `$on`
  events: {
    'child-msg': function (msg) {
      // 事件回调内的 `this` 自动绑定到注册它的实例上
      this.messages.push(msg);
    }
  }
})
```

#### 使用slot分发内容

每个组件都有自己的作用域，父组件模板的内容在父组件作用域内编译，子组件模板的内容在子组件作用域内编译。如果要绑定一个指令打到组件的根节点上，应该按如下方式：

```
Vue.component('child-component', {
  // v-show指令有效，因为是在正确的作用域内
  template: '<div v-show="someChildProperty">Child</div>',
  data: function () {
    return {
      someChildProperty: true
    }
  }
})
```
类似的，分发内容也是在父组件的作用域内编译。

- slot

 父组件的内容在渲染的时候会被抛弃，除非子组件包含了`slot`标签。如果子组件只包含一个`slot`，则父组件的内容将被添加到`slot`标签中；如果子组件具有多个`slot`标签，可以通过`slot`标签的`name`属性进行分发。在具有多个`slot`标签时，仍然可以有一个匿名的`slot`，它是默认的`slot`，作为找不到匹配的内容的`slot`。
 
 子组件模板：
 
 ```
 <div>
	  <slot name="one"></slot>
	  <slot></slot>
	  <slot name="two"></slot>
</div>
 ```
 
 父组件模板：
 
 ```
  <multi-insertion>
	  <p slot="one">One</p>
	  <p slot="two">Two</p>
	  <p>Default A</p>
   </multi-insertion>
 ```
 
 渲染为：
 
 ```
   <div>
	  <p slot="one">One</p>
	  <p>Default A</p>
	  <p slot="two">Two</p>
   </div>
 ```
 
#### 编写可复用的组件

在编写组件的时候，如果需要达到可复用的目的，应当定义一个清晰的公开接口。Vue.js组件的API来自三个部分：props、事件和slot

- **props**允许外部环境传递数据给组件
- **事件**允许组件触发外部环境的action
- **slot**允许外部环境的内容插入到组件内部结构中

通常一个组件模板的清晰结构如下：

```
 <my-component
  :foo="baz"
  :bar="qux"
  @event-a="doThis"
  @event-b="doThat">
  <!-- content -->
  <img slot="icon" src="...">
  <p slot="main-text">Hello!</p>
</my-component>
```

### 自定义指令

除了Vue内置的指令外，还可以自定义指令。自定义指令提供一种机制将数据变化映射为DOM行为。通过`Vue.directive(id, definition)`方法注册一个全局自定义指令，它接收两个参数，指令ID和定义对象。在HTML元素中使用自定义指令时，需要添加`v-`前缀

#### 钩子函数

定义对象中定义了几个可选的钩子函数

- bind：只调用一次，在指令第一次绑定到元素上时调用
- update：在bind后立即以初始值为参数第一次调用，以后每次绑定的值发生变化时，触发一次，参数为新值和旧值
- unbind：只调用一次，在指令元素上解绑时调用

```
Vue.directive('my-directive', {
	  bind: function () {
	    // 准备工作
	    // 例如，添加事件处理器或只需要运行一次的高耗任务
	  },
	  update: function (newValue, oldValue) {
	    // 值更新时的工作
	    // 也会以初始值为参数调用一次
	  },
	  unbind: function () {
	    // 清理工作
	    // 例如，删除 bind() 添加的事件监听器
	  }
})
```

#### 指令实例属性

在钩子函数内`this`执行这个指令对象。这个对象暴露了一些实例属性：

- **el**：指令绑定的元素
- **vm**：拥有该指令的上下文ViewModel
- **expression**：指令表达式
- **arg**：指令参数
- **name**：指令名称
- **modifiers**：指令修饰符对象
- **descriptor**：指令解析的结果对象

**注意:这些属性我们应该将其视为可读的，不要修改他们。可以添加自定义属性，但不要覆盖已有的内部属性**

```
<div id="demo" v-demo:hello.a.b="msg"></div>
```

```
 Vue.directive('demo', {
	  bind: function () {
	    console.log('demo bound!')
	  },
	  update: function (value) {
	    this.el.innerHTML =
	      'name - '       + this.name + '<br>' +  
	      'expression - ' + this.expression + '<br>' +
	      'argument - '   + this.arg + '<br>' +
	      'modifiers - '  + JSON.stringify(this.modifiers) + '<br>' +
	      'value - '      + value
	  }
});
var demo = new Vue({
	  el: '#demo',
	  data: {
	    msg: 'hello!'
	  }
})
```

结果为：

```
 name - demo
 expression - msg
 argument - hello
 modifiers - {a: true, b: true}
 value - hello!
```

#### 高级选项-params

类似于自定义组件的`props`属性，自定义指令提供`params`属性，指令一个数组列表，Vue编译器将自动提取绑定元素的这些特性。而且`params`还支持动态属性，另外还可以指定一个回调，在值变化时调用

```
<div v-example v-bind:a="someValue"></div>
```

```
Vue.directive('example', {
  params: ['a'],
  paramWatchers: {
    a: function (val, oldVal) {
      console.log('a changed!')
    }
  }
})
```

### 自定义过滤器
类似于自定义指令，可以通过`Vue.filter()`注册一个全局自定义过滤器，接收两个参数：过滤器ID和过滤器函数，过滤器函数以值为参数，返回转换后的值

自定义过滤器可以接收任意数量的参数，第一个参数为表达式的值，从第二个参数开始可以传递任意值，字面量或者计算表达式

```
Vue.filter('wrap', function (value, begin, end) {
    return begin + value + end
});

var vm = new Vue({
    el: '#demo',
    data: {
   	   after: 'last'
    }
});
```

```
<!-- 'hello' => 'before hello after' -->
<span v-text="message | wrap 'before' after"></span>
```







