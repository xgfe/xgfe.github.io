title: Kotlin初探(JAVA视角)
date: 2020.6.17 16:01:00
updated: 2020.6.17 16:01:00
categories:
- zhangziying03
tags:
- Android
- Kotlin
- Mobile
---
## 简介
kotlin凭什么被称为 "better java"？本文从java使用者的角度入门kotlin，康康kotlin好处都有啥🤔
<!--more-->
## Kotlin是什么
### Kotlin和JAVA的关系：
Kotlina兼容JAVA，可以直接调用JAVA代码，因此一切JAVA的库也适用于kotlin。Kotlin可以编译成JVM字节码也可以编译成JavaScript方便在没有 JVM 的设备上运行。JAVA能跑的地方kotlin也能跑，kotlin可以看做JAVA的扩展/优化。
在语法糖的加持下Kotlin相比JAVA可以写出更简洁的代码。Kotlin在无缝兼容JAVA的基础上还拥有一些其他特性，比如协程、空类型检查等特性。
### Kotlin的社会地位：
Kotlin 在2017年被Google宣布为Android官方开发语言。
## 基本语法
## 变量
Kotlin中一切都是对象。可以采用统一的方式进行声明
### 声明
kotlin中可以使用var或val对变量进行定义，其中var定义可变变量，val定义不可变变量
```kotlin
//kotlin中不需要分号了哦😯
var <标识符> : <类型> = <初始化值>
val <标识符> : <类型> = <初始化值>

```
### NULL检测
java中虽然有@Nullable @NotNull等注解。但是不会在编译期起作用，而是在运行期抛出异常。kotlin在声明变量的时候，可以指定变量是否为空，调用可为空对象时，需要进行空判断。
在Kotlin的NULL检查机制中，使用!!以及?进行NULL检测。其中加上!!后则变量不可为空，否则会NPE(NullPointerException)，而?则可以为空。
在声明变量的时候，在类型后面加上相应的符号：
```kotlin
var h: String? = "helloworld" 
```
在使用变量的时候对于可空的变量可以直接抛出异常或者进行相应的处理或者不作处理。
```kotlin
var h: String? = "1" 
//!!抛出空指针异常
val ages = age!!.toInt()
//不做处理返回 null
val ages1 = age?.toInt()
//age为空返回-1 等价于 age2 = age==null?null:-1;
val ages2 = age?.toInt() ?: -1
```
### 比较与类型判断
在 Kotlin 中，三个等号 === 表示比较对象地址，两个 == 表示比较两个值大小。
```kotlin
val a:Int = 1
val b:Int = 2
a===b //false
a==b //true
```
类型判断也十分简便，使用 is 进行判断：
```kotlin
if(a is Int) { //todo }
```
## 循环相关
### 区间遍历
对于一个区间的遍历，kotlin提供了java相比更为简约的写法
//区间可以通过..进行连接，如A..B表示[A,B] 还可以通过 until 进行连接,比如 A until B 表示[A,B)
```kotlin
for(i in 区间) 
//还可以通过downTo从大往小取 
for(i in 5 downTo 1)
//也可以设定步长，比如每两个数取一次
for(i in 5 downTo 1 step 2)
```
### 更简洁的switch：when
```kotlin
在kotlin中可以使用when来替代java中的switch
when (x) {
    1,3 -> print("1 OR 3")
    2 -> print("3")
    in 4..10 -> print("in [4,10]")//可以判断区间
    is Int -> print("is Int") // 还可以判断类型
    else -> { // 除非覆盖所有情况，否则必须写
        print("err")
    }
}
```
## 类与对象
### 构造函数
kotlin对象支持多个构造函数，其中分为主构造函数和次构造函数。主构造函数的参数放在类的头，具体代码放在类内的 init{} 代码段中。次构造函数直接在类内使用constructor进行声明：
```kotlin
//若主构造函数没有任何注解或者可见性修饰符(public、protected、private、internal)，则 constructor 可以省略
class Demo construcotr(name: String) {   
        //主构造函数
   init {
             // TODO  
      }    
    //次构造函数
   construcotr(name: String, key: String){
   //TODO
   }
}
```
其他内容与java相似度较大，不再展开。
## 协程
首先，协程并不是kotlin特有的，它已经有十几年的历史了，go javascript python等语言都支持协程。简单的来说，协程就是轻量级的线程。协程完全由程序控制，因此协程的切换不设计用户态和内核态的转变消耗相对于线程切换更低。一个进程中可以有多个线程，而一个线程中也可以有多个协程。对于同一个线程里面的协程，它们之间的执行是串行的。因此协程序适合于io密集型的程序。
### 基本使用
**launch**
一个最简单协程的创建用launch加上大括号括起来的代码即可，返回Job,可以用来对协程进行取消等操作
```kotlin
fun main() {
    var job = launch{
        //todo
    //使用delay可以挂起协程
    delay(1000L)
    }
    job.cancel()
    jobljoin()
}
```
**runBlocking**
runBlocking启动的协程任务会阻断当前线程，直到该协程执行结束：
```kotlin
fun main() {
    runBlocking {     
        delay(2000L)  
    } 
}
```
也可以用runBlocking来包装一个函数
```kotlin
fun test() = runBlocking<T> { 
    //todo
}
```
**async/await**
async方法的返回值类型是Deferred, 是Job的子类, Deferred里有个await方法, 调用它可得到协程的返回值。
```kotlin
fun test() = runBlocking<T> { 
    var deferred = async{ //todo}
    //输出结果
    print(deferred.await())
}
```
### 其他概念&参数
上下文：协程运行的上下文包括Job以及调度器等
协程调度器: 决定协程运行的线程情况，比如指定线程或者不设限
***GlobalScope&CoroutineScope***
GlobalScope继承自CoroutineScope。当一个协程被其它协程在 CoroutineScope中启动的时候则会继承父协程的上下文。当使用 GlobalScope来启动一个协程时，则新协程的作业没有父作业。 因此它与这个启动的作用域无关且独立运作。
可以在创建协程的时候使用，比如
```kotlin
var job = GlobalScope.launch{
        //todo
    //使用delay可以挂起协程
    delay(1000L)
}
```
也可以直接创建一个作用域，然后在里面创建协程
```kotlin
GlobalScope{
        launch{
            //todo
    }
}
```
***调度器***
```kotlin
launch(Dispatchers.Default) { // 将会获取默认调度器
   //todo
}
launch(newSingleThreadContext("MyOwnThread")) { // 将使它获得一个新的线程
   //todo
}
```


