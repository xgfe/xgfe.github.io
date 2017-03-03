title: ActivityRouter
date: 2017-03-3
categories: wangweitao
tags:
- Andorid
- Activity Router
---
## 简介 
android通过在intent中指定目标类名和参数实现界面之间的跳转。这种写法在activity数量少、跳转简单、开发人员较少时效果好。
 
 如果遇到activity数量较多、跳转复杂、多人协作开发、长期的修改变动的情况，则可以通过activityRouter来解耦合、管理跳转逻辑等。

<!--more-->
## AcitivtyRouter的主要优势

 ActivityRouter的最大优势在于项目中存在大量的activity、跳转关系较复杂，且后续需求变动添加频繁、开发人员较多或流动性大的时候，能非常方便的进行维护和开发。
### 使用原生跳转
 假设需要做一个包含商品列表、购物车、用户中心、商品详情、登录、订单列表、订单详情等界面的demo，跳转关系如下图所示。
 ![1. 使用原生跳转](https://p0.meituan.net/dpnewvc/10dbcf812dadbfc530586dab3e9bfeeb582755.png)
 如果按照原生的跳转方案，必须在每个跳转点使用一次startActivity。如果某些界面或服务需要先登录才能访问，则需要在跳转时添加相应的判断，如此就形成了图中的跳转情况。
 
 一种简便的方法是在此基础上对跳转进行一些封装，这样只要维护几个静态的跳转类即可。随着参数的不同和改变、需求的变化，这种做法也会变的更加复杂。
 
### 使用ActivityRouter管理跳转
 如果使用ActivityRouter来管理这些跳转会简便的多。所有的打开界面以及请求服务都通过ActivityRouter来完成。ActivityRouter中添加某一类操作的拦截即可完成。跳转图如下所示。
 
 ![2. 使用ActivityRouter管理跳转](https://p0.meituan.net/dpnewvc/2e3998e6e62a8147fc6d286f7aec34c0306557.png)
  
### ActivityRouter在版本迭代和维护中的优势
 假设在原先的基础上需要添加一个活动页面，改页面有很多跳往其他页面的入口。那么则如下图所示，有多少新的入口就需要添加多少个跳转的判断或者调用。
 ![3. 添加界面后的原生跳转](https://p0.meituan.net/dpnewvc/1e60eef57c66b8b50239dd7261613470662661.png)
   
 如果是采用ActivityRouter的来管理这些路有的，那么只需要调用ActivityRouter的接口即可，调用哪些服务时需要被拦截的逻辑根本不需要变动和添加。
 ![4. 添加界面后的ActivityRouter跳转](https://p1.meituan.net/dpnewvc/25ad81ab29548af2a57bef4a30970a4f325124.png)
 
## 已有的开源activityRouter
* [mzuleActivityRouter](https://github.com/mzule/ActivityRouter)
 
 比较早的activityRouter,功能也比较健全，但是api设计不够友好，使用apt编译。
 
* [ARouter](https://github.com/alibaba/ARouter)

 最近阿里出的一个activityRouter，可以同时支持apt和android annotation编译，api比较简单。
* [AndRouter](https://github.com/campusappcn/AndRouter)

 apt编译，api设计有点反人类。
* [chenenyuRouter](https://github.com/chenenyu/Router)

 android annotation编译，api比较简单，目前没有稳定版本。
 
## ARouter的使用
 本文例子使用的是ARouter。它的api简单有效，同时支持apt和android annotation的编译。
 
### gradle配置
 使用apt编译的gradle配置：

```gradle
//项目的gradle配置
buildscript {
    repositories {
        jcenter()
    }

    dependencies {
        classpath 'com.neenbedankt.gradle.plugins:android-apt:1.8'
    }
}

//模块的gradle配置
apply plugin: 'com.neenbedankt.android-apt'

apt {
    arguments {
        moduleName project.getName();
    }
}

dependencies {
	compile "com.alibaba:arouter-api:1.0.6"
	compile "com.alibaba:arouter-annotation:1.0.1"
	apt "com.alibaba:arouter-compiler:1.0.2"
｝
```
 
 使用android annotation编译：

```gradle
 //在模块gradle中配置
android {
	defaultConfig {
		...
		javaCompileOptions {
			annotationProcessorOptions {
				arguments = [ moduleName : project.getName() ]
			}
		}
	}
}

dependencies {
	compile "com.alibaba:arouter-api:1.0.6"
	compile "com.alibaba:arouter-annotation:1.0.1"
	annotationProcessor "com.alibaba:arouter-compiler:1.0.2"
｝
```
 
 **注意:**

* arouter-api >= 1.0.6 	 
* arouter-compiler >= 1.0.2
* arouter-annotation >= 1.0.1 

低于上述要求版本会导致注入功能不能正常使用，不便于跳转时参数的传递。
 
### 初始化activityRouter

```java
public class App extends Application {
    @Override
    public void onCreate() {
        super.onCreate();
        //初始化路由
        ARouter.init(this);
    }
}
```

使用之前必须要调用ARouter.init()方法，推荐在application中调用。
 
### 标注activity，注解参数

```java
@Route(path = "/mall/home")
public class Home extends AppCompatActivity {
	
	@Autowired(name = "model")
    Integer model = GOODS_LIST;

	@Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        ARouter.getInstance().inject(this);
        
        // ...
    }
    
   	public static final int GOODS_LIST = 101;
    public static final int SHOPPING_CART = 102;
    public static final int USERS = 103;
}
```

 **注意:**
 
* 标注activity时，path至少包含两级目录。如/mall/home,只有/home是出错。
* 注解@Autowired的name参数是通过url跳转时对应的参数名称。
* 使用@Autowired注解要记得ARouter.getInstance().inject(this)注解。
 
### activity间路由跳转

```java
ARouter.getInstance()
	.build("/mall/home")
	.withInt("model", Home.GOODS_LIST)
	.navigation()

//如果需要有回调的话可以在callback中添加操作
ARouter.getInstance()
	.build("/mall/home")
	.withInt("model", Home.GOODS_LIST)
	.navigation(this, new NavigationCallback(){
		@Override
		public void onFound(Postcard postcard) {
			// ...
		}

		@Override
		public void onLost(Postcard postcard) {
			// ...
		}
	});
```

 **注意：**
 
  调用跳转语句前要确保ARouter已经被初始化，否则会crash.

### 接受从浏览器或者webview的跳转

```
<!-- 申明一个activity接受浏览器或者webview的跳转 -->
<activity android:name=".SchemeActivity">
	<intent-filter>
		<action android:name="android.intent.action.VIEW"/>
		<category android:name="android.intent.category.DEFAULT"/>
		<category android:name="android.intent.category.BROWSABLE"/>
		<data android:host="KMall" android:scheme="sankuai"/>
	</intent-filter>

	<intent-filter>
		<action android:name="android.intent.action.VIEW"/>
		<category android:name="android.intent.category.DEFAULT"/>
		<category android:name="android.intent.category.BROWSABLE"/>
		<data android:host="KMall" android:scheme="http"/>
		<data android:host="KMall" android:scheme="https"/>
	</intent-filter>
</activity>
```

```java
//接受到请求后用ARouter进行应用内跳转
public class SchemeActivity extends AppCompatActivity {
	@Override
	protected void onCreate(@Nullable Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		final Uri uri = getIntent().getData();

		ARouter.getInstance().build(uri).navigation(this, new NavigationCallback() {
			@Override
			public void onFound(Postcard postcard) {
				finish();
			}

			@Override
			public void onLost(Postcard postcard) {
				finish();
			}
		});
	}
}

```

### 路由跳转拦截器

```java
@Interceptor(priority = 1, name = "login interceptor")
public class LoginInterceptor implements IInterceptor {

    private Context context = null;

    @Override
    public void process(Postcard postcard, InterceptorCallback callback) {
        String path = postcard.getPath();

        if (context.getString(routerPathOrderList).equals(path)) {
            if (Config.isLogin) {
                callback.onContinue(postcard);
            } else {
                unLoginNotify();
            }
        } else if (context.getString(routerPathOrderDetail).equals(path)) {
            if (Config.isLogin) {
                if (postcard.getExtras().getLong("detailId") == 0) {
                    showADialog("orderId不能为空或0!", "确定");
                } else {
                    callback.onContinue(postcard);
                }
            } else {
                unLoginNotify();
            }
        } else if (context.getString(routerPathGoodsDetail).equals(path)) {
            if (Config.isLogin) {
                if (postcard.getExtras().getLong("csuId") == 0) {
                    showADialog("csuId不能为空或0", "确定");
                } else {
                    callback.onContinue(postcard);
                }
            } else {
                unLoginNotify();
            }
        } else if (context.getString(routerPathHome).equals(path)
                && postcard.getExtras().getInt("model") != Home.GOODS_LIST) {
            if (Config.isLogin) {
                callback.onContinue(postcard);
            } else {
                unLoginNotify();
            }
        } else {
            callback.onContinue(postcard);
        }
    }

    @Override
    public void init(Context context) {
        this.context = context;
        ARouter.getInstance().inject(this);
    }

    private void unLoginNotify() {
        showADialog("你需要先登录!", "确定");
    }

    private void showADialog(String message, String action) {
        ARouter.getInstance().build("/mall/ADialog").withString("message", message).withString("action", action)
                .navigation();
    }
}
```

 **注意：**
 
* 注解@Interceptor的priority标志优先级，拦截器按照优先级顺序依次执行，name属性只是在生成java doc的过程中有用。
* 在拦截操作process中，如果继续跳转需要调用callback.onContinue()，如果遇到错误可以使用callback.onInterrupt()中断所有的路由。
* 拦截器中一定要保证不需要被处理的路径能够通过callback.onContinue()继续执行下去。
* 拦截器中不应有耗时操作，积压大量的请求会crash.

### 注入服务

 服务就是一个公用的类，没有界面，可以通过ARouter来调用。可以用来做一些依赖注入，省略掉不少代码。

```java
//申明服务的接口
public interface CustomToast extends IProvider {
    void showDefaultStyleToast(String content);
}

//实现服务
@Route(path = "/mall/utils/toast/normal", name = "自定义样式Toast")
public class NormalToast implements CustomToast {
    private Context context = null;

    @Override
    public void showDefaultStyleToast(String content) {
        if (context != null) {
            Toast.makeText(context, content, Toast.LENGTH_LONG).show();
        }
    }

    @Override
    public void init(Context context) {
        this.context = context;
    }
}

//使用服务
public class MainActivity extends AppCompatActivity {
    @Autowired(name = "/mall/utils/toast/normal")
    CustomToast customToast;
    
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
				//注入
        ARouter.getInstance().inject(this);
        
        // ...
		｝
｝
```

 **注意：**
 
* 接口一定要继承IProvider，否则编译不通过后，错误信息提示不够准确，难以定位。
* 如果只有一个服务的实现，那么利用@Autowired(name = "/mall/utils/toast/normal")时可以不添加name属性。如果超过一个服务的实现，就需要通过name属性来区分。
* 除了利用@Autowired来注解外，也可以通过(CustomToast)ARouter.getInstance().build("/mall/utils/toast/normal").navigation()来获取引用执行。

### demo地址

 本文的demo地址：[demo](https://github.com/thedevilking/demoCode/tree/develop/Demo_ActivityRouter)
 
 