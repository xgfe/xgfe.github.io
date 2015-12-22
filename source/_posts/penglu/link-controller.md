title: 指令编译过程中link与controller函数执行顺序
date: 2015-12-22 22:30:00
categories: penglu
tags: 
- angularjs
- link
- controller
- 编译顺序
---

本文主要介绍指令使用过程中，编译阶段link函数与controller函数的执行顺序相关知识。

<!-- more -->
## link
1. link实例

    ```
    <body>
        <script>
            angular.module('app', []);
            angular.module('app').directive('linkParent', function(){
                return {
                    restrict: 'EA',
                    template: '<div>My name is {{name}},{{parentContent}}</div><link-child></link-child>',
                    link:function (scope, ele, attrs){
                        console.log(scope); // childContent: "My parent name is undefined";childName: "rabbit"; name: "penglu"
                        scope.name = "penglu";
                        scope.parentContent = "My child name is " + scope.childName;
                    }
                }
            });
            angular.module('app').directive('linkChild', function(){
                return {
                    restrict: 'EA',
                    template:'<div style="color: red">My name is {{childName}}{{childContent}}</div>',
                    link: function(scope, ele, attrs){
                        scope.childName = "rabbit";
                        scope.childContent = 'My parent name is '  + scope.name;
                    }
                }
            });
        </script>
       <link-parent></link-parent>
    </body>
    ```
    - 解析
        - 定义一个父指令:linkParent,在其template中使用子指令linkChild,并且两个指令都没有指定scope,则表示默认使用的同一个scope,因此本可以在linkChild中可以访问scope.name，但是实际上在linkChild中获取不到name,反而在linkParent中可以获取到childName属性。
        - 产生上述现象的主要原因在于:link函数执行可以分为两部分;编译过程中,controller以及link的执行顺序。
2. link知识点汇总
    - link其实可以分为两个阶段:preLink和postLink.
    - 简单定义link:一般通过link定义的都是postLink函数(通常使用这种方法)
    ```
     link: function(scope, ele, attrs){  //postLink
        scope.childName = "rabbit";
        scope.childContent = 'My parent name is '  + scope.name;
     }
    ```
    - 使用link对象定义post｜pre方法
    ```
    link: {
        pre: function(scope, ele, attrs){  //postLink
                scope.childName = "rabbit";
                scope.childContent = 'My parent name is '  + scope.name;
            },
        post: function(scope, ele, attrs){  //postLink
              scope.childName = "rabbit";
              scope.childContent = 'My parent name is '  + scope.name;
          }
    }
    ```
    - 也可以在compile函数中返回preLink和postLink或link函数
    ```
    link: function(ele, attrs, transclude){
        return {
            pre: function preLink(scope, ele, attrs){  //postLink
                // preLink
            },
            post: function postLink(scope, ele, attrs){  //postLink
              // postLink
            }
        }
    }
    ```
3. controller,link(pre & post)函数执行顺序
    - DOM结构
       <img src="http://tututu.oss.aliyuncs.com/dom.png">
    - 代码实例
    ```
    <body>
    <script>
        angular.module('app', []);
        angular.module('app').directive('linkParent', function(){
            return {
                restrict: 'EA',
                template: '<link-child></link-child>',
                controller: function(){
                    console.log('controller - parent');
                },
                link: {
                    pre: function (scope, ele, attrs) {
                        console.log('preLink-parent');
                    },
                    post: function (scope, ele, attrs){
                        console.log('postLink-parent');
                    }
                }
            }
        });
        angular.module('app').directive('linkChild', function(){
            return {
                restrict: 'EA',
                template:'<link-off-spring-one></link-off-spring-one><link-off-spring-two></link-off-spring-two>',
                controller: function(){
                    console.log('controller - child');
                },
                link: {
                    pre:function(scope, ele, attrs){
                        console.log('preLink - child')
                    },
                    post:function(scope, ele, attrs){
                        console.log('postLink - child')
                    }
                }
            }
        });
        angular.module('app').directive('linkOffSpringOne', function(){
            return {
                restrict: 'EA',
                controller: function(){
                    console.log('controller - offSpringOne');
                },
                link: {
                    pre:function(scope, ele, attrs){
                        console.log('preLink - offSpringOne');
                    },
                    post:function(scope, ele, attrs){
                        console.log('postLink - offSpringOne');
                    }
                }
            }
        });
        angular.module('app').directive('linkOffSpringTwo', function(){
            return {
                restrict: 'EA',
                controller: function(){
                    console.log('controller - offSpringTwo');
                },
                link: {
                    pre:function(scope, ele, attrs){
                        console.log('preLink - offSpringTwo');
                    },
                    post:function(scope, ele, attrs){
                        console.log('postLink - offSpringTwo');
                    }
                }
            }
        });
    </script>
    <link-parent></link-parent>
    </body>
    ```
    - controller,link执行顺序
    <img src="http://tututu.oss.aliyuncs.com/excute.png">
    - 总结
        - 从DOM结构来看,同一个元素中执行顺序为:controller > preLink > postLink.
        - 从DOM结构来看,从上往下依次执行父级元素(controller->preLink) > 第一个子元素(controller->preLink),若该子元素无子元素，则执行postLink，否则继续对子元素依次执行(controller -> preLink -> postLink)。
        - 从DOM结构来看,相邻兄弟节点之间的执行顺序为:第一个兄弟节点(controller -> preLink -> postLink) > 下一个兄弟节点(controller -> preLink -> postLink) > ...依次执行
4. 针对实例问题，如果想在linkChild中访问name属性，则需要在linkParent的preLink中给name赋值;则在linkChild中就可以获取name属性.在linkParent的postLink中获取childName属性。
```
<body>
    <script>
        angular.module('app', []);
        angular.module('app').directive('linkParent', function(){
            return {
                restrict: 'EA',
                template: '<div>My name is {{name}},{{parentContent}}</div><link-child></link-child>',
                link: {
                    pre: function (scope, ele, attrs){
                        scope.name = "penglu";
                    },
                    post: function(scope){
                        scope.parentContent = "My child name is " + scope.childName;
                    }
                }
            }
        });
        angular.module('app').directive('linkChild', function(){
            return {
                restrict: 'EA',
                template:'<div style="color: red">My name is {{childName}}{{childContent}}</div>',
                link: function(scope, ele, attrs){
                    scope.childName = "rabbit";
                    scope.childContent = 'My parent name is '  + scope.name;
                }
            }
        });
    </script>
   <link-parent></link-parent>
</body>
```
## 参考文章
[Practical Guide to PreLink, PostLink and Controller Methods of Angular Directives](http://www.undefinednull.com/2014/07/07/practical-guide-to-prelink-postlink-and-controller-methods-of-angular-directives/)
