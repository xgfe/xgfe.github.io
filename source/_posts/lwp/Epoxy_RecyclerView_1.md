title: Epoxy：构建复杂页面的框架（一）
date: 2018-01-04 14:13:36
categories:
- lwp
tags:
- Android
- Epoxy

---

本文仅从宏观上介绍了 Epoxy 的特色和优势，并说明了基本使用步骤。

Epoxy 是由 Airbnb 团队开发的 ，以简化使用 `RecyclerView` 的过程，并添加了必要的缺失功能。Airbnb 在他们的应用中的大部分页面上使用 Epoxy ，这大大提高了开发人员的经验。

<!--more-->

Epoxy（环氧树脂）是一个Android库，用于在 `RecyclerView` 中构建复杂的页面。界面模型是通过自定义视图、数据绑定布局或 Litho 组件通过注释处理自动生成的。这些模型会在 `EpoxyController` 中用于声明在 `RecyclerView` 中显示哪些项目。

这将抽象化 `ViewHolder` 的样板，区分项目和绑定有效负载变化，项目类型，项目ID，跨度计数等等，以简化具有多种视图类型的构建屏幕。此外，Epoxy 增加了对保存视图状态和自动比较项目变化的支持。

## Epoxy 的特点

Android 中的 RecyclerView 是一个显示列表的强大工具，但是它的用法比较琐碎。显示复杂度高的列表是我们团队的一个常用需求，比如具有多种视图类型，分页功能，支持平板和 item 动画的列表。我们发现自己总是不断的重复相同的设置。所以 Airbnb 开发了 Epoxy 来减轻这个趋势，以简化基于列表的视图的创建，加载静态或者动态的内容。

Epoxy 采用可组合的方式来创建列表。列表中的每个 item 由一个 Model 代表，Model 定义了 item 的布局，id 以及 span。Model 还负责处理数据到视图的绑定，在视图被回收的时候释放资源。如果要显示这些 Model 则把它们添加到 Epoxy 的 Adapter 中，Adapter 为你处理复杂的显示问题。

### 追踪 Item 变化

Epoxy 通过在 Models 中使用一种 Diffing 算法帮你解决了这个问题。只要你改变了 Model 的设置，Epoxy 就会找到变化然后通知 RecyclerView。这简化了你的 Adapter ，提高了性能，还顺便提供了 Item Change 动画。

这个 Diffing 算法依赖于每个 Model 实现了 HashCode，这样当一个 Model 发生变化的时候就可以被检测到。Epoxy 提供了一个注解处理器，这样你的 Model 就可以为那些能代表 Model 状态的成员添加注解。一个生成的 subclass 可以为你实现正确的 HashCode 方法，同时为每个成员变量生成getter & setter 方法。

你还会注意到这个 Model 实现了getDefaultLayout() 来返回一个布局资源。这个资源用于 inflate 传递给 model bind 方法的 view，bind 方法中把数据设置到 view 上。另外，在 Adapter 中 layout（资源id）还被用作这个 item 的 view type id。

### Stable IDs By Default

为了让功能正常工作，Epoxy默认启用了RecyclerView的stable id（要了解什么是stable id，参见RecyclerView Adapter的setHasStableIds(boolean hasStableIds)方法）。

这使得diffing，item动画以及状态保存成为可能，每个model负责定义它的id,我们为动态生成的model手动设置id。比如每个neighborhood carousel model用网络请求中的neighborhood对象提供的id设置。

静态视图比如header就要复杂点。它没有一个固有的id与之关联，因此我们需要制作一个。Epoxy为每个新创建的model自动生成一个id。这个id可以保证在app生命周期中不会和其他生成的model id重复，而负id被用来避免和手动设置的id重复。

### 保存 View 的状态

Epoxy还添加了对保存视图状态的支持，这是默认的RecyclerView所缺乏的。比如，上面search设计中的carousels是可以横向滑动的，为了更好的用户体验我们想保存这个carousel的滚动位置。如果用户向下滚动之后再回到这里时他们应该看到carousel保持了原来的状态。类似的，如果他们旋转手机或者切换app之后再回来，尽管activity发生了重建，我们还是应该呈现出相同的状态。

如果使用普通的RecyclerView adapter这就难以实现了。Epoxy支持保存任意model的view状态，为了做到这点，它是用了stable ids把view的状态和model id联系起来。

要保存view的状态只需再model中添加如下代码：

```java
@Override
public boolean shouldSaveViewState {
    return true;
}
```

Epoxy将在它离开屏幕的时候保存自己的状态，并在返回的时候恢复。默认这个设置为false，这样内存和滚动的性能就不会因为保存了不必要的视图状态而受影响。

### Epoxy在静态内容中的应用

RecyclerView通常用于显示从远程数据（比如网络或者数据库）加载的动态内容，否则使用scrollview要简单些。但是Epoxy可以让RecyclerView的使用和ScrollView一样简单，我们的详情界面就是这样做的。

这种效果使用ScrollView来实现可能是最简单的。但是我们使用Epoxy配合RecyclerView可以得到更快的加载速度，也更容易实现动画。

性能对我们来说至关重要，这个页面通常在用户搜索的时候展示，用户点击一个搜索结果的图片，然后使用共享元素动画切换到详情页面，为了让搜索体验良好，动画必须流畅，因此details view的加载必须非常快。

让我们仔细看看这个view了解为什么它们会影响性能。首先，最顶上的图片实际是一个横向的RecyclerView，这样用户就能滑动查看房间的图片。在中间我们有一张静态的地图显示房源的位置，而在底部我们还有另一个RecyclerView，显示该地区的类似房源。而在这三个比较大的视图中间还穿插着一些文字信息和小图片。

这些加在一起就得到了一个带有很多位图的非常复杂的结构。这使得测量和布局的过程要花更长的时间，同时还需要更多的内存来加载图片。

另外，我们还从不同的渠道加载数据－databases, in-memory caches, 以及多个网络请求。这对为用户显示即时数据有好处，但是如果处理不好也会增加更多的时间开销。

庞大的视图结构，多个bitmap，多个view刷新，这些要求使得我们有足够的理由去关注性能问题。多亏了Epoxy我们可以在兼顾这些考虑的情况下也能提供很棒的用户体验。这是因为：

因为我们使用的是RecyclerView，当用户首次打开这个屏幕的时候只有一小部分视图被加载。避免了过早的加载map图片，底部的画廊以及它们之间的所有视图。这就使得布局更快，内存使用更小，过度动画更流畅。

当新数据被加载的时候我们无需反复的刷新view，减小了丢帧的概率。如果遇到类似的列表请求，而那个carousel不在屏幕上，我们什么夜不用做。如果价格发生了变换，Epoxy只是更新价格标签。这增加了进入动画的流畅度，同时防止用户滚动的时候丢帧。

自带Item change动画。当数据发生变化的时候我们可以以相应的动画显示，隐藏或者更新view。比如，点击翻译按钮可以插入一个加载器，当加载完成再过渡到翻译后的text，这避免了突兀的变化。

## 项目中引入 Epoxy

使用 gradle 依赖 Epoxy 和 Annotation Processor，目前最新版本为 2.8.0 。 [查看最新版本](https://github.com/airbnb/epoxy/releases/latest)

```gradle
dependencies {
  implementation 'com.airbnb.android:epoxy:2.8.0'
  // 依赖 Epoxy 的注解处理工具
  annotationProcessor 'com.airbnb.android:epoxy-processor:2.8.0'
}
```

## 基本使用方法

Epoxy 有两个主要的组件，各司其职：

1. `EpoxyModel`：负责列表项的样式和数据；
2. `EpoxyController`：负责列表中如何排列各种类型的 `EpoxyModel` 来显示列表项和数据。

### 1. 创建 EpoxyModel

Epoxy 根据你设置的自定义控件或布局文件来构造一个 Model 类，这个自动生成的类使用 `_` 作为类名的后缀，在 `EpoxyController` 中应该使用这个自动生成的类。

下面是创建 `EpoxyModel` 类的三种方法：

#### 自定义控件

通过自定义控件创建 `EpoxyModel` 的步骤如下：

* 首先按照普通的自定义控件的方法创建一个 View 的子类；
* 然后在类名上添加注解 `@ModelView` ；
* 在需要作为 `EpoxyModel` 的属性的 setter 方法上添加 "prop" 注解（`@TextProp`、`@ModelProp`、`@CallbackProp`）。

代码示例：

```java
@ModelView(autoLayout = Size.MATCH_WIDTH_WRAP_HEIGHT)
public class HeaderView extends LinearLayout {

  ... // Initialization omitted

  @TextProp
  public void setTitle(CharSequence text) {
    titleView.setText(text);
  }
}
```

项目 Rebuild 后，将会生成类 `HeaderViewModel_`，包名与 `HeaderView` 相同。

#### 数据绑定

如果使用了 Android 的 DataBinding，你可以使用类似下面的简单方法创建布局：

```xml
<layout xmlns:android="http://schemas.android.com/apk/res/android">
    <data>
        <variable name="title" type="String" />
    </data>

    <TextView
        android:layout_width="120dp"
        android:layout_height="40dp"
        android:text="@{title}" />
</layout>
```

然后, 在任意合适的包中创建 `package-info.java` 文件，并添加注解 `@EpoxyDataBindingLayouts` 指定以上布局.

```java
@EpoxyDataBindingLayouts({R.layout.header_view, ... // other layouts })
package com.airbnb.epoxy.sample;

import com.airbnb.epoxy.EpoxyDataBindingLayouts;
import com.airbnb.epoxy.R;
```

项目 Rebuild 后，将会生成类 `HeaderViewBindingModel_`。

#### ViewHolder 方式

使用 xml 布局来创建 `EpoxyModel` ，可以继承 `EpoxyModelWithHolder` 创建一个抽象类。

```java
@EpoxyModelClass(layout = R.layout.header_view)
public abstract class HeaderModel extends EpoxyModelWithHolder<Holder> {
  @EpoxyAttribute String title;

  @Override
  public void bind(Holder holder) {
    holder.header.setText(title);
  }

  static class Holder extends BaseEpoxyHolder {
    @BindView(R.id.text) TextView header;
  }
}
```

项目 Rebuild 后，会生成类 `HeaderModel_`，继承了抽象类 `HeaderModel` 并实现了其抽象方法。`HeaderModel` 中标注了 `@EpoxyAttribute` 注解的成员变量，会在 `HeaderModel_` 中生成 getter & setter 方法。

### 2. 创建 EpoxyController

Epoxy 的控制器可以指定列表显示的项目类型、数量和顺序，同时指定每个项目的数据。

在最重要的 `buildModels` 方法中，我们可以添加每一项 model ，这个方法会在我们每次调用 `requestModelBuild` 方法更新数据后被触发，Epoxy 跟踪模型中的变化，并自动绑定和更新视图。

下面的例子中，列表有一个头部，大量的照片列表项，最后是加载更多条。

```java
public class PhotoController extends Typed2EpoxyController<List<Photo>, Boolean> {
    @AutoModel HeaderModel_ headerModel;
    @AutoModel LoaderModel_ loaderModel;

    @Override
    protected void buildModels(List<Photo> photos, Boolean loadingMore) {
      headerModel
          .title("My Photos")
          .description("My album description!")
          .addTo(this);

      for (Photo photo : photos) {
        new PhotoModel()
           .id(photo.id())
           .url(photo.url())
           .addTo(this);
      }

      loaderModel
          .addIf(loadingMore, this);
    }
  }
```

### 3. 整合到 RecyclerView

列表控件既可以使用 Android Support Library 中的 `RecyclerView`，也可以使用 Epoxy 提供的 `EpoxyRecyclerView`。推荐使用后者，更加简便。

#### RecyclerView

```java
MyController controller = new MyController();
recyclerView.setAdapter(controller.getAdapter());

// Request a model build whenever your data changes
controller.requestModelBuild();

// Or if you are using a TypedEpoxyController
controller.setData(myData);
```

#### EpoxyRecyclerView

```java
epoxyRecyclerView.setControllerAndBuildModels(new MyController());

// Request a model build on the recyclerview when data changes
epoxyRecyclerView.requestModelBuild();
```

## 总结

非常感谢 Airbnb 和其他开发者对此开源项目的贡献，让我们得以体验到全新的列表开发方式，并享受到了 Epoxy 的注解处理器、Diffing 算法以及通用工具带给我们的方便。

本文仅从宏观上介绍了 Epoxy 的基本使用步骤，敬请期待后续文章，介绍 Epoxy 的更多细节。

## 参考资料

* [GitHub - Airbnb/Epoxy](https://github.com/airbnb/epoxy)
* [Epoxy Wiki](https://github.com/airbnb/epoxy/wiki)


