title: Egg.js 体验
date: 2018-05-26 15:00:00
categories: guanxiaofeng
tags:
    - nodejs
    - Eggjs
---

## Egg.js 是什么?
﻿Egg.js是一个强约束的Node框架，这也是和Express/Koa最大的不同，后者对开发者相对宽松，主要体现在目录结构，编写方式等均可以自定义，标准的mvc模式有千奇百怪的写法。

 Egg.js 奉行『约定优于配置』，他规定一定的约定，让开发者都按照统一的约定去开发，降低团队协作成本，减少差异，求同存异，提升项目阅读和维护性。但约定不等于扩展性差，相反 Egg.js 有很高的扩展性。

### ﻿特性
    * 提供基于 Egg 定制上层框架的能力
    * 高度可扩展的插件机制
    * 内置多进程管理
    * 基于 Koa 开发，性能优异
    * 框架稳定，测试覆盖率高
    * 渐进式开发

## 快速开始
官方推荐使用脚手架快速生成项目：

    $ npm install egg-init -g
    $ egg-init egg-test --type=simple
    $ cd egg-test
    $ npm install
    $ npm run dev
    $ open localhost:7001

Egg.js给我们规定的目录结构如下图：

     ﻿egg-project
     ├── package.json
     ├── app.js (可选)
     ├── agent.js (可选)
     ├── app
     |   ├── router.js
     │   ├── controller
     │   |   └── home.js
     │   ├── service (可选)
     │   |   └── user.js
     │   ├── middleware (可选)
     │   |   └── response_time.js
     │   ├── schedule (可选)
     │   |   └── my_task.js
     │   ├── public (可选)
     │   |   └── reset.css
     │   ├── view (可选)
     │   |   └── home.tpl
     │   └── extend (可选)
     │       ├── helper.js (可选)
     │       ├── request.js (可选)
     │       ├── response.js (可选)
     │       ├── context.js (可选)
     │       ├── application.js (可选)
     │       └── agent.js (可选)
     ├── config
     |   ├── plugin.js
     |   ├── config.default.js
     │   ├── config.prod.js
     |   ├── config.test.js (可选)
     |   ├── config.local.js (可选)
     |   └── config.unittest.js (可选)
     └── test
         ├── middleware
         |   └── response_time.test.js
         └── controller
             └── home.test.js

﻿其中包括controller，router，config等等；﻿然后我们需要先添加一个渲染模版，
Eggjs提供了很多view模版，这里选择Egg-view-ejs 为例,安装完插件后需要在config里面开启插件,
同时需要在app文件夹下新建view文件夹，放置页面文件。

配置需要用的插件，在config/plugin.js中添加

    ﻿exports.ejs = {
        enable: true,
        package: 'egg-view-ejs'
    };
    // 使用mysql插件
    exports.mysql = {
        enable: true,
        package: 'egg-mysql',
    };

开启插件，config.default.js中增加

    ﻿config.view = {
        defaultViewEngine: 'ejs',
        mapping: {
            '.html': 'ejs',
        }，
    };
    // 设置mysql
    config.mysql = {
        clients: {
            // clientId, 获取client实例，需要通过 app.mysql.get('clientId') 获取
            db: {
                ...
            }
        },
        // 是否加载到 app 上，默认开启
        app: true,
    };

﻿其中defaultViewEngine表示使用的模版，当然也可以使多种模版。mapping设置的属性名表示view中文件的扩展名，属性值表示对应的模板。

﻿接下来就可以编写controller和router了。

定义controller，﻿在controller文件夹下的home.js中：

    ﻿const Controller = require('egg').Controller;

    // eggjs 推荐使用类形式来定义
    class HomeController extends Controller {
      async index() {
          await this.ctx.render('site/home.html');
      }
    }
    module.exports = HomeController;

定义路router，在router.js文件中：

    ﻿module.exports = app => {
        const { router, controller } = app;

        router.get('/', controller.home.index);
        router.get('/login', controller.login.index);
    };

﻿Context 对象上提供了 3 个渲染模版的接口，返回值均为 Promise:

    ﻿// render：渲染模版文件，data为传入模版的数据，并赋值给ctx.body
    await ctx.render('home/index.tpl', data);
    // renderView：渲染模版文件，data为传入模版的数据，需要主动赋值
    ctx.body = await ctx.renderView('path/to/file.tpl', data);
    // renderString：渲染模版字符串，data为传入模版的数据，需要主动赋值，
    ctx.body = await ctx.renderString('hi, {{ name }}', data, {
        // 需要指定模板引擎
        viewEngine: 'nunjucks',
    });

## 内置基础对象扩展

框架包括从 Koa 继承而来的 4 个对象（Application, Context, Request, Response)
以及框架扩展的一些对象（Controller, Service, Helper, Config, Logger）。

### Application扩展

app 对象指的是 Koa 的全局应用对象，全局只有一个，在应用启动时被创建。在Controller，Middleware，Helper，Service 中都可以通过
this.app 访问到 Application 对象。框架会把 app/extend/application.js 中定义的对象与 Koa Application 的 prototype 对象进行合并，在应用启动时会基于扩展后的 prototype 生成 app 对象。这样能在其他地方使用Application中扩展的方法。

    ﻿// app/extend/application.js
    module.exports = {
      foo(params) {
        // this 就是 app 对象，在其中可以调用 app 上的其他方法，或访问属性
      },
    };

### ﻿Context扩展

Context 指的是 Koa 的请求上下文，这是请求级别的对象，每次请求生成一个 Context 实例，通常我们也简写成 ctx。在所有的文档中，Context 和 ctx 都是指 Koa 的上下文对象。如下做的是对数据返回的扩展：

    ﻿// app/extend/context.js
    module.exports = {
      returnJson(code,data,msg) {
        // this 就是 ctx 对象，在其中可以调用 ctx 上的其他方法，或访问属性
        this.body={code,data,msg};
        return
      }
    };
    在controller中就可以直接使用这个方法了
    async info() {
        const userId = this.ctx.query.id;
        const res = await this.ctx.service.getInfo(userId);
        this.ctx.returnJson(0, res, "请求成功");
    }

### ﻿Request和Response扩展

 ﻿ctx 上的很多属性和方法都被代理到 request和response 对象上，对于这些属性和方法使用 ctx 和使用 request 去访问它们是等价的，例如 ctx.url === ctx.request.url，ctx.status === ctx.response.status 。
 框架会把 app/extend/request.js 中定义的对象与内置 request 的 prototype 对象进行合并，在处理请求时会基于扩展后的 prototype 生成 request 对象；Response的扩展和Request相同。

    ﻿// app/extend/request.js
    module.exports = {
      get foo() {
        return this.get('request-foo');
      },
    };
    // app/extend/response.js
    module.exports = {
      set bar(value) {
        this.set('response-bar', value);
      },
    };

### ﻿Helper扩展
﻿Helper 函数用来提供一些常用的方法或自定义的方法，可以将项目中用的多的函数封装在成对的函数，并且Helper对象可以在ctx对象里面访问到。

    ﻿// app/extend/helper.js
    module.exports = {
      foo(param) {
        // this 是 helper 对象，在其中可以调用其他 helper 方法
        // this.ctx => context 对象
        // this.app => application 对象
      },
    };

## ﻿service 服务层

﻿service 就是在复杂业务场景下用于做业务逻辑封装的一个抽象层,比如要展现的信息需要从数据库获取，还要经过一定的规则计算，才能返回用户显示。可以将数据逻辑的处理都放在service中

    ﻿const Service = require('egg').Service;

    class UserService extends Service {
      async find(uid) {
        const user = await app.mysql.get('db').query(`select * from user where uid = ${uid}`);
        return user;
      }
    }
    module.exports = UserService;

## ﻿Middleware 中间件

﻿Egg 的中间件形式和 Koa 的中间件形式是一样的，都是基于洋葱圈模型。约定中间件是一个放置在 app/middleware 目录下的单独文件，它需要 exports 一个普通的 function，接受两个参数：

    options: 中间件的配置项，框架会将 app.config[${middlewareName}] 传递进来。
    app: 当前应用 Application 的实例。

﻿定义一个中间件：

    ﻿module.exports = (options,app) => {
        return async function checkLogin() {
            if(!(this.session && this.session.userid)){
                this.redirect('/login');
                return;
            };
            // 刷新session时间
            this.session.save();
        };
    }

﻿在应用中，我们可以完全通过配置来加载自定义的中间件，并决定它们的顺序。配置最终将在启动时合并到 app.config.appMiddleware中。在config.default.js中配置如下：

    ﻿// 配置需要的中间件，数组顺序即为中间件的加载顺序
    config.middleware= ['checkLogin'];

    // 配置 checkLogin 中间件的配置
    config.checkLogin= {
        // 设置需要忽略检查的路径
        ignore: '/login'
    };

 ﻿利用上述定义的中间件，如下是做的一个简单的登录

    ﻿// router.js
    module.exports = app => {
        const { router, controller } = app;

        router.get('/login', controller.login.index);
        router.post('/login/vaild', controller.login.valid);
        // 登陆后获取用户名
        router.get('/user/admin', controller.login.userinfo);
        // 退出登录
        router.get('/logout', controller.login.logout);
    }
    // app/controller/login.js
    module.exports = app => {
        class LoginController extends app.Controller {

            async index() {
                    await this.ctx.render('site/login.html');
            }

            async valid() {
                const name = this.ctx.request.body.username;
                const pwd = this.ctx.request.body.password;
                if (!name || !pwd) {
                    //1表示没有填写
                    this.ctx.returnJson(1,'',"请填写帐号和密码。")
                    return;
                }
                const user = await app.mysql.get('db').query(`select id,username  from user WHERE username= '${name}' AND password ='${pwd}'`);
                if (user.length != 0) {
                    //登录成功，下发session
                    this.ctx.session.username = user[0].username;
                    this.ctx.session.userid = user[0].id;
                    // 设置过期时间为3小时
                    this.ctx.session.maxAge = 3 * 3600 * 1000;
                    // 调用 rotateCsrfSecret 刷新用户的 CSRF token
                    this.ctx.rotateCsrfSecret();
                    this.ctx.returnJson(0, '', "登录成功");
                } else {
                    this.ctx.returnJson(2,'',"帐号或密码错误");
                };
            }

            async userinfo() {
                const uid = this.ctx.query.uid;
                let user = await this.ctx.service.UserService.find(uid)
                this.ctx.returnJson(0,user ,"操作成功");
            }

            async logout() {
                this.ctx.session = null;
                this.ctx.redirect('/login');
            }
        }
        return LoginController;
    };

在这里面遇到一个坑就是通过get请求和post请求时，获取参数的方式不一样。

    * 在get请求中要通过this.ctx.query去获取参数；在post请求中是通过this.ctx.request.body去获取参数。


﻿这些只是Eggjs的一小部分内容，框架还有很多扩展，插件，进程管理等等，接下来会通过自己的学习慢慢总结，有不对的地方还希望各位前辈指出。