title: ES6项目构建
date: 2017-08-28
categories: DaisyXL
tags:
- javascript
- ES6

---

本文主要结合自己学习ES6的过程，说明了如何从零开始搭建一个ES6前端框架，并在大家都很关注的彩票业务中进行应用。

<!-- more -->
# 前言：为什么要使用ES6？
ECMAScript6，又叫ECMAScript 2015，和ES3以及ES5的区别大概就像下面这个图一样，ES6相对早先几个版本有更加强大的生产力，能够提高开发效率。
<img src="/uploads/DaisyXL/ES6/ES.png" width="1000px" height="300px">
同样实现对象深拷贝，看看下面两种实现方式。
```javascript
//ES5
var creatAssign = function(keysFunc, defaults) {
    return function(obj) {
        var length = arguments.length;
        if (defaults) {
            obj = Object(obj);
        }
        if (length < 2 || obj == null) {
            return obj;
        }
        for(var i=1; i<length; i++) {
            var source = arguments[index];
            var keys = keysFunc(source);
            var len = key.length;
            for(var j=0; j<length; j++) {
                var key = keys[i];
                if (!defaults || obj[key] === void 0) {
                    obj[key] = source[key];
                }
            }
        }
        return obj;
    };
};
var allKeys = function(obj) {
    var keys = [];
    for(key in obj) {
        keys.push(key);
    }
    return keys;
};
var extend = creatAssign(allKeys);
extend({t:1}, {k:2});
```
```javascript
//ES6
Object.assign({t:2}, {k:2});
```
显而易见，ES6提供了深拷贝的接口，可以一行代码完胜ES5实现对象深拷贝。
# ES6一些比较好的特性
**1.默认参数**
```javascript
//ES5
function hello(txt) {
    txt = txt || 'hello world';
}
//ES6
function hello(txt = 'hello') {
    //减少了代码冗余
}
```
**2.字符串模版**
```javascript
//ES5-引用underscore这个第三方库实现
var compiled = _.template("hello: <%= name %>");
compiled({name: 'xueningjiejie'});
//ES6
var name = 'xnjj';
var txt = `hello ${name}`;
```
当然，这篇文章不是一篇讲解ES6特性的文章，因此不会一一陈述，那么ES6还有哪些特性呢？
1.解构赋值： 改变了参数赋值和变量赋值的形式，使赋值方式更加多样。
2.箭头函数
3.Set和Map
4.异步操作，如Promise()
5.类和对象
6.模块化
...
想要了解更多具体特性，请认真研读阮一峰的[ECMAScript 6入门](http://es6.ruanyifeng.com/) 

# 项目构建
ES6是无法直接在浏览器中运行的，因此想要实现一个ES6工程并在浏览器中看到实现效果，需要先进行项目构建。

**1 基础架构** 
<img src="/uploads/DaisyXL/ES6/jiagou.png" width="800px" height="350px">

模块说明：
- 业务逻辑
    写页面，表现为html,js,css，通过js实现和服务器端进行交互
- 自动构建-编译
    把ES6的代码根据需要编译成ES5或ES3（需要兼容IE8以下低级浏览器的时候）的代码。         
- 自动构建-辅助
    实现修改代码自动刷新网页（livereload）  文件合并资源压缩（js,css,图片→base64编码）
- 服务接口
    后端服务器提供数据和接口
- mock接口
    用于开发阶段纯前端的交互测试

**2 任务自动化（gulp）**
定义：减少人工操作，让电脑自动监听操作，记性响应，提高效率。
作用：自动化处理sass／less转化为css的编译过程，文件合并，模块依赖，文件压缩。
gulp：自动化工具，替代之前流行grant，通过stream流操作使得级联操作非常块，完成任务自动化，顺畅工作流，由nodejs开发。

**gulp** 使用说明
(全局安装）$ npm instal --global gulp
(项目安装）$ npm install --save-dev gulp
(根目录创建gulpfile.js/gulpfile.babel.js）$ touch gulpfile.js
<img src="/uploads/DaisyXL/ES6/gulpfile-babel.png" width="450px" height="100px">
(运行）$ gulp
(运行并监听）$ gulp --watch

具体使用可以阅读[gulp中文文档](http://www.gulpjs.com.cn/)

**3 编译工具（ **babel, webpack** ）** 

babel：js编译器，把ES6代码编译成ES5代码。
webpack：处理模块化，项目依赖的关系，import实现。
webpack-stream—webpack：对gulp对支持。

**4 代码实现** 

创建 **ES6** 前端工程

公司内部可以从 [公司的](ssh://git@git.sankuai.com/~gaoxueling/es6.git) [git](ssh://git@git.sankuai.com/~gaoxueling/es6.git) [仓库](ssh://git@git.sankuai.com/~gaoxueling/es6.git)进行clone

完成目录结构（该目录结构为自行练习时需要创建的目录结构）
<img src="/uploads/DaisyXL/ES6/mulu.png" width="630px" height="920px">

自动构建

task-util-args.js   定义命令行参数，其中.option就是定义gulp -\*\*\*中对内容  .argv表示输入对命令行以字符串形式进行解析。

服务器搭建

以上步骤完成后，通过gulp指令检查有没有缺少依赖包，无抱错后，通过gulp --watch使服务处于监听状态。

<img src="/uploads/DaisyXL/ES6/runresult.png" width="520px" height="260px">

至此，前端开发框架已经搭建好了，编辑index.ejs模板页面，通过localhost：3000访问

**ps** ：此时有一个问题，就是不能实现热更新，那么补充一点：
需要在app.js中添加这样一行代码：

app.use(require(&#39;connect-livereload&#39;)());