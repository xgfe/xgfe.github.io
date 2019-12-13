title: 代理工具whistle的基本使用
date: 2019-09-17
categories: qiuwei
tags: 
- 代理
- charles
---

本文主要介绍代理工具whistle的基本功能以及实际应用。
<!--more-->
# whistle是干嘛用的
whistle(读音[ˈwɪsəl]，拼音[wēisǒu])基于Node实现的跨平台web调试代理工具，类似的工具有Fiddler、Charles，主要用于查看、修改HTTP、HTTPS、Websocket的请求、响应，也可以作为HTTP代理服务器使用。

# 有了charles为什么还用whistle
* whistle是开源的，安装也更简单。（安装：npm i -g whistle   启动：w2 start   操作：浏览器访问127.0.0.0:8899）
* 官方文档清晰、全面。 （[文档链接](http://wproxy.org/whistle/)）
* 代码式操作。(请求转发、编辑等都是以代码行的形式进行，相比较于charles这种图形化操作，效率更高，更灵活)
* 默认集成vconsole、weinre等调试功能。（例如vconsole这种客户端控制台日志打印功能都默认集成，而且是在PC的控制台显示客户端日志）

# 安装启动
[安装启动、代理配置移步官方文档](http://wproxy.org/whistle/install.html)

# 常用功能

## hosts配置
  提供类似switchhosts的修改域名解析的功能，并且可以做到单独对浏览器生效或本机全局生效，无需刷新dns缓存。
  更强大的是他支持同一个域名下的不同链接解析到不同的ip、支持正则匹配、支持端口转发等等。
    
    以下规则在whistle rules窗口下添加：
    
    127.0.0.1 a.meituan.com             # a.meituan.com下的请求代理到本机
    192.168.191.1 b.meituan.com/list/   # b.meituan.com下list路径的请求代理到192.168.191.1
    192.168.191.2 b.meituan.com         # b.meituan.com下的其余请求代理到192.168.191.2
    d.metuan.com e.meituan.com          # d.metuan.com的请求转发到e.meituan.com
    127.0.0.1:8080 f.meituan.comn       # f.meituan.comn的请求转发到本地8080端口
    192.168.191.3 /./                   # 除以上规则匹配到的请求以外，其他请求均代理到192.168.191.3
    
  注：更高级别的规则放在前面 否则不会执行 如b.meituan.com/list/需放在b.meituan.com前面。

## https转http
  很多客户端强制要求页面是https，这样连带着所有请求也都是https了，本地调试不方便，可以把https转为http。
    
  1. 解析https请求 请看[官方文档](http://wproxy.org/whistle/webui/https.html)。
  2. 按照以上操作执行后，whistle可以解析https了，然后只需在rules窗口下添加以下规则，则请求便由https转为http了。
    
    
## 客户端日志/错误打印
  我们一般本地调试时，想看H5页面运行在客户端的日志或者报错，只能用charles代理，然后alert或者程序中加vconsole在手机上看。
  有了whistle这两步就可以合在一起，并且在电脑上看日志了。
    
  (1）在whistle rules窗口下添加以下规则:
    
    127.0.0.1 a.meituan.com             # a.meituan.com下的请求代理到本机
    a.meituan.com log://test            # a.meituan.com下的consolelog打印  ://后面的名字随便起 这只是一个标识
    
  (2）在network窗口右侧的tools下的Console窗口可查看客户端的console.log打印以及异常报错。
<img src="https://p0.meituan.net/spacex/cf8ab4025831138fb87ff953d0fca060.png" />
    
  注：whistle也整合了weinre远程调试的功能，可以直接看[官方文档](http://wproxy.org/whistle/webui/weinre.html)。

## 延迟、限速
  这两个功能做功能测试以及性能优化时经常用。
    
    在whistle rules窗口下添加以下规则：
    
    a.meituan.com/js/ resSpeed://1000     # 限速 kb/s
    /./ resDelay://3000                   # 延迟 3秒

## 修改响应内容
  在mock数据或者本地调试时，我们经常要将线上文件替换为本地文件，或者对接口的响应内容做修改。
    
    在whistle rules窗口下添加以下规则：
    
    a.meituan.com/home/ file:///Users/xxx/Desktop/test.html             #替换页面
    a.meituan.com/unify.min.js file:///Users/xxx/Desktop/test.js        #替换js
    a.meituan.com/api/list resBody://{myRes}                            #替换响应内容 myRes为自定义变量 可以紧跟规则在下面用```定义 也可在Values窗口内定义
    `` ` myRes
        {"code":200,"data":{"list":[]},"message":"请求成功","status":1}
    `` `
  注：因为不能转义 所以把```中间加了个空格 实际操作时应该是连续的。

## 修改响应头
  有时我们需要修改响应头，比如cors跨域头。
    
    在whistle rules窗口下添加以下规则：
    
    a.meituan.com/api/list resHeaders://{myRes1}
    `` ` myRes1
        Access-Control-Allow-Origin: https://a.meituan.com
    `` `
  注：因为不能转义 所以把```中间加了个空格 实际操作时应该是连续的。

## 修改请求参数
  测试环境有时我们没法通过代码修改入参，我们可以通过代理修改。
    
    在whistle rules窗口下添加以下规则：
    
    a.meituan.com/api/list reqMerge://(name=test&brand=nokia)

## 修改请求头
  referer、origin、ua这些请求头我们都可以修改。
    
    在whistle rules窗口下添加以下规则：
        
    a.meituan.com/api/list reqHeaders://{myReq}
    `` ` myReq
        referer: b.meituan.com
        origin: http://b.meituan.com
    `` `
  注：因为不能转义 所以把```中间加了个空格 实际操作时应该是连续的。    

## 通过js代码动态获取请求/响应内容 编辑请求/响应
  有很多情况我们的响应不是固定的，而是根据请求参数动态变化的，whistle同样可以帮我们做到。
  whistle内置了一些全局变量，我们可以获取链接参数，动态生成一条rule，然后push到whislte规则中。
  这是最灵活，最全面的，理论上我们掌握这一种就可以实现上述所有功能。
    
    在whistle rules窗口下添加以下规则：

    a.meituan.com/api/list resScript://{myScript}
    `` ` myScript
        const queryMap = parseQuery(parseUrl(url).query);
        const res = {
            "code": queryMap.isLogin ? 200 : 400,
            "data": {}
        };
        console.log(res);
        values.myScript_res = res;
        rules.push(`${url} resBody://{myScript_res}}`);
    `` `
  注：因为不能转义 所以把```中间加了个空格 实际操作时应该是连续的。
  注：上述js的控制台打印可在（network - tools - Server）看到，这也就让我们拥有了调试能力。
<img src="https://p0.meituan.net/spacex/dd06637b80edc0164ff4ecba04a6978b.png"  width="800px" />
 
 ## 页面注入js/css
  直接往线上注入我们本地的js/css。
    
    在whistle rules窗口下添加以下规则：
    
    a.meituan.com js:///Users/xxx/Desktop/test.js         #追加js
    a.meituan.com css:///Users/xxx/Desktop/test.css       #追加css

# 其他小点

## 本地ip查看
<img src="https://p0.meituan.net/spacex/a8824c1f6ad4ca1b2ad604d62eb41bd4.png" />

## 过滤
<img src="https://p0.meituan.net/spacex/912beee28fecf0c003d2f11524897072.png" />

## Rules窗口、Values窗口
<img src="https://p0.meituan.net/spacex/2b39a1e37ea763d111805cdcd7123880.png" />
