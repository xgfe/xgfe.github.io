title: E2E测试之protractor
date: 2016-07-01 10:58:49
categories: yangjiyuan
tags:
- 测试
- E2E
- protractor
---

> e2e或者端到端（end-to-end）或者UI测试是一种测试方法，它用来测试一个应用从头到尾的流程是否和设计时候所想的一样。简而言之，它从一个**用户**的角度出发，认为整个系统都是一个**黑箱**，只有**UI**会暴露给用户。  

在我们的实际项目中碰到过多次测试不完善而出现的问题，很大程度上是因为人工测试的时候，很多功能并不能很好的覆盖到，尤其是当出现大范围代码重构的时候，一旦功能测不到，发布到线上就是定时炸弹💣所以自动化的测试就是我们当前的一大痛点，[@HeOH](https://github.com/hexiaoming)同学曾经分享过关于[Angular单元测试](http://xgfe.github.io/2015/12/17/HeOH/AngularJS%E7%9A%84%E8%87%AA%E5%8A%A8%E5%8C%96%E6%B5%8B%E8%AF%95/)的内容，那么我们就来聊一聊Angular的E2E测试。  
<!-- more -->
# protractor简介
protractor是为AngularJS定制的测试框架，也是由angular团队开发并维护的。顺便提一句，“Angular”本意为“角、角度”，框架名字源于“angular brackets”（尖括号），因为HTML中标签都是由尖括号包裹的。而protractor的意思为“量角器”，这就很好理解为什么说protractor是为angular定制的测试框架了，因为量角器就是用来测量角的啊。  
## 特点
protractor有如下几个特点：

- 端到端测试
- jasmine作为测试框架- 基于WebDriverJS- 针对angular的定位器- 实现自动等待，变异步为同步
- 支持测试代码的调试- 支持多浏览器的并行UI测试## 安装
1.安装protractor工具

```
$ npm install -g protractor
```
2.安装selenium-standlone(在安装完成protractor之后就可以调用webdriver-manager命令了)

```
$ webdriver-manager update
```
	3.安装v1.6以上版本的Java

## 使用
写好配置文件之后，就可以执行测试了

```
$ protractor protractor.conf.js
```
# 配置文件
使用protractor运行测试一般是需要指定配置文件的，配置文件都是一个npm module，导出一个config对象。

```
exports.config = {
	......
};
```
可配置的内容有很多，这里就不一一介绍，只对主要的一些配置做一些说明，其他配置参考protractor的[官方示例](https://github.com/angular/protractor/blob/master/docs/referenceConf.js)。

- specs  
指定测试文件路径
- exclude  
指定需要被排除的测试文件
- suites  
指定测试组合，比如一个流程包含多个测试文件，就可以指定测试“套件”
- baseUrl  
基础路径，打开浏览器的baseUrl，指定该路径之后再在测试里直接打开相对路径即可
- rootElement  
根路径，一般是指定`ng-app`的DOM节点，是一个DOM选择器
- framework  
指定测试框架，默认是[jasmine](http://jasmine.github.io/)，也可以指定[mocha](https://mochajs.org/)等其他框架
- plugins  
指定插件数组
- onPrepare, onComplete等  
测试的生命周期，可以针对不同的生命周期做不同的操作

一个简单的配置文件如下所示

```
// protractor.conf.js
exports.config = {
    specs: [
        'test/e2e/*.js'
    ],
    suites: {
        official: 'test/e2e/official.js',
        page: 'test/e2e/phoneList.e2e.js'
    },

    capabilities: {
        'browserName': 'chrome'
    },

    baseUrl: 'http://localhost:9000/',

    framework: 'jasmine'
};
```
# 测试文件
protractor是基于Jasmine的，所以Jasmine的语法都可以使用，即`describe`表示测试块，`it`表示测试用例，`expect`表示断言。  
和其他测试用例不同的是，protractor在测试的时候有几个比较特殊的对象可以使用，比如`browser`对象用于操作浏览器，`element`用于获取元素等，如下是一个简单的测试用例。

```
describe('Protractor Demo',function(){
    it('should have a title',function(){
        browser.get('http://www.facebook.com');
        expect(browser.getTitle()).toEqual('no this site');
    });
});
```
*注：protractor中的expect可以对promise进行断言*
## browser对象
browser对象主要用于执行操作浏览器相关的行为，比如打开链接，设置窗口大小，执行脚本等操作。以下是browser中几个比较重要的方法。

- browser.get()
- browser.waitForAngular()
- browser.addMockModule()
- browser.getTitle()
- browser.executeScript()
- browser.getCurrentUrl()## element、by对象
element和by对象主要用于获取浏览器中的元素和操作元素行为。by元素用于生成一个特殊的“选择器”，element接受选择器对参数从而获取到页面中的元素。  
element中获取元素的方法，如：  

- element.all()
- element.filter()
- element.get()
- element.count()

element获取到的元素可以调用一些方法操作元素的一些行为，如点击事件，输入框输入等。

- element.click()
- element.sendKeys()
- element.getText()
- element.isEnable()

by对象用于生成选择器对象供element使用，可以把它理解为jQuery的选择器，有很多方式生成选择器，如

- by.id()
- by.css()
- by.tagName()
- by.model()
- by.binding()
- by.repeater()
- by.buttonText()

其中，`model`、`bindling`、`repeater`等方法都是根据AngularJS定制的选择方法，更方便获取元素。## ExpectedConditionsd对象
顾名思义， ExpectedConditions意为“期望条件”，也就是说在一定条件下，执行特定的操作，一般和`browser.wait`配合使用。protractor提供了有限的几个方法，浏览器会在满足条件之前停止运行一定时间，直到满足条件才会继续运行。如下面的测试表示当Checkbox在5秒之内被选中的时候再对列表的数目进行断言。

```
it('should wait for checkoBox to be select', function() {
    var EC = protractor.ExpectedConditions;
    var checkBox = element(by.model('$ctrl.isSelected'));
    browser.wait(EC.elementToBeSelected(checkBox), 5000);
    var phoneList = element.all(by.repeater('phone in $ctrl.phones'));
    expect(phoneList.count()).toBe(20);
});
```
**以上只是简单地介绍了几个对象的一些方法，更多的内容可以查看[官方文档](http://www.protractortest.org/#/api)**
# 测试用例编写原则/风格
## 测试用例原则
以下是protractor建议的用于编写测试用例的时候的规则：

1. 不要用E2E测试已经有单元测试的代码
2. 用不同的文件来区分和独立测试用例
3. 不要在测试中使用逻辑操作，如if判断、for循环等
4. 非必要情况下不要使用模拟数据
5. 使用jasmine2.x作为测试框架
6. 测试之间彼此独立
7. 对主要的模块有一套组合测试导航，即前面配置文件部分提到的suites

## 选择器
使用选择器获取元素的时候，应该尽量遵照如下原则：

1. 永远不要使用[xpath](http://www.w3school.com.cn/xpath/xpath_intro.asp)
2. 尽量使用protractor提供的选择器，如by.model等
3. 当没有protractor选择器可以使用的时候，尽量选用by.id或by.css
4. 尽量不要使用经常变动的文本作为选择器，如by.linkText、by.buttonText等

## 使用页面对象配合测试用例
页面对象是protractor推荐的一种写法，即页面是对象，从而把测试和页面的操作逻辑解耦，降低测试用例的复杂度，提高代码复用率，使测试专注于需要测试的逻辑，获取元素、操作浏览器等在页面对象中进行完成。具体写法参照[文档](http://www.protractortest.org/#/style-guide#page-objects)

1. 使用页面对象与测试页面进行交互
2. 每一个文件定义各自的对象
3. 使用module.exports在文件末尾导出一个对象
4. 所有依赖的模块都在文件头部require
5. 在测试文件的开头对页面对象进行实例化
6. 把公共的元素定义到对象的构造函数中
7. 把需要多个步骤进行操作的定义为方法
8. 在页面对象中不要使用expec
9. 对指令、对话框或其他常见元素进行封装

## 项目目录结构
测试文件的目录结构建议和源文件的目录进行对应。

```
/* recommended */

|-- project-folder
  |-- app
    |-- css
    |-- img
    |-- partials
        home.html
        profile.html
        contacts.html
    |-- js
      |-- controllers
      |-- directives
      |-- services
      app.js
      ...
    index.html
  |-- test
    |-- unit
    |-- e2e
      |-- page-objects
          home-page.js
          profile-page.js
          contacts-page.js
      home-spec.js
      profile-spec.js
      contacts-spec.js
```
# 测试程序的调试
端到端测试是很难调试的,因为他们依赖于整个系统,而且可能取决于之前的行为(比如登录),并可能改变他们测试的应用程序的状态。使用`selenium-webdriver`操纵浏览器的时候更加困难,在这里protractor就提供调试方式 在代码中加入 `browser.pause()`; 并且在终端输入`repl`就可以使用WebDriver commands来调试程序了。

# 结语
端到端测试是一个大坑！在实际的情况下更坑，有太多的不确定因素，实际情况下面临的问题比本文中讨论的基础特征要复杂得多，甚至有很多场景是无法用端到端测试覆盖到的。在实际项目中尽量要结合端到端测试和单元测试共同使用，多方面保证代码的质量。

---
参考文献

- [http://www.protractortest.org/](http://www.protractortest.org/)
- [http://dj1211.com/?p=678](http://dj1211.com/?p=678)
- [http://ramonvictor.github.io/protractor/slides/#/](http://ramonvictor.github.io/protractor/slides/#/)
- [https://github.com/codef0rmer/proquery](https://github.com/codef0rmer/proquery)