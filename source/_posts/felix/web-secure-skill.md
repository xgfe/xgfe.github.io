title: Web安全技术
date: 2016-11-28 21:47:00
categories: felix
tags:
- XSS
- CSRF
---


<iframe src="//slides.com/xgfe/deck-5/embed" width="576" height="420" scrolling="no" frameborder="0" webkitallowfullscreen mozallowfullscreen allowfullscreen></iframe>
<!--more-->

## XSS

Cross Site Scripting, 跨站脚本

跨站脚本发生在目标网站中目标用户的**浏览器**层面上，当用户浏览器渲染整个HTML文档的过程中出现了**不被预期的**脚本指令并执行，XSS就会发生。

想尽一切办法将你的脚本内容在目标网站中目标用户的浏览器上解析执行即可。

### 类型
#### 反射型XSS（非持久型XSS）

发出请求时，XSS代码出现在URL中作为输入提交到服务端，服务端解析后响应，在响应内容中出现这段XSS代码，最后浏览器解析执行。

1. 服务端输出HTML
2. 服务端输出为Location字段

#### 存储型XSS（持久型XSS）

提交的XSS代码会存储在服务端（留言板）

#### DOM XSS

不需要服务端参与，靠浏览器端的DOM解析触发

### 危害

1. 挂马
2. 盗取用户Cookie
3. Dos（拒绝服务）客户端浏览器
4. 钓鱼攻击
5. 编写正对性的CSS病毒，删除目标文章、恶意篡改数据
6. 劫持用户Web行为
7. 爆发Web 2.0蠕虫


## CSRF

Cross Site Request Forgery, 跨站请求伪造

伪造：如果请求的发出不是用户的意愿，那么这个请求就是伪造的

### 类型

#### HTML CSRF攻击

发起的CSRF请求都属于HTML元素发起的。

HTML中能够设置src/href等链接地址的标签都可以发起GET请求。
eg. link, img, meta, iframe, script, bgsound, embed, video, audio, a, table[background], @import "", background: url("")

#### JSON HiJacking攻击

## 界面操作劫持

一种基于视觉欺骗的Web会话劫持攻击，它通过在网页的可见输入控件上覆盖一个不可见的框(iframe)，使得用户误以为在操作可见控件，而实际上用户的操作行为被其不可见的框所劫持，执行不可见框中的恶意劫持代码，从而完成在用户不知情的情况下窃取敏感信息、篡改数据等攻击。

技术发展阶段分类：点击劫持、拖放劫持、触屏劫持

## 漏洞挖掘

### CSRF的漏洞挖掘

1. 确认目标表单是否有有效的token随机串
2. 目标表单是否有验证码
3. 目标是否判断了Referer来源
4. 网站根目录下crossdomain.xml的“allow-access-from domain”是否是通配符
5. 目标JSON数据似乎可以自定义callback函数

### 界面操作劫持的漏洞挖掘

1. 目标的HTTP响应头是否设置好了X-Frame-Options字段
2. 目标是否有JavaScript的Frame Busting机制
3. 即目标网站能不能被iframe嵌入

### 普通XSS漏洞自动化挖掘

1. 探子请求，确定反射位置
2. 构造攻击

### 存储型XSS漏洞挖掘

重点在于如何确定输出点

1. 表单提交后跳转页面有可能是输出点
2. 表单所在页面有可能是输出点
3. 全站查找，可先缓存页面，然后根据Last-Modified和Etag头部判断

### 编解码(DOM XSS挖掘预备知识)

#### HTML形式编码

以下HTML形式的编码会在HTML中自动解码。

1. 进制编码: &#xH; (十六进制格式)、&#D; (十进制格式)
2. HTML实体编码: &lt; &gt; &quot; &amp; &nbsp;

#### CSS 属性中的编码

1. 兼容HTML形式编码
2. 十六进制还可以使用\H的形式. eg. \6c

#### Javascript编码

在Javascript执行之前，以下Javascript形式的编码会自动解码。

1. Unicode形式: \uH(十六进制)
2. 普通十六进制: \xH
3. 纯转义: \' \" \< \>

#### 具备HtmlEncode功能的标签

textarea, title, iframe, noscript, noframes, xmp, plaintext

### DOM XSS挖掘

#### 静态方法

[入点和输出点匹配正则表达式] (http://code.google.com/p/domxsswiki/wiki/FindingDOMXSS)

发现可疑点后需要人工分析。

#### 动态方法

模糊测试所有输入点提交标志位，然后全文档监测标志位是否出现

### Flash XSS 挖掘

#### 静态分析

工具反编译

### 字符集缺陷导致的XSS

1. 宽字节编码带来的安全问题 P.160

GBK、GB2312


## 代码注入技巧

* [HTML5 XSS Attack Vectors](https://github.com/cure53/H5SC)
* [SHARED ONLINE FUZZING](shazzer.co.uk/vectors)

## 漏洞利用

### 获取隐私数据

Cookie, browser, ua, Referer...

1. Referer暴露Token
2. 获取浏览器记住的明文密码
3. 键盘记录器
4. 开启路由远程访问能力
4. 劫持保持：window.open()拦截link跳转，操作新窗口添加劫持脚本


## Web蠕虫

### 类型

1. XSS蠕虫
2. CSRF蠕虫
3. Clickjacking蠕虫

### 蠕虫性质

1. 传播性: Web层面上就是基于HTTP请求传播
2. 病毒行为: 会进行一些恶意操作。Web层面主要是通过Javascript脚本发起各种恶意的HTTP请求。

### XSS蠕虫的条件

1. 目标网站具备Web 2.0的关键特性：内容由用户驱动(UGC)
2. 存在XSS漏洞
3. 被感染的用户是登录状态，这样XSS的权限就是登录后的权限，能执行更多的恶意操作
4. XSS蠕虫传播利用的关键功能本身具备内容传播性


## 防御

### 浏览器厂商的防御

1. HTTP响应的X-头部. HTTP响应的扩展头部字段都以X-打头，区分标准的头部字段

    * X-Frame-Options: 防御ClickJacking
        * ==DENY==: 禁止被加载进任何frame
        * ==SAMEORIGIN==: 仅允许被加载进同yu'nei同域内的frame
        * ==ALLOW-FROM uri==: 不允许被指定的域名以外的页面嵌入(Chrome不支持)
    * X-XSS-Protection: 防御反射型XSS
        * ==0==: 禁用这个策略
        * ==1==: 默认值，对危险脚本做一些标志或修改，以阻止在浏览器上渲染执行
        * ==1;mode=block==: 强制不渲染，在Chrome下直接跳转到空白页，在IE下返回一个#符号
    * Content-Security-Policy: ([CSP](http://www.w3.org/TR/CSP))
        ![](http://p1.meituan.net/dpnewvc/14a8bd5f9ddbc7d0ca9548c2bdfdf92e66222.png)

        * [指令1] [指令值1] [指令值2]; ...
        * 指令: default-src, script-src, style-src, img-src, connect-src, font-src, object-src, media-scr, frame-src, sandbox-src, report-uri
        * 指令值:
            ![](http://p1.meituan.net/dpnewvc/944dae0fc2cd1cfd936f327976410dd5230483.png)
        * 不特别指定 'unsafe-inline' 时，页面上所有 inline 样式和脚本都不会执行；不特别指定 'unsafe-eval'，页面上不允许使用 new Function，setTimeout，eval 等方式执行动态代码
        * 担心影响面太大，也可以像下面这样，仅收集不匹配规则的日志，可以设置`Content-Security-Policy-Report-Only`先观察下：
            ```
            Content-Security-Policy-Report-Only: script-src 'self'; report-uri http://test/
            ```
    * Strict-Transport-Security

        * HTTP Strict Transport Security，简称为HSTS. 它允许一个HTTPS网站，要求浏览器总是通过HTTPS来访问它，**浏览器端重定向**

            ```
            strict-transport-security: max-age=16070400; includeSubDomains
            ```
        * Chrome内置了一个[HSTS列表](chrome://net-internals/#hsts), 可以增删改查
    * X-Content-Type-Options：禁用浏览器的类型猜测行为

        ```
        X-Content-Type-Options: nosniff
        ```

### Web厂商的防御

1. 域分离
2. 安全传输，HTTPS
3. 安全的Cookie, HttpOnly、Secure
4. 验证码
5. 慎防第三方内容
6. XSS防御方案 OWASP的ESAPI

### 工具汇总

1. [编解码工具](http://monyer.com/demo/monyerjs/)
2. [Hydra](https://github.com/addthis/hydra)
3. [BeFE](https://github.com/beefproject/beef)渗透探索工具
4. Metasploit
5. EditThisCookie

## 参考文献

1. 《Web前端黑客技术揭秘》
2. [Content Security Policy 介绍](https://imququ.com/post/content-security-policy-reference.html)
3. [一些安全相关的HTTP响应头](https://imququ.com/post/web-security-and-response-header.htm)
3. [我的渗透利器-余弦](http://evilcos.me/?p=336)
4. [零基础如何学习 Web 安全？-知乎](https://www.zhihu.com/question/21606800)