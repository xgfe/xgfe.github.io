title: 关于富文本AttributedString的使用总结
date: 2017.09.22 16:00:00
categories: Sudaxi
tags:
- iOS
---
本文主要分析了富文本常用的属性设置，平时工作过程经常遇到一些有特殊需求的label、UITextField、UITextView。一般情况下，大家都喜欢直接用多个label来实现其不同的属性，很多人忽略了label本身的富文本属性。本文针对富文本进行了详细的介绍。
<!--more-->

首先先大概了解一下NSAttributedString 的21个属性。
常见的属性大概如下：
<img src="http://p0.meituan.net/xgfe/8ac5ef6b34677319cfc020c8a1406681105850.jpg" width="600" height="600" alt="常见属性"/>

API: Character Attributes , NSAttributedString 共有21个属性

     1. NSFontAttributeName ->设置字体属性，默认值：字体：Helvetica(Neue) 字号：12
     2. NSParagraphStyleAttributeName ->设置文本段落排版格式，取值为 NSParagraphStyle 对象
     3. NSForegroundColorAttributeName ->设置字体颜色，取值为 UIColor对象，默认值为黑色
     4. NSBackgroundColorAttributeName ->设置字体所在区域背景颜色，取值为 UIColor对象，默认值为nil, 透明色
     5. NSLigatureAttributeName ->设置连体属性，取值为NSNumber 对象(整数)，0 表示没有连体字符，1 表示使用默认的连体字符
     6. NSKernAttributeName ->设置字符间距，取值为 NSNumber 对象（整数），正值间距加宽，负值间距变窄
     7. NSStrikethroughStyleAttributeName ->设置删除线，取值为 NSNumber 对象（整数）
     8. NSStrikethroughColorAttributeName ->设置删除线颜色，取值为 UIColor 对象，默认值为黑色
     9. NSUnderlineStyleAttributeName ->设置下划线，取值为 NSNumber 对象（整数），枚举常量 NSUnderlineStyle中的值，与删除线类似
     10. NSUnderlineColorAttributeName ->设置下划线颜色，取值为 UIColor 对象，默认值为黑色
     11. NSStrokeWidthAttributeName ->设置笔画宽度(粗细)，取值为 NSNumber 对象（整数），负值填充效果，正值中空效果
     12. NSStrokeColorAttributeName ->填充部分颜色，不是字体颜色，取值为 UIColor 对象
     13. NSShadowAttributeName ->设置阴影属性，取值为 NSShadow 对象
     14. NSTextEffectAttributeName ->设置文本特殊效果，取值为 NSString 对象，目前只有图版印刷效果可用
     15. NSBaselineOffsetAttributeName ->设置基线偏移值，取值为 NSNumber （float）,正值上偏，负值下偏
     16. NSObliquenessAttributeName ->设置字形倾斜度，取值为 NSNumber （float）,正值右倾，负值左倾
     17. NSExpansionAttributeName ->设置文本横向拉伸属性，取值为 NSNumber （float）,正值横向拉伸文本，负值横向压缩文本
     18. NSWritingDirectionAttributeName ->设置文字书写方向，从左向右书写或者从右向左书写
     19. NSVerticalGlyphFormAttributeName ->设置文字排版方向，取值为 NSNumber 对象(整数)，0 表示横排文本，1 表示竖排文本
     20. NSLinkAttributeName ->设置链接属性，点击后调用浏览器打开指定URL地址
     21.NSAttachmentAttributeName ->设置文本附件,取值为NSTextAttachment对象,常用于文字图片混排

下面分别详细介绍整段文字不同属性的两种使用方式：

1、对一整段文字进行初始化，分范围（range主要是NSMakeRange(NSUInteger loc, NSUInteger len)）下标和长度进行属性化。实现不同的文字样式，再进行控件赋值。
	     
    //其中\n可以达到分行的效果
    NSString *str = @"鲁班七号\n啦哈哈哈哈，不得了了。\n有人需要技术支持吗？\n鲁班大师，智商二百五，膜拜，极度膜拜。\n正在思考，如何攻克地心引力。\n请你们绕行，见识新发明的威力。\n不得不承认，有时候肌肉比头脑管用。\n检测了对面的智商，嘿嘿嘿，看来无法发挥全部实力啦。\n漏漏漏漏漏漏油啦。\n看，天上的飞机。\n相信科学。\n刮风了，吓到了。\n我想静～静～～";
    NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc] initWithString:str];
    //改变某个范围的文字颜色
    [attributedStr addAttribute:NSForegroundColorAttributeName value:[UIColor magentaColor] range:NSMakeRange(16, 10)];
    //设置特殊字体
    [attributedStr addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:20] range:NSMakeRange(27, 4)];
    
    [attributedStr addAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:17],
                                   NSUnderlineStyleAttributeName:@1,
                                   NSUnderlineColorAttributeName:[UIColor redColor]
                                   } range:NSMakeRange(32, 5)];
    
    [attributedStr addAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:30],
                                   NSForegroundColorAttributeName:[UIColor brownColor],
                                   NSBackgroundColorAttributeName:[UIColor yellowColor]
                                   } range:NSMakeRange(0, 4)];
    //给控件赋值
    self.showLa.attributedText = attributedStr;
    
 运行效果如下：   
 <img src="http://p0.meituan.net/xgfe/c2aebeaf980a1a784389fa2c4afa2efa113929.jpg" width="300" height="300" alt=""/>
 
 
 2、整段文字，根据不同的需求，拆分成n个string。创建字典，将每个string的属性初始化。然后通过拼接string将文字串起来。再给控件的赋值
 
     NSMutableAttributedString *muAttributedStr = [[NSMutableAttributedString alloc] init];
     NSString *titleStr = @"王昭君。\n";
     NSDictionary *titleDict = @{
                                 NSFontAttributeName:[UIFont boldSystemFontOfSize:30],
                                 NSForegroundColorAttributeName:[UIColor brownColor],
                                 NSBackgroundColorAttributeName:[UIColor yellowColor]
                                 };
     NSAttributedString *attStr = [[NSAttributedString alloc] initWithString:titleStr attributes:titleDict];
     [muAttributedStr appendAttributedString:attStr];
    
     NSShadow *shadow = [[NSShadow alloc] init];
     shadow.shadowColor = [UIColor purpleColor];
     shadow.shadowOffset = CGSizeMake(5, 5);
     shadow.shadowBlurRadius = 3.0; 
    NSString *str1 = @"凛冬已至，故乡的梅花开了吗。\n心已经融化。\n身躯已然冰封，灵魂仍旧火热。\n寒梅，无处不在。\n";
    NSDictionary *dict1 = @{
                             NSKernAttributeName:@5,//字符间距
                             NSShadowAttributeName:shadow,//阴影
                             NSStrikethroughStyleAttributeName:@2,
                             NSStrikethroughColorAttributeName:[UIColor redColor]
                             };
     NSAttributedString *attStr1 = [[NSAttributedString alloc] initWithString:str1 attributes:dict1];
     [muAttributedStr appendAttributedString:attStr1];
    
    
     NSString *str2 = @"凛寒梅，无处不在。\n替你们消消火。\n";
     NSDictionary *dict2 = @{
                             NSKernAttributeName:@5,//字符间距
                             NSShadowAttributeName:shadow,//阴影
                             NSStrikethroughStyleAttributeName:@2,
                             NSStrikethroughColorAttributeName:[UIColor redColor]
                             };
     NSAttributedString *attStr2 = [[NSAttributedString alloc] initWithString:str2 attributes:dict2];
     [muAttributedStr appendAttributedString:attStr2];
    
     NSString *str3 = @"百梅落下之日，归去故里之时。\n";
     NSDictionary *dict3 = @{
                             NSBaselineOffsetAttributeName:@5,
                             NSUnderlineStyleAttributeName:@1,
                             NSUnderlineColorAttributeName:[UIColor redColor],
                             NSObliquenessAttributeName:@1
                             };
     NSAttributedString *attStr3 = [[NSAttributedString alloc] initWithString:str3 attributes:dict3];
     [muAttributedStr appendAttributedString:attStr3];
    
     NSString *str31 = @"美貌是种罪孽，暴雪也无法掩埋。\n";
     NSDictionary *dict31 = @{
                             NSBaselineOffsetAttributeName:@2,
                             NSUnderlineStyleAttributeName:@3,
                             NSUnderlineColorAttributeName:[UIColor yellowColor],
                             NSObliquenessAttributeName:@0
                             };
     NSAttributedString *attStr31 = [[NSAttributedString alloc] initWithString:str31 attributes:dict31];
     [muAttributedStr appendAttributedString:attStr31];
    
     NSString *str32 = @"看见了.....故乡的.......春天。\n";
     NSDictionary *dict32 = @{
                              NSBaselineOffsetAttributeName:@24,
                              NSUnderlineStyleAttributeName:@2,
                              NSUnderlineColorAttributeName:[UIColor greenColor],
                              NSObliquenessAttributeName:@(-1),
                              NSExpansionAttributeName:@(-0.5)
                              };
     NSAttributedString *attStr32 = [[NSAttributedString alloc] initWithString:str32 attributes:dict32];
     [muAttributedStr appendAttributedString:attStr32];
其中需要注意的是：
NSStrikethroughStyleAttributeName（删除线）、NSUnderlineStyleAttributeName的value（下划线）: 1~7单线,依次加粗  9~15:双线,依次加粗
NSObliquenessAttributeName（倾斜）：正值右倾,负值左倾
 运行效果如下：   
 <img src="http://p1.meituan.net/xgfe/9da9d0eeed5b545b73b8e7d14e2b3afe99240.jpg" width="300" height="300" alt=""/>

图文混排的使用：
一、将图片和文字分别初始化成不同的NSAttributedString，然后拼接到NSMutableAttributedString，赋值到控件上。

    NSString *str1= @"刻骨铭心~霸王！明媚如风，轻盈似箭！啊~已经放弃了做个淑女~";
    NSString *str2= @"净化森林，净化污秽，净化心灵，净化自己。风会带走你曾经存在过的证明。";
    
    NSMutableAttributedString *muAttributedStr = [[NSMutableAttributedString alloc] init];
    
    NSAttributedString *attStr = [[NSAttributedString alloc] initWithString:str1 attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16],
                                                                                              NSForegroundColorAttributeName:[UIColor magentaColor]
                                                                                              }];
    NSTextAttachment *attachment = [[NSTextAttachment alloc]init];
    attachment.image = [UIImage imageNamed:@"yujiphoto"];
    attachment.bounds = CGRectMake(0, 0, 110, 70);
    
    NSAttributedString *attStr1 = [NSAttributedString attributedStringWithAttachment:attachment];
    
    NSAttributedString *attStr2= [[NSAttributedString alloc] initWithString:str2 attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14],
                                                                                              NSBackgroundColorAttributeName:[UIColor clearColor]}];
    
     [muAttributedStr appendAttributedString:attStr];
     [muAttributedStr appendAttributedString:attStr1];
     [muAttributedStr appendAttributedString:attStr2];

二、使用insertAttributedString将图片插入到文字中。

    
    NSString *str3 = @"一点疼痛能让偷窥者牢记我的魅力！不为所爱之人哭泣，只因从未离去。想和风比赛脚力吗？弱小，并非服从恐惧的理由！";
    NSMutableAttributedString *mustr = [[NSMutableAttributedString alloc] initWithString:str3];
    NSTextAttachment *attachMent1 = [[NSTextAttachment alloc] init];
    attachMent1.image = [UIImage imageNamed:@"photo23"];
    attachMent1.bounds = CGRectMake(0, 0, 110, 70);
    [mustr addAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:20],
                             NSForegroundColorAttributeName:[UIColor greenColor]
                             } range:NSMakeRange(0, 8)];
    NSAttributedString *att = [NSAttributedString attributedStringWithAttachment:attachMent1];
    [mustr insertAttributedString:att atIndex:6];
    [muAttributedStr appendAttributedString:mustr];
    使用
    self.showLa.attributedText = muAttributedStr;
 运行效果如下：   
  <img src="http://p0.meituan.net/xgfe/dccd36a6ac1a8845cbad513316355332110431.jpg" width="300" height="300" alt=""/>



介绍了富文本的常用属性，并且介绍了一些常用的场景后，安利一个富文本第三方库---YYText（github的地址---https://github.com/ibireme/YYText）。详细的使用可以参考一下github上面的介绍。
