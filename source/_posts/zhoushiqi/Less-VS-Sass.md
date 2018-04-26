title: Less Vs Sass
date: 2018-01-26
categories: zhoushiqi
tags: 
- CSS
- Less
- Sass

---

通过一些对Less 和 Sass 的研究和学习，逐渐发现了它们一些共同特征（混入、参数混入、嵌套规则、运算、颜色功能、名字空间、作用域、JavaScript 赋值）和 不同之处，这里主要总结一些 Less 和 Sass **用法不同之处**。

<!--more-->
## CSS 预处理器
CSS 预处理器：用一种专门的编程语言，为 CSS 增加了一些编程的特性，将 CSS 作为目标生成文件，开发者只需使用这种语言就可进行编码工作。

## 简述 Less & Sass
<table><tr><td>Less</td><td>Sass</td></tr><tr><td>Less 是一门 CSS 预处理语言，它扩充了 CSS 语言，增加了诸如变量、混合（mixin）、函数等功能，让 CSS 更易维护、方便制作主题、扩充。</td><td> Sass 是一门高于 CSS 的元语言，也是一门 CSS 预处理语言，它能用来清晰地、结构化地描述文件样式，有着比普通 CSS 更加强大的功能。Sass 能够提供更简洁、更优雅的语法，同时提供多种功能来创建可维护和管理的样式表。 </td></tr></table>

## 安装
> * Less ： npm install -g less
> * Sass ： gem install sass

## Sass & Less

### 编译环境
* Sass 的安装需要 Ruby 环境，是在服务端处理的。
* Less 是需要引入 less.js 来处理 Less 代码输出 CSS 到浏览器，也可以在开发环节使用Less，然后编译成 CSS 文件，直接放到项目中，也有 Less.app、SimpleLess、CodeKit.app这样的工具，也有在线编译的。

### 引用 @import
* Less 可以根据文件扩展名不同而用不同的方式处理
	* 如果文件是.css的扩展名，将处理为 CSS 和 @import 语句保持原样。
	* 如果为其他的扩展名将处理为 less 导入。
	* 如果没有较少的扩展，那么它将被附加并包含为导入的较少文件。
	* 如果没有扩展名，将会为他添加 .less 扩展名，作为 less 导入。
	* 多个关键字 @import 是允许的，你必须使用逗号分隔关键字：example：@import (optional， reference) "foo.less"。

* Sass 的@import规则在生成 CSS 文件时就把相关文件导入进来。Sass 允许 @import 命令写在CSS规则内。这种导入方式下，生成对应的 CSS 文件时，局部文件会被直接插入到CSS规则内导入它的地方。被导入的局部文件中定义的所有变量和混合器，也会在这个规则范围内生效。这些变量和混合器不会全局有效。另外，所有在被导入文件中定义的变量和混合器均可在导入文件中使用。但是，在少数几种情况下，它会被编译成 CSS 的 @import 规则：
	* 如果文件的扩展名是 .css。
	* 如果文件名以 http:// 开头。
	* 如果文件名是 url()。
	* 如果@import包含了任何媒体查询（media queries）。
	
	Scss/Sass 引用的外部文件命名必须以下划线 _ 开头，文件名如果以下划线 _ 开头的话，Sass 会认为该文件是一个引用文件，这将告诉 Sass 不要把它编译成 CSS 文件。

### 嵌套
* Less
	* 内层选择器前面的 & 符号就表示对父选择器的引用。在一个内层选择器的前面，如果没有 & 符号，则它被解析为父选择器的后代；如果有 & 符号，它就被解析为父元素自身或父元素的伪类。
* Sass
	* 1.选择器嵌套中，可以使用 & 表示父元素选择器 
	* 2.Sass 中还提供属性嵌套，所谓属性嵌套指的是有些属性拥有同一个开始单词，如border-width，border-color 都是以 border 开头。CSS 有一些属性前缀相同，只是后缀不一样 
	* 3.其实伪类嵌套和属性嵌套非常类似，只不过他需要借助`&`符号一起配合使用

### 变量
* Less的变量声明和调用 ：用@ 
* Sass的变量声明和调用 ：用$

<table><tr><td>Less</td><td>Sass</td></tr><tr><td><img width = "300px" height = "100px" src="https://ws1.sinaimg.cn/large/0073X7Nbly1fntwpg061yj30nw0cwq62.jpg"></td><td><img width = "300px" height = "100px" src="https://ws1.sinaimg.cn/large/0073X7Nbly1fntwo1ksgcj30p80cugo9.jpg"></td></tr></table>

### 局部变量和全局变量
Both ： 定义全局变量（在选择器、函数、选择宏...的外面定义的变量为全局变量）

<table><tr><td>Less</td><td>Sass</td></tr><tr><td><img width = "300px" height = "150px" src="https://ws1.sinaimg.cn/large/0073X7Nbly1fntwzi2wicj30pm0f4whn.jpg"></td><td><img width = "300px" height = "150px" src="https://ws1.sinaimg.cn/large/0073X7Nbly1fntwzh8h1zj30ps0fgq67.jpg"></td></tr></table>

### 工具库
* Sass工具库
	* **Compass**。
		* 特点 
			* 1、减少重复工作，加快开发进度 
			* 2、使用变量，便于记忆，变量使用$符号开头 
			* 3、自动转换 RGBA 颜色值 
			* 4、Compass 带有大量混合宏，可以忘记浏览器前缀，节省大量时间
			* 5、嵌套规则，使用嵌套，减少代码量 
			* 6、设备查询，media queries，一样是使用混合宏，减少代码量，节省开发时间 
			* 7、自动压缩 CSS 代码，再次节省开发时间，提高效益
		* 只要先import “compass/_**CSS3**_”， 之後就可以使用所有 CSS3 的內容，如border-radius、box-shadow、gradient…等，使用方式是 @include ，其实是 compass 帮你写好了 @mixin ，你只要会用就好，而compass厉害的就是会同时帮你产生各個浏览器相对应的CSS。
		* 在 compass 新建的项目目录下，新建 images 文件夹。 在 images 文件夹中新建一个文件夹用于放置要合成的图片。 在项目的 Sass 文件夹下新建一个文件。就能看到在 images 文件夹中生成了一个_**雪碧图**_。
	* **SCUT**。SCUT 是提供给前端开发者的 Sass 工具集，能帮助提高对一般样式代码模式的执行（implementations of common style-code patterns）。Scut 工具集可以帮助用户避免重复写代码，扩大代码的可重用性。Scut 工具集可以处理模式（patterns）遇到的下列问题：pattern 是不直观的。pattern 需要简写 pattern 涉及到一些重要的最佳实践 pattern 是极为常见的，（至少）有点讨厌。Scut 工具集的目标是实现可重用性的最大化（maximizies reusabilit）。
	* **Koala**。Sass 和 Less 不一样，需要在本地编译成 CSS 才能看到效果，所以有一个很强大的_**编译工具**_才是重中之重。如果你不会安装 ruby ，更是没听过它;如果你安装了 Ruby，但是不会用它，那么就果断用 Koala 吧。
		* 特点：
			* 1、多语言支持 	
			* 2、实时编译　
			* 3、编译选项　
			* 4、强大的文件右键功能　
			* 5、错误提示 
			* 6、跨平台　
			* 7、免费且负责
* Less工具库
	* 有UI组件库**Bootstrap**，Bootstrap 是 web前端开发中一个比较有名的前端UI组件库，Bootstrap的样式文件部分源码就是采用 Less 语法编写。
	* Less工具库**EST**。 EST（EFE Styling Toolkit）是一个基于Less的样式工具库，帮助您更轻松地书写 Less 代码。EST 提供了一系列方便快捷的 mixin，只在调用时才输出代码。该项目由 EFE 团队开发而来，项目托管在 [GitHub](https：//github.com/ecomfe/est/) 上。EST不希望提供直接给HTML调用的类名，用「样式类」污染HTML代码的语义。当然您也可以根据自己的项目需求基于 EST 搭建样式类库，提供类名接口来进行快速开发。

### 循环
1.在 Less 里你可以用递归函数通过数值来循环：

	 .looper (@i) when (@i > 0) {
	   .image-class-@{i} {
	     background： url(“../img/@{i}.png”) no-repeat;
	   }
	   .looper(@i – 1);
	 }
	 .looper(0);
	 .looper(3);
	 
2.在 Sass 里你可以通过任何数据来迭代：

	@each $beer in stout， pilsner， lager {
	  .#{$beer}-background {
	    background： url(“../img/beers/#{$beer}.png”) no-repeat;
	  }
	}

### 条件语句(Less中称作引导)  
* Less ： 可以通过 when 语句判断条件
* Sass ： 通过 @if 和 @else 的方式进行条件判断

<table><tr><td>Less</td><td>Sass</td></tr><tr><td rowspan="2"><img width = "400px" height = "100px" src="https://ws1.sinaimg.cn/large/0073X7Nbly1fnty9d44q4j30pi0bcacy.jpg"></td><td><img width = "300px" height = "100px" src="https://ws1.sinaimg.cn/large/0073X7Nbly1fnty9br31dj30p40iqdjj.jpg"></td></tr></table>

### 作用域
* Less 的作用域是按照代码的从上至下的顺序进行的
* Sass 的作用域是按照最后一次定义影响全局的

<table><tr><td>Less</td><td>Sass</td></tr><tr><td><img width = "150px" height = "300px" src="https://ws1.sinaimg.cn/large/0073X7Nbly1fntwsyxnt0j30fi0qqacf.jpg"></td><td><img width = "150px" height = "300px" src="https://ws1.sinaimg.cn/large/0073X7Nbly1fntwsw1rouj30fg0qodi7.jpg"></td></tr></table>

### 输出格式
* Less ：并没有输出设置
* Sass ：提供4种输出选项：nested，compact，compressed 和 expanded

### Mixins (混合宏)
* Less ：支持带参数的混合以及有默认参数值的混合
* Sass ：有明确的定义： @Mixin + 宏 调用 ： @include + 宏

<table><tr><td>Less</td><td>Sass</td></tr><tr><td><img width = "300px" height = "100px" src="https://ws1.sinaimg.cn/large/0073X7Nbly1fntxaheqwoj30n00kin0g.jpg"></td><td><img width = "300px" height = "100px" src="https://ws1.sinaimg.cn/large/0073X7Nbly1fntxak5ku1j30my0ketcd.jpg"></td></tr></table>

### Parametric-Mixins (参数混入)
混合宏使用中参数使用：

* Less ： @
* Sass ： $ + @mixin + @include

<table><tr><td>Less</td><td>Sass</td></tr><tr><td><img width = "300px" height = "100px" src="https://ws1.sinaimg.cn/large/0073X7Nbly1fntxcz0u3aj30ng0dwq55.jpg"></td><td><img width = "300px" height = "100px" src="https://ws1.sinaimg.cn/large/0073X7Nbly1fntxcz7mboj30nm0e0wgz.jpg"></td></tr></table>

### Placeholder (占位符) 
* Less ： Null
* Sass ： 可以使用 **%** 作为占位符

### 运算
Sass 在数字上比 Less 更专业。它已经可以换算单位了。Sass 可以处理无法识别的度量单位并将其输出。这个特性很明显是一个对未来的尝试——证明W3C作出的一些改变。

* Sass ： 2in + 3cm + 2pc = 3.514in 
* Less ： 2in + 3cm + 2pc = Error

### 选择器继承 
* Sass 定义的选择器可以通过继承的方式使用
* Less 没有这个功能

<table><tr><td>Less</td><td>Sass</td></tr><tr><td>Null</td><td><img width = "300px" height = "150px" src="https://ws1.sinaimg.cn/large/0073X7Nbly1fntxsqoiopj30p60kmn0e.jpg"></td></tr></table>

## 总结
### 开发中如何选择使用Less还是Sass?
* **相同点**：两者都是 CSS 预处理器，都具有相同的功能，可以帮助我们快速编译代码，帮助我们更好的维护我们的样式代码或者说维护项目吧。
* **不同点**：Less 相对清晰明了，易于上手，对编译环境要求比较宽松。Sass 的功能比 Less 强大，是下一个层次的选择，适合稍微有经验的前端开发者。
* 根据业务线需求、组内成员情况，进行约定。
* 按需使用，随习惯所为！

### 相关参考

> http://lessCSS.cn/ 

> https://www.sass.hk/