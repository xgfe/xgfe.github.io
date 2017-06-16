title: cocos2d-Js 基础入门
date: 2017-05-15 16:30:00
categories: jakii
tags: 
- javascript
- cocos2d-x

---
![](http://oprp8vydn.bkt.clouddn.com/2017-05-15-14948390188781.jpg)

cocos2d-x是一个广泛流行的2D跨平台游戏引擎。采用c++作为开发语言。而cocos2d-Js是cocos2d-x采用脚本绑定技术实现的采用JavaScript语言作为开发语言的版本。


本博客主要内容分为三部分：

- 环境搭建
- 核心概念
- 相关扩展

<!-- more -->

## 环境搭建
### 概述
cocos2d-x是一个广泛流行的2D跨平台游戏引擎。采用c++作为开发语言。而cocos2d-Js是cocos2d-x采用脚本绑定技术实现的采用JavaScript语言作为开发语言的版本。
### 设计目标
![](http://oprp8vydn.bkt.clouddn.com/2017-05-15-14944929318503.jpg)

cocos2d-x的设计目标是横向兼容各个不同的平台，包括多种手机平台和pc平台。纵向支持c++、js、lua多种语言
编写代码，而且支持canvas，openGl渲染等

### 开发环境搭建
* 下载安装webstorm，作为开发IDE
* 安装chrome插件jetBrains IDE Support
* 下载cocos官方核心包
* 配置cocos2d-x环境
    * 安装python2.x版本
    * 安装Apache Ant工具
    * 安装其它诸如安卓sdk等特定环境的sdk等
    * 运行python setup安装cocos工具
    
按照系统提示把上面步骤进行完成后，就可以进行项目的开发了
### 一个简单的实例 helloWorld

```js
创建项目:cocos new helloWorld -l js
运行项目:cocos run -p web|ios|android|mac|win32
打包:cocos compile -p web|ios|android|mac|win32 -m release
```
创建生成的目录如下
![](http://oprp8vydn.bkt.clouddn.com/2017-05-15-14944957996388.jpg)
frameworks是cocos2d-x的源文件，我们使用的一些库和API都是里面定义的。
res目录存放我们的资源文件，包括图片、音频、字体等资源。
src目录主要存放我们的代码，是我们主要的工作区域，我们的代码逻辑和资源引入都在此处进行。
index.html文件主要是用于web端的主页面，main.js主要是游戏启动，以及一些对页面的设置问题。
project.json主要是一些项目设置，以及js文件的引入

```js
//在index.html中,由于浏览器的兼容性问题，采用canvas来渲染，此处定义屏幕大小
<canvas id="gameCanvas" width="480" height="720"></canvas>

//在main.js中，此处代码用来加载游戏资源，同时用导演对象启动游戏
cc.LoaderScene.preload(g_resources, function () {
    cc.director.runScene(new HelloWorldScene());
}, this);

//在project.json中，jsList数组用于加载js资源
"jsList" : [
    "src/resource.js",
    "src/app.js"
]
```
## 核心概念
### 导演
![](http://oprp8vydn.bkt.clouddn.com/2017-05-15-14945711804166.jpg)
导演cc.director是整个游戏工程的管理者，可以称它为大总管，采用单例模式，也就是说，不管在游戏里面任何一个场景访问它获取到的都是一个对象。
它的主要职责是访问和切换游戏场景，访问一些API配置信息，暂停、继续、结束游戏，转换坐标等
### 场景scene
场景scene是构成游戏的界面，类似于电影中的场景。继承于node，是层layer的容器。
主要分为三类场景。
* 展示类场景:主要展示一些视频、游戏介绍等
* 选项类场景：主要是主菜单、设置选项等场景
* 游戏主场景：游戏运行的主要场景，是游戏中最重要的场景
### 层layer
![](http://oprp8vydn.bkt.clouddn.com/2017-05-15-14945723879457.jpg)
层是场景的重要组成部分，一个场景由一个或多个层铺叠而成，就如同上图一样，一个游戏开始界面由三层组成，最下面的背景层，中间的精灵层和最上面的菜单层，层相互叠加最终组成最终的游戏界面。
需要注意的是，层之间是有顺序的，与此同时，层继承与node，而且是精灵的容器，可以随意存放精灵。

### 精灵
![](http://oprp8vydn.bkt.clouddn.com/2017-05-15-14945729564081.jpg)
精灵是游戏中极其重要的一部分。比如在坦克大战游戏中，坦克、子弹、增益物品等对象都是精灵，可以说游戏编程其实就是面对精灵编程。在整个游戏中我们会创建很多很多的精灵。

### Node究竟是什么？
从上面的简要介绍中我们可以看出，包括场景，层，精灵等很多元素都继承于Node，那么Node究竟是什么呢？
![](http://oprp8vydn.bkt.clouddn.com/2017-05-15-14945743415606.jpg)
熟悉web开发的人应该对上面这张图应该并不陌生，在web开发中，html是最上层的节点，然后按层依次管理其对应的子节点。与之类似，在cocos2d-x中，节点管理也是采用类似的方式。场景是最外层的容器，类似于html节点，采用树形结构依次管理对应的层和精灵。其中所有的节点均继承自Node，具有Node的所有属性和方法。
其中，Node的常用属性和方法如下所示

```
1.重要操作
    - var node=new cc.Node();//创建节点
    - node.addChild(childNode,0,123);//子节点，层级，标签
    - var childNode=node.getChildByTag(123);
    - node.removeChildByTag(123,true);移除子节点及其相关动作
    - node.removeChild(childNode,true);移除子节点及其相关动作

    
2.重要属性
    - position  node在场景中的实际位置
    - anchorPoint(0.5,0.5); 锚点，node相对position的比例，也是运动的不动点
    - anchorPoint=(w1/w,h1/h);
    
    node.setPosition(x,y);
    node.setAnchorPoint(0.5,0.5);
```
### 事件循环与调度
我们知道，跟拍电影类似 整个过程是由一帧一帧的图片连续播放而成。cocos2d-x游戏工程也是基于不断的刷新重绘页面的原理制作而成的。在整个游戏的过程中，引擎会基于特定的帧率(默认60帧)来不断更新游戏页面。

```
//让游戏进行循环
scene.scheduleUpdate();

update:function(dt){
    //执行循环代码
}
```
正如上面的代码，当某个场景(层)调用`scheduleUpdate()`这个函数，就会启用工程的刷新机制，会不断调用当前对象对应的`update()`函数，从而达到更新游戏的目的

### 标签与菜单
在游戏中，我们可以看到上面会有各种各样的文字和菜单，比如坦克大战中坦克的数量，杀敌数等数据，以及开始游戏时候的开始游戏，结束游戏等菜单。

#### 标签

>`cc.LabelTTF`使用系统字体来定义文字

```
var helloLabel=new cc.LabelTFF("hello world","Arial",38);


//如果使用的是第三方字体，需要将字体文件加入resource.js中
varg_resources=[{
    type:"font",
    name:"Courier New",
    srcs:["res/fonts/Courier New.ttf"]
}];
```

>`cc.LabelAtlas`图片集标签，这种标签的文字是从一个图片集中取出来的，需要额外加载图片集文件，比前者快许多

```
//图片集需要在资源文件中定义
var helloLabel=new cc.LabelAtlas("hello world",res.charmap.png,48,46,"")
```

>`cc.LabelBMFont`使用位图字体来添加字体，它比前两者速度要快得多

```
//资源文件中需要定义字体文件
var helloLabel=new cc.LabelBMFont("hello world",res.BMFont_fnt)

```
#### 菜单
菜单分为三种，分别是文本菜单、精灵菜单、开关菜单

```
//文本菜单
cc.MenuItemFont.setFontName("Times New Roman");
cc.MenuItemFont.setFontSize(86);

var item1=new cc.MenuItemFont("Start",this.menuItem1CallBack,this);

//精灵菜单与图片菜单
var startSpriteNormal = new cc.Sprite(res.start_up_png);
var startSpriteSelected = new cc.Sprite(res.start_down_png);
var startMenuItem = new cc.MenuItemSprite(
            startSpriteNormal,
            startSpriteSelected,
            this.menuItemStartCallback, this);

var settingMenuItem = new cc.MenuItemImage(
            res.setting_up_png,
            res.setting_down_png,
            this.menuItemSettingCallback, this);
            
//开关菜单
var soundOnMenuItem = new cc.MenuItemImage(
            res.On_png, res.On_png);
var soundOffMenuItem = new cc.MenuItemImage(
            res.Off_png, res.Off_png);
var soundToggleMenuItem = new cc.MenuItemToggle(
            soundOnMenuItem,
            soundOffMenuItem,
            this.menuSoundToggleCallback, this);
```
### 动作与动画

#### 动作
>属性变化动作，其中position可以是cc.p(x,y)，也可以是x

```
//直线移动
- cc.moveTo(duration, position, y); 
- cc.moveBy(duration, position, y);

//跳跃移动，jump为跳跃次数
cc.jumpTo(duration, position, y, height, jumps); 
cc.jumpBy(duration, position, y, height, jumps);

//贝塞尔曲线运动，cc.BezierTo cc.BezierBy
var size=cc.winSize;
var control = [
    cc.p(0, size.height),
    cc.p(size.width, size.height),
    cc.p(size.width, 0)
];

cc.bezierTo(duration, control); 
cc.bezierBy(duration, control);


//cc.ScaleTo cc.ScaleBy缩放

//cc.rotateTo和cc.rotateBy旋转

```
>视觉特效动作

```
//淡入淡出  cc.FadeIn cc.FadeOut cc.FadeTo
var fadeOut = cc.fadeOut(1);
var fadeIn = cc.fadeIn(1);
var fadeTo = cc.fadeTo(1, 128);
node.runAction(cc.sequence(fadeOut, fadeIn, fadeTo));



//闪烁 cc.blink,1s时间闪烁10次
var actionBlink = cc.blink(1, 10); 
node.runAction(actionBlink);


//cc.Animation 自定义帧动画 参数:帧对象、间隔时间、循环次数
var animation = new cc.Animation(frames, delay, loops);
//实例
var animation = new cc.Animation(); // 创建动作
animation.addSpriteFrameWithFile(res.sh_node_64_png);
animation.addSpriteFrameWithFile(res.sh_node_128_png);
animation.addSpriteFrameWithFile(res.sh_node_256_png);
animation.addSpriteFrameWithFile(res.sh_node_512_png);
animation.setDelayPerUnit(0.15); // 设置间隔时间
animation.setRestoreOriginalFrame(true); // 设置是否回复到第一帧
var animate = cc.animate(animation); // 通过cc.animate将animation封装成动作 
node.runAction(animate);

```
>复合动作

```
//cc.DelayTime延时动作，只起到延时作用
cc.delayTime(duration);


//cc.Repeat cc.RepeatForever 重复执行
//用0.5s旋转节点90度 
var rotate = cc.rotateBy(0.5, -90);
var repeat = rotate.repeat(4); //  重复4次 
node.runAction(repeat);
 
var rotate = cc.rotateBy(0.5, -90);
var repeat = rotate.repeatForever();//一直重复
node.runAction(repeat);



//cc.Sequence 有顺序执行动作
//cc.Spawn同步执行动作
```

### 动画
>此处主要介绍帧动画，骨骼动画制作较为复杂，此处不做介绍

```
//cc.Animation 自定义帧动画 参数:帧对象、间隔时间、循环次数
var animation = new cc.Animation(frames, delay, loops);
//实例
var animation = new cc.Animation(); // 创建动作
animation.addSpriteFrameWithFile(res.sh_node_64_png);
animation.addSpriteFrameWithFile(res.sh_node_128_png);
animation.addSpriteFrameWithFile(res.sh_node_256_png);
animation.addSpriteFrameWithFile(res.sh_node_512_png);
animation.setDelayPerUnit(0.15); // 设置间隔时间
animation.setRestoreOriginalFrame(true); // 设置是否回复到第一帧
var animate = cc.animate(animation); // 通过cc.animate将animation封装成动作 
node.runAction(animate);
```
### 事件
在cocos2d-x中，事件主要分为鼠标事件，触摸事件，键盘事件和自定义事件等。此处简要介绍以下单点触摸事件和鼠标事件
![](http://oprp8vydn.bkt.clouddn.com/2017-05-15-14948319177139.jpg)
如上代码所示，首先检测是不是触摸事件，如果是，则在事件管理器中添加单点触摸事件，并绑定move时的触发函数。如果不是触摸事件，则在事件管理器中添加鼠标事件，并绑定相关触发函数

### 音频处理
>在`cocos2d-x`中，音频控制主要是在`cc.audioEngine`中控制的，以下是相关的API，直接调用即可。不过需要注意的是，相关音频必须在res目录中且被代码引入

![](http://oprp8vydn.bkt.clouddn.com/2017-05-15-14948325815436.jpg)

### 数据存储
我们都知道，除了那种特别简单的游戏，一般都是需要存储游戏数据。在cocos2d-x阴影中当然也不例外。通常来说，如果游戏数据存储在本地，我们一般采用localStorage方法，将数据存储在本地。
如果数据需要存储在服务端，自然而然要存放在数据库中，在客户端与服务端交换数据时候可以采用json形式
![](http://oprp8vydn.bkt.clouddn.com/2017-05-15-14948330435333.jpg)

## 相关拓展
开发一个游戏当然远远不止上面展示的那么简单，里面牵扯到的内容还有很多很多，以下简要介绍一下cocos2d-x开发游戏需要了解到的技术点，当然，我所提到的只是九牛一毛，开发游戏水很深，需要大家持续不断的去学习，去努力

* 物理引擎
* 性能优化
* 3D特性
* 网络通信
* 多平台移植
* 屏幕适配
* 瓦片地图
* 粒子系统
* 骨骼动画










