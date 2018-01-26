title: Less Vs Sass
date: 2018-01-26
categories: zhoushiqi
tags: 
- CSS
- Less
- Sass

---

主要进行Less 和 Sass 用法的对比。

<!--more-->

## css预处理器：
CSS 预处理器定义了一种新的语言，其基本思想是，用一种专门的编程语言，为 CSS 增加了一些编程的特性，将 CSS 作为目标生成文件，然后开发者就只要使用这种语言进行编码工作。

## 安装
> * Less : npm install -g less
> * Sass : gem install sass

## 简述 Less & Sass
<table><tr><td>Less</td><td>Sass</td></tr><tr><td>Less 是一门 CSS 预处理语言，它扩充了 CSS 语言，增加了诸如变量、混合（mixin）、函数等功能，让 CSS 更易维护、方便制作主题、扩充。</td><td> Sass 是一门高于 CSS 的元语言，它能用来清晰地、结构化地描述文件样式，有着比普通 CSS 更加强大的功能。Sass 能够提供更简洁、更优雅的语法，同时提供多种功能来创建可维护和管理的样式表。 </td></tr></table>

## Sass / Scss / Less 对比
### Sass & Scss
<table><tr><td>Sass</td><td>Scss</td></tr><tr><td>$width: 200px<br>.container<br>&nbsp;&nbsp;&nbsp;&nbsp;with: $width</td><td>$width:200px<br>.container{<br>&nbsp;&nbsp;&nbsp;&nbsp;with: $width<br>}</td></tr></table>

### Less & Sass
<table><tr><td>Less</td><td>Sass</td></tr><tr><td>lessc test.less test.css</td><td>Less & Sass sass 1.sass.sass:1.sass.css<br>Less & Sass sass --watch 1.sass.sass:1.sass.css</td></tr></table>

## Less & Sass语法详解
### 变量
<table><tr><td>Less</td><td>Sass</td></tr><tr><td><img src="https://ws1.sinaimg.cn/large/0073X7Nbly1fntwpg061yj30nw0cwq62.jpg"></td><td><img src="https://ws1.sinaimg.cn/large/0073X7Nbly1fntwo1ksgcj30p80cugo9.jpg"></td></tr></table>

### 作用域

<table><tr><td>Less</td><td>Sass</td></tr><tr><td><img width = "200px" height = "400px" src="https://ws1.sinaimg.cn/large/0073X7Nbly1fntwsyxnt0j30fi0qqacf.jpg"></td><td><img width = "200px" height = "400px" src="https://ws1.sinaimg.cn/large/0073X7Nbly1fntwsw1rouj30fg0qodi7.jpg"></td></tr></table>

### 局部变量和全局变量
<table><tr><td>Less</td><td>Sass</td></tr><tr><td><img src="https://ws1.sinaimg.cn/large/0073X7Nbly1fntwzi2wicj30pm0f4whn.jpg"></td><td><img src="https://ws1.sinaimg.cn/large/0073X7Nbly1fntwzh8h1zj30ps0fgq67.jpg"></td></tr></table>

### 什么时候需要声明变量？
* 该值至少重复出现了两次
* 该值至少可能会被更新一次
* 该值所有的表现都与变量有关
* 没有理由声明一个永远不需要更新或者只在单一地方使用变量

### 嵌套 - 选择器
<table><tr><td>Less</td><td>Sass</td></tr><tr><td><img width = "200px" height = "300px" src="https://ws1.sinaimg.cn/large/0073X7Nbly1fntx2oo31nj30mo0na77r.jpg"></td><td><img width = "200px" height = "300px" src="https://ws1.sinaimg.cn/large/0073X7Nbly1fntx2qs64cj30q40ng774.jpg"></td></tr></table>

### 嵌套 - 属性
<table><tr><td>Less</td><td>Sass</td></tr><tr><td><img src="https://ws1.sinaimg.cn/large/0073X7Nbly1fntx5hrpwaj30l606ejsh.jpg"></td><td><img src="https://ws1.sinaimg.cn/large/0073X7Nbly1fntx5hyphhj30l8080wfm.jpg"></td></tr></table>

### 嵌套 - 伪类嵌套
<table><tr><td>Less</td><td>Sass</td></tr><tr><td><img src="https://ws1.sinaimg.cn/large/0073X7Nbly1fntx5i3dh8j30lq0jen06.jpg"></td><td><img src="https://ws1.sinaimg.cn/large/0073X7Nbly1fntx5i88i5j30la0jedie.jpg"></td></tr></table>

### Mixins (混合宏)
<table><tr><td>Less</td><td>Sass</td></tr><tr><td><img src="https://ws1.sinaimg.cn/large/0073X7Nbly1fntxaheqwoj30n00kin0g.jpg"></td><td><img src="https://ws1.sinaimg.cn/large/0073X7Nbly1fntxak5ku1j30my0ketcd.jpg"></td></tr></table>

### Parametric-Mixins (参数混入)
<table><tr><td>Less</td><td>Sass</td></tr><tr><td><img src="https://ws1.sinaimg.cn/large/0073X7Nbly1fntxcz0u3aj30ng0dwq55.jpg"></td><td><img src="https://ws1.sinaimg.cn/large/0073X7Nbly1fntxcz7mboj30nm0e0wgz.jpg"></td></tr></table>

### 选择器继承 
<table><tr><td>Less</td><td>Sass</td></tr><tr><td>Null</td><td><img width = "200px" height = "400px" src="https://ws1.sinaimg.cn/large/0073X7Nbly1fntxsqoiopj30p60kmn0e.jpg"></td></tr></table>

### Placeholder (占位符) 
<table><tr><td>Less</td><td>Sass</td></tr><tr><td>Null</td><td><img width = "200px" height = "400px" src="https://ws1.sinaimg.cn/large/0073X7Nbly1fntxsq6zjtj30ly0re41s.jpg"></td></tr></table>

### Mixins VS 继承 VS Placeholder
<table><tr><td>Mixins</td><td> 继承 </td><td> Placeholder </td></tr><tr><td><img width = "200px" height = "300px" src="https://ws1.sinaimg.cn/large/0073X7Nbly1fntxvwtmvej30dy0so78f.jpg"></td><td><img width = "200px" height = "300px" src="https://ws1.sinaimg.cn/large/0073X7Nbly1fntxvx0dvzj30e20swtcf.jpg"></td><td><img width = "200px" height = "300px" src="https://ws1.sinaimg.cn/large/0073X7Nbly1fntxvxbbdnj30e40sstcp.jpg"></td></tr><tr><td><img width = "200px" height = "300px" src="https://ws1.sinaimg.cn/large/0073X7Nbly1fntxxvjuvkj30e00li0vu.jpg"></td><td><img width = "200px" height = "300px" src="https://ws1.sinaimg.cn/large/0073X7Nbly1fntxxu3cqpj30ee0lg0vj.jpg"></td>
<td><img width = "200px" height = "300px" src="https://ws1.sinaimg.cn/large/0073X7Nbly1fntxxthq0gj30f40lk41b.jpg"></td></tr><tr><td colspan="3"><img width = "600px" height = "300px" src="	https://ws1.sinaimg.cn/large/0073X7Nbly1fntxzuoc74j31ao0lywja.jpg"></td></tr></table>

### 运算（+、-、*、/、颜色、字符串）
<table><tr><td>Less</td><td>Sass</td></tr><tr><td><img src="https://ws1.sinaimg.cn/large/0073X7Nbly1fnty6c0acpj30qe0g4aec.jpg"></td><td><img src="https://ws1.sinaimg.cn/large/0073X7Nbly1fnty6et6pxj30qc0g678j.jpg"></td></tr><tr><td colspan="2"><img src="https://ws1.sinaimg.cn/large/0073X7Nbly1fnty6g3l6cj31dy0fujyt.jpg"></td></tr></table>

### 条件语句(LESS中称作引导)  
<table><tr><td>Less</td><td>Sass</td></tr><tr><td><img width = "400px" height = "200px" src="https://ws1.sinaimg.cn/large/0073X7Nbly1fnty9d44q4j30pi0bcacy.jpg"></td><td><img width = "400px" height = "200px" src="https://ws1.sinaimg.cn/large/0073X7Nbly1fnty9br31dj30p40iqdjj.jpg"></td></tr><tr><td colspan="2"><img width = "400px" height = "200px" src="https://ws1.sinaimg.cn/large/0073X7Nbly1fnty9afksmj31400nkwmk.jpg"></td></tr></table>

## 开发中如何选择?
### 如何选择使用Less还是Sass?
* 相同点：两者都是CSS预处理器，都具有相同的功能，可以帮助我们快速编译代码，帮助我们更好的维护我们的样式代码或者说维护项目吧。
* 不同点：语法规则不同，当然功能略有差别
* 根据业务线需求、组内成员情况，进行约定

## 开发中如何组织?
### 开发中的组织
<table><tr><td><img width = "200px" height = "300px" src="https://ws1.sinaimg.cn/large/0073X7Nbly1fntydfbocbj30gi0umau6.jpg"></td><td><img width = "200px" height = "300px" src="https://ws1.sinaimg.cn/large/0073X7Nbly1fntydexr2yj30hm0uiqf2.jpg"></td></tr></table>

## 总结：
按需使用，随习惯所为！

> 相关参考
> http://lesscss.cn/
> https://www.sass.hk/