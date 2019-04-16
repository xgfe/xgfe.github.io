<<<<<<< HEAD
title: webpack入门 
=======
title: webpack 入门 
>>>>>>> 70f0ef78fcbc4ef41773f4ff1ac4dacf2a74dfdb
date: 2018-06-24 20:31:49 
categories: matengfei
tags: 
- webpack

---
Webpack 是当下最热门的前端资源模块化管理和打包工具。它可以将许多松散的模块按照依赖和规则打包成符合生产环境部署的前端资源。还可以将按需加载的模块进行代码分隔，等到实际需要的时候再异步加载。通过loader的转换，任何形式的资源都可以视作模块，比如 CommonJs 模块、AMD 模块、ES6 模块、CSS、图片、JSON、Coffeescript、LESS 等。

<!--more-->

<<<<<<< HEAD
# 1、webpack简介
=======
# 1、webpack 简介
>>>>>>> 70f0ef78fcbc4ef41773f4ff1ac4dacf2a74dfdb
前端是基于多语言、多层次的编码和组织工作，其次前端产品的交付是基于浏览器，这些资源是通过增量加载的方式运行到浏览器端，如何在开发环境组织好这些碎片化的代码和资源，并且保证他们在浏览器端快速、优雅的加载和更新，就需要一个模块化系统。


## webpack 的优势
<<<<<<< HEAD
* 1、支持CommonJs和AMD模块，意思也就是我们基本可以无痛迁移旧项目。
* 2、支持模块加载器和插件机制，可对模块灵活定制。babel-loader更是有效支持ES6。 
* 3、可以通过配置，打包成多个文件。有效利用浏览器的缓存功能提升性能。 
* 4、将样式文件和图片等静态资源也可视为模块进行打包。配合loader加载器，可以支持sass，less等CSS预处理器。 
* 5、内置有source map，即使打包在一起依旧方便调试。
=======
* 1、支持 CommonJs 和 AMD 模块，意思也就是我们基本可以无痛迁移旧项目。
* 2、支持模块加载器和插件机制，可对模块灵活定制。babel-loader 更是有效支持 ES6 。 
* 3、可以通过配置，打包成多个文件。有效利用浏览器的缓存功能提升性能。 
* 4、将样式文件和图片等静态资源也可视为模块进行打包。配合 loader 加载器，可以支持 sass ，less 等 CSS 预处理器。 
* 5、内置有 source map ，即使打包在一起依旧方便调试。
>>>>>>> 70f0ef78fcbc4ef41773f4ff1ac4dacf2a74dfdb


## webpack 核心概念
Webpack 具有四个核心的概念，想要入门 Webpack 就得先好好了解这四个核心概念。它们分别是Entry（入口）、Output（输出）、loader 和 Plugins（插件）。接下来详细介绍这四个核心概念。
### 1. Entry
<<<<<<< HEAD
Entry 是 Webpack 的入口起点指示，它指示 webpack 应该从哪个模块开始着手，来作为其构建内部依赖图的开始。可以在配置文件（webpack.config.js）中配置 entry 属性来指定一个或多个入口点，默认为./src（ webpack 4开始引入默认值）。
=======
Entry 是 Webpack 的入口起点指示，它指示 webpack 应该从哪个模块开始着手，来作为其构建内部依赖图的开始。可以在配置文件（webpack.config.js）中配置 entry 属性来指定一个或多个入口点，默认为 ./src（ webpack 4开始引入默认值）。
>>>>>>> 70f0ef78fcbc4ef41773f4ff1ac4dacf2a74dfdb
具体配置方法：

```js
entry: string | Array<string>
```

前者一个单独的 string 是配置单独的入口文件，配置为后者（一个数组）时，是多文件入口。

```js
//webpack.config.js
module.exports = {
    entry: {
        app: './app.js',
        vendors: './vendors.js'
    }
};
```
以上配置表示从 app 和 vendors 属性开始打包构建依赖树，这样做的好处在于分离自己开发的业务逻辑代码和第三方库的源码，因为第三方库安装后，源码基本就不再变化，这样分开打包有利于提升打包速度，减少了打包文件的个数。

### 2. Output
<<<<<<< HEAD
Output 属性告诉webpack在哪里输出它所创建的 bundles，也可指定 bundles 的名称，默认位置为 ./dist。整个应用结构都会被编译到指定的输出文件夹中去，最基本的属性包括 filename（文件名）和 path（输出路径）。
=======
Output 属性告诉 webpack 在哪里输出它所创建的 bundles ，也可指定 bundles 的名称，默认位置为 ./dist。整个应用结构都会被编译到指定的输出文件夹中去，最基本的属性包括 filename（文件名）和 path（输出路径）。
>>>>>>> 70f0ef78fcbc4ef41773f4ff1ac4dacf2a74dfdb

值得注意的是，即是你配置了多个入口文件，你也只能有一个输出点。

具体配置方法：

```javascript
output: {
    filename: 'bundle.js',
    path: '/home/proj/public/dist'
}
```

值得注意的是，output.filename 必须是绝对路径，如果是一个相对路径，打包时 webpack 会抛出异常。

多个入口时，使用下面的语法输出多个 bundle ：

```javascript
// webpack.config.js
module.exports = {
    entry: {
        app: './src/app.js',
        vendors: './src/vendors.js'
    },
    output: {
        filename: '[name].js',
        path: __dirname + '/dist'
    }
}
```

### 3. Loaders
<<<<<<< HEAD
loader 可以理解为webpack的编译器，它使得webpack可以处理一些非 JavaScript 文件，比如 png、csv、xml、css、json 等各种类型的文件，使用合适的 loader 可以让 JavaScript 的 import 导入非 JavaScript 模块。JavaScript 只认为 JavaScript 文件是模块，而 webpack 的设计思想即万物皆模块，为了使得 webpack 能够认识其他“模块”，所以需要 loader 这个“编译器”。
=======
loader 可以理解为 webpack 的编译器，它使得 webpack 可以处理一些非 JavaScript 文件，比如 png、csv、xml、css、json 等各种类型的文件，使用合适的 loader 可以让 JavaScript 的 import 导入非 JavaScript 模块。JavaScript 只认为 JavaScript 文件是模块，而 webpack 的设计思想即万物皆模块，为了使得 webpack 能够认识其他“模块”，所以需要 loader 这个“编译器”。
>>>>>>> 70f0ef78fcbc4ef41773f4ff1ac4dacf2a74dfdb

webpack 中配置 loader 有两个目标：

（1）test 属性：标志有哪些后缀的文件应该被处理，是一个正则表达式。

（2）use 属性：指定 test 类型的文件应该使用哪个 loader 进行预处理。

<<<<<<< HEAD
比如webpack.config.js:
=======
比如 webpack.config.js :
>>>>>>> 70f0ef78fcbc4ef41773f4ff1ac4dacf2a74dfdb

```js
module.exports = {
    entry: '...',
    output: '...',
    module: {
        rules: [
            {
                test: /\.css$/,
                use: 'css-loader'
            }
        ]
    }
};
```

该配置文件指示了所有的 css 文件在 import 时都应该经过 css-loader 处理，经过 css-loader 处理后，可以在 JavaScript 模块中直接使用 import 语句导入 css 模块。但是使用 css-loader 的前提是先使用 npm 安装 css-loader。

此处需要注意的是定义 loaders 规则时，不是定义在对象的 rules 属性上，而是定义在 module 属性的 rules 属性中。

<<<<<<< HEAD
配置多个 loader：

有时候，导入一个模块可能要先使用多个 loader 进行预处理，这时就要对指定类型的文件配置多个 loader 进行预处理，配置多个 loader，把 use 属性赋值为数组即可，webpack 会按照数组中 loader 的先后顺序，使用对应的 loader 依次对模块文件进行预处理。
=======
配置多个 loader ：

有时候，导入一个模块可能要先使用多个 loader 进行预处理，这时就要对指定类型的文件配置多个 loader 进行预处理，配置多个 loader ，把 use 属性赋值为数组即可，webpack 会按照数组中 loader 的先后顺序，使用对应的 loader 依次对模块文件进行预处理。
>>>>>>> 70f0ef78fcbc4ef41773f4ff1ac4dacf2a74dfdb

```js
{
    module: {
        rules: [
            {
                test: /\.css$/,
                use: [
                    {
                        loader: 'style-loader'
                    },
                    {
                        loader: 'css-loader'
                    }
                ]
            }
        ]
    }
}
```

### 4. Plugins
loader 用于转换非 JavaScript 类型的文件，而插件可以用于执行范围更广的任务，包括打包、优化、压缩、搭建服务器等等，功能十分强大。要是用一个插件，一般是先使用npm包管理器进行安装，然后在配置文件中引入，最后将其实例化后传递给 plugins 数组属性。

插件是 webpack 的支柱功能，目前主要是解决 loader 无法实现的其他许多复杂功能，通过 plugins 属性使用插件：

```js
// webpack.config.js
const webpack = require('webpack');
module.exports = {
    plugins: [
        new webpack.optimize.UglifyJsPlugin()
    ]
}
```

### 5. Mode
模式（ Mode ）可以通过配置对象的 mode 属性进行配置，主要值为 production 或者 development。两种模式的区别在于一个是为生产环境编译打包，一个是为了开发环境编译打包。生产环境模式下，webpack 会自动对代码进行压缩等优化，省去了配置的麻烦。

学习完以上基本概念之后，基本也就入门 webpack 了，因为 webpack 的强大就是建立在这些基本概念之上，利用 webpack 多样的 loaders 和 plugins，可以实现强大的打包功能。

<<<<<<< HEAD
# 2、js模块化
=======
# 2、js 模块化
>>>>>>> 70f0ef78fcbc4ef41773f4ff1ac4dacf2a74dfdb
## 2.1 命名空间
命名空间是通过为项目或库创建一个全局对象，然后将所有功能添加到该全局变量中。通过减少程序中全局变量的数量，实现单全局变量，从而在具有大量函数、对象和其他变量的情况下不会造成全局污染，同时也避免了命名冲突等问题。

然而，在不同的文件中给一个命名空间添加属性的时候，首先要保证这个命名空间是已经存在的，同时不对已有的命名空间造成任何破坏。可以通过非破坏性的命名空间函数实现：

```js
var KUI = KUI || {};
KUI.utils = KUI.utils || {};

KUI.utils.namespace = function(ns){
    var parts = ns.split("."),
        object = KUI,
        i, len;

    if(parts[0] === "KUI"){
        parts = parts.slice(1);
    }

    for(i = 0, len = parts.length; i < len; i+=1){

        if(!object[parts[i]]){
            object[parts[i]] = {};
        }

        object = object[parts[i]];
    }

    return object;
};
```

用法：

```js
KUI.utils.namespace("KUI.common");
KUI.utils.namespace("KUI.common.testing");
KUI.utils.namespace("KUI.modules.function.plugins");
KUI.utils.namespace("format");
```

看一下经过上述后 KUI 都有什么：

```js
{
    "utils": {},
    "common": {
        "testing": {}
    },
    "modules": {
        "function": {
            "plugins": {}
        }
    },
    "format": {}
}
```

命名空间模式的缺点

1.需要输入更长的字符，并且需要更长的解析时间；
2.对单全局变量的依赖性，即任何代码都可以修改该全局实例，其他代码将获得修改后的实例。

## 2.2 CommonJs
CommonJS 是 nodejs 也就是服务器端广泛使用的模块化机制。 
该规范的主要内容是，模块必须通过 module.exports 导出对外的变量或接口，通过 require() 来导入其他模块的输出到当前模块作用域中。

根据这个规范，每个文件就是一个模块，有自己的作用域，文件中的变量、函数、类等都是对其他文件不可见的。

如果想在多个文件分享变量，必须定义为 global 对象的属性。

### 定义模块
在每个模块内部，module 变量代表当前模块。它的 exports 属性是对外的接口，将模块的接口暴露出去。其他文件加载该模块，实际上就是读取 module.exports 变量。

```js
var x = 5;
var addX = function (value) {
  return value + x;
};
module.exports.x = x;
module.exports.addX = addX;
```

### 加载模块
require 方法用于加载模块，后缀名默认为.js

```js
var app = require('./app.js');
```

模块加载的顺序，按照其在代码中出现的顺序

根据参数的不同格式，require 命令去不同路径寻找模块文件。

* 如果参数字符串以“/”开头，则表示加载的是一个位于绝对路径的模块文件。
* 如果参数字符串以“./”开头，则表示加载的是一个位于相对路径的模块文件
<<<<<<< HEAD
* 如果参数字符串不以“./“或”/“开头，则表示加载的是一个默认提供的核心模块（ node 核心模块，或者通过全局安装或局部安装在 node_modules 目录中的模块）
=======
* 如果参数字符串不以“./” 或 “/”开头，则表示加载的是一个默认提供的核心模块（ node 核心模块，或者通过全局安装或局部安装在 node_modules 目录中的模块）
>>>>>>> 70f0ef78fcbc4ef41773f4ff1ac4dacf2a74dfdb

### 入口文件
一般都会有一个主文件（入口文件），在 index.html 中加载这个入口文件，然后在这个入口文件中加载其他文件。

可以通过在 package.json 中配置 main 字段来指定入口文件。

### 模块缓存
第一次加载某个模块时，Node 会缓存该模块。以后再加载该模块，就直接从缓存取出该模块的 module.exports 属性。

### 加载机制
CommonJS 模块的加载机制是，输入的是被输出的值的拷贝。也就是说，一旦输出一个值，模块内部的变化就影响不到这个值。

由于 CommonJS 是同步加载模块，这对于服务器端不是一个问题，因为所有的模块都放在本地硬盘。等待模块时间就是硬盘读取文件时间很小。但是，对于浏览器而言，它需要从服务器加载模块，涉及到网速，代理等原因，一旦等待时间过长，浏览器处于”假死”状态。

## 2.3 AMD
AMD 是 "Asynchronous Module Definition" 的缩写，即 “异步模块定义”。它采用异步方式加载模块，模块的加载不影响它后面语句的运行。 

这里异步指的是不堵塞浏览器其他任务（ dom 构建，css 渲染等），而加载内部是同步的（加载完模块后立即执行回调）。

> requirejs 即为遵循AMD规范的模块化工具。 

RequireJS 的基本思想是，通过 define 方法，将代码定义为模块；通过 require 方法，实现代码的模块加载。

RequireJS 主要解决两个问题：

* 多个 js 文件可能有依赖关系，被依赖的文件需要早于依赖它的文件加载到浏览器。
* js 加载的时候浏览器会停止页面渲染，加载文件越多，页面失去响应时间越长。


### 定义模块
RequireJS 定义了一个函数 define，它是全局变量，用来定义模块:

```js
define(id?, dependencies?, factory);
```

参数说明：

* id：指定义中模块的名字，可选；如果没有提供该参数，模块的名字应该默认为模块加载器请求的指定脚本的名字。如果提供了该参数，模块名必须是“顶级”的和绝对的（不允许相对名字）。

* 依赖 dependencies：是一个当前模块依赖的，已被模块定义的模块标识的数组字面量。
依赖参数是可选的，如果忽略此参数，它应该默认为["require", "exports", "module"]。然而，如果工厂方法的长度属性小于 3 ，加载器会选择以函数的长度属性指定的参数个数调用工厂方法。

* 工厂方法 factory，模块初始化要执行的函数或对象。如果为函数，它应该只被执行一次。如果是对象，此对象应该为模块的输出值。

```javascript
define("alpha", ["require", "exports", "beta"], function (require, exports, beta) {
      exports.verb = function() {
          return beta.verb();
          //Or:
          return require("beta").verb();
      }
  });
```

### 加载模块
AMD 也采用 require 命令加载模块，但是不同于 CommonJS ，它要求两个参数：

```javascript
require(['math'], function(math) {
  math.add(2, 3);
})
```

第一个参数是一个数组，里面的成员是要加载的模块，第二个参数是加载完成后的回调函数。

### 配置
require 方法本身也是一个对象，它带有一个 config 方法，用来配置 require.js 运行参数。

```javascript
require.config({
    paths: {
        "backbone": "vendor/backbone",
        "underscore": "vendor/underscore"
    },
    shim: {
        "backbone": {
            deps: [ "underscore" ],
            exports: "Backbone"
        },
        "underscore": {
            exports: "_"
        }
    }
});
```

paths：paths 参数指定各个模块的位置。这个位置可以是同一个服务器上的相对位置，也可以是外部网址。可以为每个模块定义多个位置，如果第一个位置加载失败，则加载第二个位置。上面就是指定了 jquery 的位置，那么就可以直接在文件中

```
require（['jquery'],function($){}）
```

shim：有些库不是 AMD 兼容的，这时就需要指定 shim 属性的值。shim 可以理解成“垫片”，用来帮助require.js 加载非 AMD 规范的库。

## 2.4 CMD
<<<<<<< HEAD
CMD 即Common Module Definition 通用模块定义，CMD 规范是国内发展出来的，就像 AMD 有个requireJS，CMD 有个浏览器的实现 SeaJS，SeaJS 要解决的问题和 requireJS 一样，只不过在模块定义方式和模块加载（可以说运行、解析）时机上有所不同。
=======
CMD 即 Common Module Definition 通用模块定义，CMD 规范是国内发展出来的，就像 AMD 有个requireJS，CMD 有个浏览器的实现 SeaJS ，SeaJS 要解决的问题和 requireJS 一样，只不过在模块定义方式和模块加载（可以说运行、解析）时机上有所不同。
>>>>>>> 70f0ef78fcbc4ef41773f4ff1ac4dacf2a74dfdb

在 CMD 规范中，一个模块就是一个文件。代码的书写格式如下:

```js
define(function(require, exports, module) {

  // 模块代码

});
```

require 是可以把其他模块导入进来的一个参数; 而 exports 是可以把模块内的一些属性和方法导出的; module 是一个对象，上面存储了与当前模块相关联的一些属性和方法。

* AMD 是依赖关系前置,在定义模块的时候就要声明其依赖的模块;
* CMD 是按需加载依赖就近,只有在用到某个模块的时候再去 require ;

```js
// CMD
define(function(require, exports, module) {
  var a = require('./a')
  a.doSomething()
  // 此处略去 100 行
  var b = require('./b') // 依赖可以就近书写
  b.doSomething()
  // ... 
})

// AMD 默认推荐的是
define(['./a', './b'], function(a, b) { // 依赖必须一开始就写好
  a.doSomething()
  // 此处略去 100 行
  b.doSomething()
  ...
})

```

## 2.5 ES6 Module
ES6 正式提出了内置的模块化语法，我们在浏览器端无需额外引入 requirejs 来进行模块化。ES6 在语言标准的层面上，实现了模块功能，而且实现得相当简单，完全可以取代 CommonJS 和 AMD 规范，成为浏览器和服务器通用的模块解决方案。

ES6 模块不是对象，而是通过export命令显式指定输出的代码，再通过 import 命令输入。

ES6 中的模块有以下特点：

* 模块自动运行在严格模式下
<<<<<<< HEAD
* 在模块的顶级作用域创建的变量，不会被自动添加到共享的全局作用域，它们只会在模块顶级作用域的内部存在；
=======
* 在模块的顶级作用域创建的变量，不会被自动添加到共享的全局作用域，它们只会在模块顶级作用域的内部存在
>>>>>>> 70f0ef78fcbc4ef41773f4ff1ac4dacf2a74dfdb
* 模块顶级作用域的 this 值为 undefined
* 对于需要让模块外部代码访问的内容，模块必须导出它们

### 定义模块
使用 export 关键字将任意变量、函数或者类公开给其他模块。

```js
//导出变量
export var color = "red";
export let name = "cz";
export const age = 25;

//导出函数
export function add(num1,num2){
    return num1+num2;
}

//导出类
export class Rectangle {
    constructor(length, width) {
        this.length = length;
        this.width = width;
    }
}

function multiply(num1, num2) {
    return num1 * num2;
}

//导出对象，即导出引用
export {multiply}
```

### 重命名模块
重命名想导出的变量、函数或类的名称

```js
function sum(num1, num2) {
    return num1 + num2;
}

export {sum as add}
```

这里将本地的 sum 函数重命名为 add 导出，因此在使用此模块的时候必须使用 add 这个名称。

### 导出默认值
模块的默认值是使用 default 关键字所指定的单个变量、函数或类，而你在每个模块中只能设置一个默认导出。

```js
export default function(num1, num2) {
    return num1 + num2;
}
```
此模块将一个函数作为默认值进行了导出， default 关键字标明了这是一个默认导出。此函数并不需要有名称，因为它就代表这个模块自身。对比最前面使用 export 导出的函数，并不是匿名函数而是必须有一个名称用于加载模块的时候使用，但是默认导出则无需一个名字，因为模块名就代表了这个导出值。

也可以使用重命名语法来导出默认值。

```js
function sum(num1, num2) {
    return num1 + num2;
}

export { sum as default };
```

### 加载模块
在模块中使用 import 关键字来导入其他模块。 
import 语句有两个部分，一是需要导入的标识符，二是需导入的标识符的来源模块。此处是导入语句的基本形式：

```javascript
import { identifier1,identifier2 } from "./example.js"
```

* 大括号中指定了从给定模块导入的标识符
* from 指明了需要导入的模块。模块由一个表示模块路径的字符串来指定。

当从模块导入了一个绑定时，你不能在当前文件中再定义另一个同名变量（包括导入另一个同名绑定），也不能在对应的 import 语句之前使用此标识符，更不能修改它的值。

```js
//导入单个绑定
import {sum} from './example.js'

//导入多个绑定
import {sum,multiply} from './example.js'

//完全导入一个模块
import * as example from './example.js'
example.sum(1,2);
example.multiply(2,3);

//重命名导入
import { sum as add} from './example.js'

//导入默认值
import sum from "./example.js";
```

然而要记住，无论你对同一个模块使用了多少次 import 语句，该模块都只会被执行一次。

在导出模块的代码执行之后，已被实例化的模块就被保留在内存中，并随时都能被其他 import 所引用.

```js
import { sum } from "./example.js";
import { multiply } from "./example.js";
import { magicNumber } from "./example.js";
```

尽管此处的模块使用了三个 import 语句，但 example.js 只会被执行一次。若同一个应用中的其他模块打算从 example.js 导入绑定，则那些模块都会使用这段代码中所用的同一个模块实例。

### 限制
export 与 import 都有一个重要的限制，那就是它们必须被用在其他语句或表达式的外部，而不能使用在if等代码块内部。原因之一是模块语法需要让 JS 能静态判断需要导出什么，正因为此，你只能在模块的顶级作用域使用 export 与 import。


<<<<<<< HEAD
# 3、webpack使用
## 3.1 打包js
=======
# 3、webpack 使用
## 3.1 打包 js
>>>>>>> 70f0ef78fcbc4ef41773f4ff1ac4dacf2a74dfdb
webpack 对各种模块化的支持

```js
// app.js
// es module
import sum from './sum'

// commonjs
var minus = require('./minux')

//amd
require(['muti'], function () {
    console.log(muti(2, 3))
})

console.log(sum(2, 3))
console.log(minus(3, 2))
```

```js
// sum.js
export default function () {
    return a + b
}
```

```js
// minus.js
module.exports = function (a, b) {
    a - b
}
```

```js
// muti.js
define(function() {
    'use strict';
    return function (a, b) {
        return a * b;
    }
});
```

<<<<<<< HEAD
### 压缩JS代码：
现在你写的 JS 代码，在上线之前，都是需要进行压缩的，在没有 webpack 和 gulp 这些工具前，你可能需要找一个压缩软件或者在线进行压缩，在Webpack中可以很轻松的实现JS代码的压缩，它是通过插件的方式实现的，这里我们就先来引入一个 uglifyjs-webpack-plugin ( JS 压缩插件，简称 uglify)。

注意：虽然 uglifyjs 是插件，但是webpack版本里默认已经集成，不需要再次安装。
=======
### 压缩 JS 代码：
现在你写的 JS 代码，在上线之前，都是需要进行压缩的，在没有 webpack 和 gulp 这些工具前，你可能需要找一个压缩软件或者在线进行压缩，在 Webpack 中可以很轻松的实现JS代码的压缩，它是通过插件的方式实现的，这里我们就先来引入一个 uglifyjs-webpack-plugin ( JS 压缩插件，简称 uglify )。

注意：虽然 uglifyjs 是插件，但是 webpack 版本里默认已经集成，不需要再次安装。
>>>>>>> 70f0ef78fcbc4ef41773f4ff1ac4dacf2a74dfdb

引入：

我们需要在 webpack.config.js 中引入 uglifyjs-webpack-glugin 插件

```js
const uglify = require('uglifyjs-webpack-plugin');
```

引入后在 plugins 配置里new一个 uglify 对象就可以了，代码如下。

```js
plugins:[
        new uglify()
    ],
```

这时候在终端中使用 webpack 进行打包，你会发现 JS 代码已经被压缩了。

<<<<<<< HEAD
## 3.2 编译ES6
在前端开发中都开始使用ES6的语法了，虽然说 webpack3 增加了一些 ES6 的转换支持，但是实际效果不是很好。所以我在开发中还是喜欢添加 Babel-loader 的，我也查看了一些别人的 webpack 配置也都增加了 babel-loader，所以这节课我们学习一下如何增加 Babel 支持。
=======
## 3.2 编译 ES6
在前端开发中都开始使用 ES6 的语法了，虽然说 webpack3 增加了一些 ES6 的转换支持，但是实际效果不是很好。所以我在开发中还是喜欢添加 Babel-loader 的，我也查看了一些别人的 webpack 配置也都增加了 babel-loader，所以这节课我们学习一下如何增加 Babel 支持。
>>>>>>> 70f0ef78fcbc4ef41773f4ff1ac4dacf2a74dfdb

Babel 是什么？
Babel 其实是一个编译 JavaScript 的平台，它的强大之处表现在可以通过便宜帮你达到以下目的：

* 使用下一代的 javaScript 代码( ES6, ES7….)，即使这些标准目前并未被当前的浏览器完全支持。
<<<<<<< HEAD
* 使用基于 JavaScript 进行了扩展的语言，比如 React 的 JSX。

### Babel的安装与配置
=======
* 使用基于 JavaScript 进行了扩展的语言，比如 React 的 JSX 。

### Babel 的安装与配置
>>>>>>> 70f0ef78fcbc4ef41773f4ff1ac4dacf2a74dfdb
Babel 其实是几个模块化的包，其核心功能位于称为 babel-core 的 npm 包中，webpack 可以把其不同的包整合在一起使用，对于每一个你需要的功能或拓展，你都需要安装单独的包（用得最多的是解析 ES6 的 babel-preset-es2015 包和解析 JSX 的 babel-preset-react 包）。

安装依赖包

```js
npm install --save-dev babel-loader babel-core babel-preset-env
```

在 webpack 中配置 Babel 的方法如下：

```js
{
    test:/\.(jsx|js)$/,
    use:{
        loader:'babel-loader',
        options:{
            presets:[
                "es2015","react"
            ]
        }
    },
    exclude:/node_modules/
}
```


### .babelrc配置
虽然 Babel 可以直接在 webpack.config.js 中进行配置，但是考虑到 babel 具有非常多的配置选项，如果卸载 webapck.config.js 中会非常的雍长不可阅读，所以我们经常把配置卸载 .babelrc 文件里。

在项目根目录新建 .babelrc 文件，并把配置写到文件里。

. babelrc

```js
{
    "presets":["react","es2015"]
}
```

.webpack.config.js 里的 loader 配置

```js
{
    test:/\.(jsx|js)$/,
    use:{
        loader:'babel-loader',
    },
    exclude:/node_modules/
}
```

### ENV：
babel-preset-env 代替 babel-preset-ES2015 , babel 官方推出了 babel-preset-env ，并建议在使用的时候选择 env 代替之前的 ES20** 。env 为我们提供了更智能的编译选择。

```js
npm install --save-dev babel-preset-env
```

然后修改 .babelrc 里的配置文件。其实只要把之前的 es2015 换成 env 就可以了。

```js
{
    "presets":["react","env"]
}
```

## 3.3 打包公共代码
CommonsChunkPlugin 插件，是一个可选的用于建立一个独立文件 (又称作 chunk ) 的功能，这个文件包括多个入口 chunk 的公共模块。

通过将公共模块拆出来，最终合成的文件能够在最开始的时候加载一次，便存到缓存中供后续使用。这个带来速度上的提升，因为浏览器会迅速将公共的代码从缓存中取出来，而不是每次访问一个新页面时，再去加载一个更大的文件。

### 公共chunk 用于 入口chunk (entry chunk)
生成一个额外的 chunk 包含入口 chunk 的公共模块。

```js
new webpack.optimize.CommonsChunkPlugin({
  name: "commons",
  // ( 公共chunk(commnons chunk) 的名称)

  filename: "commons.js",
  // ( 公共chunk 的文件名)

  // minChunks: 3,
  // (模块必须被3个 入口 chunk 共享)

  // chunks: ["pageA", "pageB"],
  // (只使用这些 入口chunk)
})
```

你必须在 入口 chunk 之前加载生成的这个公共 chunk:

```js
<script src="commons.js" charset="utf-8"></script>
<script src="entry.bundle.js" charset="utf-8"></script>
```

### 明确第三方库 chunk
将你的代码拆分成公共代码和应用代码。

```js
entry: {
  vendor: ["jquery", "other-lib"],
  app: "./entry"
},
plugins: [
  new webpack.optimize.CommonsChunkPlugin({
    name: "vendor",
    // filename: "vendor.js"
    // (给 chunk 一个不同的名字)

    minChunks: Infinity,
    // (随着 entry chunk 越来越多，
    // 这个配置保证没其它的模块会打包进 vendor chunk)
  })
]
```

### 将公共模块打包进父 chunk
使用代码拆分功能，一个 chunk 的多个子 chunk 会有公共的依赖。为了防止重复，可以将这些公共模块移入父 chunk。这会减少总体的大小，但会对首次加载时间产生不良影响。如果预期到用户需要下载许多兄弟 chunks（例如，入口 trunk 的子 chunk），那这对改善加载时间将非常有用。

```js
new webpack.optimize.CommonsChunkPlugin({
  // names: ["app", "subPageA"]
  // (选择 chunks，或者忽略该项设置以选择全部 chunks)

  children: true,
  // (选择所有被选 chunks 的子 chunks)

  // minChunks: 3,
  // (在提取之前需要至少三个子 chunk 共享这个模块)
})
```

### 额外的异步公共 chunk
<<<<<<< HEAD
与上面的类似，但是并非将公共模块移动到父 chunk（增加初始加载时间），而是使用新的异步加载的额外公共chunk。当下载额外的 chunk 时，它将自动并行下载。
=======
与上面的类似，但是并非将公共模块移动到父 chunk（增加初始加载时间），而是使用新的异步加载的额外公共 chunk 。当下载额外的 chunk 时，它将自动并行下载。
>>>>>>> 70f0ef78fcbc4ef41773f4ff1ac4dacf2a74dfdb

```js
new webpack.optimize.CommonsChunkPlugin({
  name: "app",
  // or
  names: ["app", "subPageA"]
  // the name or list of names must match the name or names
  // of the entry points that create the async chunks

  children: true,
  // (选择所有被选 chunks 的子 chunks)

  async: true,
  // (创建一个异步 公共chunk)

  minChunks: 3,
  // (在提取之前需要至少三个子 chunk 共享这个模块)
})
```

## 3.4 代码分割和懒加载
webpack 可以帮助我们将代码分成不同的逻辑块，在需要的时候加载这些代码。

### 使用 require.ensure() 来拆分代码
require.ensure() 是一种使用 CommonJS 的形式来异步加载模块的策略。在代码中通过 require.ensure([<fileurl>]) 引用模块，其使用方法如下：

```js
require.ensure(dependencies: String[], callback: function(require), chunkName: String);
```

第一个参数指定依赖的模块，第二个参数是一个函数，在这个函数里面你可以使用 require 来加载其他的模块，webpack 会收集 ensure 中的依赖，将其打包在一个单独的文件中，在后续用到的时候使用 jsonp 异步地加载进去。


```js
//进行代码分割
require.ensure(['lodash'],function(){
    var _ = require('lodash');//上边的require.ensure只会引入进来，但是并不会执行，再次require才会执行。
},'vendor')
```

或者

```js
if(page=='subPageA'){
    require.ensure(['./subPageA'],function(){
        var subPageA=require('subPageA');
    },'subPageA')
}else if(page=='subPageB'){
    require.ensure(['./subPageB'],function(){
        var subPageA=require('subPageB');
    },subPageB)
}
```

或者

```js
require.ensure(['./subPageA','./subPageB'],function(){
        var subPageA=require('subPageA');
        var subPageB=require('subPageB');
    },common)
    //common表示这个模块的名字
```

但是仅仅这样配置并不能把公共 js 抽离出来，在多页面应用中可以通过 new webpack.optimize.CommonsChunkPlugin 这个 plugin 来实现，但是对于单页面来说，就需要借助 require.include 了

```js
require.include('./moduleA')

if(page=='subPageA'){
    require.ensure(['./subPageA'],function(){
        var subPageA=require('subPageA');
    },'subPageA')
}else if(page=='subPageB'){
    require.ensure(['./subPageB'],function(){
        var subPageA=require('subPageB');
    },subPageB)
}
```

这样就会把公共模块 moduleA 给抽离出来。

### import
import 与 require.ensure 最大的区别就是，他在引入的时候会直接执行，而不需要在此 require 了

```js
import('./subPageA').then(function(){

})
```

但是这样打包出来的是没有 chunkname 的，怎么添加 chunkname 呢？需要 webpack3+ 的魔法注释

```js
import(/*webpackChunkName:'subPageA'*/'./subPageA').then(function(){

})
```

## 3.5 处理css
### 打包CSS
首先，在 src 目录下建立 css 文件夹，和 index.css 文件，并编写如下代码：

```js
body{
    background: burlywood;
    color:white;
    font-size:30px;
}
```

建立好后，需要引入到入口文件中，才可以打包。在 entery.js 的首行加入代码：

```js
import css from './css/index.css';
```
CSS 和引入做好后，我们就需要使用 loader 来解析 CSS 文件了，这里我们需要两个解析用的 loader，分别是 style-loader 和 css-loader。

### style-loader
它是用来处理 css 文件中的 url() 等。
用 npm install 进行项目安装：

```js
npm install --save-dev style-loader
```

### CSS-loader
它是用来将 css 插入到页面的 style 标签。
用 npm install 进行项目安装：

```js
npm install --save-dev css-loader
```

### loaders配置：

修改 webpack.config.js 中 module 属性中的配置代码如下：

webpack.config.js

```js
module:{
        rules: [
            {
              test: /\.css$/,
              use: [ 'style-loader', 'css-loader' ]
            }
          ]
    },
```

### 提取 CSS
目前，打包后的文件中，css 是打包在 js 代码里面的，这样不便于以后的维护，所以需要把 CSS 从 js 中分离出来，我们需要使用插件 Extract Text Plugin。

安装：

```js
npm install --save-dev extract-text-webpack-plugin
```

在 webpack.config.js 中引入

```js
const ExtractTextPlugin = require('extract-text-webpack-plugin');
```

在 Plugins中配置:

```js
new ExtractTextPlugin('css/index.css');
//css/index.css是分离后的路径位置
```

修改 Loader 配置：

```js
module:{
    rules:[
        {
            test:/\.css$/,
            use:ExtractTextPlugin.extract({
                fallback:"style-loader",
                use:"css-loader"
            })
        }
    ]
}
```

### 配置Less

Less 作为目前很火的 CSS 预处理语言，它扩展了 CSS 语言，增加了变量、Mixin 、函数等特性，使 CSS 更易维护和扩展；

安装:

```js
npm install --save-dev less less-loader
```

在 webpack.config.js 中配置 Loader:

```js
module:{
    rules:[
        {
            test:/\.less$/,
            use:ExtractTextPlugin.extract({
                fallback:"style-loader",
                use:[{
                    loader:"css-loader"
                },{
                    loader:"less-loader"
                }]
            })
        }
    ]
}
```

### 配置sass
Sass 的打包和分离和 less 的类似，首先下载安装 Sass 所支持的服务与 loader。
安装：

```js
npm install --save-dev node-sass sass-loader
```

在 webpack.config.js 中配置 Loader:

```js
module:{
    rules:[
        {
            test:/\.less$/,
            use:ExtractTextPlugin.extract({
                fallback:"style-loader",
                use:[{
                    loader:"css-loader"
                },{
                    loader:"sass-loader"
                }]
            })
        }
    ]
}
```

### PostCSS-in-webpack
CSS3 是目前作为一个前端必须要掌握的技能，但是由于现在好多浏览器还是不兼容 CSS3，所以前端需要多写很丑很难看的前缀代码；以前都是边查 Can I Use ，边添加，这样很麻烦，现在配置一个插件 postcss就可以搞定；

<<<<<<< HEAD
PostCSS 是一个 CSS 的处理平台，它可以帮助你的 CSS 实现更多的功能，但是今天我们就通过其中的一个加前缀的功能，初步了解一下 PostCSS。
=======
PostCSS 是一个 CSS 的处理平台，它可以帮助你的 CSS 实现更多的功能，但是今天我们就通过其中的一个加前缀的功能，初步了解一下 PostCSS 。
>>>>>>> 70f0ef78fcbc4ef41773f4ff1ac4dacf2a74dfdb

安装：

```js
npm install --save-dev postcss-loader autoprefixer
```

在根目录下，建立一个 postcss.config.js 文件：

```js
module.exports = {
    plugins:[
        require('autoprefixer')
    ]
}
```

这就是对 postCSS 一个简单的配置，引入了 autoprefixer 插件。让 postCSS 拥有添加前缀的能力，它会根据 can i use 来增加相应的css3属性前缀。

在 webpack.config.js 中配置 Loader:

```js
{
    test: /\.css$/,
    use: extractTextPlugin.extract({
        fallback: 'style-loader',
        use: [
            { loader: 'css-loader', 
                options: { importLoaders: 1 } 
            },
            'postcss-loader'
        ]
    })

}
```

## 3.6 Tree-shaking
Tree-shaking 字面意思就是摇晃树， 其实就是去除那些引用的但却没有使用的代码。 
Tree-shaking 概念最早由 Rollup.js 提出，后来在 webpack2 中被引入进来，但是这个这一特性能够被支持得益于 ES6 modules 的静态特性。ES6的模块声明相比于传统 CommonJS 的同步 require 有着本质区别。这种 modules 设计保证了依赖关系是提前确定的，使得静态分析成为了可能，与运行时无关。 
并且 webpack 中并没有直接对 tree-shaking 的配置，需要借助 uglifyjs-webpack-plugin。

webpack 中 tree-shaking主要分为两个方面:

* JS tree shaking： JS 文件中定义的多个方法或者变量没有全部使用。
* CSS tree shaking： 样式通过 css 选择器没有匹配到相应的 DOM 节点。

### JS Tree-shaking

将文件标记为无副作用( side-effect-free )
在一个纯粹的 ESM 模块世界中，识别出哪些文件有副作用很简单。然而，我们的项目无法达到这种纯度，所以，此时有必要向 webpack 的 compiler 提供提示哪些代码是“纯粹部分”。

这种方式是通过 package.json 的 "sideEffects" 属性来实现的。

```js
{
  "name": "your-project",
  "sideEffects": false
}
```

如同上面提到的，如果所有代码都不包含副作用，我们就可以简单地将该属性标记为 false，来告知 webpack，它可以安全地删除未用到的 export 导出。

> 「副作用」的定义是，在导入时会执行特殊行为的代码，而不是仅仅暴露一个 export 或多个 export 。举例说明，例如 polyfill ，它影响全局作用域，并且通常不提供 export 。

如果你的代码确实有一些副作用，那么可以改为提供一个数组：

```js
{
  "name": "your-project",
  "sideEffects": [
    "./src/some-side-effectful-file.js"
  ]
}
```
压缩输出
通过如上方式，我们已经可以通过 import 和 export 语法，找出那些需要删除的“未使用代码(dead code)”，然而，我们不只是要找出，还需要在 bundle 中删除它们。为此，我们将使用 -p(production) 这个 webpack 编译标记，来启用 uglifyjs 压缩插件。

>注意，--optimize-minimize 标记也会在 webpack 内部调用 UglifyJsPlugin。
从 webpack 4 开始，也可以通过 "mode" 配置选项轻松切换到压缩输出，只需设置为 "production"。

webpack.config.js

```js
const path = require('path');

module.exports = {
  entry: './src/index.js',
  output: {
    filename: 'bundle.js',
    path: path.resolve(__dirname, 'dist')
  },
  mode: "production"
};
```

为了学会使用 tree shaking，你必须……

* 使用 ES2015 模块语法（即 import 和 export）。
* 在项目 package.json 文件中，添加一个 "sideEffects" 入口。
* 引入一个能够删除未引用代码( dead code )的压缩工具( minifier )（例如 UglifyJSPlugin ）。

### CSS Tree-shaking
像 Bootstrap 这样的框架往往会带有很多 CSS。在项目中通常我们只使用它的一小部分。就算我们自己写CSS，随着项目的进展，CSS 也会越来越多，有时候需求更改，带来了 DOM 结构的更改，这时候我们可能无暇关注 CSS 样式，造成很多 CSS 的冗余。

PurifyCSS
使用 PurifyCSS 可以大大减少 CSS 冗余，比如我们经常使用的 BootStrap (140KB)就可以减少到只有 35KB 大小。这在实际开发当中是非常有用的。

安装 PurifyCSS-webpack
从名字你就可以看出这是一个插件，而不是 loader。所以这个需要安装还需要引入。 PurifyCSS-webpack 要以来于 purify-css 这个包，所以这两个都需要安装。

```js
npm i –save-dev purifycss-webpack purify-css
```

引入 glob
因为我们需要同步检查html模板，所以我们需要引入 node 的 glob 对象使用。在 webpack.config.js 文件头部引入 glob。

```js
const glob = require('glob');
```

引入 purifycss-webpack
同样在 webpack.config.js 文件头部引入 purifycss-webpack

```js
const PurifyCSSPlugin = require("purifycss-webpack");
```

配置 plugins
引入完成后我们需要在 webpack.config.js 里配置 plugins 。代码如下，重点看标黄部分。

```js
plugins:[
    //new uglify() 
    new htmlPlugin({
        minify:{
            removeAttrubuteQuotes:true
        },
        hash:true,
        template:'./src/index.html'
        
    }),
    new extractTextPlugin("css/index.css"),
    new PurifyCSSPlugin({
        // Give paths to parse for rules. These should be absolute!
        paths: glob.sync(path.join(__dirname, 'src/*.html')),
        })
 
]
```

这里配置了一个 paths ，主要是需找 html 模板，purifycss 根据这个配置会遍历你的文件，查找哪些css 被使用了。

配置好上边的代码，我们可以故意在 css 文件里写一些用不到的属性，然后用 webpack 打包，你会发现没用的 CSS 已经自动给你删除掉了。在工作中记得一定要配置这个 plugins ，因为这决定你代码的质量，非常有用。


## 3.7 文件处理
### 图片处理
在 index.html 文件中增加一个放置 div 的标签

```js
<div id="tupian"></div>
```

编写 css 文件，把图片作为背景显示。

```js
#tupian{
   background-image: url(../images/manhua.png);
   width:466px;
   height:453px;
}
```

安装 file-loader 和 url-loader

```js
npm install --save-dev file-loader url-loader
```

file-loader ：解决引用路径的问题，拿 background 样式用 url 引入背景图来说，我们都知道， webpack 最终会将各个模块打包成一个文件，因此我们样式中的 url 路径是相对入口 html 页面的，而不是相对于原始 css 文件所在的路径的。这就会导致图片引入失败。这个问题是用 file-loader 解决的，file-loader 可以解析项目中的 url 引入（不仅限于 css），根据我们的配置，将图片拷贝到相应的路径，再根据我们的配置，修改打包后文件引用路径，使之指向正确的文件。
url-loader：如果图片较多，会发很多 http 请求，会降低页面性能。这个问题可以通过 url-loader 解决。url-loader 会将引入的图片编码，生成 dataURl 。相当于把图片数据翻译成一串字符。再把这串字符打包到文件中，最终只需要引入这个文件就能访问图片了。当然，如果图片较大，编码会消耗性能。因此url-loader 提供了一个 limit 参数，小于 limit 字节的文件会被转为 DataURl ，大于 limit 的还会使用 file-loader 进行 copy。

配置 url-loader
我们安装好后，就可以使用这个 loader 了，记得在 loader 使用时不需要用 require 引入，在plugins 才需要使用 require 引入。

webpack.config.js文件

```js
//模块：例如解读 CSS,图片如何转换，压缩
    module:{
        rules: [
            {
              test: /\.css$/,
              use: [ 'style-loader', 'css-loader' ]
            },{
               test:/\.(png|jpg|gif)/ ,
               use:[{
                   loader:'url-loader',
                   options:{
                       limit:500000
                   }
               }]
            }
          ]
    },
```

<<<<<<< HEAD
* test:/\.(png|jpg|gif)/ 是匹配图片文件后缀名称。
=======
* test： /\.(png|jpg|gif)/ 是匹配图片文件后缀名称。
>>>>>>> 70f0ef78fcbc4ef41773f4ff1ac4dacf2a74dfdb
* use：是指定使用的 loader 和 loader 的配置参数。
* limit：是把小于 500000B 的文件打成 Base64 的格式，写入JS 。
* 写好后就可以使用 webpack 进行打包了，这回你会发现打包很顺利的完成了。具体的 Base64 的格式，你可以查看视频中的样子。

#### 为什么只使用了url-loader
有的小伙伴会发现我们并没有在 webpack.config.js 中使用 file-loader ，但是依然打包成功了。我们需要了解 file-loader 和 url-loader 的关系。url-loader 和 file-loader 是什么关系呢？简答地说，url-loader 封装了 file-loader 。 url-loader 不依赖于 file-loader ，即使用 url-loader 时，只需要安装 url-loader 即可，不需要安装 file-loader ，因为 url-loader内置了 file-loader 。通过上面的介绍，我们可以看到，url-loader 工作分两种情况：

* 1.文件大小小于 limit 参数， url-loader 将会把文件转为 DataURL（ Base64格式 ）；

* 2.文件大小大于 limit ， url-loader 会调用 file-loader 进行处理，参数也会直接传给 file-loader。

也就是说，其实我们只安装一个 url-loader 就可以了。但是为了以后的操作方便，我们这里就顺便安装上 file-loader。

#### 如何把图片放到指定的文件夹下
前边两节课程，打包后的图片并没有放到images文件夹下，要放到 images 文件夹下，其实只需要配置我们的 url-loader 选项就可以了。

```js
   module:{
        rules: [
            {
              test: /\.css$/,
              use: extractTextPlugin.extract({
                fallback: "style-loader",
                use: "css-loader"
              })
            },{
               test:/\.(png|jpg|gif)/ ,
               use:[{
                   loader:'url-loader',
                   options:{
                       limit:5000,
                       outputPath:'images/',
                   }
               }]
            }
          ]
    },
```

<<<<<<< HEAD
### CSS分离时图片路径处理
在处理 css 时我们已经学会如何使用 extract-text-webpack-plugin 插件提取 css，利用 extract-text-webpack-plugin 插件很轻松的就把 CSS 文件分离了出来，但是 CSS 路径并不正确，很多小伙伴就在这里搞个几天还是没有头绪，网上也给出了很多的解决方案，我觉的最好的解决方案是使用publicPath 解决，我也一直在用。
=======
### CSS 分离时图片路径处理
在处理 css 时我们已经学会如何使用 extract-text-webpack-plugin 插件提取 css，利用 extract-text-webpack-plugin 插件很轻松的就把 CSS 文件分离了出来，但是 CSS 路径并不正确，很多小伙伴就在这里搞个几天还是没有头绪，网上也给出了很多的解决方案，我觉的最好的解决方案是使用 publicPath 解决，我也一直在用。
>>>>>>> 70f0ef78fcbc4ef41773f4ff1ac4dacf2a74dfdb

publicPath：是在 webpack.config.js 文件的 output 选项中，主要作用就是处理静态文件路径的。

在处理前，我们在 webpack.config.js 上方声明一个对象，叫 website。

```js
var website ={
    publicPath:"http://192.168.1.108:1717/"
}
```

注意，这里的 IP 和端口，是你本机的 ip 或者是你 devServer 配置的 IP 和端口。
然后在 output 选项中引用这个对象的 publicPath 属性。

```js
//出口文件的配置项
    output:{
        //输出的路径，用了Node语法
        path:path.resolve(__dirname,'dist'),
        //输出的文件名称
        filename:'[name].js',
        publicPath:website.publicPath
    },
```
配置完成后，你再使用 webpack 命令进行打包，你会发现原来的相对路径改为了绝对路径，这样来讲速度更快。

### 处理字体文件
#### 将字体图标和 css 打包到同一个文件中

```js
{
   test:/\.(png|woff|woff2|svg|ttf|eot)$/,
   use:{
        loader:'url-loader',
        options: {
            limit: 100000,  //这里要足够大这样所有的字体图标都会打包到css中
        }
}
```

上文中的 limit 一定要保证大于最大字体文件的大小，因为这个参数是告诉 url-loader，如果文件小于这个参数，那么就以 Data Url 的方式直接构建到文件中。使用这种方式最方便，不用打包后路径的问题，但是缺点就是构建出来的文件特别大，如果线上不要使用这种方式打包。 

#### 将字体图标独放打包到一个文件夹中

```js
{
   test: /\.(woff|woff2|svg|ttf|eot)$/,
   use:[
        {
	        loader:'file-loader',
	        options:{name:'fonts/[name].[hash:8].[ext]'}}
	        //项目设置打包到dist下的fonts文件夹下
     ]
 }
```

打包中会遇到的问题就是路径不对，可以通过配置 publicPath 解决。

<<<<<<< HEAD
### Json配置文件使用
=======
### Json 配置文件使用
>>>>>>> 70f0ef78fcbc4ef41773f4ff1ac4dacf2a74dfdb
在实际工作中，我们的项目都会配置一个 Json 的文件或者说 API 文件，作为项目的配置文件。有时候你也会从后台读取到一个 json 的文件，这节课就学习如何在 webpack 环境中使用 Json。如果你会 webpack1 或者 webpack2 版本中，你是需要加载一个 json-loader 的 loader 进来的，但是在webpack3.x 版本中，你不再需要另外引入了。

读出 Json 内容
第一步：现在我们的 index.html 模板中加入一个层，并给层一个 Id，为了是在 javascript 代码中可以方便引用。

```js
<div id="json"></div>
```
第二步：到 src 文件夹下，找到入口文件，我这里是 entry.js 文件。修改里边的代码，如下：

```js
var json =require('../config.json');
document.getElementById("json").innerHTML= json.name;
```
这两行代码非常简单，第一行是引入我们的 json 文件，第二行驶写入到到 DOM 中。

## 3.8 html in webpack
### 生成html
html-webpack-plugin 可以根据你设置的模板，在每次运行后生成对应的模板文件，同时所依赖的 CSS/JS 也都会被引入，如果 CSS/JS 中含有 hash 值，则 html-webpack-plugin 生成的模板文件也会引入正确版本的 CSS/JS 文件。

安装

```js
npm install html-webpack-plugin --save-dev
```
引入

在webpack.config.js中引入：

```js
const HtmlWebpackPlugin = require('html-webpack-plugin');
```

配置

```js
module.exports = {
    entry: './app/index.js',
    output: {
        ...
    },
    module: {
        ...
    },
    plugins: [
        new HtmlWebpackPlugin({
            title: "This is the result",
            filename: "./index.html",
            template: "./app/index.html",
            inject: "body",
            favicon: "",
            minify: {
                caseSensitive: false,
                collapseBooleanAttributes: true,
                collapseWhitespace: true
            },
            hash: true,
            cache: true,
            chunks: ""
        })
    ]
};
```

然后看一下这些参数的意义：

* title: 生成的HTML模板的 title，如果模板中有设置 title 的名字，则会忽略这里的设置
* filename: 生成的模板文件的名字
* template: 模板来源文件
* inject: 引入模块的注入位置；取值有 true/false/body/head
* favicon: 指定页面图标；
* minify: 是 html-webpack-plugin 中集成的 html-minifier ，生成模板文件压缩配置
* caseSensitive: false, //是否大小写敏感
<<<<<<< HEAD
* collapseBooleanAttributes: true, //是否简写 boolean 格式的属性如：disabled="disabled" 简写为disabled 
=======
* collapseBooleanAttributes: true, //是否简写 boolean 格式的属性如：disabled="disabled" 简写为 disabled 
>>>>>>> 70f0ef78fcbc4ef41773f4ff1ac4dacf2a74dfdb
* collapseWhitespace: true //是否去除空格
* hash: 是否生成hash添加在引入文件地址的末尾，类似于我们常用的时间戳
* cache: 是否需要缓存，如果填写 true，则文件只有在改变时才会重新生成
* chunks: 引入的模块，这里指定的是 entry 中设置多个 js 时，在这里指定引入的 js，如果不设置则默认全部引入

### html中引入图片
html-withimg-loader
html-withimg-loader 就是我们今天的重点了，这个插件并不是很火，也是我个人喜欢的一个小loader 。解决的问题就是在hmtl文件中引入 <img> 标签的问题。

安装：

```js
npm install html-withimg-loader --save
```

配置 loader
webpack.config.js

```js
{
    test: /\.(htm|html)$/i,
     use:[ 'html-withimg-loader'] 
}
```

然后在终端中可以进行打包了。你会发现 images 被很好的打包了。并且路径也完全正确。

<<<<<<< HEAD
# webpack环境配置
## 搭建开发环境
在使用 webpack-cli 进行打包时，通过命令 webpack --watch即可开启 watch 模式，进入 watch 模式之后，一旦依赖树中的某一个模块发生了变化，webpack 就会重新进行编译。
=======
# webpack 环境配置
## 搭建开发环境
在使用 webpack-cli 进行打包时，通过命令 webpack --watch 即可开启 watch 模式，进入 watch 模式之后，一旦依赖树中的某一个模块发生了变化，webpack 就会重新进行编译。
>>>>>>> 70f0ef78fcbc4ef41773f4ff1ac4dacf2a74dfdb

### clean-webpack-plugin
在 webpack 中打包生成的文件会覆盖之前的文件，不过生成文件的时候文件名加了 hash 之后会每次都生成不一样的文件，这就会很麻烦，不但会生成很多冗余的文件，还很难搞清楚到底是哪个文件，这就需要引入该插件 

```js
npm install –save-dev clean-webpack-plugin
```

```js
//webpack.config.js
//引入clean-webpack-plugin
const CleanWebpackPlugin = require('clean-webpack-plugin');

//plugin 插入你想删除的路径，注意在生成出来文件之前，他会删除 public 的文件夹，而不是根据生成的文件来删除对应的文件。
new CleanWebpackPlugin(['public']);
```

### webpack dev server
webpack-dev-server 简介：

* 是一个小型 node.js express 服务器
* 新建一个开发服务器，可以 serve 我们 pack 以后的代码，并且当代码更新的时候自动刷新浏览器
* 启动 webpack-dev-server 后，你在目标文件夹中是看不到编译后的文件的，实时编译后的文件都保存到了内存当中。
两种自动刷新方式：
* iframe mode
在网页中嵌入了一个 iframe ，将我们自己的应用注入到这个 iframe 当中去，因此每次你修改的文件后，都是这个 iframe 进行了 reload
命令行：webpack-dev-server，无需 --inline
浏览器访问：http://localhost:8080/webpack-dev-server/index.html
* inline mode
命令行：webpack-dev-server --inline
浏览器访问：http://localhost:8080

<<<<<<< HEAD
安装webpack-dev-server
=======
安装 webpack-dev-server
>>>>>>> 70f0ef78fcbc4ef41773f4ff1ac4dacf2a74dfdb

```js
npm install webpack-dev-server --save-dev
```

在 webpack.config.js 中添加配置

```
var webpack=require('webpack');
module.exports = {
……
devServer: {
    historyApiFallback: true,
    inline: true,//注意：不写hot: true，否则浏览器无法自动更新；也不要写  colors:true，progress:true等，webpack2.x已不支持这些
},
plugins:[
    ……
    new webpack.HotModuleReplacementPlugin()
 ]
    ……
};
```

在 package.json 里配置运行的命令

```js
"scripts": 
{ 
　　"start": "webpack-dev-server --inline"
},
```

## 代理远程接口
如果你有单独的后端开发服务器 API，并且希望在同域名下发送 API 请求 ，那么代理某些 URL 会很有用。
webpack-dev-server 使用了非常强大的 http-proxy-middleware 包。

配置如下：

```js
proxy: {
    '/apis': {
        target: '', //要代理到的地址
        secure: false, //若地址为https，需要设置为false
        onProxyReq: function(proxyReq, req, res) { //提前设置一些代理的头部，如token信息等

        },
        //...其他配置请自行查阅文档http-proxy-middleware文档
    }
}
```

## 模块热更新

DevServer 还支持一 种叫做模块热替换( Hot Module Replacement )的技术可在不刷新整个网页的情况下 做到超 灵敏实时预览。原理是在一个源码发生变化时，只需重新编译发生变化的模块，再用新输 出 的模块替换掉浏览器中对应的老模块 。

模块热替换技术的优势如下：

* 实时预览反应更快，等待时间更短。
* 不刷新浏览器时能保留当前网页的运行状态，例如在使用 Redux 管理数据的应用中搭配模块热替换能做到在代码更新时 Redux 中的数据保持不变。

总的来说，模块热替换技术在很大程度上提升了开发效率和体验 。

DevServer 默认不会开启模块热替换模式，要开启该模式，则只 需在启动时带上参数 --hot ，完整的命令是 webpack-dev-server --hot。

除了通过在启动时带上 --hot 参数，还可以通过接入 Plugin 实现，相关代码如下 :

```js
canst HotModuleReplacementPlugin = require (’ webpack/lib/HotModuleReplacementPlugin ’);
module.exports = { 
	entry:{
		//为每个入口都注入代理客户端
		main: [’ webpack-dev-server/client?http://localhost:8080 /’, ’webpack/hot/dev-server ’,’. / src/main.j s ’],
	},
	 plugIns : [
		//该插件的作用就是实现模块热替换，实际上若启动时带上 、 --hot 、参数，就会注入该插件，生 成 .hot-update.json 文件。
		new HotModuleReplacementPlugin() ,
	],
	devServer : {
		//告诉 DevServer 要开启 模块热替换模式 
		hot: true ,
	},
};	

```
借助于 style-loader 的帮助，CSS 的模块热替换实际上是相当简单的。当更新 CSS 依赖模块时，此 loader 在后台使用 module.hot.accept 来修补(patch) `<style>`标签。

但当修改 js 文件时，我们会发现模块热替换没有生效，而是整个页面被刷新了，为了让使用者在使用模块热替换功能时能灵活地控制老模块被替换时的逻辑，webpack 允许在源码中定义一些代码去做相应的处理。

```js
// 只有当开启了模块热替换时 module.hot 才存在 
if (module.hot) {
    module.hot.accept(['.IAppComponent'],()=>{
		//在新的 AppComponent 加载成功后重新执行组建渲染逻辑 		render(<AppComponentl>, window.document.getElementByid ('app'));
	}) ;
}
```

其中的 module.hot 是当开启模块热替换后注入全局的 API，用于控制模块热替换的逻辑 。
当子模块发生更新时，更新事件会一层层地向上传递，也就是从 AppComponent.js 文件传递到 main.js 文件，直到有某层的文件接收了当前变化的模块，即 main.js 文 件中定义的 module.hot.accept(['.IAppComponent'], callback)，这时就会调用 callback 函数去执行自定义逻辑。 如果事件一直往上抛，到最外层都没有文件接收它，则会直接刷新网页。

<<<<<<< HEAD
## 开启调试SourceMap

作为一个程序员每天的大部分工作就是调试自己写的程序，那我们使用了webpack后，所以代码都打包到了一起，给调试带来了麻烦，但是webpack已经为我们充分考虑好了这点，它支持生产 Source Maps 来方便我们的调试。
=======
## 开启调试 SourceMap

作为一个程序员每天的大部分工作就是调试自己写的程序，那我们使用了webpack后，所以代码都打包到了一起，给调试带来了麻烦，但是 webpack 已经为我们充分考虑好了这点，它支持生产 Source Maps 来方便我们的调试。
>>>>>>> 70f0ef78fcbc4ef41773f4ff1ac4dacf2a74dfdb
在使用 webpack 时只要通过简单的 devtool 配置，webapck 就会自动给我们生产 source maps 文件，map 文件是一种对应编译文件和源文件的方法，让我们调试起来更简单。

在配置 devtool 时，webpack 给我们提供了四种选项：

<<<<<<< HEAD
* source-map: 在一个单独文件中产生一个完整且功能完全的文件。这个文件具有最好的 source map,但是它会减慢打包速度；
* cheap-module-source-map: 在一个单独的文件中产生一个不带列映射的map，不带列映射提高了打包速度，但是也使得浏览器开发者工具只能对应到具体的行，不能对应到具体的列（符号）,会对调试造成不便。
=======
* source-map: 在一个单独文件中产生一个完整且功能完全的文件。这个文件具有最好的 source map ，但是它会减慢打包速度；
* cheap-module-source-map: 在一个单独的文件中产生一个不带列映射的map ，不带列映射提高了打包速度，但是也使得浏览器开发者工具只能对应到具体的行，不能对应到具体的列（符号），会对调试造成不便。
>>>>>>> 70f0ef78fcbc4ef41773f4ff1ac4dacf2a74dfdb
* eval-source-map: 使用 eval 打包源文件模块，在同一个文件中生产干净的完整版的 sourcemap ，但是对打包后输出的JS文件的执行具有性能和安全的隐患。在开发阶段这是一个非常好的选项，在生产阶段则一定要不开启这个选项。
* cheap-module-eval-source-map: 这是在打包文件时最快的生产 source map 的方法，生产的 Source map 会和打包后的 JavaScript 文件同行显示，没有影射列，和 eval-source-map 选项具有相似的缺点。
四种打包模式，有上到下打包速度越来越快，不过同时也具有越来越多的负面作用，较快的打包速度的后果就是对执行和调试有一定的影响。

个人意见是，如果大型项目可以使用 source-map，如果是中小型项目使用 eval-source-map 就完全可以应对，需要强调说明的是，source map 只适用于开发阶段，上线前记得修改这些调试设置。

简单的配置：

```js
module.exports = {
  devtool: 'eval-source-map',
  entry:  __dirname + "/app/main.js",
  output: {
    path: __dirname + "/public",
    filename: "bundle.js"
  }
}
```

## 设置 ESLint 检查代码格式

首先，要使 webpack 支持 eslint，就要要安装 eslint-loader ，命令如下:

```js
npm install --save-dev eslint-loader
```

在 webpack.config.js 中添加如下代码：

```js
{
    test: /\.js$/,
    loader: 'eslint-loader',
    enforce: "pre",
    include: [path.resolve(__dirname, 'src')], // 指定检查的目录
    options: { // 这里的配置项参数将会被传递到 eslint 的 CLIEngine 
        formatter: require('eslint-friendly-formatter') // 指定错误报告的格式规范
    }
}
```

> 注：formatter 默认是 stylish ，如果想用第三方的可以安装该插件，如上方的示例中的 eslint-friendly-formatter 。

其次，要想 webpack 具有 eslint 的能力，就要安装 eslint，命令如下：

```js
npm install --save-dev eslint
```

最后，项目想要使用那些 eslin 规则，可以创建一个配置项文件 '.eslintrc.js'，代码如下:

```js
module.exports = {
    root: true, 
    parserOptions: {
        sourceType: 'module'
    },
    env: {
        browser: true,
    },
    rules: {
        "indent": ["error", 2],
        "quotes": ["error", "double"],
        "semi": ["error", "always"],
        "no-console": "error",
        "arrow-parens": 0
    }
}
```

这样，一个简单的 webpack 引入 eslint 已经完成了。


# 总结
webpack 确实是一个功能强大的模块打包工具，丰富的 loader 和 plugin 使得其功能多而强。学习 webpack 使得我们可以自定义自己的开发环境，无需依赖 create-react-app 和 Vue-Cli 这类脚手架，也可以针对不同的需求对代码进行不同方案的处理。



















