title: 跟underscore.js学如何打造前端类库
date: 2016-10-25 11:30:00
categories: weger
tags:
- library
- underscore.js
---

在我们开发项目的时候，无论项目规模大小，在所难免会写一些工具型函数来解决一些问题，随着项目开发和维护的时间越来越长，这些工具型函数会越来越多，同时还会穿插在各个项目的各模块或者文件当中，使得项目变的越来越臃肿，也不方便复用和维护。这时我们就会提取出一个类似的工具库或者基础库作为项目基础依赖，在项目中重复利用起来，比如拿AngularJS这个框架来说，在他的全局作用域(angular)下就挂载很多类似angular.foreach这样的函数。

为了这样的工具库或类库更易扩展、易维护、易复用和更加稳定，我们就需要更好的去管理，参考前端业界，正好underscore.js作为这样的一个工具型"类库"在各大项目而被广泛使用，那么我们就基于underscore.js，站在巨人的肩上，看看巨人怎么来打造前端类库的。
<!-- more -->

### 准备
在开始之前，我们先了解下 “类库”的定义。
> 类库（Class library）是指一个类的集合。一组在多个工程中可能会被重复使用的类，可以作为一个类库共享给其他相关的开发者  —wikipedia

了解基本概念之后，明白了这是一个集合，我们就来看看underscore.js里面是怎样管理这些集合的吧

### 开始
underscore.js项目目录结构
````
+-- docs  文档,gh-pages分支文件
|   +-- underscore.html
|   +-- ...
+-- test  测试
|   +-- utility.js
|   +-- ...
--- .eslintrc             eslint规范检测
--- .gitignore            git忽略规则
--- .travis.yml           travis CI配置文件

--- CNAME                 gh-pages域名绑定
--- CODE_OF_CONDUCT.md    规范
--- CONTRIBUTING.md       贡献说明
--- LICENSE               开源协议
--- README.md             项目说明

--- bower.json            bower配置

--- favicon.ico	          官网
--- index.html            官网

--- karma.conf-sauce.js
--- karma.conf.js         karma配置

--- package.json          npm配置

--- underscore.js         源文件
--- underscore-min.js     压缩文件
--- underscore-min.map    sourcemap
````
如上，已在每个文件和目录上加了简短说明，我们大概可以分为编码规范、源码、测试、配置、文档（官网+api）等几个大的模块。这几大模块串连起来基本就是一个完整的项目开发过程的体现，接下来我们就逐一的进行解析。

#### 编码规范

项目中使用eslint工具检测代码规则，涉及到要编码文件都有`.eslintrc`规则集文件，同时package.json提供了command支持`npm run lint`，方便随时调用。

打开项目根下的[.eslintrc](https://github.com/jashkenas/underscore/blob/gh-pages/.eslintrc)里面是配置的规则，主要有两大块：执行环境和具体规则条目，具体每条规则的含义可以到[eslint官网](http://eslint.org/docs/rules/)查阅。

underscore.js中主要是js文件，规范主要是针对javascript,如果需要检测html、css也有相应的工具可以使用，如：[HTMLHint](http://htmlhint.com/)、[CSSLint](https://github.com/CSSLint)、[lesshint](https://github.com/lesshint)、[lint-plus](https://github.com/xgfe/lint-plus)、[fecs](http://fecs.baidu.com/)。

由此可见，在我们编写类库代码的时候，也通过一些检测工具配置上相应的规范，这样更有利于代码规范化和提升代码可维护性。

#### 源码

这部分从目录中可以看出，主要有三个文件，其中`underscore-min.js`和`underscore-min.map`都是有`underscore.js`文件通过压缩工具[uglify-js](https://www.npmjs.com/package/uglify-js)生成，具体可以到npm配置中[devDependencies](https://github.com/jashkenas/underscore/blob/gh-pages/package.json#L25)查看到，min.js为混淆压缩后的体积比较小的文件主要用于生产环境，.map文件用于开发调试，这两个我就不在深入了。

整个项目的主体代码都在underscore.js文件里，也是其整个项目的精华部分，我们就一步步去探索其中奥妙吧。

##### 全局变量
````
(function() {
  var root = this;
  ....
  var _ = function(obj) {
    if (obj instanceof _) return obj;
    if (!(this instanceof _)) return new _(obj);
    this._wrapped = obj;
  };
  _.
  ....
}.call(this));
````
从代码中可看出，underscore.js采用了闭包的形式，隔离了内部变量，预防了冲突，声明了`_`这样的一个构造函数，后面一系列函数都绑定到`_`函数对象上面。同时上面这个函数默认传入一个`obj`参数，可以通过`_(obj)`用来校验`_`是否是`obj`的父类型以此判断继承关系，`_wrapped`用于后面链式操作。

##### 冲突解决
````
var previousUnderscore = root._;

_.noConflict = function() {
  root._ = previousUnderscore;
  return this;
};
````
如果一个文件中同时引入了多次underscore.js或者你在代码的上下文用到了`_`这个变量名，当然除了保证引入顺序和规避重复引入之外，还可以通过调用`_.noConflict()`方法，将变量`_`返回给underscore.js，转移控制权，同时还可以给这个方法赋值，用来取别名。

这种冲突解决方案在很多类库都有实际运用，如果想详细了解，请参考jQuery里`noConflict`方法的源码部分。

我们在编写类库时要处理同样情况时，也可以采用想通的方式来进行处理。

##### 压缩处理
````
var ArrayProto = Array.prototype, ObjProto = Object.prototype, FuncProto = Function.prototype;

var
    push             = ArrayProto.push,
    slice            = ArrayProto.slice,
    toString         = ObjProto.toString,
    hasOwnProperty   = ObjProto.hasOwnProperty;

var
    nativeIsArray      = Array.isArray,
    nativeKeys         = Object.keys,
    nativeBind         = FuncProto.bind,
    nativeCreate       = Object.create;
````
通过保存原生方法的引用，后面多处使用到的地方可以通过引用名去调用，这样通过压缩工具压缩后，重复使用到的引用名就会被压缩成短变量的形式，从而减小文件的体积。

##### 版本
````
// Current version.
_.VERSION = '1.8.3';
````
可以看出underscore用一个常量`VERSION`保存了当前使用的版本信息，版本数值采用了：主版本号.次版本号.修订号，具体号的含义可以参考[语义化版本管理](http://semver.org/lang/zh-CN/)。

开源的库或者框架都普遍采用这种版本号管理方式，如果我们的类库会持续迭代，或者开源和供第三方使用时，可以使用这个方法。

##### 引入方式

文档中有5种文件下载方法，分别如下：

    Node.js `npm install underscore`
    Meteor.js `meteor add underscore`
    Require.js `require(["underscore"], ...`
    Bower `bower install underscore`
    Component `component install jashkenas/underscore `

引入方式除了通过`script`，基本都是模块化引入方式，按运行环境，可以分为browser（前端）和nodejs（后端）。

npm和meteor都属于后端环境下使用方法，采用的[CommonJS](https://en.wikipedia.org/wiki/CommonJS)模块化规范，代码实现如下：

````
if (typeof exports !== 'undefined') {
  if (typeof module !== 'undefined' && module.exports) {
    exports = module.exports = _;
  }
  exports._ = _;
} else {
  root._ = _;
}
````
通过对判断 exports是否存在来决定将局部变量`_`赋值给`exports`，这样就可以通过`require("underscore")`来引入使用。

`require.js`是属于browser环境下的，前端环境下更多的都是采用的[AMD](https://github.com/amdjs/amdjs-api) (Asynchronous Module Definition)规范，Underscore.js 是支持 AMD 的，在源码中有定义，如下：
````
if (typeof define === 'function' && define.amd) {
  define('underscore', [], function() {
    return _;
  });
}
````
通过`require(["underscore"], function (_..) {})`来引入使用.

除此之外，其实有[UMD](https://github.com/umdjs/umd) (Universal Module Definition)和[AMD](https://github.com/cmdjs/specification/blob/master/draft/module.md)（Common Module Definition 国内）,每个规范的关键词我都已加上链接，如要详细理解请自行点击，这里不在赘述。

编写类库如果只是用于browser前端环境的话，建议采用UMD的规范，而且最新发布的ECMAScript2016也是遵循的此规范，如果还需要满足其他情况下使用的话，可以再采取适配方式编写相应的适配代码。

##### 继承方法

````
var Ctor = function(){};
...
var baseCreate = function(prototype) {
  if (!_.isObject(prototype)) return {};
  if (nativeCreate) return nativeCreate(prototype);
  Ctor.prototype = prototype;
  var result = new Ctor;
  Ctor.prototype = null;
  return result;
};
````
主要运用的[基于原型链的继承](https://developer.mozilla.org/zh-CN/docs/Web/JavaScript/Inheritance_and_the_prototype_chain), `baseCreate`用于创建一个干净且只想要其`prototype`的函数，第一个判断是否具有`prototype`参数，第二个判断运用`Object.create`创建，余下则是自己运用`Ctor`这个空函数创建。

继承的方式有很多种，编写类库时只要有相应的一种实现，同时提供了可以扩展的方式，达到这样的目的就可以了。

##### 链式语法
````
 _.chain = function(obj) {
  var instance = _(obj);
  instance._chain = true;
  return instance;
};
````
通过返回自己本身实例来实现链式调用，使用前先执行`_.chain()`方法就可以。

链式调用的好处这里就不赘述了，如果编写的类库想支持的话可以考虑参考下类似的方式来实现，同时如果想继续深入的了解可以关注下函数式编程。

##### 其他

这部分主要是从代码封装的角度，去看怎么样组织一个类库，而且只提到封装相关的通用的一些组织方式,其实上面部分只是underscore.js源码的冰山一角，其各个部分函数的实现细节也是很值得学习和借鉴的，比如：集合(Collections)中的随机取样函数`_.sample`的[Fisher-Yates shuffle](https://en.wikipedia.org/wiki/Fisher%E2%80%93Yates_shuffle)的实现等，数组(Arrays)中多维数组转换`_.flatten`等,函数(Functions)中`_.throttle`和`_.debounce`等，以及对象(Objects)中`_.extend`等，除了这些还有很多很多，有机会大家可以继续深入解读。

#### 测试

underscore.js有一个完整的[Test Suite](http://underscorejs.org/test/),专门用一个[test目录](https://github.com/jashkenas/underscore/tree/master/test)来管理测试文件，下面我们就来看下这部分。

文件基本都是按功能（collections\Arrays\Function\Objects\Utility\Chaining）拆分出了几个大的文件来组织。

使用[qunit](https://qunitjs.com/)测试框架，通过[karma](https://github.com/karma-runner/karma)提供browser和nodejs测试运行环境
````
"test-node": "qunit-cli test/*.js",
"test-browser": "npm i karma-phantomjs-launcher && karma start"
````

使用[nyc](https://www.npmjs.com/package/nyc)生成覆盖率报告
````
"coverage": "nyc npm run test-node && nyc report"
````

同时CI采用的是[travis-ci](https://travis-ci.org/) 做的集成，通过[coveralls](https://coveralls.io/)保存覆盖率记录，可以自动运行测试，展示测试和覆盖率结果

测试是保障代码质量的最为直接有效的手段，underscore.js的测试都是通过npm script以命令方式提供出来的，同时使用了覆盖率生成、测试执行环境和自动化工具。

编写类库测试代码时，可以参考照这种功能块来组织文件，同时再借助类似测试工具来进行管理，使其更方便高效。

#### 配置

配置主要是分两部分，一部分是用于工具配置，如：`.eslintrc`、`karma.conf.js`、`.travis.yml`、`.gitignore`，`.eslintrc`前面已经讲过了，`karma.conf.js`这个主要是用于karmay运行测试环境的配置，`.travis.yml`这个主要是[travis-ci](https://travis-ci.org/)用于CI，`.gitignore`可以忽略一些不需要的提交到仓库的文件。

另一部分是引入方式支持：bower.json、package.json，有了这个两个文件，就可以支持bower、component和npm工具install来下载文件了。

类库如果要支持相应功能的话，可以考虑增加相应的配置文件，通过`npm install`安装相应工具包，编写好相应配置项就可以了。


#### 文档

underscore.js文档主要有API文档、官方网站、Change Log、README、CODE_OF_CONDUCT和CONTRIBUTING。

其中除了用于github仓库说明的README、Contributor使用的代码行为规范CODE_OF_CONDUCT和贡献代码说明CONTRIBUTING。

API文档、官方网站、Change Log的内容都写在了[index.html](https://github.com/jashkenas/underscore/blob/master/index.html)里面，同时还通过DocumentCloud生成了[带注释的源码](http://underscorejs.org/docs/underscore.html)

在[underscore.js](http://underscorejs.org)官方文档的最后可以看到documentcloud的大广告排:

![documentcloud](http://jashkenas.s3.amazonaws.com/images/a_documentcloud_project.png)

在写类库的时候也可以参考underscore.js的做法，其中API文档和ChangLog应该说是不可或缺的部分，API文档说明类库提供的功能，ChangLog告知升级后没个版本之间的差异，这样才能让使用者更充分的了解你的类库，而且完善的文档才能让更多的人贡献集合，把集合汇集起来做成一个强大类库。

### 结束
要编写易用、易扩展、易维护和稳定的一个类库，其实是个特复杂的过程，涉及到从目录结构组织，编码规范的制订，代码的作用域、OOP、方法集合、冲突、体积、引入方式等是否支持链式调用的管理，而且还要有完整的测试和测试覆盖，自动化CI的集成，还需要编写完善的文档的和维护各个版本，同时如果多人参与或者他人贡献还要制订相应的规范和标准，可以见得和开发一个工程已相差无几，而这里提到也只是一小部分，所以在编写类库，不要以为这只是一个小的东东，不妨按照工程的角度去思考，这样才能更加全面的考虑，构建和维护有效的、实用的和高质量的类库。

### 其他参考
- http://underscorejs.org/docs/underscore.html
- https://segmentfault.com/blog/kahn1990?tag=underscore
- https://github.com/krasimir/webpack-library-starter
