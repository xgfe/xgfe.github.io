title: 如何将html保存成图片
date: 2017.9.7
categories: huanglifen
tags:
- html2canvas
- canvas2image
- html2image
---

## 使用场景

现在流行于朋友圈分享的一些活动页，经常会玩这样的一个功能：将诸如测试之类的结果页保存成图片分享至朋友圈，以此来吸引用户参与，提高活动的pv和uv。

## 如何做

一般来说有这两个技术步骤：
- html2canvas
- canvas2image

当需要连同html中跨域的图片一起转换时，需要增加一个base步骤：
- image proxy（因为canvas2image不支持跨域的图片, 本篇只是点到，不做展开）
- html2canvas
- canvas2image

首先需要将html转成canvas， 再接着将canvas转为图片，至此，用户用手机自带的功能长按就可以保存，当然你也可以自己做长按保存的功能，canvas2image 提供了保存成图片的api。

## html2canvas

### 如何转换的
```
The script traverses through the DOM of the page it is loaded on. 
It gathers information on all the elements there, which it then uses to build a representation of the page. 
In other words, it does not actually take a screenshot of the page, 
but builds a representation of it based on the properties it reads from the DOM.
As a result, it is only able to render correctly properties that it understands, 
meaning there are many CSS properties which do not work.
```

翻译过来就是：
```
通过脚本去遍历页面加载的DOM元素，收集所有元素的有关信息，然后用收集到的信息来构建页面的表示。
换句话说，它实际上并不是页面的屏幕截图，而是基于从DOM读取的属性来构建页面的表示。
因此，它只能够正确地呈现其理解的属性，这就意味着有许多CSS属性不起作用。
```

### 制约点
```
All the images that the script uses need to reside under the same origin 
for it to be able to read them without the assistance of a proxy. 
Similarly, if you have other canvas elements on the page, which have been 
tainted with cross-origin content, they will become dirty and no longer readable by html2canvas.
The script doesn't render plugin content such as Flash or Java applets.
It doesn't render iframe content either.
```

翻译过来就是：
```
脚本使用的所有图像都必须位于相同的起源点，以便脚本不需要代理协助就可以读取它们的信息。
类似地，如果页面上有其他canvas元素，这些元素已经被不是同源的内容所污染，就不能被html2canvas读取。
简单来说就两点：
- 不支持跨域
- 不支持HTML中包含canvas
```

参数说明

|       Name        |      Type       |     Default      | Description      |
| ------------------|:---------------:|:----------------:|------------------|
|  allowTaint      |     boolean  |   false              | 是否允许图片跨域|
|  background       |  string  |   #fff                   | 画布背景颜色，如果DOM中未指定，值为透明|
|  height           | number   | null |以像素为单位定义画布的高度。 如果为空，则按窗口的高度来渲染|
|  width           | number   | null |以像素为单位定义画布的宽度。 如果为空，则按窗口的宽度来渲染|
| letterRendering   | boolean  | false  | 是否分别渲染每一个字符，必要时使用letter-spacing|
| logging           | boolean  | false |  是否开启控制台日志|
| proxy             | string  | undefined|  设置用于加载跨域图片的代理域名，如果为空，跨域的图片不会被加载|
| taintTest         | boolean  | true |  设置是否在渲染前检测每张图片加载完 |
| timeout         | number  | 0 |  设置超时加载图片，毫秒为单位，设置为0则无超时 |
| useCORS         | boolean  | false |  是否在还原到代理服务器之前尝试将跨域的图像加载为CORS |
|  scale           | number   | 1 |转换时放大的倍数，可以通过获取设备的像素密度来定义，也可以自定义|

### 使用
转换后的canvas会传递到回调函数中
```javascript
html2canvas(element, {
    onrendered: function(canvas) {
        // canvas is the final rendered <canvas> element
    }
});

或者

html2canvas(element, options).then(function (canvas) {
    // canvas is the final rendered <canvas> element
});
```

想要了解更多信息，请前往官网地址：http://html2canvas.hertzen.com/

## canvas2image

你可以使用的API:
```javascript
Canvas2Image.saveAsImage(canvasObj, width, height, type)
Canvas2Image.saveAsPNG(canvasObj, width, height)
Canvas2Image.saveAsJPEG(canvasObj, width, height)
Canvas2Image.saveAsGIF(canvasObj, width, height)
Canvas2Image.saveAsBMP(canvasObj, width, height)

Canvas2Image.convertToImage(canvasObj, width, height, type)
Canvas2Image.convertToPNG(canvasObj, width, height)
Canvas2Image.convertToJPEG(canvasObj, width, height)
Canvas2Image.convertToGIF(canvasObj, width, height)
Canvas2Image.convertToBMP(canvasObj, width, height)
```


## 举个栗子

html：
```html
<div class="main">
    <div class="html-source width-6 fl">
        <img src="img/timg.jpeg" class="width-6">
        <p>图片描述文字</p>
    </div>
    <div class="option-content width-4 fl">
        <button class="button start-to-do">转换成图片</button>
        <button class="button">下载图片</button>
    </div>
    <div class="png-content width-6 fl"></div>
</div>
```
核心js：为获得高清的图片，先以N倍的尺寸转换成canvas, 再1：1转换成png, 最后通过样式去控制最后生成的图片展示尺寸。

```javascript
    var me = this;
    var sourceContent = me.$el.$htmlSource;
    var width = sourceContent.width();
    var height = sourceContent.height();
    var offsetTop = sourceContent.offset().top;
    var offsetLeft = sourceContent.offset().left;
    var canvas = document.createElement("canvas");
    var canvas2D = canvas.getContext("2d");

    // 不能小于1，否则图片不完整，通过获取设备的像素密度不能统一得到清晰的图片，建议写固定值
    var scale = N;
    canvas.width = (width + offsetLeft) * scale;
    canvas.height = (height + offsetTop) * scale;
    canvas2D.scale(scale, scale);
    canvas2D.font = "Microsoft YaHei";
    var options = {

        //检测每张图片都已经加载完成
        tainttest:true,
        canvas: canvas,
        scale: scale,

        //dom 放大的宽度，放大倍数和清晰度在一定范围内成正相关
        width: width + offsetLeft,

        // 开启日志，可以方便调试
        logging: true,

        //dom 放大的宽度，放大倍数和清晰度在一定范围内成正相关
        height: height + offsetTop
    };
    html2canvas(sourceContent, options).then(function (canvas) {
        var img = window.Canvas2Image.convertToPNG(canvas, width * scale, height * scale);
        me.$el.$pngContent.append(img);

        // 将图片恢复到原始大小
        me.$el.$pngContent.find('img').css({
            width: width,
            height: height
        });
    });
```
下面是不同的倍数N，生成的不同清晰度的图片：
![效果图（倍数N: 1~3.5）](http://p0.meituan.net/xgfe/9a8e54d6457a682eb167d77fd1d2d2ef594412.png)

之前做过一次项目，N设为3 可以满足多种主流手机的高清图片要求。

### 附完整源代码

需要说明的是： 页面需要运行于服务器中转换才能生效。

```html
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <meta content="width=device-width,minimum-scale=1.0,maximum-scale=1.0,user-scalable=no" name="viewport">
    <script type="text/javascript">
        (function () {
            var win = window, html = document.documentElement;
            function setRem() {
                var width = html.getBoundingClientRect().width;
                width = (width == 980) ? 360 : width;
                var rem = width / 20;
                win.rem = rem;
                html.style.fontSize = rem + 'px';
            }
            setRem();
        })();
    </script>
    <style type="text/css">
        * {
            padding: 0;
            margin: 0;
        }
        .main {
            padding: 0.2rem;
            background: #fafafa;
            overflow: auto;
        }
        .width-2 {
            width: 2rem;
        }
        .fl {
            float: left;
        }
        .html-source {
            height: 10rem;
        }
        .html-text {
            font-size: 0.2rem;
        }
        .png-content {
            height: 20rem;
        }
        .png-content img {
            border: 0;
            margin: 0 0.2rem;
        }
        .button {
            color: #fff;
            background-color: #23b7e5;
            border-color: #23b7e5;
            font-weight: 500;
            border-radius: 0.1rem;
            outline: 0;
            font-size: 0.2rem;
            margin: 0 0.5rem;
        }
    </style>
</head>
<body>
<div class="main">
    <div class="html-source width-2 fl">
        <img src="img/timg.jpeg" class="width-2">
        <p class="html-text">图片描述文字</p>
    </div>
    <div class="option-content fl">
        <button class="button start-to-do">转换</button>
    </div>
    <div class="png-content"></div>
</div>


<script src="js/jquery-3.2.1.min.js"></script>
<script src="js/html2canvas.js"></script>
<script src="js/canvas2image.js"></script>
<script type="text/javascript">
    var page = {
        init: function () {
            this.initDom();
            this.initEvent();
        },
        initDom: function () {
            this.$el = {};
            this.$el.$startBtn = $('.start-to-do');
            this.$el.$htmlSource = $('.html-source');
            this.$el.$pngContent = $('.png-content');
        },
        initEvent: function () {
            var me = this;
            this.$el.$startBtn.on('click', function () {
                for (var i = 2; i < 8; i++) {
                    me.initSavePng(i * 0.5);
                }
            });
        },
        initSavePng: function(N) {
            var me = this;
            var sourceContent = me.$el.$htmlSource;
            var width = sourceContent.width();
            var height = sourceContent.height();
            var offsetTop = sourceContent.offset().top;
            var offsetLeft = sourceContent.offset().left;
            var canvas = document.createElement("canvas");
            var canvas2D = canvas.getContext("2d");

            // 不能小于1，否则图片不完整
            var scale = N;
            canvas.width = (width + offsetLeft) * scale;
            canvas.height = (height + offsetTop) * scale;
            canvas2D.scale(scale, scale);
            canvas2D.font = "Microsoft YaHei";
            var options = {

                //检测每张图片都已经加载完成
                tainttest:true,
                canvas: canvas,
                scale: scale,

                //dom 放大的宽度，放大倍数和清晰度在一定范围内成正相关
                width: width + offsetLeft,

                // 开启日志，可以方便调试
                logging: true,

                //dom 放大的宽度，放大倍数和清晰度在一定范围内成正相关
                height: height + offsetTop
            };
            html2canvas(sourceContent, options).then(function (canvas) {
                var img = window.Canvas2Image.convertToPNG(canvas, width * scale, height * scale);
                me.$el.$pngContent.append(img);

                // 将图片恢复到原始大小
                me.$el.$pngContent.find('img').css({
                    width: width,
                    height: height
                });
            });
        }
    };

    page.init();
</script>
</body>
</html>
```

完整示例代码git地址：https://github.com/huanlifen/html2image

## 参考资料

1.[原版html2canvas](https://github.com/niklasvh/html2canvas)
2.[优化版html2canvas 0.5.0-beta4](https://github.com/omwteam/html2canvas)
