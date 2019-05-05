# blog

博客系统基于[Hexo](http://hexo.io/)搭建，使用主题[next.mist](https://github.com/iissnan/hexo-theme-next)。站内搜索使用[swiftype](https://swiftype.com/)。

## 环境搭建
* 基本环境
    * [git](https://github.com/)
    * [Node&npm](https://nodejs.org/en/)
    * [Hexo](http://hexo.io/)

	```
	npm install -g hexo-cli
	```
* 获取项目代码
	
	```
	git clone https://github.com/xgfe/xgfe.github.io.git blog
	cd blog
	npm install
	```
* 写博客

	```
	hexo s [-p 5000] // 启动博客本地环境，默认4000端口，供预览使用
	```
	博文路径
	```
	/source/_posts/{namespace}/{title}.md
	```
	，直接复制已有文章md文件，修改头部信息即可。
	
* 提交代码，通知相关人员审核发布


## 博客规范
头部“---”行以前的部分为博文信息定义部分

```
title: 博客说明书                             // 博文名称
date: 2015-09-24 00:00:00                   // 博文创建时间
updated: 2015-09-25 00:00:00                // 博文修改时间【可选】
categories:                                 // 博文分类，可多级，有层级之分
- felix                                     // 一级分类为{namespace}即它所在文件夹的名称
- blog                                      // 二级分类个人管理，供归纳自己文章用【可选】
tags:                                       // 标签，可多个，无层级之分
- blog
- hexo
- node
---
```
## 注意事项
* 每个人得{namespace}理论上只有一个，即所有博文放在一个文件夹下
* 创建时间发布后不可修改，因为所有博客的先后顺序只与创建时间有关，但在第一次发布时可酌情修改
* 文件名不能出现中文，单词用中横线分割，因为文件名会直接出现再生成博文的url路径中（文件里面配置的title才是blog名）
* 标签统一用小写，为了避免一个标签出现因大小写不同出现多个的情况，或者可以自己先查看标签云再添加，尽量不要添加辨识度低的标签
* 记得给文章通过添加```<!--more-->```来进行全文简介
* 贡献文章时通过fork到本人仓库修改完后提交PR的方式进行

## 后期规划
* 增加githook，做codereview
* 推广方案待定

## 展望
* 积累博文库存
* 提高文章质量
* 扩大业内影响力
* 以能挂广告攒团建费为目标

## 感谢

感谢xgfe团队的所有成员的支持和贡献，感谢小伟哥的耐心指导和付出。

即刻起航，扬帆远行。
