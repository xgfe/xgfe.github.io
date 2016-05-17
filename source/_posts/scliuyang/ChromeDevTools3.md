title: 分析timeline提升页面性能
date: 2016-5-16 16:32:00
categories: scliuyang
tags:
- Chrome Developers Tools
- Debug
- DevTools
---
学习怎样通过DevTools诊断由于强制布局引起的性能问题

<!--more-->

# 获取数据
首先，你需要捕获数据来确定到底在你的页面运行期间发生了什么。
1. 打开[demo](https://googlesamples.github.io/web-fundamentals/samples/tools/chrome-devtools/profile/rendering-tools/forcedsync.html)
2. 打开Timeline面板
3. 打开js profile选项，这样我们将会看到函数的调用情况
4. 点击start按钮来开始动画
5. 点击Record按钮(小圆点)来记录信息
6. 等待2S
7. 点击Record按钮来停止记录

当你停止记录时，你讲会看到如下的图形
<img src='/uploads/scliuyang/ChromeDevTools/31.png' style="width:500px;">

# 确定问题
现在你已经获得了性能数据，是时候去分析他了。

瞄一眼，可以看到Summary面板上显示浏览器花费大量时间在Rendering上面。
<img src='/uploads/scliuyang/ChromeDevTools/32.png' style="width:500px;">
现在将你的注意力转移到Overview面板中粉色的柱子上，这些表示每一帧的情况，鼠标放上去会显示关于这一帧的详细信息
<img src='/uploads/scliuyang/ChromeDevTools/33.png' style="width:500px;">
可以看到每一帧花费了太多的时间来完成，如果我们想得到平滑的动画最好保持在60 fps。
现在我们来分析为什么会造成这种情况，使用你的鼠标在call stack面板选中一段
<img src='/uploads/scliuyang/ChromeDevTools/34.png' style="width:500px;">
堆栈最顶层是Animation Frame Fired事件。该事件是requestAnimationFrame()调用时产生的。在下面一层你看到function call，再下面你可以看到update。你可以推断update()是requestAnimationFrame()的回调函数

现在集中你的注意力，找到在update event下的紫色条，这些紫色条大部分都会有一个红色的标记，这警告的标志。鼠标放上去你会看到DevTools警告你的页面有forced reflow,强制浏览器重新布局
<img src='/uploads/scliuyang/ChromeDevTools/35.png' style="width:500px;">
现在我们来看看引起forced reflow的函数，点击一个紫色柱子，在Summary面板你会看到这个事件的详细信息，点击Layout Forced (update @ forcedsync.html:457)跳转到函数定义的地方
<img src='/uploads/scliuyang/ChromeDevTools/36.png' style="width:500px;">
你将会在sources面板看到函数定义的地方
<img src='/uploads/scliuyang/ChromeDevTools/37.png' style="width:500px;">

这个函数基于每个图像的offsetTop值来计算left值。这将强制浏览器重排来保证获取正确的属性值。每次循环都强制重排，会导致动画卡顿。

# 修复问题

因为获取offsetTop值时，会强制浏览器进行重排来保证值的正确性，所以去掉获取这句,如下所示

```
function update(timestamp) {
            for (var m = 0; m < movers.length; m++) {
                movers[m].style.left = ((Math.sin(m +
                    timestamp / 1000) + 1) * 500) +
                 'px';
                // movers[m].style.left = ((Math.sin(m + timestamp/1000)+1) * 500) + 'px';
                }
            raf = window.requestAnimationFrame(update);
        }
```

# 重新测试

修改完毕后，重新获取一次timeline来查看结果
<img src='/uploads/scliuyang/ChromeDevTools/39.png' style="width:500px;">
可以看到每一帧都非常的平滑，满足60fps的要求