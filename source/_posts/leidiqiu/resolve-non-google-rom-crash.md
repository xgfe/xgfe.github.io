title: 非原生 ROM 的 Crash 问题通用排查方法
date: 2019-06-17 16:28:30
categories: leidiqiu
tags: 
- Android
- Crash
- 非原生ROM
---

日常 Crash 治理过程中，经常会遇到一些比较难排查的问题，比如，Crash 堆栈信息中出现了一些本不应该出现的函数，这些函数其实是手机厂商修改了 Google 的原生 ROM，自己添加进去的。本文介绍了一种定位和排查非原生 ROM 的 Crash 问题的通用方法。

<!--more-->

## 问题的提出
日常清理 Crash 时，遇到一些空指针异常的问题，每天不多，但是日积月累，数量并不少，堆栈信息如下：
```java
java.lang.NullPointerException: Attempt to invoke virtual method 'java.lang.Class java.lang.Object.getClass()' on a null object reference
	at android.os.Message.toStringLite(Message.java:507)
	at android.os.Looper.loop(Looper.java:221)
	at android.app.ActivityThread.main(ActivityThread.java:5809)
	at java.lang.reflect.Method.invoke(Native Method)
	at java.lang.reflect.Method.invoke(Method.java:372)
	at com.android.internal.os.ZygoteInit$MethodAndArgsCaller.run(ZygoteInit.java:1113)
	at com.android.internal.os.ZygoteInit.main(ZygoteInit.java:879)
```
翻看 android.os.Message 的源代码，并没有 toStringLite() 这个函数，显然，这是手机厂商修改了原生 ROM，自己加上的。如何跟进此类适配性问题呢？

## 思考
此类 ROM 相关问题无法修复，只能从 App 的代码调用端进行适配，类似 H5 页面适配各种浏览器一样。所以，主要问题在于找出非原生 ROM 的执行逻辑，从而想办法避免 Crash。那么，如何发掘里面的执行逻辑呢？

## 探索
初步考虑，通过 ClassLoader 动态导出具体的 class 类，代码如下：
```java
public class Demo {
    public static void main(String[] args) {
        try {
            ClassLoader classLoader = Thread.currentThread().getContextClassLoader();
            InputStream inputStream = classLoader.getResourceAsStream("java/util/List.class");
            FileOutputStream fileOutputStream = new FileOutputStream("List.class");
            byte[] buffer = new byte[1024];
            int length;
            while ((length = inputStream.read(buffer)) > 0) {
                fileOutputStream.write(buffer, 0, length);
            }
            fileOutputStream.close();
            inputStream.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
```
这种方法对 Java 是适用的，但是在 Android 中并不适用。

## 通用方法
既然动态方法不行，考虑静态方法，毕竟在手机 ROM 中，必然有对应的文件。
#### 步骤一
首先，通过 Crash 平台的附加信息，找到手机的型号、版本「型号：OPPO R9tm，版本：5.1」，找一台同型号、同版本的手机「美团有云真机平台，上面的手机种类繁多」，连上 adb。
#### 步骤二
把 boot.oat 文件从手机 pull 下来，boot.oat 包含启动相关的代码，可理解为里面有优化过的 framework.jar 文件，对应 SDK 的 android.jar 文件，文件较大，有 85M 左右。
```bash
[leidiqiu@leidiqiu: ] ~/Desktop $ adb -s 172.18.92.198:44429 pull /system/framework/arm64/boot.oat .
/system/framework/arm64/boot.oat: 1 file pulled. 0.4 MB/s (85477748 bytes in 229.612s)
[leidiqiu@leidiqiu: ] ~/Desktop $ ls -l boot.oat 
-rw-r--r--  1 leidiqiu  staff  85477748 May  8 16:17 boot.oat
```
#### 步骤三
下载 [oat2dex.jar](https://github.com/testwhat/SmaliEx/releases/download/0.86/oat2dex.jar) 工具，并将 oat 文件转换成 dex 文件，会生成 odex、dex 两个文件夹。
```bash
[leidiqiu@leidiqiu: ] ~/Desktop $ java -jar ~/libs/oat2dex.jar boot boot.oat 
05-08 16:23:27:465 Output raw dex: /Users/leidiqiu/Desktop/odex/core-libart.dex
05-08 16:23:27:466 Output raw dex: /Users/leidiqiu/Desktop/odex/conscrypt.dex
05-08 16:23:27:467 Output raw dex: /Users/leidiqiu/Desktop/odex/okhttp.dex
05-08 16:23:27:467 Output raw dex: /Users/leidiqiu/Desktop/odex/core-junit.dex
05-08 16:23:27:469 Output raw dex: /Users/leidiqiu/Desktop/odex/bouncycastle.dex
05-08 16:23:27:472 Output raw dex: /Users/leidiqiu/Desktop/odex/ext.dex
05-08 16:23:27:488 Output raw dex: /Users/leidiqiu/Desktop/odex/framework.dex
05-08 16:23:27:503 Output raw dex: /Users/leidiqiu/Desktop/odex/framework-classes2.dex
05-08 16:23:27:511 Output raw dex: /Users/leidiqiu/Desktop/odex/telephony-common.dex
05-08 16:23:27:512 Output raw dex: /Users/leidiqiu/Desktop/odex/voip-common.dex
05-08 16:23:27:516 Output raw dex: /Users/leidiqiu/Desktop/odex/ims-common.dex
05-08 16:23:27:516 Output raw dex: /Users/leidiqiu/Desktop/odex/mms-common.dex
05-08 16:23:27:517 Output raw dex: /Users/leidiqiu/Desktop/odex/android.policy.dex
05-08 16:23:27:523 Output raw dex: /Users/leidiqiu/Desktop/odex/apache-xml.dex
05-08 16:23:27:529 Output raw dex: /Users/leidiqiu/Desktop/odex/oppo-framework.dex
05-08 16:23:27:530 Output raw dex: /Users/leidiqiu/Desktop/odex/mediatek-common.dex
05-08 16:23:27:531 Output raw dex: /Users/leidiqiu/Desktop/odex/mediatek-framework.dex
05-08 16:23:27:532 Output raw dex: /Users/leidiqiu/Desktop/odex/mediatek-telephony-common.dex
05-08 16:23:27:786 De-optimizing /system/framework/core-libart.jar
05-08 16:23:30:094 Output to /Users/leidiqiu/Desktop/dex/core-libart.dex
05-08 16:23:30:094 De-optimizing /system/framework/conscrypt.jar
05-08 16:23:30:208 Output to /Users/leidiqiu/Desktop/dex/conscrypt.dex
05-08 16:23:30:208 De-optimizing /system/framework/okhttp.jar
05-08 16:23:30:356 Output to /Users/leidiqiu/Desktop/dex/okhttp.dex
05-08 16:23:30:356 De-optimizing /system/framework/core-junit.jar
05-08 16:23:30:371 Output to /Users/leidiqiu/Desktop/dex/core-junit.dex
05-08 16:23:30:371 De-optimizing /system/framework/bouncycastle.jar
05-08 16:23:30:928 Output to /Users/leidiqiu/Desktop/dex/bouncycastle.dex
05-08 16:23:30:928 De-optimizing /system/framework/ext.jar
05-08 16:23:31:483 Output to /Users/leidiqiu/Desktop/dex/ext.dex
05-08 16:23:31:483 De-optimizing /system/framework/framework.jar
05-08 16:23:36:301 Output to /Users/leidiqiu/Desktop/dex/framework.dex
05-08 16:23:36:301 De-optimizing /system/framework/framework.jar:classes2.dex
05-08 16:23:38:611 Output to /Users/leidiqiu/Desktop/dex/framework-classes2.dex
05-08 16:23:38:611 De-optimizing /system/framework/telephony-common.jar
05-08 16:23:40:395 Output to /Users/leidiqiu/Desktop/dex/telephony-common.dex
05-08 16:23:40:395 De-optimizing /system/framework/voip-common.jar
05-08 16:23:40:440 Output to /Users/leidiqiu/Desktop/dex/voip-common.dex
05-08 16:23:40:440 De-optimizing /system/framework/ims-common.jar
05-08 16:23:40:625 Output to /Users/leidiqiu/Desktop/dex/ims-common.dex
05-08 16:23:40:625 De-optimizing /system/framework/mms-common.jar
05-08 16:23:40:626 Output to /Users/leidiqiu/Desktop/dex/mms-common.dex
05-08 16:23:40:626 De-optimizing /system/framework/android.policy.jar
05-08 16:23:40:764 Output to /Users/leidiqiu/Desktop/dex/android.policy.dex
05-08 16:23:40:764 De-optimizing /system/framework/apache-xml.jar
05-08 16:23:41:178 Output to /Users/leidiqiu/Desktop/dex/apache-xml.dex
05-08 16:23:41:178 De-optimizing /system/framework/oppo-framework.jar
05-08 16:23:41:613 Output to /Users/leidiqiu/Desktop/dex/oppo-framework.dex
05-08 16:23:41:613 De-optimizing /system/framework/mediatek-common.jar
05-08 16:23:41:660 Output to /Users/leidiqiu/Desktop/dex/mediatek-common.dex
05-08 16:23:41:660 De-optimizing /system/framework/mediatek-framework.jar
05-08 16:23:41:889 Output to /Users/leidiqiu/Desktop/dex/mediatek-framework.dex
05-08 16:23:41:889 De-optimizing /system/framework/mediatek-telephony-common.jar
05-08 16:23:41:891 Output to /Users/leidiqiu/Desktop/dex/mediatek-telephony-common.dex
```
#### 步骤四
查看 dex 文件夹，发现有 framework.dex 文件。
```bash
[leidiqiu@leidiqiu: ] ~/Desktop $ cd dex/
[leidiqiu@leidiqiu: ] ~/Desktop/dex $ ls
android.policy.dex            ext.dex                       mediatek-telephony-common.dex
apache-xml.dex                framework-classes2.dex        mms-common.dex
bouncycastle.dex              framework.dex                 okhttp.dex
conscrypt.dex                 ims-common.dex                oppo-framework.dex
core-junit.dex                mediatek-common.dex           telephony-common.dex
core-libart.dex               mediatek-framework.dex        voip-common.dex
```
#### 步骤五
下载 [dex2jar-2.0.zip](https://sourceforge.net/projects/dex2jar/files/dex2jar-2.0.zip/download) 工具，将 dex 转成 jar，并用 JD-GUI 打开，JD-GUI 下载地址：http://java-decompiler.github.io/。
```bash
[leidiqiu@leidiqiu: ] ~/Desktop/dex $ dex2jar.sh framework.dex 
dex2jar framework.dex -> ./framework-dex2jar.jar
Detail Error Information in File ./framework-error.zip
Please report this file to http://code.google.com/p/dex2jar/issues/entry if possible.
[leidiqiu@leidiqiu: ] ~/Desktop/dex $ open framework-dex2jar.jar -a JD-GUI.app
```
#### 步骤六
通过 JD-GUI 查看，终于找到了 Message 类，里面确实有 toStringLite() 方法。
![](http://s3plus.sankuai.com/v1/mss_7fabbc64efb346df9722fadcafbc20bc/blog/Message.png)

## 总结
此类方法相对通用，对定位非原生 ROM 的问题很有帮助。
