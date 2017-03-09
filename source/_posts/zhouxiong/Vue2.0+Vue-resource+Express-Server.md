title: Vue2.0+Vue-resource+Express搭建简书网站服务端
date: 2017-03-02
categories: zhouxiong
tags:
- Vue2.0
- Vue-resource
- Express
---
### 前言
继上一篇文章[Vue2.0+Vue-router2.0+Vuex2.0搭建简书](http://xgfe.github.io/2016/12/22/zhouxiong/Vue2.0+Vue-router2.0+Vuex2.0/)，该文章主要讲述简书网站的前端搭建过程。本篇文章将重点讲述简书网站的服务端搭建，服务端主要通过Express启动一个本地server处理请求，将数据保存至数据库中。

<!--more-->

**注意：本篇文章只介绍了比较重要的几个文件的内容，有些文件内容类似就没有拿出来讲解。所以代码并不是全部的，所以按照本文的内容并不能完全搭建起一个网站，想要全部的代码可以从下面的github仓库中获取**

github地址：[https://github.com/zhouxiongking/vue2.0-vuex2.0-demo-jianshu](https://github.com/zhouxiongking/vue2.0-vuex2.0-demo-jianshu)

### 准备知识

- vue-resource

 vue-resouce是一款Vue.js插件，他可以通过XMLHttpRequest或JSONP发起请求并处理响应，也就是说$.ajax能做的事情，vue-resource插件也能够做到，而且vue-resource的API更为简洁。
 
- Express

 Express是基于Node.js的Web开发框架，可以快速地搭建一个完整功能的网站
 
- 数据库知识

 基本的数据库知识，包括表的创建，增删改查等操作，会编写SQL语句 

### 数据库设计

简书网站主要分为用户表和文章表，因此数据库设计如下，建表语句对应的文件为jianshu.sql

```
create table users
(
   id                   int          auto_increment    not null primary key,
   email                varchar(50)                    not null,
   nickname             varchar(15)                    not null,
   telephone            varchar(11)                    null,
   password             varchar(20)                    not null,
   attention_count      int          default 0         null,
   enjoy_count          int          default 0         null
)ENGINE=InnoDB DEFAULT CHARSET=utf8;

create table article
(
  id                   int          auto_increment    not null primary key,
  type                 varchar(10)                    null,
  topic                varchar(10)                    null,
  user_id              int                            not null,
  title                varchar(30)                    not null,
  content              longtext                       not null,
  read_count           int          default 0         null,
  comment_count        int          default 0         null,
  like_count           int          default 0         null,
  reward_count         int          default 0         null,
  publish_time         varchar(20)                    null,
  picture_url          varchar(100)                   null
)ENGINE=InnoDB DEFAULT CHARSET=utf8;

```

### 创建server

在build/dev-server.js文件中可以发现有以下代码

```
 var express = require('express');
 var app = express();
```

该代码表示利用Express启动一个server，而且通过`app.use()`方法使用了一系列的中间件，在实现对应的模块功能时会添加对应的处理。

为了方便做更好的讲解，下面将通过实际的功能模块进行描述，主要包括注册登录模块和编写文章模块以及加载文章列表模块三个部分。

### 注册与登录
首先看下登录的页面
<img src="https://p0.meituan.net/dpnewvc/40aff5f1eb64935fd76a4f98f87a81e6125260.png" alt="登录界面">

注册与登录主要是针对用户的操作，我们按照这个功能的整个流程来讲解。

- 前端页面的编写

- 利用vue-resource发送请求到后端

- 服务端接收请求，处理参数

- 处理完的数据存入数据库

- 给前端页面响应的响应结果

#### 前端页面内容

```
<form name="formLogin" class="login-form" accept-charset="UTF-8" method="post">
  <div class="username">
    <span class="span1"><i class="fa fa-user"></i></span>
    <input type="text" name="login_name" placeholder="邮件/电话号码" v-model="login.email" class="span2">
  </div>
  <div class="password">
    <span class="span1"><i class="fa fa-unlock-alt"></i></span>
    <input type="password" name="login_password" placeholder="密码" v-model="login.password" class="span2">
  </div>
  <button class="login-btn btn" type="button" @click='doLogin'><span>登录</span></button>
  <div class="login-control">
			<span class="f-l checkbox" :class="{checked: checked === true}"
        @click="checked = !checked">
				<input type="checkbox" class="remember" checked="checked">
				<ins class="check"></ins>
			</span>
    <span class="f-l">记住我</span>
    <span class="f-r"><a href="#" class="forget-color">忘记密码</a></span>
  </div>
</form>
```

#### vue-resource发送请求

```
 // 注册
doRegist () {
    this.$http.post('/user/register', this.user).then(function (response) {
        this.dealResponse(response)
    })
},
// 登陆
doLogin () {
    var url = '/user/login?email=' + this.login.email + '&password=' + this.login.password
    this.$http.get(url).then(function (response) {
        this.dealResponse(response)
    })
}
```

#### 服务端接收请求

```
// 用户注册
app.post('/user/register', function (req, res) {
    var user = req.body   //post请求中，需要通过req.body获取请求体的内容
    userDbUtil.getUserByRegister(user.email, user.nickname).then(function (response) {
        if(response[0]) {
            var respResult = {
                status: 0,
                message: '邮箱/电话/昵称已注册,请重新注册!'
            }
            appResponse(res, JSON.stringify(respResult))
        } else {
            userDbUtil.saveUser(user).then(function () {
                var respResult = {
                    status: 1,
                    message: '恭喜你,注册成功!'
                }
                appResponse(res, JSON.stringify(respResult))
            })
        }
    }, function () {
        var respResult = {
            status: 0,
            message: '注册失败!'
        }
        appResponse(res, JSON.stringify(respResult))
    })
})

// 登陆
app.get('/user/login', function (req, res) {
    var email = req.query.email    //get请求中，通过req.query属性获取传递的参数
    var password = req.query.password
    userDbUtil.getUserByLogin(email, password).then(function (response) {
        var respResult
        if(response.length) {
            // 登录信息写入session
            req.session.isLogin = true;
            req.session.user = response[0];
            respResult = {
                status: 1,
                message: '登录成功!'
            }
        } else {
            respResult = {
                status: 0,
                message: '用户名或密码错误,登录失败!'
            }
        }
        appResponse(res, JSON.stringify(respResult))
    }, function () {
        var respResult = {
            status: 0,
            message: '用户名或密码错误,登录失败!'
        }
        appResponse(res, JSON.stringify(respResult))
    })
})
```

在用户登录的时候会利用session记录登录信息，所以在Express中需要引入`express-session`模块，在build/dev-server.js文件中需要添加如下代码

```
// 引入session模块,判断登录情况
var session = require('express-session')
app.use(session({
  secret: 'kingx_only',
  cookie: {maxAge: 20 * 60 * 1000}
}))
```

#### 数据库操作

- 数据库的连接

数据库的连接是通用的操作，所以将其封装在一个文件dbUtil/dbConnection.js中，各个模块需要使用数据库的操作时只需要require该文件即可。

```
var mysql = require('mysql')

// 以下的数据库名称，用户名和密码大家自行更改
var options = {
    host: 'localhost',
    port: 3306,
    user: 'root',
    password: 'XXX',
    database: 'jianshu'
}

var connection = mysql.createConnection(options)

module.exports = connection
```

- 数据库操作

在将数据保存至数据库中时，利用Promise实现

```
// 保存用户
userDbUtil.saveUser = function (user) {
    var promise = new Promise(function (resolve, reject) {
        var sql = 'insert into users(email, nickname, password) values(?, ?, ?)'
        var params = [user.email, user.nickname, user.password]

        connection.connect(function(){
            connection.query(sql, params, function (error, response) {
                if(error){
                    reject(error)
                } else {
                    resolve(response)
                }
            })
        })
    })
    return promise
}

// 注册时,查找用户
userDbUtil.getUserByRegister = function (email, nickname) {
    var promise = new Promise(function (resolve, reject) {
        var sql = 'select * from users where email = ? or nickname = ?'
        var params = [email, nickname]
        connection.connect(function () {
            connection.query(sql, params, function (error, response) {
                if(error) {
                    reject(error)
                } else {
                    resolve(response)
                }
            })
        })
    })
    return promise
}
```

- 处理响应

在前端页面文件中，将处理响应的函数封装成一个公共的函数

```
// 处理响应
dealResponse (response) {
    var self = this
    self.show_result = true
    var resData = JSON.parse(response.body)
    this.result = resData.message
    if (resData.status) {
        setTimeout(function () {
            self.show_result = false
            // 注册成功后,直接自动登录到主页
            self.$router.push('/home/article/hot')
            self.$store.dispatch('changeIsLogin', true)
        }, 1000)
    } else {
        setTimeout(function () {
            self.show_result = false
        }, 1000)
    }
}
```

通过以上5步，就可以完成用户注册或者登陆的操作，当然上述代码并不是全部的代码，只是一些必要的函数，如果需要整体运行，还需要在本地建立好数据库，然后运行整个系统


### 写文章

在完成用户的注册和登录功能后，写文章应该是简书最重要的功能了，同样我们按照上述5个步骤来实现这个功能。首先来看下写文章的界面如下
<img src="https://p1.meituan.net/dpnewvc/c37d4ffb5dfd48d02965834c22bf086d99843.png" />

#### 前端页面内容

为了能写出更好看的文章，也是费了一段功夫去找支持vue的富文本编辑器，虽然现在的vue富文本编辑器已经有很多了，但是也会有各种各样的问题，比如使用复杂度上，或者字体上，最终选取了[vue-quill-editor](https://github.com/surmon-china/vue-quill-editor)作为简书的文本编辑器。

```
<div class="note-editor">
  <div class="wrapper-head">
    <div class="note-head">
      <input type="text" class="top-title" data-type="title" v-model="note.title">
    </div>
  </div>
  <div class="wrapper-body">

    <quill-editor ref="myTextEditor"
                  v-model="note.content"
                  :config="editorOption"
                  @blur="onEditorBlur($event)"
                  @focus="onEditorFocus($event)"
                  @ready="onEditorReady($event)"></quill-editor>
  </div>
  <div class="wrapper-footer">
    <div class="footer-div">
      <button class="btn" @click="saveArticle">保存</button>
    </div>
  </div>
</div>
```

#### Vue-resource发送请求

```
// 保存文章
saveArticle () {
    this.$http.post('/article/saveArticle', this.note).then(function (response) {
    	
    })
}
```

#### 服务端处理请求

在使用`vue-quill-editor`富文本编辑器编写文章的时候，如果遇到添加图片的情况，`vue-quill-editor`会将图片转化为base64格式的编码，由于base64格式编码的数据量会很大，这样在发送请求时Express会报错。因此需要对Express的body-parser模块进行设置。在build/dev-server.js文件下，添加如下代码

```
// 需要使用body-parser模块,要不然post方法获取不到传递的参数
var bodyParser = require('body-parser')
// 设置接收参数的大小,主要针对于base64的图片
app.use(bodyParser({limit: '50mb'}))
app.use(bodyParser.json())
app.use(bodyParser.urlencoded({extended: false}))

```

实际处理文章的服务端代码如下：

```
// 保存文章
app.post('/article/saveArticle', function (req, res) {
    var article = req.body
    // 获取用户id
    article.userId = req.session.user.id
    // 获取当前时间
    article.publishTime = new Date().format('yyyy-MM-dd hh:mm:ss')
    articleDbUtil.saveArticle(article).then(function (response) {
        var resultObj = {
            status: 1,
            message: '保存成功',
            articleId: response[0].id
        }
        appResponse(res, JSON.stringify(resultObj))
    }, function () {
        var resultObj = {
            status: 0,
            message: '保存失败'
        }
        appResponse(res, JSON.stringify(resultObj))
    })
})
```

#### 数据库操作

由于数据库连接采用相同的配置，此处省略数据库连接的代码。

由于图片会被编码成base64格式的数据，考虑到content字段的数据量会比较大，在设计content字段时采用的是longtext类型。

根据实际的业务逻辑，在写完一篇文章后会直接展示该篇文章，所以在将一篇文章保存后会获取该文章的id返回给客户端，因此以下代码中使用了Promise链的写法

```
// 保存文章
articleDbUtil.saveArticle = function (article) {
    var promise = new Promise(function (resolve, reject) {
        connection.connect(function () {
            var sql = 'insert into article(user_id, title, content, publish_time) values(?, ?, ?, ?)'
            var params = [article.userId, article.title, article.content, article.publishTime]
            connection.query(sql, params, function (error, response) {
                if(error) {
                    reject(error)
                } else {
                    resolve(response)
                }
            })
        })
    })
    var newPromise = promise.then(function () {
        return new Promise(function (resolve, reject) {
            connection.connect(function () {
                var sql = 'select id from article where user_id = ? and title = ? and publish_time = ?'
                var params = [article.userId, article.title, article.publishTime]
                connection.query(sql, params, function (error, response) {
                    if (error) {
                        reject(error)
                    } else {
                        resolve(response)
                    }
                })
            })
        })
    })

    return newPromise
}

```

#### 处理响应

在保存完文章后，会根据返回的文章id，再跳转到文章展示的页面，所以会用`_self.$router.push('/article/' + resData.articleId)`进行路由跳转

```
// 保存文章
saveArticle () {
    this.$http.post('/article/saveArticle', this.note).then(function (response) {
        var resData = JSON.parse(response.body)
        if (resData.status) {
            var _self = this
            _self.resMsg = '恭喜你!发表成功'
            _self.show_result = true
            setTimeout(function () {
                _self.$router.push('/article/' + resData.articleId)
            }, 1000)
        } else {
            this.show_result = true
            this.resMsg = '发表失败'
        }
    })
}
```

### 文章列表

在写完文章后，会在主页上显示出已经写的文章列表，如下图显示
<img src="https://p0.meituan.net/dpnewvc/16943ad2e51e5b7f9b8cd159c5cb9dbd1472821.png"/>

#### 前端页面内容

```
<template>
    <div>
        <ul>
            <li class="list" v-for="article in articles">
                <p class="list-top">
                    <a href="#" class="author">
                        <span>{{article.nickname}}</span>
                    </a>
                    <span class="time">
                        - {{article.publish_time}}
                    </span>
                </p>
                <h2 class="title">
                    <router-link :to="{path: '/article/' + article.id}">{{article.title}}</router-link>
                </h2>
                <span class="small-text">阅读 {{article.read_count}}</span>
                <span class="small-text">评论 {{article.comment_count}}</span>
                <span class="small-text">喜欢 {{article.like_count}}</span>
                <span class="small-text">打赏 {{article.reward_count}}</span>
                <span class="image"
                      :style="{'background': 'url(' + (article.picture_url || defaultUrl) + ')', backgroundSize: '100%', backgroundRepeat: 'no-repeat' }"></span>
            </li>
        </ul>
    </div>
</template>

```

#### 加载文章列表

在刚进入主页的时候会在主页Home.vue文件中发送请求，加载出文章列表

```
methods: {
    displayArticles (type) {
        // 发送请求,找出对应类型的文章
        var url = '/article/list?type=' + type
        this.$http.get(url).then(function (response) {
            
        })
    }
}
```

#### 服务端请求

在app-article-server.js文件中，包含了加载文件列表的内容

```
// 加载文章列表
app.get('/article/list', function (req, res) {
    var type = req.query.type
    articleDbUtil.loadArticleByType(type).then(function (response) {
        if(response.length) {
            var resultObj = {
                status: 1,
                message: '加载成功',
                articleList: response
            }
            appResponse(res, JSON.stringify(resultObj))
        }
    }, function () {
        var resultObj = {
            status: 0,
            message: '加载失败'
        }
        appResponse(resultObj)
    })
})
```

#### 数据库操作

在articleDbUtil.js文件中，包含了从数据库加载出文章列表的内容

```
// 加载某类型的文章
articleDbUtil.loadArticleByType = function (type) {
    var promise = new Promise(function (resolve, reject) {
        connection.connect(function () {
            var sql = 'select a.*, u.nickname from article as a, users as u where a.user_id = u.id'
            var params = []
            connection.query(sql, function (error, response) {
                if (error) {
                    reject(error)
                } else {
                    resolve(response)
                }
            })
        })
    })
    return promise
}
```

#### 处理响应

在将文章列表返回给浏览器端后，会直接将数据写到Vuex的store中，在ArticleList.vue文件中直接从store中读取即可。

```
displayArticles (type) {
    // 发送请求,找出对应类型的文章
    var url = '/article/list?type=' + type
    this.$http.get(url).then(function (response) {
        var resData = JSON.parse(response.body)
        if (resData.status) {
            var articleList = resData.articleList
            var payload = {
                type: type,
                articleList: articleList
            }
            this.$store.dispatch('displayArticles', payload)
        }
    })
}
```

至此关于注册登录和写文章以及加载文章列表的功能就已经完成了，这基本上是简书网站的最主要功能了，后续的例如专题的功能可以按照以上的5个步骤来完成，当然如果你们能想到哪些更有趣的功能，都可以自己添加到网站上。

通过两篇文章，基本涵盖了利用Vue全家桶+Express+Webpack搭建简书的全过程，包括前端、后台、数据库操作等等，希望能给大家带来帮助，也希望大家能提些意见。

### 参考资料

- [Express框架](http://javascript.ruanyifeng.com/nodejs/express.html#toc0)
- [Vue-resource全攻略](http://www.cnblogs.com/keepfool/p/5657065.html)
- [Vue富文本编辑器vue-quill-editor](https://github.com/surmon-china/vue-quill-editor)
- [Mysql基本操作](http://blog.csdn.net/xycit/article/details/5854694)