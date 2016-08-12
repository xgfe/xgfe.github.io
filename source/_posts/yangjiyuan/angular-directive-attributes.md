title: Angular指令中的属性
date: 2016-08-12 17:18:08
categories: yangjiyuan
tags:
- Angular
- 指令
- Directive
---

下面通过一些简单的示例说明Angular指令中属性的值的获取方式以及函数的使用。

<!--more-->
## 直接获取

```
app.directive('my-directive',function(){
	return {
		scope:{
			attr1:'@',
			attr2:'=',
			attr3:'&'
		},
		link: function(scope){
			// scope.attr1
			// scope.attr2
			// scope.attr3
		}
	};
})

<my-directive attr1="{{value}}" attr2="value2" attr3="value3()"></my-directive>
```

- `attr1` 是一次性获取
- `attr2` 是双向绑定
- `attr3` 是方法，可以在指令内部调用

## 手动解析传递的变量

```
app.directive('my-directive',function(){
	return {
		scope:{},
		link: function(scope,ele,attrs){
			var attr1 = attrs.attr1;    // 'Hello'
			var attr2 = scope.$parent.$eval(attrs.attr2); // 'Hello'
		}
	};
});

<my-directive attr1="{{value}}" attr2="value"></my-directive>

app.controller('myController',function($scope){
	$scope.value = 'Hello';
})
```
注意：上述这种做法用到了指令的**父级作用域**，所以指令中设置`scope:false`是不行的，尽量使用独立的作用域。

这样也可以实现数据的watch

```
link: function(scope,ele,attrs){
	var attr1 = attrs.attr1;    // 'Hello'
	attrs.$observe('attr1',function(){
		console.log('attr1 changed');
	});
	var attr2 = scope.$parent.$eval(attrs.attr2); // 'Hello'
	scope.$parent.$watch(attrs.attr2,function(){
		console.log('attr2 chaned');
	});
}
```

## 使用$parse

```
link: function(scope,ele,attrs){
	var attr2 = $parse(attrs.attr2)(scope.$parent); // 'Hello'
}
```
其实原理和`$eval`差不多，使用`$eval`其实也是间接调用了`$parse`

```
Angular中$eval的代码
$eval: function(expr, locals) {
	return $parse(expr)(this, locals);
}
```
同样，使用`$parse`也可以实现`watch`

```
link: function(scope,ele,attrs){
	scope.$parent.$watch($parse(attrs.attr2),function(){
		console.log('attr2 chaned');
	});
}
```

## 方法的传递和使用

使用以上说的`$eval`或者`$parse`方法解析函数

```
外层的controller
app.controller('myController',function($scope){
	$scope.onChange = function(argv){
		return 'Hello '+argv;
	};
});
```

```
[例子一]
直接传递方法名，就类似于传递变量，可以在指令中调用该方法
<my-directive on-change="onChange"></my-directive>

link: function(scope,ele,attrs){
	var onChange = scope.$parent.$eval(attrs.onChange);
	console.log(onChange('World')); // Hello World
}
```

```
[例子二]
传递方法的调用
<my-directive on-change="onChange('Angular')"></my-directive>

link: function(scope,ele,attrs){
	var onChange = scope.$parent.$eval(attrs.onChange);
	console.log(onChange); // Hello Angular
	console.log(onChange('World')); // Error
}
```
使用`&`的写法

```
指令
app.directive('my-directive',function(){
	return {
		scope:{
			onChange:'&'
		},
		link: function(scope,ele,attrs){
			// ...
		}
	};
});
```

```
[例子三]
<my-directive on-change="onChange"></my-directive>

link: function(scope,ele,attrs){
	var onChange = scope.onChange;
	console.log(onChange); // 经过Angular封装的函数，并不是父级作用域中的onChange函数
	console.log(onChange()); // 第一次调用，获取到onChange函数
	console.log(onChange()('Directive')); // 最终的执行结果 Hello Directive
}
```

```
[例子四]
<my-directive on-change="onChange('Hello')"></my-directive>

link: function(scope,ele,attrs){
	var onChange = scope.onChange;
	console.log(onChange); // 经过Angular封装的函数，并不是父级作用域中的onChange函数
	console.log(onChange('invoke')); // 最终的执行结果，输出 'Hello Hello' 而不是 'Hello invoke'
}
```
可以发现，如果使用`&`在`scope`中指定一个属性为函数的话，直接从**`scope`**上获取的是经过`Angular`封装的一个函数,经过调用这个函数返回的值才是指令属性上真正绑定的值。如果你在指令上只是要绑定一个直接执行的函数，类似于[例子四]是比较常用的做法。

## 指令中使用函数时值的传递

上面介绍了如何使用函数，这里简要介绍一下函数中如何传递值，即指令内部的值如何通过函数传递出来。

如上面的[例子三]，可以将数据传递出来，这是一种方法，不过在用法上不是很好，因为这样的话在指令中绑定的并不是**函数**，而是**变量**，下面介绍一个更好的方法。

```
<button type="button" on-click="onClickHandler($event)">按钮</button>
```
上面的代码使我们经常会使用的，在`angular`自带的`onClick`函数中可以使用`$event`参数来获取点击事件的相应内容，从而在使用指令的作用域中进行操作，那么如何才能把指令内部的值传递到外面呢？

```
外层的controller
app.controller('myController',function($scope,$interval){
	$scope.onChange = function(count,timer){
		if(count > 9){
			$interval.cancel(timer);
		}
		console.log('Hello '+ count);
	};
});
```

```
<my-directive on-change="onChange($argv,$timer)"></my-directive>

link: function(scope,ele,attrs){
	var onChange = scope.onChange;
	var count = 0;
	var timer = $interval(function(){
		onChange({
			$argv: count++,
			$timer: timer
		});
	},1000);
}
```
上述代码会指令内的值通过函数传递到外部作用域。这种使用场景并不是很多，不过非常有用，比如`ng-file-upload`中的

```
<div class="button" ngf-select="upload($file)">Upload on file select</div>
```
就是通过这种方式传递的`$file`对象。
