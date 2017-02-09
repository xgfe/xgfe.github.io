title: React Native ART介绍
date: 2017-02-07 17:33:09
categories: TinySymphony
tags:
- React Native
- ReactART

---

### React Native ART 由来

`react-art`是reactjs团队基于`art`（一个兼容各个浏览器SVG绘制的API封装）开发的模块，让react开发者能使用jsx语法绘制svg.

react native团队分别在0.10.0和0.18.0也添加了iOS和Android平台对react-art的支持，RN在本文写稿时已经发版至`0.41.0`，官网文档至今对其只字未提。本文旨在介绍安静躺在`react-native/Libraries/`里的`ART`，并展示一些实践结果。

<!-- more -->


### ART能干什么

俗话说，**库如其名**，背负着如此具有“艺术感”名字的ART生来就是为了绘制矢量图的，或者说是“画”UI的。

在web页面开发时想必大部分前端工程师都使用过svg格式的切图，矢量保证了图片的高清无码而且较小的文件体积对页面加载速度十分友好。并且svg绘图的另一个极大优点是其自身在dom树中能绑定事件，为数据可视化领域所青睐。

React Native开发者是无法直接使用矢量图的，`<Image>`标签不支持svg格式的资源。目前使用矢量图标的一个选择是[react-native-vector-icons](https://github.com/oblador/react-native-vector-icons)这种icon font形式的实现。

另一条路就是ART。ART相比于`<Image>`标签的最大优势是同步渲染，`<Image>`标签在官网文档的描述中有这样一句：

> Image decoding can take more than a frame-worth of time

图片的解码由于不在主线程中进行，所以不能确保所有图片和内容在同一帧内出现。使用`<Image>`标签的制作的组件这就很尴尬了，整个组件里的图（比如icon）可能是三三两两“闪现”出来的，让人怀疑是个`webview`，体验远不如原生。

此外ART和icon-font一样，让开发者摆脱了针对`<Image>`提供`@2x`/`@3x`图的麻烦。

### 上手ART

> 注：本文所用RN版本`0.40.0`

#### 事先准备

1. ART在iOS上使用需要事先导入ART的链接库，找到`node_modules/react-native/Libraries/ART/ART.xcdoeproj`拖入Xcode对应项目的`Libraries`
2. 打开`General Settings`添加`libART.a`到`Linked Frameworks and Libraries`列表
3. `cmd+b`重新构建项目

#### 基本API

> [ART文档 (非官方)](https://github.com/react-native-china/react-native-ART-doc/blob/master/doc.md) 在github上有这样比较全一篇文档，可以选择直接看它了解使用。

ART目前只提供以下几个API（打印属性窥视到的...）：

前四个属性是以`ReactComponent`为原型的对象，可推断是作为jsx标签使用的。

* `Surface`标签对应svg中的`svg`标签，所有ART的jsx内容需要被其包含
* `Group`标签对应`g`标签
* `Shape`标签对应`path`标签
* `Text`标签对应`text`标签
* `Transform`做图形变换的API
* `Path`绘制路径API
* `LinearGradient`创建线性渐变API
* `RadialGradient`创建径向渐变API
* `Pattern`疑似`pattern`标签做图片填充的API，使用标准格式推测为`new Pattern(url, width, height, left, top)`
* `ClippingRectangle`意义不明，可能和`clipPath`接近，定义一个蒙版

可以看到ART和svg还是有不同的，有点像是阉割后的svg，没有诸如`path`/`rect`/`animate`/`circle`/`ellipse`的标签。

当然已经有开发者做了实现，可以方便地使用svg标签写ART => [react-native-svg](https://github.com/react-native-community/react-native-svg)

不过本文后续的例子还是使用原原本本的ART实践。

#### ART基础使用栗子

基本的几个案例如下：

``` js
// 后面例子的引入会省略
import {ART} from 'react-native';
const {
  Surface,
  Group,
  Shape,
  Path,
  Transform
} = ART;

// 绘制ART图像
function drawVector() {
  return (
    <Surface width={300} height={400}>
      <Group x={0} y={0}>
        <Shape
          scale={1.0}
          stroke={"#ff0"}
          strokeWidth={4}
          d={generateSvgPath()}
          transform={new Transform().translate(150, 150).rotate(30, 100, 100).scale(3, 2)}
        />
      </Group>
    </Surface>
  );
}

```

`Surface`必须是ART内容的父层，并且其中不能包含非ART标签（否则直接闪退...），需要指定宽高。

`Group`可有可无，当绘制内容较多时可以用其统一管理，可以把它当做`View`标签使用，可制定内容在画布绘制的起点。

`Shape`是目前ART绘制的一把手，`d`属性对标svg的`path`标签上的`d`属性。

所有的ART标签都可以使用`transform`属性做变换，值是由 `Transform` API 生成的，上面链式调用就是确定其移动位置/旋转/缩放。

由于ART和svg的区别，如果需要从svg图转成ART代码，这个svg图最好全由path组成或者全部转成路径的写法。
这点其实很尴尬，也是开源社区出现上节提到的那个模块的主要原因。不过估计RN团队之后可能会做新的ART标签支持。

上面例子中的`generateSvgPath`是一个插值计算、返回路径字符串的一个函数，如果有现成的svg代码可以选择这么做，下面的例子则是利用ART的 `Path` API 构造一段路径，更有绘制的感觉。

``` js
// 使用Path生成圆形
function circlePathRender() {
  var path = Path().moveTo(0,100)
    .arc(0, radius * 2, radius)
    .arc(0, radius * -2, radius)
    .close(); // 闭合路径
  // 构造而成的path可以直接复制给d属性
  return <Shape d={path} fill={'#2ba'}/>
}
```

``` js
// 绘制多边形
function polygonPathRender() {
  var path = Path().moveTo(10, 10)
    .lineTo(20, 30)
    .lineTo(30, 40)
    .lineTo(10, 60)
    .lineTo(0, 50)
    .lineTo(-20, 40)
    .close(); // 闭合路径
  return <Shape d={path} fill={'#00a'} stroke="yellow" strokeWidth={4}/>
}

```

`Path`的各种方法很接近svg标准，除了上面出现的`lineTo`/`moveTo`/`arc`之外，还有`arcTo`/`curve`/`line`等API
满足日常绘制需求。

```js
// 绘制文字
function textRender() {
  return (
    <Text
      font={`bold 13px "Helvetica Neue", "Helvetica", Arial`}
      fill="#749"
      x={0}
      y={0}
    >
      Lorem ipsum dolor sit amet
    </Text>
  );
}
```

上面的例子绘制文本，`font`属性可以选择使用对象`{fontWeight: 'bold', fontSize: 13, fontFamily: 'Helvetica,Neue Helvetica,Arial'}`代替。

目前都使用一个固定的rgb值填充ART图像，`LinearGradient`和`RadialGradient`给我们像css一样用渐变色的选择。

* 线性渐变

``` js
// linearGradient 可赋值给Path或者Text标签的fill属性
var linearGradient = new ART.LinearGradient({
  "0": "#2ba",
  ".5": "#f90",
  "0.7": "#aa4422",
  "1": "rgba(255,255,255,0.5)"
}, 0, 0, 100, 200);
```
`LinearGradient`构造函数第一个参数是设定渐变色的对象，使用诸如`0.3`/`.52`/`1`这样的属性表示`30%`/`52%`/`100%`，值为颜色值，不符合要求的键值对会被忽略。
后面四个参数分别表示：起点x，起点y，终点x，终点y.

* 径向渐变

```js
// radialGradient 可赋值给Path或者Text标签的fill属性
var radialGradient = new ART.RadialGradient({
  ".1": "#2fb000",
  ".9": "#a080f0",
}, 300, 200, 400, 400, 200, 200);
```

`RadialGradient`构造函数第一个参数是和线性渐变相同的，后续六个分别表示：焦点x，焦点y，x半轴长，y半轴长，原点x，原点y.


#### ART动画

绘制矢量图标通过上述API的组合基本能实现，下面来讲讲动画效果的制作 (Kira☆~)


> 首先感谢Jason Brown的ART动画分享~ 本节内容主要源自他的博文:
> [art Morph动画](http://browniefed.com/blog/react-native-morphing-svg-paths-with-react-art/)
> [art Animated动画](http://browniefed.com/blog/react-native-how-to-create-twitter-exploding-hearts/)

第一个方法是使用ART它爷爷`art`库中的的`Morph`

```js
// 因为ART有art库的依赖，所以可以直接import
import Morph from 'art/morph/path'
```

Morph的基本API是`Morph.Tween(startSvg, endSvg)`，指定了一个渐变的过程对象，该对象可以直接复制给`Shape`标签的`d`属性。

调用`Morph.Tween(startSvg, endSvg).tween(percentage)`可以指定其渐变的程度，从0到1.0的动画展示便是startSvg路径变换到endSvg路径的过程。

使用`requestAnimationFrame`修改保存在state中渐变对象的渐变程度可以方便地做出动画渐变的效果，具体可以看Jason Brown的[博文]((http://browniefed.com/blog/react-native-morphing-svg-paths-with-react-art/))。

----------

其实鉴于ART中无法使用RN其他标签这点，使用最老土的`state`绑定制作动画和`Animated`制作动画在笔者的测试中性能差别并不大。
因为ART在动画的过程中基本上整体都需要重绘，并不像一般RN标签做动画会牵扯到许多实际上无重绘需求的子节点。

不过`state`和动画样式耦合一般是不推荐的方式，且`Animated`提供的`sequence`/`parallel`/`spring`/`delay`/`event`等API为制作更复杂的动画提供了便利，所以更推荐大家使用`Animated`配合ART制作动画。

首先通过`Animated`为ART标签提供动画加持~

``` js
import {ART, Animated} from 'react-native';
const {Shape, Group} = ART;
const AnimatedShape = Animated.createAnimatedComponent(Shape);
const AnimatedGroup = Animated.createAnimatedComponent(Group);
```

可以让`AnimatedGroup`标签负责基于xy属性的移动动画

```js
// 一颗星星的SVG代码
const STAR = 'M 0.000 10.000 L 11.756 16.180 L 9.511 3.090 L 19.021 -6.180 L 5.878 -8.090 L 0.000 -20.000 L -5.878 -8.090 L -19.021 -6.180 L -9.511 3.090 L -11.756 16.180 L 0.000 10.000'

// 某组件中...
constructor (props) {
  super(props);
  this.state = {
    // 设定Animated.Value初值
    value: new Animated.Value(0)
  }
  this.infiniteAnimate = this.infiniteAnimate.bind(this);
}
componentDidMount () {
  this.infiniteAnimate();
}
// 无限循环动画
infiniteAnimate () {
  Animated.timing(this.state.value, {
    duration: 1000,
    toValue: 1
  }).start(() => {
    Animated.timing(this.state.value, {
      duration: 2000,
      toValue: 0
    }).start(this.infiniteAnimate);
  });
}
render () {
  // 不断缩小放大的星星
  return (
    <View>
      <Surface width={width} height={height}>
        <AnimatedShape
          d={STAR}
          x={30}
          y={30}
          fill={"#280"}
          scale={this.state.value}
        />
      </Surface>
    </View>
  );
}

```

具体的使用和`Animated.View`之类相同，更复杂的例子看[这篇文章](http://browniefed.com/blog/react-native-animated-with-react-art-firework-show/)

### 目前ART相关的项目

* [react-native-svg](https://github.com/react-native-community/react-native-svg) 让ART支持所有svg标签
* [react-native-svg-uri](https://github.com/matc4/react-native-svg-uri) 依赖上面的`react-native-svg`让`<Image>`标签的source可使用svg的uri
* [react-native-progress](https://github.com/oblador/react-native-progress) ART做的进度条组件
* [react-native-grading](https://github.com/xgfe/react-native-grading) 笔者学习ART时做的一个评分组件

### 总结

React Native ART让RN开发者使用类svg语法绘制矢量图形，优点在于同步渲染/高清无码，并且可绘制简单的动画。
目前的坑在于未实现所有svg标签支持、安卓模拟器使用易奔溃、动画和绘制的开发效率不一定很高（相比于最近火爆酷炫的[lottie](https://github.com/airbnb/lottie-react-native))
ART动画的性能在安卓真机上也堪忧，不过这更多的应该是RN平台的问题，相信日后会有所改善。
不太建议在C端等用户体验要求较高的项目中使用ART动画（<del>不过C端有敢用RN的么</del>）

总而言之，ART其“画”UI的能力确实给了开发者很大的自定义空间。
