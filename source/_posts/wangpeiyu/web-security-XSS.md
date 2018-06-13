title: Web前端安全科普之XSS
date: 2018-06-13 11:00:00
categories: wangpeiyu
tags:
- Web安全
- 前端安全
- XSS
---
Web前端的安全主要有三类：XSS、CSRF、界面操作劫持。

XSS（Cross Site Scripting），即跨站脚本攻击，是一种代码注入攻击，恶意攻击者往Web页面里插入恶意Script代码，当用户浏览该页之时，嵌入其中的Script代码会被执行，从而达到恶意攻击用户的目的。

CSRF（Cross Site Request Forgery），即跨站请求伪造，通过伪装来自受信任用户的请求来利用受信任的网站。

界面劫持操作是一种基于视觉欺骗的Web会话劫持攻击，包括点击劫持、拖放劫持和触屏劫持三种类型。

在OWASP TOP 10中，XSS一直都是名列前茅，有了XSS漏洞，就意味着可以注入任意的JavaScript，被攻击者的任意操作都可以进行模拟，任何隐私信息都可以获取到。基于上述背景，本文将对XSS攻击的原理、类型及防御进行介绍。


<!--more-->

## XSS原理

跨站脚本的重点在脚本上，绝大多数的XSS会采用一段远程或者第三方域上的脚本资源，这样做的好处是攻击代码容易控制。script标签可以嵌入第三方资源，这是浏览器允许的，对于嵌入的脚本内容，会与本域的脚本内容一样，在整个脚本上下文环境中存在，那么在这个场景中的各种功能都可以由嵌入的脚本实现，也就是说JavaScript能做到什么效果，XSS的威力就有多大。

JavaScript可以用用来获取的Cookie、改变网页内容、URL调转，那么存在XSS漏洞的网站，就可以盗取用户Cookie、黑掉页面、导航到恶意网站，而攻击者需要做的仅仅是向Web页面中注入JavaScript代码。

XSS攻击原理主要包括三个部分：

- 攻击者对某含有漏洞的服务器发起XSS攻击（注入JS代码）

- 诱使受害者打开受到攻击的服务器URL（邮件、留言等，此步骤可选项）

- 受害者在Web浏览器中打开URL，恶意脚本执行

XSS构造的例子：

    ```
           // 目标网站在服务端将用户输入内容直接拼接到返回 HTML 里
           res.body = '...<div>' + data.用户输入的内容 + '</div>...'

           // 攻击者在页面中提交了这样的内容：
           <script>alert(123)</script>
    ```

    ```
           // 目标网站在服务端将用户输入的内容直接拼接到了页面元素的属性中
           res.body = '...<img src=" + data.用户输入的图片地址 + ">...'

           // 攻击者在页面中提交了这样的内容：
           " /><script>alert(123)</script>
    ```

    ```
           // 目标网站在页面中将通过 AJAX 取得的用户输入的内容填到页面中
           div.innerHTML = data.用户输入的内容

           // 不同于直接拼接，innerHTML 中的 script 标签不会被执行，但是攻击者可以这么写：
           <img src="x.png" onload="alert(123)">
    ```

    ```
           // 目标网站在页面中将通过 AJAX 取得的用户输入的内容填到页面元素的属性中
           a.href = data.用户输入的链接

           // 不同于直接拼接，给元素的属性赋值时内容总会被当成字符串，但是攻击者可以这么写，如用户点了链接就会受到攻击：
           javascript:alert(123)
    ```

## XSS类型

XSS有三种类型，分别是反射型XSS、存储型XSS、DOM XSS，下面分别对这三种XSS进行介绍。

### 反射型XSS

反射型XSS也被称为非持久性XSS，是最容易出现的一种XSS漏洞，指的是发送请求时，XSS代码出现在URL中，作为输入提交到服务端，服务端解析后响应，在响应内容中出现这段XSS代码，最后被浏览器解析执行。这个过程就像是一次反射，故称为反射型XSS。它的数据流向是：浏览器 -> 后端 -> 浏览器。

```
    // 服务端代码
    <?php
        echo $_GET['x'];
    ?>

    // 在浏览器地址栏中输入
    http://xssdemo.wpy.com/domxss.html#alert(1)
```

![反射型XSS](http://vfile.meituan.net/xgfe/a7271f75b155dbab2e0c3fb758cbe111100565.png)

### 存储型XSS

存储型XSS又被称为永久性XSS，是最危险的一种跨站脚本，指的是发送请求时，提交的XSS代码会存储在服务端（不管是数据库、内存还是文件系统），下次请求目标页面时不用再提交XSS代码，存储型XSS的攻击是最隐蔽的，其危害性也更大。与反射型XSS和DOM XSS相比，存储型XSS的执行不需要手动触发。最典型的例子是留言板XSS，用户提交一条包含XSS代码的留言存储到数据库，目标用户查看留言板时，那些留言的内容就会从数据库查询出来并显示，浏览器发现有XSS代码，就当做正常的HTML与JS解析执行，于是就触发了XSS攻击。它的数据流向是：浏览器 -> 后端 -> 数据库 -> 后端 -> 浏览器

### DOM XSS

DOM XSS指的是XSS代码并不需要服务器解析响应的直接参与，触发XSS靠的就是浏览器端的DOM解析，可以认为完全是客户端的事情。它的数据流向是：URL->浏览器

```
        // 客户端的脚本
        <script>eval(location.hash.substr(1));</script>

        // 用户点击这个URL#后的内容不会发送到服务端，仅在客户端被接收并解释执行。
        http://xssdemo.wpy.com/domxss.html#alert(1)
```

![DOM XSS](http://vfile.meituan.net/xgfe/919bcf853c27bbd16656cfa83b8b6ef887889.png)

#### DOM XSS场景一：在前端实现页面跳转

在前端实现页面跳转，前端通常会通过JavaScript实现跳转，最常用到的方法有: location.href / location.replace() / location.assign()。 在该场景下，可以通过伪协议“javascript:”、“data:”在浏览器下执行脚本。但是这种通过伪协议进行攻击已经随着前端工程处理对相关跳转代码逻辑做了很好的完善，基本上不会再出现上述的这种情况。但是如下两种情况却为web攻击打开了天窗：

- 使用indexOf判断URL参数是否合法，indexOf() 方法可返回某个指定的字符串值在字符串中首次出现的位置。该方法将从头到尾地检索字符串 stringObject，看它是否含有子串 searchvalue。所以如果url中包含了伪代码及攻击代码，就会被攻击。

- 正则表达式判断URL是否合法，为了避免使用indexOf判断URL带来的缺陷，有些开发人员会想到用正则表达式，但忘了一个神奇的符号“^”，加上和不加上，过滤的效果具有天壤之别，如果没有加“^”，攻击者仍然可以绕过正则的过滤，在URL中植入伪代码和攻击代码。

- 修复方案：在前端实现页面跳转业务场景下，正确的过滤实现方法是，严格限制跳转范围。一方面要限制能够跳转页面的协议：只能是http、https或是其他指可控协议；另一方面，要严格限制跳转的范围，如果业务只要跳转到指定的几个页面，可以直接从数组中取值判断是否这几个页面，如果跳转范围稍大，正确使用正则表达式将跳转URL严格限制到可控范围内。 

#### DOM XSS场景二：取值写入页面或动态执行 

除接收URL参数经后端处理最后在前端展示外，在Web前端通过JavaScript获取不同来源的参数值，不经后端处理即刻在Web页面进行展示或动态执行的业务场景也十分常见，想要在客户端实现接受参数并写入页面或动态执行，就不得不用到innerHTML、document.write、eval。因为JavaScript取值的来源纷繁复杂，如果忘记做转义处理，或过分相信取值来源的数据，直接将分离出的参数值交给JavaScriptinnerHTML、document.write、eval处理，就有可能招来DOM-XSS。下面是三种常见的缺陷： 

- 从URL中的取参数值写入页面或动态执行，如直接从URL的锚参数（即位于#后面的参数）中取值，不经过任何处理直接innerHTML写入页面，导致攻击者只需要构造如下URL即可完成一次DOM XSS攻击。由于整个攻击过程在客户端侧完成，不需要向服务器发送任何请求数据，所以即便业务接入了对抗反射型XSS的Web应用防火墙（WAF），这类DOM XSS也无法被感知，攻击者便可畅通无阻的利用漏洞对用户开展攻击。 

- 从Cookie中的取参数值写入页面或动态执行，原理基本同从URL中的取参数值写入页面或动态执行，只是换了一个取值来源而已。

- 从localStorage、Referer、Window name、SessionStorage中的取参数值写入页面或动态执行 ，如取window.name的值，最后直接innerHTML到页面中。一般情况下，页面的window.name攻击者不可控，故往往会被认为来源相对可信。但借助iframe的name属性，攻击者可以将页面的window.name设置为攻击代码，仍然可以构造DOM XSS。

- 修复方案：

    - 写入页面前先转义。在取值写入页面或动态执行的业务场景下，在将各种来源获取到的参数值传入JavaScript“三姐妹”函数（innerHTML、document.write、eval）处理前，对传入数据中的HTML特殊字符进行转义处理能防止大部分DOM-XSS的产生。此外，根据不同业务的真实情况，还应使用正则表达式，针对传入的数据做更严格的过滤限制，才能保证万无一失。 

    - 慎用危险的“eval”。需要强调的是，由于JavaScript中的eval函数十分灵活，能够支持执行的字符串编码纷繁复杂。强烈建议，不到万不得已，不要使用eval函数处理不可控的外部数据。 

    - 编写安全的函数方法，从看似“可靠”的数据源获取参数值。无论是从cookie，还是从localStorage、Referer、Window name、SessionStorage中获取数据，都应使用安全的函数，对传入的数据做过滤后，再传递给相关函数写入页面或执行。 

## XSS危害

- 盗取用户的Cookie，cookie经常被用来存储用户的会话信息，比如用户登录认证后的session，之后同域内发出的请求都会自动带上认证后的会话信息。如果Cookie被盗取，攻击者就可以不用通过密码而直接登录用户的账户。Cookie的重要字段：[name] [value] [domain] [path] [expires] [httponly] [secure]，其含义依次是：名称、值、所属域名、所属相对根路径、过期时间、是否有HttpOnly标志、是否有Secure标志。如果设置了HttpOnly标志，客户端脚本就无法通过document.cookie获取该cookie，这样就能有效地防御XSS攻击获取Cookie。

- 构建Get和Post请求，如果cookie设置了HttpOnly标志，则无法直接劫持cookie来使用了，但是XSS可以在javascript中构建get或者post请求，来实现自己的攻击。只要让用户执行下面这段脚本，就能发起get请求，攻击者通过XSS诱导用户来执行。XSS的攻击过程都是在浏览器通过执行javascript脚本自动进行，缺少与用户交互的过程。例如在POST的请求中，如果需要输入验证码，Js代码无法解析验证码，攻击也就无法实现。但是针对验证码这种情况，如果XSS可以通过把验证码的图片发到远端攻击服务器，服务器解析验证码然后把结果返回给js代码，js获取后继续进行攻击，不过就是成本有点高。

- XSS钓鱼：上面模拟用户的POST请求貌似成本有点高，攻击者可以将XSS和钓鱼结合在一起，例如通过javascript代码模拟出网站的登录框，用户输入用户名和密码后，XSS将这些信息发送到服务器端，用来进行攻击。

- 获取用户系统信息，此外XSS还可以识别用户的浏览器信息、用户安装的软件以及用户真实的IP等信息。

- XSS Wrom：这是XSS的一种终极利用方式，破坏力和影响力是巨大的，与蠕虫病毒一样具有“传染性”，与系统病毒的唯一区别就是无法对系统底层操作。XSS蠕虫是针对浏览器的攻击，网站规模越大，攻击效果就越大。一般来说，用户直接发生交互行为的页面，如果存在存储型XSS，则比较容易发起Wrom攻击。

## XSS防御

- 任何由用户输出的数据都是不可信的

- 不要在奇怪的地方插入不可信的数据

  ![不可信数据](http://vfile.meituan.net/xgfe/0a853e1b33a7dfaeb4aa47f12453026b97763.png)

- 进行输入输出检查，将期望被当成字符串的不可信数据转义后再插入文档中，不同位置需要使用不同的转义逻辑。

  ![输入输出检查](http://vfile.meituan.net/xgfe/3df441ed85fa308c54a059924acd16e0248873.png)

- 将期望被当成 HTML 的不可信数据使用专业的库消毒后再插入文档中

- 使用 HTTPOnly 的 cookie，给关键的Cookie设置HttpOnly属性，这样能够避免js读取Cookie信息，设置后有助于缓解XSS，但是XSS除了劫持Cookie之外，还可以模拟用户的身份进行操作。

- 使用内容安全策略（CSP）是对抗XSS的深度防御策略，内容安全策略可以以白名单的方式限定哪些地方的内容可以被加载和执行，如果不存在可以通过本地文件放置恶意代码的其他漏洞，则该策略是有 效的。

- 使用设计上就会自动编码来解决XSS问题的框架，如：React JS。了解每个框架的XSS保护的局限性，并适当地处理未覆盖的用例。

## 参考资料

- XSS攻击手册：https://www.owasp.org/index.php/XSS_Filter_Evasion_Cheat_Sheet

- XSS防御手册：https://www.owasp.org/index.php/XSS_(Cross_Site_Scripting)_Prevention_Cheat_Sheet

- 《Web前端黑客技术揭秘》

- 《Web安全深度剖析》

- 《白帽子讲Web安全》

- https://security.tencent.com/index.php/blog/msg/107

## 相关链接

- http://vfile.meituan.net/xgfe/a7271f75b155dbab2e0c3fb758cbe111100565.png

- http://vfile.meituan.net/xgfe/919bcf853c27bbd16656cfa83b8b6ef887889.png

- http://vfile.meituan.net/xgfe/0a853e1b33a7dfaeb4aa47f12453026b97763.png

- http://vfile.meituan.net/xgfe/3df441ed85fa308c54a059924acd16e0248873.png