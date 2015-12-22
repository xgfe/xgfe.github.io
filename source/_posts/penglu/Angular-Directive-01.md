title: Angular-Directive-01
date: 2015-12-21 18:20:00
categories: penglu
tags: 
- angularjs
- directive

---
# AngularJs 指令基础
## Why
1. 直接操作DOM；
2. 通过移除重复代码来重构你应用的某些部分；
3. 创建一个新HTML标签共享使用。

## What
1. 定义:连接应用的逻辑和HTML DOM对象.
2. 具体作用
	1. 扩展HTML标签。
	2. 修改DOM结构,绑定scope与DOM。
3. 使用方式
	1. 元素: ```<my-directive></my-directive>```
	2. 属性:```<input my-directive>```
	3. 注释: ```<!-- directive: my-directive-->```
	4. css类: ```<input class="my-directive"> ```
	
## How
### 如何定义
#### directive()   
```
angular.module('app', []);
angular.module('app').directive('myDir', function(){
	    return myDirectiveDefinition;
});
```
- 备注:
	-  每个指令必须注册一个模块.
	-  驼峰命名(xY)
		- 使用: x-y | x:y | data-x-y | x-x-y  
		
#### 指令定义字段
1. restrict
	- 定义：描述指令声明风格.
	- 取值：一种或几种混合
		- E:元素
		- A:属性(默认)
		- C:样式类
		- M:注释类
	- Demo
	
	```
	  <script>
        angular.module('app', []);
        angular.module('app').directive('myDirective',function(){
            return {
                restrict:'AE',
                template:'<div>I am my directive</div>'
            }
        });
    </script>
    <my-directive></my-directive>  <!-- E:元素 -->
    <div my-directive></div>   <!-- A:属性 -->
	```
2. priority
	1. 定义：指定指令生效顺序.
	2. 取值：整数(默认为0).
		- 数值越高会越优先运行.
	3. Demo
	 
  ```
   <script>
    angular.module('app', []);
    angular.module('app').directive('priorityHigh',function(){
        return {
            restrict:'AE',
            priority: 100,
            template:'<div>I am my directive,priority equals to 100</div>'
        }
    });
    angular.module('app').directive('priorityLow',function(){
        return {
            restrict:'AE',
            priority: 101,
            template:'<div>I am my directive</div>'
        }
    });
</script>
<div priority-high priority-low></div>
<!-- 结果显示:I am my directive -->
  ```
  ```
   <script>
    angular.module('app', []);
    angular.module('app').directive('priorityHigh',function(){
        return {
            restrict:'AE',
            priority: 100,
            template:'<div>I am my directive,priority equals to 100</div>'
        }
    });
    angular.module('app').directive('priorityLow',function(){
        return {
            restrict:'AE',
            template:'<div>I am my directive</div>'
        }
    });
</script>
<div priority-high priority-low></div>
<!-- 结果显示:I am my directive,priority equals to 100 -->
```

3. template & templateUrl
	1. 相同:定义模版包裹或替换元素中内容.通过template或templateUrl指定DOM元素.
	2. 不同
		- template:通过字符串描述模板内容。
		- url:可以从服务器加载模版文件。
	3. 备注
		1. 如果同时定义template和templateUrl,会报错,并且templateUrl定义失效. 
		2. 使用script定义模版,会将根据定义的id,将模版缓存到'$templateCache'中,然后templateUrl中使用id就可以获取到模版内容.
	4. Demo
		
	```
	<script type="text/ng-template" id="myTemplate.html">
	    <div>hello,templateUrl.</div>
	</script>
	<script>
	    angular.module('app', []);
	    angular.module('app').directive('templateDirective',function(){
	        return {
	            restrict:'AE',
	            template:'<div>hello,template</div>'
	        }
	    });
	    angular.module('app').directive('urlDirective',['$templateCache',function($templateCache){
	        console.log($templateCache.get('myTemplate.html'));
	        return {
	            restrict:'AE',
	            templateUrl:'myTemplate.html'
	        }
	    }]);
	</script>
	<template-directive></template-directive>
	<url-directive></url-directive>
	```
4. replace
	1. 定义：是否替换元素.
	2. 取值：true ｜ false
		- true:使用模版来替换元素.如果存在template,则被替换标签上的属性会被绑定到template的根元素上。
		- false:模版添加到元素内部(默认)
	3. Demo
	
	```
		<script>
	        angular.module('app', []);
	        angular.module('app').directive('templateDirective',function(){
	            return {
	                restrict:'AE',
	                replace:true,
	                template:'<div>hello,template</div>'
	            }
	        });
	    </script>
	    <div template-directive name="111">
	        template-directive
	    </div>
	```
5. transclude
	1. 定义：元素内容是否插入新模版 。
	2. 取值：true｜false
		- true:模版中使用ng-transclude重新插入
	3. Demo
	
	```
    <script>
    angular.module('app', []);
    angular.module('app').directive('myDirective',function(){
        return {
            restrict:'AE',
            replace:true,
            transclude: true,
            template:'<div>hello,template<span ng-transclude style="color:red;"></span></div>'
        }
    });
    </script>
    <div my-directive>
        the content of transclude.
    </div>
	```
6. scope
	1. 定义：指令可访问scope对象.
	2. 取值：true｜false｜ { }
		- true:新scope
			- 创建新scope,继承外层控制器scope。
			- Demo
			
			```
			<body ng-controller="myController">
    <script>
        angular.module('app', []);
        angular.module('app').directive('myDirective',function(){
            return {
                restrict:'AE',
                scope: true,
                template:'<div>hello,{{userName}},my scope id is {{scopeId}},my parent id is {{parentId}}</div>',
                controller: function($scope){
                    $scope.scopeId = $scope.$id;
                    $scope.parentId = $scope.$parent.$id;
                }
            }
        });
        angular.module('app').controller('myController', ['$scope', function($scope){
            $scope.userName = 'penglu';
            $scope.scopeId = $scope.$id;
        }])
    </script>
    <div>{{scopeId}}</div>
    <div my-directive></div>
</body>
			```
		- false:现有scope
			- 指令对应Dom元素上存在的对象。 
			
			```
			<body ng-controller="myController">
    <script>
        angular.module('app', []);
        angular.module('app').directive('myDirective',function(){
            return {
                restrict:'AE',
                template:'<div>hello,{{userName}}</div>'
            }
        });
        angular.module('app').controller('myController', ['$scope', function($scope){
            $scope.userName = 'penglu';
        }])
    </script>
    <div my-directive></div>
</body>
			```
		- {}:独立scope
			- 创建新scope,不会从父对象继承模型的任何属性。
			- 默认情况下不可访问父scope模型中的任何东西。
	3. 独立scope:可以通过传递属性名映射的方式把父scope中指定的属性传递给这个独立的scope.	(绑定策略:三种在scope和父scope之间传递数据的方式)
		-  共同点
			-  	通过标签属性(xx-yy)传递(注意如果通过data-xx的方式传递，则scope中接收要忽略data-.即直接接收xx)
			-  在scope中通过驼峰(xxYy)的方式接收,如果外层scope传递变量在独立scope中不改变名称，则可以直接使用scope:{xxYy : '=|@|&'}的方式接收，但是如果要使用不同的变量名则可以使用scope:{yyXx: '=|@|&xxYy'}的方式接收.
		-  @: 当前属性作为字符串传递.通过在属性中插入{{}}来绑定来自外层scope的值。
			- 通过这种方式，只能单向传递数据，独立scope可以看做复制了一份外层scope的变量。在独立scope中修改变量不会引起外层scope值的变化.
			- 通过这种方式,在独立scope中接收到的字符串,如果传递的是对象或者数组,则会变转换成json字符串,	如果在独立$scope中需要使用,则需要使用$scope.$eval()函数或者$parse服务进行解析，**注意:解析后的数据必须使用新变量来接受，否则scope域值改变，但是dom绑定的数值仍未变化**
			- Demo
			
			```
			<body ng-controller="myController">
    <script>
        angular.module('app', []);
        angular.module('app').directive('myDirective',['$parse', function($parse){
            return {
                restrict:'AE',
                scope: {
                    subUser: "@user",
                    subFamily: "@family"
                },
                template:'<div>{{user.name}},My family:<span ng-repeat="item in family track by $index">{{item}}&nbsp;</span></div><div>{{subUser.name}},My family:<span ng-repeat="item in subFamily track by $index">{{item}}&nbsp;</span></div>',
                link: function(scope){
                    scope.title = '独立scope';
                    scope.user = scope.$eval(scope.subUser);  // 使用$scope的$eval方法解析,结果重新赋值
                    scope.subUser = scope.$eval(scope.subUser);  // 使用$scope的$eval方法解析
                    scope.family = $parse(scope.subFamily)(); // 使用$parse服务解析,结果重新赋值
                    scope.subFamily= $parse(scope.subFamily)(); // 使用$parse服务解析
                }
            }
        }]);
        angular.module('app').controller('myController', ['$scope', function($scope){
            $scope.user =  {
                name : 'penglu'
            };
            $scope.family = ['father', 'mother', 'grandMother'];
        }])
    </script>
    <div my-directive user="{{user}}" family="{{family}}" ></div>
    </body>
			```
		-  =: 双向数据绑定
			-  通过这种方式，可以实现双向数据绑定，可以看成是独立scope拿到一个指向外层scope的指针。内外层数据的修改都是同步进行的。
			-  通过这种方式可以传递对象、数组。即数据按照原格式进行传递.
			-  Demo

			```
			<body ng-controller="myController">
    <script>
        angular.module('app', []);
        angular.module('app').directive('myDirective',['$parse', function($parse){
            return {
                restrict:'AE',
                scope: {
                    user: "=",
                    family: "="
                },
                template:'<div>{{user.name}},My family:<span ng-repeat="item in family track by $index">{{item}}&nbsp;</span></div><button ng-click="changeUser()">修改user</button><button ng-click="changeFamily()">修改family</button>',
                controller: function($scope){
                    $scope.changeUser = function(){
                        $scope.user.name = '彭璐 - 独立scope';
                    };
                    $scope.changeFamily = function(){
                        $scope.family.push('独立scope');
                    };
                }
            }
        }]);
        angular.module('app').controller('myController', ['$scope', function($scope){
            $scope.user =  {
                name : 'penglu'
            };
            $scope.family = ['father', 'mother', 'grandMother'];
        }])
    </script>
    <div>外层controller:{{user.name}},My family:<span ng-repeat="item in family track by $index">{{item}}&nbsp;</span></div>
    <div my-directive user="user" family="family" style="color: red;"></div>
</body>
			```
		-  &: 传递一个来自父scope的函数.
 	4. $eval与$parse 
 		- $eval:scope域上的一个函数,在当前scope域上执行传入的表达式
 			- $eval([expression], [locals]); 
 				- 第一个参数为表达式(可以是一个字符串，也可以是一个传入scope的匿名函数) ，如果是一个字符串，则根据表达式定义规则进行计算和转换。如果是一个函数，则根据传入的scope对函数内的表达式进行计算.
 				- Demo
 				
 				```
 			    <script>
        angular.module('app', []);
        angular.module('app').controller('myController', ['$scope', '$rootScope', function($scope, $rootScope){
            var scope = $rootScope.$new();
            scope.a = 1;
            scope.b = 2;
            console.log(scope.$eval('a+b'));  // 3
            console.log(scope.$eval('a+b',{a:3,b:4}));  // 7
            console.log(scope.$eval(function(scope){return scope.a + scope.b;}));  //3
        }])
    </script>
     	```
     	
     - $eval():可以将json字符串转换为对象或者数组
     		- Demo
     	
     	```
     	<body ng-controller="myController">
<script>
    angular.module('app',[]);
    angular.module('app').controller('myController', ['$scope', function($scope){
        $scope.familyStr= '["father","mother","grandMother"]';
        $scope.userStr = '{"name":"penglu"}';
        $scope.family = $scope.$eval($scope.familyStr);
        $scope.user = $scope.$eval($scope.userStr);
    }]);
</script>
<div><span>{{userStr}} --></span>{{user.name}}</div>
<p>{{familyStr}}</p>
<ul>
    <li ng-repeat="item in family">{{item}}</li>
</ul>
</body>
     	```
     	
 	- $parse:将表达式转换为一个函数
 		- 备注
 			- 一个服务，使用之前必须进行注入。
 			- 返回一个函数
 				- function(context, locals)
 					-  context:对象，一般是一个scope对象，指定表达式所在的作用域
 					-  locals:对象，可以用来覆盖context指定的对象
					- assign:如果表达式解析的是一个变量，那么返回的函数具有assign属性，可以通过assign属性得到一个setter函数，用来设置表达式对应变量的值 	
			- Demo
			
			```
			<body ng-controller="myController">
	<script>
	    angular.module('app',[]);
	    angular.module('app').controller('myController', ['$scope', '$parse', function($scope, $parse){
	        var getter_user = $parse('user.name');
	        var getter_family = $parse('family');
	        var setter_user = getter_user.assign;
	        var context = {user:{name:'angular'},family:['dad', 'mother', 'sister']};
	        var locals = {user:{name:'local'}};
	        console.log(getter_family(context));  // ['dad', 'mother', 'sister']
	        console.log(getter_user(locals));  // local
	        console.log(getter_user(context));  // angular
	        console.log(setter_user(context,'pl'));  // 修改context对象中的user.name = 'pl'
	    }]);
	</script>
	</body>
			```
			
		-  $parse:用于解析json字符串
			- 备注:解析字符串的时候，没有assign属性  
			- Demo
			
			```
			<body ng-controller="myController">
<script>
    angular.module('app',[]);
    angular.module('app').controller('myController', ['$scope','$parse', function($scope, $parse){
        $scope.familyStr= '["father","mother","grandMother"]';
        $scope.userStr = '{"name":"penglu"}';
        var getterUser = $parse($scope.userStr);
        var getterFamily = $parse($scope.familyStr);
        $scope.family = getterFamily($scope);
        $scope.user = getterUser($scope);
    }]);
</script>
<div><span>{{userStr}} --></span>{{user.name}}</div>
<p>{{familyStr}}</p>
<ul>
    <li ng-repeat="item in family">{{item}}</li>
</ul>
</body>
			```  
			
	 - $eval和$parse对比
	 		- 如果只需要通过解析表达式获得变量则使用$eval(单向),如果需要对获得的变量做修改则使用$parse(双向)
7. controller&require
	1. controller:实现需要彼此通信的嵌套指令.(配合require)
	2. require: 指定需要依赖指令。
		- ^: 需要同时遍历Dom树去查找指令,被依赖的指令在DOM树中需要在指令的上层(父节点)
		- ?: 控制器可选(如果获取不到该指令的控制器不会报错)
	3. 备注
		- 如果依赖多个指令，需要注入多个控制，则require接收数组；同时在link函数的第四个参数也是所依赖指令controller的数组。
		- 依赖指令的controller需要在link函数中注入.
	4. Demo
		
		```
		<script>
    angular.module('app',[]).directive('requireDir', function(){
        return {
            restrict:'EA',
            replace: true,
            transclude: true,
            scope:true,
            template:'<div>{{title}}<div ng-transclude></div></div>',
            controller: function($scope){
                $scope.title = '被依赖的指令';
                this.setTitle = function(title){
                    $scope.title = title;
                };
                this.getTitle = function(){
                    return $scope.title;
                };
            }
        }
    });
    angular.module('app').directive('myDir',function(){
        return {
            restrict:'EA',
            require: '^?requireDir',
            link: function($scope, ele, attrs, requireCtrl){
                // 调用依赖控制器中方法
                requireCtrl.setTitle(attrs['title']);
            }
        }
    });
</script>
   <require-dir></require-dir>
   <require-dir>
       <my-dir title="penglu"></my-dir>
   </require-dir>
</body>
		```
8. link & compile
	1. Angular初始化
		- 加载脚本:加载库、ng-app
		- 编译阶段:转换模版(遍历Dom,标识指令,根据定义指令规则,转换Dom结构.)
		- 连接阶段:修改视图中数据
			- 每条指令运行一个link函数
			- 创建监听器(Dom｜模型) 
	2. compile与link的不同点
		- compile:模版自身进行；link: 模型和视图之间进行动态关联。
		- compile:编译阶段运行一次;link:对于指令的每个实例,都会执行一次.
	3. compile: function(ele, attrs, transclude)
		- ele:指令元素或者指令所在标签元素
		- attrs:指令元素上的属性集合或者指令所在标签元素的属性集合
		- transclude: 链接函数
		- compile函数执行完返回一个link函数。
	4. link: function(scope, ele, attrs, controller)
		- scope:指令作用域
		- ele:指令元素或者指令所在标签元素
		- attrs:指令元素上的属性集合或者指令所在标签元素的属性集合
		- controller:指令依赖其他指令的控制器数组集合
	5. 备注
		- 如果同时设置compile和link，则link函数失效，因为compile会反回一个link函数
		- 一般只使用compile，然后再返回函数中绑定scope，或者只使用link函数。
		- 可以在compile或者link函数中操作dom，绑定一些事件
   6. Demo
   
   ```
   <body  ng-controller="MainCtrl">
    <script>
        angular.module('app',[]);
        angular.module('app').controller('MainCtrl', ['$scope', function($scope){
            $scope.num = 5;
        }]);
        angular.module('app').directive('rabbitRepeater', function($document){
            return {
                restrict: 'A',
                compile: function(ele, attrs){
                    console.log('compile');
                    // 数据绑定发生在link中，因此如果需要动态绑定model的，都需要使用link设置
                    // 可以在compile函数中返回link函数,则return的函数会执行
                    return function(scope, ele, attrs, controller){
                        console.log('compile & link');
                        // compile与link不能同时设置,如果同时设置则link函数无效。
                        var template = $(ele).children().clone();
                        for(var i=0; i<attrs.rabbitRepeater - 1; i++){
                            $(ele).append(template.clone());
                        }
                    }
                },
                link: function(scope, ele, attrs){
                    console.log('link');
                    // compile与link不能同时设置,如果同时设置则link函数无效。
                    var template = $(ele).children().clone();
                    for(var i=0; i<attrs.rabbitRepeater - 1; i++){
                        $(ele).append(template.clone());
                    }
                }
            }
        });
    </script>
    <ul rabbit-repeater="{{num}}">
        <li >哈哈哈</li>
    </ul>
</body>
   ```
	
## 一起来定义指令
1. 指令使用:定义一个pagination指令，用于翻页等功能.
```
<pagination page-num='{{pageNum}}' current-page= '{{currentPage}}'></pagination>
```
2. 功能分析
  - 根据pageNum动态生成Dom结构.
  		- 如果变化也会重新生成Dom
  - 当前选中页为激活状态.
  - 如果当前页为末｜首页，则’下｜上一页’设置为不可用.
  - 页面点击切换当前页.
  - 点击’上｜下一页’进行切换，如果当前页为’首｜末页’则不切换
3. 代码实现:class使用bootstrap

```
<!DOCTYPE html>
<html ng-app="app">
<head lang="en">
    <meta charset="UTF-8">
    <title>restrict</title>
    <!-- 文件引入 -->
    <link rel="stylesheet" href="../css/bootstrap.css">
    <script src="../lib/jquery/dist/jquery.min.js"></script>
    <script src="../lib/angular/angular.js"></script>
    <script src="../lib/angular-animate/angular-animate.js"></script>
    <script src="../lib/angular-bootstrap/ui-bootstrap-tpls.js"></script>
    <script>
        angular.module('app', []).controller('paginationCtrl', ['$scope', function($scope){
            $scope.pageNum = 5;
            $scope.currentPage = 1;
        }]);
        angular.module('app').directive('pagination', function(){
            return {
                restrict: 'EA',
                scope:{
                    pageNum: '@',
                    currentPage: '@'
                },
                templateUrl:'pagination.html',
                link: function(scope, ele, attrs){
                    scope.pages = [];

                    // 根据pageNum生成页码数组
                    scope.$watch('pageNum', function(val){
                        scope.pages.length = val;
                        for(var i=0; i<val; i++){
                            scope.pages[i] = i+1;
                        }
                        if(scope.currentPage > val){
                            scope.selectPage(val);
                        }
                    });

                    /**
                     * 判断当前激活页是不是第一页,如果是,则返回true
                     * @returns {boolean}
                     */
                    scope.noPrevious = function(){
                        return scope.currentPage == 1;
                    };

                    /**
                     * 判断当前激活页是不是最后一页,如果是,则返回true
                     * @returns {boolean}
                     */
                    scope.noNext = function(){
                        return !(scope.currentPage < this.pages.length);
                    };

                    /**
                     * 判断当前页是不是激活页,如果是,则返回true
                     * @param {num} page 当前页
                     * @returns {boolean}
                     */
                    scope.isActive = function(page){
                        return page == scope.currentPage;
                    };


                    /**
                     * 根据传入页码选择当前页,如果当前页是激活状态则不选中，否则选中
                     * @param {num} page 选择页
                     */
                    scope.selectPage = function(page){
                        if(!scope.isActive(page)){
                            scope.currentPage = page;
                        }
                    };

                    /**
                     * 选中前一页
                     */
                    scope.selectPrevious = function(){
                        if(!scope.noPrevious()){
                            scope.selectPage(--scope.currentPage);
                        }
                    };

                    /**
                     * 选中后一页
                     */
                    scope.selectNext = function(){
                        if(!scope.noNext()){
                            scope.selectPage(++scope.currentPage);
                        }
                    };
                }
            }
        });
    </script>
</head>
<body ng-controller="paginationCtrl">
    <pagination page-num = "{{pageNum}}"   current-page="{{currentPage}}"></pagination>
</body>
</html>
```