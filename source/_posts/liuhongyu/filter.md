title: 用CSS实现各种图片滤镜效果演示
date: 2017-10-18 21:46:00
categories: liuhongyu
tags: 
- CSS3
---

本演示关键使用了几个新型的CSS属性(background-blend-mode, mix-blend-mode, 和 filter)，利用这些属性，我们可以让同一张图片呈现出各种不可思议的神奇效果。

<!-- more -->

### 技术原理
* 以下大多数的效果图中，背景图片源 background-image url 通常会反复使用数次，同时利用CSS混合模式 (multiply, overlay, screen, difference 等)进行处理。
* 在某些效果中，使用了 CSS filter 属性进一步处理图片，比如 grayscale(), brightness(), 和 contrast() 等可以让图片呈现出更好的效果。
* 使用 CSS @supports 来检测某种 CSS 属性是否在浏览器中受支持，不支持展示原图。

### 属性介绍
#### mix-blend-mode属性
	mix-blend-mode: normal; //正常
	mix-blend-mode: multiply; //正片叠底
	mix-blend-mode: screen;  //滤色
	mix-blend-mode: overlay; //叠加
	mix-blend-mode: darken; //变暗
	mix-blend-mode: lighten; //变亮
	mix-blend-mode: color-dodge; //颜色变淡
	mix-blend-mode: color-burn; //颜色加深
	mix-blend-mode: hard-light; //强光
	mix-blend-mode: soft-light; //柔光
	mix-blend-mode: difference; //插值
	mix-blend-mode: exclusion; //排除
	mix-blend-mode: hue; //色调
	mix-blend-mode: saturation; //饱和度
	mix-blend-mode: color; //颜色
	mix-blend-mode: luminosity; //亮度

[具体可参考](https://developer.mozilla.org/en-US/docs/Web/CSS/mix-blend-mode)

#### background-blend-mode属性
*属性值和mix-blend-mode一样[具体可参考](https://developer.mozilla.org/en-US/docs/Web/CSS/background-blend-mode)

#### filter属性
	/* URL to SVG filter */
	filter: url("filters.svg#filter-id");

	/* <filter-function> values */
	filter: blur(5px); //模糊
	filter: brightness(0.4); //亮度
	filter: contrast(200%); //对比度
	filter: drop-shadow(16px 16px 20px blue); //阴影
	filter: grayscale(50%); //灰度
	filter: hue-rotate(90deg); //色相旋转
	filter: invert(75%); //反色
	filter: opacity(25%); //透明度
	filter: saturate(30%); //饱和度
	filter: sepia(60%); //褪色

	/* Multiple filters */
	filter: contrast(175%) brightness(3%);
[具体可参考](https://developer.mozilla.org/en-US/docs/Web/CSS/filter)

### 效果示例
#### 原图效果
![](http://p0.meituan.net/xgfe/5bdb72c861a17a9749cff76b099a356d212585.jpg)

```css
.pencil-effect {
  background-image: url(minions.jpg);
  background-size: cover;
  background-position: center;
}

@supports (filter: invert(1)) and (background-blend-mode: difference) {
  .pencil-effect {
    background-image: url(minions.jpg), url(minions.jpg);
    background-blend-mode: difference;
    background-position: calc(50% - 1px) calc(50% - 1px), calc(50% + 1px) calc(50% + 1px);
    filter: brightness(2) invert(1) grayscale(1);
    box-shadow: inset 0 0 0 1px black;
  }
}
```
#### pencil效果
![](http://p0.meituan.net/xgfe/4c64f176d177c77b4fb42d988015af19145095.jpg)

```css
.watercolor-effect {
  background-image: url(minions.jpg);
  background-size: cover;
  background-position: center;
}

@supports (filter: blur(2px)) and (mix-blend-mode: multiply) {
  .watercolor-effect {
    position: relative;
    overflow: hidden;
  }
  .watercolor-effect:before, .watercolor-effect:after {
    display: block;
    content: "";
    position: absolute;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
    background-size: cover;
  }
  .watercolor-effect:before {
    background-image: url(minions.jpg), url(minions.jpg);
    background-blend-mode: difference;
    background-position: calc(50% - 1px) calc(50% - 1px), calc(50% + 1px) calc(50% + 1px);
    filter: brightness(2) invert(1) grayscale(1);
    box-shadow: inset 0 0 0 1px black;
  }
  .watercolor-effect:after {
    background-image: url(minions.jpg);
    background-position: center;
    mix-blend-mode: multiply;
    filter: brightness(1.3) blur(2px) contrast(2);
  }
}

```
#### watercolor效果
![](http://p1.meituan.net/xgfe/27a8948fbda95756722abcc5b7c8aba5227184.jpg)

```css
.colored-pencil-effect {
  background-image: url(minions.jpg);
  background-size: cover;
  background-position: center;
}

@supports (filter: invert(1)) and (mix-blend-mode: color) {
  .colored-pencil-effect {
    position: relative;
  }
  .colored-pencil-effect:before, .colored-pencil-effect:after {
    display: block;
    content: "";
    position: absolute;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
    background-size: cover;
    box-shadow: inset 0 0 0 1px black;
  }
  .colored-pencil-effect:before {
    background-image: url(minions.jpg), url(minions.jpg);
    background-blend-mode: difference;
    background-position: calc(50% - 1px) calc(50% - 1px), calc(50% + 1px) calc(50% + 1px);
    filter: brightness(2) invert(1) grayscale(1);
  }
  .colored-pencil-effect:after {
    background: inherit;
    mix-blend-mode: color;
  }
}

```
#### colored-pencil效果
![](http://p0.meituan.net/xgfe/50e1cef7923d032a304a90c078bdbbba86681.jpg)

```css
.warhol-effect {
  background-image: url(minions.jpg);
  background-size: cover;
  background-position: center;
}

@supports (background-blend-mode: color) {
  .warhol-effect {
    background-image: linear-gradient(#14EBFF 0, #14EBFF 50%, #FFFF70 50%, #FFFF70 100%), linear-gradient(#FF85DA 0, #FF85DA 50%, #AAA 50%, #AAA 100%), url(minions.jpg);
    background-size: 50% 100%, 50% 100%, 50% 50%;
    background-position: top left, top right;
    background-repeat: no-repeat, no-repeat, repeat;
    background-blend-mode: color;
  }
}
```
#### warhol效果
![](http://p1.meituan.net/xgfe/c3f854448e4e29a81747f6f2cc27426a90904.jpg)

```css
.infrared-effect {
  background-image: url(minions.jpg);
  background-size: cover;
  background-position: center;
  filter: hue-rotate(180deg) saturate(2);
}
```
#### infrared效果
![](http://p1.meituan.net/xgfe/c0b7f1e52f4e11a4a55bad3ba1157f6f69507.jpg)

### 浏览器兼容性
* background-blend-mode不支持IE具体详情见下图（mix-blend-mode类似）

![](http://p1.meituan.net/xgfe/02a2dec38a572e4175a74533c2589854308285.jpg)



