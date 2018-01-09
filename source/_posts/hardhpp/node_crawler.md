title: Node学习系列(1) -- Node实现爬虫
date: 2018.1.5
categories: hardhpp
tags:
- Node
- 爬虫
---



Node学习系列(1) -- 使用Node实现爬虫，介绍了如何实现一个简单的爬虫程序、多页面的爬虫程序、如何保存爬虫的结果等内容。

<!-- more -->

**前提**：已安装Node.js和npm   
**开发环境**：推荐Visual Studio Code   
**使用到的模块**：http cheerio fs (说明：Node中的原生模块之外的其他模块，需要使用`npm install <package>`进行安装)

**blog背景**：现在需要获取xgfe博客(http://xgfe.github.io/) 中所有博客的相关数据，数据包括：博客的题目、链接地址、创建时间、作者以及关键字。

## Step1：确定要爬取的网页

在开始爬虫程序开始之前，我们应该先明确需要爬取的网页以及内容。  

本文要爬取的网页是：http://xgfe.github.io/   

爬取网页全部数据，程序如下：  

```
// app01.js
var http = require('http')
var url = 'http://xgfe.github.io/'

http.get(url,function(res){
    var html = '';

    res.on('data',function(data){
        html+=data;
    })

    res.on('end',function(){
        console.log(html);
    })
}).on('error',function(){
    console.log('获取数据出错');
})
```

运行结果：输出网页的源代码（图略）  
本步骤获取到页面的所有信息，为之后获取指定信息做铺垫。

### http模块简单介绍  

http模块是Node中的原生模块，该部分在Node进程启动时，就被直接加载进内存中，不需要再次安装。   
Node的http模块包含对HTTP处理的封装。http服务继承自TCP服务器，能够与多个客户端保持连接，采用事件驱动的形式，低内存占用，高并发。   

引入http模块： `require('http')`

* HTTP服务器

	```
	// http_createServer.js
	var http = require('http');
	
	http.createServer(function(req, res){
	    res.writeHead(200, {'Content-type' : 'text/html'});
	    res.write('<h1>Node</h1>');
	    res.end('<p>Hello World</p>');
	}).listen(3000);
	```
	运行代码，在浏览器访问http://localhost:300
* HTTP客户端(http模块提供了两个函数http.request和http.get，功能是客户端向服务器端发送请求)
	1. http.request(options,callback)用于发起http请求，接收两个参数，options是一个类似关联数组的对象，里面包含一些请求的参数，callback表示请求后的回调。

		```
// http_request.js
var http = require('http')
var querystring = require('querystring')   // querystring模块需要使用npm安装

var postData = querystring.stringify({
    'msg': Hello World!'
 });
  
var options = {
    hostname: 'www.baidu.com',
    port: null,
    path: '/',
    method: 'POST',
    headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Content-Length': Buffer.byteLength(postData)
    }
};		

var req = http.request(options, function (res) {
    var html = ''

    console.log('状态码:' + res.statusCode);
    console.log('头部信息:' + JSON.stringify(res.headers));
    res.setEncoding('utf8');
    res.on('data', function (chunk) {
        html += chunk;
    })
    res.on('end', function () {
        console.log(html);
    });
}).on('error', function (e) {
   	console.error('请求出错了！');	
});
  
// write data to request body
req.write(postData);
req.end();
```
	2. http.get(options,callback)，用来更简单的处理GET方式的请求，它是http.request的简化版本，唯一的区别在于http.get自动将请求方法设为GET请求，同时不需要手动调用req.end()。

		```
// http_get.js
var http = require('http')
	
http.get('http://www.baidu.com',function (res) {
    var html = '';
    
    console.log('状态码:' + res.statusCode);
    res.on('data', function (data) {
        html += data
    })
    res.on('end', function (){
        console.log(html)
    })
}).on('error', function () {
    console.log('获取数据出错')
}
```


## Step2：分析网页结构，确定数据的结构
分析网页结构如下：

![](https://github.com/hardhpp/Node/blob/master/crawler/picture/picture1.png?raw=true)

可以看出，图中方框内显示的数据，是最终应该获取的数据。


### 数据格式

根据最终的需求以及网页的结构，我们可以定义数据结构如下：

```
[{
    blogTitle: blogTitle,       // 博客名称
    blogHref: blogHref,         // 博客链接
    blogTime: blogTime,	         // 博客创建时间
    blogAuthor: blogAuthor,     // 博客作者
    blogKeywords: [],           // 博客关键词
    blogAbstract: blogAbstract  // 博客简介
}]
```

xgfe博客的数据与页面的对应如下：

![](https://github.com/hardhpp/Node/blob/master/crawler/picture/picture2.png?raw=true)


引入chreeio模块(chreeio模块需要使用`npm`进行安装)，使得可以更方便的访问html的结点，方便查找所需数据。  

```
// app02.js
var http = require('http')
var cheerio = require('cheerio')
var url = 'http://xgfe.github.io/'

var urlArr = url.split('')
urlArr.splice(-1)
var rootUrl = urlArr.join('')

var index =0 

// 获取内容
function filterBlogInfo(html) {

    var $ = cheerio.load(html)
    var blogContent = $('#content .post')
    var blogInfo =  []
    var root

    blogContent.each(function (index,item) {
        var blogItemHeader = $(this).find('.post-header')
        var blogItemBody = $(this).find('.post-body')
        var blogArticleInfo = {}
        var blogTitle = blogItemHeader.find('.post-title-link').text().trim()
        var blogHref = rootUrl + blogItemHeader.find('.post-title-link').attr('href')
        var blogTime = blogItemHeader.find('.post-time time').text().trim()
        var blogAuthor = blogItemHeader.find('.post-category a').text().trim()
        var blogKeywords = []
        blogItemHeader.find('.post-tags a').each(function (tagItem) {
            blogKeywords.push($(this).text().trim())
        })
        var blogAbstract = blogItemBody.find('p').text().trim()

        blogArticleInfo.blogTitle = blogTitle
        blogArticleInfo.blogHref = blogHref
        blogArticleInfo.blogTime = blogTime
        blogArticleInfo.blogAuthor = blogAuthor
        blogArticleInfo.blogKeywords = blogKeywords
        blogArticleInfo.blogAbstract = blogAbstract

        blogInfo.push(blogArticleInfo)
    })

    return blogInfo
}

// 打印数据
function printBlogInfo (blogInfo) {

    blogInfo.forEach(function (item) {
        console.log(index++)
        console.log('题目： ' + item.blogTitle)
        console.log('链接： ' + item.blogHref)
        console.log('时间： ' + item.blogTime)
        console.log('作者： ' + item.blogAuthor)
        console.log('关键字： ')
        item.blogKeywords.forEach( function (tagItem) {
            console.log(tagItem)
        })
        console.log("简介： " + item.blogAbstract +'\n')
    })
}

// 获取网页源代码
http.get(url,function(res){
    var html = '';

    res.on('data',function(data){
        html+=data;
    })

    res.on('end',function(){
        var data = filterBlogInfo(html)
        printBlogInfo(data)
    })
}).on('error',function(){
    console.log('获取数据出错');
})
```

运行结果如图：   
![](https://github.com/hardhpp/Node/blob/master/crawler/picture/picture3.png?raw=true)

### cheerio模块简单介绍 

cheerio模块不是Node的原生模块，需要安装   
安装：`npm install cheerio`    

cheerio模块是为服务器特别定制的，快速、灵活、实施的jQuery核心实现。  
     
1. **相似的语法:** Cheerio 包括了 jQuery 核心的子集。Cheerio  从jQuery库中去除了所有 DOM不一致性和浏览器尴尬的部分，揭示了它真正优雅的API。
2. **闪电般的块:** Cheerio 工作在一个非常简单，一致的DOM模型之上。解析，操作，呈送都变得难以置信的高效。基础的端到端的基准测试显示Cheerio 大约比JSDOM快八倍(8x)。 
3. **巨灵活:** Cheerio 封装了兼容的htmlparser。Cheerio 几乎能够解析任何的 HTML 和 XML document。

使用：    
step1: 需要加载HTML    

```
var html = '<ul id="fruits">...</ul>'
var $ = cheerio.load(html)
```

step2: 使用选择器，选择需要处理的元素  `$(selectior,[context],[root])`

```
// 选择器在 Context 范围内搜索，Context又在Root范围内搜索
$('.apple', '#fruits')
// selector 和 context可以是一个字符串表达式
$('#fruits .apple')

// 使用find()
$('#fruits').find('.apple')
// 使用parent()
$('.apple').parent()
```

step3: 获得和修改相应的属性     

```
$('.apple', '#fruits').val([value])
$('#fruits .apple').text([textString])
$('#fruits .apple').attr(name,value)
$('#fruits .apple').addClass('.red')
```


## Step3：多页面爬虫

在Step2中，我们已经可以爬取最终所需要的数据，不过，现在爬取的数据仅仅是第一页的数据，我们还需要爬取其他页的数据。

现在，为了获取其他页面的数据，我们需要获取其他页面的url。

为此，我们可以分析页面：
![](https://github.com/hardhpp/Node/blob/master/crawler/picture/picture4.png?raw=true)

观察页面可得，我们可以通过拼接url，获取每个页面的url。

具体程序如下：

```
// app03.js
var http = require('http')
var cheerio = require('cheerio')
var url = 'http://xgfe.github.io/'

var urlArr = url.split('')
urlArr.splice(-1)
var rootUrl = urlArr.join('')

// 获取分页的url
function fetchPageUrl(html) {

    var $ = cheerio.load(html)
    var blogPageTotal = $('#content .pagination .page-number').eq(2)
    var blogPageHref = blogPageTotal.attr('href').split('')
    blogPageHref.splice(-2)
    var blogPageTotalNumber = parseInt(blogPageTotal.text()) 
    var pageUrl =  [url]

    for(var i=2; i <= blogPageTotalNumber; i++){
        pageUrl.push(rootUrl + blogPageHref.join('')+i+'/')
    }

    return pageUrl
}

// 打印数据
function printPageUrl(pageUrl) {

    pageUrl.forEach(function (item, index) {
        console.log(item)
    })
}

// 获取页面源代码
http.get(url,function(res){
    var html = '';

    res.on('data',function(data){
        html+=data;
    })

    res.on('end',function(){
        var data = fetchPageUrl(html)
        printPageUrl(data)
    })
}).on('error',function(){
    console.log('获取数据出错');
})

```

运行结果：
![](https://github.com/hardhpp/Node/blob/master/crawler/picture/picture5.png?raw=true)

所以，在获取到所有的url之后，可以按照Step2进行获取数据。    
此时，**出现一个问题！**

我们需要访问完一个页面之后，再去访问另外一个，此时，需要用到回调，具体如下：

```
// 第一层：获取所有页面的url
http.get(url1,function(res){
    var html = '';

    res.on('data',function(data){
        html+=data;
    })

    res.on('end',function(){
        var data1 = filterPageUrl(html)
        printPageUrl(data1)
        
        // 第二层： 获取第一个页面的源代码并处理
        http.get(url2,function(res){
            var html = '';
        
            res.on('data',function(data){
                html+=data;
            })
            
            res.on('end',function(){
                var data2 = filterBlogInfo(html)
                printBlogInfo(data2)
                // 第三层： 获取第二个页面的源代码并处理
                http.get(url3,function(res){
                    var html = '';
                
                    res.on('data',function(data){
                        html+=data;
                    })
                    res.on('end',function(){
                        var data3 = filterBlogInfo(html)
                        printBlogInfo(data3)
                        
                        
                        // **** 此处省略了6次回调 ****
                        
                        
                    })
                }).on('error',function(){
                    console.log('获取数据出错');
                })
            })
        }).on('error',function(){
            console.log('获取数据出错');
        })
    })
}).on('error',function(){
    console.log('获取数据出错');
})
```
**问题：** 单纯的使用回调，会形成回调地狱，此时，我们应该采用其他的方式进行优化。

**解决方法：采用promise**

```
// app04.js
var http = require('http')
var cheerio = require('cheerio')
var url = 'http://xgfe.github.io/'

var urlArr = url.split('')
urlArr.splice(-1)
var rootUrl = urlArr.join('')

var index = 0

// 获取分页的url
function fetchPageUrl(html) {
    // 此处省略，与之前示例相同
}

// 获取内容
function filterBlogInfo(html) {
    // 此处省略，与之前示例相同
}

// 打印数据
function printBlogInfo (blogInfo) {
    // 此处省略，与之前示例相同
}

function getUrlAsync(url) {
    return new Promise(function (resolve, reject){
        console.log('正在爬取： ' + url)
        http.get(url, function(res){
            var html = ''
            res.on('data',function (data) {
                html += data
            })

            res.on('end',function (){
                resolve(html)
            })
        }).on('error', function () {
            reject(e)
            console.log('获取' + url + '页面数据出错!')
        })
    })
}

// 获取页面源代码
http.get(url,function(res){
    var html = '';

    res.on('data',function(data){
        html+=data;
    })

    res.on('end',function(){
        var URLs = fetchPageUrl(html)
        
        var fetchPageDataArray = []

        URLs.forEach(function (url) {
            fetchPageDataArray.push(getUrlAsync(url))
        })

        // 执行promise 
        Promise
            .all(fetchPageDataArray)
            .then(function (pages) {
                pages.forEach( function (pageItem){
                    printBlogInfo(filterBlogInfo(pageItem))
                })
            })
    })
}).on('error',function(){
    console.log('获取数据出错');
})

```

运行结果：与Step2相似，获取了全部的数据。（图略）

### promise简单介绍    
  
先来回顾一下promise的基本概念：

* promise只有三种状态，未完成，完成(fulfilled)和失败(rejected)。
* promise的状态可以由未完成转换成完成，或者未完成转换成失败。
* promise的状态转换只发生一次

方法：  
1.Promise.then 接受3个函数作为参数。前两个函数对应promise的两种状态fulfilled, rejected的回调函数。第三个函数用于处理进度信息。 

2.Promise.all 接收一个 promise对象的数组作为参数，当这个数组里的所有promise对象全部变为resolve或reject状态的时候，它才会去调用 .then 方法。

使用promise的好处：

* 链式处理，方便之后的代码维护
* 在Promise.all中进行并发处理，避免阻塞


## Step4：保存为文件

在Step3中，运行之后，会输出特别多的信息，这样，不仅不容易观察最终数据，也不利于后期的再处理（例如：哪个作者发表的文章最多、哪个类型的文章发表最多之类的统计）。所以，我们可以将最终输出的结果保存在文件中。

在node中，fs模块负责文件的操作。

现在，我们引入fs模块：

```
// app05.js
var http = require('http')
var cheerio = require('cheerio')
var fs = require('fs')
var url = 'http://xgfe.github.io/'

var urlArr = url.split('')
urlArr.splice(-1)
var rootUrl = urlArr.join('')

var index = 0
var dataStr = ""

// 获取分页的url
function fetchPageUrl(html) {
    // 此处省略，与之前示例相同
}

// 获取内容
function filterBlogInfo(html) {
    // 此处省略，与之前示例相同
}

// 打印数据
function printBlogInfo (blogInfo) {

    var blogInfoStr = ''
    blogInfo.forEach(function (item) {
        blogInfoStr += (index++) + '\n'
        blogInfoStr += '题目： ' + item.blogTitle + '\n'
        blogInfoStr += '链接： ' + item.blogHref + '\n'
        blogInfoStr += '时间： ' + item.blogTime + '\n'
        blogInfoStr += '作者： ' + item.blogAuthor + '\n'
        blogInfoStr += '关键字： '
        item.blogKeywords.forEach( function (tagItem) {
            blogInfoStr += tagItem + ' '
        })
        blogInfoStr += "\n简介：" + item.blogAbstract +'\n\n'
    })
    return blogInfoStr
}

function getUrlAsync(url) {
	// 此处省略，与之前示例相同
}

// 获取页面源代码
http.get(url,function(res){
    var html = '';

    res.on('data',function(data){
        html+=data;
    })

    res.on('end',function(){
        var URLs = fetchPageUrl(html)
        
        var fetchPageDataArray = []

        URLs.forEach(function (url) {
            fetchPageDataArray.push(getUrlAsync(url))
        })

        // 执行promise
        Promise
            .all(fetchPageDataArray)
            .then(function (pages) {
                pages.forEach( function (pageItem){
                    dataStr += printBlogInfo(filterBlogInfo(pageItem))
                })

                // 写入文件
                fs.writeFile('data.txt', dataStr, function (err) {
                    if (err) console.log('write error')
                    console.log('file saved!')
                })
            })
    })
}).on('error',function(){
    console.log('获取数据出错');
})

```

### fs模块简单介绍    

fs模块用于对系统文件及目录进行读写操作。

**读文件** 

1.异步读文件

```
var fs = require('fs')

fs.readFile('simple.txt', 'utf-8', function (err, data){ 
    if (err) {
        // 出错了
    } else {
        // 处理文件数据
    }
})
```
异步读取文件时，传入的回调函数接收两个参数。  
1) 当正常读取时，err参数为null，data参数为读取到的String;  
2) 当读取发生错误时，err参数代表一个错误对象，data为undefined。  
当读取二进制文件时，不传入文件编码，回调函数的data参数将返回一个Buffer对象。

**扩展：Buffer对象与String对象转换：**  
Buffer对象 -> String对象: `var str = buf.toString('utf-8')`    
String对象 -> Buffer对象: `var buf = Buffer.from(str, 'utf-8')`

2.同步读文件 

```
var fs = require('fs')
var data = fs.readFileSync('simple.txt', 'utf-8')
```

同步读文件时，读取到的数据被直接返回,需要使用**try...catch**捕获错误。 
 
```
try {
    var data = fs.readFileSync('simple.txt', 'utf-8')
} catch (err) {
    // 出错了
}
```

**写文件**  
1.异步写文件

```
var fs = require('fs')

var data = 'write something.'
fs.writeFile('output.txt', data, function (err){
    if (err) {
        // 出错了
    } else{
        // 写文件成功
    }
})
```
`writeFile()`的参数依次为文件名、数据和回调函数。  
如果传入的数据是String,默认按`UTF-8`编码写入文件；  
如果传入的参数是Buffer,则写入的是二进制文件。

2.同步写文件

```
var fs = require('fs')  

var data = 'write something again.'  
fs.writeFileSync('output.txt', data)
```

**获取文件信息**

Stats对象：包含文件或目录的详细信息，例如：文件大小、创建时间等信息。
Stats对象具有的属性和方法：  
`size                        // 文件大小`              
`birthtime                   // 文件的创建时间，Date对象`       
`mtime                       // 文件的修改时间，Date对象`           
`isFile()                    // 如果是文件返回true，否则返回false`           
`isDirectory()               // 如果是目录返回true，否则返回false`    
    
1.异步获取文件信息

```
var fs = require('fs')

fs.stat('simple.txt', function (err, stat) {
    if (err) {
        // 出错了
    } else {
        // 获取文件信息
    }
})
```
2.同步获取文件信息

```
var fs = require('fs')

var stat = fs.statSync('simple.txt')
```

**异步or同步**    
绝大部分需要再服务器运行期反复执行业务逻辑的代码，必须使用**异步代码**，避免同步代码在执行期间，服务器停止响应，因为JavaScript只有一个执行线程。  
服务器启动时如果需要读取配置文件，或结束时需要写入到状态文件时，可以使用**同步代码**，因为这些代码只在启动和结束时执行一次，不影响服务器正常运行时的异步执行。  

**从文件流读取文件**
**关于流**   
在Node.js中，流是一个对象，拥有以下事件：   
data事件 表示流的数据已经可以读取；     
end事件 表示这个流已经到末尾，没有数据可以读取；   
error事件 表示出错了

```
'use strict'

var fs = require('fs')

// 打开一个流
var rs = fs.createReadStream('sample.txt', 'utf-8')

rs.on('data',function (chunk) {
    // 数据已经可以读取
})

rs.on('end', function () {
    // 数据已经读取到末尾，没有数据可以读取
})

rs.on('error', function (err) {
    // 读取数据发生错误
})

```

**注意：**data事件可能会有很多次，每次传递的chunk是流的一部分数据。

**以流的形式写入文件**

**注意：**以流的形式写入文件，可以不断调用write()方法，最后以end()结束。

1. 写入文本数据

```
'use strict'

var fs = require('fs')

var ws1 = fs.createWriteStream('output1.txt', 'utf-8')
ws1.write('使用Stream写入文本数据...\n')
ws1.write('END.')
ws1.end()
```

2. 写入二进制数据

```
‘use strict’

var fs = require('fs')

var ws2 = fs.createWriteStream('output2.txt')
ws2.write(new Buffer('使用Stream写入二进制数据...\n', 'utf-8'))
ws2.write(new Buffer('END.', 'UTF-8'))
ws2.end()
```

所有可以读取数据的流都继承自stream.Readable，所有可以写入的流都继承自stream.Writable。

**复制文件pipe**
一个Readable流和一个Writable流串起来后，所有的数据自动从Readable流进入Writable流，这种操作叫pipe。    
在Node.js中，Readable流有一个pipe()方法，pipe()把一个文件流和另一个文件流串起来，这样源文件的所有数据就自动写入到目标文件里了，所以，这实际上是一个复制文件的程序。

```
'use strict'

var fs = require('fs')

var rs = fs.createReadStream('sample.txt')
var ws = fs.createWriteStream('copied.txt')

rs.pipe(ws)
```

默认情况下，当Readable流的数据读取完毕，end事件触发后，将自动关闭Writable流。如果我们不希望自动关闭Writable流，需要传入参数:`readable.pipe(writable, { end: false });`




## Step5：完整的爬虫程序

[程序示例](https://github.com/hardhpp/Node/tree/master/crawler)





> 相关参考  
> [慕课视频](http://www.imooc.com/learn/348)   
> [Node.js 实现爬虫（1） —— 简单的爬虫程序](http://blog.csdn.net/hard_hpp/article/details/77181681)   
> [Node.js 实现爬虫（2） —— 多页面的爬虫程序](http://blog.csdn.net/hard_hpp/article/details/77247326)   
> [Node.js 实现爬虫（3） —— 保存爬取的数据](http://blog.csdn.net/hard_hpp/article/details/77248298)     
> [cheerio API](http://cnodejs.org/topic/5203a71844e76d216a727d2e)


















