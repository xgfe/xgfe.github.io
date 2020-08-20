title: CoreML简单使用
date: 2020-08-20
categories: jinwenzhe
tags:
- iOS
- CoreML


---
简介：
        Core ML 是一个框架，支持iPhone的一些功能，比如FaceID、Animoji和增强现实AR。
        自从Core ML在2017年发布以来，它已经走过了很长的路，现在它支持大量的工具，可以帮助我们快速构建基于机器学习的应用程序。
        Core ML通过轻松集成机器学习模型来提供惊人的快速性能，使你仅需几行代码即可构建具有智能新功能的应用程序。
        使用由Core ML支持的API轻松地将预建的机器学习功能添加到您的应用程序中，或者使用Create ML以获得更大的灵活性，并在Mac上训练自定义的Core ML模型。
        你还可以使用Core ML Converters转换其他培训库中的模型，或下载即可使用的Core ML模型。
        Core ML提供了一系列的API，仅需几行代码，即可将设备上的机器学习功能（如图像和视频中的对象检测，语言分析和声音分类）带到您的应用中。

​![](https://p0.meituan.net/spacex/ceadf7f29a7865d11a79e999447d08ad.png)

优势：
简单、轻量：
模型是将机器学习算法应用于一组训练数据的结果。您可以基于新的输入数据使用模型进行预测。
一些很难或者用代码编写起来很困难的任务，可以通过模型来完成。
例如，您可以训练模型对照片进行分类，或者直接使用现有照片来进行识别。

性能、离线、安全：
Core ML通过利用CPU，GPU和神经引擎来优化设备上的性能，同时最大程度地减少其内存占用空间和功耗。
只在用户设备上运行模型可以消除对网络连接的任何需求，这有助于保持用户数据的私密性和您的应用程序的响应速度。


宗旨：
Build intelligence into your apps using machine learning models from the research community designed for Core ML.

使用研究社区专门为Core ML设计的机器学习模型，将智能构建到您的应用中。

CoreML官网中可供使用的一些关于计算机视觉的模型：

​![](https://p0.meituan.net/spacex/3ddf02503149cfe5c10ef3b91d6f10db.png)

Demo展示：
主界面：
​![](https://p0.meituan.net/spacex/12ef25396ce3fd3687801b2cf0582d77.png)
图像识别：
​![](https://p0.meituan.net/spacex/c7a5809a62a5df0506c3a169ba7713ff.png)
​![](https://p0.meituan.net/spacex/5d4462d3316f734ea0677686d501d633.png)
主体识别：
​![](https://p0.meituan.net/spacex/620c41f68a181febbd710e1633fc7439.png)
​![](https://p0.meituan.net/spacex/4377a0f840316051156a449d1285dce5.png)
物体检测：
​![](https://p0.meituan.net/spacex/f0a2f9ac27c39a27ac2e3af30ae59244.png)
​![](https://p0.meituan.net/spacex/4b286f1bc4b72ed247e280fa744b1bf1.png)
使用方法：
一、下载模型：
下载链接：https://developer.apple.com/machine-learning/models/

不同的mlmodel区别在于参数精度不同
![](https://p0.meituan.net/spacex/4d9c5017d03297ea071508d25195ead2.png)
二、导入工程：
将下载好的mlmodel文件直接拖进工程文件：
![](https://p0.meituan.net/spacex/cf9d4fc0556922c6b2fa4795670b7490.png)

三、查看模型输入输出：
![](ttps://p0.meituan.net/spacex/acd4de65d6e0046ebb6558ed461d2be7.png)
四、导入头文件开始使用：
代码块
Objective-C
#import "SqueezeNetFP16.h"
模型介绍：
SqueezeNet