title: Angular的自动化测试
date: 2015-12-17
categories: HeOH
tags: 
- angular
- karma
- jasmine
- 测试
- 单元测试
- 端到端测试

---



当Angular项目的规模到达一定的程度，就需要进行测试工作了。本文着重介绍关于ng的测试部分，主要包括以下三个方面：
	
1. 框架的选择（Karma+Jasmine）
2. 测试的分类和选择（单元测试 + 端到端测试）
3. 在ng中各个模块如何编写测试用例

下面各部分进行详细介绍。

<!-- more -->

### 测试的分类

在测试中，一般分为`单元测试`和`端到端测试`，单元测试是保证开发者验证代码某部分有效性的技术，端到端（E2E）是当你想确保一堆组件能按事先预想的方式运行起来的时候使用。

其中单元测试又分为两类： `TDD(测试驱动开发)`和`BDD(行为驱动开发)`。下面着重介绍两种开发模式。

- TDD（测试驱动开发 Test-driven development）是使用测试案例等来驱动你的软件开发。

	如果我们想要更深入点了解TDD，我们可以将它分成五个不同的阶段：
	
	1. 首先，开发人员编写一些测试方法。

	2. 其次，开发人员使用这些测试，但是很明显的，测试都没有通过，原因是还没有编写这些功能的代码来实际执行。

	3. 接下来，开发人员实现测试中的代码。

	4. 如果开发人员写代码很优秀，那么在下一阶段会看到他的测试通过。

	5. 然后开发人员可以重构自己的代码，添加注释，使其变得整洁，开发人员知道，如果新添加的代码破坏了什么，那么测试会提醒他失败。
	
	其中的流程图如下：
	![TDD](http://images.cnitblog.com/blog/672888/201410/271613208781121.png)
	
	TDD的好处：
	
	1. 能驱使系统最终的实现代码，都可以被测试代码所覆盖到，也即“每一行代码都可测”。
	
	2. 测试代码作为实现代码的正确导向，最终演变为正确系统的行为，能让整个开发过程更加高效。
		
- BDD是（行为驱动开发 Behavior-Driven Development）指的是不应该针对代码的实现细节写测试，而是要针对行为写测试。BDD测试的是行为，即软件应该怎样运行。

	- 和TDD比起来，BDD是需要我们先写行为规范（功能明细），在进行软件开发。功能明细和测试看起来非常相似，但是功能明细更加含蓄一些。BDD采用了更详细的方式使得它看起来就像是一句话。
	
	- BDD测试应该注重功能而不是实际的结果。你常常会听说BDD是帮助设计软件，而不是像TDD那样的测试软件。

最后总结：TDD的迭代反复验证是敏捷开发的保障，但没有明确如何根据设计产生测试，并保障测试用例的质量，而BDD倡导大家都用简洁的自然语言描述系统行为的理念，恰好弥补了测试用例（即系统行为）的准确性。


### 测试框架选择

利用karma和jasmine来进行ng模块的单元测试。

- Karma:是一个基于Node.js的JavaScript测试执行过程管理工具，这个测试工具的一个强大特性就是，它可以监控(Watch)文件的变化，然后自行执行，通过console.log显示测试结果。

- jasmine是一个行为驱动开发（BDD）的测试框架,不依赖任何js框架以及dom,是一个非常干净以及友好API的测试库.

#### Karma

karma是一个单元测试的运行控制框架,提供以不同环境来运行单元测试,比如chrome,firfox,phantomjs等,测试框架支持jasmine,mocha,qunit,是一个以nodejs为环境的npm模块.

Karma从头开始构建，免去了设置测试的负担，集中精力在应用逻辑上。会产生一个浏览器实例，针对不同浏览器运行测试，同时可以对测试的运行进行一个实时反馈，提供一份debug报告。

测试还会依赖一些Karma插件，如测试覆盖率Karma-coverage工具、Karman-fixture工具及Karma-coffee处理工具。此外，前端社区里提供里比较丰富的插件，常见的测试需求都能涵盖到。

安装测试相关的npm模块建议使用----save-dev参数,因为这是开发相关的,一般的运行karma的话只需要下面两个npm命令:

```
npm install karma --save-dev
npm install karma-junit-reporter --save-dev
```
然后一个典型的运行框架通常都需要一个配置文件,在karma里可以是一个karma.conf.js,里面的代码是一个nodejs风格的,一个普通的例子如下：

```
module.exports = function(config){
  config.set({
    // 下面files里的基础目录
    basePath : '../',
    // 测试环境需要加载的JS信息
    files : [
      'app/bower_components/angular/angular.js',
      'app/bower_components/angular-route/angular-route.js',
      'app/bower_components/angular-mocks/angular-mocks.js',
      'app/js/**/*.js',
      'test/unit/**/*.js'
    ],
    // 是否自动监听上面文件的改变自动运行测试
    autoWatch : true,
    // 应用的测试框架
    frameworks: ['jasmine'],
    // 用什么环境测试代码,这里是chrome`
    browsers : ['Chrome'],
    // 用到的插件,比如chrome浏览器与jasmine插件
    plugins : [
            'karma-chrome-launcher',
            'karma-firefox-launcher',
            'karma-jasmine',
            'karma-junit-reporter'
            ],
    // 测试内容的输出以及导出用的模块名
    reporters: ['progress', 'junit'],
    // 设置输出测试内容文件的信息
    junitReporter : {
      outputFile: 'test_out/unit.xml',
      suite: 'unit'
    }
  });
};
```
运行时输入：

```
karma start test/karma.conf.js

```

#### jasmine

jasmine是一个行为驱动开发的测试框架,不依赖任何js框架以及dom,是一个非常干净以及友好API的测试库.

以下以一个具体实例说明`test.js`：

```
describe("A spec (with setup and tear-down)", function() {
  var foo;
  beforeEach(function() {
    foo = 0;
    foo += 1;
  });
  afterEach(function() {
    foo = 0;
  });
  it("is just a function, so it can contain any code", function() {
    expect(foo).toEqual(1);
  });
  it("can have more than one expectation", function() {
    expect(foo).toEqual(1);
    expect(true).toEqual(true);
  });
});
```

1. 首先任何一个测试用例以describe函数来定义,它有两参数,第一个用来描述测试大体的中心内容,第二个参数是一个函数,里面写一些真实的测试代码

2. it是用来定义单个具体测试任务,也有两个参数,第一个用来描述测试内容,第二个参数是一个函数,里面存放一些测试方法

3. expect主要用来计算一个变量或者一个表达式的值,然后用来跟期望的值比较或者做一些其它的事件

4. beforeEach与afterEach主要是用来在执行测试任务之前和之后做一些事情,上面的例子就是在执行之前改变变量的值,然后在执行完成之后重置变量的值



### 开始单元测试

下面分别以`控制器`，`指令`，`过滤器`和`服务`四个部分来编写相关的单元测试。项目地址为[`angular-seed(点我)`](https://github.com/jsprodotcom/source/blob/master/angular-seed.zip)项目，可以下载demo并运行其测试用例。

demo中是一个简单的todo应用，会包含一个文本输入框，其中可以编写一些笔记，按下按钮可以将新的笔记加入笔记列表中，其中使用notesfactory封装LocalStorage来储存笔记信息。

先介绍一下angular中测试相关的组件`angular-mocks`。


#### 了解angular-mocks

在Angular中，模块都是通过依赖注入来加载和实例化的，因此官方提供了`angular-mocks.js`测试工具来提供`模块的定义`、`加载`，`依赖注入`等功能。

其中一些常用的方法(挂载在window命名空间下)：

- angular.mock.module: `module`用来加载已有的模块，以及配置`inject`方法注入的模块信息。具体使用如下：
	
```
beforeEach(module('myApp.filters'));

beforeEach(module(function($provide) {
      $provide.value('version', 'TEST_VER');
}));
```

该方法一般在`beforeEach`中使用，在执行测试用例之前可以获得模块的配置。

- angular.mock.inject: `inject`用来注入配置好的`ng`模块，来供测试用例里进行调用。具体使用如下：


```
it('should provide a version', inject(function(mode, version) {
      expect(version).toEqual('v1.0.1');
      expect(mode).toEqual('app');
    }));
```
其实`inject`里面就是利用`angular.inject`方法创建的一个内置的依赖注入实例，然后里面的模块和普通的`ng`模块的依赖处理是一样的。

#### Controller部分

Angular模块是todoApp，控制器是TodoController，当按钮被点击时，TodoController的`createNote()`函数会被调用。下面是app.js的代码部分。

```
var todoApp = angular.module('todoApp',[]);

todoApp.controller('TodoController',function($scope,notesFactory){
    $scope.notes = notesFactory.get();
    $scope.createNote = function(){
    notesFactory.put($scope.note);
    $scope.note='';
    $scope.notes = notesFactory.get();
    }
});

todoApp.factory('notesFactory',function(){
    return {
    put: function(note){    
        localStorage.setItem('todo' + (Object.keys(localStorage).length + 1), note);
    },
    get: function(){
        var notes = [];
        var keys = Object.keys(localStorage);
        for(var i = 0; i < keys.length; i++){
            notes.push(localStorage.getItem(keys[i]));
        }
        return notes;
    }       
    };
});
```

在todoController中用了个叫做`notesFactory`的服务来存储和提取笔记。当`createNote()`被调用时，会使用这个服务将一条信息存入LocalStorage中，然后清空当前的note。因此，在编写测试模块是，应该保证控制器初始化，scope中有一定数量的笔记，在调用`createNote()`之后，笔记的数量应该加一。具体的单元测试如下：

```
describe('TodoController Test', function() {
  beforeEach(module('todoApp')); // 将会在所有的it()之前运行

  // 我们在这里不需要真正的factory。因此我们使用一个假的factory。
  var mockService = {
    notes: ['note1', 'note2'], //仅仅初始化两个项目
    get: function() {
      return this.notes;
    },
    put: function(content) {
      this.notes.push(content);
    }
  };

  // 现在是真正的东西，测试spec
  it('should return notes array with two elements initially and then add one',
    inject(function($rootScope, $controller) { //注入依赖项目
      var scope = $rootScope.$new();

      // 在创建控制器的时候，我们也要注入依赖项目
      var ctrl = $controller('TodoController', {$scope: scope, notesFactory:mockService});

      // 初始化的技术应该是2
      expect(scope.notes.length).toBe(2);

      // 输入一个新项目
      scope.note = 'test3';

      // now run the function that adds a new note (the result of hitting the button in HTML)
      // 现在运行这个函数，它将会增加一个新的笔记项目
      scope.createNote();

      // 期待现在的笔记数目是3
      expect(scope.notes.length).toBe(3);
    })
  );
});

```

在beforeEach中，每一个测试用例被执行之前，都需要加载模块`module("todoApp")`。

由于不需要外部以来，因此我们本地建立一个假的mockService来代替factory，用来模拟noteFactory，其中包含相同的函数，`get()`和`put()`。这个假的factory从数组中加载数据代替localStorage的操作。

在it中，声明了依赖项目`$rootScope`和`$controller`，都可以由Angular自动注入，其中`$rootScope`用来获得根作用域，`$controller`用作创建新的控制器。

1. $controller服务需要两个参数。第一个参数是将要创建的控制器的名称。第二个参数是一个代表控制器依赖项目的对象，
2. $rootScope.$new()方法将会返回一个新的作用域，它用来注入控制器。同时我们传入mockService作为假factory。

之后，初始化会根据notes数组的长度预测笔记的数量，同时在执行了`createNote()`函数之后，会改变数组的长度，因此可以写出两个测试用例。

#### Factory部分
factory部分的单元测试代码如下：

```
describe('notesFactory tests', function() {
  var factory;

  // 在所有it()函数之前运行
  beforeEach(function() {
    // 载入模块
    module('todoApp');

    // 注入你的factory服务
    inject(function(notesFactory) {
      factory = notesFactory;
    });

    var store = {
      todo1: 'test1',
      todo2: 'test2',
      todo3: 'test3'
    };

    spyOn(localStorage, 'getItem').andCallFake(function(key) {
      return store[key];
    });

    spyOn(localStorage, 'setItem').andCallFake(function(key, value) {
      return store[key] = value + '';
    });

    spyOn(localStorage, 'clear').andCallFake(function() {
      store = {};
    });

    spyOn(Object, 'keys').andCallFake(function(value) {
      var keys=[];

      for(var key in store) {
        keys.push(key);
      }

      return keys;
    });
  });

  // 检查是否有我们想要的函数
  it('should have a get function', function() {
    expect(angular.isFunction(factory.get)).toBe(true);
    expect(angular.isFunction(factory.put)).toBe(true);
  });

  // 检查是否返回3条记录
  it('should return three todo notes initially', function() {
    var result = factory.get();

    expect(result.length).toBe(3);
  });

  // 检查是否添加了一条新纪录
  it('should return four todo notes after adding one more', function() {
    factory.put('Angular is awesome');

    var result = factory.get();
    expect(result.length).toBe(4);
  });
});
```

在`TodoController`模块中，实际上的factory会调用localStorage来存储和提取笔记的项目，但由于我们单元测试中，不需要依赖外部服务去获取和存储数据，因此我们要对`localStorage.getItem()`和`localStorage.setItem()`进行spy操作，也就是利用假函数来代替这两个部分。

`spyOn(localStorage,'setItem')andCallFake()`是用来用假函数进行监听的。第一个参数指定需要监听的对象，第二个参数指定需要监听的函数，然后`andCallfake`这个API可以编写自己的函数。因此，测试中完成了对`localStorage`和`Object`的改写，使函数可以返回我们自己数组中的值。

在测试用例中，首先检测新封装的`factory`函数是否包含了`get()`和`put()`这两个方法，，然后进行`factory.put()`操作后断言笔记的数量。

#### Filter部分
我们添加一个过滤器。`truncate`的作用是如果传入字符串过长后截取前10位。源码如下：

```
todoApp.filter('truncate',function(){
    return function(input,length){
        return (input.length > length ? input.substring(0,length) : input);
    }
});
```
所以在单元测试中，可以根据传入字符串的情况断言生成子串的长度。

```
describe('filter test',function(){
    beforeEach(module('todoApp'));
    it('should truncate the input to 1o characters',inject(function(truncateFilter){
        expect(truncateFilter('abcdefghijkl',10).length).toBe(10);
    });
  );
});  
```
之前已经对断言进行讨论了，值得注意的一点是我们需要在调用过滤器的时候在名称后面加入Filter，然后正常调用即可。

#### Directive部分
源码中的指令部分：

```
todoApp.directive('customColor', function() {
  return {
    restrict: 'A',
    link: function(scope, elem, attrs) {
      elem.css({'background-color': attrs.customColor});
    }
  };
});  
```
由于指令必须编译之后才能生成相关的模板，因此我们要引入`$compile`服务来完成实际的编译，然后再测试我们想要进行测试的元素。
`angular.element()`会创建一个`jqLite`元素，然后我们将其编译到一个新生成的自作用域中，就可以被测试了。具体测试用例如下：

```
describe('directive tests',function(){
    beforeEach(module('todoApp'));
    it('should set background to rgb(128, 128, 128)',
    inject(function($compile,$rootScope) {
      scope = $rootScope.$new();

      // 获得一个元素
      elem = angular.element("<span custom-color=\"rgb(128, 128, 128)\">sample</span>");

      // 创建一个新的自作用域
      scope = $rootScope.$new();

      // 最后编译HTML
      $compile(elem)(scope);

      // 希望元素的背景色和我们所想的一样
      expect(elem.css("background-color")).toEqual('rgb(128, 128, 128)');
     })
  );
})；
```
### 开始端到端测试

在端到端测试中，我们需要从用户的角度出发，来进行黑盒测试，因此会涉及到一些DOM操作。将一对组件组合起来然后检查是否如预想的结果一样。
在这个demo中，我们模拟用户输入信息并按下按钮的过程，检测信息能否被添加到`localStorage`中。

在E2E测试中，需要引入`angular-scenario`这个文件，并且建立一个html作为运行report的展示，在html中包含带有e2e测试代码的执行js文件，在编写完测试之后，运行该html文件查看结果。具体的e2e代码如下：

```
describe('my app', function() {
  beforeEach(function() {
    browser().navigateTo('../../app/notes.html');
  });

  var oldCount = -1;

  it("entering note and performing click", function() {
    element('ul').query(function($el, done) {
      oldCount = $el.children().length;
      done();
    });

    input('note').enter('test data');

    element('button').query(function($el, done) {
      $el.click();
      done();
    });
  });

  it('should add one more element now', function() {
    expect(repeater('ul li').count()).toBe(oldCount + 1);
  });        
});  
```

我们在端到端测试过程中，首先导航到我们的主html页面`app/notes.html`，可以通过`browser.navigateTo()`来完成，`element.query()`函数选择了ul元素并记录其中有多少个初始化的项目，存放在`oldCount`变量中。
然后通过`input('note').enter()`来键入一个新的笔记，然后模拟一下点击操作来检查是否增加了一个新的笔记（li元素）。然后通过断言可以将新旧的笔记数进行对比。


### 相关资料

[tdd vs bdd](http://www.bubuko.com/infodetail-432586.html)

[从tdd到bdd](http://blog.csdn.net/bailyzheng/article/details/11694069)

[jasmine框架介绍](http://keenwon.com/1191.html)

[jasmine框架介绍二](http://www.html-js.com/article/column/12)

[关于前端开发谈谈单元测试](http://segmentfault.com/a/1190000000317146)

[前端测试探索实践](http://www.csdn.net/article/2015-07-15/2825220-qiniu-front-end-test-practice)

[说说NG里的单元测试](http://www.w3ctech.com/topic/120)

[在AngularJS中进行单元测试和端到端测试](http://www.html-js.com/article/Study-of-Nodejs-testing-for-unit-testing-and-endtoend-testing-in-AngularJS)