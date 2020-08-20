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