title: 远程调用框架Thrift分享
date: 2017.5.3
categories: zhouxiong
tags:
- Thrift
- NodeJS
---

## Thrift

Thrift是一个跨语言的远程调用框架(RPC)，它允许你根据IDL规则定义数据类型和服务接口，然后通过Thrift编译器生成跨语言的client和server端，目前支持市面上所有的主流语言。

<!--more-->

- 主要目标

建立一种高效，可信赖的跨语言通信方案，不再将客户端和服务端局限于同一种语言上。

## Thrift VS Restful

Thrift RPC相比于HTTP的Restful模式有自己的优势，也有不足的地方。

|       对比项          |      Thrift                                   |     Restful                              |
| ---------------------  |:---------------------------------------:| --------------------------------------|
|   架构设计          |     基于C/S模式                        |   基于B/S模式                       |
|  传输协议           |  可以通过Socket，HTTP传输  |   通过HTTP传输                   |
|  传输格式           | 基于二进制数据传输               | 基于JSON或者XML格式传输 |
| 优势                   | 体积更小，传输更快               | 充分利用HTTP协议优势         |
| 劣势                   | 增加额外序列化和反序列化成本 | 针对业务场景HTTP动词太少   
## Thrift基础知识之IDL

Thrift是一门接口定义语言(interface definition language, IDL)，遵循自己的语言原则。一个IDL文件中包含定义的数据结构以及接口服务，可以由Thrift的代码生成器将源文件(.thrift)编译成各种目标语言支持的文件，例如可以将IDL文件编译成Java支持的.java文件，NodeJS支持的.js文件等。

###  基本数据类型

- bool 表示一个布尔值，取true或false
	
- byte 表示一个带符号的字节
	
- i16 表示一个带符号的16位整形
	
- i32 表示一个带符号的32位整形 
	
- i64 表示一个带符号的64位整形
	
- double 表示一个带符号的64位浮点数is
	
- string 表示一个不可知编码的文本或二进制串

### 结构struct

类似于C++里的结构体，定义一个通用的对象以此来跨语言，通过struct来描述，对于struct有一些限制

- struct不能继承，可以嵌套
 
- 成员必须有明确的数据类型
 
- 成员是被整数编过号的，编号不能被重复使用

- 字段有required和optional之分，默认值为optional，设置为required，则必须赋值而且会被序列化；设置为optional，则在没有设置值的时候不会进行序列化。而且如果设置为required，而没有赋值时会报错`Required field XX is unset!`

- 字段可以设置默认值

例如定义一个User对象

```
 struct User {
    1: i16 id,
    2: string username,
    3: string password = '123456',
    4: required string email,
    5: optional string telphone
}
```

### 容器Containers

Thrift容器类似于主流编程语言的容器，主要有三种类型：

 - list< type >：元素类型为type的有序列表，允许重复元素
 
 -  set< type >：元素类型为type的无序列表，不允许重复元素

 - map< key, value>：< key, value>类型的键值对，key不允许重复，一般情况下map的key最好是thrift的基本类型

例如定义一个struct，里面包含三种类型的容器

```
struct User {
    1: i16 id,
    2: string username,
    3: string password,
    4: required string email,
    5: optional string telphone
}

struct Person { 
    1: list<User> userList,
    2: set<User> userSet,
    3: map<string, User> userMap
}
```

### 枚举Enum

枚举是很多语言中都有的概念，是有穷序列的所有成员的一种表示方式，具有以下一些特征：

- 编译器会将每个成员变量赋予一个整数值，默认从0开始

- 可以赋予成员变量任意一个整数值

例如定义一个运算符的枚举

```
enum Operation {
    ADD = 1,
    SUBTRACT = 2,
    MULTIPLY = 3,
    DIVIDE = 4
}
```

### 异常Exception

Thrift中同样提供了自定义异常信息的exception属性，Thrift的exception继承了每种语言的基础异常类。

例如，自定义一个运算错误的异常

```
// 运算异常
exception InvalidOperation {
    1: i32 whatOp,  
    2: string why
}
```

### 服务Service

Thrift中的service定义相当于其他语言中的接口定义，service中只有方法的声明，没有方法的实现。Thrift编译器会产生实现这些接口的client和server。

例如定义个NodeJS的运算Service，注意在service中不需要进行顺序的编码

```
service Calculate {
    void ping(),

    i32 add(1: i32 num1, 2: i32 num2),

    i32 calculate(1: i32 logid, 2: Work work) throws (1: InvalidOperation invalid)
}
```

### 命名空间Namespace

Thrift中的namespace类似于c++中的namespace和java中的package，将相关代码组织在一起

```
namespace cpp com.example.test
namespace java com.example.test 
namespace php com.example.test  
```

### include

为了方便管理、重用和提高模块性/组织性，我们常常分割Thrift定义在不同的文件中。Thrift允许文件通过include关键字来引入其它thrift文件，用户需要使用thrift文件名作为前缀访问被包含的对像。

注意：在include关键那行后面没有逗号或者分号。

```
include "test.thrift"   
...
struct StSearchResult {
    1: i32 uid,
	...
}
```

## Thrift基础之底层网络通信

Thrift的整体架构图如下所示

![架构图](https://p1.meituan.net/dpnewvc/c8ae7c1cd293f4317d504b39289f7924517918.png)

从架构图中可以看出，我们自己编写的代码只需要实现service就可以，我们其实并不关心底层的Protocol和Transport的实现。

### Transport

Transport提供了一个简单的网络读写抽象层，是thrift最底层的服务，Transport接口定义了以下一些方法

- open

- close

- read

- write

- flush

目前提供的transport有以下这些：

- TSocket：使用阻塞的socket I/O

- TFramedTransport：以帧的形式发送，每帧前面是一个长度。要求服务器来non-blocking server

- TFileTransport：写到文件。没有包括在java实现中。

- TMemoryTransport：使用内存 I/O 。java实现中在内部使用了ByteArrayOutputStream。

- TZlibTransport：压缩使用zlib。在java实现中还不可用。

### Protocol

Protocol抽象层定义了一种将内存中数据结构映射成可传输格式的机制。换句话说，Protocol定义了datatype怎样使用底层的Transport对自己进行编解码。因此，Protocol的实现要给出编码机制并负责对数据进行序列化。

目前支持的协议有：

- TBinaryProtocol：二进制格式

- TCompactProtocol：效率和高压缩编码数据

- TDenseProtocol：和TCompactProtocol相似，但是省略了meta信息，从哪里发送的，增加了receiver。还在实验中，java中还不可用

- TJSONProtocol：使用JSON

- TSimpleJSONProtocol：只写的protocol使用JSON

- TDebugProtocol：使用人类可读的text格式，帮助调试

## Thrift使用

在这里我们要完成的一个功能是使用NodeJS编程，建立Thrift服务，通过客户端向服务端发送请求完成加减乘除的计算，下面对整个过程进行详细讲解。

### 安装

参考地址：[https://thrift.apache.org/docs/BuildingFromSource](https://thrift.apache.org/docs/BuildingFromSource)

- 下载

首先将thrift项目clone到本地，thrift地址为`https://github.com/apache/thrift.git`，然后进入到项目中。

- 构建和安装thrift的编译器

进入到项目的顶级目录中，执行以下命令，安装boost

```
./bootstrap.sh

```

然后执行以下命令，安装libevent

```
./configure --prefix=/usr/local
make
```

在安装过程中可能出现`Bison version 2.5 or higher must be installed on the system!`的问题，需要安装bison的最新版本

```
brew install bison
```

然后链接bison

```
brew link bison --force 
```

### 建立.thrift文件

建立一个calculate.thrift文件，在文件中定义struct以及服务接口。

```
// 操作运算符
enum Operation {
    ADD = 1,
    SUBTRACT = 2,
    MULTIPLY = 3,
    DIVIDE = 4
}

// 运算实体
struct Work {
    1: i32 num1 = 0,
    2: i32 num2,
    3: Operation op,
    4: string comment
}

// 异常信息
exception InvalidOperation {
    1: i32 whatOp,
    2: string why
}

// 服务接口
service Calculate {
    void ping(),

    i32 add(1: i32 num1, 2: i32 num2),

    i32 calculate(1: i32 logid, 2: Work work) throws (1: InvalidOperation invalid)
}
```

### 编译.thrift文件

通过以下命令来编译calculate.thrift文件，---gen后面的参数表示编译成支持NodeJS的文件

```
thrift -r --gen js:node tutorial.thrift
```
编译后会发现生成了一个gen-nodejs文件夹，下面包含了两个文件
![生成的文件夹](https://p1.meituan.net/dpnewvc/e6b5b5b48d0fe84953da10fbffe70edb16813.png)

### 编写server文件

Thrift是基于Client/Server模式的，我们需要分别编写server和client文件。

- require

首先需要通过require的方式引入thrift和刚才生成的gen-nodejs文件夹下的两个文件

```
var thrift = require('thrift');
var Calculate = require('../gen-nodejs/Calculate');
var ttypes = require('../gen-nodejs/calculate_types');
```

- 创建server

通过createServer()方法创建一个server，并在内部实现service中定义的几个方法

```
var server = thrift.createServer(Calculate, {})
```

- 监听端口

```
server.listen(9090);
```

- 完整代码如下

```
var thrift = require('thrift');
var Calculate = require('../gen-nodejs/Calculate');
var ttypes = require('../gen-nodejs/calculate_types');

var server = thrift.createServer(Calculate, {
    ping: function (result) {
        console.log('ping success');
        result(null);
    },
    add: function (num1, num2, result) {
        console.log('add success');
        result(null, num1 + num2);
    },
    calculate: function (logid, work, result) {
        console.log('calculate success');
        var val = 0;
        if (work.op === ttypes.Operation.ADD) {
            val = work.num1 + work.num2;
        } else if (work.op === ttypes.Operation.SUBTRACT) {
            val = work.num1 - work.num2;
        } else if (work.op === ttypes.Operation.MULTIPLY) {
            val = work.num1 * work.num2;
        } else if (work.op === ttypes.Operation.DIVIDE) {
            if (work.num2 === 0) {
                var o = new ttypes.InvalidOperation();
                o.whatOp = work.op;
                o.why = 'Can not divide by 0';
                result(o);
                return;
            }
            val = work.num1 / work.num2;
        } else {
            var o = new ttypes.InvalidOperation();
            o.whatOp = work.op;
            o.why = 'invalid operation';
            result(o);
            return;
        }
        result(null, val);
    }
});

server.listen(9090);
```

### 编写client文件

- require

类似于server端，client端也需要引入相关文件

```
var thrift = require('thrift');
var Calculator = require('../gen-nodejs/Calculate');
var ttypes = require('../gen-nodejs/calculate_types');
```

- 建立连接

```
var transport = thrift.TBufferedTransport;
var protocol = thrift.TBinaryProtocol;

var connection = thrift.createConnection("localhost", 9090, {
  transport : transport,
  protocol : protocol
});
```

- 创建client

```
var client = thrift.createClient(Calculator, connection);
```

- 调用service中的方法

client端通过调用service中的方法向server发送请求

- 完整代码

```
var thrift = require('thrift');
var Calculator = require('../gen-nodejs/Calculate');
var ttypes = require('../gen-nodejs/calculate_types');

var transport = thrift.TBufferedTransport;
var protocol = thrift.TBinaryProtocol;

var connection = thrift.createConnection('localhost', 9090, {
    transport: transport,
    protocol: protocol
});

connection.on('error', function (error) {
    console.log(error);
});

var client = thrift.createClient(Calculator, connection);

client.ping(function (response) {
    console.log('client ping');
});

client.add(1, 1, function (error, response) {
    console.log('1 + 1 = ', response);
});

var work = new ttypes.Work();
work.op = ttypes.Operation.SUBTRACT;
work.num1 = 10;
work.num2 = 4;

var work2 = new ttypes.Work({
    num1: 10,
    num2: 4,
    op: ttypes.Operation.SUBTRACT
});

client.calculate(1, work2, function (error, response) {
    if (error) {
        console.log(error);
    } else {
        console.log('10 - 4 = ' + response);
    }
    connection.end();
});
```

### 调用server和client

直接通过node命令启动server监听端口，然后通过node创建client

```
node server/server.js

node client/client.js
```

### 运行结果

- 服务端
![服务端结果](https://p1.meituan.net/dpnewvc/14ff01bccad5570e9e923b31798c820d28373.png)

- 客户端
![客户端结果](https://p1.meituan.net/dpnewvc/8d37bd540b2967cbf8367ce454b4740c23797.png)

## 参考资料

1.[Thrift IDL入门教程](http://www.jianshu.com/p/0f4113d6ec4b)

2.[thrift官网的NodeJS实例](https://thrift.apache.org/tutorial/nodejs)
