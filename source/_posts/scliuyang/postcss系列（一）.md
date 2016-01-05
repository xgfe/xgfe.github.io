title: postcss系列一：初识postcss
date: 2016-1-5 16:32:00
categories: scliuyang
tags:
- postcss
---  

postcss系列一，初步认识postcss，了解postcss工具的强大之处

<!--more-->

# postcss系列一：初识postcss

## 什么是postcss

> PostCSS is a tool for transforming styles with JS plugins. These plugins can lint your CSS, support variables and mixins, transpile future CSS syntax, inline images, and more.

这是摘自postcss的github上的一句话，它很好的解释了postcss作为一个css(不仅仅限于css语法，比如说sass)转换工具，将css转化为AST（抽象语法树）然后交给postcss-plugins进行进一步处理的工具。

本质上来说postcss对css文件仅仅只是进行语法分析，真正的核心操作依赖于postcss庞大的[插件群体](https://github.com/postcss/postcss/blob/master/docs/plugins.md)，比如说进行css语法验证，压缩；支持变量和混入语法

## postcss不单纯是预处理器也不是后处理器

postcss可以像预处理器一样支持变量和语法混入，也可以通过插件支持css未来语法[cssnext](http://cssnext.io/),这样看来postcss确实是一个预处理无遗。但是postcss也支持后处理器的功能，比如说通过[autoprefixer](https://github.com/postcss/autoprefixer)结合[Can I Use](http://caniuse.com/)来完成浏览器私有前缀的添加工作。

所以postcss可以看做是一个处理器，通过插件可以扩展处理器的功能使其变成一个预处理或后处理的工具

## 为什么要使用postcss

### 有庞大的插件支持

postcss的火爆使得它有全球大量的工程师为它编写各种各样的插件，详情请看[plugin-list](https://github.com/postcss/postcss/blob/master/docs/plugins.md)。

其中有大家熟悉的添加私有前缀插件，也有支持未来css语法的cssnext等等...

### 模块化

postcss的具体功能依赖于你所使用的插件，你可以根据你的喜好添加或删除某些功能。

如果仅想用PostCSS让CSS是更有效率和让浏览器更友好的话，加载一些优化插件，你就可以闪人了。

如果仅想用PostCSS作为预处理器的话，使用一些语言扩展插件就OK。

PostCSS的基本原理是粒子化，模块化。简而言之，没有处理多个功能的笨重插件。相反，每创建一个插件，就是一个功能。

### 简单的插件编写工作

PostCSS是用JavaScript编写的插件，这样只要能编写JavaScript的就可以创建一个自己想要的插件，达到自己的目的。值得庆幸的是，就算你不是专业的JavaScript开发人员，但使用PostCSS开发插件也就只需要短短的几个小时，就可以开发出一个全功能的插件。

### postcss可以和你现在的工具无缝拼接

postcss 支持命令行模式，也可以和当前的grunt,glup等等结合在一起使用，方便快捷