title: Angular CDK 部分功能介绍
date: 2019-01-17 19:31:00
categories: luanmingyang
tags: 

- angularjs
- Angular CDK

------

本文主要介绍了 Angular CDK 的部分功能，主要包括了三部分：Portal、Overlay、a11y/FocusTrap。

<!-- more -->

# Angular CDK 部分功能介绍

Angular CDK(Component Dev Kit) 是一个组件开发工具包，实现了一些公共的交互，同时不关注组件的具体呈现，可以在组件的开发中使用。

Angular CDK主要分为两大类：

- Common Behaviors

  一组包括了常见功能需求的工具，只与组件行为相关，不影响组件的呈现。

  目前主要包括：

  - [Accessibility](https://material.angular.io/cdk/a11y) 提供了许多改进可访问性的工具
  - [Bidirectionality](https://material.angular.io/cdk/bidi) 用于获取和响应LTR / RTL布局方向的变化
  - [Drag and Drop](https://material.angular.io/cdk/drag-drop) 提供了声明式创建拖拽的接口，支持自由拖拽、列表排序等
  - [Layout](https://material.angular.io/cdk/layout) 用于构建响应屏幕大小改变的响应式UI
  - [Observers](https://material.angular.io/cdk/observers) 提供了一组 observers 指令
  - [Overlay](https://material.angular.io/cdk/overlay) 提供了一种在屏幕上打开浮动面板的方法
  - [Platform](https://material.angular.io/cdk/platform) 用于收集当前平台及其支持的不同功能的信息
  - [Portal](https://material.angular.io/cdk/portal) 用于将动态内容呈现到应用程序
  - [Scrolling](https://material.angular.io/cdk/scrolling) 提供了对滚动的处理
  - [Text field](https://material.angular.io/cdk/text-field) 用于处理文本输入

- Components

  一组具有实用功能的无样式组件。

  目前主要包括：

  - [Stepper](https://material.angular.io/cdk/stepper) 步进器
  - [Table](https://material.angular.io/cdk/table) 可自定义的 data-table
  - [Tree](https://material.angular.io/cdk/tree) 方便为结构化数据构建树型结构

本文主要包括了三部分的介绍：Portal、Overlay、a11y/FocusTrap

## 1. Angular CDK 之 Portal

### 1.1 概述

Portal 用于将动态内容呈现到应用程序。

Portal：动态内容，可以是 `Component` 或 `TemplateRef`

PortalOutlet：放置动态内容的地方

[Portal API](https://material.angular.io/cdk/portal/api#DomPortalOutlet)

### 1.2 指令

#### CdkPortal

指令版本 `TemplatePortal`，用于从 `<ng-template>` 获取一个Portal。

```html
<ng-template cdkPortal>
  <p>Portal1</p>
</ng-template>

<p *cdkPortal>Portal2</p>
```

组件内部可以使用 `@ViewChild` 或 `@ViewChildren` 获取引用。

```typescript
@ViewChildren(CdkPortal) templatPortals: QueryList<CdkPortal>;
```

<img src="/Users/luanmingyang/Desktop/luan/img/portal-cdkportal.png" width="540">

#### CdkPortalOutlet

用于添加 `PortalOutlet`

```html
<ng-template [cdkPortalOutlet]="curPortal"></ng-template>
```

#### 🌰 动态切换内容

[传送门](https://stackblitz.com/edit/angular-hua49e?file=src%2Fapp%2Fportal%2Fportal-demo.component.ts)

使用时需要先引入对应模块：

`import {PortalModule} from '@angular/cdk/portal';`

首先设置一个插槽，用于放置动态内容：

```html
<div class="content">
  <div [cdkPortalOutlet]="curPortal"></div>
</div>
```

需要动态显示的内容：

```html
<ng-template cdkPortal>Portal1</ng-template>
<div *cdkPortal>Portal2</div>
<ng-template #template>Portal3</ng-template>
```

通过改变 `curPortal` 切换显示内容：

```js
export class PortalDemoComponent {
  curPortal: Portal<any>;
  // 获取动态内容引用
  @ViewChildren(CdkPortal) templatPortals: QueryList<CdkPortal>;
  @ViewChild('template') template: TemplateRef<any>;
  // 切换
  changePortal() {
    // this.curPortal = xxx;
  }
}
```

### 1.3 常用class

#### Portal

想要渲染在其它位置的内容，可以附加到 `PortalOutlet`，或从 `PortalOutlet` 分离。

可以通过 `isAttached` 属性判断是否已经被附加到某个 `PortalOutlet`。

#### ComponentPortal

可以在attach时实例化某些组件

`new ComponentPortal<{}>(component: ComponentType<{}>, viewContainerRef?: ViewContainerRef, injector?: Injector, componentFactoryResolver?: ComponentFactoryResolver): ComponentPortal<{}>`

#### TemplatePortal

表示一些嵌入的模版

`new TemplatePortal<{}>(template: TemplateRef<{}>, viewContainerRef: ViewContainerRef, context?: {}): TemplatePortal<{}>`

#### DomPortalOutlet

用于将 Portal 附加到Angular应用程序上下文之外的任意DOM元素，也就是附加到 `<app-root>` 之外

##### 🌰 简单使用示例

[传送门](https://stackblitz.com/edit/angular-dxl7fg?file=src%2Fapp%2Fportal%2Fportal-demo.component.ts)

```js
domPortalOutlet: DomPortalOutlet;

constructor(
    private viewContainerRef: ViewContainerRef,
    private injector: Injector,
    private componentFactoryResolver: ComponentFactoryResolver,
    private appRef: ApplicationRef) {}

createOutletOutApp() {
  const elem = document.createElement('div');
  elem.innerHTML = '&ltapp-root&gt;外的插槽';
  document.body.appendChild(elem);
  this.domPortalOutlet = new DomPortalOutlet(elem, this.componentFactoryResolver, this.appRef, this.injector);
}

attachTemplatePortal() {
  this.domPortalOutlet.attachTemplatePortal(this.templatPortals.first);
}
```

通过 `new DomPortalOutlet(elem, this.componentFactoryResolver, this.appRef, this.injector);` 把elem 变成Angular可管理的插槽。

<img width="360" src="/Users/luanmingyang/Desktop/luan/img/portal-DomPortalOutlet.png">

##### DomPortalOutlet 在 Angular Material 中的使用

在 Angular Material CDK Overlay 中，通过使用 DomPortalOutlet 在 `<app-root>` 之外创建 Overlay container

[源码](https://github.com/angular/material2/blob/master/src/cdk/overlay/overlay.ts#L117) 部分代码实现如下：

```js
const pane = this._createPaneElement(host);
const portalOutlet = this._createPortalOutlet(pane);

private _createPaneElement(host: HTMLElement): HTMLElement {
    const pane = this._document.createElement('div');

    pane.id = `cdk-overlay-${nextUniqueId++}`;
    pane.classList.add('cdk-overlay-pane');
    host.appendChild(pane);

    return pane;
}

private _createPortalOutlet(pane: HTMLElement): DomPortalOutlet {
    if (!this._appRef) {
      this._appRef = this._injector.get<ApplicationRef>(ApplicationRef);
    }

    return new DomPortalOutlet(pane, this._componentFactoryResolver, this._appRef, this._injector);
}
```



## 2. Angular CDK 之 Overlay

### 2.1 概述

Overlay 提供了一种在屏幕上打开浮动面板的方法，即在 `<app-root>` 之外创建叠加层，并且该叠加层仍在 Angular 控制范围内。

主要用于构建公共组件，Modal、Tooltip、Menu、Select等组件的构建过程中都可以选择使用 Overlay。

使用时需要先引入对应模块：

`import {OverlayModule} from '@angular/cdk/overlay';`

通过调用 `overlay.create()` 创建一个 `OverlayRef` 实例，`OverlayRef` 是一个 `PortalOutlet`，一旦被创建，可以通过附加 `Portal` 为其添加内容。

```js
const overlayRef = overlay.create();
const userProfilePortal = new ComponentPortal(UserProfile);
overlayRef.attach(userProfilePortal);
```

创建时 `OverlayRef` 时可以提供可选的配置对象 `OverlayConfig`。

[Overlay API](https://material.angular.io/cdk/overlay/api#Overlay)

### 2.2 OverlayRef

使用服务创建的Overlay引用，用于对其操纵或处理。

```js
class OverlayDemoComponent implements OnInit {

  overlayRef: OverlayRef;

  constructor(private overlay: Overlay) { }

  ngOnInit(): void {
      this.overlayRef = this.overlay.create();
  }
}
```

<img width="400" src="/Users/luanmingyang/Desktop/luan/img/overlay-create.png" >

### 2.3 OverlayConfig

创建Overlay时使用的配置对象。

属性：

- hasBackdrop：是否使用遮罩
- backdropClass：遮罩的classname，使得我们可以自定义遮罩的样式
- positionStrategy：PositionStrategy 指定位置策略
- scrollStrategy：ScrollStrategy 指定在打开时处理滚动事件的策略
- direction：文本的方向
- panelClass：指定 Overlay 类名
- disposeOnNavigation：当用户在前进/后退时是否应该丢弃。注意，通常不包括单击链接（除非在使用`HashLocationStrategy`）。
- width/minWidth/maxWidth：定义宽度。类型为number时，则默认单位为px
- height/minHeight/maxHeight：定义高度。类型为number时，则默认单位为px

可以通过 OverlayRef 指定 backdrop 的点击事件：

```js
this.overlayRef.backdropClick().subscribe(() => {
  this.overlayRef.detach();
});
```

### 2.4 两种位置策略

- GlobalPositionStrategy

  使用此策略，叠加层被赋予相对于浏览器视口的显式位置，与其他元素无关。

- ConnectedPositionStrategy（弃用）

  使用此策略，叠加层被赋予相对于某个元素的隐式位置。相对位置是根据Overlay上的点相对原点定义的。例如，下拉列表将原点的左下角连接到叠加层的左上角。

- FlexibleConnectedPositionStrategy

  使用此策略，叠加层被赋予相对于某个元素的隐式位置。相对位置是根据Overlay上的点相对原点定义的。例如，下拉列表将原点的左下角连接到叠加层的左上角。

### 2.5 四种滚动策略

- NoopScrollStrategy

  默认，什么都不做。

- CloseScrollStrategy

  滚动时会自动关闭叠加层。

- BlockScrollStrategy

  将在打开时阻止页面滚动。

- RepositionScrollStrategy

  滚动时会重新定位覆盖元素，会对滚动产生一些性能影响。

### 🌰 示例

[传送门](https://stackblitz.com/edit/angular-zmcuh9?file=src%2Fapp%2Foverlay%2Foverlay-demo.component.ts)

使用 Overlay 需要先引入必要的样式

`@import '~@angular/cdk/overlay-prebuilt.css';`

#### 1. 创建菜单

```js
createMenu() {
  const strategy = this.overlay.position()
    .flexibleConnectedTo(this.createMenuBtn).withPositions([{
      originX: 'center',
      originY: 'bottom',
      overlayX: 'center',
      overlayY: 'top'
    }]);
  this.overlayRef = this.overlay.create({
    positionStrategy: strategy
  });
  this.overlayRef.attach(new TemplatePortal(this.menuTpl, this.viewContainerRef));
}
```

通过调用 `overlay.position()` 方法获取一个 `OverlayPositionBuilder` ，通过它来配置位置策略。

通过调用 `flexibleConnectedTo(elementRef)` 方法创建位置策略 `FlexibleConnectedPositionStrategy`

<img width="100" src="/Users/luanmingyang/Desktop/luan/img/overlay-menu.png">

#### 2. 创建弹出框

```js
createDialog() {
  const strategy = this.overlay.position().global().centerHorizontally().centerVertically();
  const config = new OverlayConfig({
    hasBackdrop: true, // 使用backdrop
    positionStrategy: strategy
  });
  this.overlayRef = this.overlay.create(config);
  this.overlayRef.attach(new TemplatePortal(this.dialogTpl, this.viewContainerRef));
  // 绑定backdrop点击事件
  this.overlayRef.backdropClick().subscribe(() => {
    this.overlayRef.detach();
  });
}
```

通过调用 `global()` 方法创建位置策略 `GlobalPositionStrategy`

<img width="400" src="/Users/luanmingyang/Desktop/luan/img/overlay-dialog.png">



## 3. Angular CDK 之 a11y

### 3.1 a11y 概述

a11y 提供了许多改进可访问性的工具。

使用时需要先引入对应模块：

`import {A11yModule} from '@angular/cdk/a11y';`

### 3.2 FocusTrap

旨在用于为对话框等**焦点必须受到约束**的组件创建可访问的体验。

#### 3.2.1 指令

`cdkTrapFocus` 在区域内捕获焦点的指令。

可以显式地声明聚焦的区域：

`cdkFocusInitial` 指定在初始化区域时将获得焦点的元素。

`cdkFocusRegionStart ` 与 `cdkFocusRegionEnd` 定义焦点将被捕获的区域。使用Tab键时，焦点将在此区域中移动并在两端环绕。

#### 3.2.2 FocusTrapFactory

用于根据给定的元素创建一个焦点捕获区域。

`focusTrap = focusTrapFactory.create(element);`

#### 3.2.3 FocusTrap

允许在DOM元素中捕获焦点的类。

它假定Tab键顺序与DOM顺序相同，但实际上这是不一定的，如 tabIndex > 0 或 指定了 flex order 等情况。

- focusFirstTabbableElement()   聚焦区域内的第一个可捕捉元素
- focusFirstTabbableElementWhenReady()
- focusInitialElement()  
- focusInitialElementWhenReady()
- focusLastTabbableElement()
- focusLastTabbableElementWhenReady()

#### 3.2.4 实际中的使用

以公共组件 Dialog 为例，需要在 Dialog 打开时，将焦点约束在 Dialog 区域内部。

主要分为三步：

1. 打开 Dialog 时，保存当前获得焦点的元素
2. 使 Dialog 获得焦点，并将焦点约束在 Dialog 内
3. Dialog 关闭时，将焦点恢复到之前聚焦的元素上

```js
import { Component, Inject } from '@angular/core';
import { FocusTrap, FocusTrapFactory } from '@angular/cdk/a11y';
import { DOCUMENT } from '@angular/common';

class Dialog {
    focusTrap: FocusTrap;
    prevFocusedElem: HTMLElement;

    constructor(
        private elementRef: ElementRef,
        private focusTrapFactory: FocusTrapFactory,
        @Inject(DOCUMENT) private document: any) { }

    // 保存 Dialog open 之前聚焦的元素
    savePrevFocusedElement() {
        if (this.document) {
            this.prevFocusedElem = this.document.activeElement as HTMLElement;
            if (this.elementRef.nativeElement.focus) {
                // 元素可能无法立即聚焦
                Promise.resolve().then(() => {
                    this.elementRef.nativeElement.focus();
                });
            }
        }
    }

    // 将焦点限制在 Dialog 内部
    trapFocus() {
        if (!this.focusTrap) {
            this.focusTrap = this.focusTrapFactory.create(this.elementRef.nativeElement);
        }
        this.focusTrap.focusInitialElementWhenReady();
    }

    // Dialog close 时恢复原来聚焦的元素
    restoreFocus() {
        if (this.prevFocusedElem && typeof this.prevFocusedElem.focus === 'function') {
            this.prevFocusedElem.focus();
        }

        if (this.focusTrap) {
            this.focusTrap.destroy();
            this.focusTrap = null;
        }
    }
}
```

