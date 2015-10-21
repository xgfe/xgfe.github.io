title: Vim使用xg-htmlhint配置教程
date: 2015-10-21
categories: HeOH
tags: 
- vim
- htmlhint

---


&emsp;&emsp;在[《HTML代码检查工具实践》](http://xgfe.github.io/blog/2015/10/08/yangjiyuan/html-hinting-tool/)中对xg-htmlhint进行了详细的介绍。本文主要针对vim使用xg-htmlhint工具需要的配置安装进行了说明。
<!-- more -->  

## 安装xg-htmlhint  

```
 npm install -g xg-htmlhint  
```

## 编辑配置文件.vimrc


打开vim的配置文件(默认路径)：

```
vim ~/.vimrc
```
在配置文件末尾添加：

```
autocmd BufWritePost,FileWritePost *.html   ks|call AutoRun()|'s
fun AutoRun()
    let file = bufname('%')
    w !cat %:p > htmlhint.html
    w !htmlhint htmlhint.html
    w !rm htmlhint.html
endfun
```

用vim编辑.html文件时，每次保存时都会用htmlhint自动编译该文件，效果如下。

![htmlhint-vim](/blog/uploads/htmlhint-vim.gif)

## 参考链接  

- [vim用户手册](http://man.chinaunix.net/newsoft/vi/doc/help.html)  

- [xg-htmlhint的github主页](https://github.com/yangjiyuan/xg-htmlhint)  

## Tips  

- 针对shell命令无法调用vim参数的变通做法。