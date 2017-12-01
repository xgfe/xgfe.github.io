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

根据设计图尺寸，获取布局的基准宽、高。两者使用统一的单位 px。

### 2. 布局单位 px

布局文件中各控件的长度单位和 TextView 的字体大小采用与 UI 设计师通用的 px 作为标准单位。

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

> 源码来自 [AndroidBase](https://github.com/ryantaoyf/AndroidBase/blob/master/AndBase/src/com/ab/util/AbViewUtil.java)，在原调用方法 `void scaleContentView(ViewGroup contentView)` 和 `void scaleView(View view)` 的基础上，添加了 `void scaleCompat(View view)` ，实现自动判断参数 `view` 是否为 `ViewGroup` 类型。

```
/*
 * Copyright (C) 2012 www.amsoft.cn
 * 
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package ab.utils;

import android.content.Context;
import android.content.res.Resources;
import android.graphics.Paint;
import android.text.TextPaint;
import android.text.TextUtils;
import android.util.DisplayMetrics;
import android.util.TypedValue;
import android.view.View;
import android.view.View.MeasureSpec;
import android.view.ViewGroup;
import android.view.ViewGroup.MarginLayoutParams;
import android.view.ViewParent;
import android.widget.AbsListView;
import android.widget.GridView;
import android.widget.ListAdapter;
import android.widget.ListView;
import android.widget.TextView;

/**
 * © 2012 amsoft.cn
 * 名称：AbViewUtil.java
 * 描述：View工具类.
 *
 * @author 还如一梦中
 * @version v1.0
 * @date：2013-01-17 下午11:52:13
 */

public class AbViewUtil {

    public static final String TAG = AbViewUtil.class.getSimpleName();

    /**
     * UI设计的基准宽度.
     */
    public static int UI_WIDTH = 720;

    /**
     * UI设计的基准高度.
     */
    public static int UI_HEIGHT = 1280;
    /**
     * 无效值
     */
    public static final int INVALID = Integer.MIN_VALUE;

    /**
     * 描述：重置AbsListView的高度. item 的最外层布局要用
     * RelativeLayout,如果计算的不准，就为RelativeLayout指定一个高度
     *
     * @param absListView   the abs list view
     * @param lineNumber    每行几个 ListView一行一个item
     * @param verticalSpace the vertical space
     */
    public static void setAbsListViewHeight(AbsListView absListView, int lineNumber, int verticalSpace) {
        int totalHeight = getAbsListViewHeight(absListView, lineNumber, verticalSpace);
        ViewGroup.LayoutParams params = absListView.getLayoutParams();
        params.height = totalHeight;
        ((MarginLayoutParams)params).setMargins(0, 0, 0, 0);
        absListView.setLayoutParams(params);
    }

    /**
     * 描述：获取AbsListView的高度.
     *
     * @param absListView   the abs list view
     * @param lineNumber    每行几个 ListView一行一个item
     * @param verticalSpace the vertical space
     * @return the abs list view height
     */
    public static int getAbsListViewHeight(AbsListView absListView, int lineNumber, int verticalSpace) {
        int totalHeight = 0;
        int w = View.MeasureSpec.makeMeasureSpec(0, View.MeasureSpec.UNSPECIFIED);
        int h = View.MeasureSpec.makeMeasureSpec(0, View.MeasureSpec.UNSPECIFIED);
        absListView.measure(w, h);
        ListAdapter mListAdapter = absListView.getAdapter();
        if (mListAdapter == null) {
            return totalHeight;
        }

        int count = mListAdapter.getCount();
        if (absListView instanceof ListView) {
            for (int i = 0; i < count; i++) {
                View listItem = mListAdapter.getView(i, null, absListView);
                listItem.measure(w, h);
                totalHeight += listItem.getMeasuredHeight();
            }
            if (count == 0) {
                totalHeight = verticalSpace;
            } else {
                totalHeight = totalHeight + (((ListView)absListView).getDividerHeight() * (count - 1));
            }

        } else if (absListView instanceof GridView) {
            int remain = count % lineNumber;
            if (remain > 0) {
                remain = 1;
            }
            if (mListAdapter.getCount() == 0) {
                totalHeight = verticalSpace;
            } else {
                View listItem = mListAdapter.getView(0, null, absListView);
                listItem.measure(w, h);
                int line = count / lineNumber + remain;
                totalHeight = line * listItem.getMeasuredHeight() + (line - 1) * verticalSpace;
            }

        }
        return totalHeight;

    }

    /**
     * 测量这个view
     * 最后通过getMeasuredWidth()获取宽度和高度.
     *
     * @param view 要测量的view
     * @return 测量过的view
     */
    public static void measureView(View view) {
        ViewGroup.LayoutParams p = view.getLayoutParams();
        if (p == null) {
            p = new ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);
        }

        int childWidthSpec = ViewGroup.getChildMeasureSpec(0, 0 + 0, p.width);
        int lpHeight = p.height;
        int childHeightSpec;
        if (lpHeight > 0) {
            childHeightSpec = MeasureSpec.makeMeasureSpec(lpHeight, MeasureSpec.EXACTLY);
        } else {
            childHeightSpec = MeasureSpec.makeMeasureSpec(0, MeasureSpec.UNSPECIFIED);
        }
        view.measure(childWidthSpec, childHeightSpec);
    }

    /**
     * 获得这个View的宽度
     * 测量这个view，最后通过getMeasuredWidth()获取宽度.
     *
     * @param view 要测量的view
     * @return 测量过的view的宽度
     */
    public static int getViewWidth(View view) {
        measureView(view);
        return view.getMeasuredWidth();
    }

    /**
     * 获得这个View的高度
     * 测量这个view，最后通过getMeasuredHeight()获取高度.
     *
     * @param view 要测量的view
     * @return 测量过的view的高度
     */
    public static int getViewHeight(View view) {
        measureView(view);
        return view.getMeasuredHeight();
    }

    /**
     * 从父亲布局中移除自己
     *
     * @param v
     */
    public static void removeSelfFromParent(View v) {
        ViewParent parent = v.getParent();
        if (parent != null) {
            if (parent instanceof ViewGroup) {
                ((ViewGroup)parent).removeView(v);
            }
        }
    }

    /**
     * 描述：dip转换为px.
     *
     * @param context  the context
     * @param dipValue the dip value
     * @return px值
     */
    public static float dip2px(Context context, float dipValue) {
        DisplayMetrics mDisplayMetrics = getDisplayMetrics(context);
        return applyDimension(TypedValue.COMPLEX_UNIT_DIP, dipValue, mDisplayMetrics);
    }

    /**
     * 描述：px转换为dip.
     *
     * @param context the context
     * @param pxValue the px value
     * @return dip值
     */
    public static float px2dip(Context context, float pxValue) {
        DisplayMetrics mDisplayMetrics = getDisplayMetrics(context);
        return pxValue / mDisplayMetrics.density;
    }

    /**
     * 描述：sp转换为px.
     *
     * @param context the context
     * @param spValue the sp value
     * @return sp值
     */
    public static float sp2px(Context context, float spValue) {
        DisplayMetrics mDisplayMetrics = getDisplayMetrics(context);
        return applyDimension(TypedValue.COMPLEX_UNIT_SP, spValue, mDisplayMetrics);
    }

    /**
     * 描述：px转换为sp.
     *
     * @param context the context
     * @param pxValue the px value
     * @return sp值
     */
    public static float px2sp(Context context, float pxValue) {
        DisplayMetrics mDisplayMetrics = getDisplayMetrics(context);
        return pxValue / mDisplayMetrics.scaledDensity;
    }

    /**
     * 描述：根据屏幕大小缩放.
     *
     * @param context the context
     * @param value   the px value
     * @return the int
     */
    public static int scale(Context context, float value) {
        DisplayMetrics mDisplayMetrics = getDisplayMetrics(context);
        return scale(mDisplayMetrics.widthPixels, mDisplayMetrics.heightPixels, value);
    }

    /**
     * 描述：根据屏幕大小缩放.
     *
     * @param displayWidth  the display width
     * @param displayHeight the display height
     * @param pxValue       the px value
     * @return the int
     */
    public static int scale(int displayWidth, int displayHeight, float pxValue) {
        if (pxValue == 0) {
            return 0;
        }
        float scale = 1;
        try {
            float scaleWidth = (float)displayWidth / UI_WIDTH;
            float scaleHeight = (float)displayHeight / UI_HEIGHT;
            scale = Math.min(scaleWidth, scaleHeight);
        } catch (Exception ignored) {
        }
        return Math.round(pxValue * scale + 0.5f);
    }

    /**
     * TypedValue官方源码中的算法，任意单位转换为PX单位
     *
     * @param unit    TypedValue.COMPLEX_UNIT_DIP
     * @param value   对应单位的值
     * @param metrics 密度
     * @return px值
     */
    public static float applyDimension(int unit, float value, DisplayMetrics metrics) {
        switch (unit) {
            case TypedValue.COMPLEX_UNIT_PX:
                return value;
            case TypedValue.COMPLEX_UNIT_DIP:
                return value * metrics.density;
            case TypedValue.COMPLEX_UNIT_SP:
                return value * metrics.scaledDensity;
            case TypedValue.COMPLEX_UNIT_PT:
                return value * metrics.xdpi * (1.0f / 72);
            case TypedValue.COMPLEX_UNIT_IN:
                return value * metrics.xdpi;
            case TypedValue.COMPLEX_UNIT_MM:
                return value * metrics.xdpi * (1.0f / 25.4f);
        }
        return 0;
    }

    /**
     * 描述：View树递归调用做适配.
     * AbAppConfig.uiWidth = 1080;
     * AbAppConfig.uiHeight = 700;
     * scaleContentView((RelativeLayout)findViewById(R.id.rootLayout));
     * 要求布局中的单位都用px并且和美工的设计图尺寸一致，包括所有宽高，Padding,Margin,文字大小
     *
     * @param contentView
     */
    public static void scaleContentView(ViewGroup contentView) {
        AbViewUtil.scaleView(contentView);
        if (contentView.getChildCount() > 0) {
            for (int i = 0; i < contentView.getChildCount(); i++) {
                if (contentView.getChildAt(i) instanceof ViewGroup) {
                    scaleContentView((ViewGroup)(contentView.getChildAt(i)));
                } else {
                    scaleView(contentView.getChildAt(i));
                }
            }
        }
    }

    /**
     * 按比例缩放View，以布局中的尺寸为基准
     *
     * @param view
     */
    public static void scaleView(View view) {
        // 设置 View 的 TAG 为 disable_scale，禁用缩放
        if (TextUtils.equals(String.valueOf(view.getTag()), "disable_scale")) {
            return;
        }
        if (view instanceof TextView) {
            TextView textView = (TextView)view;
            setTextSize(textView, textView.getTextSize());
        }

        ViewGroup.LayoutParams params = view.getLayoutParams();
        if (null != params) {
            int width = INVALID;
            int height = INVALID;
            if (params.width != ViewGroup.LayoutParams.WRAP_CONTENT && params.width != ViewGroup.LayoutParams.MATCH_PARENT) {
                width = params.width;
            }

            if (params.height != ViewGroup.LayoutParams.WRAP_CONTENT && params.height != ViewGroup.LayoutParams.MATCH_PARENT) {
                height = params.height;
            }

            //size
            setViewSize(view, width, height);

            // Padding
            setPadding(view, view.getPaddingLeft(), view.getPaddingTop(), view.getPaddingRight(), view.getPaddingBottom());
        }

        // Margin
        if (view.getLayoutParams() instanceof ViewGroup.MarginLayoutParams) {
            ViewGroup.MarginLayoutParams mMarginLayoutParams = (ViewGroup.MarginLayoutParams)view.getLayoutParams();
            if (mMarginLayoutParams != null) {
                setMargin(view, mMarginLayoutParams.leftMargin, mMarginLayoutParams.topMargin, mMarginLayoutParams.rightMargin,
                    mMarginLayoutParams.bottomMargin);
            }
        }

    }

    /**
     * 缩放文字大小
     *
     * @param textView button
     * @param size     sp值
     * @return
     */
    public static void setSPTextSize(TextView textView, float size) {
        float scaledSize = scale(textView.getContext(), size);
        textView.setTextSize(scaledSize);
    }

    /**
     * 缩放文字大小,这样设置的好处是文字的大小不和密度有关，
     * 能够使文字大小在不同的屏幕上显示比例正确
     *
     * @param textView   button
     * @param sizePixels px值
     * @return
     */
    public static void setTextSize(TextView textView, float sizePixels) {
        float scaledSize = scale(textView.getContext(), sizePixels);
        textView.setTextSize(TypedValue.COMPLEX_UNIT_PX, scaledSize);
    }

    /**
     * 缩放文字大小
     *
     * @param context
     * @param textPaint
     * @param sizePixels px值
     * @return
     */
    public static void setTextSize(Context context, TextPaint textPaint, float sizePixels) {
        float scaledSize = scale(context, sizePixels);
        textPaint.setTextSize(scaledSize);
    }

    /**
     * 缩放文字大小
     *
     * @param context
     * @param paint
     * @param sizePixels px值
     * @return
     */
    public static void setTextSize(Context context, Paint paint, float sizePixels) {
        float scaledSize = scale(context, sizePixels);
        paint.setTextSize(scaledSize);
    }

    /**
     * 设置View的PX尺寸
     *
     * @param view         如果是代码new出来的View，需要设置一个适合的LayoutParams
     * @param widthPixels
     * @param heightPixels
     */
    public static void setViewSize(View view, int widthPixels, int heightPixels) {
        int scaledWidth = scale(view.getContext(), widthPixels);
        int scaledHeight = scale(view.getContext(), heightPixels);
        ViewGroup.LayoutParams params = view.getLayoutParams();
        if (params == null) {
            LogUtils.error(TAG, "setViewSize出错,如果是代码new出来的View，需要设置一个适合的LayoutParams");
            return;
        }
        if (widthPixels != INVALID) {
            params.width = scaledWidth;
        }
        if (heightPixels != INVALID) {
            params.height = scaledHeight;
        }
        view.setLayoutParams(params);
    }

    /**
     * 设置PX padding.
     *
     * @param view   the view
     * @param left   the left padding in pixels
     * @param top    the top padding in pixels
     * @param right  the right padding in pixels
     * @param bottom the bottom padding in pixels
     */
    public static void setPadding(View view, int left, int top, int right, int bottom) {
        int scaledLeft = scale(view.getContext(), left);
        int scaledTop = scale(view.getContext(), top);
        int scaledRight = scale(view.getContext(), right);
        int scaledBottom = scale(view.getContext(), bottom);
        view.setPadding(scaledLeft, scaledTop, scaledRight, scaledBottom);
    }

    /**
     * 设置 PX margin.
     *
     * @param view   the view
     * @param left   the left margin in pixels
     * @param top    the top margin in pixels
     * @param right  the right margin in pixels
     * @param bottom the bottom margin in pixels
     */
    public static void setMargin(View view, int left, int top, int right, int bottom) {
        int scaledLeft = scale(view.getContext(), left);
        int scaledTop = scale(view.getContext(), top);
        int scaledRight = scale(view.getContext(), right);
        int scaledBottom = scale(view.getContext(), bottom);

        if (view.getLayoutParams() instanceof ViewGroup.MarginLayoutParams) {
            ViewGroup.MarginLayoutParams mMarginLayoutParams = (ViewGroup.MarginLayoutParams)view.getLayoutParams();
            if (mMarginLayoutParams != null) {
                if (left != INVALID) {
                    mMarginLayoutParams.leftMargin = scaledLeft;
                }
                if (right != INVALID) {
                    mMarginLayoutParams.rightMargin = scaledRight;
                }
                if (top != INVALID) {
                    mMarginLayoutParams.topMargin = scaledTop;
                }
                if (bottom != INVALID) {
                    mMarginLayoutParams.bottomMargin = scaledBottom;
                }
                view.setLayoutParams(mMarginLayoutParams);
            }
        }

    }

    /**
     * 获取屏幕尺寸与密度.
     *
     * @param context the context
     * @return mDisplayMetrics
     */
    public static DisplayMetrics getDisplayMetrics(Context context) {
        Resources mResources;
        if (context == null) {
            mResources = Resources.getSystem();

        } else {
            mResources = context.getResources();
        }
        //DisplayMetrics{density=1.5, width=480, height=854, scaledDensity=1.5, xdpi=160.421, ydpi=159.497}
        //DisplayMetrics{density=2.0, width=720, height=1280, scaledDensity=2.0, xdpi=160.42105, ydpi=160.15764}
        DisplayMetrics mDisplayMetrics = mResources.getDisplayMetrics();
        return mDisplayMetrics;
    }

    /**
     * 自动判断 view 的类型
     *
     * @param view
     */
    public static void scaleCompat(View view) {
        if (view instanceof ViewGroup)
            scaleContentView((ViewGroup)view);
        else
            scaleView(view);
    }
}
```


