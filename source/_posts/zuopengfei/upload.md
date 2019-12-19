title: 文件上传那些事
date: 2019-12-19 19:18:00
categories: zuopengfei
tags: 
- http
- koa
- koa-body
- 文件上传

---

本文是写给新手前端的各种文件上传攻略，本文涉及到的知识点包括:文件上传的基本原理；最原始的基于form表单的文件上传；基于xhr2的文件上传、文件上传进度、终止上传；拖拽上传、剪贴板上传、大文件分片上传、大文件断点续传。


<!-- more -->

## 文件上传原理

文件上传其实就是根据http协议的规范和定义，完成请求消息体的封装和消息体的解析，然后将二进制内容保存到文件。

如果要上传一个文件，http请求的method必须为post方法；content-type类型必须是multipart/form-data；如果使用form表单上传文件时，必须让 form 的 enctyped 等于multipart/form-data。

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
