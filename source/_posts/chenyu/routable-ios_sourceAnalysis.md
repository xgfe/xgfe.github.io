title: routable-ios 源码解析
date: 2018-04-07 13:12
categories:
- chenyu
tags:
- iOS
- 源码
- 路由

---

本文主要分析 [routable-ios](https://github.com/clayallsopp/routable-ios) 源码，通过本文可以了解路由的原理及使用。本文分为六个部分，从代码结构到具体的类依次介绍，文章最后会给出在项目中注册路由常用的方式。

<!--more-->
## 一、routable-ios 是什么？可以用来做什么？与之类似的框架还有哪些？
* routable-ios 是一个路由框架，由两个文件四个类组成，其中核心的类就一个。
* 可以很方便的实现 iOS 中`UIViewController`之间的跳转。跳转方式也可以灵活的设置，后面具体会讲到。
* 类似的框架还有 [ABRouter](https://github.com/aaronbrethorst/ABRouter) & [HHRouter](https://github.com/lightory/HHRouter)。后期的文章也会对 HHRouter 做介绍。

## 二、routable-ios 中类的关系
&nbsp;&nbsp;了解类与类之间的关系，有助于理解整个框架。`Routable`继承自`UPRouter`，主要的功能都在`UPRouter`类中，路由主要的功能其实就两个：

* 注册希望路由跳转的类及`URL`
* 进行跳转


![routable-ios 类组织结构.png](http://upload-images.jianshu.io/upload_images/142772-7f18a54a0a327233.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)


## 三、routable-ios 如何使用
* 将`routable-ios`导入项目
* 注册路由：
	```
	[[Routable sharedRouter] map:@"user/:name/:age" toController:[UserController class]];
	```
* 调用路由进行跳转：
	```
	[[Routable sharedRouter] open:@"user/chenyu/28"];
	```
* 在 VC 中获取传递的参数

	```
	@implementation UserController
	
	- (id)initWithRouterParams:(NSDictionary *)params {
	  if ((self = [self initWithNibName:nil bundle:nil])) {
	    self.title = @"User";
	      NSLog(@"name: %@",[params objectForKey:@"name"]); //chenyu
	      NSLog(@"age: %@",[params objectForKey:@"age"]);   //28
	  }
	  return self;
	}
	
	@end
	```

## 四、routable-ios 中的核心类
&nbsp;&nbsp;核心类分别有：`Routable`，`UPRouterOptions`，`RouterParams`，`UPRouter`
### 1.`Routable`
&nbsp;&nbsp;`Routable`继承自`UPRouter`

```
+ (instancetype)sharedRouter; //提供单例方法，用来创建路由类
+ (instancetype)newRouter;     //另一种创建路由的方式，一般不推荐，不是单例。
```

### 2.`UPRouterOptions`
&nbsp;&nbsp;`UPRouterOptions`继承自`NSObject`。首先看一下这个类提供的一些属性，我们就知道这个类是做什么的了。

```
@property (readwrite, nonatomic, getter=isModal) BOOL modal;  //是否是模态视图
@property (readwrite, nonatomic) UIModalPresentationStyle presentationStyle;  //VC 显示的样式
@property (readwrite, nonatomic) UIModalTransitionStyle transitionStyle;  //VC 出现时的动画
@property (readwrite, nonatomic, strong) NSDictionary *defaultParams;  //默认的数据
@property (readwrite, nonatomic, assign) BOOL shouldOpenAsRootViewController; //是否是根视图

//.m 文件中的两个属性
@property (readwrite, nonatomic, strong) Class openClass;  //注册的类
@property (readwrite, nonatomic, copy) RouterOpenCallback callback;  //block 回调
```
&nbsp;&nbsp;通过以上内容，可以看到`UPRouterOptions`其实就是一个配置类，里面存储路由跳转时需要的一些数据，可以理解成一个辅助的类。这个类中提供了一系列的工厂方法，用来创建不同类型的对象，比如（只列举部分函数，其他同类型的函数还有很多，功能大体一致，只是某个配置项不同而已。）：

* 全部使用默认配置

	```
	//Default construction; like [NSArray array]
	+ (instancetype)routerOptions {
	  return [self routerOptionsWithPresentationStyle:UIModalPresentationNone
	                                  transitionStyle:UIModalTransitionStyleCoverVertical
	                                    defaultParams:nil
	                                           isRoot:NO
	                                          isModal:NO];
	}
	```

* 传入所有参数创建对象

	```
	//Explicit construction
	+ (instancetype)routerOptionsWithPresentationStyle: (UIModalPresentationStyle)presentationStyle
	                                   transitionStyle: (UIModalTransitionStyle)transitionStyle
	                                     defaultParams: (NSDictionary *)defaultParams
	                                            isRoot: (BOOL)isRoot
	                                           isModal: (BOOL)isModal {
	  UPRouterOptions *options = [[UPRouterOptions alloc] init];
	  options.presentationStyle = presentationStyle;
	  options.transitionStyle = transitionStyle;
	  options.defaultParams = defaultParams;
	  options.shouldOpenAsRootViewController = isRoot;
	  options.modal = isModal;
	  return options;
	}
	```
* 自定义部分参数创建对象

	```
	//Custom class constructors, with heavier Objective-C accent
	+ (instancetype)routerOptionsAsModal {
	  return [self routerOptionsWithPresentationStyle:UIModalPresentationNone
	                                  transitionStyle:UIModalTransitionStyleCoverVertical
	                                    defaultParams:nil
	                                           isRoot:NO
	                                          isModal:YES];
	}
	```
* 剩余的基本就是一些快捷的方法及一些`setters`方法，可以查看源码。

### 3.`RouterParams`
&nbsp;&nbsp;`RouterParams`继承自`NSObject`。`RouterParams`并没有在.h 文件中做声明，这个类只在`Routable`和`UPRouter`中的实现中才用到，而这三个类都在一个文件中，所以也没有必要出现在 .h 文件中。
首先看一下`RouterParams`的声明：

```
@interface RouterParams : NSObject

@property (readwrite, nonatomic, strong) UPRouterOptions *routerOptions;
@property (readwrite, nonatomic, strong) NSDictionary *openParams; 
@property (readwrite, nonatomic, strong) NSDictionary *extraParams;
@property (readwrite, nonatomic, strong) NSDictionary *controllerParams;

@end
```
&nbsp;&nbsp;这个类的出现，主要作用是将跳转时匹配好的所有内容存起来，缓存到另一个字典中，未来再次跳转的时候，直接可以拿出来用，你也许会问，我们的路由不是在一个字典里吗，也可以直接拿出来用，为什么还要缓存，后续到源代码的地方会细说，为什么要缓存，为什么跳转的时候不是直接去 map 中寻找。
            
### 4.`UPRouter`
&nbsp;&nbsp;`UPRouter`继承自`NSObject`，首先看一下类的声明，删除了很多注释。

```
@interface UPRouter : NSObject

/**
 The UINavigationController instance which mapped UIViewControllers will be pushed onto.
 */
@property (readwrite, nonatomic, strong) UINavigationController *navigationController;

- (void)pop;
- (void)popViewControllerFromRouterAnimated:(BOOL)animated;
- (void)pop:(BOOL)animated;

@property (readwrite, nonatomic, assign) BOOL ignoresExceptions;

- (void)map:(NSString *)format toCallback:(RouterOpenCallback)callback;
- (void)map:(NSString *)format toCallback:(RouterOpenCallback)callback withOptions:(UPRouterOptions *)options;
- (void)map:(NSString *)format toController:(Class)controllerClass;
//注册路由，本篇主要分析的方法。上面的方法最终会调用这个方法，options 传入的是 nil
- (void)map:(NSString *)format toController:(Class)controllerClass withOptions:(UPRouterOptions *)options;


- (void)openExternal:(NSString *)url;
- (void)open:(NSString *)url;
- (void)open:(NSString *)url animated:(BOOL)animated;
//路由跳转，本篇主要分析的方法。上面两个方法最终都会调用这个方法。
- (void)open:(NSString *)url animated:(BOOL)animated extraParams:(NSDictionary *)extraParams;

- (NSDictionary*)paramsOfUrl:(NSString*)url;

@end
```
```
@interface UPRouter ()

// 存储注册的路由
@property (readwrite, nonatomic, strong) NSMutableDictionary *routes;
// 缓存已跳转过的路由
@property (readwrite, nonatomic, strong) NSMutableDictionary *cachedRoutes;

@end
```

&nbsp;&nbsp;注册路由比较简单，就是将传入的`URL`作为 key，将`Class`作为值存入已初始化的`routes`中。

```
- (void)map:(NSString *)format toController:(Class)controllerClass {
  [self map:format toController:controllerClass withOptions:nil];
}

- (void)map:(NSString *)format toController:(Class)controllerClass withOptions:(UPRouterOptions *)options {
  if (!format) {
    @throw [NSException exceptionWithName:@"RouteNotProvided"
                                   reason:@"Route #format is not initialized"
                                 userInfo:nil];
    return;
  }
  //如果没有传入 options，则会创建一个默认的配置对象
  if (!options) {
    options = [UPRouterOptions routerOptions];
  }
  options.openClass = controllerClass;
  [self.routes setObject:options forKey:format];
}

```

&nbsp;&nbsp;路由跳转做的事情比较多，一共有三个比较重要的方法，会详细看，首先看路由跳转的方法

```
- (void)open:(NSString *)url
    animated:(BOOL)animated
 extraParams:(NSDictionary *)extraParams
{
  //获取路由跳转相关的参数，往下滑动，先看怎么获取的数据，看完下面的方法再回来看这个方法
  RouterParams *params = [self routerParamsForUrl:url extraParams: extraParams];
  UPRouterOptions *options = params.routerOptions;
  
  //好了，拿到数据了，开始跳转。先判断是否有回调，如果有的话，则去执行 block
  if (options.callback) {
    RouterOpenCallback callback = options.callback;
    callback([params controllerParams]);
    return;
  }
  //此处删除了判断 self.navigationController 是否存在的容错代码，无关紧要。
  
  //获取将要跳转的 VC，并且将我们传递的数据以字典的形式，传递给这个 VC
  //controllerForRouterParams 这个方法比较简单，打断点进去看看就 OK 了。
  UIViewController *controller = [self controllerForRouterParams:params];
  
  //判断当前是否有 presented 的 UIViewController，有的话要 dismiss，因为接下来要跳转或者 presentViewController
  if (self.navigationController.presentedViewController) {
    [self.navigationController dismissViewControllerAnimated:animated completion:nil];
  }
  
  //是否是以模态的方式弹出 UIViewController
  if ([options isModal]) {
    if ([controller.class isSubclassOfClass:UINavigationController.class]) {
      [self.navigationController presentViewController:controller
                                              animated:animated
                                            completion:nil];
    }
    else {
      UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
      navigationController.modalPresentationStyle = controller.modalPresentationStyle;
      navigationController.modalTransitionStyle = controller.modalTransitionStyle;
      [self.navigationController presentViewController:navigationController
                                              animated:animated
                                            completion:nil];
    }
  }
  else if (options.shouldOpenAsRootViewController) {
    //设置根视图
    [self.navigationController setViewControllers:@[controller] animated:animated];
  }
  else {
    //直接 push 一个 UIViewController
    [self.navigationController pushViewController:controller animated:animated];
  }
}
```

&nbsp;&nbsp;获取路由跳转相关的参数方法（删除了一些容错处理的代码）：

```
- (RouterParams *)routerParamsForUrl:(NSString *)url extraParams: (NSDictionary *)extraParams {
  //如果缓存中已经有了（证明之前已经跳转过这个 VC），并且传递的参数没有变化。
  //这里需要注意了，如果传递的参数你也不确定是不是没变化，最好给 extraParams 给个值，这样就不会走缓存了
  //否则可能传递的数据变了，但是走的还是之前的缓存。
  //如果 VC 之间不要传递数据，不用考虑这个问题
  if ([self.cachedRoutes objectForKey:url] && !extraParams) {
    return [self.cachedRoutes objectForKey:url];
  }
  
  NSArray *givenParts = url.pathComponents;
  NSArray *legacyParts = [url componentsSeparatedByString:@"/"];
  //这里判断传入的路由路径是否正确，如果传入这样的 "iOS/app//first" 路径，则会警告。
  //也许你的路由路径是"iOS/app"，这样写你就少传了一个实参
  if ([legacyParts count] != [givenParts count]) {
    NSLog(@"Routable Warning - your URL %@ has empty path components - this will throw an error in an upcoming release", url);
    givenParts = legacyParts;
  }
  
  //使用枚举的方式去匹配，这里不能从 self.routes 中通过 [self.routes objectForKey:@"key"] 的方式获取，
  //因为注册的时候，你后面添加的是参数（形参），在跳转的时候传递的是数据（实参）。
  //这里也就是为什么需要缓存的原因了，每次跳转都要枚举这个字典，缓存了以后时间复杂度直接降到了 O(1)。
  __block RouterParams *openParams = nil;
  [self.routes enumerateKeysAndObjectsUsingBlock:
   ^(NSString *routerUrl, UPRouterOptions *routerOptions, BOOL *stop) {
     //routerUrl 是枚举到的 key，也是当时注册路由时添加进去的 url，routerOptions 是枚举到的 value

     NSArray *routerParts = [routerUrl pathComponents];
     //判断注册的路由地址和跳转的带参数的地址是否一致，最简单的办法就是判断他们包含的元素个数是否一致，如果一致，再做更详细的判断
     if ([routerParts count] == [givenParts count]) {
       //如果个数一致，再判断是否匹配
       NSDictionary *givenParams = [self paramsForUrlComponents:givenParts routerUrlComponents:routerParts];
       if (givenParams) {
         //givenParams 存储的是路由地址中给的数据，再将 extraParams 一起传入 RouterParams，创建 RouterParams 的对象。
         openParams = [[RouterParams alloc] initWithRouterOptions:routerOptions openParams:givenParams extraParams: extraParams];
         *stop = YES;//结束遍历
       }
     }
   }];
  
  //如果没有匹配到路由
  if (!openParams) {
    //用户设置了忽略异常，直接返回 nil，否则会走 @throw
    if (_ignoresExceptions) {
      return nil;
    }
    @throw [NSException exceptionWithName:@"RouteNotFoundException"
                                   reason:[NSString stringWithFormat:ROUTE_NOT_FOUND_FORMAT, url]
                                 userInfo:nil];
  }
  //将我们辛辛苦苦封装好的路由相关的所有数据缓存起来，下次在走这个 url 的时候，直接取缓存中的数据，这就是为什么要缓存了。
  //除非你传递的参数变了，那么一定传给 extraParams，相关方法检测到 extraParams 不为空，会重新组装数据。
  [self.cachedRoutes setObject:openParams forKey:url];
  return openParams;
}
```

```
//判断注册的路由和跳转的路由是否一致
- (NSDictionary *)paramsForUrlComponents:(NSArray *)givenUrlComponents
                     routerUrlComponents:(NSArray *)routerUrlComponents {
  
  __block NSMutableDictionary *params = [NSMutableDictionary dictionary];
  [routerUrlComponents enumerateObjectsUsingBlock:
   ^(NSString *routerComponent, NSUInteger idx, BOOL *stop) {
     
     NSString *givenComponent = givenUrlComponents[idx];
     //判断是否是形参，所以在注册路由时，一定要注意，参数以:开始，否则会当成路径字符串
     if ([routerComponent hasPrefix:@":"]) {
       //去除参数的:，然后将参数名作为 key，将对应的 givenComponent 作为值存入字典中，所以在调用路由的时候，传递参数（实参）顺序要一致，否则参数就错乱了
       NSString *key = [routerComponent substringFromIndex:1];
       [params setObject:givenComponent forKey:key];
     }
     else if (![routerComponent isEqualToString:givenComponent]) {
       //在非传参数的情况下，如果路径不一致，则结束。结束后会去路由表中拿下一个路由来判断。
       params = nil;
       *stop = YES;
     }
   }];
  return params;
}
```
&nbsp;&nbsp;将路由跳转最重要的三个方法分析了一下，在重要的代码前都加上了注释。接下来总结一下整体的思路。
## 五、总结
&nbsp;&nbsp;注册的时候，比较简单，将我们的路径和 VC 传递进去，保存在字典中就可以了。跳转的时候，做的判断就比较多。首先判断缓存中是否有这个路径，如果有的话，直接跳转，在注释中也详细说明了为什么要缓存。如果没有的话，则去枚举这个路由字典，并组装数据，存入缓存中。

&nbsp;&nbsp;任何框架，都会有不完美的地方，没错，这里要说说了。如果需要给你跳转的 VC 传递数据，那么需要你的 VC 实现这个方法：`initWithRouterParams:params`，通过`params`去获取你的值。其实在这里也可以通过获取这个 VC 的所有属性，在创建这个 VC 的时候，通过 KVC 的方式把值赋给这个 VC 的属性。

&nbsp;&nbsp;另一种实现办法是扩展`UIViewController`，在这里可以这样做：

```
@interface UIViewController (Routable)

@property (nonatomic, strong) NSDictionary *params;
@end
```

```
@implementation UIViewController (Routable)

static char kAssociatedParamsObjectKey;

- (void)setParams:(NSDictionary *)params{
    objc_setAssociatedObject(self, &kAssociatedParamsObjectKey, params, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSDictionary *)params
{
    return objc_getAssociatedObject(self, &kAssociatedParamsObjectKey);
}

@end

```
&nbsp;&nbsp;这样每个`UIViewController`中就不用实现固定的方法了，在使用的时候，直接调用`self. params`就可以拿到这个字典了。

## 六、建议
&nbsp;&nbsp;在`routable-ios`中给出的注册路由的方式是，一个 VC 一个 VC 的注册。可以将需要路由跳转的 VC 配置到 plist 文件中，写一个方法，读取 plist 文件，循环注册即可，在`application:didFinishLaunchingWithOptions:`方法中，调用注册路由的方法即可。

&nbsp;&nbsp;我 fork 了一份代码，并在里面添加了注释，想通过 Xcode 看的，可以下载下来看。 [传送门](https://github.com/chenyu1520/routable-ios)








  
    
    

    
    

    
    

  
  
 
 
 
     
    





