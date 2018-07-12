title: 前后端通信的几种方式
date: 2018-06-10 
categories:
- ANJING
tags:
- 前后端通信
---
本文主要总结了前后端通信的几种方式。本文分为两个部分，第一部分是主要是介绍同源的前后端通信的方式，第二部分是介绍前后端跨域通信的方式。

## 一、前后端通信（同源）简介

### 1. 什么是同源策略
同源策略显示从一个源加载的文档或脚本如何来自另一个源的资源进行交互。这是一个用于隔离潜在恶意文件的关键的安全机制。源包含三部分内容（协议，端口和域名，默认端口是80）。
同源的限制：
（1）Cookie ,LocalStorage和IndexDB 无法获取
（2）DOM无法获得和操作
（3）Ajax请求不能发送，只是用与同源通信

### 2.前后端通信的几种方式

* Ajax（同源下面的通信方式）
* WebSocket（不受同源策略限制）
* CORS（支持跨域也支持同源）

### 3.如何创建一个ajax

发送 Ajax 请求的五个步骤（XMLHttpRequest的工作原理）
（1）创建XMLHttpRequest 对象。
（2）使用open方法设置请求的参数。open(method, url, 是否异步)。
（3）发送请求。
（4）注册事件。 注册onreadystatechange事件，状态改变时就会调用。如果要在数据完整请求回来的时候才调用，我们需要手动写一些判断的逻辑。
（5）获取返回的数据，更新UI。
post 请求举例：
```

    <script type="text/javascript"> 
        // 建立XMLHttpRequest对象       
        var xhr = new XMLHttpRequest();        
        xhr.open('post', '02.post.php');           
        xhr.setRequestHeader("Content-type", "application/x-www-form-urlencoded");  
        // 将数据通过send方法传递       
        xhr.send('name=fox&age=18');            
        xhr.onreadystatechange = function () {                 
            if (xhr.readyState == 4 && xhr.status == 200) { 
                //判断返回状态  
                alert(xhr.responseText);
            }
        }; 
    </script>

```
### 4.实际开发中用的原生Ajax请求
```
var util = {};      
//获取 ajax 请求之后的json     
util.json = function (options) {
    var opt = {
        url: '',
        type: 'get',
        data: {},
        success: function () {
        },
        error: function () {
        },
    };
    Object.assign(opt, options);
    //IE兼容性处理：浏览器特征检查。检查该浏览器是否存在XMLHttpRequest这个api，没有的话，就用IE的api             
    var xhr = XMLHttpRequest ? new XMLHttpRequest() : new window.ActiveXObject('Microsoft.XMLHTTP');
    var data = opt.data,
    var type = opt.type.toUpperCase();
    var dataArr = [];
    if (opt.url) {   
        var url = opt.url;
    }
    for (var key in data) {
        dataArr.push(key + '=' + data[key]);
    } 
    if (type === 'GET') {
        url = url + '?' + dataArr.join('&');
        xhr.open(type, url.replace(/\?$/g, ''), true);
        xhr.send();
    }
    if (type === 'POST') {
        xhr.open(type, url, true);
        // 如果想要使用post提交数据,需要明确设置Request Header    
        xhr.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
        xhr.send(dataArr.join('&'));
    }
    xhr.onreadystatechange = function () {
        if (xhr.status === 200 || xhr.status === 304) {
            //304表示：用缓存即可。206表示获取媒体资源的前面一部分                
            var res;
            if (opt.success && opt.success instanceof Function) {
                res = xhr.responseText;
                if (typeof res === 'string') {
                    //将字符串转成json
                    res = JSON.parse(res);                           
                    opt.success.call(xhr, res);
                }
            }
        } else {
            if (opt.error && opt.error instanceof Function) {
                opt.error.call(xhr, res);
            }
        }
    };
}
```
### 5.WebSocket 介绍
HTTP 协议有一个缺陷：通信只能由客户端发起。所以出现了WebSocket。它的最大特点就是，服务器可以主动向客户端推送信息，客户端也可以主动向服务器发送信息，是真正的双向平等对话，属于服务器推送技术的一种。
其他特点包括：
（1）建立在 TCP 协议之上，服务器端的实现比较容易。
（2）与 HTTP 协议有着良好的兼容性。默认端口也是80和443，并且握手阶段采用 HTTP 协议，因此握手时不容易屏蔽，能通过各种 HTTP 代理服务器。
（3）数据格式比较轻量，性能开销小，通信高效。
（4）可以发送文本，也可以发送二进制数据。
（5）没有同源限制，客户端可以与任意服务器通信。
（6）协议标识符是ws（如果加密，则为wss），服务器网址就是 URL。

通常WebSocket协议的链接如下所示：
``` 
ws://example.com:80/some/path

```
WebSocket的实现需要后端搭建一个WebSocket服务器，但是如果想搭建一个WebSocket服务器就没有那么轻松了，因为WebSocket是一种新的通信协议，目前还是草案，没有成为标准，比如 PyWebSocket,WebSocket-Node, LibWebSockets等等，这些库文件已经实现了WebSocket数据包的封装和解析，我们可以调用这些接口，这在很大程度上减少了我们的工作量。
具体的实现方式：（在客户端）
```
// 再js文件中 创建WebSocket对象
var ws = new WebSocket(‘wss://echo.WebSocket.org’);
ws.onopen = function (evt) {
    console.log(‘connnection……’);
    ws.send('hello WebSocket');
}
ws.onmessage = function (evt) {
        console.log('received message' + evt.data);
        ws.close();
    }
ws.onclose = dunction(evt){
        console.log('connection closed.');
    }   
// ws的使用，以为按钮添加发送信息事件为例
$("#send").click(function(){
    ws.send($("#msg").val());
});
```
### 6.CORS 介绍
CORS是一个W3C标准，跨域资源共享（CORS ）是一种网络浏览器的技术规范，它为Web服务器定义了一种方式，允许网页从不同的域访问其资源。而这种访问是被同源策略所禁止的。CORS系统定义了一种浏览器和服务器交互的方式来确定是否允许跨域请求。 它是一个妥协，有更大的灵活性，但比起简单地允许所有这些的要求来说更加安全。简言之，CORS就是为了让AJAX可以实现可控的跨域访问而生的。
下图为各浏览器对于CORS的支持情况，看起来相当乐观。主流浏览器都已基本提供对跨域资源共享的支持，所以，CORS才会在国外使用的如此普遍。
<img src="http://vfile.meituan.net/xgfe/d87439988ef5ab43251311a668d027d6233940.png">
使用CORS需要做服务端和前端的配置：
#### 服务端的配置

以下是CORS协议规定的HTTP头，用来进行浏览器发起跨域资源请求时进行协商：
1. Origin。HTTP请求头，任何涉及CORS的请求都必需携带。
2. Access-Control-Request-Method。HTTP请求头，在带预检(Preflighted)的跨域请求中用来表示真实请求的方法。
3. Access-Control-Request-Headers。HTTP请求头，在带预检(Preflighted)的跨域请求中用来表示真实请求的自定义Header列表。
4. Access-Control-Allow-Origin。HTTP响应头，指定服务器端允许进行跨域资源访问的来源域。可以用通配符 \* 表示允许任何域的JavaScript访问资源，但是在响应一个携带身份信息(Credential)的HTTP请求时，Access-Control-Allow-Origin必需指定具体的域，不能用通配符。
5. Access-Control-Allow-Methods。HTTP响应头，指定服务器允许进行跨域资源访问的请求方法列表，一般用在响应预检请求上。
6. Access-Control-Allow-Headers。HTTP响应头，指定服务器允许进行跨域资源访问的请求头列表，一般用在响应预检请求上。
7. Access-Control-Max-Age。HTTP响应头，用在响应预检请求上，表示本次预检响应的有效时间。在此时间内，浏览器都可以根据此次协商结果决定是否有必要直接发送真实请求，而无需再次发送预检请求。
8. Access-Control-Allow-Credentials。HTTP响应头，凡是浏览器请求中携带了身份信息，而响应头中没有返回。

实际应用中，服务端例子：

```
//允许跨域访问  
HttpContext.Current.Response.AddHeader("Access-Control-Allow-Origin", "*");  
HttpContext.Current.Response.AddHeader("Access-Control-Allow-Methods", "POST, GET, OPTIONS, DELETE,
 PUT");  
HttpContext.Current.Response.AddHeader("Access-Control-Allow-Headers", "Test"); 

```
#### 前端的配置
前端的配置主要从简单请求、非简单请求和携带身份凭证这三点进行讲解。
浏览器将CORS请求分成两类：简单请求（simple request）和非简单请求（not-so-simple request）。
1.简单请求：
使用下列方法：GET、HEAD、POST
HTTP的头信息主要是以下几种字段：
* Accept
* Accept-Language
* Content-Language
* Content-Type:值属于下列之一:
* application/x-www-form-urlencoded
* multipart/form-data
* text/plain

简单请求如图所示：
<img src="http://vfile.meituan.net/xgfe/63958e7743ea262c379f4466c52844a636486.png" />
2.非简单请求：
不满足简单请求条件的请求则要先进行预检请求，即使用OPTIONS方法发起一个预检请求到服务器，已获知服务器是否允许该实际请求。
非简单请求如下所示：
<img src="http://vfile.meituan.net/xgfe/cf3757d6cc10ac2d4c9c023af564900f126443.png"/>
浏览器与服务器之间请求只进行了一次。
下面是PUT请求第一次返回的结果：
<img src="http://vfile.meituan.net/xgfe/33d389422e08f9f730faa7757ef26bba81218.png" />
<img src="http://vfile.meituan.net/xgfe/000d4cf1b6d92837affcddef925df2a176640.png" />
通过PUT请求结果可以看出，当检测到PUT请求为非简单请求时，浏览器便会发送一个预检请求，目的是询问，自定义头部X-Custom-Header的PUT请求是否被允许，浏览器返回了所有可以请求的方法和自定义的头部（把所有可以的返回是为了避免多次预检请求），这时候预检请求成功了，便会发送真正的PUT请求。

关于预检请求，需要注意一下两点：
* 预检请求对js来说是透明的，js获取不到预检请求的任何信息。
* 预检请求并不是每次请求都发生，服务端设置的Access-Control-Max-Age头部指定了预检请求的有效期，在有效期内的非简单请求不需要再次发生预检请求。

3.携带身份凭证
大部分的请求是需要用户携带着用户信息的，比如在一个登录的系统中，用户会携带着相应的cookie或token，但CORS跨域默认是不带身份凭证的。
如果需要附带身份凭证，在发送请求时，通过将withCredentials属性设置为true，可以指定某个请求可以发送凭据。
下面提供针对XMLHttpRequest附带身份凭证的兼容性写法：

```
function createCORSRequest(method, url) {
    var xhr = new XMLHttpRequest();
    xhr.onload = function() {
        if(xhr.readyState == 4) {
            if((xhr.status >= 200 && xhr.status < 300) || xhr == 304) {
                console.log(xhr.response);
            } else {
                console.log('Request was unsuccessful: ' + xhr.status);
            }
        }
    };
    if('withCredentials' in xhr) {
        xhr.open(method,url, true);
    } else if(typeof XDomainRequest != 'undefined') {
        xhr = new XDomainRequest();
        xhr.open(method, url);
    } else {
        xhr = null;
    }
    return xhr;
}

```
附带身份凭证对服务端有两个要求：
1. 服务端的Access-Control-Allow-Origin头部不能设置为*
2. 服务端的Access-Control-Allow-Credentials头部设置为true

## 二、 前后端跨域通信
* JSONP
* Hash
* WebSocket
* CORS


### 1.JSONP 
JSONP的工作原理：
本质是利用了script标签具有可跨域的特性，由服务端返回预先定义好的javascript全局函数的调用，并且将服务端数据以该函数参数的形式传递过来。比如说，客户端这样写：
```
<script src="http://www.smyhvae.com/?data=name&callback=myjsonp"></script>
```

实际开发中，前端的JSONP是这样实现的：
```
    var util = {}; 
    //定义方法：动态创建script标签
    util.createScript = function (url, charset) {
        var script = document.createElement('script');
        script.setAttribute('type', 'text/javascript');
        charset && script.setAttribute('charset', charset);
        script.setAttribute('src', url);
        script.async = true;
        return script;
   };
    util.jsonp = function (url, onsuccess, onerror, charset) {  
        //事先约定好的函数名
        var callbackName = util.getName('tt_player');  
        //根据回调名称注册一个全局的函数 
        window[callbackName] = function () {               
            if (onsuccess && util.isFunction(onsuccess)) {
                onsuccess(arguments[0]);
            }
        };
        //动态创建一个script标签
        var script = util.createScript(url + '&callback=' + callbackName, charset);   
        //监听加载成功的事件，获取数据
        script.onload = script.onreadystatechange = function () {      
            if (!script.readyState || /loaded|complete/.test(script.readyState)) {
                // 移除该script的DOM对象  
                script.onload = script.onreadystatechange = null;                 
                if (script.parentNode) {
                    // 删除函数或变量
                    script.parentNode.removeChild(script);  
                }      
                //最后不要忘了删除           
                window[callbackName] = null;  
            }
        };
        script.onerror = function () {                              
            if (onerror && util.isFunction(onerror)) {
                onerror();
            }
        };
        //往html中增加这个标签，目的是把请求发送出去
        document.getElementsByTagName('head')[0].appendChild(script);  
    };

 ```

### 2.Hash 
url的#后面的内容就叫Hash。Hash的改变，页面不会刷新。这就是用Hash做跨域通信的基本原理。
补充：url的?后面的内容叫Search。Search的改变，会导致页面刷新，因此不能做跨域通信。
使用举例：
场景：我的页面A通过iframe或frame嵌入了跨域的页面 B。
现在，我这个A页面想给B页面发消息，怎么操作呢？
（1）首先，在我的A页面中：

```
//伪代码  
var B = document.getElementsByTagName('iframe');  
//我们可以把JS对象，通过JSON.stringify()方法转成json字符串，发给B   
B.src = B.src + '#' + 'jsonString';  

```
（2）然后，在B页面中：
```
// B中的伪代码     
window.onhashchange = function () { 
     //通过onhashchange方法监听，url中的hash是否发生变化         
     var data = window.location.hash;
};
```