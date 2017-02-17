---
title: 我是如何实现IOS原生弹窗效果的
date: 2017-02-17 12:10:21
categories: shsoul
tags: 
- IOS
- UI
---

## 步骤1
建立一个dialogController，里面一个view用于弹窗。具体就不写了，详情见[demo](https://github.com/shsoul/ShDialog)（只是demo，样式什么的得自己调。）。需要注意的是怎么弹窗，我们需要看到弹窗后面的背景，因此要：

```
DialogViewController *dialog = [[DialogViewController alloc] init];
dialog.modalPresentationStyle = UIModalPresentationOverFullScreen;    
self.definesPresentationContext = YES;
[self presentViewController:dialog animated:NO completion:nil];
```

## 步骤2

添加弹窗动画:透明度渐变和缩放,这里用到了spring动画。需要注意的是在viewWillAppear或者viewDidAppear里面调用弹窗动画，不然看不到动画效果。

```
- (void)viewDidLoad {
	_contentView.transform = CGAffineTransformMakeScale(2, 2);
    _contentView.alpha = 0;
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self show];
}
- (void)show {
    CGFloat dTime = 0.35;
    [UIView animateWithDuration:dTime animations:^{
        self.contentView.alpha = 1;
    }];
    
    [UIView animateWithDuration:dTime delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:10 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.contentView.transform = CGAffineTransformMakeScale(1, 1);
    } completion:^(BOOL finished) {
        [self animateDidCompletion];
    }];
}
```

<video width=300 src="https://p0.meituan.net/dpnewvc/8f7e51d2071255106925286cf402630b684961.mov" controls></video>

## 步骤3

添加毛玻璃（模糊）效果,IOS8后用这种方式实现毛玻璃效果。非常方便。

```
UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
_effectView = [[UIVisualEffectView alloc] initWithEffect:effect];
_effectView.layer.cornerRadius = 12;
_effectView.clipsToBounds = YES;
[self.contentView addSubview:_effectView];
```
<img width=300 src="https://p0.meituan.net/dpnewvc/ede0c61f2c269eee769e3c618b49efd686526.png"></img>

但是这块毛玻璃也太暗了，而用`UIBlurEffectStyleExtraLight`后，毛玻璃又不明显。怎么办？

<img width=300 src="https://p0.meituan.net/dpnewvc/747b880915a92b39422cebb0bb9df1d979091.png"></img>

## 步骤4
 
UIBezierPath+CAShapeLayer来挖洞。毛玻璃太暗的原因是受到背景颜色（灰色）的影响。因此在弹窗的View背后挖一个一样大小的洞来解决。

```
- (void)animateDidCompletion {
    UIBezierPath *cPath = [UIBezierPath bezierPathWithRoundedRect:self.contentView.frame cornerRadius:12];
    UIBezierPath *wPath = [UIBezierPath bezierPathWithRect:self.view.bounds];
    [wPath appendPath:cPath];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    [self.view.layer addSublayer:maskLayer];
    maskLayer.path = wPath.CGPath;
    maskLayer.fillRule = kCAFillRuleEvenOdd;
    self.view.backgroundColor = [UIColor clearColor];
    self.contentView.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.5];
    maskLayer.fillColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.45].CGColor;
}
```
<video width=300 src="https://p1.meituan.net/dpnewvc/edebca77423a9164f4275979824fd3dc789621.mov" controls></video>

## 总结

总的来说，比较麻烦的是如何实现跟系统基本一致的毛玻璃弹窗效果。开始试过几种方法都不理想，总是受到背景色的影响，不是偏暗就是毛玻璃效果不明显。最后就用挖洞的方式实现。总体来说效果还可以。本文的demo代码在[这里](https://github.com/shsoul/ShDialog)。




