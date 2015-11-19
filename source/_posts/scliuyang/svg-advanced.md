title: SVG进阶教程
date: 2015-11-17 16:32:00
categories: scliuyang
tags:
- svg
- 进阶
---
本文在大概了解SVG的基础上，深入的讲解一些SVG常用的知识，主要有以下几点  

1. JS操作SVG
2. viewport和viewbox
3. SVG变换
4. SVG动画
5. SVG clip-path

<!--more-->
# JS如何操作SVG元素

创建SVG元素和普通创建DOM元素有细小的区别，创建SVG需要用到命名空间创建,举个栗子  

```
var svgNS = “http://www.w3.org/2000/svg”; //命名空间字符串
var svgDom = document.createElementNS(svgNS, ‘svg’);
```

当然对普通属性的操作使用setAttribue即可，但是如果操作SVG特有的属性即xlink:href之类的则必须使用如下的方法

```
<use xlink:href="#pat"> //操作xlink:href

var xlinkNS = "http://www.w3.org/1999/xlink";
var use = document.createElementNS(svgNS, 'use');
use.setAttributeNS(xlinkNS,'href', '#pat');
```
# viewport和viewbox

## viewport

首先呢讲解viewport之前，大家得先记着这个概念：我们的画布是无限大的。接着我们在来看看svg元素上的width和height，我们可以把SVG看做浏览器窗口（body部分）,width和height即浏览器的可视窗口大小，我们透过宽为width、高为height的矩形去看这块画布，画布超出部分自然也就看不到了,这个矩形呢就是viewport。
## viewbox

假如我们想看超出部分怎么办呢？别着急，这时候就是viewbox排上用场的时候了。我们先来看看语法

```
viewbox:x y width height
```
x,y呢决定viewbox的左上角起始点(允许负值)，width,height决定viewbox的宽高。注意这里的宽高不一定要和SVG的宽高一致。设置viewbox的宽高例子如下

```
<!-- viewbox和svg的宽高默认相等，可以设置不等值 -->
<svg width="800" height="600" viewBox="0 0 800 600"> 
</svg>
```
现在我们有一个宽高都是500的SVG，里面有一个鹦鹉，如图
<img src="/blog/uploads/scliuyang/svg-advance/svg-1.png" style="width:200px;height:200px;">
我们设置viewbox="0 0 100 100",结果如下
<img src="/blog/uploads/scliuyang/svg-advance/svg-2.png" style="width:200px;height:200px;">
<img src="/blog/uploads/scliuyang/svg-advance/svg-3.png" style="width:200px;height:200px;">
可以清楚的看到浏览器将蓝色方框内的内容等比例拉伸到500，500的大小

现在是viewbox的宽高比和viewport的宽高比一致，当宽高比不一致的时候就需要用到
## preserveAspectRatio

preserveAspectRatio属性。我们先来看看preserveAspectRatio的语法

```
preserveAspectRatio="align meetOrSlice"
```
### align

align取值为none时，宽高比不相同的话会强制拉伸充满整个viewport,就像这样
<img src="/blog/uploads/scliuyang/svg-advance/svg-5.png" style="height:200px;">

align的其他取值情况是下面两列的混合情况

```
 xMin YMin
 xMid YMid
 xMax YMax

```
<img src="/blog/uploads/scliuyang/svg-advance/svg-6.jpg" >
<img src="/blog/uploads/scliuyang/svg-advance/svg-7.jpg" >

### meetOrSlice

#### meet(默认值）

基于以下两条准侧尽可能缩放元素： 

- 保持宽高比
- 整个viewBox在视窗中可见  

在这个情况下，如果图形的宽高比不符合视窗，一些视窗会超出viewBox的边界（即viewBox绘制的区域会小于视窗）。（在viewBox一节查看最后的例子。）在这个情况下，viewBox的边界被包含在viewport中使得边界满足。

这个值类似于background-size: contain。背景图片在保持宽高比的情况下尽可能缩放并确保它适合背景绘制区域。如果背景的长宽比和应用的元素的长宽比不一样，部分背景绘制区域会没有背景图片覆盖。

#### slice

在保持宽高比的情况下，缩放图形直到viewBox覆盖了整个视窗区域。viewBox被缩放到正好覆盖视窗区域（在两个维度上），但是它不会缩放任何超出这个范围的部分。换而言之，它缩放到viewBox的宽高可以正好完全覆盖视窗。

在这种情况下，如果viewBox的宽高比不适合视窗，一部分viewBox会扩展超过视窗边界（即，viewBox绘制的区域会比视窗大）。这会导致部分viewBox被切片。

你可以把这个类比为background-size: cover。在背景图片的情况中，图片在保持本身宽高比（如何）的情况下缩放到宽高可以完全覆盖背景定位区域的最小尺寸。

[鹦鹉在线demo](http://sarasoueidan.com/demos/interactive-svg-coordinate-system/index.html)

# SVG变换

SVG元素也可以应用css变换，不过唯一需要注意的一点就是，svg元素的transform-origin是左上角0,0点,如果想像普通元素一样请设置transform-origin:50% 50%;
<img src="/blog/uploads/scliuyang/svg-advance/svg-8.png" >
 
# SVG动画

SVG动画可以有3种实现方法  

- JS动画，利用requestAnimationFrame手动控制每一帧动画，缺点性能消耗大，不推荐
- SMIL Synchronized Multimedia Integration Language(同步多媒体集成语言),最初的SVG动画方法，但是由于标准的变更，此方法将逐渐被CSS动画取代
- CSS3动画，由于大部分SVG属性都可以使用css设置，故可以使用CSS动画，推荐

参考链接：
[帅气的描边动画](http://www.webhek.com/animated-line-drawing-in-svg)
[很有创意的loading动画](http://www.oxxostudio.tw/articles/201407/svg-progress-bar.html)

# SVG clip-path

SVG剪切，配合defs使用，剪切定义路径以外的图像（隐藏）
<img  src="/blog/uploads/scliuyang/svg-advance/svg-9.png">
<img  src="/blog/uploads/scliuyang/svg-advance/svg-10.png">
[亲自试一试](http://jsbin.com/kigiqidoze/edit?html,js,output)