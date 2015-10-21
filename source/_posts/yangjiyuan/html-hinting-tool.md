title: HTML代码检查工具实践
date: 2015-10-08
categories: yangjiyuan
tags: 
- html
- htmlhint
- 代码规范
---

## 前言

作为一只页面仔，写出一手漂（niu）亮（bi）的代码一直是我们不懈的追求。HTML作为前端开发入门级的语言，把它熟练掌握是基本功，不光如此，还需要在一个团队里保持良好的编码规范，使得代码易被理解和被维护。
就现阶段来看，我们还是没有形成统一的代码风格，写出的东西五花八门，等项目做大之后，其中的诸多问题必然会暴露出来。所以，为了能省（shao）时（jia）省（dian）力（ban），我们需要制定一套符合现有团队的规范、更需要检查代码是否符合规范的自动化工具。
<!-- more -->
## 制定规则

没有规矩，不成方圆。参照业界其他优秀团队的规范，如[百度FEX团队](https://github.com/fex-team/styleguide/blob/master/html.md)、[BootstrapCodeGuide](http://codeguide.bootcss.com/)、[Google style guide](http://google.github.io/styleguide/htmlcssguide.xml)，结合W3C的标准规范，加上大家的踩坑经验，七嘴八舌地制定了一套适合团队自身的[HTML规范草案(内网访问)](http://wiki.sankuai.com/pages/viewpage.action?pageId=341813735)或者[xg-htmlhint Rules](https://github.com/yangjiyuan/xg-htmlhint/wiki/Rules)。

## 自动化检查工具的探索和实现
### 探索阶段

在做自己的代码检查工具之前，我们调研过几个类似的工具，其他团队对此类工具也有调研，参照[HTML代码风格检查工具对比](http://efe.baidu.com/blog/comparison-of-html-linting-tool/)，以此为铺垫，我们对比了[Bootlint](https://github.com/twbs/bootlint)、[AriaLinter](https://github.com/globant-ui/arialinter)、[htmllint](https://github.com/htmllint/htmllint)、[HTMLHint](https://github.com/yaniswang/HTMLHint)、[htmlcs](https://github.com/ecomfe/htmlcs)等多种代码检查工具，各个工具的对比如下：

|  名称      |         开发团队/作者       |   是否支持配置文件 | 是否支持行内配置 | 特点
| ------------- |:-------------------:|:-----:|:----:|:-----:|
|  Bootlint       | [Bootstrap团队](https://github.com/twbs/) | 否| 否|针对 Bootstrap 相关的检查
|  AriaLinter      | [globant-ui](https://github.com/globant-ui/)| 否|否|偏重语义检查规则
|  htmllint       | [htmllint](https://github.com/htmllint) | 否|是|多数情况都能用，没有明显的优势|
|  HTMLHint       | [yaniswang](https://github.com/yaniswang) | 是|是|重点针对格式规则进行检查，没有AST操作，轻便
|htmlcs|[百度EFE](https://github.com/ecomfe/htmlcs)|是|是|大而全，覆盖面比较大

我们的主要需求点在于以下几个方面：
- 需要支持命令行，模块引入等多种操作
- 需要支持配置文件传入规则
- 对代码片段，如template进行规则豁免
- 轻量可扩展

综上，决定在HTMLHint的基础上进行扩展和补充。

### xg-htmlhint简介
[xg-htmlhint](https://github.com/yangjiyuan/xg-htmlhint)是在[HTMLHint](https://github.com/yaniswang/HTMLHint)的基础上进行改进的，为什么选择这个工具呢？一方面是该工具比较简单，实现起来比较简单，且具有较强的可扩展性；另一方面，HTMLHint会在对HTML进行parse的时候检查规则，不包含对[AST](https://en.wikipedia.org/wiki/Abstract_syntax_tree)的操作，性能方面有一点优势，但这也是它的短板，即在语义化规则的检查上略显不足。  
HTMLHint主要由四部分组成：

- core：组织各个对象，接入规则
- HTML parser：parse HTML 代码片段
- reporter：输出检验结果
- rules：检查规则

本次对HTMLHint的改进和扩展包括：

- 修复部分不准确的规则
- 在parser中添加对标签属性的定位
- 将原有的自定义规则和默认规则的优先级进行改变
- 删除或增加部分规则
- 改变命令行中检查结果的展示方式
- 改变命令行参数

### 使用xg-htmlhint

1. 安装和命令选项

	``` bash
	$ [sudo] npm install -g xg-htmlhint 
	
	$ htmlhint -V   // 显示当前版本号
	$ htmlhint -l   // 列出所有可用的规则
	$ htmlhint -c rule.conf  // 自定义配置文件（默认是执行命令目录下的.htmlhintrc文件）
	```
2. 执行检查
	
	``` bash
	htmlhint test.html   // 单个文件
	htmlhint test/       // 整个目录及子目录
	htmlhint             // 当前目录及子目录
	```
3. 输出结果

	``` bash
	test.html:
    	line 1, col 1: Doctype must be uppercase.
    	line 11, col 21: The value of attribute [ class ] must be in double quotes.  
    	line 14, col 2: Special characters must be escaped : [ < ].
    	line 14, col 49: Special characters must be escaped : [ > ].
    	line 14, col 78: Tag must be paired, no start tag: [ <button> ]

	4 Errors,1 Warnings
	```
4. 配置规则   
	根目录下获取`.htmlhintrc`文件中的内容作为自定义配置规则，如果没有就使用[默认规则](https://github.com/yangjiyuan/xg-htmlhint/wiki/Rules#default-rules)。也可以指定配置文件，使用命令`htmlhint -c rule.conf`。  
	行内嵌套规则
	
	```html
	<!--htmlhint tag-pair:false,id-class-value:underline -->
	<html>
	<head>
	``` 
	
### Guide
1. [如何使用](https://github.com/yangjiyuan/xg-htmlhint/wiki/Usage)
2. [规则列表](https://github.com/yangjiyuan/xg-htmlhint/wiki/Rules)
3. [如何添加自定义规则](https://github.com/yangjiyuan/xg-htmlhint/wiki/Developer-Guide)

## 鸣谢
- [yaniswang(原作者)](https://github.com/yaniswang/)
- [HTMLHint](https://github.com/yaniswang/HTMLHint/)
