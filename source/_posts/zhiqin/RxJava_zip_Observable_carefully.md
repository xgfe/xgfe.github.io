title: RxJava 谨慎串联Observable
date: 2017.02.24 17:21:34
updated: 2017.02.24 17:21:34
categories:
- zhiqin
tags:
- Android
- RxJava
---


RxJava提供了flatMap和switchMap两个操作符用于让我们进行Observable的串联. 但如果不谨慎使用的话, 经常会造成很多意料之外的问题

<!--more-->

例子
------

比如我们可以使用RxView.clicks()创建一个会发送点击事件的Observable，同时我们还有一个用于请求网络数据的Observable：

```java
Observable<Void> loginPress(){
  return RxView.clicks(findViewById(R.id.login));
}

Observable<LoginInfo> login() {
  return httpApi.login();
}
```

需求希望在login按钮点下之后，调用login()方法进行登陆。此时有两种写法：

1. 直接串联：

```
loginPress().flatMap(aVoid -> login()).subscribe(loginInfo -> {
  // 处理登录逻辑
}, throwable -> {
  // 处理错误情况
});
```

2. 分别调用:

```
loginPress().subscribe(aVoid -> {
  login().subscribe(loginInfo -> {
    // 处理登录逻辑
  }, throwable -> {
    // 处理错误情况
  });
});
```

从代码上看，第一种方式显然是Rx更为推荐的——不打破链式调用 的方式。但在有些时候，这种方法会出现比较严重的问题：原因是，subscriber在接受到错误以后，就无法接受到之后的事件了。

举上面的第一个使用例子来说有两个问题：

1. 如果处理登录逻辑里发生了一些意料不到的错误（比如服务器有时候成功返回了数据，但有些数据为空导致了处理逻辑出现空指针），发生错误时，错误会回调到`throwable->{}`中。之后再进行按钮点击，数据返回subscriber都接收不到了。

2. 如果login()方法里有错误，比如网络访问异常。那么当第一次点击按钮时，subscriber会收到网络异常的错误。但如果用户再点击登录按钮，无论是否成功，我们都没有办法再次接受到登录信息，页面也无法发生跳转。

前者在使用`flatMap`或者`switchMap`会发生，而后者在任何情况下都有可能出现。

解决方案
-----------

使用方案2，分别调用不会产生相应的问题。但打破了RxJava的链式调用。

对于使用方案1，最简单的解决方案是：在遇到错误重新绑定。但这种方式的成本比较高。每个处理订阅的地方都需要进行特殊处理。

首先是第一个问题：

> 1. 如果处理登录逻辑里发生了一些意料不到的错误（比如服务器有时候成功返回了数据，但有些数据为空导致了处理逻辑出现空指针），发生错误时，错误会回调到`throwable->{}`中，但之后的任何数据返回subscriber都接不到了。

这种情况出现的其实比较少。对于这种不可意料的错误，我们可以使用一个大大的try-catch把subscriber包起来，比如实现一个类似这样的类：

```
public class ErrorHandlerSubscriber<T> extends Subscriber<T> {
  private Action1<T> onNext;
  private Action1<Throwable> onError;

  public ErrorHandlerSubscriber(Action1<T> onNext, Action1<Throwable> onError) {
    this.onNext = onNext;
    this.onError = onError;
  }

  @Override
  public void onCompleted() {}

  @Override
  public void onError(Throwable e) {
    if (onError != null) {
        onError.call(e);    
    }
  }

  @Override
  public void onNext(T t) {
    try {
        if (onNext != null) {
            onNext.call(t);
        }
    } catch (Exception e) {
        if (onError != null) {
            onError.call(e);
        } else {
          // log it
        }
    }}
}
```

在使用时：
```
login().subscribe(new ErrorHandlerSubscriber(loginInfo -> {
    // 处理登录逻辑
  } , throwable -> {
    // 处理失败
  }));
```

这样一来，错误实际上不会被转发到Subscriber内，而只是会传到我们自定义的`throwable -> {}`里。也就不会影响实际Subscriber后续事件的接受。

同时，建议在`// log it`的地方将错误日志打出来，方便调试。

-------

对于第二个问题：

> 2.如果login()方法里有错误，比如网络访问异常。那么当第一次点击按钮时，subscriber会收到网络异常的错误。但如果用户再点击登录按钮，无论是否成功，我们都没有办法再次接受到登录信息，页面也无法发生跳转。

这种情况出现出现会十分频繁，尤其在进行网络请求时。解决方案有N种

1.如果你不关心错误，可以使用`switchMapDelayError`

这个关键字可以起到忽略错误的作用，但大部分情况下，我们希望在遇到错误对用户进行提示。所以如果你不关心错误是否发生的情况下，使用这个关键字进行串联是最简单的。

2.使用`materialize()`将next和error都包装到notification中：

http://stackoverflow.com/questions/32084824/rxjava-rxbinding-how-to-handle-errors-on-rxview

```
loginPress().flatMap(aVoid -> login().materialize()).subscrber(notification -> {
  if(notification.hasValue()){
    // 处理登录逻辑
  } else if(notification.isOnError()) {
    // 处理失败逻辑 
  }
});
```

3.使用doOnError处理错误，同时使用onErrorResumeNext忽略错误:

```
loginPress().flatMap(aVoid -> login().doOnError(throwable -> {
    // 处理失败逻辑 
  }).onErrorResumeNext(throwable -> Observable.empty())
  ).subscriber(loginInfo -> {
    // 处理登录逻辑
  } , throwable -> {
    // 处理失败
  });
```
这样一来，flatMap里的Observable实际上就不会发生错误，也就不会造成相应的问题了。
