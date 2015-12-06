title: $scope-ngModel-angularJs
date: 2015-12-06 14:20:00
categories: penglu
tags: 
- angularjs
- scope
- ng-model

---

# AngularJs中$scope与ng-model数据动态绑定问题

## 问题描述
在使用AngularJs中的[$modal](https://angular-ui.github.io/bootstrap/#/modal),打开一个弹出框($modal.open),则弹出框会拥有一个$scope。我们会在$scope下面定义一些变量，然后使用ng-model绑定到打开的弹框对应页面上进行数据的展示与修改(双向数据绑定)，但是如果直接使用变量直接进行绑定会造成弹框的$scope域拿不到修改的数据。

## 问题实例
1. 使用$modal.open打开一个弹框,如下图:
	<img src='http://p0.meituan.net/sds/56a90252a136f852e696980470ceecdc35095.png'>
2. 我们理解的是query绑定在$modal.open对应的controller中的$scope中，当在输入框输入数据时，query的值会变化，则$modal.open的$scope中的query会监听到变化。但是实际上我们在页面看到了变化，却在controller中不能通过$scope.query拿到。问题关键在于，打开的modal内部又有自己的$scope,如下图：<img src='http://p0.meituan.net/sds/8871fdf7f893c5817f3dc5faef159caf350554.png'>
3. 而input所属于$scope也是controller对用$scope的子孙$scope,如下图：<img src="http://p1.meituan.net/sds/94dac1e3dc55ce19821289f6549eec69305247.png">
4. 因此当input中键入内容时，ng-model会自动在input所在的$scope添加query这个变量而不会影响父$scope中的query，而如果用ng-model绑定一个父级的对象，就能解决此问题。

## 还原问题知识点
1. 以上问题，以及此类问题都是因为父$scope与子$scope中变量的控制引起的。
2. 通过三组代码来剖析问题
	1. 如果不在父上设置query变量，则当在input中进行输入的时候，会在子$scope(即input所在$scope)上动态添加变量(无论是以对象的形式还是非对象)
		- 代码如下
		
		```
		<!-- html代码 -->
		<div ng-controller="SupperController">
		    <div ng-controller="SubController">
		        <label>ng-model = status.query</label><input type="text" ng-model="status.query">
		        <label>ng-model = query</label><input type="text" ng-model="query">
		    </div>
		</div>
		
		// js代码
		var app = angular.module('app', []);
		
		// 父controller
		app.controller('SupperController', function($scope) {
		    $scope.ctrl = "SupperController";
		});
		
		// 子controller
		app.controller('testController', function ($scope) {
		    $scope.ctrl = "SubController";
	})
		```
		- 代码运行结果，$scope查看
		<img src="http://p1.meituan.net/sds/99d0c93b3b12dfe6b615bee238960ebc89494.png">
		- input输入值之后$scope查看
		<img src="http://p0.meituan.net/sds/d1498ba90b84a19348d386ee46ced076188895.png">
	2. 在父$scope上设定query变量(非对象)，子$scope中的input中使用ng-model绑定.
		 - 代码如下
		 
		 ```
		<!-- html代码 -->
		<div ng-controller="SupperController">
		    <div ng-controller="SubController">
		        <input type="text" ng-model="query">
		    </div>
		</div>
		// js代码
		var app = angular.module('app', []);	
		// 父controller
		app.controller('SupperController', function($scope) {
		    $scope.ctrl = "SupperController";
		    // 父$scope设置query
		    $scope.query = "1";
		});
		// 子controller
		app.controller('testController', function ($scope) {
		    $scope.ctrl = "SubController";
		})
		 ```
		 
		- 代码运行结果，$scope查看图
		<img src="http://p0.meituan.net/sds/28bf7f7e91b61eaaab25b2f05126de8e126669.png">
		- 在input输入框输入2之后，$scope查看图
		<img src="http://p1.meituan.net/sds/a1177fabf4630c504d077b5c15427161152873.png">
	3. 在父$scope上设定query变量(对象)，子$scope中的input中使用ng-model绑定
		- 代码如下
		
		```
		<!-- html代码 -->
		<div ng-controller="SupperController">
		    <div ng-controller="SubController">
		        <input type="text" ng-model="status.query">
		    </div>
		</div>
		// js代码
		var app = angular.module('app', []);
		
		// 父controller
		app.controller('SupperController', function($scope) {
		    $scope.ctrl = "SupperController";
		    // 父$scope设置query
		    $scope.status = {};
		    $scope.status.query = "1";
		});
		
		// 子controller
		app.controller('testController', function ($scope) {
		    $scope.ctrl = "SubController";
		})
		``` 
		- 代码运行结果，$scope查看图
		<img src="http://p1.meituan.net/sds/a1177fabf4630c504d077b5c15427161152873.png" >
		- 在input输入框输入2之后，$scope查看图
		<img src="http://p0.meituan.net/sds/8e6def241a0db6c159073659f90c0585167436.png" >
		
## 问题总结
1. 使用ng-model进行双向数据绑定，当数据不存在的时候(没有在$scope中进行定义),则会在ng-model绑定标签的$scope中动态添加属性(对象或者常规变量)；而如果在祖先$scope对变量做了定义，则当祖先$scope以对象形式设定，则当通过ng-model绑定标签输入数据时不会在ng-model绑定标签的$scope中动态添加属性，而是修改祖先$scope中的属性，而如果以普通方式，则会在ng-model绑定标签的$scope中动态添加属性。
2. 对于父$scope与子$scope的问题，只有父$scope通过对象设定一个变量，则子$scope上面可以使用ng-model进行数据绑定来动态对数据进行修改。