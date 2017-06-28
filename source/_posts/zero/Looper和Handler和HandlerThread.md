title: Looper和Handler和HandlerThread
date: 2017-06-26
categories:
- zero
tags:
- Android

---

本文主要分析了Looper，Handler和HandlerThread的主要源码部分。

<!-- more -->

Looper主要成员变量是：   
MessageQueue mQueue;   
Thread mThread;   
一个线程拥有一个Looper，一个Looper封装了MessageQueue和Thread，loop方法使消失队列循环起来了。loop中由Message关联的Handler执行对Message的处理,因为loop是执行在线程中的所以对消息的处理是在同一线程中执行的。  

```java
private Looper(boolean quitAllowed) {
        mQueue = new MessageQueue(quitAllowed);
        mThread = Thread.currentThread();
    }
public static void loop() {
        final Looper me = myLooper();
        final MessageQueue queue = me.mQueue;
			for (;;) {
            Message msg = queue.next(); // might block
            if (msg == null) {
                // No message indicates that the message queue is quitting.
                return;
            }
            msg.target.dispatchMessage(msg);
            msg.recycleUnchecked();
        }
```   

## Handler 
  
Handler执行对消息和Runnable的处理，如果post Runnable到队列中，是把Runnable赋值给Message的callback，然后直接执行它的run方法（参见handleCallback），如果sendMessage 到队列中，是先判断Handler的mCallback对消息的处理返回true时就不执行handleMessage，返回false时就执行handleMessage。Callback起到了对消息处理进行拦截的功能。   
final MessageQueue mQueue;   
final Looper mLooper;   
public Handler(Looper looper)   

```java  
public Handler(Looper looper, Callback callback, boolean async) {
        mLooper = looper;
        mQueue = looper.mQueue;
        mCallback = callback;
        
public void dispatchMessage(Message msg) {
        if (msg.callback != null) {
            handleCallback(msg);
        } else {
            if (mCallback != null) {
                if (mCallback.handleMessage(msg)) {
                    return;
                }
            }
            handleMessage(msg);
        }
    }
public final boolean post(Runnable r)
    {
       return  sendMessageDelayed(getPostMessage(r), 0);
    }
private static Message getPostMessage(Runnable r) {
        Message m = Message.obtain();
        m.callback = r;
        return m;
    }
private static void handleCallback(Message message) {
        message.callback.run();
    }
```   

## HandlerThread   

HandlerThread是一个封装了Looper的Thread。在消息循环前会先调用onLooperPrepared()。   

```java
public void run() {
        mTid = Process.myTid();
        Looper.prepare();
        synchronized (this) {
            mLooper = Looper.myLooper();
            notifyAll();
        }
        Process.setThreadPriority(mPriority);
        onLooperPrepared();
        Looper.loop();
        mTid = -1;
    }
```   
   
   