title: iOS Crash栈的捕获和分析
date: 2017-03-23 12:48:00
categories: lrdcq
tags: 
- iOS
- objective-c
- hopper

---
在iOS应用开发和线上运行的过程中，我们总会被反馈到各种各样的崩溃。很多崩溃通过case的描述，就能很快的重现并得到修复，但是更多的崩溃也许这一辈子就发生这么一次，也许我们永远不知道它什么时候再会出现。

同时，就算我们捕获到一个Crash栈，由于版本环境等种种原因，或者发生崩溃的代码我们就无法得到它详细的源码，我们往往会对着一片全是程序指令偏移量的Crash栈一脸蒙蔽。
基于以上事实，我们需要从Crash栈的捕获和分析这两个角度进行深入的了解。

本博客主要内容分为两部分：

- OC中的Crash异常的总结和捕获方法
- 利用Hopper对Crash栈进行分析

<!-- more -->

## OC中的Crash异常的总结和捕获方法

相对于java从设计之初就养成的一条exception往下流，trycatch到底的作风，在我们iOS开发过程中，oc的异常处理就是一个不可逾越的障碍阻碍着程序的运行与调试。因为oc一般用NSError甩错误，一旦遇到异常，八成就是非常非常严重的不可挽回的错误了，并且由于oc往下直通c层，里面发生的异常简直是多种多样非常难以准确定位和分析。因此，我们来总结一下常见的异常和抓取处理分析方式。

### OC Exception

oc层的异常是ios开发中最最最好抓取和分析的异常了。制造一个典型的oc异常简直再简单不过：

~~~oc
NSString *str = nil;
NSDictionary *dic = @{@"key":str};
//or
NSArray *array= @[@"a",@"b",@"c"];
[array objectAtIndex:5];
//or
NSAssert(false, @"OC Exception");
~~~

显然，分别是NSDictionary的value不能为空，和NSArray取数据越界，和最暴力的assert直接抛出来的异常。这些在oc层面由iOS库或者各种第三方库或者oc runtime验证出错误而抛出的异常，就是oc异常了。在debug环境下，oc异常导致的崩溃log中都会输出完整的异常信息，比如：*** Terminating app due to uncaught exception 'NSInternalInconsistencyException', reason: 'OC Exception'。包括这个Exception的类名和描述，下面是这个异常的完整堆栈。所以就算xcode的断点停在了main.m里面，我们也可以轻易的找到异常的位置修复问题。

另外，oc异常还有一个非常好用的特性是可以用trycatch抓住（虽然苹果并不建议这么使用）。例如：

~~~oc
@try {
    NSAssert(false, @"OC Exception");
} @catch (NSException *exception) {
    NSLog(@"%@",exception);
}
~~~

就可以获取到当前抛出异常并且阻止异常继续往外抛导致程序崩溃。虽然苹果真的不建议这样做。对于程序真的往外抛出并且我们很难catch到的异常，比如界面和第三方库中甩出来的异常，我们也有方式可以截获到。NSException.m这个文件中携带了一个void NSSetUncaughtExceptionHandler(NSUncaughtExceptionHandler * _Nullable);的函数可以注册一个函数来处理未被捕获的异常。虽然无法阻止程序崩溃，但是可以取得异常进行一些准备和后续处理，使用起来这样：

~~~oc
void HandleException(NSException *exception) {
    NSArray *stackArray = [exception callStackSymbols];
    NSString *reason = [exception reason];
    NSString *name = [exception name];
    NSString *exceptionInfo = [NSString stringWithFormat:@"Exception reason：%@\nException name：%@\nException stack：%@",name, reason, stackArray];
    NSLog(@"%@", exceptionInfo);
}

NSSetUncaughtExceptionHandler(&HandleException);
~~~

往往我们要做的，是把异常信息保存到本地，等到下次启动的时候进行一些后续处理。这些就是crash收集工具所做的事儿。当然，如果妄想在HandleException时拉界面的话，就算了吧，这个函数运行完成后马上就崩溃了。

### Mach Exception

从OC异常往底层走，我们看到的是Mach异常。Mach异常是FreeBSD上特有定义的高层异常，当然，现在网络上能收集到的资料都和mac和ios开发有关。相关的源码网络上可以找到[这里](https://github.com/st3fan/osx-10.9/blob/master/xnu-2422.1.72/osfmk/mach/exception_types.h)。看到异常定义的名称我们会感觉到异常的亲切——EXC_MASK_开头的异常呢。我们一一来总结常见的两个Mach异常吧：

#### EXC_BAD_ACCESS (Bad Memory Access)

这是最常见并且我们觉得最头疼的，内存访问错误。这种异常分为两种：

1. 访问对象未初始化(SIGBUS信号)
2. 访问了什么东西已经被回收掉了(SIGSEGV信号)

当然，事实上到底是怎样的错误比上面描述的复杂神秘得多，这才是这个最难处理的主要原因。
EXC_BAD_ACCESS同时也提供了辅助的异常code来帮助我们判断到底是什么错误，比如KERN_PROTECTION_FAILURE是指的地址无权限访问，KERN_INVALID_ADDRESS是指的地址不可用，异常信息中还会包括具体出错的地址。也许可以获得更多的帮助呢。在debug运行是打开内存管理的Zombie Objects可以获得有效的调试信息。

#### EXC_BAD_INSTRUCTION (Illegal Instruction)

通常通过SIGILL信号触发的异常，很明显，它是在说运行了一条非法的指令。往往错误是这样子的：
XC_BAD_INSTRUCTION (code=EXC_I386_INVOP, subcode=0x0)
虽然是这样说，都是编译器编译出来的指令怎么会有非法指令嘛。所以事实上遇到这样的问题往往是运行指令的参数不对，多半是为0即nil了。然后我们又回到了空指针的问题了～。

当然，除了代码中的问题。更多的是ios开发中的玄学问题导致的ios本身异常和bug，比如[这个](http://stackoverflow.com/questions/24337791/exc-bad-instruction-code-exc-i386-invop-subcode-0x0-on-dispatch-semaphore-dis)就是这样。解决这些问题，还是得老老实实的分析堆栈猜测和分析了。

#### 其他

其他在实际开发中有可能遇到的并不多，主要是:

1. EXC_RESOURCE是指的程序到达资源上限，比如cpu占用过高，内存不足之类的。这样的问题也没法解决啦。
2. EXC_GUARD是一些c层函数访问错误导致的异常，比如fopen文件访问错误之类的都会爆出这个。不过我们好好的oc不用肯定一般也不会使用这些，所以还安好。
3. 0x00000020，这些是被FreeBSD定义为玄学异常的异常都在里面了，也提供了特殊的code来提供辅助信息。其中其实最常见的code是0x8badf00d，是主线程阻塞时间太长，程序被os杀了。其他的遇到了就是见鬼了！

### Unix Signal Exceptions

从Mach异常再往上走追根究底，其实，所以异常发生的本质途径都是Unix的异常信号。

1. OC异常并不是真正的异常，但是当一个OC异常被抛出到最外层还没被谁捕获，程序会强行发送SIGABRT信号中断程序。
2. Mach异常没有比较方便的捕获方式，不过由于它本质就是信号，所以这一段讲的东西也能包含处理Mach异常。

产生一个不属于Mach异常的异常信号也是非常非常简单的事儿，比如:

~~~oc
int *i;
free(i);
~~~

总之，c层面，runtime或者其他东西控制程序就是通过信号，中断当然也不例外。通过不同的信号，我们也能知道很多不同的东西。在ios开发环境中，信号枚举在sys/signal.h文件中，我们可以看到大量的Unix信号罗列其中，参考[wiki](https://en.wikipedia.org/wiki/Unix_signal)可以看到各个信号的详解。当然，我们最终关心的是能否捕获这些异常信号来抓住异常和崩溃。对，方法是有的，这里提供了一个叫void (*signal(int, void (*)(int)))(int);的方法来注册一个处理函数。

这个方法最后吐出来的是当前的信号，没异常信息堆栈怎么办，还好，从execinfo.h中，我们可以取出当然汇编层程序的堆栈情况。这就好办了，最后处理代码如下：

~~~oc
void SignalExceptionHandler(int signal) {
    NSMutableString *mstr = [[NSMutableString alloc] init];
    [mstr appendString:@"Stack:\n"];
    void* callstack[128];
    int i, frames = backtrace(callstack, 128);
    char** strs = backtrace_symbols(callstack, frames);
    for (i = 0; i <frames; ++i) {
        [mstr appendFormat:@"%s\n", strs[i]];
    }
}

void InstallSignalHandler(void) {
    signal(SIGHUP, SignalExceptionHandler);
    signal(SIGINT, SignalExceptionHandler);
    signal(SIGQUIT, SignalExceptionHandler);
    signal(SIGABRT, SignalExceptionHandler);
    signal(SIGILL, SignalExceptionHandler);
    signal(SIGSEGV, SignalExceptionHandler);
    signal(SIGFPE, SignalExceptionHandler);
    signal(SIGBUS, SignalExceptionHandler);
    signal(SIGPIPE, SignalExceptionHandler);
}
~~~

要注意的是这里获得的堆栈信息是，当前汇编子程序的offset+指令offset，要么我们需要符号表，要么我们需要反编译一些我们的程序来对应代码了。

## 利用Hopper对Crash栈进行分析

对于上文已经获得的crash堆栈，无论是否可以通过符号表获得代码实际情况，只要我们没发看到确切的代码，都是无法直接通过crash栈直接进行分析。特别是遇到整个crash堆栈里面完全没有自己项目的代码，或者虽然是我们的项目名下的堆栈，却是通过pod引入的第三方库。更现实的是，为了加速代码编译或者开发者干脆就是闭源的，往往pod引入的库都是二进制的静态库，所以我们得到的堆栈肯定没有具体代码行数，看到堆栈肯定是无计可施。

遇到这样的情况，我们看到的堆栈往往是：0x100072ea4 0x100050000 + 143012这样只会有堆栈指令的pc位置或者方法名 + offset显示出来的pc位置，而不是。这样我们需要分析代码，只有通过分析具体的汇编指令才能继续下去。

而Hopper这个iOS查看和半反编译工具正适合这件事。

### 准备工作

首先我们当然要下载一个[Hopper](https://www.hopperapp.com)。这个软件demo版可以直接使用完整功能，和Charles一样每次启动可以使用30分钟——对于我们勉强够用了，动心了可以买买买～
另外，我们还需要找到用于进行反编译的程序。理论上，它在ipa包的/Payload/xxx.app/xxx即对应的编译结果，其中在本地xcode编译出来的app在~/Library/Developer/Xcode/DerivedData下。
最后，我们当然要准备好需要的crash堆栈，另外在旁边准备一个科学计算器比较好。
另外再用浏览器开一个ARM汇编指令大全吧。[比如](http://blog.csdn.net/forever_2015/article/details/50285865)

### iOS的ARM汇编基础

虽然基本上只需要一丁点儿汇编基础知识就可以开展工作，还是有一些需要知道的。
寄存器相关：一共有31个64位通用寄存器, x0~x30。其中x29是frame pointer；x30是procedure link register；还有sp和pc。

常用的汇编指令我们需要了解的主要是：

- mov r1,r2 把r2的数据赋予r1
- ldr r1,r2 把r2指向的数据赋予r1
- str r1,r2 把r1的数据赋予r2指向的地方
- add sub之类的运算符肯定是需要的
- 那一堆草鸡麻烦的跳转判断指令
- bl 调用子程序
- [r1, 0xXXXX]这样offset的方法

另外oc方法调用的情况下：

~~~oc
id value = [obj methodKey1:key1 andKey2:key2];
~~~

编译到c层实际调用是：

~~~c
id value = objc_msgSend(obj, @selector(methodKey1:andKey2:), key, key2);
~~~

当然，c的函数对应的其实是汇编调用子函数。因此我们需要的入口参数obj,selector,key,key2...其实是通过r0,r1,r2.....传输的，特殊情况下可能会通过堆栈传输，不过一般不会～。另外返回值会直接返回到r0里边。

嗯，知道这些就可以了。

### 栗子：一次完整的分析

这次我们分析的完整的崩溃堆栈是这样的：

~~~log
Exception Type:  EXC_CRASH (SIGABRT)
Exception Codes: 0x0000000000000000, 0x0000000000000000
Exception Note:  EXC_CORPSE_NOTIFY
Triggered by Thread:  8

Application Specific Information:
abort() called

Filtered syslog:
None found

Last Exception Backtrace:
0   CoreFoundation                  0x18a1151b8 __exceptionPreprocess + 124
1   libobjc.A.dylib                 0x188b4c55c objc_exception_throw + 56
2   CoreFoundation                  0x18a11c268 -[NSObject(NSObject) doesNotRecognizeSelector:] + 140
3   CoreFoundation                  0x18a119270 ___forwarding___ + 916
4   CoreFoundation                  0x18a01280c _CF_forwarding_prep_0 + 92
5   kmall                           0x1004b103c 0x100050000 + 4591676
6   kmall                           0x1003d1ef8 0x100050000 + 3677944
7   kmall                           0x1003d23a0 0x100050000 + 3679136
8   libdispatch.dylib               0x188f9e1fc _dispatch_call_block_and_release + 24
9   libdispatch.dylib               0x188f9e1bc _dispatch_client_callout + 16
10  libdispatch.dylib               0x188fac3dc _dispatch_queue_serial_drain + 928
11  libdispatch.dylib               0x188fa19a4 _dispatch_queue_invoke + 652
12  libdispatch.dylib               0x188fac8d8 _dispatch_queue_override_invoke + 360
13  libdispatch.dylib               0x188fae34c _dispatch_root_queue_drain + 572
14  libdispatch.dylib               0x188fae0ac _dispatch_worker_thread3 + 124
15  libsystem_pthread.dylib         0x1891a72a0 _pthread_wqthread + 1288
16  libsystem_pthread.dylib         0x1891a6d8c start_wqthread + 4
~~~

从堆栈的角度，可以看到，倒数第三层调用到了doesNotRecognizeSelector方法然后抛出了异常，结合上下文，可以猜想到应该是某一个object存在，但是调用了不存在的方法——也许是类型错误，导致了这个崩溃的发生。

而查询后，kmall的三层均不是我们项目代码，而是闭源的第三方库中抛出来的错误，无法得到其他信息。因此现在，只有从kmall最高的那一层，即第5层堆栈开始入手分析汇编代码了。

#### 堆栈第一层

我们看到的地址是0x1004b103c 0x100050000 + 4591676，其实就是程序的0x46103C偏移位置。直接用hopper打开程序进行反汇编找到对应的子函数：

~~~asm
        ; ================ B E G I N N I N G   O F   P R O C E D U R E ================


                     +[GuardCommon encrypt:withKey:byAlgorithm:]:
0000000100460f1c         stp        x29, x30, [sp, #-0x10]!                     ; Objective C Implementation defined at 0x1009fa370 (class method), DATA XREF=0x1009fa370
0000000100460f20         mov        x29, sp
0000000100460f24         sub        sp, sp, #0x80
0000000100460f28         sub        x8, x29, #0x20
0000000100460f2c         movz       x9, #0x0
0000000100460f30         stur       x0, [x29, #-0x10]
0000000100460f34         stur       x1, [x29, #-0x18]
0000000100460f38         stur       x9, [x29, #-0x20]
0000000100460f3c         mov        x0, x8
0000000100460f40         mov        x1, x2
0000000100460f44         str        x3, [sp, #0x40]
0000000100460f48         str        x4, [sp, #0x38]
0000000100460f4c         bl         imp___stubs__objc_storeStrong
0000000100460f50         sub        x8, x29, #0x28
0000000100460f54         movz       x9, #0x0
0000000100460f58         stur       x9, [x29, #-0x28]
0000000100460f5c         ldr        x9, [sp, #0x40]
0000000100460f60         mov        x0, x8
0000000100460f64         mov        x1, x9
0000000100460f68         bl         imp___stubs__objc_storeStrong
...
0000000100460fd0         adrp       x8, #0x100a64000                            ; CODE XREF=+[GuardCommon encrypt:withKey:byAlgorithm:]+156
0000000100460fd4         add        x8, x8, #0x630                              ; objc_cls_ref_GuardEncryptProcessor
0000000100460fd8         ldr        x8, x8
0000000100460fdc         ldur       x9, [x29, #-0x20]
0000000100460fe0         mov        x0, x9
0000000100460fe4         str        x8, [sp, #0x30]
0000000100460fe8         bl         imp___stubs__objc_retainAutorelease
0000000100460fec         adrp       x8, #0x100a53000                            ; @selector(setTitleLabelBackgroundColor:)
0000000100460ff0         add        x8, x8, #0x488                              ; @selector(bytes)
0000000100460ff4         ldr        x1, x8
0000000100460ff8         bl         imp___stubs__objc_msgSend
0000000100460ffc         adrp       x8, #0x100a52000
0000000100461000         add        x8, x8, #0x3a0                              ; @selector(length)
0000000100461004         ldur       x9, [x29, #-0x20]
0000000100461008         ldr        x1, x8
000000010046100c         str        x0, [sp, #0x28]
0000000100461010         mov        x0, x9
0000000100461014         bl         imp___stubs__objc_msgSend
0000000100461018         mov        x2, x0
000000010046101c         ldur       x8, [x29, #-0x28]
0000000100461020         mov        x0, x8
0000000100461024         str        w2, [sp, #0x24]
0000000100461028         bl         imp___stubs__objc_retainAutorelease
000000010046102c         adrp       x8, #0x100a55000                            ; @selector(clickGoPay:)
0000000100461030         add        x8, x8, #0xfd0                              ; @selector(UTF8String)
0000000100461034         ldr        x1, x8
0000000100461038         bl         imp___stubs__objc_msgSend
000000010046103c         ldur       x8, [x29, #-0x30]
~~~

这个子函数有点长，我先截取一部分看看。首先根据hopper部分反编译（其实是数据映射的结果），这个子函数对应的方法是 +[GuardCommon encrypt:withKey:byAlgorithm:]:。嗯，糟糕，这是一个第三方库里面的代码，并且我们找不到源码，到此为止我们落实要通过分析汇编代码的方式来查crash了。

然后我们找到目标pc地址的上一句，是一句bl即调用子函数，hopper又很贴心的把ios中常见系统子函数给反编译告诉我们了，这是一句msgSend，和我们看到堆栈预期的一样，调用了不存在的方法。那么我们首先要做的就是找到msgSend的obj和selector，他们应该在调用子函数前被放置在了对应的x0和x1处。

往上看，x1很快就找到了。hopper也很贴心的把常量指向的字符串在右侧标了出来。x1是从x8加载出来的，x8指向的字符串“UTF8String”。然后x0呢，在0x461020看到x0是从x8挪过来的，而那里x8是从[x29, #-0x28]加载出来的。那么我们接下来就是需要关心[x29, #-0x28]是哪儿来的了。

继续往上看，在子函数开始部分0x460f58，把原本x9的数据放入了[x29, #-0x28]指向的位置中，但是注意到0x460f50开始的sub最后得到的x8也是指向的这个位置，所以我们综合看一下。那一段结束之后调用了objc_storeStrong方法，我们知道objc_storeStrong是处理入参的持有问题，把入参数转换到另一个新的id上。因此考虑到分别传入了一个空的指针和一个x0，因此这其实是在对x8做storeStrong初始化。

那么看到传入的x1即原始数据，是从哪儿来的？在0x460f5c从[sp, #0x40]读出来的，而[sp, #0x40]哪儿来的，就在上面几行从x3中储存进去的，x3到此为止——嗯，x3不就是子函数的入参么，应该是oc方法的第二个参数吧。即+[GuardCommon encrypt:withKey:byAlgorithm:]的key咯。

到此为止，我们第一层堆栈分析完毕，可以继续往上了。

#### 堆栈第二层

然而，分析第二层我们可见的堆栈子程序：

~~~asm
        ; ================ B E G I N N I N G   O F   P R O C E D U R E ================


                     -[WindFingerprintGenerator tranformToFingerprint:]:
0000000100381db0         stp        x29, x30, [sp, #-0x10]!                     ; Objective C Implementation defined at 0x1009e41f8 (instance method), DATA XREF=0x1009e41f8
0000000100381db4         mov        x29, sp
0000000100381db8         sub        sp, sp, #0xb0
0000000100381dbc         sub        x8, x29, #0x30
0000000100381dc0         movz       x9, #0x0
0000000100381dc4         adrp       x10, #0x100918000
0000000100381dc8         ldr        x10, [x10, #0x400]                          ; ___stack_chk_guard_100918400,___stack_chk_guard
0000000100381dcc         ldr        x10, x10
0000000100381dd0         mov        x3, x10
0000000100381dd4         stur       x10, [x29, #-0x8]
0000000100381dd8         stur       x0, [x29, #-0x20]
...
0000000100381e64         adrp       x8, #0x100a5b000                            ; @selector(readStream)
0000000100381e68         add        x8, x8, #0x270                              ; @selector(aesKey)
0000000100381e6c         stur       x0, [x29, #-0x40]
0000000100381e70         ldur       x9, [x29, #-0x20]
0000000100381e74         ldr        x1, x8
0000000100381e78         mov        x0, x9
0000000100381e7c         bl         imp___stubs__objc_msgSend
0000000100381e80         mov        x29, x29
0000000100381e84         bl         imp___stubs__objc_retainAutoreleasedReturnValue
0000000100381e88         str        x0, [sp, #0x48]
0000000100381e8c         cbz        x0, loc_100381e9c

0000000100381e90         ldr        x8, [sp, #0x48]
0000000100381e94         str        x8, [sp, #0x40]
0000000100381e98         b          loc_100381eac

                     loc_100381e9c:
0000000100381e9c         adrp       x8, #0x10092e000                            ; CODE XREF=-[WindFingerprintGenerator tranformToFingerprint:]+220
0000000100381ea0         add        x8, x8, #0x390                              ; _kAESKey
0000000100381ea4         ldr        x8, x8
0000000100381ea8         str        x8, [sp, #0x40]

                     loc_100381eac:
0000000100381eac         ldr        x0, [sp, #0x40]                             ; CODE XREF=-[WindFingerprintGenerator tranformToFingerprint:]+232
0000000100381eb0         bl         imp___stubs__objc_retain
0000000100381eb4         stur       x0, [x29, #-0x48]
0000000100381eb8         ldr        x0, [sp, #0x48]
0000000100381ebc         bl         imp___stubs__objc_release
0000000100381ec0         adrp       x0, #0x10096d000                            ; @"- (int64_t)%@;"
0000000100381ec4         add        x0, x0, #0xc60                              ; @"AES"
0000000100381ec8         adrp       x30, #0x100a5b000                           ; @selector(readStream)
0000000100381ecc         add        x30, x30, #0x278                            ; @selector(encrypt:withKey:byAlgorithm:)
0000000100381ed0         adrp       x8, #0x100a64000
0000000100381ed4         add        x8, x8, #0x338                              ; objc_cls_ref_GuardCommon
0000000100381ed8         ldr        x8, x8
0000000100381edc         ldur       x2, [x29, #-0x40]
0000000100381ee0         ldur       x3, [x29, #-0x48]
0000000100381ee4         ldr        x1, x30
0000000100381ee8         str        x0, [sp, #0x38]
0000000100381eec         mov        x0, x8
0000000100381ef0         ldr        x4, [sp, #0x38]
0000000100381ef4         bl         imp___stubs__objc_msgSend
0000000100381ef8         mov        x29, x29
~~~

依然是一段分析过后的关键段落截取。首先看到的方法名-[WindFingerprintGenerator tranformToFingerprint:]:，嗯，不是可见的方法，但是和刚才不同的是这是一个实例方法了，所以当前对象很重要。另外虽然方法没见过，WindFingerprintGenerator却是有暴露给用户使用，所以可以找到一些有用的信息。

然后从堆栈出口看，嗯，果然是msgSend而且selector对得上，没问题。然后刚才我们注意到的是x3，那在哪儿放进去的呢？原来是0x381ee0行，从[x29, #-0x48]读取出来的。然后继续往上0x381eb4处，讲0x储存到了[x29, #-0x48]中，而x0又是从[sp, #0x40]读取出来的。

然后上面这一段是一个双goto，本质上是一个if判断，看一下判断指令：cbz x0是否存在？如果存在，往下，0x381e90把[sp, #0x48]读出来赋予了[sp, #0x40]，而[sp, #0x48]正好又是x0。所以结论是如果x0存在，传给后面了x0的值。

另一个分支，如果x0不存在，0x381ea0开始从一个叫_kAESKey的静态变量读取了数据并赋予了[sp, #0x40]。

所以这一段其实是：

~~~c
[sp, #0x40] = x0 ? x0 : _kAESKey;
~~~

那关键其实就是x0了。考虑到后面的崩溃应该是对象存在但是没有方法，因此这里要么是x0不存在_kAESKey不对，要不是x0不对，我们需要继续追踪。

这里往上，x0就是0x381e7c中sendMsg的返回值，其中selector是aesKey，而对象x0是x9从[x29, #-0x20]来的。继续往上找，[x29, #-0x20]在0x381dd8从x0赋予，而这里是x0最早出现的位置，即当前子函数的obj。因此完整解释出来，就是：

~~~c
[sp, #0x40] = self.aesKey ? self.aesKey : _kAESKey;
~~~

诶，打住，到此为止。写过相关代码的同学立刻会发现，self，即WindFingerprintGenerator的实例的aesKey好像是暴露出来给用户设置的诶。赶快去看看～～～

至此，这次crash分析就结束了，事实上看到的是api希望aesKey是一个NSString，而我们代码中设置成了NSNumber，由此导致的错误。

## 总结

以上Crash捕获处理就可以兜底式的涵盖所有的ios应用异常和崩溃的情况，是非常有效率。而结合hopper帮助给子程序映射oc方法进行拆分，和对常用oc子程序进行部分反编译之后，阅读iOS的汇编结果进行crash堆栈分析并不是什么困难的事情。我们可以得到很多有用的信息，结合传统的crash分析方法和经验，可以更可靠有效的解决问题。

通过以上一个完整的Crash栈捕获和抓取的流程，我们可以亲手抓住iOS应用在运行中遇到的所有大大小小的崩溃情况，并且在非常劣势的条件下，有效的对Crash进行分析，解决疑难杂症。

虽然通过各种第三方崩溃统计服务，它们可能帮助我们把以上的大部分工作都完成了。但是最好解决bug的还是我们自己啊，不知彼知己拿着Crash能不方么～