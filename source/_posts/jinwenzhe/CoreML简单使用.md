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
<img src="https://p0.meituan.net/spacex/12ef25396ce3fd3687801b2cf0582d77.png" width="35%">

<!-- ​![](https://p0.meituan.net/spacex/12ef25396ce3fd3687801b2cf0582d77.png) -->
图像识别：
<img src="https://p0.meituan.net/spacex/c7a5809a62a5df0506c3a169ba7713ff.png" width="35%">
<img src="https://p0.meituan.net/spacex/5d4462d3316f734ea0677686d501d633.png" width="35%">
<!-- ​![](https://p0.meituan.net/spacex/c7a5809a62a5df0506c3a169ba7713ff.png)
​![](https://p0.meituan.net/spacex/5d4462d3316f734ea0677686d501d633.png) -->
主体识别：
<img src="https://p0.meituan.net/spacex/620c41f68a181febbd710e1633fc7439.png" width="35%">
<img src="https://p0.meituan.net/spacex/4377a0f840316051156a449d1285dce5.png" width="35%">
<!-- ​![](https://p0.meituan.net/spacex/620c41f68a181febbd710e1633fc7439.png)
​![](https://p0.meituan.net/spacex/4377a0f840316051156a449d1285dce5.png) -->
物体检测：
<img src="https://p0.meituan.net/spacex/f0a2f9ac27c39a27ac2e3af30ae59244.png" width="35%">
<img src="https://p0.meituan.net/spacex/4b286f1bc4b72ed247e280fa744b1bf1.png" width="35%">
<!-- ​![](https://p0.meituan.net/spacex/f0a2f9ac27c39a27ac2e3af30ae59244.png)
​![](https://p0.meituan.net/spacex/4b286f1bc4b72ed247e280fa744b1bf1.png) -->
使用方法：
一、下载模型：
下载链接：https://developer.apple.com/machine-learning/models/

不同的mlmodel区别在于参数精度不同
![](https://p0.meituan.net/spacex/4d9c5017d03297ea071508d25195ead2.png)
二、导入工程：
将下载好的mlmodel文件直接拖进工程文件：
![](https://p0.meituan.net/spacex/cf9d4fc0556922c6b2fa4795670b7490.png)

三、查看模型输入输出：
![](https://p0.meituan.net/spacex/acd4de65d6e0046ebb6558ed461d2be7.png)
四、导入头文件开始使用：
代码块
Objective-C
#import "SqueezeNetFP16.h"
模型介绍：
SqueezeNet
简介：
SqueezeNet 发表于ICLR-2017，作者分别来自Berkeley和Stanford，

SqueezeNet不是模型压缩技术，而是 “design strategies for CNN architectures with few parameters”

Squeezenet比alexnet参数少50倍，同时大小仅4.8mb

下图是AlexNet 与 SqueezeNet 相关参数的对照表：
![](https://p0.meituan.net/spacex/d641cb8ddc7c31ad8aad57f2694e0e2b.jpg)

使用说明：
![](https://p0.meituan.net/spacex/6a7664866f8e47ce76378f532e3e2066.png)
简单使用：

```
//加载一张需要识别的图片
UIImage *image = [UIImage imageNamed:@"fruit.jpeg"];
CGImageRef imgRef = [image CGImage];
//model 只接受CVPixelBufferRef的图片，所以先转一下
// pixelBufferFromCGImage 函数的具体内容见本文附录
CVPixelBufferRef img = [self pixelBufferFromCGImage:imgRef];
​
//初始化model
SqueezeNetFP16 *mod = [[SqueezeNetFP16 alloc] init];
//通过model的predictionFromImage函数，入参为image，出参为SqueezeNetFP16Output
SqueezeNetFP16Output *res = [mod predictionFromImage:img error:nil];
//打印出识别的名称和识别率
NSLog(@"识别为:%@,概率为:%@",res.classLabel,res.classLabelProbs[res.classLabel]);
```
SqueezeNetFP16Output的classLabelProbs属性
classLabelProbs属性包含了预测的所有种类对应的概率，

所以，res.classLabelProbs[res.classLabel]可以取出预测名称所对应的概率

```
{
    "Afghan hound, Afghan" = "9.044347437864655e-14";
    "African chameleon, Chamaeleo chamaeleon" = "1.968000415408788e-11";
    "African crocodile, Nile crocodile, Crocodylus niloticus" = "2.88645680707883e-13";
    "African elephant, Loxodonta africana" = "9.819910726585612e-13";
    "African grey, African gray, Psittacus erithacus" = "8.513797999931683e-11";
    "African hunting dog, hyena dog, Cape hunting dog, Lycaon pictus" = "1.588692420890006e-13";
    "Airedale, Airedale terrier" = "3.033485734740132e-13";
    "American Staffordshire terrier, Staffordshire terrier, American pit bull terrier, pit bull terrier" = "4.295829802991591e-10";
    "American alligator, Alligator mississipiensis" = "1.02866250673711e-12";
    "American black bear, black bear, Ursus americanus, Euarctos americanus" = "9.978090402540385e-13";
    "American chameleon, anole, Anolis carolinensis" = "2.216001861177208e-11";
    "American coot, marsh hen, mud hen, water hen, Fulica americana" = "7.412853967811
}
​```
Resnet50
简介：
Resnet是残差网络(Residual Network)的缩写,

该系列网络广泛用于目标分类等领域以及作为计算机视觉任务主干经典神经网络的一部分，

典型的网络有resnet50, resnet101等。

Resnet网络的证明网络能够向更深（包含更多隐藏层）的方向发展。



使用说明：
![](https://p0.meituan.net/spacex/49fe90eeb134d8ab5837a3e4b7f755bc.png)
简单使用：
```objectivec
//ResNet的输入图片大小要求为224*224，这里先将获取的image resize一下
CGSize size_resNet = CGSizeMake(224,224);
UIGraphicsBeginImageContextWithOptions(size_resNet, NO, 1.0);
[img drawInRect:CGRectMake(0, 0, 224, 224) blendMode:kCGBlendModeNormal alpha:1.0];
UIImage *resultImage_resNet = UIGraphicsGetImageFromCurrentImageContext();
UIGraphicsEndImageContext();
​
// UIImage 转 CVPixelBufferRef
CGImageRef imgRef_resNet = [resultImage_resNet CGImage];
CVPixelBufferRef pbimg_resNet = [self pixelBufferFromCGImage:imgRef_resNet];
​
// Resnet50Output的classLabel属性为识别的类别名称
// Resnet50Output的classLabelProbs属性为识别成每个类别的对应概率
//res_resNet.classLabelProbs[res_resNet.classLabel] 可以取出最终识别的类别的概率（即最大概率）
Resnet50Output *res_resNet = [self.mod_resNet predictionFromImage:pbimg_resNet error:nil];
//    NSLog(@"resNet识别为:%@,概率为:%@",res_resNet.classLabel,res_resNet.classLabelProbs[res_resNet.classLabel]);
​```
​
Resnet50Output的classLabelProbs属性：
同SqueezeNet

DeepLabV3
简介：
DeepLab是谷歌使用tensorflow基于CNN开发的语义分割模型，至今已更新4个版本。

最新版本是DeepLabv3+，在此模型中进一步将深度可分离卷积应用到孔空间金字塔池化和解码器模块，从而形成更快，更强大的语义分割编码器-解码器网络

![](https://p0.meituan.net/spacex/35f5a3d928e02acaef02092bce2b1e47.jpg)
使用说明：
输入为image，输出一个与image尺寸相同的矩阵，每个矩阵数值代表了对图片前后景的分类（后景为0，前景不为0）
![](https://p0.meituan.net/spacex/5cd0408eb81ec16f51400fbf4d27644b.png)

简单使用：
```objectivec
UIImage *img = info[@"UIImagePickerControllerEditedImage"];
    
//输入image 规格为513*513
//先resize图片
CGSize size = CGSizeMake(513,513);
//    UIGraphicsBeginImageContext(size);
UIGraphicsBeginImageContextWithOptions(size, NO, 1.0);
[img drawInRect:CGRectMake(0, 0, 513, 513) blendMode:kCGBlendModeNormal alpha:1.0];
UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
UIGraphicsEndImageContext();
//将原图展示在imageView中
[self.imageView setImage:resultImage];
​
//UIImage转输入要求的图片格式CVPixelBufferRef
// pixelBufferFromCGImage 函数见附录
CGImageRef imgRef = [resultImage CGImage];
CVPixelBufferRef pbimg = [self pixelBufferFromCGImage:imgRef];
​
//得到模型输出
DeepLabV3Output *res = [self.mod_deeplab predictionFromImage:pbimg error:nil];
​
//使用imageBlackToTransparent 函数处理输出，返回一张处理后的图片
// imageBlackToTransparent函数见附录
UIImage *myimg = [self imageBlackToTransparent:resultImage withArr:res.semanticPredictions];
//将处理后的图片展示在另一个imageView中
[self.imageView2 setImage:myimg];
​```


附录：
CoreML官方文档：https://developer.apple.com/documentation/coreml

pixelBufferFromCGImage: 函数
UIImage 转 CGImageRef
```objectivec
UIImage *image = [UIImage imageNamed:@"fruit.jpeg"];
CGImageRef imgRef = [image CGImage];
​```
CGImageRef 转  CVPixelBufferRef
```objectivec
- (CVPixelBufferRef)pixelBufferFromCGImage:(CGImageRef)image{
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGImageCompatibilityKey,
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGBitmapContextCompatibilityKey,
                             nil];
​
    CVPixelBufferRef pxbuffer = NULL;
​
    CGFloat frameWidth = CGImageGetWidth(image);
    CGFloat frameHeight = CGImageGetHeight(image);
​
    CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault,
                                          frameWidth,
                                          frameHeight,
                                          kCVPixelFormatType_32ARGB,
                                          (__bridge CFDictionaryRef) options,
                                          &pxbuffer);
​
    NSParameterAssert(status == kCVReturnSuccess && pxbuffer != NULL);
​
    CVPixelBufferLockBaseAddress(pxbuffer, 0);
    void *pxdata = CVPixelBufferGetBaseAddress(pxbuffer);
    NSParameterAssert(pxdata != NULL);
​
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
​
    CGContextRef context = CGBitmapContextCreate(pxdata,
                                                 frameWidth,
                                                 frameHeight,
                                                 8,
                                                 CVPixelBufferGetBytesPerRow(pxbuffer),
                                                 rgbColorSpace,
                                                 (CGBitmapInfo)kCGImageAlphaNoneSkipFirst);
    NSParameterAssert(context);
    CGContextConcatCTM(context, CGAffineTransformIdentity);
    CGContextDrawImage(context, CGRectMake(0,
                                           0,
                                           frameWidth,
                                           frameHeight),
                       image);
    CGColorSpaceRelease(rgbColorSpace);
    CGContextRelease(context);
​
    CVPixelBufferUnlockBaseAddress(pxbuffer, 0);
​
    return pxbuffer;
​
}
​```