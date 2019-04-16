<<<<<<< HEAD
title: koa-router源码解读
=======
title: koa-router 源码解读
>>>>>>> 70f0ef78fcbc4ef41773f4ff1ac4dacf2a74dfdb
date: 2018-09-27 19:18:00
categories: zuopengfei
tags: 
- node
- koa
- koa-router
---

<<<<<<< HEAD
本文通过阅读koa-router的源码归纳了koa-router涉及到的router和layer两个对象的关系；以及梳理了koa-router处理请求的整体流程。
=======
本文通过阅读 koa-router 的源码归纳了 koa-router 涉及到的 router 和 layer 两个对象的关系；以及梳理了 koa-router 处理请求的整体流程。
>>>>>>> 70f0ef78fcbc4ef41773f4ff1ac4dacf2a74dfdb


<!-- more -->


## 背景

如果实现一个简单的路由，可以解析`node`原生`request即IncomingMessage`对象的`url`属性，用 `if...else`判断路径从而返回不同的结果；当然也可以利用`koa`的`request`对象和`response`对象来处理。下面就是用`koa`实现的简单路由：

```javascript

const Koa = require('koa');
const fs = require('fs');
const app = new Koa();

function render(page){
   
    return new Promise((resolve,reject) => {
        let pageUrl = `./page/${page}`;
        fs.readFile(pageUrl, "binary", (err,data) => {
            console.log(444);
            if (err) {
                reject(err)
            } else {
                resolve(data);
            }
        })
    })
    
}

async function route(url){
    
    let page = '404.html';
    switch(url){
        case '/':
            page ='index.html';
            break;
        case '/index':
            page ='index.html';
            break;
        case '/todo':
            page = 'todo.html';
            break;
        case '/404':
            page = '404.html';
            break;
        default:
            break; 
    }
    let html = await render(page);
    
    return html;
}

app.use(async(ctx)=>{
    let url = ctx.request.url;
    let html = await route(url);
    
    ctx.body = html;
})
app.listen(3000);
console.log('starting at 3000');

```

缺点

+ 路由越多消耗的性能也就越大
+ 不能对特殊路由添加中间件
+ 也没有处理响应头类型

更好的方法是使用面向对象的方式，根据请求的`path`和`method`执行相应的中间件处理函数；而在实际开发中我们常用的是`koa`路由库[koa-router](https://github.com/alexmingoia/koa-router)。本文通过解析`koa-router`的源码来达到深入学习其原理的目的。

## kao-router的简单使用demo

使用`koa-router`第一步就是新建一个`router`实例对象:

```javascript

const Koa = require('koa');
const KoaRouter = require('koa-router');
const pagePromptRouter require('./controllers/pagePrompt');

const app = new Koa();
// 创建router实例对象
const router = new KoaRouter();

// 嵌套路由
router.use('/admin/prompt', pagePromptRouter.routes(), pagePrompt.allowedMethods());

// 添加路由中间件
app.use(router.routes()); 
// 对请求进行一些限制处理
app.use(router.allowedMethods()); 

app.listen(3000);

```


构建应用的时候，我们的首要目标就是创建多个`CGI`接口以适配不同的业务需求，那么接下来就需要注册对应的路由：

```javascript

const KoaRouter = require('koa-router');

let router = new Router();

router.get('/queryPagePromptList', queryPagePromptList);
router.post('/deletePagePromptById', deletePagePromptById);
router.post('/savePagePrompt', savePagePrompt);

async function queryPagePromptList(ctx, next) {
	let result = await getResult();
	ctx.body = {
	    data: result.data,
	    code: 200
    };
	await next();
}


```

然后为了让`koa`实例使用我们配置后的路由模块，需要使用`routes()`方法将路由(上面的例子中为了代码分层使用了嵌套路由)加入到应用全局的中间件函数中：


``` javaScript
app.use(router.routes());  // 添加路由中间件
app.use(router.allowedMethods()); // 对请求进行一些限制处理

```

## 源码结构


[router.js](https://github.com/alexmingoia/koa-router/blob/master/lib/router.js)

![router](http://vfile.meituan.net/xgfe/88ed43b2f2951c77384f10d7ff4e1a6a172778.png)

[layer.js](https://github.com/alexmingoia/koa-router/blob/master/lib/layer.js)

![layer](http://vfile.meituan.net/xgfe/190cd799e93c05d43fd05b1bda3574ad116451.png)


router和layer的关系

![router-layer](http://p0.meituan.net/xgfe/b736ea9f7cc83ba0f0aeaf22782185ff20689.png)


## 源码解析

<<<<<<< HEAD
### Router构造函数
=======
### Router 构造函数
>>>>>>> 70f0ef78fcbc4ef41773f4ff1ac4dacf2a74dfdb

`Node`本身提供了数十个`HTTP`请求动词，`koa-router`只是实现了部分常用的：

```
function Router(opts) {
  if (!(this instanceof Router)) {
    return new Router(opts);
  }

  this.opts = opts || {};
  this.methods = this.opts.methods || [
    'HEAD',
    'OPTIONS',
    'GET',
    'PUT',
    'PATCH',
    'POST',
    'DELETE'
  ];
  //省略
};
```

### router.(get|post|delete|all...)()

这些请求动词的实现是通过第三方模块[methods](https://github.com/jshttp/methods)支持的，然后`koa-router`内部进行了注册处理：

```
// 这里的methods就是上面的methods模块提供的数组
methods.forEach(function (method) {
  Router.prototype[method] = function (name, path, middleware) {
    var middleware;

    // 这段代码做了两件事：
    // 1.name 参数是可选的，所以要做一些参数置换的处理
    // 2.将所有路由中间件（因为可以注册多个中间件）合并成一个数组
    if (typeof path === 'string' || path instanceof RegExp) {
      middleware = Array.prototype.slice.call(arguments, 2);
    } else {
      middleware = Array.prototype.slice.call(arguments, 1);
      path = name;
      name = null;
    }

    // 调用register方法
    this.register(path, [method], middleware, {
      name: name
    });

    return this;
  };
});
```

上面函数先判断`path`是否是字符串或者正则表达式，是因为注册路由的时候还可以为路由进行命名(命名空间方便管理)，然后准确地获取回调的函数数组(注册路由可以接收多个回调)， 这样如果匹配到某个路由，回调函数数组中的函数就会依次执行。留意到每个方法都会返回对象本身，也就是说注册路由的时候是可以支持链式调用的。

### register方法

`this.register`接受请求路径、方法、中间件作为参数，返回已经注册的路由：

```
Router.prototype.register = function (path, methods, middleware, opts) {
  opts = opts || {};
  var router = this;

  // 全部路由
  var stack = this.stack;

  // 说明路由的path是支持数组的
  // 如果是数组的话，需要递归调用register来注册路由，因为一个path对应一个路由
  if (Array.isArray(path)) {
    path.forEach(function (p) {
      router.register.call(router, p, methods, middleware, opts);
    });
    return this;
  }

  // 创建路由，路由就是Layer的实例
  // methods是路由处理的http方法
  // 最后一个参数对象最终是传给Layer模块中的path-to-regexp模块接口调用的
  var route = new Layer(path, methods, middleware, {
    end: opts.end === false ? opts.end : true,
    name: opts.name,
    sensitive: opts.sensitive || this.opts.sensitive || false,
    strict: opts.strict || this.opts.strict || false,
    prefix: opts.prefix || this.opts.prefix || "",
    ignoreCaptures: opts.ignoreCaptures
  });

  // 处理路径前缀
  if (this.opts.prefix) {
    route.setPrefix(this.opts.prefix);
  }

  // 将全局的路由参数添加到每个路由中
  Object.keys(this.params).forEach(function (param) {
    route.param(param, this.params[param]);
  }, this);

  // 往路由数组中添加新创建的路由
  stack.push(route);

  return route;
};
```

根据上面的逻辑我们应该知道

```
router.get('/test', async (ctx, next) => {});
```
其实它相当于下面这段代码:

```
router.register('/test', ['GET'], [async (ctx, next) => {}], { name: null });

```

`register`函数将路由作为第一个参数传入，然后方法名放入到方法数组中作为第二个参数， 第三个函数是路由的回调数组；其实每个路由注册的时候，后面都可以添加很多个函数，而这些函数都会被添加到一个数组里面，如果被匹配到，就会利用中间件机制来逐个执行这些函数。最后一个参数是将路由的命名空间传入。

对于`stack`数组，则是存储每一个路由，也就是`Layer`的实例对象，每一个路由都相当于一个`Layer`实例对象。

对于`Layer`类来说, 创建一个实例对象用于管理每个路由:

```
function Layer(path, methods, middleware, opts) {
  this.opts = opts || {};
  // 路由命名
  this.name = this.opts.name || null;
  // 路由对应的方法
  this.methods = [];
  // 路由参数名数组
  this.paramNames = [];
  // 路由处理中间件数组
  this.stack = Array.isArray(middleware) ? middleware : [middleware];
  // 存储路由方法
  methods.forEach(function(method) {
    var l = this.methods.push(method.toUpperCase());
    if (this.methods[l-1] === 'GET') {
      this.methods.unshift('HEAD');
    }
  }, this);

  // 将添加的回调处理中间件函数添加到Layer实例对象的 stack 数组中
  this.stack.forEach(function(fn) {
    var type = (typeof fn);
    if (type !== 'function') {
      throw new Error(
        methods.toString() + " `" + (this.opts.name || path) +"`: `middleware` "
        + "must be a function, not `" + type + "`"
      );
    }
  }, this);

  this.path = path;
  this.regexp = pathToRegExp(path, this.paramNames, this.opts);

  debug('defined route %s %s', this.methods, this.opts.prefix + this.path);
};

```

我们可以看到, 对于`Layer`的实例对象, 核心的逻辑还是在于将`path`转化为正则表达式用于匹配请求的路由,  然后将路由的处理中间件添加到`Layer`的`stack`数组中。 注意这里的`stack`和`Router`里面的`stack`是不一样的, `Router`的`stack`数组是存放每个路由对应的`Layer`实例对象的, 而 `Layer`实例对象里面的`stack`数组是存储每个路由的处理函数中间件的, 换言之, 一个路由可以添加多个处理函数。

下面的图详细描述了`Router`和`Layer`的关系：

![Router和Layer的关系](https://vfile.meituan.net/xgfe/baf7698bb56fa67e38d3c84ad2121a0725705.png)



### router.routes()

`app.use(router.routes())`就这样，`koa-router`就启动了，所以大家也一定会很好奇这个`routes`函数到底做了什么，但可以肯定的是`router.routes()`返回了一个中间件函数。

```
Router.prototype.routes = Router.prototype.middleware = function () {
  var router = this;
  var dispatch = function dispatch(ctx, next) {
    ...
  }
  dispatch.router = this;
  return dispatch;
};

```
<<<<<<< HEAD
这里形成了一个闭包，在routes函数内部返回了一个dispatch函数作为中间件。 

接下来看下dispatch函数的实现：
=======
这里形成了一个闭包，在`routes`函数内部返回了一个`dispatch`函数作为中间件。 

接下来看下`dispatch`函数的实现：
>>>>>>> 70f0ef78fcbc4ef41773f4ff1ac4dacf2a74dfdb

```
var dispatch = function dispatch(ctx, next) {

    var path = router.opts.routerPath || ctx.routerPath || ctx.path;

    // router.match函数内部遍历所有路由（this.stack),
    // 根据路径和请求方法找到对应的路由
    // 返回的matched对象为： 
    /* 
      var matched = {
        path: [], // 保存了path匹配的路由数组
        pathAndMethod: [], // 保存了path和methods都匹配的路由数组
        route: false // 是否有对应的路由
      };
    */
    var matched = router.match(path, ctx.method);
    var layerChain, layer, i;
    if (ctx.matched) {
      ctx.matched.push.apply(ctx.matched, matched.path);
    } else {
      ctx.matched = matched.path;
    }

    // 如果没有对应的路由，则直接进入下一个中间件
    if (!matched.route) return next();

    // 找到正确的路由的path
    var mostSpecificPath = matched.pathAndMethod[matched.pathAndMethod.length - 1].path;
    ctx._matchedRoute = mostSpecificPath;

    // 使用reduce方法将路由的所有中间件形成一条链
    // 构建路径对应路由的处理中间件函数数组
    // 这里的目的是在每个匹配的路由对应的中间件处理函数数组前添加一个用于处理
    // 对应路由的 captures, params, 以及路由命名的函数
    layerChain = matched.pathAndMethod.reduce(function(memo, layer) {

      // 在每个路由的中间件执行之前，根据参数不同，设置 ctx.captures 和 ctx.params
      // 这就是为什么我们可以直接在中间件函数中直接使用 ctx.params 来读取路由参数信息了
      memo.push(function(ctx, next) {

       // captures是存储路由中参数的值的数组
        ctx.captures = layer.captures(path, ctx.captures);

        // params是一个对象, 键为参数名, 根据参数名可以获取路由中的参数值, 值从captures中拿
        ctx.params = layer.params(path, ctx.captures, ctx.params);

        // 执行下一个中间件
        return next();
      });

      // 将上面另外加的中间件和已有的路由中间件合并到一起
      // 所以最终 layerChain 将会是一个中间件的数组
      return memo.concat(layer.stack);
    }, []);

    // 最后调用上面提到的compose模块提供的方法，返回将layerChain(中间件的数组) 
    // 顺序执行所有中间件的执行函数， 并立即执行。
    return compose(layerChain)(ctx, next);
  };

```

### router.allowedMethod()

对于`allowedMethod`方法来说, 它的作用就是用于处理请求的错误, 所以它作为路由模块的最后一个函数来执行。同样地, 它也是以一个`koa`的中间件插件函数的形式出现, 同样在函数内部形成了一个闭包:

```
Router.prototype.allowedMethods = function (options) {
  options = options || {};
  var implemented = this.methods;

  return function allowedMethods(ctx, next) {
    ...
  };
};
```

<<<<<<< HEAD
上面的代码很简单, 就是保存Router配置中允许的HTTP方法数组在闭包内部
=======
上面的代码很简单, 就是保存`Router`配置中允许的`HTTP`方法数组在闭包内部
>>>>>>> 70f0ef78fcbc4ef41773f4ff1ac4dacf2a74dfdb

```
return function allowedMethods(ctx, next) {
    // 从这里可以看出, allowedMethods函数是用于在中间件机制中处理返回结果的函数
    // 先执行next函数, next函数返回的是一个Promise对象
    return next().then(function() {
      var allowed = {};
      // allowedMethods函数的逻辑建立在statusCode没有设置或者值为404的时候
      if (!ctx.status || ctx.status === 404) {
        // 这里的matched就是在match函数执行之后返回结果集中的 path 数组
        // 也就是说请求路径与路由正则匹配的 layer 实例对象数组
        ctx.matched.forEach(function (route) {
          // 将这些layer路由的HTTP方法存储起来
          route.methods.forEach(function (method) {
            allowed[method] = method;
          });
        });
        // 将上面的allowed整理为数组
        var allowedArr = Object.keys(allowed);
        // implemented就是Router配置中的methods数组, 也就是允许的方法
        // 这里通过~运算判断当前的请求方法是否在配置允许的方法中
        // 如果该方法不被允许
        if (!~implemented.indexOf(ctx.method)) {
          // 如果 Router 配置中配置 throw 为 true
          if (options.throw) {
            var notImplementedThrowable;
            // 如果配置中规定了throw抛出错误的函数, 那么就执行对应的函数
            if (typeof options.notImplemented === 'function') {
              notImplementedThrowable = options.notImplemented(); // set whatever the user returns from their function
            } else {
            // 如果没有则直接抛出HTTP Error
              notImplementedThrowable = new HttpError.NotImplemented();
            }
            // 抛出错误
            throw notImplementedThrowable;
          } else {
            // Router配置throw为false
            // 设置状态码为 501
            ctx.status = 501;
            // 并且设置Allow头部, 值为上面得到的允许的方法数组allowedArr
            ctx.set('Allow', allowedArr.join(', '));
          }
        } else if (allowedArr.length) {
          // 来到这里说明该请求的方法是被允许的, 那么为什么会没有状态码statusCode或者 statusCode为404呢?
          // 原因在于除却特殊情况, 我们一般在业务逻辑里面不会处理OPTIONS请求的
          // 发出这个请求一般常见就是非简单请求, 则会发出预检请求OPTIONS
          // 例如 application/json 格式的POST请求
          
          // 如果是 OPTIONS 请求, 状态码为 200, 然后设置 Allow 头部, 值为允许的方法数组 methods
          if (ctx.method === 'OPTIONS') {
            ctx.status = 200;
            ctx.body = '';
            ctx.set('Allow', allowedArr.join(', '));
          } else if (!allowed[ctx.method]) {
          // 方法被服务端允许, 但是在路径匹配的路由中没有找到对应本次请求的方法的处理函数
            // 类似上面的逻辑
            if (options.throw) {
              var notAllowedThrowable;
              if (typeof options.methodNotAllowed === 'function') {
                notAllowedThrowable = options.methodNotAllowed(); // set whatever the user returns from their function
              } else {
                notAllowedThrowable = new HttpError.MethodNotAllowed();
              }
              throw notAllowedThrowable;
            } else {
              // 这里的状态码为 405
              ctx.status = 405;
              ctx.set('Allow', allowedArr.join(', '));
            }
          }
        }
      }
    });
};
```

<<<<<<< HEAD
值得注意的是, Router.methods数组里面的方法是服务端需要实现并支持的方法, 如果客户端发送过来的请求方法不被允许, 那么这是一个服务端错误 501, 但是如果这个方法被允许, 但是找不到对应这个方法的路由处理函数(比如相同路由的POST 路由但是用GET方法来获取数据), 这是一个客户端错误405。
=======
值得注意的是, `Router.methods`数组里面的方法是服务端需要实现并支持的方法, 如果客户端发送过来的请求方法不被允许, 那么这是一个服务端错误`501`, 但是如果这个方法被允许, 但是找不到对应这个方法的路由处理函数(比如相同路由的`POST`路由但是用`GET`方法来获取数据), 这是一个客户端错误`405`。
>>>>>>> 70f0ef78fcbc4ef41773f4ff1ac4dacf2a74dfdb


### router.use()

`use`函数就是用于添加中间件的, 只不过不同于`koa`中的`use`函数, `router`的`use`函数添加的中间件函数会在所有路由执行之前执行。此外, 它还可以对某些特定路径的进行中间件函数的绑定执行.

```
router.prototype.use = function () {
  var router = this;
  // 中间件函数数组
  var middleware = Array.prototype.slice.call(arguments);
  var path;

  // 支持同时为多个路由绑定中间件函数: router.use(['/use', '/admin'], auth());
  if (Array.isArray(middleware[0]) && typeof middleware[0][0] === 'string') {
    middleware[0].forEach(function (p) {
      // 递归调用
      router.use.apply(router, [p].concat(middleware.slice(1)));
    });
    // 直接返回, 下面是非数组 path 的逻辑
    return this;
  }
  // 如果第一个参数有传值为字符串, 说明有传路径
  var hasPath = typeof middleware[0] === 'string';
  if (hasPath) {
    path = middleware.shift();
  }
    
  middleware.forEach(function (m) {
    // 如果有router属性, 说明这个中间件函数是由 Router.prototype.routes暴露出来的
    // 属于嵌套路由
    if (m.router) {
      // 这里的逻辑很有意思, 如果是嵌套路由, 相当于将需要嵌套路由重新注册到现在的 Router 对象上
      m.router.stack.forEach(function (nestedLayer) {
        // 如果有path, 那么为需要嵌套的路由加上路径前缀
        if (path) nestedLayer.setPrefix(path);
        // 如果本身的router有前缀配置, 也添加上
        if (router.opts.prefix) nestedLayer.setPrefix(router.opts.prefix);
        // 将需要嵌套的路由模块的 stack 中存储的 Layer 加入到本 router 对象上
        router.stack.push(nestedLayer);
      });
      // 这里与register函数的逻辑类似, 注册的时候检查添加参数校验函数 params
      if (router.params) {
        Object.keys(router.params).forEach(function (key) {
          m.router.param(key, router.params[key]);
        });
      }
    } else {
      // 没有router属性则是常规中间件函数, 如果有给定的 path 那么就生成一个 Layer 模块进行管理
      // 如果没有path, 那么就生成通配的路径 (.*) 来生成 Layer 来管理
      router.register(path || '(.*)', [], m, { end: false, ignoreCaptures: !hasPath });
    }
  });

  return this;
};
```

<<<<<<< HEAD
眼尖的同学可能会看到一些http code：404, 501, 204, 405。那这个函数其实就是当所有中间件函数执行完了，并且请求出错了进行相应的处理：

+ 如果请求的方法koa-router不支持并且没有设置`throw`选项，则返回`501`(未实现)
+ 如果是options请求，则返回 `204`(无内容)
=======
眼尖的同学可能会看到一些 http code：404, 501, 204, 405 。那这个函数其实就是当所有中间件函数执行完了，并且请求出错了进行相应的处理：

+ 如果请求的方法`koa-router`不支持并且没有设置`throw`选项，则返回`501`(未实现)
+ 如果是`options`请求，则返回 `204`(无内容)
>>>>>>> 70f0ef78fcbc4ef41773f4ff1ac4dacf2a74dfdb
+ 如果请求的方法支持但没有设置`throw`选项，则返回 `405`(不允许此方法 )

### Router.prototype.match

<<<<<<< HEAD
我们已经注册好了路由, 但是, 如果请求过来了, 请求是怎么匹配然后进行到相对应的处理函数去的呢? 答案就是利用 match 函数.先看一下 match 函数的代码:
=======
我们已经注册好了路由, 但是, 如果请求过来了, 请求是怎么匹配然后进行到相对应的处理函数去的呢? 答案就是利用`match`函数.先看一下`match`函数的代码:
>>>>>>> 70f0ef78fcbc4ef41773f4ff1ac4dacf2a74dfdb

```
Router.prototype.match = function (path, method) {
  // 取所有路由 Layer 实例
  var layers = this.stack;
  var layer;
  // 匹配结果
  var matched = {
    path: [],
    pathAndMethod: [],
    route: false
  };
  // 遍历路由 Router 的 stack 逐个判断
  for (var len = layers.length, i = 0; i < len; i++) {
    layer = layers[i];

    debug('test %s %s', layer.path, layer.regexp);
    // 这里是使用由路由字符串生成的正则表达式判断当前路径是否符合该正则
    if (layer.match(path)) {
      // 将对应的 Layer 实例加入到结果集的 path 数组中
      matched.path.push(layer);
      // 如果对应的 layer 实例中 methods 数组为空或者数组中有找到对应的方法
      if (layer.methods.length === 0 || ~layer.methods.indexOf(method)) {
        // 将 layer 放入到结果集的 pathAndMethod 中
        matched.pathAndMethod.push(layer);
        // 这里是用于判断是否有真正匹配到路由处理函数
        // 因为像 router.use(session()); 这样的中间件也是通过 Layer 来管理的, 它们的 methods 数组为空
        if (layer.methods.length) matched.route = true;
      }
    }
  }

  return matched;
};
```

<<<<<<< HEAD
通过上面返回的结果集, 我们知道一个请求来临的时候, 我们可以使用正则来匹配路由是否符合, 然后在 path 数组或者 pathAndMethod 数组中找到对应的 Layer 实例对象.
=======
通过上面返回的结果集, 我们知道一个请求来临的时候, 我们可以使用正则来匹配路由是否符合, 然后在`path`数组或者`pathAndMethod`数组中找到对应的`Layer`实例对象.
>>>>>>> 70f0ef78fcbc4ef41773f4ff1ac4dacf2a74dfdb

## router处理请求的流程

![router处理请求的流程](https://vfile.meituan.net/xgfe/63d452eb5a23d3fe3e1bf2e0219bceea93599.png)


## 其他

<<<<<<< HEAD
`koa-router`用到了第三方的node模块
=======
`koa-router`用到了第三方的`node`模块
>>>>>>> 70f0ef78fcbc4ef41773f4ff1ac4dacf2a74dfdb

 + [koa-compose](https://github.com/koajs/compose): 
	提供给它一个中间件数组， 返回一个顺序执行所有中间件的执行函数。
	 
 + [methods](https://github.com/jshttp/methods)： 
<<<<<<< HEAD
	node中支持的http动词，就是http.METHODS，可以在终端输出看看。 
=======
	`node`中支持的`http`动词，就是`http.METHODS`，可以在终端输出看看。 
>>>>>>> 70f0ef78fcbc4ef41773f4ff1ac4dacf2a74dfdb

 + [path-to-regexp](https://github.com/pillarjs/path-to-regexp)： 
	将路径字符串转换成强大的正则表达式，还可以输出路径参数。
	

## 总结

本文通过分析`koa-router`的源码，总结了：

 + `koa-router`涉及到的`router`和`layer`的关系；
 + `koa-router`处理请求的整体流程；
<<<<<<< HEAD
 
=======
 

>>>>>>> 70f0ef78fcbc4ef41773f4ff1ac4dacf2a74dfdb
