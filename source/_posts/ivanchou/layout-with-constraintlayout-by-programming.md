title: ConstraintLayout 采用代码方式布局用法简介
date: 2017-09-17
categories: 
- ivanchou
tags:
- Android
- 布局
---

关于 ConstraintLayout 的 xml 方式布局的介绍有很多，但是你知道 ConstraintSet 吗？
本文对于 ConstraintLayout 采用代码进行布局的方式进行了介绍。

<!--more-->

## 引言

我们知道，Android 界面的布局按照传统方式是通过编写 xml 代码去实现的。虽然 Android Studio 提供可视化的方式去编写界面，但是并没有编写 xml 代码好用。为了解决这一问题 ConstraintLayout 诞生了，这是 Google 在 I/O 2016 推出的用可视化的方式编写界面的布局。（注：从 Android Studio 2.2 开始提供支持）

ConstraintLayout 的优点在于使用扁平的层次结构创建出复杂的布局，类似于 RelativeLayout 通过定义自身与其他 View 或者 Parent 之间的关系实现布局，ConstraintLayout 比 RelativeLayout 更加灵活。同时，在 Android Studio 中可以且推荐使用可视化的方式去编写界面。

* 在 xml 中使用
    
    关于 xml 方式进行布局的资料有很多，就不再赘述了。

* 通过编程的方式布局

    android.support.constraint 包下有四个类，分别是 ConstraintLayout、ConstraintLayout.LayoutParams、ConstraintSet 与 Guideline。官方文档对它们的说明分别如下所示，

>| 类名 | 描述 |
|----------|----------|
| ConstraintLayout | A ConstraintLayout is a ViewGroup which allows you to position and size widgets in a flexible way. |
| ConstraintLayout.LayoutParams | This class contains the different attributes specifying how a view want to be laid out inside a ConstraintLayout. |
| ConstraintSet | This class allows you to define programmatically a set of constraints to be used with ConstraintLayout. |
| Guideline | Utility class representing a Guideline helper object for ConstraintLayout. |

   对于 ConstraintSet 的描述是可以通过编程的方式定义一系列约束，本文的主题就是围绕着 ConstraintSet 来进行的。

## 编程实现约束布局

要通过编程的方式实现约束布局，分为以下一个步骤，

* 添加 View 到 Activity 中
    
    在 onCreate() 方法中创建 ConstraintLayout，并添加两个按钮到布局上，通过 setContentView() 设置 Activity 的布局。
    
    ```Java
    public class MainActivity extends AppCompatActivity {

        Button mOkBtn;
        Button mCancelBtn;

        @Override
        protected void onCreate(Bundle savedInstanceState) {
            super.onCreate(savedInstanceState);

            ConstraintLayout cl = new ConstraintLayout(this);

            mOkBtn = new Button(this);
            mOkBtn.setText("OK");
            cl.addView(mOkBtn);

            mCancelBtn = new Button(this);
            mCancelBtn.setText("Cancel");
            cl.addView(mCancelBtn);

            setContentView(cl);

        }
    }
    ```

* 给 View 设置 id

    通常在 xml 中添加 View 时，Android SDK 会自动帮我们生成资源文件的 id，存储在 R.java 中。但是通过代码的方式并不会触发生成 id，所以需要进行手动绑定。
    
    首先，在 res/values 目录中新建一个资源文件 ids.xml，内容如下:
    
    ```Xml
    <?xml version="1.0" encoding="utf-8"?>
    <resources>
        <item name="btnCancel" type="id"/>
        <item name="btnOk" type="id"/>
    </resources>
    ```
    然后在代码中进行绑定，
    
    ```Java
    mOkBtn.setId(R.id.btnOk);
    mCancelBtn.setId(R.id.btnCancel);
    ```
    这时候之后设置的相关约束才会真正生效。

* 设置 View 的属性

    必须设置的属性除了 view id 还有宽高，宽高属性是通过 ConstraintSet 来设置的，通过指定 view id 及可选的有水平方向的依赖以及垂直方向的依赖。

    我们知道采用 xml 进行布局的时候对于宽高的设置有三种选项，分别是 wrap_content、match constraints(0dp) 以及 fixed ，而通过代码的方式只有前面两种，没有 fiexd 这个选项。
    
>|              常量值             |      描述     |
|:-------------------------------|:------------:|
| ConstraintSet.WRAP_CONTENT     | WRAP_CONTENT |
| ConstraintSet.MATCH_CONSTRAINT | 0 dp         |
	
设置 view 宽高的方法如下，
	
>|xml 属性 | 对应方法|
|---|---|
|android:layout_height | ConstraintSet.constrainHeight(int viewId, int height)|
|android:layout_width | ConstraintSet.constrainWidth(int viewId, int width)|

* 配置依赖关系 ConstraintSet
    
    官方推荐使用 ConstraintSet 来进行约束配置，这里很奇怪为什么不能通过 LayoutParams 来配置依赖关系。ConstraintSet 可以用来通过编程的方式定义一系列用在 ConstraintLayout 上的约束，可以用来创建、保存约束，并且可以将其应用在已有的 ConstraintLayout 上，可以通过以下几种方式创建 ConstraintSet，
    
    1. 手动
    ```Java
    c = new ConstraintSet(); c.connect(....);
    ```
    2. 读取 xml 文件中的约束
    ```Java
    c.clone(context, R.layout.layout1);
    ```
    3. 从其他 ConstraintLayout 复制
    ```Java
    c.clone(clayout);
    ```
    第2、3两种方法具体使用参见官方文档说明，这篇文章主要介绍手动编码的方式。我们重点来看 connect 方法，

    ```Java
    void connect(int startID, int startSide, int endID, int endSide, int margin)
    ```
    connect 方法需要四个参数，可以理解为连线的起始 view 的边与终止 view 的边，描述一个 view 的边需要通过 view id 与 side 来确定，对应到 xml 中则是 layout_constraint{$startSide}_to{$endSide}Of = "endID" 属性。这里的 view id 非常重要，在没有设置 view id 的情况下会导致无法找到正确的 view，也就无法正确应用约束设置。

    尝试在代码中打印出 view id 的值，可以发现通过 new 方式得到的 view 的 id 默认为 -1，也正是因为这个原因，你会发现没有设置 view id 的情况下布局并没有生效。ConstraintSet 中用来描述约束特征的常量有如下几种，
   
>|常量值 | 描述|
|---|---|
|ConstraintSet.LEFT | View 的左边界|
|ConstraintSet.RIGHT| View 的右边界|
|ConstraintSet.TOP | View 的顶部|
|ConstraintSet.BOTTOM | View 的底部|
|ConstraintSet.BASELINE | View 中 text 的基线|
|ConstraintSet.PARENT_ID | 父控件的 id，通常情况下为 ConstraintLayout|
    
    
* dpTopx

    通常我们在 xml 中可以直接输入具体的 dp 值，但是在代码中具体的数值代表的是 px，所以需要根据屏幕具体的分辨率进行转换。

    ```Java
    public int dpToPx(int dp) {
        DisplayMetrics displayMetrics = getContext().getResources().getDisplayMetrics();
        return Math.round(dp * (displayMetrics.xdpi / DisplayMetrics.DENSITY_DEFAULT));     
    }
    ```
    

## 案例
    
接下来我们通过一个简单的 demo 来了解一下 ConstraintSet 的用法。编写一个只包含确定、取消按钮的界面，采用 xml 的方式配置的代码如下，

```Xml
<Button
    android:id="@+id/btnCancel"
    android:layout_width="wrap_content"
    android:layout_height="wrap_content"
    android:layout_marginBottom="8dp"
    android:layout_marginLeft="8dp"
    android:text="Cancel"
    app:layout_constraintBottom_toBottomOf="parent"
    app:layout_constraintLeft_toLeftOf="parent" />

<Button
    android:id="@+id/btnOK"
    android:layout_width="wrap_content"
    android:layout_height="wrap_content"
    android:layout_marginBottom="8dp"
    android:layout_marginRight="8dp"
    android:text="OK"
    app:layout_constraintBottom_toBottomOf="parent"
    app:layout_constraintRight_toRightOf="parent" />
```
将其转换成对应的 Java code，

```Java
public class MainActivity extends AppCompatActivity {

    Button mOkBtn;
    Button mCancelBtn;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        ConstraintLayout cl = new ConstraintLayout(this);

        mOkBtn = new Button(this);
        mOkBtn.setText("OK");
        cl.addView(mOkBtn);

        mCancelBtn = new Button(this);
        mCancelBtn.setText("Cancel");
        cl.addView(mCancelBtn);

        ConstraintSet set = new ConstraintSet();

        set.connect(mCancelBtn.getId(), ConstraintSet.BOTTOM, ConstraintSet.PARENT_ID, ConstraintSet.BOTTOM, dpTopx(8));
        set.connect(mCancelBtn.getId(), ConstraintSet.LEFT, ConstraintSet.PARENT_ID, ConstraintSet.LEFT, dpTopx(8));
        set.constrainHeight(mCancelBtn.getId(), ConstraintSet.WRAP_CONTENT);
        set.constrainWidth(mCancelBtn.getId(), ConstraintSet.WRAP_CONTENT);
        
        set.connect(mOkBtn.getId(), ConstraintSet.BOTTOM, ConstraintSet.PARENT_ID, ConstraintSet.BOTTOM, dpTopx(8));
        set.connect(mOkBtn.getId(), ConstraintSet.RIGHT, ConstraintSet.PARENT_ID, ConstraintSet.RIGHT, dpTopx(8));
        set.constrainHeight(mOkBtn.getId(), ConstraintSet.WRAP_CONTENT);
        set.constrainWidth(mOkBtn.getId(), ConstraintSet.WRAP_CONTENT);
        
        set.applyTo(cl);
        setContentView(cl);

    }
}
```

可以看到相比于 xml 代码，Java 代码既繁琐又长，更何况 ConstraintLayout 的出现本来就不推荐手写 xml，在 Android Stuidio 中以直接拖动的方式进行布局操作最少只需要 3 步，

* 拖动控件到界面上
* 设置 id（可省略）
* 选中控件，将控件左边界连接到父空间的左边
* 选中控件，将控件下边界连接到父空间的底部

所以采用代码的方式进行布局，效率反而进一步降低了。除非必要，这并不是一种值的推荐的方式。

## 存在的问题
在进行代码布局的过程中，发现对 view 设置的与父控件的左／右间隔并没有生效，不知道是不是一个已知的 bug，有待进一步深入。

## 总结

初次接触到 ConstraintLayout 时被这种快速便捷的操作方式吸引，意味着可以不用为了实现复杂的布局而进行多层嵌套。顺理成章，当我在自定义控件时第一时刻便想到了它，也就有了这篇简介。其实后来仔细一想这种需求还是比较奇怪，本身 ConstraintLayout 的出现是为了解决 Android 开发中可视化编辑界面的不便，然而偏要选择写 xml 的方式去布局，甚至是 Java code，那就是自找麻烦了。这可能也是为什么官方没有在 Tutorial 中提及而只是在 API Doc 中一笔带过的原因吧。



## 参考资料
1. [Build a Responsive UI with ConstraintLayout | Android Developers][2]
2. [Android新特性介绍，ConstraintLayout完全解析][3]
3. [ConstraintLayout | Android Developers][4]
4. [An Android ConstraintSet Tutorial][5]

[1]:http://p0.meituan.net/xgfe/c0e6f4a512cf2b68c3284e5226201ba135327.png
[2]:https://developer.android.com/training/constraint-layout/index.html
[3]:http://blog.csdn.net/guolin_blog/article/details/53122387
[4]:https://developer.android.com/reference/android/support/constraint/package-summary.html
[5]:http://www.techotopia.com/index.php/An_Android_ConstraintSet_Tutorial