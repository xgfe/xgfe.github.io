title: 学习如何使用AngularJs 1.3中的新form表单特性
date: 2015-11-30 22:34:00
categories: felix
tags: 
- angularjs
- form
---
**长文慎入**

译自：[Taming Forms in AngularJS 1.3](http://www.yearofmoo.com/2014/09/taming-forms-in-angularjs-1-3.html)

在AngularJs 1.3中form表单得到了大幅度的优化，解决了大量的与浏览器原生HTML5验证的bug，同时增加了诸如“验证器管道”（validators pipeline）和“异步验证”（asynchronous validations）等新特性。辅以“嵌套表单”（nested form）和新的消息提示模块（ngMessages），1.3中的form表单变得空前强大。

<!-- more -->

![盗图1](http://www.yearofmoo.com/images/site/mookins/2.png)

下面让我们一起来领略这些惊人的表单新特性吧。

**最近更新**

本文首次发表于2014年9月2日，最近修改于2014年9月4日。  

**目录**

[1、Angular中的表单验证](#angular-form)  
[2、演讲视频，Github仓库和演示应用](#video-github)  
[3、基础知识](#basics)  
[4、HTML5验证器和解析错误](#html5-validation-errors)  
[5、验证器管道($validators pipeline)](#validators-pipeline)  
[6、通过异步验证器实现异步验证](#async-validators)  
[7、错误消息渲染](#errors-rendering)  
[8、控制何时更新数据模型(model)](#ng-model-options)  
[9、动态生成表单元素](#dynamic-forms)  
[10、关于解析器和格式化](#parsers-formatters)  
[11、正在进行中的工作](#work-progress)

![盗图2](http://www.yearofmoo.com/images/site/mookins/20.png)

## <span id="angular-form">Angular中的表单验证</span>

表单验证在任何一个框架中都是一只晋安驯服的野兽。在Vanilla JS中就更加让人捉摸不透。虽然已经有一些在制定中的HTML5表单验证API，但是这些API是不一致的，同时不失所有设备都很好的支持，甚至一些平台根本就不支持它们。

幸亏AngularJs通过ngModel对表单验证做了一个多功能的包装。如果需要的话ngModel的内部验证也可以只使用HTML5验证API，当然ngModel总体上的跨浏览器的统一性还是非常不错的。AngularJs 1.3对表单的控制能力远远高于1.2版本。

不过还有好多知识点需要理解的，让我们快点开始吧......

## <span id="video-github">演讲视频，Github仓库和演示应用</span  

不是很久以前，那是在2014年6月多伦多的AngularJs交流会上，我讲述了AngularJs的表单验证，几乎涵盖了这篇文章的所有话题。视频放在Youtube上，链接在下面。**请记住在当时，异步验证API还不稳定**。所以当视频中讨论API对于基于promise的验证是如何工作的时候，请查看一下本文章的后面部分。除此，好好欣赏视频吧，期望你能喜欢我潇洒的幽默。

视频传送门[Youtube视频，要爬长城才能看到的额]：[AngularJs - ngModel Form Validation](https://www.youtube.com/watch?v=AgdGhZvzUxg&feature=youtu.be)

有一个朋友的示范仓库展示了本文列出的所有特性，在线示范和仓库地址如下：
[查看示范应用](http://yom.nu/ng-forms-demo)  
[查看Github仓库](http://yom.nu/ng-forms-code)

## <span id="basics">基础知识</span>

我们不能假想所有的人都了解Angular的表单是如何使用的，所以在开始之前先简要的介绍一下如何使用。

### 使用ngModel收集数据

用户angular的人就会知道，ng-model属性总是位于输入元素上，如（input, select, textarea）。这个强大的指令连接中DOM种输入元素的输入值（称为“view value”）和对应作用域（scope）中的数据模型值（称为“model value”）,即当用户输入时，输入值（view value）改变，对应的数据模型值（model value）也会相应更新，反之亦然。

```html
<div class="field">
    <input type="text" ng-model="myName" />
    <p>My name is <strong></strong></p>
    <button ng-click="myName='default value'">Reset to 'default value'</button>
</div>
```

现在当用户再input元素上输入值的时候，scope中的对应数据模型会同步此值。当按钮被按下的时候，scope中的myName属性值会变化，然后input输入域会显示这个值（‘defaut value’）。

### 数据模型值和控制器

控制值在DOM（view value）和scope（model value）中传递的逻辑是由ngModelController提供的。每当一个输入元素有ng-model属性时，ngModel指令会创建一个ngModelController的实例来处理所有的值的解析，格式化和传递。

这种机制的好处是我们不用写任何js代码就可以完成一些标准的处理流程，如传递数据给scope，执行验证器，触发数据模型绑定的事件。看一下下面的代码：

```html
<div class="field">
    <input type="email"
        minlength="5"
        maxlength="100"
        ng-model="myEmail"
        required />
</div>
```

上面的input元素通过ng-model指令绑定了一个scope中的myEmail属性。用户输入数据时将自动修改scope上的myEmail属性值为输入值。同时input元素上还定义了一系列的验证器来验证用户的输入，只有当用户输入的值满足所有定义验证器的条件，这个输入值才会被angualr写入到scope中绑定的属性上。上面例子中，ngModelController将会检查：
    * 输入值不能为空（required）
    * 输入值最小长度为5（minlength）
    * 输入值最大长度为100（maxlength）
    * 输入值须是一个合法的邮箱地址（type="email"）
通过这四个验证器我们不用写一行js代码就可完成表单验证，同时可以在不同的表单元素上复用。

当一个验证器验证失败的时候，将会把错误信息注册到ngModelController实例中的$error对象中。不过要想展示错误信息的话，我们首先需要能在模板（html）中访问这个ngModelController 的model，此处可以把输入元素用一个form元素包裹，同时给form元素和input元素写上自己的name属性和值。

```html
<form name="myForm">
    <div class="field">
        <input type="email"
            name="myEmail"
            minlength="5"
            maxlength="100"
            ng-model="myEmail"
            required />
    </div>
</form>
```

现在我们可以在模板中通过myForm.myEmail.$error检查此input元素的验证状态，同时还可以检查表单元素的其他状态属性，如$pristine(未被修改过为true), $dirty(修改过为true), $valid(通过验证), $invalid（未通过验证）。通过这些值我们可以在模板中定义何时显示错误信息。

```html
<form name="myForm">
    <div class="field">
        <input type="email"
            name="myEmail"
            minlength="5"
            maxlength="100"
            ng-model="myEmail"
            required />
        <div ng-if="myForm.myEmail.$invalid">There is an error with the field...</div>
    </div>
</form>
```

我们可以创建自定义的ngModel组件指令来访问ngModelController实例并实现验证器，所有要做的仅仅是在指令定义时通过require属性来注入ngModel的控制器。这种方式创建的指令需要和ngModel一起使用。

```javascript
//
// Use this in your templates like so
// <input type="text" custom-validator ng-model="myModel" />
//
ngModule.directive('customValidator', function() {
    require : 'ngModel',
    link : function(scope, element, attrs, ngModel) {
        ngModel.$validators.myValidator = function() { ... }
    } 
});
```

form元素拥有自己的控制器，form的控制器是为了管理整个表单验证而添加的，它拥有$valid和$invalid属性。下面的例子是一个根据表单是否通过验证的状态来决定是否把数据提交到后台的表单控制器。

```javascript
ngModule.controller('FormCtrl', function($http) {
    this.submit = function(isValid, data) {
        if(!isValid) return;

        //submit the data to the server
        $http.post('/api/submit', data);
    }
});
```

在form的html模板中通过ng-submit属性指定表单提交时调用控制器中的submit方法。

```html
<form ng-controller="FormCtrl as form"
    name="myForm" 
    ng-submit="form.submit(myForm.$valid, data)">
    <div class="field">
        <input type="email"
            name="myEmail"
            minlength="5"
            maxlength="100"
            ng-model="data.myEmail"
            required />
        <div ng-if="myForm.myEmail.$invalid">There is an error with the field</div>
    </div>
</form>
```

不知你是否注意都我们使用了一个data集合来存储所有的表单数据模型。如果我们仅仅且把所有的表单数据模型存储在一个集合中，那么在提交表单时可以直接把这个集合提交给后台。这种模式为我们省去不少的js代码。

希望上面的介绍是你初略的了解了ngModel的一些基本知识。接下来我们开始介绍AngualrJs 1.3中的那些新特性。

## <span id="html5-validation-errors">HTML5验证器和解析错误</span>

现在所有的HTMl5验证器都被绑定到ngModel上，当错误发生时，错误信息将作为属性挂在ngModel.$error上。下面的表格展示了属性名和错误错误类型的对应关系。

|     HTML5 Attribute    |        ng Attribute       |     Registered Error     |
|:----------------------:|:-------------------------:|:------------------------:|
|     required="bool"    |     ng-required="..."     |  ngModel.$error.required |
|   minlength="number"   |   ng-minlength="number"   | ngModel.$error.minlength |
|   maxlength="number"   |   ng-maxlength="number"   | ngModel.$error.maxlength |
|      min="number"      |      ng-min="number"      |    ngModel.$error.min    |
|      max="number"      |      ng-max="number"      |    ngModel.$error.max    |
| pattern="patternValue" | ng-pattern="patternValue" |  ngModel.$error.pattern  |

下面的input元素的type类型也会注册验证器。

|   \<input type="...">  |       Registered Error       |
|:---------------------:|:----------------------------:|
|      type="email"     |     ngModel.$error.email     |
|       type="url"      |      ngModel.$error.url      |
|     type="number"     |     ngModel.$error.number    |
|      type="date"      |      ngModel.$error.date     |
|      type="time"      |      ngModel.$error.time     |
| type="datetime-local" | ngModel.$error.datetimelocal |
|      type="week"      |      ngModel.$error.week     |
|      type="month"     |     ngModel.$error.month     |

### ngModel如何处理这些错误

由于HTML5自身带有的表单验证特性，一些类型的input输入框只有当输入值满足验证条件后才会生效（也就是element.value只能取到通过验证的输入值）。

在1.3中，ngModel将先处理解析相关的验证，然后才是其它的验证。也就是说会先判断一个值是否是符合number, date, url和email这种类型验证，然后才是其它的如required, minlength, max等等。

[一个小小Demo](http://plnkr.co/edit/UuF2H1poVvPfiePEhDif?p=preview)

## <span id="validators-pipeline">验证器管道($validators pipeline)</span>

在AngularJs 1.3中我们使用$validators来代替以前的$parsers和$formatters实现表单验证。为了将自定义验证器注册到表单验证器中（ngModel.$validators），我们需要先创建包含ngModel的自定义指令。下面的例子展示了如何通过$validators定义一个判断密码输入是否符合要求的验证器。

```javascript
ngModule.directive('validatePasswordCharacters', function() {

    var REQUIRED_PATTERNS = [
        /\d+/,    //numeric values
        /[a-z]+/, //lowercase values
        /[A-Z]+/, //uppercase values
        /\W+/,    //special characters
        /^\S+$/   //no whitespace allowed
    ];

    return {
        require : 'ngModel',
        link : function($scope, element, attrs, ngModel) {  
            ngModel.$validators.passwordCharacters = function(value) {
                var status = true;
                angular.forEach(REQUIRED_PATTERNS, function(pattern) {
                    status = status && pattern.test(value);
                });
                return status;
            }; 
        }
    }
});
```

当在控制器管道（给$validators添加属性）注册验证器时需要函数返回一个布尔类型的值。

对应的HTML代码如下

```html
<form name="myForm">
    <div class="label">
        <input name="myPassword" type="password" ng-model="data.password" validate-password-characters required />
        <div ng-if="myForm.myPassword.$error.required">
          You did not enter a password
        </div>
        <div ng-if="myForm.myPassword.$error.passwordCharacters">
          Your password must contain a numeric, uppercase and lowercase as well as special characters
        </div>
    </div>
</form>
```

## <span id="async-validators">通过异步验证器实现异步验证</span>

下面让我们用同样的方式来创建一异步验证器功能的指令，通过ajax与后台交互的结果来判断输入的用户名是否可用。

```javascript
ngModule.directive('usernameAvailableValidator', ['$http', function($http) {
    return {
        require : 'ngModel',
        link : function($scope, element, attrs, ngModel) {
            ngModel.$asyncValidators.usernameAvailable = function(username) {
                return $http.get('/api/username-exists?u='+ username);
            };
        }
    }
}]);
```

异步验证器($asyncValidators)在触发的时候需要每个验证器返回一个promise对象。当这个promise完成的时候表示验证通过，拒绝（reject）的时候将把验证的错误信息注册到对应的$error对象上。只有当所有的验证器（包含异步验证器）验证通过后，值才会被写入scope中。

需要记住的是，异步验证器只有再其他验证器全部验证通过后才会触发。这种机制有效的防止了在用户名无效时发送无意义的后端验证请求。下面的样例代码很好的诠释了这点。

```html
<form name="myForm">
    <!-- 
      first the required, pattern and minlength validators are executed
      and then the asynchronous username validator is triggered...
    -->
    <input type="text"
        class="input"
        name="username"
        minlength="4"
        maxlength="15"
        ng-model="form.data.username"
        pattern="^[-\w]+$"
        username-available-validator
        placeholder="Choose a username for yourself"
        required />
    <!-- ... -->
</form>
```

### 异步验证期间的$valid和$invalid

当一个或多个异步验证器正在验证中时，对应model和form的$valid和$invalid标志都被置为undefined，只有当所有的异步验证器完成后，$valid和$invalid才会根据所有验证器验证的结果来赋值(true or false)。在这个期间，在modal和form上会有一个特殊的标志$pending(值为true)来标识，当所有异步验证完成后这个值将被移除。

### 展示加载中动画

因此，通过$pending标志我们可以在正在执行异步验证的input旁边加上“加载中动画”，正如上面的用户名的异步验证，可以修改如下。

```html
<form name="myForm">
    <!-- first the required, pattern and minlength validators are executed
       and then the asynchronous username validator is triggered -->
    <input type="text"
        name="myUsername"
        ng-model="data.username"
        minlength="10"
        pattern="^[-\w]+$"
        validate-username-availability
        required />
    <div ng-if="myForm.myUsername.$pending">
        Checking Username...
    </div>
</form>
```

## <span id="errors-rendering">错误消息渲染</span>

Angular会默认展示模板中定义的所有错误提示，我们有很多方式来优化这种提示。

### 使用ngIf或者ngShow/ngHide

一个input输入域在聚焦(focus)再失去焦点(blur)后，它的$touched属性都会是true。所以我们可以使用ngIf或者ngShow指令根据$touched的值来控制错误信息何时显示。

```html
<form name="myForm">
    <input type="text" name="colorCode" ng-model="data.colorCode" minlength="6" required />
    <div ng-if="myForm.colorCode.$touched">
        <div ng-if="myForm.colorCode.$error.required">...</div>
        <div ng-if="myForm.colorCode.$error.minlength">...</div>
        <div ng-if="myForm.colorCode.$error.pattern">...</div>
    </div>
    <nav class="actions">
        <input type="submit" />
    </nav>
</form>
```

但是思考一下如果我们没有聚焦到任何一个输入域就直接提交表单呢，是不是也应该展示所有错误信息？我们可以增加一个对myForm.$submitted属性的判断来修复这个bug。

```html
<form name="myForm">
    <input type="text" name="colorCode" ng-model="data.colorCode" minlength="6" required />
    <div ng-if="myForm.$submitted || myForm.colorCode.$touched">
        <div ng-if="myForm.colorCode.$error.required">...</div>
        <div ng-if="myForm.colorCode.$error.minlength">...</div>
        <div ng-if="myForm.colorCode.$error.pattern">...</div>
    </div>
    <nav class="actions">
        <input type="submit" />
    </nav>
</form>
```

现在这个表单就变得更加友好了。但是当错误信息太多了回发生什么？我们应该如何控制错误信息展示的时机和行为？如何给这些错误提示给一个优先级使得每次只显示一条错误提示？AngularJs 1.3通过一个新的ngMessages模块提供了这些功能。

### 使用ngMessages

下面使用ngMessages来显示错误信息。

```html
<form name="myForm">
    <input type="text" name="colorCode" ng-model="data.colorCode" minlength="6" required />
    <div ng-messages="myForm.colorCode.$error" ng-if="myForm.$submitted || myForm.colorCode.$touched">
        <div ng-message="required">...</div>
        <div ng-message="minlength">...</div>
        <div ng-message="pattern">...</div>
    </div>
    <nav class="actions">
        <input type="submit" />
    </nav>
</form>
```

使用ng-messages最多只会有一条错误信息会被展示。并且ng-messages指令会按照html模板中的顺序渲染第一条匹配的错误提示。注意到此处我们仍然使用了前面的ng-if属性来控制错误信息块是否显示。

为了能够再项目中使用ngMessage，我们需要下载并引入angular-messages.js文件，并将它作为我们应用的一个依赖注入。

```html
<script type="text/javascript" src="angular-messages.js"></script>
<script type="text/javascript">
    var ngModule = angular.module('myApp', ['ngMessages']);
</script>
```

扩展阅读：[ngMessage详解](http://www.yearofmoo.com/2014/05/how-to-use-ngmessages-in-angularjs.html)

## <span id="ng-model-options">控制何时更新数据模型(model)</span>

AngularJs 1.3中添加了一个新的ngModelOptions属性，通过对该属性的配置可以控制input元素上的ngModel何时更新。一个典型的应用就是防止值抖动(value debouncing)。通过这个属性可以让数据模型值(model value)只有在特定事件发生时才更新。以往默认的行为是每次字符输入都会更新数据模型值。

下面的例子展示的是只有在用户停止输入500毫秒后(500ms内不得再输入，否则重新计时)才出发绑定的所有验证器。

```html
<input type="text"
    name="myUsername"
    ng-model="data.username"
    minlength="10"
    pattern="^[-\w]+$"
    validate-username-availability
    ng-model-options="{ debounce : { 'default' : 500 } }"
    required />
```

同时可以通过设置blur属性值为0使得当输入域失去焦点时立即触发验证。

```html
ng-model-options="{ debounce : { 'default' : 500, blur : 0 } }"
```

另一个应用场景是根据用户输入的搜索字符串来改变当前页面的url地址的时候，可以观看前面的视频作详细了解。

## <span id="dynamic-forms">动态生成表单元素</span>

引入ng-if是因为它能很容易的添加和移除form的子区域。如此可以很好地控制表单中可选区域的添加和移除。想象一下如何编写一个只有在用户想要提供邮箱地址时候才展示邮箱收集输入框的form表单。

```html
<form>
    <div class="field">
        <label>
            <input type="checkbox" ng-model="data.allowNotifications" />
            Notify me via email 30 minutes before my event happens
        </label>
    </div>

    <div class="field" ng-if="data.allowNotifications">
        <label>Notification Email:</label>
        <input type="email" ng-model="data.notificationEmail" name="notificationEmail" required />
    </div>

    <input type="submit" />
</form>
```

上面代码的核心点就是邮箱输入框只会在checkbox为true时候被添加。由于这个输入域是根据状态添加到DOM中和从DOM中移除的，所以它的添加和移除会直接影响到整个form的验证状态。

### 嵌套重复的表格

如果我们现在需要不止一个邮箱输入框，那么我们该如何重构我们的HTML代码呢(保证表单的验证和错误提示方式与前面一致，每个输入域【input】和form都有自己的提示和验证)？我们可以使用ng-repeat指令生成需要的输入域并绑定数据模型。

```html
<div class="field" ng-if="data.allowNotifications">
    <div ng-repeat="email in notifcationEmails"> 
        <label>Email :</label>
        <input type="email" ng-model="email" name="notificationEmail" />
    </div>
</div>
```

上面的代码当某一个邮箱输入错误时会发生什么呢？我们如何知道是哪一个输入框错误呢？如何给错误的输入框给出单独的错误提示呢？解决方法是使用ng-form指令给重复元素创建嵌套的表单域。

```html
<div class="field" ng-if="data.allowNotifications">
    <div ng-form="emailForm" ng-repeat="email in notifcationEmails"> 
        <label>Email :</label>
        <input type="email" ng-model="email" name="notificationEmail" />
        <div ng-if="emailForm.notificationEmail.$error.email">
            You did not enter a valid email address
        </div>
    </div>

    <button ng-click="addAnotherEmail()">Add another email</button>
</div>
```

牛逼啊！等等...这满屏的错误提示你玩我呢？我只想对循环生成的同类型的邮箱地址验证给出一个总的提示就够了！绝对事儿逼啊...满足你，我们再在循环块的包含块上增加一个ng-form指令就行啦...233...就是这么叼...

```html
<div class="field" ng-if="data.allowNotifications" ng-form="notificationEmails">
    <div ng-form="emailForm" ng-repeat="email in notifcationEmails"> 
        <label>Email :</label>
        <input type="email" ng-model="email" name="notificationEmail" />
        <div ng-if="emailForm.notificationEmail.$error.email">
            You did not enter a valid email address
        </div>
    </div>

    <div ng-if="notificationEmails.$error.email" class="error">
        One or more emails have been incorrectly entered.
    </div>

    <button ng-click="addAnotherEmail()">Add another email</button>

</div>
```

## <span id="parsers-formatters">关于解析器和格式化</span>

ngModelController的解析器($parsers)和格式化($formatters)在1.3中没有任何改变，但是她们将不再应该用于处理验证逻辑。$parsers应该用于将显示值(view value)解析成一个不同数据模型值(model value)，$formatters则用于将模型值(model value)格式化成合适的显示值(view model)。有必要再次强调一个概念——模型值(model value)表示存储在scope中的值，而显示值(view value)是指存在于DOM中input元素上的值。

一个好的使用例子是用于处理时间相关的输入元素，如date, time, datetime, week, month等等。下面的实例中的显示值是一个字符串，而对应的模型值却是一个Date实例。来来来，上代码。

```javascript
var DATE_REGEXP = /^(\d{4})-(\d{2})-(\d{2})$/;

//grab ngModel inside of a directive
ngModel.$parsers.push(function(value) {
    if (value == '' || value == null || value == undefined) {
        // null means that there is no value which is fine
        return null;
    }

    if (DATE_REGEXP.test(value)) {
        return parseDateFromString(value);
    }

    // undefined means that the date syntax is invalid and
    // this will cause a parse error during validation
    return undefined;
});
```

$formatters是$parsers的逆过程。所以我们需要向下面这样把一个Date实例的模型值格式化成对应的字符串展示。

```javascript
//grab ngModel inside of a directive
ngModel.$formatters.push(function(value) {
    if(angular.isDate(value)) {
        value = $filter('date')(value, ['yyyy', 'MM', 'dd']);
    }
    
    return value;
});
```

因此$parsers和$formatters总是成对工作的，只有这样才能使得值在两种不同的类型或者要求下正确转换。

## <span id="work-progress">正在进行中的工作</span>

ngModel在AngularJs最初版本就已经存在，到现在1.3版本中的新特性极大的提升了开发者和使用者的体验。虽然现在新特性可能还有一两处不恰当的地方，但这些不足将在1.3的稳定版本中被修改。但现在你可以放心大胆的用RC0发布版中的新特性，因为所有API已经冻结，不会再做修改。所以勇敢向前吧，骚年...不要害羞:)

如果你发现有bug，或者有任何想法，欢迎到AngularJs的github仓库创建issue，记得在issue描述中@ matsko额。这样我才能能快速的看到您的反馈并响应。

非常感谢您阅读本篇文章。欢迎分享本文并在Twitter上关注[@yearofmoo](https://twitter.com/yearofmoo)。

***

处女翻，欢迎轻拍。  
译自：[Taming Forms in AngularJS 1.3](http://www.yearofmoo.com/2014/09/taming-forms-in-angularjs-1-3.html)