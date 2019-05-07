title: Android Zxing 扫码封装
date: 2018-3-20 10:49:30
categories:
- Catherine
tags:
- android
- Zxing

---


Zxing 是一个开放源码的，用 Java 实现的多种格式的 1D/2D 条码图像处理库，它包含了联系到其他语言的端口。Zxing 可以实现使用手机的内置的摄像头完成条形码的扫描及解码。

<!--More-->

## 一、条码码型

Zxing 目前支持扫描和解析以下码型：

| 码型 | 中文名 | 维度 | 字符类型 |
| --- | --- | --- | --- |
| AZTEC | 阿兹特克码 | 2D | ASCII  |
| CODABAR | 库德巴码 | 1D | 数字、字母  |
| CODE_39 | 39码 | 1D | (0-9)10个数字、“ABCD”四个字母和“$-:/.+”六个特殊字符  |
| CODE_93 | 93码 | 1D | (0-9)10个数字、“ABCD”四个字母和“$-:/.+”六个特殊字符  |
| CODE_128 | 128码 | 1D | ASCII |
| DATA_MATRIX | Matrix 25码 | 2D | 任意字符  |
| EAN_8 | EAN商品码 | 1D | 数字  |
| EAN_13 | EAN商品码 | 1D | 数字  |
| ITF | 交插25码 | 1D | 数字  |
| MAXICODE | UPC快递码 | 2D | ASCII  |
| PDF_417 | PDF417 | 2D | 扩展的字母数字压缩格式、二进制 、ASCII、数字压缩格式  |
| QR_CODE | 二维条码 | 2D | 任意字符  |
| RSS_14 | RSS码 | 1D+2D | 数字  |
| RSS_EXPANDED | RSS码 | 1D+2D | 数字  |
| UPC_A | UPC美国码 | 1D | 数字 |
| UPC_E | UPC美国码 | 1D | 数字  |
| UPC_EAN_EXTENSION | EAN/UPC混合码 | 1D | 数字  |

在 `build.gradle` 中引入依赖：

```
implementation "com.google.zxing:core:${zxingCoreVer}"
implementation "com.google.zxing:android-core:${zxingAndroidVer}"
implementation "com.google.zxing:android-integration:${zxingAndroidVer}"
```

引入依赖后即可使用 Zxing 的解码库，对条形码或二维码进行解析，但是需要封装扫码界面、取图流程和解析后的数据返回，才能方便 Android 应用中使用。为此，我们封装了整个扫码和解析的组件库，使得 Android 应用中仅需关注布局的构建。

## 二、CaptureActivity 界面部分封装

`CaptureActivity` 是一个抽象类，继承于 `AppCompatActivity` ，这个Activity不包含界面，所以其子类需要在 `onCreate()` 中设置布局。

`CaptureActivity` 中有多个抽象方法：

* boolean getResult(Result, byte[]) : 每次扫码结束后会调用此方法，实现类可以从参数中获取扫码结果；
* SurfaceView getScanPreview() : 子类 Activity 需要自定义布局，可实现此方法，返回自定义布局中的 `SurfaceView` 对象；
* View getCropView() : 返回子类自定义布局中的扫码框 View，用于裁剪取图图片。

`CaptureActivity` 中封装了扫码的流程，包括：

1. 摄像头预览：通过 `SurfaceView` 和 `Camera` 的初始化，在界面中显示摄像头的预览画面；
2. 自动取图：通过定时获取 `SurfaceView` 预览图片的方式，得到预览图的二进制数据，然后裁剪出扫码框中部分；
3. 解析：通过 Zxing Core 解析图片的二进制数据，获取解析结果；
4. 封装解析结果：结果包含一个字符串、一个图片二进制数组、条码位置数组，封装为 `Result` 对象；
5. 界面接收结果：通过抽象方法 `boolean getResult(Result, byte[])` ，将结果返回给子类 Activity 。

另外，此抽象类中还封装了扫码界面中常用闪光灯开关方法，并且封装了适配 Android 6.0 的动态权限申请。

### 2.1 摄像头预览

为了在界面中显示摄像头预览画面，需要子类 Activity 提供布局中的 `SurfaceView` 对象，即可在 Activity 生命周期中处理其初始化和销毁：

* 完成 `SurfaceView` 的初始化后，打开 `Camera` 获取摄像头数据显示预览画面；
* 在 Activity 暂停时，停止预览，释放 `Camera` 资源；
* 在 Activity 重新显示时，重新初始化。

### 2.2 自动取图

取图，即获取 `SurfaceView` 预览画面的一帧图片。为 `SurfaceView` 设置取图回调，即可在请求取图后，获取到此刻一帧图像的二进制数据。

自动取图的实现方式有很多种：

1. 自动对焦方式，启动摄像头的自动对焦功能，在每次对焦成功的回调中执行取图。这种取图方式依赖自动对焦，在极端情况下可能无法对焦，或者对焦时间较长，造成扫码速度降低。
2. 定时取图方式，需要开启定时任务，每隔一定时间请求取图方法。这种取图方法的取图间隔是固定的，可以提高取图速度，但是在解析速度较慢的手机上可能出现解析未完成而再次取图的情况，造成混乱。
3. 线性取图方式，即完成“取图——解析——取图”的线性操作，取图和解析都是由我们自己的代码请求的，这样可以完全控制整个操作流程，避免了定时取图的弊端；因为不需要在完成对焦后再取图，我们可以通过控制延迟时间控制取图速度。

建议使用线性取图方式，以完全控制取图速度和取图过程，也可以在子类 Activity 获取到结果后，自由控制继续取图或暂停取图。

### 2.3 解析图片

解析取图数据的过程由 zxing:core 库完成。

具体解析原理代码较多，此处不详述，代码在 `com.google.zxing.MultiFormatReader` 中。

### 2.4 结果封装

`com.google.zxing.Result` 类中定义了扫码结果。

* String text: 即上一步解析出来的字符串；
* byte[] rawBytes: 图片的二进制数据；
* ResultPoint[] resultPoints: 一个或多个关键点，可以用于在界面中标出条码位置；
* BarcodeFormat format: 条码的码型；
* long timestamp: 时间戳。

以上数据，可以帮助我们获取扫码结果和展示友好的界面。

## 三、预览和摄像头

我们将摄像头预览相关的操作，封装在 `camera` 包中，关键类有：

* CameraManager：控制摄像头的开启和关闭；
* CameraConfigurationManager：设置摄像头和预览的参数；
* AutoFocusManager：控制摄像头的自动对焦。

## 四、图片解析

我们将图片解析相关的操作，封装在 `decode` 包中，关键类有：

* DecodeHandler: 从摄像头获取的原始二进制数据是 YUV 格式，我们在此类中将其转换为 `Bitmap` ，然后发送到 zxing:core 库解析；
* DecodeThread: 解析图片是耗时操作，所以需要在非 UI 线程中进行。

在 `DecodeThread` 类中，我们定义了多种码型组合，例如所有条形码、条形码与二维码、CODE128与二维码等，以满足不同业务场景。在 `CaptureActivity` 中定义了方法 `int getBarcodeMode()`，可以在子类中重写，即可定义应用需要的码型。

> 注意：支持的码型数量越多，解析速度越慢；二维码的解析速度大大慢于一维码的解析速度。

## 五、App 中实现扫码界面

在依赖以上组件库后，即可快速实现扫码功能，在 App 开发中仅需自定义界面即可。

我们首先继承 `CaptureActivity` ，创建 `MyScanActivity` 和布局文件 `activity_my_scan.xml`

MyScanActivity.java:

```java
public class MyScanActivity extends CaptureActivity {

    private SurfaceView mPreviewSv;
    private View mCropView;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_my_scan);
        mPreviewSv = findViewById(R.id.scan_preview);
        mCropView = findViewById(R.id.scan_crop);
    }

    /**
     * 获取扫码结果
     *
     * @param result 扫码结果
     * @param bytes  图片二进制数组
     * @return true - 继续扫描；false - 暂停扫描
     */
    @Override
    protected boolean getResult(Result result, byte[] bytes) {
        if (result == null || TextUtils.isEmpty(result.getText()))
            return true;
        return false;
    }

    @NonNull
    @Override
    protected SurfaceView getScanPreview() {
        return mPreviewSv;
    }

    @NonNull
    @Override
    protected View getCropView() {
        return mCropView;
    }
}
```

activity_my_scan.xml:

```xml
<?xml version="1.0" encoding="utf-8"?>
<FrameLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent"
    android:layout_height="match_parent">

    <SurfaceView
        android:id="@+id/scan_preview"
        android:layout_width="match_parent"
        android:layout_height="match_parent" />

    <View
        android:id="@+id/scan_crop"
        android:layout_width="300dp"
        android:layout_height="200dp"
        android:layout_gravity="center"
        android:background="#33ffffff" />

</FrameLayout>
```

> 以上仅仅是实现扫码界面的最简单代码，如果需要更好的界面效果，还需要修改布局和获取结果后的逻辑。

至此，我们就快速实现了扫码页面的功能。

