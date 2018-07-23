<font face="微软雅黑">&emsp;**title**：该博客总结了OC中Category和Extension的相关知识，以及两者之间的区别。<br> &emsp;**date：**2018-07-04 09:30:48。<br>&emsp;**categories：**wanglibin05 <br>&emsp;**tags：**

+ OC 
+ Category 
+ Extension</font>

---

目录
##### Category

+ category的背景和概念
+ category的声明及实现
+ category的使用
+ category扩展属性（变量）

##### Extension

+ extension的格式
+ extension的实现

##### category和Extension的区别


---

一、Category
#### 1、category的背景和概念

在日常开发中，经常需要对已有类进行功能上的扩展，在学习“类别”之前，常用的类扩展方式有以下三种：

+ 原有类的修改

+ 继承

+ protocol（协议）

针对以上三种扩展方式，

+ 第一种为最原始的方法；

+ 第二种在继承父类的同时，也扩展自己，包括（方法和变量）。但是在面向对象的开发原则中“优先使用组合慎用继承”，因为继承在一定程度上破坏了封装性、子类随父类变动。

+ 第三种协议，主要是依靠实现类的具体方法实现，当扩展功能时，需要修改原有类，协议定义过多，实现类过于庞大。

&ensp;那么，在oc中，当我们想避免上述两种扩展方式的缺点，又想只对现有类进行扩展些方法，并且不用去修改原有类以及使用它的地方的代码，就用到了Category（类别）。

&ensp;类别是OC的特有语法，可以通过在类上声明和实现方法来扩展现有类的功能。原则上只能增加方法（包括对象方法和类方法），不能增加成员变量。

#### 2、category的声明及实现

    @interface 需扩展的类 （类别的名称）
    -（void）appendMethod;
    @end

	@implementation 需扩展的类 （类别的名称）
	-（void）appendMethod{
	}
	@end
#### 3、category的使用

&ensp;如果需要扩展一个类，定义好此类的category ，则可以通过该类的对象直接调用category中的扩展方法。与此同时，在category中也可以访问原有类.h中的属性和方法。

.h文件：
	
	#import <Foundation/Foundation.h>

	@interface pson : NSObject<NSCoding>
	@property (nonatomic, copy) NSString *name;
	@property (nonatomic, assign) NSInteger age;
	- (void) run;
	+ (void) jump;
	@end
.m文件

	#import "pson.h"

	@implementation pson

	-(void) run{
    	NSLog(@"run");
	}
	+(void) jump{
    	NSLog(@"jump");
	}
	@end
为pson类添加eat方法，category的.m文件如下所示：


pson+eat.h文件

	#import "pson.h"

	@interface pson (eat)
	@property (nonatomic, strong) NSString *food;
	-(void) eat;

	@end

pson+eat.m文件

	#import "pson+eat.h"

	@implementation pson (eat)
	-(void) eat{
   	//调用原有类的公共方法
    [self run];
	//调用原有类的非私有属性
    NSLog(@"%@",self.name);
	}
	+(void) drink{
    	NSLog(@"drink");
	}
	@end
	
在main方法中


	pson *me = [[pson alloc] init];
        [me run];
        //调用扩展类中的对象方法
        [me eat];
        //调用扩展类中的类方法
        [pson drink]

        
#### 4、category扩展属性（变量）

&ensp;由于category本质上是个指向类型的结构体指针，在结构体中只有方法的列表，没有属性的列表，所以理论上只能增加方法不能增加属性。

如何通过category来扩展属性呢？

&ensp;无法添加属性的根本原因是：在category中@property声明属性，系统不会生成_成员变量和setter、getter。

&ensp;解决方法：手动添加setter和getter方法，采用的就是：关联引用（objc_setAssociatedObject和objc_getAssociatedObject）

其中，

&ensp;objc_setAssociatedObject，接收4个参数：想关联到数据的对象、获取数据的键值、存储引用的值、关联的策略；

&ensp;objc_getAssociatedObject，接收2个参数：关联到数据的对象、键值

常见的关联策略，如下表所示：

| 一个普通标题 | 一个普通标题 | 
| ------ | ------ |
| OBJC _ ASSOCIATION _ ASSIGN | 指定值将被简单赋值、没有保留和释放| 
| OBJC _ ASSOCIATION _ RETAIN _ NONATOMIC | 指定值通过非线程安全的方式赋值并保留| 
| OBJC _ ASSOCIATION _ COPY _ NONATOMIC | 指定值通过非线程安全的方式复制| 
| OBJC _ ASSOCIATION _ RETAIN | 指定值通过线程安全的方式赋值并保留| 
| OBJC _ ASSOCIATION _ COPY | 指定值通过线程安全的方式复制| 

具体实现例子如下所示：

category的.h文件

	#import "pson.h"

	@interface pson (eat)
	@property (nonatomic, strong) NSString *food;
	-(void) eat;
	+(void) drink;
	@end
	
category的.m文件

	#import "pson+eat.h"
	#import "objc/runtime.h"
	static NSString *key = @"personEatKey";

	@implementation pson (eat)
	-(void) eat{
    	NSLog(@"eat");
	}

	-(void) setFood:(NSString *)food{
	    objc_setAssociatedObject(self, &key, food, 	OBJC_ASSOCIATION_COPY);
	}

	-(NSString *) food{
    	return objc_getAssociatedObject(self, &key);
	}
	@end
	
main方法中的使用如下：


	#import <Foundation/Foundation.h>
	#import "pson.h"
	#import "pson+eat.h"
	int main(int argc, const char * argv[]) {
    	@autoreleasepool {

        	pson *me = [[pson alloc] init];
        	[me eat];
        	me.food = @"鸡蛋";
			NSLog(@"%@",me.food);
        
    	}
    	return 0;
	}
	
二、Extension

&ensp;extension 是Category的特例，少了类别的名称，是匿名分类。声明私有方法和属性的机制。具体实现在原有类的.m文件中。
#### 1、extension的格式

	@interface XXX ()
		//私有属性
		//私有方法（如果不实现，编译时会报警,Method definition for 'XXX' not found）
	@end
	
#### 2、extension的实现

+ 通过单独的.h声明，在原有类的.m中导入。

+ 直接在原有类的.m中使用。

### category和Extension的区别

+ category原则上只能增加方法；而Extension方法和变量都可以。

+ Extension声明方法没有被实现，编译器报警。category在运行时添加、Extension是编译阶段。
+ Extension没有自己独立的实现部分。

+ Extension是私有。

