title: Jetpack-Navigation使用指南与原理剖析
date: 2020-05-27 10:00:00
categories: jiangweidong02
tags:
- jetpack
- navigation
- android
---

## 简介
Navigation是Jetpack系列组件中针对界面导航的一个非常好用的组件，该组件推崇的是使用单Activity+多Fragment的方式来架构你的app。
类似于AndroidManifest.xml文件中对Activity的配置，该组件需配置res/navigation/navigation.xml文件以对所有的Fragment进行集中管控。
<!--more-->
## 特性
>·提供一套标准的单Activity+多Fragment的解决方案。
>·可以在Android Studio中直观的查看和编辑导航图。
>·可在目标之间导航和传递数据时提供类型安全的 Gradle 插件。（SafeArgs）
>·使用DeepLink处理Schema形式的跳转。

## 如何使用
我们先来看一下导航图的全貌，相信就凭这一张图我们就能感受到它的重要性。
随着频繁的版本迭代，RD同学在找一个页面都有哪些入口的时候只能是去翻代码查引用关系，甚至特殊情况下PM同学有时还会找我们问页面路径。
现在，Navigation提供的导航图可以轻松帮你找到入口，快速看清整体业务的来龙去脉。
![](/uploads/jiangweidong02/navigation/n1.png)

### 依赖添加
     build.gradle文件中加入:

``` groovy
    def nav_version = "2.3.0-alpha01"
    implementation "androidx.navigation:navigation-fragment:$nav_version"
    implementation "androidx.navigation:navigation-ui:$nav_version"
```
**注意：如果要在 Android Studio 中使用 Navigation 组件，则必须使用 Android Studio 3.3 或更高版本。且必须将应用升级为androidX**
### 概念理解
  | 名词 | 含义 |
  | ---- | ---- |
  | Destination | 想要前往的目的地,可以是Fragment、Activity、或者Graph |
  | Graph | 一个视图，视图中可包含多个Fragment、Activity、Graph,是模块化的利器 |
### 宿主Activity搭建
要想使用Navigation组件，我们需要提供一个宿主Activity作为整体导航框架的依托，这个宿主activity中会提供一块区域用来容纳所有的Fragment。
我们首先看一下宿主Activity的布局文件:
``` xml
    <?xml version="1.0" encoding="utf-8"?>
    <FrameLayout xmlns:android="http://schemas.android.com/apk/res/android"
        xmlns:app="http://schemas.android.com/apk/res-auto"
        android:layout_width="match_parent"
        android:layout_height="match_parent">
        <fragment
            android:id="@+id/fragment_host"
            //这里我们需要指定一个NavHostFragment或者是继承自它的一个Fragment就可以。
            android:name="androidx.navigation.fragment.NavHostFragment"
            android:layout_width="match_parent"
            android:layout_height="match_parent"
            //我们知道,一个activity中可以有多个同级的fragment，所以这里需要指定一个默认的Fragment用来响应系统事件，如截获back键的操作。
            app:defaultNavHost="true"
            app:navGraph="@navigation/navigation" />
    </FrameLayout>
```
再来看一下app:navGraph所引用的文件navigation.xml，后续所有的路由配置都是在这个xml文件中进行的，这个文件是整个Navigation框架的核心。
<img width = "600px" src="/uploads/jiangweidong02/navigation/n13.png" alt="">
### 携参跳转
下面的例子中我们尝试从LoginFragment跳转到HomeFragment,并携带一个String类型的参数。
首先我们来看一下navigation.xml文件中的基本配置:
``` xml
    <navigation xmlns:android="http://schemas.android.com/apk/res/android"
        xmlns:app="http://schemas.android.com/apk/res-auto"
        xmlns:tools="http://schemas.android.com/tools"
        android:id="@+id/nav"
        app:startDestination="@+id/fragment_splash">
        <fragment
            android:id="@+id/fragment_login"
            android:name="com.example.android.navigation.LoginFragment">
            <action  //当前Fragment可以跳到哪个Fragment去
                android:id="@+id/action_home"
                app:destination="@id/fragment_home"
             />
        </fragment>
        <fragment
            android:id="@+id/fragment_home"
            android:name="com.example.android.navigation.HomeFragment"
            tools:layout="@layout/home_fragment">
            <argument //别的Fragment想要跳过来，需要传递的参数
                android:name="userName"
                android:defaultValue="String"
                />
        </fragment>
    </navigation>
```
***需要理解的是，同一个<fragment>标签下的<argument>和<action>标签是没有任何联系的。***
Navigation帮开发者定制了一个规范：
1.规定每个Fragment所接收的参数类型和最大数量是明确的。
2.规定每个Fragment可跳转到哪些别的Fragment是明确的。
仔细想想，确实只有在规范了这两点的基础上，才可以达到生成导航图的目的。


现在,我们想从LoginFragment跳转到HomeFragment，让我们发起一个跳转动作，并传入参数:
``` kotlin
    btnLogin?.setOnClickListener {
        var bundle = Bundle()
        bundle.putString("userName","小驴")
        findNavController().navigate(R.id.fragment_login, bundle)
    }
```

也可以发送对象，注意对象需要实现序列化
``` xml
    <fragment
        android:id="@+id/fragment_home"
        android:name="com.example.android.navigation.HomeFragment">
        <argument
            android:name="user"
            app:argType="com.example.android.navigation.User" />
    </fragment>
```
``` kotlin
    var bundle = Bundle()
    bundle.putParcelable("user",User())
    findNavController().navigate(R.id.fragment_home, bundle)
```
除上述的跳转方式外，我们还可以使用Navigation组件提供的SafeArgs方式进行跳转。
使用SafeArgs需要添加额外的依赖。
root级build.gradle中添加：
``` groovy
    buildscript {
        repositories {
            google()
        }
        dependencies {
            def nav_version = "2.3.0-alpha01"
            classpath "androidx.navigation:navigation-safe-args-gradle-plugin:$nav_version"
        }
    }
```
app级build.gradle中添加：
``` groovy
    apply plugin: "androidx.navigation.safeargs"
```
如果是纯kotlin开发环境，可替换为：
``` groovy
    apply plugin: "androidx.navigation.safeargs.kotlin"
```

跳转:
``` kotlin
    btnHome?.setOnClickListener {
        SplashFragmentDirections.actionHome("小驴")
        findNavController().navigate(R.id.fragment_home)
    }
```
接收:
``` kotlin
    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        var bundle = HomeFragmentArgs.fromBundle(arguments!!)
        LogUtil.log("userName=$bundle.userName")
    }
```
SafeArgs的作用实际上是将xml文件中的<action>和<argments>标签进行解析,再通过dsl方式在编译期动态生成与跳转和接收参数相关的封装类。

SafeArgs插件的工作流程：SafeArgsPlugin.kt->ArgumentsGenerationTask.kt->NavSafeArgsGenerator.kt

![](/uploads/jiangweidong02/navigation/n2.png)

编译后产生的文件示例：

<img width = "400px" src="/uploads/jiangweidong02/navigation/n3.png" alt="">

<!--more-->
使用SafeArgs的好处有：

>·规范了页面跳转的方式
>·对类型安全做了检测
>·代码自动生成，提高开发效率。

想了解代码生成过程的同学可以查看[SafeArgs插件源码](https://android.googlesource.com/platform/frameworks/support/+/refs/heads/androidx-master-dev/navigation/navigation-safe-args-gradle-plugin?source=post_page---------------------------%2F&autodive=0%2F/)。

## 跳转方式
类似于Activity中的lunchMode，Navigation组件也为开发者提供了友好的跳转的方式。
### 默认跳转方式
``` xml
    <fragment
        android:id="@+id/fragment_login"
        android:name="com.example.android.navigation.LoginFragment">
        <action
            android:id="@+id/action_home"
            app:destination="@id/fragment_home" />
    </fragment>
```
默认跳转方式也是最常见的跳转方式是，与activity的默认跳转方式规则一致,保持正常的入栈顺序和出栈顺序。

### launchSingleTop属性

``` xml
    <fragment
        android:id="@+id/fragment_login"
        android:name="com.example.android.navigation.LoginFragment">
        <action
            android:id="@+id/action_home"
            app:launchSingleTop="true"
            app:destination="@id/fragment_home" />
    </fragment>
```
launchSingleTop与activity的singleTop理解是一致的，都是栈顶复用的含义。
这里需要注意的是，在AndroidManifest.xml中我们配置singleTop属性是在<activity>标签中，意味着默认情况下，从任何地方跳转到该Activity都是栈顶复用的模式。
而在navigation.xml中，launchSingleTop配置在了<action>标签下，这相当于将以下代码做成了配置:
``` kotlin
    var intent= Intent();
    intent.setFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP);
```
### popUpTo&popUpToInclusive
popUpTo："fragmentId"是对栈的操作管理，意思是不断的弹出栈顶的Fragment直到遇到FragemntId对应的Fragment为止。这个属性很有用，

例如有个很常见场景，登录页登录成功后进入首页、首页进入设置页、设置页中可以退出登录又回到登录页并清空堆栈中的设置页和首页。那我们就可以通过以下配置轻松进行跳转和堆栈管理：
``` xml
    <fragment
        android:id="@+id/fragment_settings"
        android:name="com.example.android.navigation.SettingsFragment"
        tools:layout="@layout/settings_fragment">
        <action
            android:id="@+id/action_login"
            app:popUpTo="@id/fragment_login"
            app:popUpToInclusive="true"
            app:destination="@id/fragment_login"
            />
    </fragment>
```
<img width = "1200px" src="/uploads/jiangweidong02/navigation/n4.png" alt="">
再看下popUpToInclusive=false的情况：

<img width = "1200px" src="/uploads/jiangweidong02/navigation/n5.png" alt="">

所以popUpToInclusive=true的含义就是将popUpTo标签所指定的Fragment也一并销毁。个人感觉多数情况下我们都会将popUpToInclusive设置为true。
<!--more-->
>** action标签处理的不一定只有跳转，也可以单纯的对栈进行操作。**
>**这也就意味着popUpTo不需要和destination同时使用，且Navigation内部的处理机制会先将popUpTo、popUpToInclusive两个属性执行完毕后再对destination属性进行处理。**
## XML标签概览
![](/uploads/jiangweidong02/navigation/n6.png)

argType的可选类型：

  | 类型 | app:argType语法 | 是否支持默认值 | 是否支持null值 |
  | ---- | ---- | ---- | ---- |
  | 布尔值 | app:argType="boolean"|是 -“true”或“false”|否|
  | 浮点数 | app:argType="float"|是|否|
  | 数组|integer[]、float[]、com.example.User[]|否| 是|
  | 长整数 | app:argType="long" |是 - 默认值必须始终以“L”后缀结尾（例如“123L”）|否|
  | 整数 | app:argType="integer"|是|否|
  | 资源引用| app:argType="reference"|是 - 默认值必须为“@resourceType/resourceName”格式（例如，“@style/myCustomStyle”）或“0”|否|
  | 字符串 | app:argType="string"|是|是|
  | 自定义 Parcelable | app:argType="com.example.User"|支持默认值“@null”。不支持其他默认值。|是|
  | 自定义 Serializable | app:argType="com.example.User"|支持默认值“@null”。不支持其他默认值。|是|

## Navigation实现原理

Navigation是如何进行的堆栈管理、如何保存的后退栈都是我们需要关注的问题。
我们先来看一下重要类和接口的关系图：

![](/uploads/jiangweidong02/navigation/n7.png)

**NavHostFragment.java**

这是宿主类，所有的业务Fragment实际上都是在它的布局中进行的replace操作，本质上就是一个空的FragmentLayout等待被填充。

``` java
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container,
                             @Nullable Bundle savedInstanceState) {
        FrameLayout frameLayout = new FrameLayout(inflater.getContext());
        frameLayout.setId(getId());
        return frameLayout;
    }

```
**NavController.java**

这里存放了Fragment的堆栈，所以想要查看堆栈信息的同学可以从这里切入。同时可以发现Navigation组件已经将LifeCycle考虑了。

``` java
    private final Deque<NavBackStackEntry> mBackStack = new ArrayDeque<>();
    private LifecycleOwner mLifecycleOwner;
```
Navcontroller更是负责导航操作的关键，所有的导航操作都是由这里发起，具体由其内部的Navigator 进行处理。
``` java
    private void navigate(@NonNull NavDestination node, @Nullable Bundle args,
                @Nullable NavOptions navOptions, @Nullable Navigator.Extras navigatorExtras) {
      .......
            Navigator<NavDestination> navigator = mNavigatorProvider.getNavigator(
                    node.getNavigatorName());
            NavDestination newDest = navigator.navigate(node, finalArgs,
                    navOptions, navigatorExtras);
      ........
    }
```
Navigator是个抽象类，它的继承类有很多：

<img width = "800px" src="/uploads/jiangweidong02/navigation/n8.png" alt="">
通过上图我们也可以发现“导航”不仅仅针对Fragment，也有针对Activity、DialogFragment、Graph的考虑。
再看一下FragmentNavigator是如何处理navigate()方法的：
``` java
    public NavDestination navigate(@NonNull Destination destination, @Nullable Bundle args,
            @Nullable NavOptions navOptions, @Nullable Navigator.Extras navigatorExtras) {
        ........
        final FragmentTransaction ft = mFragmentManager.beginTransaction();
        ........
        ft.replace(mContainerId, frag);
        .......
        ft.addToBackStack(generateBackStackName(mBackStack.size(), destId));
        .......
        ft.commit();
        .......
        }
```
这里的mContainerId实际上就是NavHostFragment中的空FrameLayout。所以通过阅读源码我们发现Navigation是使用的replace的方式进行的堆栈处理。
replace方式进行的堆栈管理一定要使用addToBackStack操作，这个操作不仅会将上一个Fragment保存在后退栈中，也会影响Fragment的生命周期，使得上一个Fragment只触发onDestoryView()，不会触发onDestory()。


如果有一个跳转动作跳到了Graph，那具体会是跳到哪里？可以看下NavGraphNavigator是如何处理navigate()方法的：
``` java
    public class NavGraphNavigator extends Navigator<NavGraph> {
        ...
        public NavDestination navigate(@NonNull NavGraph destination, @Nullable Bundle args,
                @Nullable NavOptions navOptions, @Nullable Extras navigatorExtras) {
            int startId = destination.getStartDestination();
            ...
            NavDestination startDestination = destination.findNode(startId, false);
            if (startDestination == null) {
                final String dest = destination.getStartDestDisplayName();
                throw new IllegalArgumentException("navigation destination " + dest
                        + " is not a direct child of this NavGraph");
            }
            Navigator<NavDestination> navigator = mNavigatorProvider.getNavigator(
                    startDestination.getNavigatorName());
            return navigator.navigate(startDestination, startDestination.addInDefaultArgs(args),
                    navOptions, navigatorExtras);
        }
       ...
    }
```
通过阅读源码，我们发现如果是一个Graph的话，则必须指定一个startDestination用于具体的跳转。那还记得我们在哪里看到过<startDestination>标签么？请看下图：
<img width = "600px" src="/uploads/jiangweidong02/navigation/n13.png" alt="">
图中的startDestination写在了navigation标签下，所以其实每一个navigation标签就是一个Graph，我们完全可以依靠Graph将业务模块化。（一个navigation.xml文件中可以有多个navigation标签）

## AndroidStudio导航图绘制原理

首先，为什么想讲这个原理？是因为多数情况下我们没有办法在短时间内将现有的项目架构迁移成Navigation形式，但我们确实对他的导航图感到欣喜，出于这一点，可以简单讲一下AS绘制导航图的原理，以便为创建我们自己的导航图提供一些思路。

我们先将[AndroidStudio源码](https://github.com/JetBrains/android)下载下来。navigation编辑器相关的代码都存在了android/naveditor/src/com/android/tools/idea/naveditor路径下。

转化一下角色，**想象自己是一名AndroidStudio工具开发者**。然后继续分析naveditor目录结构：
<img width = "300px" src="/uploads/jiangweidong02/navigation/n9.png" alt="">
**../actions目录**
    这里的action是用来处理与navigation编辑器中每个可点击动作的.每一个action都继承自anAction，anAction是Intellij系列ide中编写插件重要的类。
    例如ScrollToDestinationAction.kt：
``` kotlin
class ScrollToDestinationAction(private val surface: NavDesignSurface, private val component: NlComponent): AnAction("Scroll into view") {
  override fun actionPerformed(e: AnActionEvent) {
    surface.scrollToCenter(listOf(component))
  }
}
```
<img width = "300px" src="/uploads/jiangweidong02/navigation/n10.png" alt="">
 **../property目录**
 所有的属性也需要显示在界面上。例如NavActionsProperty
<img width = "300px" src="/uploads/jiangweidong02/navigation/n11.png" alt="">
 **.../scene/decorator**
这里有很多decorator，每个decorator中都分配了一个scene，以FragmentDecorator为例，编辑器中显示的每个Fragment其实就是一个FragmentDecorator。每个decorator中都会生成各自特有的绘制指令，然后之后交给Draw类进行绘制工作。
<img width = "300px" src="/uploads/jiangweidong02/navigation/n12.png" alt="">
 **.../scene/draw** 
执行decorator产生的绘制指令，以完成真正的显示工作。
 **.../surface**
 这里是navigation编辑器的主视图，所有编辑器上能看到的内容都是以它作为容器。

## 总结
Navigation并不只是一个单Activity+多Fragment的解决方案，它更是一个**闭环的工具链条**。可惜出现的比较晚，没有多少人会真正的把老项目用它进行重构，所以更多的我们还是学习它的思想和核心要领。

在保证我们项目中**跳转和传参的形式稳定**的情况下：

1.我们是否可以通过脚本扫描跳转和传参的代码，输出一个xxx_navigation.xml文件？

2.或者是通过注解的方式在编译期生成xxx_navigation.xml文件？

3.有了xxx_navigation.xml文件后，是否可以模仿SafeArg编写个gradle插件自动生成代码？

4.是否还可以利用xxx_navigation.xml文件，再编写个AS插件生成导航图？

5.再或者我们可不可以直接将生成的xxx_navigation.xml的格式与Navigation组件中xml的格式保持一致？这样就能直接利用他的导航图了。


