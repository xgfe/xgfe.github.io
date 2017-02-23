title: IOS confused attribute Part 1
date: 2017-02-23 12:00:37
tags:
---

## 概述   
本文对IOS中易混淆的两组属性：frame和bounds、id和instancetype，结合实例做了简单分析总结，学习区分和正确使用。  
<!-- more -->

## Frame && Bounds

先看一下代码：     

```
- (CGRect)frame {
	 return CGRectMake(self.frame.origin.x,self.frame.origin.y,self.frame.size.width,self.frame.size.height);
}
- (CGRect)bounds {
	 return CGRectMake(0,0,self.frame.size.width,self.frame.size.height);
}
```

bounds的原点是(0,0)点，就是View本身的坐标系统，默认都是0，0点，除非人为setbounds；     
frame的原点是任意的，相对于父视图中的坐标位置。        


参考下图示意：    
![](https://p1.meituan.net/dpnewvc/17700a291a6a67172f5d56643e036aa936025.jpg)      

frame:该View在父View坐标系统中的位置和大小，参照点是父View的坐标系统；     
bounds：该View在本地坐标系统中的位置和大小，参照点是本地坐标系统，即View自己的坐标系统，默认以0，0为起点；     
center：该View的中心点在父View坐标系统中的位置，参照点是父View坐标系统。      
通过修改View的bounds属性可以修改本地坐标系统的原点位置。    
例:

	[view setBounds:CGRectMake(-20, -20, 300, 300)];         
	  	
则View坐标系的原点为（-20，-20）   
bounds参考自己坐标系，可以修改自己坐标系的原点位置，进而影响到“子view”的显示位置
   

demo演示:

``` 
	UIView *view1 = [[UIView alloc] initWithFrame:CGRectMake(20, 20, 280, 250)];  
	[view1 setBounds:CGRectMake(-20, -20, 280, 250)];  
	view1.backgroundColor = [UIColor redColor];  
	[self.view addSubview:view1];//添加到self.view  
	NSLog(@"view1 frame:%@========view1 bounds:%@",NSStringFromCGRect(view1.frame),NSStringFromCGRect(view1.bounds));  
		  
	UIView *view2 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];  
	view2.backgroundColor = [UIColor yellowColor];  
	[view1 addSubview:view2];//添加到view1上,[此时view1坐标系左上角起点为(-20,-20)]  
	NSLog(@"view2 frame:%@========view2 bounds:%@",NSStringFromCGRect(view2.frame),NSStringFromCGRect(view2.bounds));     
```
 
#### 结果如图所示：   
![](https://p0.meituan.net/dpnewvc/4721b54d14f6ba0a90468588ea7dd5e861110.jpg)     

为何（-20，-20）的偏移量，却可以让view2向右下角移动呢？   
这是因为setBounds的作用是：    
强制将自己（view1）坐标系的左上角点，改为（-20，-20），那么view1的原点（0，0），自然就向右下方偏移（20，20）。    
     
       
 
## id && instancetype    

### 概述   
instancetype是clang3.5开始提供的一个关键字，与id一样表示未知类型的Objective-C对象。     
	
### 关联返回类型和非关联返回类型     

1. 关联返回类型  
	根据cocoa的命名规则，满足下述规则的方法   
	> 类方法中以alloc和new开头     
	> 实例方法中，以autorelease、init、retain、self开头    
	  
	会返回一个方法所在类类型的对象，即这些方法的返回结果以方法所在的类为类型。     
例：

	```
	@interface NSObject    
	+ (id)alloc;    
	- (id)init;  
	@end  
	
	```
	当我们使用如下方式初始化NSArray时：

 ```
	NSArray *array = [[NSArray alloc] init];     	 
 ```
	按照Cocoa的命名规则，[NSArray alloc]与[[NSArray alloc]init]返回的都为NSArray的对象。
	
2. 非关联返回类型  
  
	```
	 @interface NSArray    
    + (id)constructAnArray;  
	 @end   
		
	```
	当我们使用如下方式初始化NSArray时：

     ```
	 [NSArray constructAnArray];  
	 ```
  根据Cocoa的方法命名规范，得到的返回类型就和方法声明的返回类型一样，是id。    
	
   但是如果使用instancetype作为返回类型，如下：

    ```
	@interface NSArray  
	+ (instancetype)constructAnArray;    
	@end      
	```
   当使用相同方式初始化NSArray时：

  ```
	[NSArray constructAnArray];    
	```
 得到的返回类型和方法所在类的类型相同，是NSArray*。   
	
- 总结：instancetype的作用就是使那些非关联返回类型的方法返回所在类的类型。      
	
### instancetype和id区别(总结)       
- instancetype可以返回和方法所在类相同类型的对象，id只能返回未知类型的对象。
- instancetype只能作为返回值，不能像id那样作为参数。 