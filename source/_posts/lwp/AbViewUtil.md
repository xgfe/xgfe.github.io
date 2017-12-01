title: AbViewUtil屏幕适配方法
date: 2017-11-30 14:34:30
categories:
- lwp
tags:
- Android
- 适配

---

抛弃 google 提供的 dip 理论与多套图片与布局方案，采用与 UI 设计师通用的 px 作为标准单位，原理是将 UI 设计师的设计图与当前查看的手机或其他设备的屏幕像素尺寸进行换算，得到缩放比例，在 Activity 中装载布局时将所有布局的 px 尺寸进行缩放后设置给布局，就实现了一套尺寸在不同大小的设备上能够按照合理的比例进行缩放，达到万能适配的目的。

<!--more-->

# AbViewUtil 实现屏幕适配

AndroidBase 框架中有个 AbViewUtil 类，可以实现屏幕适配。

## 一、适配原理

Android 推荐使用 dp 作为长度单位，sp 作为字体大小单位，App 运行时会根据屏幕像素密度自动适配。但是这种适配并不适用于平板（大尺寸、小密度）和其他特殊尺寸的屏幕，所以为了适配它们就需要添加额外的布局和尺寸文件。

为了实现一套布局自动适配所有屏幕的目的，可以使用下面的方法。

### 1. 设计图尺寸

根据设计图尺寸，获取布局的基准宽、高。两者使用统一的单位 `px`。

### 2. 布局单位 px

布局文件中各控件的长度单位和 TextView 的字体大小均采用设计图标注的 `px` 作为单位。

### 3. 加载布局

* 将设计图基准尺寸与当前手机屏幕的像素尺寸进行换算，得到缩放比例；
* 在装载布局时，将所有控件的 px 尺寸进行缩放后设置给布局；
* 如果是 TextView 及其子类，还会设置缩放后的字体大小；
* 这样就实现了按照合理的比例进行缩放，达到万能适配的目的。

### 4. 适用场景

* Activity
* Fragment
* Dialog
* PopupWindow

## 二、用法

下面介绍代码方面的使用方法。

### 1. 自定义设计图的屏幕尺寸

例如设计图为 720×1280，则修改 AbViewUtil 类中常量如下：

```
/**
 * UI设计的基准宽度.
 */
public static int UI_WIDTH = 720;

/**
 * UI设计的基准高度.
 */
public static int UI_HEIGHT = 1280;
```

### 2. Activity

需要在 Activity 的 `onCreate()` 方法中添加如下代码：

```
setContentView(R.layout.activity_main);
//根据屏幕分辨率和屏幕密度自定缩放
AbViewUtil.scaleCompat(
    (LinearLayout) findViewById(R.id.act_main_root_layout)
);
```

如果使用了 BaseActivity ，可以重写以下方法，实现子类 Activity 调用 setContentView() 方法时自动缩放布局：

```

/**
 * 使用 {@link AbViewUtil} 处理
 *
 * @param layoutResID
 * @see android.app.Activity#setContentView(int)
 */
@Override
public void setContentView(@LayoutRes int layoutResID) {
    LayoutInflater inflater = LayoutInflater.from(this);
    View root = inflater.inflate(layoutResID, null);
    setContentView(root);
}

/**
 * 使用 {@link AbViewUtil} 处理
 *
 * @param view
 * @see android.app.Activity#setContentView(View)
 */
@Override
public void setContentView(@NonNull View view) {
    super.setContentView(view);
    AbViewUtil.scaleCompat(view);
}

/**
 * 使用 {@link AbViewUtil} 处理
 *
 * @param view
 * @param params
 * @see android.app.Activity#setContentView(View, ViewGroup.LayoutParams)
 */
@Override
public void setContentView(@NonNull View view, ViewGroup.LayoutParams params) {
    super.setContentView(view, params);
    AbViewUtil.scaleCompat(view);
}

/**
 * 使用 {@link AbViewUtil} 处理
 *
 * @param view
 * @param params
 * @see android.app.Activity#addContentView(View, ViewGroup.LayoutParams)
 */
@Override
public void addContentView(@NonNull View view, ViewGroup.LayoutParams params) {
    super.addContentView(view, params);
    AbViewUtil.scaleCompat(view);
}
```

### 3. Fragment

在Fragment的 `onCreateView()` 方法中添加如下内容：

```
inflater = LayoutInflater.from(getActivity());
rootView = inflater.inflate(R.layout.fragment_function, container, false);
AbViewUtil.scaleCompat(rootView);
```

也可以在 `BaseFragment` 中添加如下方法，在子类Fragment的  `onCreateView()` 中调用以获取缩放后的 View：

```
/**
 * 使用 {@link AbViewUtil} 处理
 *
 * @param inflater
 * @param container
 * @param layoutId
 * @return
 */
protected View getContentView(LayoutInflater inflater, @Nullable ViewGroup container, int layoutId) {
    View view = inflater.inflate(layoutId, container, false);
    AbViewUtil.scaleCompat(view);
    return view;
}
```

### 4. Dialog & PopupWindow 等

类似 Dialog 需要传入自定义 View 作为布局的，可以参考如下代码：

```
View view = View.inflate(mContext, layoutResID, null);
AbViewUtil.scaleCompat(view);
dialog.setContentView(view);
```

如果有 BaseDialog ，可以重写下列方法：

```
@Override
public void setContentView(int layoutResID) {
    View view = View.inflate(mContext, layoutResID, null);
    setContentView(view);
}

@Override
public void setContentView(@NonNull View view) {
    super.setContentView(view);
    AbViewUtil.scaleCompat(view);
}

@Override
public void setContentView(@NonNull View view, ViewGroup.LayoutParams params) {
    super.setContentView(view, params);
    AbViewUtil.scaleCompat(view);
}
```

### 5. 注意

布局文件中的宽高和文字大小都统一使用设计图提供的尺寸值，单位统一使用 `px` 。

至此，一个Activity的屏幕适配就完成了。


## 二、源码

最新源码请点击：[AbViewUtil](https://github.com/leowing/commonUtils/blob/master/utils/src/main/java/com/github/leowing/utils/AbViewUtil.java)

示例项目：[Example](https://github.com/leowing/commonUtils/tree/master/example)

