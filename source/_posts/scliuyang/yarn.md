title: js新的包管理工具yarn
date: 2016-11-30 16:32:00
categories: scliuyang
tags:
- yarn

---
2016年10月11日，facebook 公开了新的 javascript 包管理工具 yarn, 用来替代目前被广泛使用的 npm (nodejs 自带的包管理工具)，本文将介绍yarn工具带来的优点和使用入门。

<!--more-->
本文会介绍yarn的以下几个方面：
1. yarn对比npm解决了什么问题，带来哪些便利。
2. 获取yarn的正确姿势
3. yarn的使用入门（介绍一些常用的命令
4. 个人使用心得

# yarn对比npm的优点
根据[官方文档](https://github.com/yarnpkg/yarn)yarn具有6大优点

## 离线模式
yarn会有一个缓存目录，会缓存以前安装过的软件包，再次安装时就不必从网络下载了，大大加速安装速度。

这一点很重要，npm 饱受诟病的一点就是，每次安装依赖，都需要从网络下载一大堆东西，而且是全部重新下载，工程多的时候比较烦人。

我司部署node项目，是需要在发布机上install所有的依赖而且发布机的网络环境不是很好(不给搭梯子)，导致安装慢不说还经常失败(部分包需要联网编译)。更换yarn后只需将yarn的cache目录缓存起来，每次install嗷嗷的快，麻麻再也不用担心发布失败了。

## 依赖关系确定性

在每一台机器上针对同一个工程安装依赖时，生成的依赖关系顺序和版本是一致的。

之前 npm 在这里有一个处理得不好的地方 。举例来说，我写的工程依赖 A, B, C 三个库，我在编写 package.json 的时候，给 A, B, C 都指定了版本号。但是 A 库可能又依赖 D, E, F 库，D 库又依赖 G, H 库。这么多关联依赖关系中，很可能某个库在指定依赖时，没有指定版本号。

于是，这就导致了一个问题。如果我在另一台机器上对同样的工程安装依赖，或者把这台机器工程下的 node_modules 目录删除来重新安装依赖。由于关联依赖中，没有指定版本号的库，发生了版本更新，就会导致再次安装的依赖，其中具体某些软件包的版本是不一致的。在这种情况下，你会发现原来能够正常运行的程序，忽然变得不能工作或一堆 BUG.

npm对包引入顺序也十分的敏感，比如在一个空项目里执行以下命令

```
npm init -y
npm install globule@0.1.0 -S
npm install babel-generator@6.19.0 -S
npm install babel-helper-define-map@6.18.0 -S
```
我们这里安装了3个包都依赖于lodash，不过globule依赖lodash@1.0.3,另外两个依赖lodash@4.x。现在目录依赖结构如下
<img src="http://p1.bpimg.com/567571/d6e758cf0daca760.png" style="width:500px">

这时假设我们在项目里使用lodash，但是忘记重新安装lodash
```
var lodash = require('lodash');
console.log(lodash.VERSION); // v1.0.3
```
另一个同事获取项目代码，执行`npm install`,这时的目录依赖结构为
<img src="http://p1.bpimg.com/567571/4e045ea553b1e6d1.png" style="width:500px">
可以看到第一层依赖的lodash变成了4.x版本，这样就造成了依赖版本不一致的问题。而yarn则会保证无论怎样引入的顺序，目录依赖结构都是一致的，确保不会发生这样的BUG。

## 网络性能优化
下载软件时会优化请求顺序，避免`请求瀑布`发生

## 网络回弹
yarn在某个安装包请求失败时不会导致安装失败，它会自动去尝试重新安装。而npm则会毫不犹豫的失败，导致得再来一次，耗费时间

## 多注册来源
所有的依赖包，不管他被不同的库间接关联引用多少次，安装这个包时，只会从一个注册来源去装，要么是 npm 要么是 bower, 防止出现混乱不一致。

## 扁平模式

对于多个包依赖同一个子包的情况，yarn会尽量提取为同一个包，防止出现多处副本，浪费空间。比如1.2中，yarn会为babel-generator和babel-helper-define-map 创建同一个lodash子依赖，这样就节约一份的空间。

## 更多的emojis
表情包大战o(╯□╰)o
<img src="http://i1.piimg.com/567571/9821a5982fd73104.jpg" style="width:500px">

# 正确的安装姿势

注意yarn依赖node运行环境，官网提供了不同环境下的N种安装方法，[点我查看](https://yarnpkg.com/en/docs/install#alternatives-tab)。其中最重要的也是最通用的当然是`npm install yarn -g`，也不知道官网搞那么多幺蛾子的安装方式干嘛又是brew又是yum，还折腾半天。

# yarn常用命令介绍

## 创建项目
命令`yarn init`，[详细介绍](https://yarnpkg.com/en/docs/cli/init)

跟npm一样，会出现一个交互式的窗口，问一些package相关的问题

```
question name (testdir): my-awesome-package
question version (1.0.0): 
question description: The best package you will ever find.
question entry point (index.js): 
question git repository: https://github.com/yarnpkg/example-yarn-package
question author: Yarn Contributor
question license (MIT): 
success Saved package.json
✨  Done in 87.70s.
```
当然可以加参数 `--yes/-y` 来自动回答所有的问题(yes),便捷的生成一个package.json

## 管理依赖

注意，以下的命令都会自动更新你的package.json和yarn.lock文件

### 添加依赖
命令`yarn add [package]@[version/tag]`,[详细介绍](https://yarnpkg.com/en/docs/cli/add)

这会自动把包添加到package.json里的dependencies,也同时会更新yarn.lock

```
  {
    "name": "my-package",
    "dependencies": {
+     "package-1": "^1.0.0"
    }
  }
```

添加到不同的dependencies需要加如下参数
1. `yarn add --dev/-D` 添加到devDependencies
2. `yarn add --peer/-P` 添加到peerDependencies
3. `yarn add --optional/-O` 添加到optionalDependencies

### 更新依赖
命令`yarn upgrade [package]@[version/tag]`,[详细介绍](https://yarnpkg.com/en/docs/cli/upgrade)
更新某个依赖的版本，并自动更新package.json和yarn.lock文件

```
  {
    "name": "my-package",
    "dependencies": {
-     "package-1": "^1.0.0"
+     "package-1": "^2.0.0"
    }
  }
```

### 删除依赖
命令`yarn remove [package]`
删除某个依赖，并自动更新package.json和yarn.lock文件

## 安装依赖
命令 `yarn install`,[详细介绍](https://yarnpkg.com/en/docs/cli/install)

会从package.json里提取所有的依赖并安装，然后生成yarn.lock锁定所有的依赖版本，别人执行`yarn install`时会根据yarn.lock安装依赖，保证不同的电脑安装的依赖目录结构完全一致。

可选参数
1. `yarn install --flat` 有且仅有一个依赖的版本被允许，多依赖会出现一个交互式窗口，让使用者选择某一个版本安装
2. `yarn install --force` 强制重新下载所有的依赖包
3. `yarn install --production` 只下载dependencies下的依赖

## 全局命令
在yarn命令前加一个global修饰，可以将命令变为全局的，支持的命令有 add,bin,ls,remove,upgrade
例如`npm install gulp -g`,可以用`yarn global add gulp`来替代

# 个人使用心得
1. 更换安装源，使用阿里提供的npm register加速， `yarn config set registry 'https://registry.npm.taobao.org'`,当然如果npm已经配置过，yarn就无需再配置了。
2. yarn还有许多小问题，不过官方也在努力修复中，建议时不时使用`yarn self-update`来更新版本
3. 以前包锁定是使用`npm shrinkwrap`命令，感觉繁琐且难维护，使用yarn后自动生成锁定文件，简单方便

# 参考资料
[新的 js 包管理工具 yarn 解决了什么问题？](https://zhuanlan.zhihu.com/p/22967139)
[yarn cli doc](https://yarnpkg.com/en/docs/cli/)