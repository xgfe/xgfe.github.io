title: React Native 学习系列一
date: 2015-06-22 21:12:00
categories: lulutia
tags: 
- React Native
---
本文是React Native学习系列的第一篇，主要介绍了React Native产生的背景、环境搭建、文件结构及如何使用Flex布局进行样式搭建。

<!-- more -->

#### 背景介绍
* 创造者: Facebook
* 时间: React.js Conf 2015 上发布，9月推出Android版本
* 使用范围: 用于开发**iOS和Android**原生应用
* 设计理念: 既拥有Native的**用户体验**、又保留React的**开发效率**
* 产生原因:
  * Native的原生控件有更好的体验，有更好的手势识别，有更合适的线程模型，能实现更精细的动画
  * Native开发成本高
* 发展趋势: 开源不到1周github上star破万
* 基本特点:
  * Learn once, write anywhere
    * 用React.js抽象操作系统的原生UI组件，继而代替DOM元素来渲染
  * 具备流畅和反应灵敏的优势
    * 在后台，React Native运行在主线程之外，而在另一个专门的后台线程里运行JavaScript引擎，两个线程之间通过异步消息协议来通信。
* 对应技术栈
  * JSX vs HTML
  * CSS-layout vs css
  * ECMAScript 6 vs ECMAScript 5
  * React Native View vs DOM

#### 环境配置
* 按照React Native官方文档搭建环境
  * [英文版](http://facebook.github.io/react-native/docs/getting-started.html)搭建流程
  * [中文版](http://reactnative.cn/docs/0.46/getting-started.html)搭建流程
  * 模拟器推荐使用[Genymotion](https://www.genymotion.com/)。
* 安装过程中可能出现的问题
  * $ANDROIDNDK 和 $ANDROIDHOME 没有正确设置: 
    * 解决办法：vi .bashrc和.bash_profile 加上 /usr/local/opt/android-ndk和/usr/local/opt/android-sdk,并且source一下这两个文件，然后eoch下上述两个变量是否已经存在。
* [真机调试](http://reactnative.cn/docs/0.41/running-on-device-android.html#content)
  * 注意iOS系统真机调试需要有开发者账号
  * 可能有些机型无法用这种方式进行(比如小米4C)，可以手动安装

#### 结构
* 文件结构

![文件结构](https://raw.githubusercontent.com/lulutia/images/master/ReactNative/one/structure.png)

* 代码结构
  * 7-13: 引入需要用到的模块
  * 15-32: 本组件的渲染逻辑
  * 34-51: 样式定义
  * 53: AppRegistry是JS运行所有React Native应用的入口，应用的根组件应当通过AppRegistry.registerComponent方法注册自己，然后原生系统才可以加载应用的代码包并且在启动完成之后通过调用AppRegistry.runApplication来真正运行应用
  * 样式定义可以单独提出作为一个模块，甚至组件的具体实现也可以和应用注册分离开来
  
![代码结构](https://raw.githubusercontent.com/lulutia/images/master/ReactNative/one/code.png)




#### 样式
* React Native中用JS来写样式
* 所有的核心组件都接受名为style的属性。这些样式名基本上是遵循了web上的CSS的命名，只是按照JS的语法要求使用了驼峰命名法
* style属性可以是一个普通的JavaScript对象，也可以是一个数组，在数组中位置居后的样式对象比居前的优先级更高
* [Text样式](http://reactnative.cn/docs/0.41/text.html#style)
* [View样式](http://reactnative.cn/docs/0.41/view.html#style)
* 最简单的调试方法: 当错误的书写了样式属性时，应用会抛出一个warning，在这个warning里面会列出当前元素所有可使用的样式
* 实际开发中组件的样式会越来越复杂，官方建议使用StyleSheet.create来集中定义组件的样式。StyleSheet提供了一种类似CSS样式表的抽象，相比于plain object，其主要有以下优势
  * 代码质量:
    * 移除了render里面的具体样式内容，使代码组织更加合理
    * 给样式命名可以对render函数中的原始组件进行一种作用标记
  * 性能角度:
    * 创建一个样式表，就可以使得我们后续更容易通过ID来引用样式，而不是每次都创建一个新的对象
    * 它还使得样式只会在JavaScript和原生之间传递一次，随后的过程都可以只传递一个ID(现在还没实现)
  * 因此，如果我们直接打印styles.xxx，我们只会得到一个number，要使用StyleSheet.flatten(styles.xxx)才能得到具体内容

#### Flex布局
* 在React Native中布局采用的是FleBox(弹性框)进行布局
* Flex布局主要思想是让容器有能力让其子项目能够改变其宽度、高度(甚至顺序)，以最佳方式填充可用空间(主要是为了适应所有类型的显示设备和屏幕大小)

像素无关
  * React Native中的尺寸都是无单位的，表示的是与设备像素密度无关的逻辑像素点

  ```js
    <View style={ {width:100,height:100,margin:40,backgroundColor:'gray'}}>
          <Text style={ {fontSize:16,margin:20}}>尺寸</Text>
    </View>
  ```
  * 上面的例子，运行在Android上时，View的长和宽被解释成100dp 其单位是dp，字体被解释成16sp 其单位是sp，运行在iOS上时尺寸单位被解释称了pt，这些单位确保了布局在任何不同dpi的手机屏幕上显示不会发生改变。如果希望获取实际的像素尺寸，则需要使用尺寸 * pixelRatio。[pixelRatio使用](https://facebook.github.io/react-native/docs/pixelratio.html)
  
React Native中的FlexBox 和Web CSS中的FlexBox不全相同
  * flexDirection: React Native中默认为flexDirection:'column'，在Web CSS中默认为flex-direction:'row'
  * alignItems: React Native中默认为alignItems:'stretch'，在Web CSS中默认align-items:'flex-start'
  * flexWrap: React Native中没有wrap-reverse，在Web CSS中有
  * flex: 相比Web CSS的flex接受多参数，如:flex: 2 2 10%;，但在 React Native中flex只接受一个参数
  * 不支持属性：align-content，flex-flow等
  
Flex基本知识[基于RN]
  ![flex基本概念](https://raw.githubusercontent.com/lulutia/images/master/ReactNative/one/flex.png)
  
  * 父容器属性
    * flexDirection属性定义了父视图中的子元素沿横轴或侧轴方片的排列方式，默认为column: 'row', 'column','row-reverse','column-reverse'
    
    ![flexDirection](http://okzzg7ifm.bkt.clouddn.com/flexdirection.png)
    
    * flexWrap属性定义了子元素在父视图内是否允许多行排列，默认为nowrap: 'wrap', 'nowrap'
    
    ![flexWrap](http://okzzg7ifm.bkt.clouddn.com/wrap.png)
    
    * justifyContent属性定义了浏览器如何分配顺着父容器主轴的弹性（flex）元素之间及其周围的空间，默认为flex-start: 'flex-start', 'flex-end', 'center', 'space-between', 'space-around'

    ![justifyContent](http://okzzg7ifm.bkt.clouddn.com/justifyContent.png)
    
    * alignItems属性以与justify-content相同的方式在侧轴方向上将当前行上的弹性元素对齐，默认为stretch: 'flex-start', 'flex-end', 'center', 'stretch'。这里需要注意，当选择stretch时，侧轴上的元素不能有固定的size，否则无效

    ![alignItems](http://okzzg7ifm.bkt.clouddn.com/alignItems.png)
    
  * 子容器属性
    * alignSelf决定了元素在父元素的次轴方向的排列方式（此样式设置在子元素上），其值会覆盖父元素的alignItems的值，默认auto: 'auto', 'flex-start', 'flex-end', 'center', 'stretch'
  * flex 属性定义了一个可伸缩元素的能力，默认为0
  * 视图边框: border[Bottom/Top/Left/Right]Width，borderColor等
  * 尺寸: width，height
  * 外边距: margin[Bottom/Top/Left/Right/Horizontal/Vertical]等
  * 内边距: padding[Bottom/Top/Left/Right/Horizontal/Vertical]等
  * 边缘: left，right，top，bottom等
  * 定位: absolute，relative
  * [更多参考](https://reactnative.cn/docs/0.39/layout-props.html)


图片布局
  * 图片有一个stretchMode. 通过Image.resizeMode访问，其主要有以下几种模式(默认采用cover模式):
    * cover: 在保持图片宽高比的前提下缩放图片，直到宽度和高度都大于等于容器视图的尺寸（如果容器有padding内衬的话，则相应减去）。这样图片完全覆盖甚至超出容器，容器中不留任何空白 
    ![cover](https://raw.githubusercontent.com/lulutia/images/master/ReactNative/one/cover.png)
    
    * contain: 在保持图片宽高比的前提下缩放图片，直到宽度和高度都小于等于容器视图的尺寸（如果容器有padding内衬的话，则相应减去）。这样图片完全被包裹在容器中，容器中可能留有空白

    ![contain](https://raw.githubusercontent.com/lulutia/images/master/ReactNative/one/contain.png)
    * stretch: 拉伸图片且不维持宽高比，直到宽高都刚好填满容器

    ![stretch](https://raw.githubusercontent.com/lulutia/images/master/ReactNative/one/stretch.png)
    
    * repeat: 重复平铺图片直到填满容器。图片会维持原始尺寸。仅iOS可用，android使用会报错

    ![repeat](https://raw.githubusercontent.com/lulutia/images/master/ReactNative/one/repeat.png)
    
    * center: 居中不拉伸

    ![center](https://raw.githubusercontent.com/lulutia/images/master/ReactNative/one/center.png)
    
文本元素  
  * 文本可嵌套
  * <Text>元素在布局上不同于其它组件：在Text内部的元素不再使用flexbox布局，而是采用文本布局。这意味着<Text>内部的元素不再是一个个矩形，而可能会在行末进行折叠

  ![文本布局](https://raw.githubusercontent.com/lulutia/images/master/ReactNative/one/text.png)  
  * 你必须把你的文本节点放在<Text>组件内。你不能直接在<View>下放置一段文本
  * 不能直接设置一整颗子树的默认样式。使用一个一致的文本和尺寸的推荐方式是创建一个包含相关样式的组件MyAppText，然后在你的App中反复使用它
  * 文本标签的子树还是可以继承的，继承父元素的样式
  * 通过numberOfLines={}可以实现文字截断效果
  * 注意ios和android的默认文字样式是不一样的，主要是fontSize和color的不同。
  
#### 参考
* [React Native: Bringing modern web techniques to mobile](https://code.facebook.com/posts/1014532261909640/react-native-bringing-modern-web-techniques-to-mobile/)
* [基于Facebook Buck改造Android构建系统之初体验](http://www.jianshu.com/p/1e990aac7836)
* [flow——A static type checker for javascript](https://github.com/amfe/article/issues/32)
* [自定义 Git - Git属性](https://git-scm.com/book/zh/v1/%E8%87%AA%E5%AE%9A%E4%B9%89-Git-Git%E5%B1%9E%E6%80%A7)
* [AppRegistry](http://reactnative.cn/docs/0.36/appregistry.html)
* [React Native布局详细指南](https://github.com/crazycodeboy/RNStudyNotes/blob/master/React%20Native%E5%B8%83%E5%B1%80/React%20Native%E5%B8%83%E5%B1%80%E8%AF%A6%E7%BB%86%E6%8C%87%E5%8D%97/React%20Native%E5%B8%83%E5%B1%80%E8%AF%A6%E7%BB%86%E6%8C%87%E5%8D%97.md)
* [flex布局示意图](http://weibo.com/1712131295/CoRnElNkZ?ref=collection&type=comment#_rnd1486356368337)
* [react-native 之布局篇](https://segmentfault.com/a/1190000002658374)
