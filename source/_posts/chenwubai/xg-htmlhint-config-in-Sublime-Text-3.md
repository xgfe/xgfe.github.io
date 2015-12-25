title: Sublime Text 3使用xg-htmlhint配置教程
date: 2015-10-20 16:32:00
categories: chenwubai
tags:
- htmlhint
---

&emsp;&emsp;在[《HTML代码检查工具实践》](/2015/10/08/yangjiyuan/html-hinting-tool/)中对xg-htmlhint进行了详细的介绍。本文主要针对Sublime Text 3使用xg-htmlhint工具需要的配置安装进行了说明。该教程只针对Sublime Text 3，在Sublime Text 2中可能会安装出错。  
<!-- more -->  

### 安装[Package Control](https://github.com/wbond/package_control)  
&emsp;&emsp;Sublime安装插件有两种方式，一种是直接下载安装包解压缩到Packages目录，另一种是通过Package Control组件来安装组件，后者更加的方便。  

- 打开Sublime，按control + ` 打开控制台，粘贴如下代码到命令行并回车；  
	
		import urllib.request,os; pf = 'Package Control.sublime-package'; ipp =   sublime.installed_packages_path(); urllib.request.install_opener( urllib.request.build_opener( urllib.request.ProxyHandler()) ); open(os.path.join(ipp, pf), 'wb').write(urllib.request.urlopen( 'http://sublime.wbond.net/' + pf.replace(' ','%20')).read())  

- 重启Sublime，在Perferences->Package Settings 中看到 Package Control，则表示安装成功。  

### 安装[SublimeLinter](https://github.com/SublimeLinter/SublimeLinter3)  

&emsp;&emsp;SublimeLinter是Sublime的一个代码检测工具插件。  

- 打开Sublime，按下 Ctrl+Shift+p 进入 Command Palette;  

- 输入install进入 Package Control: Install Package;  

- 输入SublimeLinter，选择SublimeLinter进行安装。  

### 安装[sublimeLinter-contrib-htmlhint](https://github.com/mmaday/SublimeLinter-contrib-htmlhint)  

&emsp;&emsp;可以把sublimeLinter-contrib-htmlhint看成是SublimeLinter的一个插件，sublimeLinter-contrib-htmlhint调用xg-htmlhint来进行语法检查。sublimeLinter-contrib-htmlhint 1.0.1版本有问题，所以我们使用1.0.0版本。  

- 前往[Releases](https://github.com/mmaday/SublimeLinter-contrib-htmlhint/releases)下载1.0.0的压缩包，解压并重命名为“SublimeLinter-contrib-htmlhint”，并放入Sublime的Package目录(菜单->Preferences->Browse Packages)  

### 安装[xg-htmlhint](https://github.com/yangjiyuan/xg-htmlhint)  

- npm install -g xg-htmlhint  

&emsp;&emsp;此时打开Sublime Text3，xg-htmlhint就可以检测代码了，保存(cmd + S)的时候如果有错误会有错误提示。  

### 参考链接  

- [代码校验工具 SublimeLinter 的安装与使用](http://gaohaoyang.github.io/2015/03/26/sublimeLinter/)   

- [那些年我使用过的 Sublime Text 3 插件](http://bubkoo.com/2014/01/04/sublime-text-3-plugins/) 

### 致谢  

&emsp;&emsp;除了参考链接，在这里特别感谢团队乐乐小公举(·_·)的帮助。