title: Less Vs Sass
date: 2018-01-26
categories: zhoushiqi
tags: 
- CSS
- Less
- Sass

---

通过一些对Less 和 Sass 的研究和学习,逐渐发现了它们一些共同特征（混入、参数混入、嵌套规则、运算、颜色功能、名字空间、作用域、JavaScript 赋值）和 不同之处，这里主要总结一些 Less 和 Sass **用法不同之处**。

<!--more-->
### CSS 预处理器
CSS 预处理器：用一种专门的编程语言，为 CSS 增加了一些编程的特性，将 CSS作为目标生成文件，开发者只需使用这种语言就可进行编码工作。

## 简述 Less & Sass
<table><tr><td>Less</td><td>Sass</td></tr><tr><td>Less 是一门 CSS 预处理语言，它扩充了 CSS 语言，增加了诸如变量、混合（mixin）、函数等功能，让 CSS 更易维护、方便制作主题、扩充。</td><td> Sass 是一门高于 CSS 的元语言，也是一门CSS预处理语言，它能用来清晰地、结构化地描述文件样式，有着比普通 CSS 更加强大的功能。Sass 能够提供更简洁、更优雅的语法，同时提供多种功能来创建可维护和管理的样式表。 </td></tr></table>

## 安装
> * Less : npm install -g less
> * Sass : gem install sass

## Sass & Less 对比

### 编译环境
* Sass的安装需要Ruby环境,是在服务端处理的
* Less是需要引入less.js来处理Less代码输出css到浏览器，也可以在开发环节使用Less，然后编译乘css文件，直接放到项目中,也有Less.app、SimpleLess、CodeKit.app这样的工具，也有在线编译的。

### 引用 @import
* Less引用外部文件和css中的@import没什么差异。
* scss引用的外部文件命名必须以_ 开头,文件名如果以下划线_ 开头的话,Sass会认为该文件是一个引用文件,不会将其编译为css文件。

### 变量
* Less的变量声明和调用 : 用@ 
* Sass的变量声明和调用 : 用$

<table><tr><td>Less</td><td>Sass</td></tr><tr><td><img width = "300px" height = "100px" src="https://ws1.sinaimg.cn/large/0073X7Nbly1fntwpg061yj30nw0cwq62.jpg"></td><td><img width = "300px" height = "100px" src="https://ws1.sinaimg.cn/large/0073X7Nbly1fntwo1ksgcj30p80cugo9.jpg"></td></tr></table>

### 局部变量和全局变量
Both : 定义全局变量（在选择器、函数、选择宏...的外面定义的变量为全局变量）

<table><tr><td>Less</td><td>Sass</td></tr><tr><td><img width = "300px" height = "150px" src="https://ws1.sinaimg.cn/large/0073X7Nbly1fntwzi2wicj30pm0f4whn.jpg"></td><td><img width = "300px" height = "150px" src="https://ws1.sinaimg.cn/large/0073X7Nbly1fntwzh8h1zj30ps0fgq67.jpg"></td></tr></table>

### 工具库
* Sass有工具库Compass,简单说,Sass和Compass的关系有点像Javascript和jQuery的关系,Compass是Sass的工具库。在它的基础上,封装了一系列有用的模块和模板,补充强化了Sass的功能。
* Less有UI组件库Bootstrap,Bootstrap是web前端开发中一个比较有名的前端UI组件库，Bootstrap的样式文件部分源码就是采用Less语法编写。

### 循环
1.在Less里你可以用递归函数通过数值来循环:

	 .looper (@i) when (@i > 0) {
	   .image-class-@{i} {
	     background: url(“../img/@{i}.png”) no-repeat;
	   }
	   .looper(@i – 1);
	 }
	 .looper(0);
	 .looper(3);
	 
2.在Sass里你可以通过任何数据来迭代:

	@each $beer in stout, pilsner, lager {
	  .#{$beer}-background {
	    background: url(“../img/beers/#{$beer}.png”) no-repeat;
	  }
	}

### 条件语句(LESS中称作引导)  
* Less : 可以通过 when 语句判断条件
* Sass : 通过 @if 和 @else 的方式进行条件判断

<table><tr><td>Less</td><td>Sass</td></tr><tr><td rowspan="2"><img width = "400px" height = "100px" src="https://ws1.sinaimg.cn/large/0073X7Nbly1fnty9d44q4j30pi0bcacy.jpg"></td><td><img width = "300px" height = "100px" src="https://ws1.sinaimg.cn/large/0073X7Nbly1fnty9br31dj30p40iqdjj.jpg"></td></tr></table>

### 作用域
* Less的作用域是按照代码的从上至下的顺序进行的
* Sass的作用域是按照最后一次定义影响全局的

<table><tr><td>Less</td><td>Sass</td></tr><tr><td><img width = "150px" height = "300px" src="https://ws1.sinaimg.cn/large/0073X7Nbly1fntwsyxnt0j30fi0qqacf.jpg"></td><td><img width = "150px" height = "300px" src="https://ws1.sinaimg.cn/large/0073X7Nbly1fntwsw1rouj30fg0qodi7.jpg"></td></tr></table>

### 输出格式
* LESS : 并没有输出设置，
* Sass : 提供4中输出选项：nested, compact, compressed 和 expanded。

### Mixins (混合宏)
* Less : 支持带参数的混合以及有默认参数值的混合
* Sass : 有明确的定义: @Mixin + 宏 调用 : @include + 宏

<table><tr><td>Less</td><td>Sass</td></tr><tr><td><img width = "300px" height = "100px" src="https://ws1.sinaimg.cn/large/0073X7Nbly1fntxaheqwoj30n00kin0g.jpg"></td><td><img width = "300px" height = "100px" src="https://ws1.sinaimg.cn/large/0073X7Nbly1fntxak5ku1j30my0ketcd.jpg"></td></tr></table>

### Parametric-Mixins (参数混入)
混合宏使用中参数使用：

* Less : @
* Sass : $ + @mixin + @include

<table><tr><td>Less</td><td>Sass</td></tr><tr><td><img width = "300px" height = "100px" src="https://ws1.sinaimg.cn/large/0073X7Nbly1fntxcz0u3aj30ng0dwq55.jpg"></td><td><img width = "300px" height = "100px" src="https://ws1.sinaimg.cn/large/0073X7Nbly1fntxcz7mboj30nm0e0wgz.jpg"></td></tr></table>

### Placeholder (占位符) 
* Less : Null
* Sass : 可以使用 **%** 作为占位符

### 运算
Sass在数字上比Less更专业。它已经可以换算单位了。Sass可以处理无法识别的度量单位并将其输出。这个特性很明显是一个对未来的尝试——证明W3C作出的一些改变。

* Sass : 2in + 3cm + 2pc = 3.514in 
* Less : 2in + 3cm + 2pc = Error

### 选择器继承 
* Sass定义的选择器可以通过继承的方式使用
* Less没有这个功能

<table><tr><td>Less</td><td>Sass</td></tr><tr><td>Null</td><td><img width = "300px" height = "150px" src="https://ws1.sinaimg.cn/large/0073X7Nbly1fntxsqoiopj30p60kmn0e.jpg"></td></tr></table>

## 总结
### 开发中如何选择使用Less还是Sass?
* **相同点**：两者都是CSS预处理器，都具有相同的功能，可以帮助我们快速编译代码，帮助我们更好的维护我们的样式代码或者说维护项目吧。
* **不同点**：Less相对清晰明了,易于上手,对编译环境要求比较宽松。Sass的功能比Less强大,是下一个层次的选择，适合稍微有经验的前端开发者的工具。
* 根据业务线需求、组内成员情况，进行约定
* 按需使用，随习惯所为！

### 相关参考

> http://lesscss.cn/ 

> https://www.sass.hk/