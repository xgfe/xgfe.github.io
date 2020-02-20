title: SharedPreference导致的ANR优化实践
date: 2020-02-09 15:07:40
categories: shenyanghong
tags: 
- android
- anr
- plugin
- gradle
---

本文介绍了ANR相关原理，以及如何通过插件方式解决SharedPreference导致的ANR。

<!--more-->

## 什么是ANR
ANR是“Application Not Responding”的简称，当Android应用程序的UI线程被阻止时间太长时，将触发应用程序无响应（ANR）的错误，如下图。如果应用程序位于前台，则系统会向用户显示一个对话框，使得用户可以强制退出该应用。开发者模式下可以设置后台程序也展示ANR对话框。
<img src="/uploads/shenyanghong/anr/pic1.png" alt="" width="200" />

### 通常哪些情况会触发ANR
1.在主线程做耗时的IO操作
2.在主线程中做耗时计算
3.主线程中做跨进程操作
4.主线程中使用同步锁，或者sleep等，导致线程长时间等待
### 线下如何检测和排查ANR
1.在开发者模式下，开启“显示所有应用程序无响应”选项，后台应用程序也会显示ANR对话框
2.开启StrictMode( 严苛模式)，帮助检测主线程中的磁盘操作和网络请求
3.从设备中提取/data/anr/anr_* 文件分析，需要root权限，无权限时可以执行adb bugreport > trace.txt 命令，将ANR信息导入trace.txt文件

## 线上ANR如何监控
要想监控ANR，首先需要了解系统是何时抛出ANR对话框的。然后可以模拟系统做相同的监控，或者在系统监控到ANR的，通过手段获取到该通知。
### 系统定义的ANR场景有哪些
ANR都会走到AMS的mAppErrors.appNotResponding方法，通过查看该方法调用，主要有以下场景：
1.前台服务在20s内未执行完成 或者 android 8.0调用startForegroundService() 后，5秒内没有调用startForeground()也会触发ANR
2.前台广播在10s内未执行完成，默认的后台广播超时时间是60s
3.ContentProviderClient 也可能会调用ams.appNotRespondingViaProvider。ContentProviderClient中所有操作都会先调用beforeRemote()，最后调用afterRemote()，在beforeRemote时就会开始ANR计时。ContentProviderClient主要是用来缓存ContentResolver的，使用较少，一般都是使用getContentResolver()。
4.输入事件分发超时5s，包括按键和触摸事件，当native层监控到超时后，会调用InputManagerService.notifyANR，方法如下：

```
// Native callback.
private long notifyANR(InputApplicationHandle inputApplicationHandle,
        InputWindowHandle inputWindowHandle, String reason) {
    return mWindowManagerCallbacks.notifyANR(
            inputApplicationHandle, inputWindowHandle, reason);
}
````

mWindowManagerCallbacks的实现是InputMonitor，InputMonitor的notifyANR,最终会调用AMS的inputDispatchingTimeOut方法，notifyANR中关键代码如下：
```
try {
    // Notify the activity manager about the timeout and let it decide whether
    // to abort dispatching or keep waiting.
    long timeout = ActivityManager.getService().inputDispatchingTimedOut(
            windowState.mSession.mPid, aboveSystem, reason);
    if (timeout >= 0) {
        // The activity manager declined to abort dispatching.
        // Wait a bit longer and timeout again later.
        return timeout * 1000000L; // nanoseconds
    }
} catch (RemoteException ex) {
}
```
AMS.inputDispatchingTimeOut方法，最终会调用AppErrors.appNotResponding方法，该方法主要做了以下几件事：
1.前台应用ANR时存储各个线程调用栈信息到/data/anr/目录下
```
// For background ANRs, don't pass the ProcessCpuTracker to
// avoid spending 1/2 second collecting stats to rank lastPids.
File tracesFile = mService.dumpStackTraces(true, firstPids,
                                           (isSilentANR) ? null : processCpuTracker,
                                           (isSilentANR) ? null : lastPids,
                                           nativePids);
```
2.存储未响应状态到进程中
```
private void makeAppNotRespondingLocked(ProcessRecord app,
            String activity, String shortMsg, String longMsg) {
    app.notResponding = true;
    app.notRespondingReport = generateProcessError(app,
            ActivityManager.ProcessErrorStateInfo.NOT_RESPONDING,
            activity, shortMsg, longMsg, null);
    startAppProblemLocked(app);
    app.stopFreezingAllLocked();
}
```
3.显示ANR对话框
```
// Bring up the infamous App Not Responding dialog
Message msg = Message.obtain();
HashMap<String, Object> map = new HashMap<String, Object>();
msg.what = ActivityManagerService.SHOW_NOT_RESPONDING_UI_MSG;
msg.obj = map;
msg.arg1 = aboveSystem ? 1 : 0;
map.put("app", app);
if (activity != null) {
    map.put("activity", activity);
}
mService.mUiHandler.sendMessage(msg);
```
4.发送ANR广播
```
Intent intent = new Intent("android.intent.action.ANR");
if (!mService.mProcessesReady) {
    intent.addFlags(Intent.FLAG_RECEIVER_REGISTERED_ONLY
            | Intent.FLAG_RECEIVER_FOREGROUND);
}
mService.broadcastIntentLocked(null, null, intent,
        null, null, 0, null, null, null, AppOpsManager.OP_NONE,
        null, false, false, MY_PID, Process.SYSTEM_UID, 0);
```
通过上述分析，ANR发生在发送，启动服务，按键或者触摸事件时；而Activity生命周期耗时，并不会导致ANR，但是如果此时有service启动，用户操作等，则可能会出现ANR
### 线上监控方案
#### 判断ANR时机
通过上述分析，判断ANR时机，较好的办法是通过FileObserver监听/data/anr/目录或者 “android.intent.action.ANR”广播。
而由于没有root权限，/data/anr/目录或文件的监听会无效，ANR广播在部分手机上不ok，因此大部分线上监控方案还会结合5秒轮询的方式。轮询时判断AMS.getProcessesInErrorState()中是否有ANR异常信息。或者监听主线程Looper.loop时，每条Message的执行时间。而ANR问题基本上同一个APP不同用户的现象相差不大，因此会设置一个采样率，不用所有人都监控采样。
#### 输出anr堆栈信息
堆栈信息可以通过提取/data/anr/目录中文件或者调用AMS.getProcessesInErrorState()，该方法返回进程所有错误信息，在发生ANR之后过滤出包含ANR的ProcessErrorStateInfo即可。
## SharedPreference导致的ANR
我们遇到过一个占比较高的ANR和SharedPreference有关，堆栈信息如下：
<img src="/uploads/shenyanghong/anr/pic2.png" alt="" width="600" />
### 原因分析
#### 调用QueueWork.waitToFinish时机有哪些？
我们查看到调用路径为QueueWork.waitToFinish， 那么哪些情况下会调用该方法，查看ActivityThread源码发现有以下情况：
1.Service onStartCommand被调用时
```
private void handleServiceArgs(ServiceArgsData data) {
    Service s = mServices.get(data.token);
    if (s != null) {
        try {
            if (data.args != null) {
                data.args.setExtrasClassLoader(s.getClassLoader());
                data.args.prepareToEnterProcess();
            }
            int res;
            if (!data.taskRemoved) {
                res = s.onStartCommand(data.args, data.flags, data.startId);
            } else {
                s.onTaskRemoved(data.args);
                res = Service.START_TASK_REMOVED_COMPLETE;
            }
            QueuedWork.waitToFinish();
            ...
        } catch (Exception e) {
            ...
        }
    }
}
```
2.Service onStop时
```
private void handleStopService(IBinder token) {
    Service s = mServices.remove(token);
    if (s != null) {
        try {
            if (localLOGV) Slog.v(TAG, "Destroying service " + s);
            s.onDestroy();
            s.detachAndCleanUp();
            Context context = s.getBaseContext();
            if (context instanceof ContextImpl) {
                final String who = s.getClassName();
                ((ContextImpl) context).scheduleFinalCleanup(who, "Service");
            }
            QueuedWork.waitToFinish();
            ...
        } catch (Exception e) {
            ...
        }
    } else {
        Slog.i(TAG, "handleStopService: token=" + token + " not found.");
    }
}
```
3.Activity不可见时
```
private void handleStopActivity(IBinder token, boolean show, int configChanges, int seq) {
    ActivityClientRecord r = mActivities.get(token);
    r.activity.mConfigChangeFlags |= configChanges;
    StopInfo info = new StopInfo();
    performStopActivityInner(r, info, show, true, "handleStopActivity");
    updateVisibility(r, show);
    // Make sure any pending writes are now committed.
    if (!r.isPreHoneycomb()) {
        QueuedWork.waitToFinish();
    }
    ...
}
```
#### 为什么线程会阻塞在SharedPreferencesImpl中，它和QueuedWork有什么关系？
SharedPreferencesImpl 是 SharedPreference的实现类，其中apply() 和 commit() 都调用了QueuedWork，apply()方法中写文件是调用QueuedWork中的Handler来延时执行的。
commit()方法是立即执行 或者调用QueuedWork中的Handler 批量立即执行的。其中加入QueuedWork.sFinishers列表的只有apply()
apply方法代码如下：
```
public void apply() {
    final MemoryCommitResult mcr = commitToMemory();//立即修改内存
    final Runnable awaitCommit = new Runnable() {
            public void run() {
                try {
                    mcr.writtenToDiskLatch.await(); //等待该apply数据写完文件
                } catch (InterruptedException ignored) {
                }
            }
        };

    QueuedWork.addFinisher(awaitCommit);//加入QueuedWork的Finisher队列，检查时机见下文

    Runnable postWriteRunnable = new Runnable() { //写入文件完毕的回调，从QueuedWork移除等待
            public void run() {
                awaitCommit.run();
                QueuedWork.removeFinisher(awaitCommit);
            }
        };

    SharedPreferencesImpl.this.enqueueDiskWrite(mcr, postWriteRunnable);//加入QueuedWork队列，并延时执行

    notifyListeners(mcr);//回调通过registerOnSharedPreferenceChangeListener注册的listener，⚠️回调时不等文件写完成。
}
```
commit方法代码如下：
```
public boolean commit() {
    MemoryCommitResult mcr = commitToMemory();//写入内存

    //如果所有的apply commit 文件都写入完成，则在当前线程执行写入，否则丢到QueuedWork队列，且立即在子线程中执行队列中的runnable
    SharedPreferencesImpl.this.enqueueDiskWrite(mcr, null);

    try {
        mcr.writtenToDiskLatch.await();//等待本次写完
    } catch (InterruptedException e) {
        return false;
    }
    notifyListeners(mcr);
    return mcr.writeToDiskResult;
}
```
apply中关键的异步写方法enqueueDiskWrite代码如下：
```
private void enqueueDiskWrite(final MemoryCommitResult mcr,
                              final Runnable postWriteRunnable) {
    final boolean isFromSyncCommit = (postWriteRunnable == null);

    final Runnable writeToDiskRunnable = new Runnable() {
            public void run() {
                synchronized (mWritingToDiskLock) {
                    writeToFile(mcr, isFromSyncCommit);
                }
                synchronized (mLock) {
                    //写入完成，减少计数器
                    mDiskWritesInFlight--;
                }
                if (postWriteRunnable != null) {
                    postWriteRunnable.run();
                }
            }
        };

    // commit操作
    if (isFromSyncCommit) {
        boolean wasEmpty = false;
        synchronized (mLock) {
            //mDiskWritesInFlight==1表示只有本次写入未完成
            wasEmpty = mDiskWritesInFlight == 1;
        }
        if (wasEmpty) {
            //如果所有的apply commit 文件都写入完成，则在当前线程执行写入
            writeToDiskRunnable.run();
            return;
        }
    }
    //丢到QueuedWork队列，由子线程执行writeToDiskRunnable，commit操作会理解执行，apply会延时100ms执行
    QueuedWork.queue(writeToDiskRunnable, !isFromSyncCommit);
}
```
真正写数据到文件的方法writeToFile代码如下
```
private void writeToFile(MemoryCommitResult mcr, boolean isFromSyncCommit) {
    boolean fileExists = mFile.exists();
    // Rename the current file so it may be used as a backup during the next read
    // 如果文件存在，则先备份，写入时会写到mFile中
    if (fileExists) {
        boolean needsWrite = false;
        // 当磁盘缓存的版本低于需要写入的版本时，才写入
        if (mDiskStateGeneration < mcr.memoryStateGeneration) {
            if (isFromSyncCommit) {
                needsWrite = true;// 当commit时，由于外面在等待写入结果，因此每次都写入
            } else {
                synchronized (mLock) {
                    // 当内存的版本等于要写入的版本时，才写入，也就是多个apply操作，只写入最后一个apply时的内存
                    if (mCurrentMemoryStateGeneration == mcr.memoryStateGeneration) {
                        needsWrite = true;
                    }
                }
            }
        }

        if (!needsWrite) {
            //如果不需要写入时，实际是否写入文件为false，是否操作成功为true
            mcr.setDiskWriteResult(false, true);
            return;
        }

        boolean backupFileExists = mBackupFile.exists();
        if (!backupFileExists) {
            if (!mFile.renameTo(mBackupFile)) {
                //备份失败则算没有写入，且写入失败
                mcr.setDiskWriteResult(false, false);
                return;
            }
        } else {
            mFile.delete();//backup文件存在，则丢弃mFile，因为backupFile永远是完整的
        }
    }

    //真正开始写入mFile，出现任何异常，删除写入异常的mFile
    try {
        FileOutputStream str = createFileOutputStream(mFile);

        if (str == null) {
            mcr.setDiskWriteResult(false, false);
            return;
        }
        XmlUtils.writeMapXml(mcr.mapToWriteToDisk, str);
        ...略

        // 写入成功，mBackupFile就无用了，删除
        mBackupFile.delete();
        mDiskStateGeneration = mcr.memoryStateGeneration;

        //更新写入成功回调
        mcr.setDiskWriteResult(true, true);

        long fsyncDuration = fsyncTime - writeTime;
        mSyncTimes.add(Long.valueOf(fsyncDuration).intValue());
        return;
    } catch (Exception e) {
        Log.w(TAG, "writeToFile: Got exception:", e);
    }

    // 出现异常，删除写入异常的mFile
    if (mFile.exists()) {
        mFile.delete()
    }
    mcr.setDiskWriteResult(false, false);
}
```
### ANR原因
通过上面汇总的waitToFinish调用时机，我们了解到，它都是在主线程执行的。而apply方法执行时，往sFinishes添加了一个等待写入完成的Runnable，因此在触发waitToFinish时，由于主线程等待子线程写入执行完成，从而可能造成ANR，因此主要原因在于QueuedWork.addFinisher代码。
### 解决思路
初步解决思路是，apply时，不将等待写入完成runnable加入sFinishes 队列。设计原因在代码中未说明，可能是为了防止丢失数据，让写入线程有更多时机写入。经过分析和讨论这个不是必须的，因为该方案无法保证进程被杀时的数据丢失问题，修改前后，通过杀进程测试，发现被杀前apply的数据都无法保留下来。而通过和其他端解决方案对比，发现也有将sFinishers 队列清空的方案，这种方案改动更大且未暴露出其他问题，因此我们决定采用apply()时，不将等待写入完成的runnable加入sFinishes 队列。经过多个版本灰度，未见异常，最终全量后没有SharedPreference相关的ANR。
### 具体方案
重写了SharedPreferencesImpl的包装类，该包装类中改变了Editor的apply方法的实现。
apply()重新实现时，将不包含QueuedWork.addFinisher(awaitCommit)，代码如下：
```
public void apply() {
    if (!SafeSp.sEnable) {
        //如果未开启优化，则调用原apply方法
        this.mEditor.apply();
    } else {
        try {
            //通过反射，调用commitToMemory
            final Object mcr = this.commitToMemoryWrapper();
            Runnable postWriteRunnable = new Runnable() {
                @Override
                public void run() {
                    try {
                        //通过反射，调用真正写文件方法writtenToDiskLatch
                        SafeApplyEditor.this.startDiskLatchAwait(mcr);
                    } catch (Exception var2) {
                        SafeSp.setEnable(false);
                    }
                }
            };
            //通过反射，调用enqueueDiskWrite
            this.enqueueDiskWriteWrapper(mcr, postWriteRunnable);
            //通过反射，调用notifyListeners
            this.notifyListenersWrapper(mcr);
        } catch (Exception var3) {
            //API有变更时，关闭优化
            this.mEditor.apply();
            SafeSp.setEnable(false);
        }
    }
}
```
使用时通过SafeSp.getSP(sharedPreferences) 可以返回一个修复了ANR的sharedPreferences，由于SDK中可能也使用了sharedPreferences，因此可以通过gradle插件修改字节码的方式，将app中所有使用SharedPreference的地方都进行替换，替换后是否开启优化可以由上层控制。
## 插件化方案
### 插件开发
插件方案为通过自定义Transform，实现在编译成class后，打包成dex前扫描所有class，找到所有Context.getSharedPreferences("name",mode) 和 PreferenceManager.getDefaultSharedPreferences(context) 代码，替换为SafeSp.getSP(原代码).

为了减少class扫描，因此增加一个外部配置，可以用正则表达式，配置不需要检查的class，默认配置如下：

```
SPManagerPlugin {
    skipClass = ['R\\..*', 'R\\$.*', '.*BuildConfig.*','.*SafeSharedPreferenceUtil.*']
}
```

### 新建Plugin工程
自定义Plugin可以在build.gradle文件中直接定义，为了方便复用，我们这里新建一个独立的Plugin工程来实现，由于AndroidStudio下没有提供直接创建Plugin工程的快捷方式，但可以用AndroidStudio新建一个Java-Library，将build.gradle文件中apply plugin: 'java' 改成 apply plugin: 'groovy'，且在dependencies中添加依赖：compile gradleApi() 和 compile 'com.android.tools.build:gradle:2.3.3' ，这样才可以导入gradle.api 以及gradle相关的类。同时为了兼容java7，需要制定jdk编译版本：

sourceCompatibility = "7"
targetCompatibility = "7"

将src/main下的java目录改名为groovy，在groovy同级目录下新建resources/META-INF/gradle-plugins目录，并在该目录下新建一个文件按以下规则命名：插件名称.properties，插件名称将决定了如何使用该Plugin，用法如apply plugin: '插件名称'，文件内容为implementation-class=Plugin接口的实现类完整名称。如：implementation-class=com.sjst.xgfe.android.plugin.SPManagerPlugin

最后的目录结构如下:
├── build.gradle
├── gradle.properties
└── src
    └── main
        ├── groovy
        └── resources
            └── META-INF
                └── gradle-plugins
                    └── SPManagerPlugin.properties
### 实现Plugin
在groovy目录下新建plugin入口类：SPManagerPlugin.java ，也可以使用.groovy后缀，使用groovy语言开发。SPManagerPlugin需要实现Plugin接口的apply方法，该方法在apply插件的时候会被调用。在该方法中我们可以操作Project。通过Project，可以对已有的Task进行修改或者新增Task，同时也可以注册Transform来实现我们所需要的扫描class 以及新增class功能，注册Transform其本质也是添加一个TransformTask，示例代码如下：
```
public class SPManagerPlugin implements Plugin<Project> {
    @Override
    public void apply(Project project) {
        if (project == null) {
            return;
        }
        LogUtils.sLogger = project.getLogger();//初始化log
        PluginConfig pluginConfig = project.getExtensions().create("SPManagerPlugin", PluginConfig.class);//加载插件配置

        AppExtension appExtension = project.getExtensions().findByType(AppExtension.class);
        //注册Transform来处理字节，TransformProcessor为具体替换处理类
        appExtension.registerTransform(new ReplaceSPTransform(pluginConfig, new TransformProcessor(project,
                pluginConfig)));
    }
}
```
ReplaceSPTransform继承自Transform，它是Android官方提供的在项目构建class到生成dex期间修改class或资源的一套API。主要有以下方法需要实现:
1.getInputTypes:该方法用于指定需要处理的源，这里不需要处理资源，则只需要返回CONTENT_CLASS，如果需要处理资源和class，则返回CONTENT_JARS
```
@Override
public Set<QualifiedContent.ContentType> getInputTypes() {
    //这里只需要处理class
    return TransformManager.CONTENT_CLASS;
}
```
2.getScopes:用于指明Transform的作用域，需要返回各种Scope集合，这里需要支持所有工程，因此返回SCOPE_FULL_PROJECT

```
@Override
public Set<? super QualifiedContent.Scope> getScopes() {
    //所有module都检查
    return TransformManager.SCOPE_FULL_PROJECT;
}
```
3.isIncremental:是否支持增量编译，如果支持增量编译，则需要判断输入源的状态，根据状态处理。如jarInput 通过jarInput.getStatus()判断，directoryInput通过directoryInput.getChangedFiles()判断，来分别处理。当前该插件是不支持增量编译。

Transform执行的入口方法是transform(TransformInvocation invocation)，其中invocation参数包含了输入、输出相关信息，在该方法中我们需要将输入源拷贝到输出目录，输入源中就包含了class文件或jar包，因此可以扫描所有类。同时如果需要修改或新增class，可以在拷贝的过程中处理。invocation输入源分为 JarInput 和 DirectoryInput，JarInput包含的是jar文件地址，DirectoryInput包含的是类或资源文件位置，因此需要分别处理，代码如下：
```
public void transform(TransformInvocation invocation) throws TransformException, InterruptedException,
        IOException {
    Collection<TransformInput> inputs = invocation.getInputs();
    TransformOutputProvider outputProvider = invocation.getOutputProvider();

    for (TransformInput input : inputs) {
        //处理jar文件，处理完后，需要将jar文件写入targetFile
        for (JarInput jarInput : input.getJarInputs()) {

            File targetFile = outputProvider.getContentLocation(
                    jarInput.getName(), jarInput.getContentTypes(), jarInput.getScopes(),
                    Format.JAR);
            processor.processJarFile(jarInput.getFile(), targetFile);
        }
        //处理目录，处理完每个文件后，需要将文件拷贝到targetDir目录
        for (DirectoryInput directoryInput : input.getDirectoryInputs()) {
            File targetDir = outputProvider.getContentLocation(
                    directoryInput.getName(), directoryInput.getContentTypes(),
                    directoryInput.getScopes(), Format.DIRECTORY);
            processor.processDir(directoryInput.getFile(), targetDir);
        }
    }
}
```
### 扫描Class
JarInput数据源处理方式实际上是解压jar文件，并解析jar中的class，DirectoryInput数据源处理实际是直接解析dir中class文件，或者jar文件，总之最终都会走到解析class文件流。
### 替换Class中内容
替换class中内容原理为通过asm API解析字节码，然后再通过visitor去遍历变量，方法或者注解，在遍历的时候可以修改内容，最后再取出修改后的字节码。
解析类内容的代码如下：
```
private byte[] processClassStream(InputStream inputStream) throws Exception {
    ClassReader classReader = new ClassReader(inputStream);

    ClassWriter cw = new ClassWriter(classReader, ClassWriter.COMPUTE_MAXS);
    MyClassVisitor cv = new MyClassVisitor(cw);
    classReader.accept(cv, EXPAND_FRAMES);

    return cw.toByteArray();
}
```
遍历方法并替换内容的代码如下：
```
public class MyClassVisitor extends ClassVisitor {
    public MyClassVisitor(ClassVisitor cv) {
        super(Opcodes.ASM5, cv);
    }
    @Override
    public void visit(int version, int access, String name, String signature, String superName, String[] interfaces) {
        super.visit(version, access, name, signature, superName, interfaces);
    }

    @Override
    public MethodVisitor visitMethod(int access, String name, String desc, String signature, String[] exceptions) {
        //遍历方法时，还需要进一步遍历方法中的内容
        return new MyMethodVisitor(super.visitMethod(access, name, desc, signature, exceptions));
    }
    public class MyMethodVisitor extends MethodVisitor {
        public MyMethodVisitor(MethodVisitor mv) {
            super(Opcodes.ASM5, mv);
        }
        @Override
        public void visitMethodInsn(int opcode, String owner, String name, String desc, boolean itf) {
            if (!needReplace(opcode, owner, name, desc, itf)) {
                super.visitMethodInsn(opcode, owner, name, desc, itf);
            }
        }

        //替换实现
        private boolean needReplace(int opcode, String owner, String name, String desc, boolean itf) {
            boolean result = false;
            boolean isGetSharedPreferences =
                    "android/content/Context".equals(owner) && "getSharedPreferences".equals(name);
            boolean isGetDefaultSharedPreferences = "android/preference/PreferenceManager".equals(owner) &&
            "getDefaultSharedPreferences".equals(name);
            if (isGetSharedPreferences || isGetDefaultSharedPreferences) {
                super.visitMethodInsn(opcode, owner, name, desc, itf);
                //如何替换，可以通过前后代码的asm字节码进行比较
                super.visitMethodInsn(INVOKESTATIC, "com/sjst/xgfe/android/safesp/SafeSp",
                        "getSP", "(Landroid" +
                                "/content/SharedPreferences;)Landroid/content/SharedPreferences;", false);

                result = true;
            }
            return result;
        }
    }
}
```
由于ASM api比较复杂也容易出错，这里我们借助AndroidStudio  asm-bytecode-outline 插件，可以直接查看这个java文件的class类需要用什么asm api来生成。然后通过前后asm字节码文件进行比较即可。
### 本地发布aar
远程发布无法快速测试，因此开发期间可以先采用本地发布aar。主要实现为在plugin工程的build.gradle中添加maven配置，然后在命令行调用  ./gradlew install，就会生成aar到本地mavenLocal目录：~/.m2/repository。maven配置如下：
```
apply plugin: 'maven'
//arr打包配置
group = 'com.sjst.xgfe.android.plugin'
version = '1.0.3'
project.archivesBaseName = 'SPManagerPlugin'
```
因此调试的时候，在测试工程的repositories 中加入mavenLocal() 即可加载到本地插件aar。
### 断点调试
Android运行时代码调试只需要打上断点，选择调试进程即可。而编译期的代码调试则需要做如下处理：
1.添加远程debug运行模式，操作步骤如图1，图2，添加后如图3，名称可以自选，选需要调试的工程
<img src="/uploads/shenyanghong/anr/debug1.png" alt="" width="200" /> <img src="/uploads/shenyanghong/anr/debug2.png" alt="" width="400" />
2.执行编译命令，在正常的编译命令后加--no-daemon -Dorg.gradle.debug=true 即可。

```
./gradlew clean assembleDebug -p plugintest --no-daemon -Dorg.gradle.debug=true
```
3.打上断点，选中刚创建的远程调试模式，也可以在执行命令前选中，点击Debug即可
## 总结
本文首先介绍了ANR相关概念，以及ANR是如何由系统底层产生的。了解底层原理后，我们又分析了如何在线上监控ANR。同时通过剖析SharedPreference实现原理，找到了产生ANR的原因，以及解决办法。为了彻底解决App中此类问题，我们用到了Gradle插件。最后，本文介绍了Gradle插件的开发、调试以及发布技巧。




