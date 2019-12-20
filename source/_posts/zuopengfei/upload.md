title: 文件上传那些事
date: 2019-12-19 19:18:00
categories: zuopengfei
tags: 
- http
- koa
- koa-body
- 文件上传

---

本文是写给新手前端的各种文件上传攻略，本文涉及到的知识点包括：文件上传的基本原理；最原始的基于form表单的文件上传；基于xhr2的文件上传、文件上传进度、终止上传；拖拽上传、剪贴板上传、大文件分片上传、大文件断点续传。


<!-- more -->

## 文件上传原理

文件上传其实就是根据http协议的规范和定义，完成请求消息体的封装和消息体的解析，然后将二进制内容保存到文件。

如果要上传一个文件，http请求的method必须为post方法；content-type类型必须是multipart/form-data；如果使用form表单上传文件时，必须让form的enctyped等于multipart/form-data。

### 什么是multipart/form-data？

multipart表示混合资源，也就是由多种元素组成的资源。

### multipart/form-data的结构

![multipart/form-data的结构](https://p0.meituan.net/spacex/c3c978ff56b657f370a38ace0be3d5b9.png)

#### 请求头：
Content-Type: multipart/form-data; boundary=----WebKitFormBoundaryDCntfiXcSkPhS4PN 表示本次请求要上传文件；其中boundary表示分隔符，如果要上传多个表单项，就要使用boundary分割，每个表单项由----WebKitFormBoundaryXXX开始，以----WebKitFormBoundaryXXX--结尾。

#### 请求消息体Form Data 部分:
每一个表单项又由Content-Type和Content-Disposition组成。

Content-Disposition：form-data 为固定值，表示一个表单元素；name 表示表单元素的名称；回车换行后面就是name的值；

如果是上传文件是文件是二进制内容，则会多一个filename字段，表示上传文件的文件名称；还有多一个Content-Type：表示当前的内容的MIME类型，是图片、还是文本、还是二进制数据。

### 解析
客户端发送请求到服务器后，服务器会收到请求的消息体，然后对消息体进行解析，解析出哪是普通表单哪些是附件。

## 基于form表单的最原始文件上传

### 演示效果

![基于form表单的文件上传](https://s3plus.meituan.net/v1/mss_877fd457c4cf425388a58130e2279ae8/file/297e0daeab680d302d60d1a2bdb38b26)
### 前端代码

```html
<form method="post" action="http://localhost:8100" enctype="multipart/form-data">
      选择文件: <input type="file" name="f1"/>input 必须设置 name 属性，否则数据无法发送<br/><br/>
      标题：<input type="text" name="title"/><br/><br/><br/>
	  <button type="submit" id="btn-0">上 传</button>
</form>
```

### 上传接口

基于现有的库koa-body结合koa2实现服务端文件的解析和保存。

```JavaScript
/**
 * 服务入口
 */
var http = require('http');
var koaStatic = require('koa-static');
var path = require('path');
var koaBody = require('koa-body');//文件保存库
var fs = require('fs');
var Koa = require('koa2');

var app = new Koa();
var port = process.env.PORT || '8100';

var uploadHost= `http://localhost:${port}/uploads/`;

app.use(koaBody({
    formidable: {
        //设置文件的默认保存目录，不设置则保存在系统临时目录下  os
        uploadDir: path.resolve(__dirname, '../static/uploads')
    },
    multipart: true // 开启文件上传，默认是关闭
}));

//开启静态文件访问
app.use(koaStatic(
    path.resolve(__dirname, '../static') 
));

//文件二次处理，修改名称
app.use((ctx) => {
    var file = ctx.request.files.f1;//得道文件对象
    var path = file.path;
    var fname = file.name;//原文件名称
    var nextPath = path+fname;
    if(file.size>0 && path){
        //得到扩展名
        var extArr = fname.split('.');
        var ext = extArr[extArr.length-1];
        var nextPath = path+'.'+ext;
        //重命名文件
        fs.renameSync(path, nextPath);
    }
    //以 json 形式输出上传文件地址
    ctx.body = `{
        "fileUrl":"${uploadHost}${nextPath.slice(nextPath.lastIndexOf('/')+1)}"
    }`;
});

/**
 * http server
 */
var server = http.createServer(app.callback());
server.listen(port);
console.log('demo1 server start ......   ');

```

koa-body会自动保存文件到系统临时目录下，也可以指定保存的文件路径。

```shell
✘  ~/work/gitstash/other/fe-learn-code-master  node
> os.tmpdir()
'/var/folders/mc/lfl3v3n954v2ynmd8zbmk0xw0000gp/T'
```

然后在后续中间件内得到已保存的文件的信息；ctx.request.files.f1 可以得到上传的文件对象

key |  名称 | demo
:-:  | :-: |  :-:
name | 文件名 |  包括扩展名，扩展名需要自己截取 var extArr = fname.split('.'); var ext = extArr[extArr.length-1];
path | 文件路径 | 
lastModifiedDate | 文件修改时间 | 
size | 文件大小 | 
type | 文件类型 | 


拿到文件后就可以做二次处理了

```JavaScript
创建可读流 const reader = fs.createReadStream(file.path)
创建可写流 const writer = fs.createWriteStream('upload/newpath.txt')
可读流通过管道写入可写流 reader.pipe(writer)
```

## 多文件上传

```html
//设置 multiple属性
<input type="file" name="f1" multiple/> 
```
服务端也需要进行简单的调整，由单文件对象变为多文件数组，然后进行遍历处理。

```javascript
var files = ctx.request.files.f1;// 多文件， 得到上传文件的数组
var result=[];
//遍历处理
files && files.forEach(item=>{
       ...
```

## 局部刷新 - iframe

### 效果演示

![局部刷新 - iframe](https://s3plus.meituan.net/v1/mss_877fd457c4cf425388a58130e2279ae8/file/e6f1c57f474671bddd9268dde7d0f57b)

### 前端代码

页面内放一个隐藏的 iframe，或者使用 js 动态创建，指定 form 表单的 target 属性值为iframe标签 的 name 属性值，这样 form 表单的 shubmit 行为的跳转就会在 iframe 内完成，整体页面不会刷新。

```html
	<iframe id="temp-iframe" name="temp-iframe" src="" style="display:none;"></iframe>
	<form method="post" target="temp-iframe" action="http://localhost:8100" enctype="multipart/form-data">
	  选择文件(可多选): <input type="file" name="f1" id="f1" multiple/><br/> input 必须设置 name 属性，否则数据无法发送<br/>
	  标题：<input type="text" name="title"/><br/><br/><br/>
	  <button type="submit" id="btn-0">上 传</button>
	</form>
```

### 如何拿到接口数据

为 iframe 添加load事件，得到 iframe 的页面内容，将结果转换为 JSON 对象，这样就拿到了接口的数据

```JavaScript
var iframe = document.getElementById('temp-iframe');
iframe.addEventListener('load',function () {
      var result = iframe.contentWindow.document.body.innerText;
      //接口数据转换为 JSON 对象
      var obj = JSON.parse(result);
      if(obj && obj.fileUrl.length){
          alert('上传成功');
          
      }
      console.log(obj);
});

```

## 基于xhr2的文件上传

XMLHttpRequest |  XMLHttpRequest2 
:-:  | :-: 
在 ie 时代就存在；只支持文本数据的传输；无法用来读取和上传二进制数据 | 可以读取和上传二进制数据；可以使用·FormData·对象管理表单数据。

### 多文件上传-xhr formdata


不用 form 表单元素包裹

```JavaScript
<div>
	选择文件(可多选):
  <input type="file" id="f1" multiple/><br/><br/>
  <button type="button" id="btn-submit">上 传</button>
</div>

 function submitUpload() {
    //获得文件列表，注意这里不是数组，而是FileList对象，每个
    var fileList = document.getElementById('f1').files;
    if(!fileList.length){
       alert('请选择文件');
       return;
    }
		//构造FormData对象
    var fd = new FormData();
    //多文件上传需要遍历添加到 fromdata 对象
    for(var i =0; i<fileList.length; i++){
        //支持多文件上传
        fd.append('f1', fileList[i]);
    }

    var xhr = new XMLHttpRequest();   //创建对象
    xhr.open('POST', 'http://localhost:8100/', true);

    xhr.send(fd);//发送时  Content-Type默认就是: multipart/form-data; 
    ....                             

}

```

### 多文件，单进度

#### 效果演示
![多文件，单进度](https://s3plus.meituan.net/v1/mss_877fd457c4cf425388a58130e2279ae8/file/c61713f2f6f59ce31aa1693766317ecc)

#### 获取进度条的原理

```JavaScript
// 进度处理的监听函数
xhr.upload.onprogress = updateProgress;
function updateProgress(event) {
	// event.lengthComputable这是一个状态，表示发送的长度有了变化，可计算
	if (event.lengthComputable) {
	// event.loaded表示发送了多少字节
     // event.total表示文件总大小
     // 根据event.loaded和event.total计算进度
	var completedPercent = (event.loaded / event.total * 100).toFixed(2);
	progressSpan.style.width= completedPercent+'%';
	progressSpan.innerHTML=completedPercent+'%';
	if(completedPercent>90){//进度条变色
		progressSpan.classList.add('green');
	}
	console.log('已上传',completedPercent);
  }
}
//注意 send 一定要写在最下面，否则 onprogress 只会执行最后一次 也就是100%的时候
xhr.send(fd);//发送时  Content-Type默认就是: multipart/form-data;
```

### 多文件上传之预览、多进度条、终止上传

上一个栗子的多文件上传只有一个进度条，有些需求可能会不大一样，需要观察到每个文件的上传进度，并且可以终止上传。

#### 效果演示

![多文件，多进度](https://s3plus.meituan.net/v1/mss_877fd457c4cf425388a58130e2279ae8/file/bafc069ad266dd863776cbcda27572e6)

#### 图片预览

getObjectURL方法是一个用于获取本地图片的地址，使用该url可以显示图片

```JavaScript
img.src = getObjectURL(file);
img.onload = function () {
	// 在图片加载成功后需要清除使用的内存
	window.URL.revokeObjectURL(this.src);
}
```

#### 多进度条

每个file对象都创建一个与之对应的独立XMLHttpRequest对象，并行或者串行发送，每个file对象独立监听进度

```JavaScript
 //遍历文件信息进行上传
 willFiles.forEach(function (item) {
  xhrSend({
  	file:item.file,
  	progress:item.progress
  });
});
```

#### 终止上传

取消请求的方法xhr.abort()调用后，xhr.readyState会立即变为4, 而不是0；但是MDN上说是0；所以这里需要做容错处理。

```JavaScript
xhr.onreadystatechange = function () {
	console.log('state change', xhr.readyState);
	//调用abort后，state立即变成了4,并不会变成0
	//增加自定义属性 xhr.uploaded
	if (xhr.readyState == 4 &&  xhr.uploaded) {
		var obj = JSON.parse(xhr.responseText);   //返回值
		console.log(obj);
		if(obj.fileUrl.length){
			//alert('上传成功');
		}
	}
}
```

## 拖拽上传

### 效果演示

![拖拽上传](https://s3plus.meituan.net/v1/mss_877fd457c4cf425388a58130e2279ae8/file/3dc77833bca65bcc35c2c379291e118d)

### 原理

为拖拽区域绑定事件；鼠标在拖拽区域上 dragover, 鼠标离开拖拽区域dragleave, 在拖拽区域上释放文件drop


针对对象 | 事件 | 说明
:-:  | :-: |  :-:
说明 | dragenter |  当被拖动元素进入目的地元素所占据的屏幕空间时触发
 | dragover | 当被拖动元素在目的地元素内时触发
 | dragleave | 当被拖动元素没有放下就离开目的地元素时触发
 
 
drop事件内获得拖动操作中的文件列表 e.dataTransfer.files 
取消drop 事件的默认行为e.preventDefault()；不然浏览器会直接打开文件

## 剪贴板上传

### 效果演示

![剪贴板上传](https://s3plus.meituan.net/v1/mss_877fd457c4cf425388a58130e2279ae8/file/c70ba1f24daa2f0d8647e18f8c728fb2)


### 原理

```Javascript
// 页面内增加一个可编辑的编辑区域div.editor-box,开启contenteditable
// 为div.editor-box绑定paste事件
box.addEventListener('paste',function (event) {
				// 处理paste 事件，从event.clipboardData || window.clipboardData获得数据
        var data = (event.clipboardData || window.clipboardData);
        console.dir(data);

        var items = data.items;
        var fileList = [];//存储文件数据
        if (items && items.length) {
            // 检索剪切板items
            for (var i = 0; i < items.length; i++) {
                console.log(items[i].getAsFile());
                // 将数据转换为文件items[i].getAsFile()
                fileList.push(items[i].getAsFile());
            }
        }
        console.log('data.items.length', data.items.length);
        console.log('data.files.length', data.files.length);

        window.willUploadFileList = fileList;
        event.preventDefault();

        submitUpload();
    }); 
```

## 大文件分片上传

如果太大的文件，比如一个视频1g 2g那么大，直接采用上面的栗子中的方法上传可能会出链接现超时的情况，而且也会超过服务端允许上传文件的大小限制，所以解决这个问题我们可以将文件进行分片上传，每次只上传很小的一部分 比如2M。

### 演示效果

![大文件分片上传](https://s3plus.meituan.net/v1/mss_877fd457c4cf425388a58130e2279ae8/file/1c9bbe108cb91d7e97c9231df6243095)

### 原理
相信大家都对Blob 对象有所了解，它表示原始数据,也就是二进制数据，同时提供了对数据截取的方法slice, 而 File 继承了Blob的功能，所以可以直接使用此方法对数据进行分段截取。

#### 前端逻辑：

把大文件进行分段 比如2M，发送到服务器携带一个标志，暂时用当前的时间戳，用于标识一个完整的文件。

浏览器端所有分片上传完成，发送给服务端一个合并文件的请求 。

```JavaScript
<script>
    function submitUpload() {
        var chunkSize=2*1024*1024;//分片大小 2M
        var file = document.getElementById('f1').files[0];
        var chunks=[], //保存分片数据
        token = (+ new Date()),//时间戳
        name =file.name,
        chunkCount=0,
        sendChunkCount=0;

        //分片逻辑  像操作字符串一样    
        if(file.size > chunkSize){
            //拆分文件
            var start=0,end=0;
            while (true) {
                end += chunkSize;
                var blob = file.slice(start,end);
                start += chunkSize;
                if(!blob.size){//截取的数据为空 则结束
                    //拆分结束
                    break;
                }
                chunks.push(blob);//保存分段数据
            }
        }else{
            chunks.push(file.slice(0));
        }

        chunkCount=chunks.length;//分片的个数 
        
        //没有做并发限制，较大文件导致并发过多，tcp 链接被占光 ，需要做下并发控制，比如只有4个在请求在发送
        for(var i=0;i< chunkCount;i++){
            var fd = new FormData();   //构造FormData对象
            fd.append('token', token);
            fd.append('f1', chunks[i]);
            fd.append('index', i);
            xhrSend(fd, function () {
                sendChunkCount+=1;
                if(sendChunkCount===chunkCount){//上传完成，发送合并请求
                    console.log('上传完成，发送合并请求');
                    var formD = new FormData();
                    formD.append('type','merge');
                    formD.append('token',token);
                    formD.append('chunkCount',chunkCount);
                    formD.append('filename',name);
                    xhrSend(formD);
                }
            });
        }
    }

    function xhrSend(fd,cb) {
        var xhr = new XMLHttpRequest();
        xhr.open('POST', 'http://localhost:8100/', true);
        xhr.onreadystatechange = function () {
            console.log('state change', xhr.readyState);
            if (xhr.readyState == 4) {
                console.log(xhr.responseText);
                cb && cb();
            }
        }
        xhr.send(fd);//发送
    }

    //绑定提交事件
    document.getElementById('btn-submit').addEventListener('click',submitUpload);
</script>
```

#### 服务器端

+ 服务端保存各段文件
+ 浏览器端所有分片上传完成，发送给服务端一个合并文件的请求 
+ 服务端根据文件标识、类型、各分片顺序进行文件合并
+ 删除分片文件

```JavaScript
//二次处理文件，修改名称
app.use((ctx) => {
    var body = ctx.request.body;
    var files = ctx.request.files ? ctx.request.files.f1:[];//得到上传文件的数组
    var result=[];
    var fileToken = ctx.request.body.token;// 文件标识
    var fileIndex=ctx.request.body.index;//文件顺序

    if(files &&  !Array.isArray(files)){//单文件上传容错
        files=[files];
    }

    files && files.forEach(item=>{
        var path = item.path;
        var fname = item.name;//原文件名称
        var nextPath = path.slice(0, path.lastIndexOf('/') + 1) + fileIndex + '-' + fileToken;
        if (item.size > 0 && path) {
            //得到扩展名
            var extArr = fname.split('.');
            var ext = extArr[extArr.length - 1];
            //var nextPath = path + '.' + ext;
            //重命名文件
            fs.renameSync(path, nextPath);
            result.push(uploadHost+nextPath.slice(nextPath.lastIndexOf('/') + 1));
        }
    });

    if(body.type==='merge'){//合并分片文件
        var filename = body.filename,
        chunkCount = body.chunkCount,
        folder = path.resolve(__dirname, '../static/uploads')+'/';
        
        var writeStream = fs.createWriteStream(`${folder}${filename}`);

        var cindex=0;
        //合并文件
        function fnMergeFile(){
            var fname = `${folder}${cindex}-${fileToken}`;
            var readStream = fs.createReadStream(fname);
            readStream.pipe(writeStream, { end: false });
            readStream.on("end", function () {
                fs.unlink(fname, function (err) {
                    if (err) {
                        throw err;
                    }
                });
                if (cindex+1 < chunkCount){
                    cindex += 1;
                    fnMergeFile();
                }
            });
        }
        fnMergeFile();
        ctx.body='merge ok 200';
    }
  
});
```

## 大文件断点续传

上面我们实现了大文件的分片上传，解决了大文件上传超时和服务器的限制。

但是仍然不够完美，大文件上传并不是短时间内就上传完成，如果期间断网，页面刷新了仍然需要重头上传,这种时间的浪费怎么能忍？

所以我们实现断点续传，已上传的部分跳过，只传未上传的部分。


### 原理

在上面我们实现了文件分片上传和最终的合并，现在要做的就是如何检测这些分片，不再重新上传即可。 这里我们可以在本地进行保存已上传成功的分片，重新上传的时候使用spark-md5来生成文件 hash，区分此文件是否已上传。

+ 为每个分段生成 hash 值，使用 spark-md5 库
+ 将上传成功的分段信息保存到本地
+ 重新上传时，进行和本地分段 hash 值的对比，如果相同的话则跳过，继续下一个分段的上传

模拟分段保存，本地保存到localStorage

```JavaScript
/获得本地缓存的数据
    function getUploadedFromStorage(){
        return JSON.parse( localStorage.getItem(saveChunkKey) || "{}");
    }

    //写入缓存
    function setUploadedToStorage(index) {
        var obj =  getUploadedFromStorage();
        obj[index]=true;      
        localStorage.setItem(saveChunkKey, JSON.stringify(obj) );
    }
    
    //分段对比
    
    var uploadedInfo = getUploadedFromStorage();//获得已上传的分段信息

    for(var i=0;i< chunkCount;i++){
            console.log('index',i, uploadedInfo[i]?'已上传过':'未上传');
            
            if(uploadedInfo[i]){//对比分段
                sendChunkCount=i+1;//记录已上传的索引
                continue;//如果已上传则跳过
            }
            var fd = new FormData();   //构造FormData对象
            fd.append('token', token);
            fd.append('f1', chunks[i]);
            fd.append('index', i);
           
           (function (index) {
                    xhrSend(fd, function () {
                    sendChunkCount += 1;
                    //将成功信息保存到本地
                    setUploadedToStorage(index);
                    if (sendChunkCount === chunkCount) {
                        console.log('上传完成，发送合并请求');
                        var formD = new FormData();
                        formD.append('type', 'merge');
                        formD.append('token', token);
                        formD.append('chunkCount', chunkCount);
                        formD.append('filename', name);
                        xhrSend(formD);
                    }
                });
            })(i);
    }
```

基于上面一个栗子进行改进，服务端已保存了部分片段，客户端上传前需要从服务端获取已上传的分片信息（上面是保存在了本地浏览器），本地对比每个分片的 hash 值，跳过已上传的部分，只传未上传的分片

## 总结

目前社区已经存在一些成熟的文件上传解决方案，如七牛SDK，腾讯云SDK等，也许并不需要我们手动去实现一个简陋的文件上传库，但是了解其原理还是十分有必要的。

本文首先整理了前端文件上传的几种方式，然后讨论了大文件上传的几种场景，以及大文件上传需要实现的几个功能

+ 通过Blob对象的slice方法将文件拆分成切片
+ 整理了服务端还原文件所需条件和参数，演示了node将切片还原成文件
+ 通过保存已上传切片的记录来实现断点续传

还留下了一些问题，如：合并文件时避免内存溢出、切片失效策略，并没有去深入或一一实现，继续学习吧~




