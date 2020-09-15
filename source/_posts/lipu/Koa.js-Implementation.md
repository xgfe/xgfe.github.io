title: 从0实现Koa.js
date: 2020-09-15 00:00:00
updated: 2020-09-15 21:34:00
categories:
- lipu
tags:
- blog
- koa.js
- node
---
#  背景

> `Koa.js`是一个使用十分广泛的Node端服务器框架，其代码简洁优雅、抽象良好，在实际的使用过程中能够满足大部分用户对node端服务器的开发需求。本文将要通过利用TypeScript重新实现`Koa.js`的方式按照`Koa`的源码对该框架进行分析。

注：本文为了使得类型声明更为清晰，代码均使用为TypeScript开发

# 核心功能实现

## 实现一个Node服务器

如何在node.js中使用使用原生的代码实现一个服务器呢？当然是使用nodejs原生系统中的`http`模块啦。使用`http`模块中的`createServer`函数进行服务器的创建，其一般代码实现为：

```typescript
import { Server, createServer, IncomingMessage, ServerResponse } from "http";

const server: Server = createServer(
  (req: IncomingMessage, res: ServerResponse) => {
    res.statusCode = 200;
    res.setHeader("Content-Type", "text/plain");
    res.end("Hello World!\n");
  }
);

server.listen(3000);
```

从上面可以看出，实现一个node服务器的主要工作还是需要是需要实现`RequestListener`实例，即形式为`(IncommingMessage, ServerResponse) => void`的函数。该函数可以通过当前的`InComingMessage`中携带的请求数据信息，为返回信息对象`ServerResponse`赋值。在利用该函数实现服务器对象`server`之后，只需要通过`server`自带的`listen`函数将其挂载到对应的端口即可。

## `Koa`实现一个Node服务器

正所谓“万变不离其宗”，在`Koa`中创建一个node服务器，依然离不开`createServer`函数，只不过`Koa`对`createServer`函数的参数方法的实现进行了封装，通过一种“洋葱模型中间件机制”，将`RequestListener`的函数所要实现的功能进行了分层，使用了不同的同步/异步函数进行处理，实现了处理逻辑的分离，为开发提供了便利。

在`Koa`中，使用`Application`对象的实例作为了一切功能的入口，`application`对象的`listen`方法调用了`createServer`方法并挂载到对应的端口。改写上面的代码，可以用类`Koa`源码的方式具体实现为：

```typescript
import {
  Server,
  createServer,
  IncomingMessage,
  ServerResponse,
  RequestListener,
} from "http";

export default class Application {
  callback(): RequestListener {
    return (req: IncomingMessage, res: ServerResponse) => {
      res.statusCode = 200;
      res.setHeader("Content-Type", "text/plain");
      res.end("Hello World!\n");
    };
  }

  listen(...args) {
    const server: Server = createServer(this.callback());
    server.listen(...args);
  }
}
```

在上述方法中，`callback`方法通过返回一个`RequestListener`实例的方式来为服务器定义了服务器处理访问请求并返回数据的具体逻辑。在实际的`Koa`源码实现中，也是通过`callback`函数的返回对象来定义处理逻辑，但是其实现逻辑却更为复杂。

## 为`Koa`添加洋葱模型中间件机制

所谓“洋葱模型中间件机制”，是指在`Request -> Response`的过程中，讲对数据的过程进行分成处理，每一层在对当前的Request进行处理之后，将当前状态（只要表现为`Request`）传入下一层即内层中进行后续处理，待所有内层所有数据处理完成后，状态（主要是Response）将返回到当前层，由当前的中间件继续进行处理。该模型可以参考下面两个比较经典的示意图：

![洋葱模型切面图](/uploads/lipu/Koa.js-Implementation/190663220-0d337f32b88ffb26_articlex.png)

![洋葱模型中间件示意图](/uploads/lipu/Koa.js-Implementation/4013927787-cbd921f6a7cc1d27_articlex.png)

### 使用者如何建立一层洋葱

在实际使用过程中，框架使用者一般会自己定义在各层中不同模块的功能，即实现各层洋葱皮的功能。那使用者应该如何创建各层的洋葱皮呢？如何在处理完数据将状态转移到内部的下一层中呢？当内部的所有洋葱皮运行处理完成后，又该如何返回到当前层进行后续数据处理呢？从上面的两幅图可以知道，建立一层洋葱皮的过程其实就是创建一个中间件的过程。从上文可以看到，一个中间件主要进行三个部分的工作：

1. 对当前的`request`进行分析，进行相关处理数据处理；
2. 转移状态到洋葱的下一层，等待所有内层洋葱中间件执行完毕后返回到当前中间件；
3. 根据当前的`request`和`response`进行后续操作。

在`Koa`2中，通过`async/await`来实现中间件。举例如下：

```typescript
const middleware = async (ctx, next) => {
  const start = new Date();
  await next();
  const delta = new Date() - start;
  console.log(`耗时:${delta}ms`)
}
```

在上例中，变量`ctx`中存储了当前的所有状态信息，如`request`、`response`等，并且该对象对所有的中间件都是公共的，所有中间件对`ctx`的操作对后续的中间件都是可见的。`next`是一个异步函数，对每个中间件来说是更里面一层中间件的执行过程，通过`await`关键字，将在`next`函数即所有更内层中间件执行完成后才开始执行`next`后面的相关逻辑代码。

所以我们可以知道，在`Koa`中通过对各个中间件共同课件的变量`ctx`实现了状态数据在中间件之间的共享，通过使用异步函数的`async/await`的方式实现了各个中间件之间执行状态的转移。

### 如何将多层洋葱皮拼装成一个洋葱

在了解如何实现一个中间件长什么样子之后，`Koa`更重要的是希望知道如何将多层洋葱皮组织成一整个洋葱。这个过程主要考虑两个方面的情况：

1. 如何组织中间件的执行次序
2. 如何包装将内层中间件的调用过程包装成一个` next`函数

首先研究第一个问题。在`Koa`的源码中，我们可以看到，`Application`对象有一个成员变量名为`middleware`，它是一个数组，用来存储需要挂载的所有的中间件。而在具体的使用中，使用`Application.use`方法来将中间件存储到`Application`对象的`middleware`中，存储的顺序由调用`Application.use`方法的顺序决定。具体的代码实现如下：

```typescript
export default class Application {
  middleware: Array<Function>;

  constructor() {
    this.middleware = [];
  }

  use(fn: (ctx: Object, next: Function) => void): Application {
    this.middleware.push(fn);
    return this;
  }

  callback(): RequestListener {
    ......
  }

  listen(...args) {
    const server: Server = createServer(this.callback());
    server.listen(...args);
  }
}
```

上面`use`方法的返回值为`Application`本身，这样便于用户链式地调用`use`方法，如`app.use(fn1).use(fn2).use(fn3);`

接下来我们考虑如何将中间件包装成一个`next`函数并从外到内依次地调用它们。在`Koa`中,专门有一个叫做`koa-compose`的子组件，其导出的函数`compose`用于处理这个流程。其设计逻辑包含以下要点：

1. `compose`将多个中间件组装为一个中间件，即`compose`的类型定义为`compose(Array<Middleware>):Middleware`;
2. `compose`中参数中的中间件，既可以是一个同步函数，也可能是一个由`async/await`来声明的异步函数，所以需要使用`Promise.resolve`来统一处理为异步函数；
3. `compse`的结果中返回的中间件中，需要按照参数数组中的中间件顺序进行对`context`进行对应的处理。

具体代码实现如下；

```typescript
type Next = () => Promise<any>;
type MiddleWare<T> = (context: T, next?: Next) => any;

function compose(middlewares: Array<MiddleWare<any>>): MiddleWare<any> {
  return ((context: any, next: Next) => {
    let index = -1;
    function dispatch(i: number) {
      if (i <= index)
        return Promise.reject(new Error("next() called multiple times"));
      index = i;
      let fn = middlewares[i];
      if (i === middlewares.length) fn = next;
      if (!fn) return Promise.resolve();
      try {
        return Promise.resolve(fn(context, dispatch.bind(null, i + 1)));
      } catch (err) {
        return Promise.reject(err);
      }
    }
    return dispatch(0);
  }) as MiddleWare<any>;
}
```

注意，虽然中间件处于一种相互嵌套，逐层递进的运行关系中，但是在实际的过程中，部分请求当我们执行到某一层时就已经确定了需要返回的结果，无需后续处理，所以可以直接不执行`next`方法，直接此层开始逐层返回即可。

### 如何将中间件嵌入服务器

通过上面的`compose`我们可以知道我们将多层中间件最终合并成一个中间件，所以多层洋葱皮打破了层壁，成为了一个圆润的洋葱。那么我们又面临了那个经典的问题： 请问将一个洋葱塞进服务器需要几个步骤？

让我们来梳理一下已知的信息：

1. 所有的中间件被整合为一个中间件，其形式为`(context, next) => any`的形式，其中`context`包含了当前所有的状态信息；
2. 我们需要得到的是`http.createServer`函数的参数，其形式为`(req, res) => void`的形式，其中`req`和`res`存储了请求处理过程中的状态信息。该结果是`Application.callback()`函数的执行结果。

由上面可以看到，将整合得到的中间件嵌入到服务器中，需要完成以下工作：

1. 将`req`和`res`整合到`context`中;
2. 将中间件改写到需要的形式

该功能的简单实现为：

```typescript
export default class Application {
  middleware: Array<MiddleWare<any>>;

  constructor() {
    this.middleware = [];
  }

  use(fn: MiddleWare<any>): Application {
    this.middleware.push(fn);
    return this;
  }

  createContext(req: IncomingMessage, res: ServerResponse){
    return {
        req,
        res
    }
  }

  callback(): RequestListener {
    let fn = compose(this.middleware);
    return (req: IncomingMessage, res: ServerResponse) => {
      let context = this.createContext(req, res);
      return fn(context);
    };
  }

  listen(...args) {
    const server: Server = createServer(this.callback());
    server.listen(...args);
  }
}

```

上面我们完成了`Koa.js`的核心内容，即通过中间件来分层封装处理服务器请求的处理过程。基本上可以总结如下图所示：

![核心流程示意图](/uploads/lipu/Koa.js-Implementation/flow1.svg)



然而，`Koa.js`的除了上述的核心功能，还存在一下其他的细节和实现，这些部分虽然不是`Koa.js`功能的绝对核心，但是如果没有了这部分功能的实现，`Koa.js`绝对不可能为开发者提供方便稳定的功能。

# 细节功能雕琢

## Context的实现

上述函数`createContext`中，将`http.createServer`的参数`req`和`res`的包装成了在中间件中传入的参数`context`。在上文中，我们直接使用`req`和`res`封装成对象`context`的方式进行包装，然而在`Koa.js`的实际实现中，`Koa.js`在保留原有的`context.req`和`context.res`这两个成员变量的基础上，又添加了`context.request`和`context.response`这两个封装了一些用户常用的属性方法的属性。使得用户不但可以选择对`http.createServer`的原生参数进行直接的操作，还能通过`context.request`和`context.response`中提供的更为方便的方法对`req`和`res`进行更为高效的操作。相关代码如下：

```typescript
import {
  Server,
  createServer,
  IncomingMessage,
  ServerResponse,
  RequestListener,
} from "http";
import Context from './context';
import Request from './request';
import Response from './response';

......

export default class Application {
  middleware: Array<MiddleWare<any>>;
  context: Context;
  request: Request;
  response: Response;

  constructor() {
    this.context = new Context();
    this.request = new Request();
    this.response = new Response();
    this.middleware = [];
  }

......

  createContext(req: IncomingMessage, res: ServerResponse){
    const context = Object.create(this.context);
    const request = context.request = Object.create(this.request);
    const response = context.response = Object.create(this.response);
    context.app = request.app = response.app = this;
    context.req = request.req = response.req = req;
    context.res = request.res = response.res = res;
    request.ctx = response.ctx = context;
    request.response = response;
    response.request = request;
    context.originUrl = request.originUrl = req.url;
    context.state = {};
    return context;
  }
 
......

}

```

另外，`Koa.js`为了更一步为开发者提供更为便捷的功能支持，还通过委托模式，将`request`和`response`中的部分方法挂载到`context`中，使得使用者可以直接通过`context.xxx`的方式去访问`context.request.xxx`或者`context.response.xxx`，进一步提供了`Koa.js`的使用体验。

![Koa.js内部对象引用图](/uploads/lipu/Koa.js-Implementation/Application.png)

## 错误处理

在`node.js`端的程序中，错误处理无疑是十分重要的问题，因为如果无法处理好在程序运行中出现的各种错误，有可能会导致程序的错误中止，影响程序运行的稳定性。特别是在使用`Koa.js`的服务器端的程序中，保证服务高效稳定地运行下去无疑是程序功能的重点，而完善的错误处理不但能够保证程序的正常运行，另一方面通过错误处理中打印出的日志信息，程序的开发者能够分析程序的运行状态，为完善和优化从程序提供很好的参考资料。

在`Koa.js`中，通过`node.js`原生模块`events`下的`EventEmitter`对象来实现具体的错误处理，主要包括以下步骤：

1. 通过`Application`对象继承`EventEmitter`对象相关的方法，使得用户可以通过`application.on`方法进行错误处理方法的监听；
2. 在`Context`中定义`onerror`方法，在中间件处理过程中，出现的问题都会抛给`ctx.onerrror`方法，该方法中又会使用`app.emit('error', error)`唤起`Application`处理问题；
3. 如果用户通过`application.on`注册了错误处理方法，将通过该方法处理错误，否则将使用`Application.onerror`方法处理该错误。

代码实现如下：

```typescript
// application.ts
import {
  Server,
  createServer,
  IncomingMessage,
  ServerResponse,
  RequestListener,
} from "http";
import { EventEmitter } from "events";
import Context from "./context";
import Request from "./request";
import Response from "./response";

export default class Application extends EventEmitter {
  
  ......

  constructor() {
    super();
    ......
  }

  ......

  callback(): RequestListener {
    let fn = compose(this.middleware);

    if(this.listenerCount('error')) this.on('error', this.onerror);

    return (req: IncomingMessage, res: ServerResponse) => {
      let context = this.createContext(req, res);
      return this.handleRequest(context, fn);
    };
  }

  handleRequest(ctx: any, fnMiddleware: MiddleWare){
    const onerror = err => ctx.onerror(err);
    return fnMiddleware(ctx).catch(onerror);
  }

  onerror(err){
    
    ......
    
  }
}

// context.ts
class Context {
  
  ...
  
  onerror(err){   
    ......
    this.app.emit('error', err, this);
    ......
  }
    
}

```



调用关系如下图所示：

![调用关系示意图](/uploads/lipu/Koa.js-Implementation/flow2.svg)



# 总结

综上就是`Koa.js`的核心功能实现。`Koa.js`虽然是一个小小的只有四个文件不到2k代码的小框架，但是其结构精巧、功能强大，通过中间件的方式满足了不同开发者的各种不同需求，充分体现了“简单即美”的设计思想。通过对其源码的学习，能够使我们对`node.js`的属性特性和设计思想有更深刻的理解。