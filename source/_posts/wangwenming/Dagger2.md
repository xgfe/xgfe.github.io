title: Dagger2 使用及原理分析
date: 2019-02-23
categories: wangwenming
tags:
- dagger2
---

## 简介
Dagger2 是一个编译时静态依赖注入框架，是由 Google 在Square开源的 Dagger 基础上进行修改而来。
<!--more-->
那么问题来了，什么是依赖注入？
> 控制反转（Inversion of Control，缩写为IoC），是面向对象编程中的一种设计原则，可以用来减低计算机代码之间的耦合度。其中最常见的方式叫做依赖注入（Dependency Injection，简称DI），还有一种方式叫“依赖查找”（Dependency Lookup）。通过控制反转，对象在被创建的时候，由一个调控系统内所有对象的外界实体，将其所依赖的对象的引用传递给它。也可以说，依赖被注入到对象中。
> ---摘自百度百科

## 如何使用
在日常编码中经常会有类之间的依赖，为了方便理解，我们举个例子。手机类Phone包含了摄像头Camera组件。
```
public class Phone {
    private Camera mCamera;
    
    public Phone() {
        mCamera = new BackCamera();
    }
}
```

我们可以看到 Phone 和 Carmera 是耦合的，Phone 需要知道 Camera 的实现类 BackCamera 的存在，一旦 Camera 的实现变为其他，比如 FrontCamera 时，我们还需要修改 Phone 的构造方法。类似问题就可以使用依赖注入来解决。依赖注入的常用方法有构造方法注入和 setter 方法注入，两种方式都可以对 Phone 和 Camera 解耦，使得 Phone 无需关注 Camera 的实现，即使 Camera 的类型变了也无需修改 Phone 的代码。
```
public class Phone {
    private Camera mCamera;
    
    public Phone(Camera camera) {
        mCamera = camera;
    }

    public void setCamera(Camera camera) {
        this.mCamera = camera;
    }
}
```

### @Component 和 @Inject

那使用 Dagger2 该如何注入呢？

```
@Component
public interface PhoneComponent {
    void inject(Phone phone);
}

public class BackCamera implements Camera {

    @Inject
    public BackCamera() {
    }

    @Override
    public String getCameraType() {
        return "后置摄像头";
    }
}

public class Phone {
    @Inject
    public BackCamera mCamera;

    public Phone() {
        DaggerPhoneComponent.create().inject(this);
    }
}
```

我们可以看到首先需要声明一个 @Component，然后需要在 BackCamera 的构造方法前增加注解 @Inject，接着在 Phone 的 mCamera 前增加 @Inject 以及构造方法中调用 **DaggerPhoneComponent.create().inject(this)**，几者间关系如下：

![](/uploads/wangwenming/dagger-1.png)

### @Module 和 @Provides
那么问题来了，@Inject 只能标记构造方法，如果需要注入的是来自三方库的对象怎么办呢？这就需要用到 @Module，下面我们用 @Module 改造下上面的例子。
```
@Module
public class CameraModule {
    @Provides
    public BackCamera provideBackCamera() {
        return new BackCamera();
    }
}

@Component(modules = {CameraModule.class})
public interface PhoneComponent {
    void inject(Phone phone);
}
```
@Module 和 @Provides 配合可以实现对三方库对象的注入。

### @Named 和 @Qualifier
@Qualifier 是限定符用于自定义注解，@Named 是 @Qualifier 的一种实现。在一些情况下我们需要两个有相同父类或实现同一接口的依赖，当需求方使用的又是他们父类时，Component 就不知道到底提供哪一个了。还是拿手机举例，我们在原有基础上增加一个前置摄像头。
```
@Module
public class CameraModule {
    @Provides
    @Named("back")
    public Camera provideBackCamera() {
        return new BackCamera();
    }

    @Provides
    @Named("front")
    public Camera provideFrontCamera() {
        return new FrontCamera();
    }
}

public class Phone {
    @Inject
    @Named("front")
    public Camera mFrontCamera;

    @Inject
    @Named("back")
    public Camera mBackCamera;

    public Phone() {
        DaggerPhoneComponent.create().inject(this);
    }
}
```

为 Module 中的 provide 方法加上 @Named 注解，然后在需要使用的地方加上对应的 @Named 注解。上面例子同样可以使用 @Qualifier 来实现，使用 @Qualifier 定义两个运行时注解 @Front 和 @Back，使用两个注解替换上面的 @Named 注解即可。

### @Singleton 和 @Scope
@Scope 同样用于自定义注解，我能可以通过 @Scope 自定义的注解来限定注解作用域，实现局部的单例；@Singleton 是 @Scope 的一个实现。在一些场景下我们需要使用单例，@Singleton 和 @Scope 可以帮助我们实现局部单例。为什么说是局部单例呢，因为 @Singleton 或 @Scope 能保证在对应的 Component 下是单例的，如果需要全局的单例，我们就需要其他手段保证 Component 是单例。下面看个例子
```
@Component
@Singleton
public interface AppComponent {
    void inject(App app);
}

@Singleton
public class Logger {
    @Inject
    public Logger(){

    }

    public void printMessage() {
        Log.d("Logger", this);
    }
}

public class App {
    @Inject
    Logger logger;

    @Inject
    Logger logger2;

    public App(){
        DaggerAppComponent.create().inject(this);
    }

    public void printMessage() {
        Log.d("App", "app:" + this);
        logger.printMessage();
        logger2.printMessage();
    }
}
```
使用 @Singleton 标注 Component 和需要注入的类即可。在上面的例子中，如果调用 App 的 printMessage 方法可以看到 logger 和 logger2 为同一对象，对于不同 App 对象的 logger 则是不同对象。当然我们也可以使用 @Scope 自定义一个注解来实现局部注解，来替换 @Singleton。

## 原理分析

前面简单介绍了 Dagger2 使用，接下来我们分析一下实现原理。Dagger2 在编译时根据注解生成一些辅助类，接下来我们具体分析下生成的辅助类。辅助类可以通过 DaggerXXXComponent 来快速定位。上面两个例子对应生成辅助类如下：

![](/uploads/wangwenming/dagger-2.png)

简单来看辅助类和注解对应关系很明显，拿手机的例子来说对应关系如下：

| 辅助类 |  注解 |
|:--|:---|
| BackCamera_Factory |  BackCamera 构造方法的 @Inject |
| CameraModule_ProvideBackCameraFactory | CameraModule 的 @Provides |
| CameraModule_ProvideFrontCameraFactory | CameraModule 的 @Provides |
| DaggerPhoneComponent | PhoneComponent 的 @Component |
| Phone_MembersInjector | Phone 对应的 @Inject |

原始类以及辅助类类图如下：

![](/uploads/wangwenming/dagger-3.png)

接下来我们分析下具体的注入过程，首先 Phone 中会调用 **DaggerPhoneComponent.create().inject(this)**，我们来看下 DaggerPhoneComponent 的源码
```
@Generated(
  value = "dagger.internal.codegen.ComponentProcessor",
  comments = "https://google.github.io/dagger"
)
public final class DaggerPhoneComponent implements PhoneComponent {
  private CameraModule cameraModule;

  private DaggerPhoneComponent(Builder builder) {
    initialize(builder);
  }

  public static Builder builder() {
    return new Builder();
  }

  public static PhoneComponent create() {
    return new Builder().build();
  }

  @SuppressWarnings("unchecked")
  private void initialize(final Builder builder) {
    this.cameraModule = builder.cameraModule;
  }

  @Override
  public void inject(Phone phone) {
    injectPhone(phone);
  }

  private Phone injectPhone(Phone instance) {
    Phone_MembersInjector.injectMFrontCamera(
        instance, CameraModule_ProvideFrontCameraFactory.proxyProvideFrontCamera(cameraModule));
    Phone_MembersInjector.injectMBackCamera(
        instance, CameraModule_ProvideBackCameraFactory.proxyProvideBackCamera(cameraModule));
    return instance;
  }

  public static final class Builder {
    private CameraModule cameraModule;

    private Builder() {}

    public PhoneComponent build() {
      if (cameraModule == null) {
        this.cameraModule = new CameraModule();
      }
      return new DaggerPhoneComponent(this);
    }

    public Builder cameraModule(CameraModule cameraModule) {
      this.cameraModule = Preconditions.checkNotNull(cameraModule);
      return this;
    }
  }
}
```

DaggerPhoneComponent 在创建时首先会创建一个 CameraModule，在进行注入时首先会调用工厂的代理方法最终调用 Module 中对应 @Provides 的方法创建对象，然后通过 Phone_MembersInjector 将上面创建的对象进行注入，工厂与 Injector 核心代码如下：

```
// 工厂类核心
 public static Camera proxyProvideFrontCamera(CameraModule instance) {
    return Preconditions.checkNotNull(
        instance.provideFrontCamera(), "Cannot return null from a non-@Nullable @Provides method");
  }

// Injector 核心
 public static void injectMBackCamera(Phone instance, Camera mBackCamera) {
    instance.mBackCamera = mBackCamera;
  }
```

## 总结

本文主要介绍了 Dagger2 的基本使用并从辅助代码的源码层面进行了原理分析。关于从注解到辅助代码的生成并没有介绍，感兴趣的同学可以自行查阅注解处理器相关知识。