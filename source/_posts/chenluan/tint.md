title: Android 着色器 tint
date: 2019-07-04 13:08:30
categories: chenluan
tags: 
- android
- tint
---

本文主要总结了 Android 着色器的使用及其原理，在实现同等效果的情况下，减少资源图的使用以减小 apk 包的体积并降低对内存的占用。

<!--more-->

# 问题描述
假设我们想实现一种效果，如下：
![](https://raw.githubusercontent.com/bayoh36/images/master/android-tint/target.png)

不怎么友好的做法是让设计师给五张资源图，然后依次排列五个对应的 ImageView。这种做法是存在一些问题的，apk 包体积增加了五张图的大小；程序运行时内存增加了五张图的大小。

这时，我们就可以考虑使用着色器来简单快捷高效地实现这个效果了。

# 实现方式
在 drawable 中导入一张资源图，导入的这张图本身的颜色不用太在意，如下：
![](https://raw.githubusercontent.com/bayoh36/images/master/android-tint/icon.png)

在布局中配置 ImageView，如下：
```xml
<ImageView
    android:layout_width="64dp"
    android:layout_height="64dp"
    android:src="@drawable/icon"
    android:tint="#FF0000"/>
```
其中关键点即是 **android:tint**，这里配置多个 ImageView，**tint** 配置不同的颜色值，就达到了我们的目的，而且没有前述的弊端。

# 实现原理
## Paint & ColorFilter
参考 Android Developer：[ColorFilter](https://developer.android.com/reference/android/graphics/ColorFilter)
颜色过滤器，通过 Paint.setColorFilter 修改渲染某个像素时的颜色值，ColorFilter 有如下一些子类，后续着重介绍一下 PorterDuffColorFilter。

### BlendModeColorFilter
混合模式，在 API Level 29 中添加的，类似于 Android 原生的 PorterDuffXferMode，在 Flutter、CSS中都有一些体现。

### ColorMatrixColorFilter
参考 Android Developer：[ColorMatrix](https://developer.android.com/reference/android/graphics/ColorMatrix.html)
通过一个 4x5 的矩阵与颜色 \[R, G, B, A\] 进行矩阵乘积，得到目标颜色值，可以调整亮度、饱和度、色调等来实现类似 PS 中的滤镜效果，如下：
![](https://raw.githubusercontent.com/bayoh36/images/master/android-tint/color_matrix.png)

### LightingColorFilter
通过颜色的相乘与相加，模拟简单的光照效果。

### PorterDuffColorFilter
使用一个颜色和 PorterDuff 模式对目标进行染色。

#### PorterDuff.Mode
参考 Android Developer：[PorterDuff.Mode](https://developer.android.com/reference/android/graphics/PorterDuff.Mode.html)
假设存在两个形状 SRC 和 DST，其中带颜色的区域的像素点 alpha = 1; color = [red|blue]，其它区域像素点 alpha = 0; color = 0，则它们叠加相交得到 ABCD 4个区，如下：
![](https://raw.githubusercontent.com/bayoh36/images/master/android-tint/composite.png)

通过对 SRC 和 DST 图中的像素值 ARGB 进行数学运算，得到一些裁剪混合叠加效果，展示其中三个如下：
![](https://raw.githubusercontent.com/bayoh36/images/master/android-tint/effect.png)

其中每种模式都有对应的数学公式进行运算，例如 SRC_ATOP 的计算方式，如下：
alpha_out = alpha_dst
color_out = alpha_dst \* color_src + (1 - alpha_src) \* color_dst

对于 AD 区，alpha 的运算结果采用了 DST 的 alpha = 0，所以 AD 区是可不见的，BC 区是可见的，最终结果在形状上表现为 DST 的样子，所以 AD 区的颜色也就没有必要计算了。

对于 B 区的颜色，如下：
color_out = 1 \* 0 + (1 - 0) \* red = red

对于 C 区的颜色，如下：
color_out = 1 \* blue + (1 - 1) \* red = blue

最终分析结果与前述图片表现一致。其它种类模式的公式可以参考 Android Developer。

## BitmapDrawable.setTintList
参考 Android Developer：[BitmapDrawable](https://developer.android.com/reference/android/graphics/drawable/BitmapDrawable.html)

这个方法是在 API Level 21 中添加的，将一个颜色 ColorStateList 设置给 mTintFilter 变量，如下：
```java
private PorterDuffColorFilter mTintFilter;
...

@Override
public void setTintList(ColorStateList tint) {
    final BitmapState state = mBitmapState;
    if (state.mTint != tint) {
        state.mTint = tint;
        mTintFilter = updateTintFilter(mTintFilter, tint, mBitmapState.mTintMode);
        invalidateSelf();
    }
}
```
在渲染的时候，如下：
```java
@Override
public void draw(Canvas canvas) {
    ...
    final boolean clearColorFilter;
    if (mTintFilter != null && paint.getColorFilter() == null) {
        paint.setColorFilter(mTintFilter);
        clearColorFilter = true;
    } else {
        clearColorFilter = false;
    }
    ...
}
```
将这个 PorterDuffColorFilter 交给了 Paint 进行处理。

## ImageView_tint
ImageView 在使用 tint 属性的时候，如下：
```java
private void applyImageTint() {
    if (mDrawable != null && (mHasDrawableTint || mHasDrawableTintMode)) {
        ...
        if (mHasDrawableTint) {
            mDrawable.setTintList(mDrawableTintList);
        }

        if (mHasDrawableTintMode) {
            mDrawable.setTintMode(mDrawableTintMode);
        }
        ...
    }
}
```

这样我们从 ImageView 的 tint 属性到 Paint 的使用，过程如下：
- ImageView 读取到 tint 属性之后，将 tint color 和 tint mode 设置给 Drawable
- Drawable 将 tint color 和 tint mode 组装成 PorterDuffColorFilter
- Drawable 在渲染的时候，将 PorterDuffColorFilter 设置给 Paint
- Paint 将效果应用到画布上

## ImageView_tintMode
ImageView 在使用 tint 属性的时候，也可以配置 tintMode 属性，如下：
- add
- multiply
- screen
- src_atop
- src_in
- src_over

Drawable 的默认 tint mode 是 SRC_IN，如下：
```java
public abstract class Drawable {
    ...
    static final PorterDuff.Mode DEFAULT_TINT_MODE = PorterDuff.Mode.SRC_IN;
    ...
}
```

ImageView 的默认 tint mode 是 SRC_ATOP，如下：
```java
if (a.hasValue(R.styleable.ImageView_tint)) {
    mDrawableTintList = a.getColorStateList(R.styleable.ImageView_tint);
    mHasDrawableTint = true;

    // Prior to L, this attribute would always set a color filter with
    // blending mode SRC_ATOP. Preserve that default behavior.
    mDrawableTintMode = PorterDuff.Mode.SRC_ATOP;
    mHasDrawableTintMode = true;
}
```

因为 PorterDuff 对应的 SRC 默认是一个铺满 DST 宽高的颜色值，所以 SRC_IN 和 SRC_ATOP 效果上是一样的。
布局 xml 中只提供了6中模式，若想使用其它 PorterDuff 模式也可以，需要用 Java 代码去实现。

# 使用进阶
## Drawable.setTintList
tint 不仅仅只是 BitmapDrawable 可以使用，setTintList 在 API Level 21 中被添加到 Drawable 中，所以 Drawable 子类都可以使用，如下：
- BitmapDrawable
- NinePatchDrawable
- LayerDrawable
- StateListDrawable
- LevelListDrawable
- TransitionDrawable
- InsetDrawable
- ClipDrawable
- ScaleDrawable
- ShapeDrawable
- GradientDrawable
- AnimationDrawable
- VectorDrawable

其中有一些 Drawable 可以在布局 xml 中配置 tint，如下：

BitmapDrawable
```xml
<?xml version="1.0" encoding="utf-8"?>
<bitmap xmlns:android="http://schemas.android.com/apk/res/android"
    android:src="@drawable/icon"
    android:tint="#FF0000">
</bitmap>
```

NinePatchDrawable
```xml
<nine-patch xmlns:android="http://schemas.android.com/apk/res/android"
    android:src="@drawable/icon"
    android:tint="#FF0000">
</nine-patch>
```

ShapeDrawable
```xml
<?xml version="1.0" encoding="utf-8"?>
<shape xmlns:android="http://schemas.android.com/apk/res/android"
    android:tint="#FF0000">
</shape>
```

VectorDrawable
```xml
<?xml version="1.0" encoding="utf-8"?>
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:tint="#FF0000">
</vector>
```

## ColorStateList
我们可以在 xml 中配置一个 ColorStateList，如下：
```xml
<?xml version="1.0" encoding="utf-8"?>
<selector xmlns:android="http://schemas.android.com/apk/res/android">
    <item android:color="#FF0000" android:state_pressed="true"/>
    <item android:color="#00FF00"/>
</selector>
```
然后将这个 ColorStateList 设置给 ImageView，如下：
```xml
<ImageView
    android:layout_width="64dp"
    android:layout_height="64dp"
    android:src="@drawable/icon"
    android:tint="@color/state_color"/>
```
这样当这个 ImageView 被点击的时候，颜色就可以被改变。

当然还有一种方式可以实现这种效果，使用 xml 配置两个 bitmap，如下：
```xml
<?xml version="1.0" encoding="utf-8"?>
<bitmap xmlns:android="http://schemas.android.com/apk/res/android"
    android:src="@drawable/icon"
    android:tint="#FF0000">
</bitmap>
```
然后配置一个 selector，如下：
```xml
<?xml version="1.0" encoding="utf-8"?>
<selector xmlns:android="http://schemas.android.com/apk/res/android">
    <item android:drawable="@drawable/icon_pressed" android:state_pressed="true"/>
    <item android:drawable="@drawable/icon_normal"/>
</selector>
```
随后将这个 selector 设置给 ImageView。这种方式占用了更多的内存，因为 BitmapDrawable 在 inflate 的时候直接从输入流读取文件的，没有进行图片重用，如下：
```java
public class BitmapDrawable extends Drawable {
    ...
    @Override
    public void inflate(Resources r, XmlPullParser parser, AttributeSet attrs, Theme theme)
            throws XmlPullParserException, IOException {
        super.inflate(r, parser, attrs, theme);
        ...
        Bitmap bitmap = null;
        try (InputStream is = r.openRawResource(srcResId, value)) {
            bitmap = BitmapFactory.decodeResourceStream(r, value, is, null, null);
        } catch (Exception e) {
            // Do nothing and pick up the error below.
        }
        ...
    }
}
```

## 组合使用
基于前述几种使用方式，我们就可以将 LevelListDrawable、LayerDrawable、StateListDrawable、BitmapDrawable 组合在一起，这就可以有无限的组合方式了。

## 在 View 中配置 tint
除了前述 ImageView 中可以配置 tint 外，View 也可以对前景和背景配置 tint，如下：
```xml
<View
    android:layout_width="wrap_content"
    android:layout_height="wrap_content"
    android:backgroundTint="#FF0000"
    android:foregroundTint="#00FF00"/>
```

TextView 也可以配置 drawable tint，如下：
```xml
<TextView
    android:layout_width="wrap_content"
    android:layout_height="wrap_content"
    android:drawableTint="#FF0000"/>
```

CompoundButton 也可以配置 button tint，所以 CheckBox、RadioButton 等也可以配置 button tint，如下：
```xml
<CheckBox
    android:layout_width="wrap_content"
    android:layout_height="wrap_content"
    android:drawableTint="#FF0000"
    android:buttonTint="#FF0000"/>
```

## Compatible
### ViewCompat
由于 API Level 21 才开始支持 background tint 在 xml 中配置，可以使用 ViewCompat.setBackgroundTintList 和 ViewCompat.setBackgroundTintMode 进行兼容。

如果我们想在自定义 View 中也实现 tint 的一些特性，可以让自定义 View 实现 TintableBackgroundView 接口，然后调用 ViewCompat.setBackgroundTintList 进行设置，这样就能对 API Level 21 之前的版本进行兼容。

ViewCompat 的相关实现，如下：
```java
static final ViewCompatBaseImpl IMPL;
static {
    if (Build.VERSION.SDK_INT >= 26) {
        IMPL = new ViewCompatApi26Impl();
    } else if (Build.VERSION.SDK_INT >= 24) {
        IMPL = new ViewCompatApi24Impl();
    ...
    } else {
        IMPL = new ViewCompatBaseImpl();
    }
}

public static void setBackgroundTintList(View view, ColorStateList tintList) {
    IMPL.setBackgroundTintList(view, tintList);
}

static class ViewCompatApi21Impl extends ViewCompatApi19Impl {
    ...
    @Override
    public void setBackgroundTintList(View view, ColorStateList tintList) {
        view.setBackgroundTintList(tintList);

        if (Build.VERSION.SDK_INT == 21) {
            // Work around a bug in L that did not update the state of the background
            // after applying the tint
            Drawable background = view.getBackground();
            boolean hasTint = (view.getBackgroundTintList() != null)
                    && (view.getBackgroundTintMode() != null);
            if ((background != null) && hasTint) {
                if (background.isStateful()) {
                    background.setState(view.getDrawableState());
                }
                view.setBackground(background);
            }
        }
    }
    ...
}

static class ViewCompatBaseImpl {
    ...
    public void setBackgroundTintList(View view, ColorStateList tintList) {
        if (view instanceof TintableBackgroundView) {
            ((TintableBackgroundView) view).setSupportBackgroundTintList(tintList);
        }
    }
    ...
}
```

### DrawableCompat
由于 API Level 21 才开始支持对 drawable 设置 tint，可以使用 DrawableCompat.setTintList，如下：
```java
public static void setTintList(@NonNull Drawable drawable, @Nullable ColorStateList tint) {
    if (VERSION.SDK_INT >= 21) {
        drawable.setTintList(tint);
    } else if (drawable instanceof TintAwareDrawable) {
        ((TintAwareDrawable)drawable).setTintList(tint);
    }
}
```

可以使用 DrawableCompat.wrap 对 drawable 进行包装兼容，如下：
```java
public static Drawable wrap(@NonNull Drawable drawable) {
    if (Build.VERSION.SDK_INT >= 23) {
        return drawable;
    } else if (Build.VERSION.SDK_INT >= 21) {
        if (!(drawable instanceof TintAwareDrawable)) {
            return new DrawableWrapperApi21(drawable);
        }
        return drawable;
    } else if (Build.VERSION.SDK_INT >= 19) {
        if (!(drawable instanceof TintAwareDrawable)) {
            return new DrawableWrapperApi19(drawable);
        }
        return drawable;
    } else {
        if (!(drawable instanceof TintAwareDrawable)) {
            return new DrawableWrapperApi14(drawable);
        }
        return drawable;
    }
}
```

## 使用场景
- 多图并列显示，用颜色来区分类别，图的形状是一样的
- 简单的按钮普通、按下、置灰等状态切换
- 换肤换主题