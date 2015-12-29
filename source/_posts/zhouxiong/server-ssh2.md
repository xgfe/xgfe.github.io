title: 后台SSH2框架分享
date: 2015.12.24 16:00:00
categories: zhouxiong
tags:
- java
- SSH2
---
## 1.SSH2
- **Struts2**－最早接触到用户请求,下面的加粗部分就是一个struts2的请求
<pre>
<code>
	$.ajax({
		type: "GET",
		**url: "/share/picture-json/doShowRelatePictureAction.action",**
		data: {
			"picId": id
		},
		success: function(result){
			//do something
		}
	})
</code>
</pre>

- **Hibernate**－对象关系映射框架，是对JDBC的轻量级封装，可以运用面向对象的思想操纵数据库。传统的JDBC操作数据库只能针对表的一条条属性，如果表的属性过多时，编写代码会显得非常冗余。如果采用Hibernate，对于一个表的操作只需要操作一个对象即可，编写代码会非常方便。

- **Spring**－管理Struts2的请求以及简化对数据库的访问，并能通过Ioc（依赖注入）和AOP（面向切面）特性快速进行项目开发

## 2.MVC
### 2.1 MVC原理图
<img src="/Users/zhouxiong/Desktop/images/personal-share/server/mvc.jpg">

### 2.2 MVC与MVVM
1. MVC 

 mvc是一种常用的软件架构，是一种开发模式，其各部分的通信可简单看成以下几步：<br/>
  （1）View传送指令到controller  <br/>
  （2）Controller完成业务逻辑，改变Model的状态  <br/>
  （3）Model将数据发送给View重新渲染，用户得到反馈  <br/>
 **在MVC模式中，通信都是单向的**
 
2. MVVM

	<img src="/Users/zhouxiong/Desktop/images/personal-share/server/mvvm.png" height="300px" width="400px">

	MVVM模式是将Controller换成ViewModel，其有以下特性： <br/>
（1）**各部分之间通信为双向的**  <br/>
（2）View和Model不直接通信，而是通过ViewModel传递  <br/>
（3）View只是被动的显示内容，所有业务逻辑放在ViewModel中  <br/>

## 3.服务器端代码请求过程
![服务器端请求过程](/Users/zhouxiong/Desktop/images/personal-share/server/server-process.png)

## 4.服务端代码的逻辑结构
### 4.1逻辑结构图
<!--![代码组织结构](/Users/zhouxiong/Desktop/images/personal-share/code-layout.png) -->
<img src="/Users/zhouxiong/Desktop/images/personal-share/server/code-layout.png" height="600px">
### 4.2各部分说明
1. Java Resources-包含全部的java源代码，配置文件和引入的jar文件
 * src-包括所有的java源文件和配置文件
  		* configs下包括所有的struts2和spring的配置文件
  		* yiban下包括所有的java源文件，在源文件中也会分成相应的层，action层（用于接收请求，由Struts2负责），dao层（直接处理数据库），service层（处理具体的业务逻辑）。pojo是对象和数据库表的映射文件。util下是一些公共功能的可复用的java文件。
 * Libraries－所有的jar文件，包括tomcat，jre，外部引入的SSH2的jar包
2. WebContent-编写的前端展示的文件，css、js、jsp等。其中WEB-INF下的web.xml是至关重要的文件，所有的请求都会经过web.xml然后查找对应的java文件进行处理

## 5.具体项目搭建过程
### 5.1准备工作
- jdk1.7
- IDE: eclipse
- 服务器：tomcat6.0
- 数据库：mysql，保证数据库的服务是启动的

### 5.2 项目搭建
1. 新建项目
<p>
 在eclipse中新建一个web project，此时的project没有ssh2的支持，需要手动引入
</p>
2. 引入SSH2框架
	- 引入Struts2
		* 首先在WebContent/WEB-INF/web.xml中添加如下代码段1⃣️，这段代码表示所有的请求都将由Struts2来处理
		* 在Java Resources/src目录下添加struts.xml文件，其中添加一些全局设置，比如编码方式，扩展名等。如果在一个xml文件内配置所有的请求，这个文件就会显得很冗长，不方便管理，因此struts2的xml文件是可以拆分的。项目中的src/configs/struts下的xml文件都是关于struts2的配置
		* 导入Struts2依赖的jar包，将jar包拷贝到WebContent/WEB-INF/lib下
	- 引入Hibernate
		* 首先在Java Resources/src下建立hibernate.cfg.xml文件（其实也可以不用建立，因为对Hibernate的配置都交给了Spring，故可省略）
		* 导入Hibernate所依赖动jar包，将jar包拷贝到WebContent/WEB-INF/lib下
	- 引入Spring
		* 首先在WebContent/WEB-INF/web.xml中添加如下代码段2⃣️，这段代码表示添加对Spring的支持。同样可以将Spring的配置文件进行拆分，建立多个方便管理的xml文件，项目中的src/configs/spring下都是spring的配置文件	
		* 引入Spring依赖的jar包，将jar包拷贝到WebContent/WEB-INfO/lib下
	- 引入额外的jar包
	 	* Spring支持Struts2的jar包
	 	* Struts2支持json的jar包
	 	* 连接mysql数据库jar包   
3. 项目部署到tomcat，测试项目完整运行 
4. 数据库设计
	- 创建数据库
	- 设计数据库表结构
5. 前端页面设计与代码编写
6. 后台逻辑实现
7. 测试
8. 上线
	
代码段1⃣️

```
	<filter>
		<filter-name>struts2</filter-name>
		<filter-class>
		org.apache.struts2.dispatcher.ng.filter.StrutsPrepareAndExecuteFilter
		</filter-class>
	</filter>

	<filter-mapping>
		<filter-name>struts2</filter-name>
		<url-pattern>/*</url-pattern>
	</filter-mapping>
```
代码段2⃣️

```
    <context-param>
		<param-name>contextConfigLocation</param-name>
		<param-value>
			/WEB-INF/classes/configs/spring/context_base_beans.xml
			/WEB-INF/classes/configs/spring/context_service_beans.xml
			/WEB-INF/classes/configs/spring/context_action_beans.xml
        </param-value>
	</context-param>
	<listener>
		<listener-class>
			org.springframework.web.context.ContextLoaderListener
		</listener-class>
	</listener>
```   































