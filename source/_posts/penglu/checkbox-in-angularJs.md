title: checkbox-in-angularJs
date: 2015-12-03 20:50:00
categories: 
- penglu
- Angular
tags: 
- angularjs
- checkbox
---
# AngularJs中checkbox的使用
用了两次checkbox,第一次使用的时候遇到了一些问题，本来要做总结的，结果一拖再拖，导致今天用的时候又生疏了，所以今天就做一下总结.

1. ng-model:双向数据绑定，通过设置ng-model的值可以设置对应checkbox的“选中|不选”状态，ng-model的变化(手动选择造成的改变)会触发ng-change事件;
2. ng-true-value和ng-false-value可以用来动态绑定"选中|不选"状态下默认值(默认为true和false);
3. 同时在input[checkbox]上绑定ng-change和ng-click，则在执行"选中|取消选中"操作时，首先会触发ng-click,此时传递过去的ng-model为点击之前的model数据，而触发ng-change之后，传递过去的model是最新数据;
4. ng-change事件的触发:只有当手动"选中|取消选中"时才会触发ng-change事件，而通过使用代码修改ng-model不能触发ng-change事件;
5. ng-ckecked:true表示当前checkbox‘勾选’；false表示当前checkbox‘取消勾选’。<span style="color:red">angularjs版本1.3以下，如果同时使用ng-model和ng-true-value|ng-false-value,则初始化的时候需要同时设置ng-checked才能真正实现通过ng-model来实现checkbox的勾选状态(js修改ng-model会触发‘勾选状态’的变化)</span>

通过代码来对上面几点总结做演示

```
<!doctype html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>AngularJS Checkbox实例</title>
    <script src="https://code.angularjs.org/1.2.25/angular.js"></script>
</head>
<body ng-app="checkboxExample">
<script>
    // 链式方式定义和使用module
    angular.module('checkboxExample', [])
            .controller('ExampleController', ['$scope', function($scope) {
                $scope.checkboxModel = {
                    value1: true,
                    value2: 'YES'  // 与ng-true-value设置的值保持一致
                };
                $scope.eventName = ""; //触发事件名称

                // 点击事件
                $scope.clickFn = function(obj){
                    $scope.clickModel = obj.value1;
                    $scope.eventName = 'click';
                };
                // change事件
                $scope.changeFn = function(obj){
                    $scope.changeModel = obj.value1;
                    $scope.eventName = 'change';
                };
                $scope.clickModel =  $scope.checkboxModel.value1;
                $scope.changeModel =  $scope.checkboxModel.value1;

                $scope.changeVal = function(){
                    $scope.checkboxModel.value1 = !$scope.checkboxModel.value1; //修改model状态
                }
            }]);
</script>
<ol ng-controller="ExampleController">
    <li>
        <h4>普通方式绑定ng-model:选中(true)、取消选中(false);绑定ng-change和ng-click事件:验证1，3，4结论</h4>
        <input type="checkbox" ng-model="checkboxModel.value1"  ng-click="clickFn(checkboxModel)" ng-change="changeFn(checkboxModel)">
        <button ng-click="changeVal()">修改ng-model值</button>
        <p>click事件对应ng-model取值:{{clickModel}}</p>
        <p>change事件对应ng-model取值:{{changeModel}}</p>
        <p>事件名称:{{eventName}}</p>
    </li>
    <li>
        <h4>设置ng-true-value="'YES'"和ng-false-value="'NO'",则ng-model:选中('YES')、取消选中('NO');绑定ng-change和ng-click事件:2,5结论</h4>
        <div><label>设置ng-checked:</label><input type="checkbox" ng-model="checkboxModel.value2" ng-true-value="'YES'" ng-false-value="'NO'" ng-checked="checkboxModel.value2=='YES'"></div>
        <div><label>不设置ng-checked:</label><input type="checkbox" ng-model="checkboxModel.value2" ng-true-value="'YES'" ng-false-value="'NO'" ></div>
        <p>'选中|不选'对应ng-model的值:{{checkboxModel.value2}}</p>
    </li>
</ol>
</body>
</html>
```
[戳我看效果](http://plnkr.co/edit/wIfYZnJwJV5IcN7mx9wZ?p=preview)