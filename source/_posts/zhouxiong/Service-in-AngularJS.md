title: AngularJS的服务
date: 2016-09-08 16:00:00
categories: zhouxiong
tags:
- AngularJS
- 依赖注入
- Service
---
在AngularJS中有许多内置的标准化服务组件，同时我们也可以自定义服务组件。在AngularJS中所有Service服务组件都是通过依赖注入进行管理的。本篇文章将通过以下几点进行讲解。
1.依赖注入
2.AngularJS中的内置服务
3.自定义AngularJS服务


<!--more-->
## 依赖注入
	
依赖注入（Dependency Injection）是一种经典的设计模式，主要是用来处理组件如何获取依赖的问题。依赖注入可以简单的理解为：在一个容器中我们定义了很多个模块和组件化服务，当模块需要某些服务时，只需要跟容器说我需要这些服务，并且只需要提供服务的名称，容器就会自动提供这些服务的实例。调用服务的模块不需要考虑这些服务是怎么来的，这些服务会由容器通过依赖注入提供给对应的模块。

### 注入声明方式

AngularJs一共提供了三种注入方式

- 推断式的注入声明

 ```
   var app = angular.module('myApp', []);
   app.controller('myCtrl', function ($scope, $window) {
   	   // do something    
   });	
 ```

	如果没有明确的声明，AngularJS会假定参数名称就是函数依赖，它会使用`$injector`将这些参数注入进对象实例。

	**注意:**我们并不推荐使用这种方式，因为代码一旦被压缩，参数名称就会被替换为简单的字符，AngularJS将会找不到这些函数依赖，从而导致注入失败。
	
- 显示注入声明

 ```
    var app = angular.module('myApp', []);

    app.controller('myCtrl', myCtrl);

    myCtrl.$inject = ['$scope', '$window'];

    function myCtrl(a, b) {
        // do something
    }
 ```
 这种方式能够明确定义函数被调用时所需要的依赖关系。我们只需要为函数对象新增一个`$inject`属性，值为一个字符串数组，数组的每个元素代表依赖名称，注意数组元素必须和注入参数的顺序一个一个对应，在字符串的拼写时必须与定义的时候一致。使用这种方式参数相当于形参，名称并没有多大关系，因此代码压缩也不会影响使用。
 
- 行内注入声明

 ```
   var app = angular.module('myApp', []);

    app.controller('myCtrl', ['$scope', '$window', function ($scope, $window) {
         // do something
    }]);
 ```
 
 这种方式是显示注入声明方式的一种更为简洁的表现方式。它允许我们在定义一个AngularJS对象时直接传入一个参数数组而不是一个函数，参数的最后一项是依赖注入的目标函数本身，其他项是字符串，依次对应该函数注入的依赖名字，同样函数的参数名也与前面的字符串一一对应，这种情况下也不怕代码压缩。

- 注意的地方

 当依赖注入的服务定义在了另一个模块中，首先需要将该模块注入到被依赖的模块中，然后才能调用该模块的服务
 
 ```
   angular.module('myModule', [])
            .factory('myFactory', function () {
                return {};
            });

    var app = angular.module('myApp', ['myModule']);  //首先需要注入myModule模块，才能使用myFactory服务

    app.controller('myCtrl', ['$scope', 'myFactory', function ($scope, myFactory) {
        console.log(myFactory);
    }]);
 ```

### Strick Mode

通过在ng-app所在的DOM元素中添加ng-strict-di切换到严格的依赖注入模式下。在Strict模式下使用隐式的注入声明会报错

```
<!DOCTYPE html>
<html lang="en" ng-app="myApp" ng-strict-di>
<head>
    <meta charset="UTF-8">
    <script src="../../../js/lib/angular.min.js"></script>
</head>
<body>
<script>
    /*--------------方式1:推断式注入声明start--------------------------------------------*/
    var app = angular.module('myApp', []);
    app.factory('willBreak', function ($rootScope) {
        //在这里会报错，$rootScope没有显示声明注入
        return {};
    });
    app.run(['willBreak', function (willBreak) {

    }]);
    /*--------------方式1:推断式注入声明end--------------------------------------------*/

    /*--------------方式2:显式注入声明start--------------------------------------------*/
    var app = angular.module('myApp', []);

    app.factory('willBreak', wilBreakFn);
    wilBreakFn.$inject = ['$rootScope'];
    function wilBreakFn($rootScope) {
        return {};
    }
    app.run(['willBreak', function (willBreak) {

    }]);
    /*--------------方式2:显式注入声明end--------------------------------------------*/

</script>
</body>
</html>

```

### 依赖注入的优点

- 各模块之间的解耦，每个部分专注于自己的功能，对象的注入通过容器来完成
- 避免全局对象的污染

## AngularJS内置服务
服务是一个对外提供某个特定功能，如消息服务、文件压缩等的独立模块。在AngularJS中，服务是一个单例对象或者函数。具有以下的两个特点：

- 服务是一个单例，即无论这个服务被注入到任何地方，对象始终只有一个实例
- 定义服务的方式也是通过function，但是与我们自己定义一个function然后在其他地方调用不同，因为服务是被定义在一个模块中，所以其使用的范围是可以被管理的，这一点体现了AngularJS非常强的避免全局变量污染意识。

### 代表性的内置服务

- $rootScope

 每个应用都仅有一个rootScope。其他的例如controller中的scope都是rootScope的后代scope。scope通过监听数据层的变化，实现了数据层和模型层的分离。注册在`$rootScope`上的值可以被子`$scope`覆盖。
 
 ```
 <div ng-controller="myCtrl">
        {{name}}
    </div>

    <script>
        var app = angular.module('myApp', []);

        app.run(function ($rootScope) {
            $rootScope.name = 'kingx'; 
        });

        app.controller('myCtrl', function ($scope) {
            //当子scope定义了name属性时，则显示当前name的值；
            //当未定义时，则显示的是$rootScope的值
            $scope.name = 'kingxxxxx';
        });

    </script>
 ```
 
- $http

 `$http`服务是AngularJS和远程服务器通过ajax请求进行通信的核心服务。`$http`的API是基于`$q`服务的，它返回的是一个promise。根据返回的状态码判断执行成功的回调还是失败的回调，当状态码为200到299时执行成功回调，不在这个范围内的都执行失败回调。

 ```
 $http({
        method: 'GET',
        url: '/someUrl'
    }).then(function successCallback(response) {
        //异步请求成功
    }, function errorCallback(response) {
        //异步请求失败
    });
```

- $q

 `$q`服务是AngularJS自己封装的一种对Promise的实现，使用`$q`一般有两种方式。
 
 - $q构造方法
  	
  	 `$q`的构造方法接收一个函数，该函数接收resolve和reject两个参数，分别代表成功和失败后的回调函数
  	
	 ```
	function asyncHandle() {
            return $q(function (resolve, reject) {
                if($scope.flag) {
                    resolve('invoke success');
                    $scope.flag = false;
                } else {
                    reject('invoke fail');
                    $scope.flag = true;
                }
            });
        }
        
        var promise = asyncHandle();

        promise.then(function (result) {
            console.log('congratulation,' + result);
        }, function (result) {
            console.log('i am sorry, ' + result);
        })
	
	 ```
 
 - $q的defer()方法

 	 ```
 	var defered = $q.defer();
        var promise = defered.promise;

        promise.then(function (result) {
            console.log('congratulation,' + result);
        }, function (result) {
            console.log('i am sorry, ' + result);
        });

        if($scope.flag){
            defered.resolve('invoke success');
            $scope.flag = false;
        } else {
            defered.reject('invoke fail');
            $scope.flag = true;
        }
 	 ```


- $location

 `$location`是用于解析地址栏URL的服务，可以监听和改变地址栏的URL。当改变地址栏或者点击前进和后退时可以与浏览器同步URL
 
 ![location的各方法](/uploads/zhouxiong/Service-in-AngularJS/location.png)
 
 - absUrl( )：只读；返回带有所有的片段的url
 - host( )：只读；返回url中的主机路径
 - port( )：只读；返回当前路径的端口号
 - protocol( )：只读；返回当前url的协议
 - hash( )：读、写；当带有参数时，返回哈希碎片；当在带有参数的情况下，改变哈希碎片时，返回$location
 - path( )：读、写；当没有任何参数时，返回当前url的路径；当带有参数时，改变路径，并返回$location
 - search( )：读、写；当不带参数调用的时候，以对象形式返回当前url的搜索部分
 - replace( )：如果被调用，就会用改变后的URL直接替换浏览器中的历史记录，而不是在历史记录中新建一条信息，这样可以阻止『后退』

## AngularJS自定义服务

在AngularJS中，系统内置的服务都是以`$`开头，所以我们的自定义服务尽量避免以`$`开头。自定义服务的方式有如下几种：

- 使用Module的provider方法
- 使用Module的factory方法
- 使用Module的service方法

### 使用Module的provider方法

- 语法糖

 ```
    app.provider('myProvider', function () {
        this.$get = function () {
            	//do somthing
        };
    });
 ```
- 通过provider方法创建的服务一定要包含`$get`方法，provider注入的结果就是`$get`方法返回的结果，如果不包含`$get`方法，则程序会报错。

 ```
Provider 'myProvider' must define $get factory method.
 ```

- 如果在provider中有返回值，只能返回this或者基本数据类型或者具有$get方法的对象类型

- 在三种创建服务的方法中，只有使用provider方法创建的服务才可以传进config函数，以用于在对象启用之前，对模块进行配置。但是在config中进行配置的只能是在`$get`函数之外定义的变量，在下面定义的provider中只有`artist`与`thingFromConfig`两个变量可以被访问到，而`getArtist`与`getThingFromConfig`两个方法是不能被在config函数中访问到的。
- 而且在注入config函数中时，参数名必须由`服务名+Provider`组成，例如下面的例子注入到config函数中的就是`myProviderProvider `

 ```
   app.controller('myCtrl', ['$scope', 'myProvider', function ($scope, myProvider) {
        console.log(myProvider.getThingFromConfig());  //kingx name
    }]);

    app.provider('myProvider', function () {
        this.artist = '';
        this.thingFromConfig = '';

        this.$get = function () {
            var that = this;
            return {
                getArtist: function () {
                    return that.artist;
                },
                getThingFromConfig: function () {
                    return that.thingFromConfig;
                }
            }
        };
    });

    app.config(function (myProviderProvider) {
        myProviderProvider.thingFromConfig = 'kingx name';
    });
```

### 使用Module的factory方法

- 语法糖

 ```
 app.factory('myFactory', function ($http) {
        //不一定是要对象类型，实际为任意类型
        var factory = {};
        return factory;
    });
 ```
 
- 通过factory方法创建的服务必须有返回值，即必须有return函数，它可以返回任意类型的值，包括基本数据类型或者对象类型。如果没有return函数，则会报错。

 ```
 Provider 'myFactory' must return a value from $get factory method.
 ```
- factory注入的结果就是return返回的结果，可以在被注入的对象中使用注入的结果定义的各种方法

 ```
   app.controller('myCtrl', ['$scope', 'myFactory', function ($scope, myFactory) {
        console.log(myFactory.getName());  //foo
        //请求当前文件夹下的test.html
        myFactory.getData('./test.html').then(function (response) {
            console.log(response);  //返回test.html的字符串形式
        });
    }]);

    /**------------ 使用factory方法 -----------------*/
    app.factory('myFactory', function ($http) {
        var factory = {};
        var _name = 'foo';
        //模仿ajax请求
        factory.getData = function (url) {
            return $http({
                method: 'get',
                url: url
            });
        };

        factory.getName = function () {
            return _name;
        };

        return factory;
    });
```

 
### 使用Module的service方法

- 语法糖

 ```
 app.service('myService', function () {
        //对this进行操作
    });
 ```
- 通过service方法创建的服务，可以不用返回任何值，因为service方法本身返回一个构造器，系统会用new关键字来创建一个对象，所以我们可以在service内部使用this关键字，对service进行扩展。

 ```
app.controller('myCtrl', ['$scope', 'myService', function ($scope, myService) {
        console.log(myService);
        myService.setName('foo');
        console.log(myService.getName());
    }]);

    /**------------ 使用service方法 -----------------*/
    app.service('myService', function () {
        this._name = '';

        this.getName = function () {
            return this._name;
        };

        this.setName = function (name) {
            this._name = name;
        };

    }); 
 ```
 
- 如果使用具有返回值的写法，返回的值必须是一个对象，如果只返回基本类型，则实际返回的还是相当于this

 ```
   app.service('myService', function () {
        var obj = {};
        this._name = '';

        obj.getName = function () {
            return this._name;
        };

        obj.setName = function (name) {
            this._name = name;
        };
        return obj;
    });
 ```

### 三种方法的比较

- 需要在config中进行全局配置的话，只能选择provider方法
- factory和service是使用比较频繁的创建服务的方法。他们之间的唯一区别是：service方法用于注入的结果通常是new出来的对象，factory方法注入的结果通常是一系列的functions
- provider是创建服务最为复杂的方法，除非你需要创建一个可以复用的代码段并且需要进行全局配置，才需要使用provider创建
- 所有具有特定性目的的对象都是通过factory方法去创建

- AngularJS官方文档也对这几种方法做了对比，结果如下表格所示

 特性                                      |   Factory   |Service  | Provider
--------------------------------------|---------------|------------|------------
是否可以依赖注入                 |    是          |      是     |   是
是否依赖注入友好                 |    否          |      是     |   否
是否可在config中进行配置    |    否          |      否     |   是
是否可以创建函数                 |    是          |      是     |   是
是否可以创建基本数据类型   |    是          |     否      |   是
 
- 依赖注入的时机

 当在使用以上三种方法创建服务时，它们可能也需要依赖于别的服务，此时它们的依赖注入时机是有差别的。
 - provider
 
     provider是在`$get`方法中进行依赖注入的，当在定义provider时依赖注入则会报错
     
     ```
      angular.module('providerModule', [])
           .provider('myProvider', function () {
	           this.$get = ['$http', function ($http) {
	               return {};
	           }];
    });
     ```
 
 - factory与service

     factory和service的依赖注入发生在定义时
     
     ```
     	angular.module('serviceModule', [])
	      .service('myService', ['$http', function ($http) {
	
	 }]);
     ```
     ```
     angular.module('factoryModule', [])
          .factory('myFactory', ['$http', function ($http) {
             return {};
    }]);
     ```

### 参考资料

- [AngularJS官方文档之Provider](https://docs.angularjs.org/guide/providers)
- [自定义服务详解(factory、service、provider)](http://blog.csdn.net/zcl_love_wx/article/details/51404390)
- [自定义服务的三种方法以及provider供应商](http://blog.csdn.net/bboyjoe/article/details/50456869)
- [AngularJS 之 Factory vs Service vs Provider](http://www.oschina.net/translate/angularjs-factory-vs-service-vs-provider)
 






