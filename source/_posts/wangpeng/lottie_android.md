title: 动画库 Lottie 的使用
date: 2018-04-26 16:26
categories:
- w.p
tags:
- Android
- lottie
- animation

---

本文主要介绍动画开源库 Lottie 在 Android 中的使用。

<!--more-->

## 前言

在日常APP开发中，为了提升用户感官舒适度等原因，我们会在APP中加入适量动画。  
而传统手写动画方式往往存在诸多问题:

* **动画复杂而实现困难**

* **图片素材占用体积过大**
    
* **不同Native平台都需各自实现，开发成本高**
   
* **不同Native平台实现的最终效果不一致**
     
* **后期视觉联调差异化大**
   

![](http://p0.meituan.com/tuanpic/lottie_android_headache.jpeg)  

*难道就没有一种简便且高效的方案来减缓或解决上述问题吗？*
 
答:有的，那就是本文要介绍的主角 **Lottie**

## 一、Lottie 是什么？

> Lottie是Airbnb开源的一个面向IOS、Android、React Native的动画库，可以解析用 Adobe After Effects 制作动画后通过 Bodymovin 插件导出的 JSON 数据文件并在移动端原生渲染

通俗点说，它是一款动画开源库，通过解析特定的JSON文件或JSON文本，可直接在移动端上渲染出复杂的动画效果。

![参考图释](http://p0.meituan.com/tuanpic/lottie_android_flow.png)
  
## 二、Lottie 能干什么?

**它可以简便高效的实现复杂动画，替代传统低效的手写动画方式。** 
 
动画展示:
 
![](http://p0.meituan.com/tuanpic/lottie_android_example_4.gif)


上方的动画是通过Lottie直接实现的。

如果我们使用手写代码方式实现，可以说是很难！  
 
而通过 Lottie 实现时，需要的仅是一个JSON文件或一段JSON文本，并通过简洁的代码集成即可。

集成代码可能精简到如下模样:

```xml
<com.airbnb.lottie.LottieAnimationView
    android:id="@+id/animation_view"
    android:layout_width="wrap_content"
    android:layout_height="wrap_content"  
    app:lottie_rawRes="@raw/anim_lottie"
    app:lottie_loop="true"
    app:lottie_autoPlay="true" />
    
```

## 三、为什么使用 Lottie?

* **简便，开发成本低**  
  相对于传统方式，动画不再是全部手写，所需做得只是嵌入XML并配置动画属性，集成快，开发时间少，开发成本低。    
  
* **不同 Native 平台效果基本一致**  
  渲染交由Lottie引擎内部实现，无需开发者处理平台差异，多平台共用同一个动画配置文件，效果一致性高。    
  
* **占用包体积小**  
  Lottie配置文件由JSON文本串构成，相对于图片，占用体积更小。
  
* **动画效果不失真**  
  传统图片拉伸或压缩导致失真，而Lootie为矢量图展示，不会出现失真情况。
  
* **动画效果可以云端控制**  
  由于Lottie动画基于JSON文件或文本解析，因此可以实现云端下发，实现动态加载，动态控制动画样式。

## 四、如何使用 Lottie？  
Lottie 仅支持用 Gradle 构建配置，最低支持安卓版本 16     

### 1. 添加依赖到 build.gradle

```gradle
dependencies {
    implementation 'com.airbnb.android:lottie:2.5.4'
}
或
dependencies {
    implementation "com.airbnb.android:lottie:${全局版本变量}"
}

```

### 2. 添加 Adobe After Effects 导出的动画 JSON 文件

通常由视觉工程师确认动效后通过AE导出, 我们只需将该JSON文件保存至 /raw 或 /assets文件夹下  

### 3. XML中嵌入基本布局

```xml
<com.airbnb.lottie.LottieAnimationView
    android:id="@+id/animation_view"
    android:layout_width="wrap_content"
    android:layout_height="wrap_content"/>
    
```

### 4. 加载播放动画，两类方式可选

#### ① XML中静态配置, 举例:

```xml
<com.airbnb.lottie.LottieAnimationView
    android:id="@+id/animation_view"
    android:layout_width="wrap_content"
    android:layout_height="wrap_content"  
       
    //加载方式如下2种任选其一
    app:lottie_rawRes="@raw/hello_world"
    app:lottie_fileName="hello_world.json"
	
    //循环播放
    app:lottie_loop="true"
    //加载完毕后自动播放
    app:lottie_autoPlay="true" />
    
```
	
#### ② 代码动态配置, 举例:

*如下代码会在后台异步加载动画文件，并在加载完成后开始渲染动画。*

```java
LottieAnimationView animationView = ...;
animationView.setAnimation(R.raw.hello_world);
animationView.loop(true);
animationView.playAnimation();

```

## 五、其他拓展使用  

### 1. 直接解析JSON文本串加载动画    	
	
```java
JsonReader jsonReader = new JsonReader(new StringReader(jsonStr));
lottieView.setAnimation(jsonReader);
lottieView.playAnimation();
或
Cancellable cancellable = LottieComposition.Factory.fromJsonString(jsonStr, composition -> {
            lottieView.setComposition(composition);
            lottieView.playAnimation();
        });
//必要时取消进行中的异步操作
cancellable.cancel();   
```

### 2. 配合网络下载，实现下载JSON配置并动态加载

```java
Call<ResponseBody> call = RetrofitComponent.fetchLottieConfig();//伪代码
call.enqueue(new Callback<ResponseBody>() {
            @Override
            public void onResponse(Call<ResponseBody> call, Response<ResponseBody> response) {
                //String json = response.body().string();
                //交由Lottie处理...
            }

            @Override
            public void onFailure(Call<ResponseBody> call, Throwable t) {
                //do something.
            }
        });
```
	
### 3. 动画加载监听器

根据业务需要进行动画过程监听:    
	
```java
animationView.addAnimatorUpdateListener((animation) -> {
    	// do something.
});
animationView.playAnimation();
...
if (animationView.isAnimating()) {
	// do something.
}
...
animationView.setProgress(0.5f);
...

```

### 4. LottieDrawable 的使用


```java
LottieDrawable drawable = new LottieDrawable();
LottieComposition.Factory.fromAssetFileName(getApplicationContext(), "lottie_pin_jump.json", composition -> {
            drawable.setComposition(composition);
            //目前显示为静态图
            ivLottie.setImageDrawable(drawable);
            //调用start()开始播放动画
            drawable.start();
        });
```

### 5. 更多使用可参考文末官方链接


## 六、需要考虑的问题  

1. 由于是依赖于AE做的动画，估计以后不只是要求视觉设计师精通AE，连前端开发都需要了解AE  
2. Lottie 对 Json 文件的支持待完善，目前存在部分AE导出成 Json 文件无法渲染或渲染不佳
3. 支持的功能存在限制，可参考 [功能支持列表](http://airbnb.io/lottie/supported-features.html)

## 七、总结  

尽管Lottie还存在诸多小问题，但它所带来的效率提升绝对是传统开发方式无法比拟的。我们要做的是正确善用它。

## 参考资料  

[官网网址](http://airbnb.io/lottie/android/android.html)   
[Github地址](https://github.com/airbnb/lottie-android)  
[测试用JSON文件](https://github.com/airbnb/lottie-android/tree/master/LottieSample/src/main/assets)  
[项目中文翻译版 (略有差异)](https://github.com/bigxixi/lottie-android)  
