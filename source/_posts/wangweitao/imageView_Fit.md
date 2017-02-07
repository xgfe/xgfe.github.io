
title: ImageView的scaleType属性效果
date: 2017-01-13
categories: wangweitao
tags:
- andorid
- imageView scaleType
---
android中的imageView在图片大小不完全一致时会进行相应的缩放或者裁剪。scaleType属性决定缩放裁剪的效果，这里总结了下在各种情况下的缩放裁剪效果。

<!--more-->
## ImageView中ScaleType属性效果

### imageview的宽高为wrap_content
- scaletype的值不影响结果，图片按照原有大小展示
![](https://p0.meituan.net/dpnewvc/a2f1b906686c357a59a5d362a6fb32f3547985.png)

### imageview的宽固定&高为wrap_content
- imageview宽度的值为固定值，高度按照图片的高度计算。

#### 宽大于图片宽度
- matrix：宽度靠左，填充满高度
- fitstart：同上
![](https://p0.meituan.net/dpnewvc/2e6e71a284dd4bd6d548e04805c1be76548788.png)

- center：宽度居中，填充满高度
- centerInside：同上
- fitcenter：同上
![](https://p1.meituan.net/dpnewvc/69fbc333327e5df8fede90f4f3db0797548853.png)

- centerCrop：宽度填充，高度截取中间部分；图片展示不全
![](https://p0.meituan.net/dpnewvc/e53152213fd8b0af4cd44108de0b6746895640.png)

- fitend：宽度靠右，填充满高度
![](https://p0.meituan.net/dpnewvc/ad4639a9de366c11b3e8cd793e982eb9547758.png)

- fitxy：宽度填充，高度填充；图片变形
![](https://p0.meituan.net/dpnewvc/e9701efbee755771ef25a7032922533f701299.png)


#### 宽小于图片宽度
- matrix：显示左侧部分，填充满高度
![](https://p0.meituan.net/dpnewvc/9ca7525670c4b20c38c66786ca56014186658.png)

- fitstart：宽度缩小居中，高度靠上
![](https://p0.meituan.net/dpnewvc/49e7f4bb46446683521b6c8a423c689583618.png)

- center：显示中间部分图片，填充满高度；图像显示不全
- centerCrop：同上
![](https://p0.meituan.net/dpnewvc/74ebc9edd6aff6e815f9fbe9e513aa37288486.png)

- centerInside：宽度缩小且居中，高度居中
- fitcenter：同上
![](https://p0.meituan.net/dpnewvc/41f568b5568559045bc7a75f6010ed3983587.png)

- fitend：宽度缩小居中，高度靠下
![](https://p1.meituan.net/dpnewvc/7f3948ecaba0183230d37259ea0bd28c83641.png)

- fitxy：宽度缩放填充，高度缩放填充；图像变形
![](https://p1.meituan.net/dpnewvc/0198a92eea8b1a3a1a95a18e5e9a5703153906.png)

### imageView宽wrap_content&高固定

#### imageView高大于图片高度
- matrix：宽填充，高靠上
- fitstart：同上
![](https://p1.meituan.net/dpnewvc/e93403fa33842d3b76d3dd5c13de5406546264.png)

- center：宽填充，高居中
- centerInside：同上
- fitcenter：同上
![](https://p1.meituan.net/dpnewvc/bf0893257327052edb8c9ee611ed7e46549666.png)

- centerCrop：宽显示中间部分，高填充居中；图片显示不全
![](https://p1.meituan.net/dpnewvc/9efede97a1b28e8ecf2a982bebccc67b1284114.png)

- fitend：宽填充，高靠下
![](https://p0.meituan.net/dpnewvc/a68b0ab08eaac625e95d25f5f0d40a10544645.png)

- fitxy：宽填充，高填充；图片变形
![](https://p0.meituan.net/dpnewvc/a02468cf3831c681758aec46a96819c2860692.png)

#### imageView高小于图片高度
- matrix：宽度填充，高度显示靠上的部分；图片显示不全
![](https://p1.meituan.net/dpnewvc/3aa6cbb94fd6211eea3bf8e35f24743884883.png)

- fitstart：高度缩小居中，宽度显示靠左
![](https://p0.meituan.net/dpnewvc/395262b6ffe83e3fda57d1e5de483e1582554.png)

- center：宽度填充，高度显示中间的部分；图片显示不全
- centerCrop：同上
![](https://p1.meituan.net/dpnewvc/ea3f989c644839ccf04a36687af90cee273401.png)

- centerInside：宽度缩小居中，高度缩小居中
- fitcenter：同上
![](https://p0.meituan.net/dpnewvc/719958c69be4f17470b44f6b06663c2781227.png)

- fitend：宽度靠右，高度缩小居中
![](https://p0.meituan.net/dpnewvc/49aaa375e2e7f5cbe417b62a2e973e4282812.png)

- fitxy：宽度填充，高度缩小；图片变形
![](https://p0.meituan.net/dpnewvc/f3c016de087d8ceac182a54a7540f938138397.png)