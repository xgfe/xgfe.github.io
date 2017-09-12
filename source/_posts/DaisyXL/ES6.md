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
<img src="https://p0.meituan.net/dpnewvc/98edd093d4e832cd1c7bcfdfd2f699d8277917.png" width="1000px" height="300px">
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
显而易见，ES6提供了深拷贝的接口，可以一行代码完胜ES5实现对象深拷贝。不过需要说明的是，Object.assign跟我们手动复制的效果相同，所以一样只能处理深度只有一层的对象，没办法做到真正的 Deep Copy。不过如果要复制的对象只有一层的话可以考虑使用它。
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
<img src="https://p1.meituan.net/dpnewvc/dcb6af4925ecdda34fa5ab6452b969ad99150.png" width="800px" height="350px">

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
<pre>(全局安装）<code>$ npm instal --global gulp</code></pre>
<pre>(项目安装）<code>$ npm install --save-dev gulp</code></pre>
<pre>(根目录创建gulpfile.js/gulpfile.babel.js）<code>$ touch gulpfile.js</code></pre>

gulpfile.js文件内容
```javascript
var gulp = require('gulp');
gulp.task('default', function() {

});
```
<pre>(运行）<code>$ gulp</code></pre>
<pre>(运行并监听）<code>$ gulp --watch</code></pre>

具体使用说明可以阅读[gulp中文文档](http://www.gulpjs.com.cn/)

**3 编译工具（ babel, webpack ）** 

babel：js编译器，把ES6代码编译成ES5代码。
webpack：处理模块化，项目依赖的关系，import实现。
webpack-stream—webpack：对gulp对支持。

**4 代码实现** 

1.创建ES6前端工程,并创建三个并行模块：
- **app**
- **server**
- **tasks**

2.app目录为前端项目代码，包含**html**（模板页面）,**js**（交互实现）,**css**（样式）
*ps.1:这里的模版页面创建的不是html页面，而是ejs文件，是因为实战工程的服务器端代码是通过express这个nodejs框架创建的。*
*ps.2:js目录下的index.js文件为入口脚本文件，同样的views目录下的index.ejs为入口模板文件。*

3.server为服务器端目录，这里面我们使用**nodejs**来写服务器端代码。
在server目录下执行下面命令,在当前目录使用ejs模板引擎,如果执行express出错，先检查下是否已经安装nodejs，并install了express脚手架。
<pre><code>express -e .
npm install
</code></pre>

4.task为构建工具目录
   - util--放置常见脚本的目录
        args.js--定义gulp命令行脚本 .option就是定义gulp -***中对内容  .argv表示输入对命令行以字符串形式进行解析
   - scripts.js--构建脚本，通过gulp对js文件进行重命名，压缩和存放  脚本服务文件
   - pages.js--模板脚本
   - server.js--服务器脚本
   - css.js--监听样式脚本
   - browser.js--浏览器自动监听变化并编译到指定文件夹
   - clean.js--编译前情况文件夹
   - build.js--把所有脚本关联起来，编排执行顺序
   - default.js--默认执行的任务

5.使用npm自动生成package.json文件，有这个文件就可以使用npm来获取依赖包了
<pre><code>npm init</code></pre>

6.创建设置babel编译工具的文件.babelrc

7.创建gulp的配置文件gulpfile.babel.js

*ps.2:官网上给的是创建gulpfile.js,是ES5使用的，但是当前工程是ES6工程，使用官网给出的文件名运行gulp命令会报错。*


```md
**最终目录结构**
app
    js--交互实现
        class--类
            test.js
        index.js
    css--样式
    views--模板页面
        error.ejs
        index.ejs
server
tasks
    util
        args.js
    scripts.js
    pages.js
    server.js
    css.js
    browser.js
    clean.js
    build.js
    default.js
package.json
.babelrc
gulpfile.babel.js
```
这里没有粘贴每个配置文件的内容，若需要可以克隆https://github.com/DaisyGXL/Lemmon-tree.git 仓库的地址获取搭建好的工程es6-project查看具体配置文件，其中我对每个文件的配置和依赖包的用处进行了注释说明。

8.通过<code>npm install *** --save-dev</code>命令把涉及到的依赖包依赖到本地，并添加到package.json文件中，可以通过<code>gulp</code>命令检查是否有使用的依赖包没有更新到本地,直到命令行输出下面内容为止，ES6工程基本搭建完成。
<pre><code>➜  es6 git:(master) gulp
[16:53:30] Requiring external module babel-register
[16:53:31] Using gulpfile ~/works/es6/gulpfile.babel.js
[16:53:31] Starting 'build'...
[16:53:31] Starting 'clean'...
[16:53:31] Finished 'clean' after 10 ms
[16:53:31] Starting 'css'...
[16:53:31] Finished 'css' after 16 ms
[16:53:31] Starting 'pages'...
[16:53:31] Finished 'pages' after 17 ms
[16:53:31] Starting 'scripts'...
[16:53:31] Version: webpack 3.5.5
   Asset     Size  Chunks             Chunk Names
index.js  2.94 kB       0  [emitted]  index
[16:53:31] Finished 'scripts' after 290 ms
[16:53:31] Starting 'browser'...
[16:53:31] Finished 'browser' after 92 μs
[16:53:31] Starting 'serve'...
[16:53:31] Finished 'serve' after 77 μs
[16:53:31] Finished 'build' after 338 ms
[16:53:31] Starting 'default'...
[16:53:31] Finished 'default' after 25 μs</code></pre>
从输出可以看出，gulp执行的顺序，build --> clean --> css --> pages --> scripts，那么为什么会按照这样的顺序执行呢？
我们前面创建了一个gulpfile.babel.js，在文件中指定了gulp运行时，先进入task目录。
```javascript
requireDir('./tasks');
```
那么，gulp 会进入task目录寻找一个叫做default.js的文件,该文件中指定了启动时默认要执行的脚本build，也就是编译脚本。在build.js这个文件中，我们来编排编译步骤，即是上面运行的这种步骤。
<img src="https://p1.meituan.net/dpnewvc/ba5a70a25d75752961db41f1b315cb7627416.png" width="520px" height="260px">
9.无报错后，通过gulp --watch使服务处于监听状态,运行出现最后一行，则启动并监听成功。
<pre><code>➜  es6 git:(master) gulp --watch
[17:02:49] Requiring external module babel-register
[17:02:50] Using gulpfile ~/works/es6/gulpfile.babel.js
[17:02:50] Starting 'build'...
[17:02:50] Starting 'clean'...
[17:02:50] Finished 'clean' after 9.31 ms
[17:02:50] Starting 'css'...
[17:02:50] Finished 'css' after 16 ms
[17:02:50] Starting 'pages'...
[17:02:50] Finished 'pages' after 16 ms
[17:02:50] Starting 'scripts'...
[17:02:50] Version: webpack 3.5.5
   Asset     Size  Chunks             Chunk Names
index.js  2.94 kB       0  [emitted]  index
[17:02:50] Finished 'scripts' after 281 ms
[17:02:50] Starting 'browser'...
[17:02:50] Starting 'serve'...
livereload[tiny-lr] listening on 35729 ...</pre></code>

至此，前端开发框架已经搭建好了，编辑index.ejs模板页面显示内容，通过localhost：3000访问

然而，我们发现，有一些ES6的项目网页依赖了livereload包却并不能自动进行刷新，仍然需要手动去刷新，也就是自动构建中的辅助功能未得到实现。
那么检查一下在server目录中的app.js中是否缺少这样一行代码：
```javascript
app.use(require('connect-livereload')());
```

最后，因为学习那段时间身边的小伙伴们都很沉迷彩票，就简单做了个彩票业务的demo，有些逻辑还没有写完，后面会不断完善。
git仓库地址：https://github.com/DaisyGXL/Lemmon-tree.git  工程名：cp-project