title: ES6项目构建
date: 2017-08-28
categories: DaisyXL
tags:
- javascript
- ES6

---

本文主要说明了如何从零开始搭建一个ES6前端框架。

<!-- more -->

# ES6

# 项目构建

**1.** 基础架构
<img src="/uploads/DaisyXL/ES6/jiagou.png" width="800px" height="350px">

模块说明：

- 业务逻辑-页面（html,js,css）-和服务器端进行交互
- 自动构建-编译-ES6→ES5/ES3（ie8以下低级浏览器）                                                         
- 自动构建-辅助-自动刷新  文件合并资源压缩（js,css,,图片→base64编码）
- 服务接口-后端服务器提供数据和接口
- mock接口

**2.** 任务自动化（ **gulp** ）

定义：减少人工操作，让电脑自动监听文件变化。

作用：sass／less→css 编译过程，文件合并，模块依赖，文件压缩。

gulp：替代之前流行grant，通过stream流操作使得级联操作非常块，完成任务自动化，顺畅工作流，由nodejs开发。

**gulp** 使用说明

（全局安装）$ npm instal --global gulp

（项目安装）$ npm install --save-dev gulp

（根目录创建gulpfile.js/gulpfile.babel.js）$ touch gulpfile.js

<img src="/uploads/DaisyXL/ES6/gulpfile-babel.png" width="450px" height="100px">

（运行）$ gulp

（运行并监听）$ gulp --watch

**3.** 编译工具（ **babel, webpack** ）

babel–js编译器，把ES6代码编译成ES5代码。

webpack–处理模块化，项目依赖的，import实现。

webpack-stream—webpack对gulp对支持

**4.** 代码实现

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