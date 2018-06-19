title: 移动前端开发中的伪装术
date: 2018-5-30 12:00:00
categories: zhaojun
tags:
- 前端优化实践
- 移动端
- hybrid
- React Native
---
本文从一个web前端的角度讲述了在移动端开发中H5,Hybrid,react-native与原生应用的差距，探讨了如何将自己的应用，尽可能在UI，交互体验，流畅度方面去接近原生应用。

<!-- more -->

## 前言

去年双十一，中国客单占比中，有近90%的用户，使用移动设备下单。移动互联网在中国的普及程度可见一斑。正是因为用户终端的转变，前端攻城狮们的技能树也需要改变。

## 战场的转移

目前前端攻城狮（由于背景是针对原本的web前端，本文暂时不把ios和adr开发归入前端攻城狮的队伍中，虽然现在广义上来说app开发也属于前端开发）在移动端的主要战场有以下几个：

1. 普通浏览器网页的移动端响应式适配
2. 微信小程序（小米快应用）
3. hybrid
4. react native
5. PWA（暂时还是非主流）


用一个表格整理一下

|  | 流畅度 | 交互体验 | 开发学习成本 | 功能及限制 | 发布 |
| --- | --- | --- | --- | --- | --- |
| 移动端网页 | 最低 | 差 | 低，兼容性和响应式 | 需要浏览器运行，功能被浏览器限制 | 与web前端一致 |
| Hybrid（含小程序） | 低 | 较好 | 一套代码两端复用  | 通过JSBridge，SDK调用原生功能 | 通过热更新 |
| React Native | 高 | 好 | 一套代码两端复用，有个别组件和属性有平台差异 | 本身有组件和API可以调用部分原生功能，也可以用Bridge | 通过热更新 |
| 原生APP | 最高 | 最佳 | 学习成本大，需要开发ios端和adr端 | 无限制 | 有审核，版本兼容问题多 |


说了这么多，其实就是想表达，前端攻城狮们在移动互联网的浪潮下的追求，或者说方向其实就是希望让用户可以在使用上有原生app的交互体验。

## 原生APP的交互体验
那么到底什么原生app的交互体验，准确的说一个好的app到底会和一个移动端网页有什么样的区别，这种区别可以被磨平吗？原生app的在移动端上真的是前端攻城狮无法望其项背的么？前端攻城狮们如何把一个Hybrid或者RN的应用伪装成一个原生app呢？
### UI
实际上最直观的的区别就是UI上，app和网页在设计上其实是有很多各自的风格，当然这种风格上的差距是可以轻易磨平的，让一个网页做的像一个app那样对于UI和前端开发都不是难事。
UI的设计资源的保留在前端团队中很重要。比如说Ant Design提供的一些思路。字体，行高，空白的大小都可以固定为一些常量，这里就不赘述了。
简单说一下取色的过程。[参考链接](http://ant.design/docs/spec/colors-cn)
![](https://gw.alipayobjects.com/zos/rmsportal/msiCkgfDaDgrTUuumxlq.png)
一般来说在前端开发过程中，一个应用多数是会有主色，辅助色，强调色。而在实际的应用中例如图中蓝色的主色又会衍生为hover，click，disable之类的几种状态，UI在团队中无法兼顾所有的应用，此时自动通过一个颜色，衍生出多种色彩就显得很重要。除了通过类似antd的取色板帮助取色外，也可以通过代码的手段。衍生颜色的过程其实就是HSV颜色空间的变化。这里不详述这一点了。


### 交互感
这个词看起来很抽象，具体的来说比如说按钮或卡片的交互感，按下后有波纹式的背景颜色变化。列表或者页面下拉上拉时不仅列表的动画和触发响应的动作和动作的弹性。页面跳转时候进出的动画，tab或者卡片切换时的动画。
还有很多优秀的细节就不一一举例了，此时就有重要的需求扔给前端攻城狮了，能不能实现这些交互感。
首先一个移动端的交互习惯是跟随一个组件的，比如按钮的touch交互，列表的滚动交互，卡片的drag交互。所以说这些交互的模式和动画可以利用UI、UE积累的设计资源沉淀到组件中，假设这些交互动画都可以流畅的实现，并且形成一套移动端的组件库，那么用这套组件库开发出来的应用也可以用优秀的交互感。比如说rn官方提供的[TouchableNativeFeedback组件](https://reactnative.cn/docs/0.51/touchablenativefeedback.html#content)，就实现了可以实现涟漪状的波纹。
另一个问题就是交互动画的流畅度能不能和原生应用媲美呢。由于手机的性能瓶颈，目前前端在移动端的动画很多场合下是需要在意性能问题的。就动画层面是有一些手段尽可能的提升流畅度的：
1. 动画竟可能使用transform，而非直接操作dom
2. 必要情况下使用will-change或者transform3D()去让webview调用GPU做渲染
3. 如果有dom操作考虑回流和重绘的优化。[可参考](http://xgfe.github.io/2018/04/15/zhangjianfeng/web%E5%89%8D%E7%AB%AF%E6%80%A7%E8%83%BD%E4%BC%98%E5%8C%96/)
4. 防抖和节流，优化一些频繁操作

RN实现动画的话，则可以通过Animated库实现流畅又好看的动效。[RN动画参考](https://reactnative.cn/docs/0.51/animations.html)


### 手势操作
多点触控可以组成一系列的手势操作，这个是智能机的一大体验优势，原生的app可以很好的支持手势事件，做出流畅的交互体验。js也可以通过touch库去监听到手势，并作出交互；另外在RN上对手势则有天然的支持。[参考链接](https://reactnative.cn/docs/0.51/gesture-responder-system.html#content)

### 渲染
下图是一个react的Hybrid项目在webview中渲染出来的过程
![](http://ww1.sinaimg.cn/large/6f3ac581gy1frt5z11h1kj20ta088q37.jpg)

基于这个过程有以下一些加速方案，主要分为两类，网络类和渲染类。
首先是网络类

* 在兼顾APP包大小的前提下，将一部分资源放入离线包
* 采用HTTP缓存，减少资源的重复请求
* 拆分快慢接口，首屏展示时尽可能不要先请求慢接口
* 升级到HTTP2，多路复用
* dns 寻址优化
* 本地数据缓存，先使用本地数据渲染页面，然后等线上数据更新下来后再更新视图。
* 缓存的差分更新
* 减少cookie的传输

附上一个[美团大众点评Hybrid](https://zhuanlan.zhihu.com/p/24202408)资源预加载的方案
![](https://pic2.zhimg.com/80/v2-4a3b24ba6335c2f5baf5f6bc958e4674_hd.jpg)

渲染类

* 在页面拿到基础的dom结构后，优先用占位符的方式，尽快缩减页面渲染的体感市场
* MVVM框架中减少不必要的的dom更新
* 首屏渲染的直出
* 尽可能减少webview中的js代码，让webview专一的处理渲染工作，业务和框架js放入jscore中，webview和jscore通过桥通信更新dom节点

#### webview与jsCore
微信小程序就是二者分离的典型实践。微信小程序直接进行平时前端的DOM操作是不支持的，原因就是脚本的运行环境是JSCore并不支持DOM和BOM对象。微信小程序对MVVM模式在Hybrid上给出的最佳实践就是：业务脚本，虚拟dom的diff交给JSCore，让webview可以专心致志的去完成DOM的渲染，事件监听，DOM的更新工作。
Hybrid一个桥连接webview和native的实践很常见，如果像微信一样用到webview和jscore的话需要两个桥。
![](http://ww1.sinaimg.cn/large/6f3ac581gy1frtbophcnfj20g503xmx5.jpg)
JSBridge实际上可以算作是一个[EventEmitter](https://segmentfault.com/a/1190000014206309)的变形。
JS部分的核心接口的伪代码

```js
//注册函数，用于被native调用
const addListener = function(type, fn) {
    if (!isFunction(fn)) return;//判断是否在监听中添加的是合法的函数
    //判断type是否添加过，添加过一个还是多个函数
    if (this.event[type]) {
        if (isArray(this.event[type])){
            //如果想要实现preadd将push改为unshift即可
            this.event[type].push(fn);
        } else {
            //如果想要实现preadd改变顺序
            this.event[type] = [this.event[type], fn];
        }
    } else {
        this.event[type] = fn;
    }
}
```
以下是向native发送消息的postMessage函数，核心的信息是option

* name: 对应了在addListener中的type
* data: 给native中传递的数据
* callback: 回调函数

```js
//postMessage是用于调用native
const nativeBridge = getBridge();//根据平台获取bridge
const postMessage = function (option) {
    const id = createID(option.name);//生成唯一id
    addListener(id, option.callBack);
    nativeBridge.post({
        name: option.name,
        data: option.data,
        cbId: id
    });//通知native
}
```

```js
const receiveMessage = function(option) {
    const handle = this.event[option.cbId];
    Promise.resolve(handle.call(null, option.message)).then((...args) => {
        postMessage({
            name: option.name,
            data: args
        });//执行native的回调
})

}
```

利用两个桥在JSCore中可以在执行业务逻辑代码，及虚拟dom diff后将需要进行dom修改结果通过告知native
Option可以如下

```js
{
    name: 'domUpdate',
    data: {
        pageId: 'xxx',
        componentId: 'xxx',
        children: [{
            type: 'text',
            content: '换了换了'
        }, {
            type: 'span',
            children: [{
                type: 'text',
                content: '我也换了'
            }]
        }],
        type:
    },
    callback: function() {console.log('updateDown')}
}
```

native发现是domUpdate后通知webview的DomUpdate，根据page，component及data 进行dom的更新

以上就是利用JSCore进行渲染加速的一点思路。


## 总结
在做Hybrid项目和RN项目中，更多的关注性能和体验，渲染层面的优化很多需要整体方案的革新或者整个框架的支持，不过在组件层面交互的优化是性价比最高，也相对容易实现的手段。这就需要在移动端的业务开发工作中积累组件，雕琢交互体验。

