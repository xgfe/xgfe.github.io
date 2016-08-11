title: 编写高质量JS代码
date: 2016-08-11 10:30:00
categories: penglu
tags:
- javascript
- 读书笔记
---

本文主要是阅读Effective Javascript书籍的读书笔记。

<!-- more -->
# 编写高质量JS代码
# 目录
- 让自己习惯JavaScript
- 变量作用域
- 使用函数
- 对象和原型
- 数组和字典
- 库和API设计
- 并发

# 内容详解
## 让自己习惯JavaScript
### 了解你使用的js版本
1. 决定你的应用程序支持JS的哪些版本
2. 确保你使用的任何JS的特性对于应用程序将要运行的所有环境都是支持的
3. 总是要在执行严格模式检查的环境中测试严格代码
4. 当心连接那些在不同严格模式下有不同预期的脚本
	- [严格模式注意点](http://xgfe.github.io/Basics/JavaScript/strictMode.html)
	- 'use strict'指令只有在脚本或函数的顶部才能生效
		- 在开发中使用多个独立的文件，但是部署到产品环境时却需要连接成一个单一的文件。
			- 不要将进行严格模式检查的文件和不进行严格模式检查的文件连接在一起。
			- 通过将其自身包裹在理解调用的函数表达式(IIFE)中的方式连接多个文件

### 理解JavaScript的浮点数
1. Javascript的数字都是双精度的浮点数
2. Javascript中的整数仅仅是双精度浮点数的一个子集，而不是一个单独的数据类型
3. 位运算符将数字视为32位的有符号整数
	- 它们将操作数转换为整数，然后使用整数位模式(被隐式的转换成32位大端的2的补码表示的整数)进行运算， 最后将结果转换为标准的Js浮点数`8 | 1 = 9`
4. 当心浮点运算中的精度陷阱

	```
	(0.1 + 0.2) + 0.3;     // 0.6000000000000001
	0.1 + (0.2 + 0.3);     // 0.6
	```

	- 尽可能的采用整数数值运算，货币相关计算，通常会按比例将数值转换为最小的货币单位来进行计算，这样就可以以整数进行计算

### 当心隐式的强制转换
1. 类型错误可能被隐式的强制转换所隐藏
	- 算术运算符-、*、/、%在计算之前都会尝试将其参数转换为数字
		- null会被转换为0
		- 未定义变量被转换为特殊的浮点数值NaN(JS中唯一一个不等于其自身的值)
			- 检查一个值是否为NaN: `a!==a`;
2. 重载的运算符+是进行加法运算还是字符串连接操作取决于其参数类型
	- 数字和字符串一起，会将数字转换为字符串`1+2+'3' = 33`
3. 对象通过valueOf方法强制转换为数字，通过toString方法强制转换为字符串
	- 对象的运算符+被重载时，JS选择valueOf方法进行转换

	```
	var obj = {
	    toString: function(){
	        return '[object MyObject]';
	    },
	    valueOf: function(){
	        return 17;
	    }
	}
	'object:' + obj;  // "object:17"
	1 + obj;  // 18
	```
4. 具有valueOf方法的对象应该实现toString方法，返回一个valueOf方法产生的数字的字符串表示
5. 测试一个值是否为未定义的值，应该使用typeof或者与undefined进行比较而不是使用真值运算
	- Js中7个假值: false、0、－0、""、NaN、null、undefined
	- 检查参数是否为undefined
		- 使用typeof:`typeof a`
		- 与undefined进行比较

### 原始类型优于封装对象
1. 当做相等比较时，原始类型的封装对象与其原始值行为不一样
	- JS有5个原始值类型: 布尔值、数字、字符串、null和undefined
		- 对null进行typeof是object
2. 获取和设置原始类型值的属性会隐式地创建封装对象
	- 当对原始值提取属性和进行方法调用时，它表现得就像已经使用了对应的对象类型封装了该值一样。
	- 隐式封装可以对原始值设置属性，但是对其丝毫没有影响

	```
	'hello'.name = 'my name is hello';
	'hello'.name
	```

### 避免对混合类型使用==运算符

```
"1.0e0" == {valueOf: function(){ return true; }};  // true
```

1. 当参数类型不同时，==运算符应用了一套难以理解的隐式强制转换规则。
	- 当两个参数属于同一类时，==和===运算符的行为是没有区别的

      **运算符的强制转换规则**

| 参数类型1      | 参数类型2          | 强制转换  |
| ------------- |:-------------:| -----:|
| null      | undefined | 不转换，返回true |
| null或undefined      | 其他任何非null或undefined的类型      |   不转换总是返回false |
| 原始类型:string,number或boolean | Date对象      |    将原始类型转换为数字，将Date对象转换为原始类型(优先调用toString，再尝试valueOf) |
| 原始类型:string,number或boolean | 非Date对象      |   将原始类型转换为数字，将非Date对象转换为原始类型(优先调用valueOf，再尝试toString) |
| 原始类型:string,number或boolean | 原始类型:string,number或boolean      |   将原始类型转换为数字 |

2. 使用===运算符，使读者不需要涉及任何的隐式强制转换就能明白你的比较运算
3. 当比较不同类型的值时，使用你自己的显示强制转换使程序的行为更清晰

### 了解分号插入的局限
1. 分号插入规则
	- 分号仅在}标记之前、一个或多个换行之后和程序输入的结尾被插入；
	- 分号仅在随后的输入标记不能解析时插入;
	- 分号不会做为分隔符在for循环空语句的头部被自动插入
2. 在以(、[、+、-、或/字符开头的语句前绝不能省略分号;
3. 当脚本连接的时候，在脚本之间显示地插入分号;
4. 在return、throw、break、continue、++、--的参数之前绝不能换行

### 视字符串为16位的代码单元序列
1. JavaScript字符串由16位的代码单元组成，而不是由Unicode代码点组成
	- Unicode编码标准:UTF-8、UTF-16、UTF-32
	- JavaScript允许直接用码点表示Unicode字符，写法是"反斜杠+u+码点"
2. JavaScript使用两个代码单元表示2^16及其以上的Unicode代码点。这两个代码单元被称为代理对
	- 字符串的属性和方法(length、charAt、charCodeAt)都是基于代码单元层级
	- 一个JS字符串的元素是一个16位的代码单元
3. 代理对甩开了字符串元素计数，length、charAt、charCodeAt方法以及正则表达式模式(例如'.')受到影响
4. 使用第三方的库编写可识别代码点的字符串操作
5. 每当你使用一个含有字符串操作的库时，你都需要查阅该库文档，看它如何处理代码点的整个范围
```
"\u221a" === √
```

## 变量作用域
### 尽量少用全局对象
- 避免声明全局变量，尽量声明局部变量
	- 全局变量会污染共享的公共命名空间，并可能导致意外的命名冲突
- 避免对全局对象添加属性
	- 声明全局变量两种方法: 在全局作用域中使用var声明它；将其加入到全局对象中.
	- 在web浏览器中，全局对象被绑定到全局的window变量:`foo == this.foo == window.foo`
- 使用全局对象来做平台特性检测。

### 始终声明局部变量

```
function swap(a, i, j){
	temp = a[i];  // global
	a[i] = a[j];
	a[j] = temp;
}
```

- 始终是用var声明新的局部变量
- 考虑使用lint工具帮助检查未绑定的变量

### 避免使用with
### 熟练掌握闭包
- 理解闭包
	- Js允许你引用在当前函数以外定义的变量

	- 即使外部函数已返回，当前函数仍然可以引用在外部函数所定义的变量
	- 闭包可以更新外部变量的值(闭包存储的是外部变量的引用，而不是它们的值的副本)
1. 函数可以引用定义在其外部作用域的变量

	```
	function makeSandwich(){
		var magicIngredient = 'peanut butter';
		function make(filling){
			return magicIngredient + " and " + filling;
		}
		return make('jelly');
	}
	makeSandwich(); // "peanut butter and jelly"
	```
2. 闭包比创建它们的函数有更长的生命周期
	- Js函数值还在内部存储它们可能会引用的定义在其封闭作用域的变量，而那些在其所涵盖的作用域内跟踪变量的函数被称为闭包。
	- 构建闭包的字面量语法－－函数表达式

	```
	function makeSandwich(){
	    return function (filling){
	        return magicIngredient + " and " + filling;
	    }
  	}
	```
3. 闭包在内部存储其外部变量的引用，并能读写这些变量

	```
	function  box(){
	    var val = undefined;
	    return {
	        set: function(newVal){ val = newVal;},
	        get: function(){ return val; },
	        type: function(){ return typeof val;}
	    };
	}
	var b = box();
	b.type(); //"undefined"
	b.set(98.6);
	b.get();  // 98.6
	b.type();  // "number"
	```

### 理解变量声明提升
1. 在代码块中的变量声明会被隐式的提升到封闭函数的顶部
	- 把声明看作由两部分组成，即声明和赋值。JS隐式地提升声明部分到封闭函数的顶部，而将赋值留在原地
2. 重声明变量被视为单个变量
	- js没有块级作用域除了try...catch，try...catch将捕获的异常绑定到一个变量，该变量的作用域只是catch语句块。

	```
	function test(){
	    var x = "var", result = [];
	    result.push(x);
	    try{
	        throw 'expection';
	    } catch(x){
	        x = 'catch';
	    }
	    result.push(x);
	    return result;
	}
	test(); // ["var", "var"]
	```
3. 考虑手动提升局部变量的声明，从而避免混淆

### 使用立即调用的函数表达式创建局部作用域
1. 理解绑定与赋值的区别
	- 运行时进入一个作用域，js会为每一个绑定到该作用域的变量在内存中分配一个‘槽(slot)’

	```
	function wrapElements(a) {
		var result = [], i, n;  // 分配三个槽
		for(i = 0, n = a.length; i < n; i++){
		   result[i] = function(){  // 闭包,a[i]存储的是引用,i共享一个槽
		       return a[i];
		   }
		}
		return result;
	}
	var wrapped = wrapElements([10, 20, 30, 40, 50]);
	var f = wrapped[0];
	```
2. 闭包通过引用而不是值捕获它们的外部变量
3. 使用立即调用函数表达式(IIFE)来创建局部作用域

	```
	function wrapElements(a) {
	    var result = [], i, n;
	    for(i = 0, n = a.length; i < n; i++){
	        (function(){
	            var j = i;
	            result[i] = function(){
	                return a[j];
	            }
	        })();
	        /**
	       (function(j){
	            result[i] = function(){
	                return a[j];
	            }
	        })(i);
	        **/
	    }
	    return result;
	}
	var wrapped = wrapElements([10, 20, 30, 40, 50]);
	var f = wrapped[0];
	```
4. 当心在立即调用的函数表达式中包裹代码块可能改变其行为的情形。
	- 代码块不能包含任何跳出块的break语句和continue语句
	- 如果代码块引用了this或arguments变量，IIFE将会改变它们的含义

### 当心命名函数表达式笨拙的作用域
1. 在Error对象和调试器中使用命名函数表达式改进栈跟踪

	```
	var f = function double(x){ return x*2; }
	// 此语句将该函数绑定到变量f而不是变量double
	```
	- 匿名和命名函数表达式区别: 后者会绑定到与其函数名相同的变量上，该变量将作为函数内的一个局部变量
	- 在跟踪栈中，函数表达式的名称通常作为其入口使用
2. 在ES3和有问题的JS环境中谨记函数表达式作用域会被Object.prototype污染
	- 在ES3中，JS引擎被要求将命名函数表达式的作用域表示为一个对象，该作用域对象继承了Object.prototype的属性
3. 谨记在错误百出的js环境中会提升命名函数表达式声明，并导致命名函数表达式的重复存储
4. 考虑避免使用命名函数表达式或在发布前删除函数名
5. 如果你将代码发布到正确实现的ES5环境中，那么你没有什么好担心的

### 当心局部块函数声明笨拙的作用域
1. 始终将函数声明置于程序或被包含的函数的最外层以避免不可移植的行为
	- 始终避免将函数声明置于局部块或子语句中

	```
	function f(){ return 'global'; }
	function test(x){
	    var result = [];
	    if(x){
	        function f(){
	            return 'local';
	        }
	        result.push(f());
	    }
	    result.push(f());
	    return result;
	}
	test(true);
	test(false);
	```
2. 使用var声明和有条件的赋值语句替代有条件的函数声明

	```
	function f(){ return 'global'; }
	function test(x){
	    var g = f;
	    var result = [];
	    if(x){
	        g = function f(){
	            return 'local';
	        }
	        result.push(g());
	    }
	    result.push(g());
	    return result;
	}
	test(true);
	test(false);
	```

### 避免使用eval创建局部变量
1. 避免使用eval函数创建的变量污染调用者的作用域

	```
	function test(x){
		eval('var y = x;')
		return y;
	}
	test('hello'); // hello
	```
2. 如果eval函数代码可能创建全局变量，将此调用封装到嵌套的函数中以防止作用域污染

### 间接调用eval函数优于直接调用
1. 将eval函数同一个毫无意义的字面量包裹在序列表达式中以达到强制使用间接调用eval函数的目的
	- eval函数具有访问调用它那时的整个作用域的能力
	- 函数调用涉及eval标识符,被认为是一种"直接"调用eval函数的方式

		```
		// 直接调用
		var x = 'global';
		function test(){
		   var x = 'local';
		   return eval('x');  // 'local'
		}
		test();
		// 间接调用
		var x = 'global';
		function test(){
		   var x = 'local';
		   var f = eval;
		   return f('x');  // global
		}
		test();
		```
	- 绑定eval函数到另一个变量名，通过该变量名调用函数会使代码失去对所有局部作用域的访问能力
2. 尽可能间接调用eval函数，而不要直接调用eval函数
	- 编写间接调用eval函数的另一种简洁方式是使用表达式序列运算符(,)和一个明显毫无意义的数字字面量｀(0, eval)(src)｀
	- 直接调用eval函数性能上的损耗是相当高昂的(需要承担直接调用eval函数导致其包含的函数以及所有直到函数最外层的函数运行相当缓慢的风险)

## 使用函数
### 理解函数调用、方法调用及构造函数调用之间的不同
- JS中函数，方法，类的构造函数是单个构造对象的不同使用模式
	- 函数调用

		```
		function hello(userName){
	    	return "hello," + userName;
		}
		hello('pl');  // "hello,pl"
		```

	- 方法调用:对象的属性恰好是函数

		```
		var obj = {
	    hello: function(){
	        return 'hello,' + this.userName;
	    },
	    userName: 'pl'
		}
		obj.hello(); // "hello,pl"
		var obj2 = {
		    hello: obj.hello,
		    userName: 'rabbit'
		};
		obj2.hello();  // "hello,rabbit"
		```

		- 方法调用中是由调用表达式自身来确定this变量的绑定。绑定到this变量的对象被称为调用接收者
		- ES5的严格模式将this变量的默认值绑定值改为undefined

			```
			function hello(){
			    // 'use strict';
			    console.log(this);
			    return "hello," + this.userName;
			}
			hello();
			```
	- 通过构造函数使用
		- 使用new操作符来调用函数，则视其为构造函数。构造函数调用将一个全新的对象作为this变量的值，并隐式返回这个新对象作为调用结果。

### 熟练掌握高阶函数
1. 高阶函数是那些将函数作为参数或返回值的函数
2. 熟练掌握现有库中的高阶函数
	- Array.prototype.sort、forEach、map、filter等
3. 学会发现可以被高阶函数所取代的常见的编码模式
	- 需要引入高阶函数抽象的信号是出现重复或相似的代码

	```
	// 使用英文字母创建一些字符串
	var aIndex = "a".charCodeAt(0);
	var alphabet = "";
	for(var i = 0; i < 26; i++){
	    alphabet += String.fromCharCode(aIndex + i);
	}
	alphabet; //"abcdefghijklmnopqrstuvwxyz"
	// 生成一个包含数字的字符串
	var digits = "";
	for(var i = 0; i < 10; i++){
	    digits += i;
	}
	digits;  // "0123456789"
	// 创建一个随机的字符串
	var aIndex = "a".charCodeAt(0);
	var random = "";
	for(var i=0; i<8; i++){
		random += String.fromCharCode(Math.floor(Math.random() * 26) + aIndex);
	}
	random;  //"uraugvrx"
	// 上面三种，都是创建一个字符串，只是创建的方式不同
	function buildString(n, callback){
		var result = "";
		for(var i=0; i<n; i++){
			result = callback(i);
		}
		return result;
	}
	```

### 使用call方法自定义接收者来调用方法
1. 使用call方法自定义接收者来调用此函数
	- 通常，函数或方法的接收者(即绑定到特殊关键字this的值)是由调用者的语法决定的。

	```
	obj.temporary = f;
	var result = obj.temporary(arg1, arg2, arg3);
	delete obj.temporary;
	// 使用call
	f.call(obj, arg1, arg2, arg3);
	```
2. 使用call方法可以调用在给定的对象中不存在的方法
3. 使用call方法定义高阶函数允许使用者给回调函数指定接收者

### 使用apply方法通过不同数量的参数调用函数
1. 使用apply方法指定一个可计算的参数数组来调用可变参数的函数
	- 可变参数或可变元的函数(函数的元数是指其期望的参数个数)
	- apply方法需要一个参数数组，然后将数组的每一个元素作为调用的单独参数调用该函数，除了参数数组，apply方法指定第一个参数绑定到被调用函数的this变量
2. 使用apply方法的第一个参数给可变参数的方法提供一个接收者

### 使用arguments创建可变参数的函数
1. 使用隐式的arguments对象实现可变参数的函数
	- JS给每个函数都隐式地提供了一个名为arguments的局部变量。arguments对象给实参提供了一个类似数组的接口。
2. 考虑对可变参数的函数提供一个额外的固定元数的版本，从而使使用者无需借助apply方法

### 永远不要修改arguments对象
1. 永远不要修改arguments对象
2. 使用[].slice.call(arguments)将arguments对象复制到一个真正的数组中再进行修改
	- arguments对象自身并不是标准的Array类型的实例，因此，不能直接调用arguments.shift()方法
	- 所有命名参数都是arguments对象中对应索引的别名

	```
	function callMethod(obj, method){
	    var shift = [].shift;
	    console.log(arguments);
	    shift.call(arguments);
	    shift.call(arguments);
	    console.log(obj);
	    console.log(method);
	    return obj[method].apply(obj, arguments);
	}
	var obj = {
	    add: function(x, y){return x + y;}
	};
	callMethod(obj, 'add', 17, 29);
	```

	- 在严格模式下，函数参数不支持对其arguments对象取别名

	```
	function strict(x){
	    "use strict";
	    arguments[0] = "modified";
	    return x === arguments[0];
	}
	function nonstrict(x){
	    arguments[0] = 'modified';
	    return x === arguments[0];
	}
	strict("unmodified"); // false
	nonstrict('unmodified'); // true
	```

### 使用变量保存arguments的引用
1. 当引用arguments时当心函数嵌套层级
2. 绑定一个明确作用域的引用到arguments变量，从而可以在嵌套的函数中引用它。
	- 一个新的arguments变量会被隐式的绑定到每个函数体内

```
function values(){
    var i = 0, n = arguments.length;
   //  var args = [].slice.call(arguments, 0);
    return {
        hasNext: function(){
            return i < n;
        },
        next: function(){
            if( i >= n ){
                throw  new Error('end of iteration');
            }
            return arguments[i++];
         // return args[i++];
        }
    }
}
var it = values(1, 4, 1, 4, 2, 1, 3, 5, 6);
it.next();
```
### 使用bind方法提取具有确定接收者的方法
1. 要注意，提取一个方法不会将方法的接收者绑定到该方法的对象上
2. 当给高阶函数传递对象方法时,使用匿名函数在适当的接收者上调用该方法
3. 使用bind方法创建绑定到适当函数接收者的函数

### 使用bind方法实现函数柯里化
1. 使用bind方法实现函数柯里化，即创建一个固定需求参数子集的委托函数
	- 在计算机科学中，柯里化（英语：Currying），又译为卡瑞化或加里化，是把接受多个参数的函数变换成接受一个单一参数的函数，并且返回接受余下的参数而且返回结果的新函数的技术.

	```
	function simpleURL(protocol, domain, path){
	    return protocol + '://' + domain + '/' + path;
	}
	var urls = paths.map(function (path) {
	    return simpleURL('http', siteDomain, path);  // 第一个和第二个参数固定
	});
	// 使用bind实现函数柯里化
	var urls = paths.map(simpleURL.bind(null, 'http', siteDomain));
	```
2. 传入null或undefined作为接收者的参数来实现函数柯里化，从而忽略其接收者


### 使用闭包而不是字符串来封装代码
1. 当将字符串传递给eval函数以执行它们的API时，绝不要在字符串中包含局部变量引用
	- eval函数会将出现在字符串中的所有变量引用作为全局变量来解释
2. 接受函数调用的API优于使用eval函数执行字符串的API
	- 函数是一种将代码作为数据结构存储的便利方式

### 不要信赖函数对象的toString方法
1. 当调用函数的toString方法时，并没有要求JS引擎能够精确地获取到函数的源代码
	- ECMAScript标准对函数对象的toString方法的返回结果(即该字符串)并没有任何要求
2. 由于在不同的引擎下调用toString方法的结果可能不同，所以绝不要信赖函数源代码的详细细节
3. toString方法的执行结果并不会暴露存储在闭包中的局部变量值
4. 通常情况下，应该避免使用函数对象的toString方法

### 避免使用非标准的栈检查属性
1. 避免使用非标准的arguments.caller和arguments.callee属性，因为它们不具备良好的移植性
	- 现在宿主环境中已经不支持arguments.caller，但还支持arguments.callee(其指向使用该arguments对象被调用的函数，它除了允许匿名函数递归地引用其自身没有更多用途)
2. 避免使用非标准的函数对象calller属性，因为在包涵全部栈信息方面，它是不可靠的。
	- 调用栈事指当前正在执行的活动函数链
	- 栈跟踪是一个提供当前调用栈快照的数据结构
	- ES5中如果试图获取严格函数或arguments对象的caller或callee属性都将抛出一个错误


## 对象和原型
### 理解prototype、getPrototypeOf和__proto__之间的不同
1. 原型包括三个独立但相关的访问器
	- C.prototype用于建立由new C()创建的对象的原型
	- Object.getPrototypeOf(obj)是ES5中用来获取obj对象的原型对象的标准方法
	- `obj.__proto__`是获取obj对象的原型对象的非标准方法
2. 类是由一个构造函数和一个关联的原型组成的一种设计模式

	```
	// User看成一个类,User函数给该类提供了一个公告的构造函数,
	// 而User.prototype是实例之间共享方法的一个内部实现
	function User(name, password){
    	this.name = name;
    	this.password = password;
	}
	User.prototype.toString = function(){
	    return "[User "  + this.name + "]";
	};
	User.prototype.checkPassword = function(password){
	    return password === this.password;
	};
	var user = new User('admin', 'root');
	```

### 使用Object.getPrototypeOf函数而不使用__proto__属性
1. 使用符合标准的Object.getPrototypeOf函数而不要使用非标准的__proto__属性
2. 在支持__proto__属性的非ES5环境中实现Object.getPrototypeOf函数

	```
	if(typeof Object.getPrototypeOf === 'undefined'){
		Object.getPrototypeOf = function(obj){
			 var t = typeof obj;
			 if(!obj || (t !== 'object' && t !== 'function')){
			 	throw new TypeError('not an object');
			 }
			 return obj.__proto__;
		}
	}
	```

### 始终不要修改`__proto__`属性
1. 始终不要修改对象的`__proto__`属性
	- `__proto__`具有修改对象原型链接的能力
	- 可移植性问题:并不是所有平台都支持改变对象原型的特性
	- 修改`__proto__`属性实际上改变了继承结构本身，这可能是最具破坏性的修改
	- 为了保持行为的可预测性
2. 使用 Object.create函数给新对象设置自定义的原型
	- 使用ES5中的Object.create函数来创建一个具有自定义原型链的新对象 `Object.create(proto, [ propertiesObject ])`

### 使构造函数与new操作符无关
1. 通过使用new操作符或Object.create方法在构造函数定义中调用自身使得该构造函数与调用语法无关。
	- 如果使用者忘记使用new关键字，那么函数的接收者将是全局对象
	- 使用严格的构造函数至少会帮助调用者尽早地发现该Bug并修复它

	```
	function User(name, password){
		//   "use strict";
    	this.name = name;
    	this.password = password;
	}
	var user = User('admin', 'root');
	user;    // undefined
	name;   //"admin"
	password; // "root"
	```

	- 检查函数的接收者是否是一个正确的User实例

	```
	function User(name, password){
	    if(!(this instanceof User)){
	        return new User(name, password);
	    }
	    this.name = name;
	    this.password = password;
	}
	// 该函数需要额外的函数调用，代价有点高，并且它很难适用于可变参数函数
	function User(name, password){
	    var self = this instanceof User ? this : Object.create(User.prototype);
	    self.name = name;
	    self.password = password;
	    return self;
	}
	```

	- Object.create兼容函数

	```
	// 简单参数版本
	if(typeof Object.create === "undefined"){
	    Object.create = function(prototype){
	        function C(){};
	        C.prototype = prototype;
	        return new C();
	    }
	}
	```

	- JavaScript允许表达式的结果可以被构造函数中的显示return语句所覆盖
2. 当一个函数期望使用new操作符调用时,清晰地文档化该函数。

### 在原型中存储方法
1. 将方法存储在实例对象中将创建该函数的多个副本，因为每一个实例对象都有一份副本
2. 将方法存储于原型优于存储在实例对象中

	```
	function User(name, password){
	    this.name = name;
	    this.password = password;
	    this.toString = function(){
	        return "[User "  + this.name + "]";
	    };
	    this.checkPassword = function(password){
	        return password === this.password;
	    };
	}
	```

### 使用闭包存储私有数据
1. 闭包变量是私有的，只能通过局部的引用获取
	- 闭包: 将数据存储到封闭的变量中而不提供对这些变量的直接访问，获取闭包内部结构的唯一方式是该函数显示地提供获取它的途径
	- 对象和闭包具有相反策略:对象的属性会被自动地暴露出去，然而闭包中的变量会被自动地隐藏起来
2. 将局部变量作为私有数据从而通过方法实现信息隐蔽

	```
	function User(name, password){
	    this.toString = function(){
	        return "[User "  + name + "]";
	    };
	    this.checkPassword = function(password){
	        return password === password;
	    };
	}
	// 缺点: 这些方法必须置于实例对象中
	```

### 只将实例状态存储在实例对象中
1. 共享可变数据可能会出问题，因为原型是被其所有的实例共享的。

	```
	function Tree(x){
	    this.value = x;
	}
	Tree.prototype = {
	    children: [],
	    addChild: function(x){
	        this.children.push(x);
	    }
	};
	var left = new Tree(2);
	left.addChild(1);
	left.addChild(3);
	var right = new Tree(6);
	right.addChild(5);
	right.addChild(7);
	right.children;  //[1, 3, 5, 7]
	left.children;  //[1, 3, 5, 7]
	```
2. 将可变的实例状态存储在实例对象中
	- 一般情况下，任何不可变的数据可以被存储在原型中从而被安全地共享
	- 在原型对象中最常见的数据是方法，而每个实例的状态都存储在实例对象中

### 认识到this变量的隐式绑定问题
1. this变量的作用域总是由其最近的封闭函数所确定
2. 使用一个局部变量(通常命名为self,me或that)使得this绑定对于内部函数是可以用的

### 在子类的构造函数中调用父类的构造函数
1. 在子类构造函数中显示地传入this作为显示的接收者调用父类构造函数
2. 使用Object.create函数来构造子类的原型对象以避免调用父类的构造函数

### 不要重用父类的属性名
1. 留意父类使用的所有属性名
	- 如果在继承体系中的两个类指向相同的属性名，那么它们指向的是同一个属性。
2. 不要在子类中重用父类的属性名

### 避免继承标准类
1. 继承标准类往往会由于一些特殊的内部属性(如[[Class]])而被破坏
	- JS标准规定它具有一些不可见的内部属性，称为[[Class]]

	 | [[CLass]]     | constructor   |
	 | ------------- |:-------------:|
	 |"Array"    | new Array(...),[...]|
	 |"Boolean"    | new Boolean(...)|
	 |"Date"    | new Date(...)|
	 |"Error"    | new Error(...),new EvalError(),new RangeError(),new ReferenceError(),new SyntaxError(),new TypeError(),new URIError()|
	 |"Function"    | new Function(...),function(...){...}|
	 |"JSON"    | JSON|
	 |"Math"    | Math |
	 |"Number"    | new Number(...)|
	 |"Object"    | new Object(...), {...}, new MyClass(...)|
	 |"RegExp"    | new RegExp(...), /.../|
	 |"String"    | new String(...)|
 - 基于这个原因，最好避免继承一下的标准类: Array、Boolean、Date、Function、Number、RegExp或String
2. 使用属性委托优于继承标准类

### 将原型视为实现细节
1. 对象是接口，原型是实现
	- 使用者与一个对象最基本的交互就是获取其属性值和调用其方法。
	- 原型是一种对象行为的实现细节。
	- JS提供内省机制来检查对象的细节
		- Object.prototype.hasOwnProperty方法确定一个属性是否为对象'自己的'属性
		- Object.getPrototypeOf和`__proto__`特性允许程序员遍历对象的原型链并单独查询其原型对象
2. 避免检查你无法控制的对象的原型结构
3. 避免检查实现在你无法控制的对象内部的属性

### 避免使用轻率的猴子补丁
1. 避免使用轻率的猴子补丁
	- 猴子补丁: 对象共享原型，每个对象都可以增加、删除或修改原型的属性的实践。
	- 当多个库以不兼容的方式给同一个原型打猴子补丁时问题就出现了。
2. 记录程序库所执行的所有猴子补丁
	- 两个以冲突的方式给原型打猴子补丁的程序不能在同一个程序中使用
3. 考虑通过将修改置于一个导出函数中，使猴子补丁称为可选的
4. 使用猴子补丁为缺失的标准API提供polyfills
	- 通过使用带有测试条件的守护猴子补丁来安全地弥补平台的差距

	```
	if(typeof Array.prototype.map !== 'function'){
	    Array.prototype.map = function(f, thisArg){
	        var result = [];
	        for(var i = 0; i < thisArg.length; i++){
	            result[i] = f.call(thisArg, this[i], i);
	        }
	        return result;
	    }
	}
	```

## 数组和字典
### 使用Object的直接实例构造轻量级的字典
1. 使用对象字面量构建轻量级字典
2. 轻量级字典应该是Object.prototype的直接子类，以使for...in循环免受原型污染
	- 原型污染是指当枚举字典的条目时，原型对象中的属性可能会导致出现一些不期望的属性

	```
	function NaiveDict(){}
	NaiveDict.prototype.count = function(){
	    var i = 0;
	    for(var name in this){
	        i++;
	        console.log(name)
	    }
	    return i;
	};
	NaiveDict.prototype.toString = function(){
	    return "[object NaiveDict]";
	};
	var dict = new NaiveDict();
	dict.alice = 34;
	dict.bob = 24;
	dict.chris = 62;
	dict.count();
	```
	- 将Object的直接实例作为字典，而不是其子类，当然也不是数组
		- 所有人都不应当增加属性到Object.prototype中，因为这样做可能会污染for...in循环，但是增加属性到Array.prototype中是合理的

	```
	var dict = {};
	dict.alice = 34;
	dict.bob = 24;
	dict.chris = 62;
	var names = [];
	for(var name in dict){
	    names.push(name);
	}
	names;
	```

### 使用null原型以防止原型污染
1. 在ES5中环境中，使用Object.create(null)创建的自由原型的空对象是不太容易被污染的。
	- 防止原型污染的最简单方式之一就是一开始就不要使用原型

	```
	var x = Object.create(null);
	Object.getPrototypeOf(x) === null;  // true
	// 使用__proto__
	var o = {__proto__: null};
	o instanceof Object; // false
	```
2. 在一些较老的环境中，考虑使用{`__proto__`:null}
3. 但是要注意`__proto__`既不标准，也不是完全可移植的，并且可能会在未来的JS环境中去除
4. 绝不要使用"`__proto__`"名作为字典中的key,因为一些环境将其作为特殊的属性对待

### 使用hasOwnProperty方法以避免原型污染
1. 使用hasOwnProperty方法避免原型污染
2. 使用词法作用域和call方法避免覆盖hasOwnProperty方法

	```
	var hasOwn = Object.prototype.hasOwnProperty;
	// 更加简明
	var hasOwn = {}.hasOwnProperty;
	```
3. 考虑在封装hasOwnProperty测试样板代码的类中实现字典操作

	```
	function Dict(elements){
	    this.elements = elements || {};
	}
	Dict.prototype.has = function(key){
	    return {}.hasOwnProperty.call(this.elements, key);
	};
	Dict.prototype.get = function (key) {
	    return this.has(key) ? this.elements[key] : undefined;
	};
	Dict.prototype.set = function(key, val){
	    this.elements[key] = val;
	};
	Dict.prototype.remove = function (key) {
	    delete this.elements[key];
	};
	```
4. 使用字典类避免将"`__proto__`"作为key来使用

### 使用数组而不要使用字典来存储有序集合
1. 使用for...in循环来枚举对象属性应当与顺序无关
	- for...in循环会挑选一定的顺序来枚举对象的属性，如果要依赖一个数据结构中的条目顺序，请使用数组而不是字典
2. 如果聚集运算字典中的数据，确保聚集操作与顺序无关
3. 使用数组而不是字典来存储有序集合

```
var ratings = {
    "Good Will Hunting": 0.8,
    "Mystic River": 0.7,
    "21": 0.6,
    "Doubt": 0.9
};
var total = 0, count = 0;
for(var key in ratings){
    total += ratings[key];
    count++;
}
total /= count;
console.log(total);  // 0.7499999999999999
(0.8 + 0.7 + 0.6 + 0.9)/4;   // 0.75
```

### 绝不要在Object.prototype中增加可枚举的属性
1. 避免在Object.prototype中增加属性
	- 如果想允许对字典对象使用for...in循环，那么不要在共享的Object.prototype中增加可枚举的属性
2. 考虑编写一个函数代替Object.prototype方法
3. 如果你确实需要在Object.prototype中增加属性，使用ES5中国的Object.defineProperty方法将它们定义为不可枚举的属性
	- Object.defineProperty方法可以定一个对象的属性并指定该属性的元数据

### 避免在枚举期间修改对象
1. 当使用for...in循环枚举一个对象的属性时，确保不要修改该对象
	- 如果被枚举的对象在枚举期间添加了新的属性，那么在枚举期间并不能保证新添加的属性能被访问。

	```
	function Member(name) {
	    this.name = name;
	    this.friends = [];
	}
	var a = new Member('Alice'),
	    b = new Member('Bob'),
	    c = new Member('Carol'),
	    d = new Member('Dieter'),
	    e = new Member('Eli'),
	    f = new Member('Fatima');
	a.friends.push(b);
	b.friends.push(c);
	c.friends.push(e);
	d.friends.push(b);
	e.friends.push(d,f);
	Member.prototype.inNetwork = function(other){
	    var visited = {};
	    var workset = {};
	    workset[this.name] = this;
	    for(name in workset){
	        var member = workset[name];
	        delete workset[name];
	        if(name in visited){
	            continue;
	        }
	        visited[name] = member;
	        if(member === other) {
	            return true;
	        }
	        member.friends.forEach(function(friend){
	            workset[friend.name] = friend;
	        });
	    }
	    return false;
	};
	a.inNetwork(f);
	```
2. 当迭代一个对象时，如果该对象的内容可能会在循环期间被改变，应该使用while循环或经典的for循环来代替for...in循环

	```
	Member.prototype.inNetwork = function(other){
	    var visited = {};
	    var workset = [this];
	    while(workset.length > 0){
	        var member = workset.pop();
	        console.log(member);
	        if(member.name in visited){
	            continue;
	        }
	        visited[member.name] = member;
	        if(member === other) {
	            return true;
	        }
	        member.friends.forEach(function(friend){
	            workset.push(friend);
	        });
	    }
	    return false;
	};
	a.inNetwork(f);
	```
3. 为了在不断变化的数据结构中能够预测枚举，考虑使用一个有序的数据结构，例如数组而不要使用字典对象

### 数组迭代要优先使用for循环而不是for...in循环
1. 迭代数组的索引属性应当总是使用for循环而不是for...in循环
2. 考虑在循环之前将数组的长度存储在一个局部变量中以避免重新计算数组长度
	- 保证避免重新计算scores.length是安全的
	- 循环的终止条件是简单且确定的

### 迭代方法优于循环
1. 使用迭代方法(如Array.prototype.forEach和Array.prototype.map)替换for循环使得代码更可读，并且避免了重复循环控制逻辑
	- Array.prototype.forEach，代码简单可读，且消除了终止条件和任何数组索引
	- Array.prototype.map，对数组的每个元素进行一些操作后建立一个新的数组，该方法模式更简单和优雅
	- Array.prototype.filter，用于计算一个新的数组，该数组包含现有数组的一些元素
2. 使用自定义的迭代函数来抽象未被标准库支持的常见循环模式
3. 在需要提前终止循环的情况下，仍然推荐使用传统的循环。另外，some和every方法也可用于提前退出
	- 循环只有一点优于迭代函数，那就是前者有控制流操作，如break和continue
	- 迭代中可以使用一个内部异常来终止循环，但这既尴尬又效率低下

### 在类数组对象上复用通用的数组方法
1. 对于类数组对象，通过提取方法对象并使用call方法来复用通用的Array方法
	- 字符串也表现为不可变的数组，因为它们是可索引的，并且其长度也可以通过length属性获取，因此Array.prototype中的方法操作字符串时并不会修改原始数组

	```
	var str = 'abcdef';
	var result = [].map.call(str, function(s){
	    return s.toUpperCase();
	});
	result;  //["A", "B", "C", "D", "E", "F"]
	```
2. 任意一个具有索引属性和恰当length属性的对象都可以使用通用的Array方法

	```
	var arrayLike = {'0':'a', '1':'C', length:2};
	var result = [].map.call(arrayLike, function(s){
	    return s.toUpperCase();
	})
	```

### 数组字面量优于数组构造函数
1. 如果数组构造函数第一个参数是数字则数组的构造函数行为是不同的
	- 首先必须确保，没有人重新包装过Array变量
	- 确保没人修改过全局的Array变量
	- 如果使用单个数字参数来调用Array构造函数，效果完全不同`[17]与Array(17)`
2. 使用数组字面量替代数组构造函数
	- 字面量是一种表示数组的优雅的方法

## 库和API设计
### 保持一致性的约定
1. 在变量命名和函数标签中使用一致的约定
	- 学习曲线尽可能的简单
	- 约定参数的顺序,确保参数总是以相同的顺序出现
	- 需要尽可能详尽的稳定
2. 不要偏离用户在他们开发平台中很可能遇到的约定

### 将undefined看做'没有值'
1. 避免使用undefined表示任何非特定值
	- 当JS无法提供具体的值时，就产生undefined
		- 未赋值的变量的初始值即为undefined
		- 访问对象中不存在的属性也会产生undefined
		- 一个函数体结尾使用未带参数的return语句，或未使用return语句都会产生返回值undefined
		- 未给参数提供实参则该函数参数值为undefined
2. 使用描述性的字符串值或命名布尔属性的对象，而不要使用undefined或null来代表特定应用标志

	```
	 element.highlight(undefined); //use a random color
	 element.highlight('random'); //use a random color
	```
3. 提供参数默认值应当采用测试undefined的方式，而不是检查arguments.length

	```
	function Server(port, hostname){
	    if(arguments.length < 2){
	        hostname = 'localhost';
	    }
	    // hostname = String(hostname || 'localhost');
	    hostname = String(hostname);
	    console.log(hostname);
	    // ...
	}
	var hostname;
	var port = 8080;
	Server(port, hostname);
	```
4. 在允许0、NaN或空字符串为有效参数的地方，绝不要通过真值测试来实现参数默认值

### 接收关键字参数的选项对象
1. 使用选项对象使得API更具可读性、更容易记忆
	- JS提供了一个简单、轻量的惯用法:选项对象(options object)
2. 所有通过选项对象提供的参数应当被视为可选的
	- 选项对象所有参数都是可选的
	- 习惯上，选项对象仅包括可选参数，因此省略掉整个对象甚至是可能的
	- 如果有一个或者两个必选参数，最好使它们独立于选项对象
3. 使用extend函数抽象出从选项对象中提取值的逻辑
	- 有用的抽象(对象扩展或合并函数)
	- 枚举对象的属性，并当这些属性不是undefined时将其复制到目标对象中
	- 使用或(||)操作符是一种提供默认参数值有效但非一致的策略，一致性是库设计的一个良好目标，它给API的使用者带来更好的可选测性

### 避免不必要的状态
1. 尽可能地使用无状态的API
	- API有时被归为两类:有状态和无状态的
	- 无状态的API提供的函数或方法的行为只取决于输入。字符串的方法是无状态的
	- Date对象的方法是有状态的
	- 相比于有状态的API，无状态的API会自动重用默认值
2. 如果API是有状态的，标示出每个操作与哪些状态有关联

### 使用结构类型设计灵活的接口
1. 使用结构类型(也称鸭子类型)来设计灵活的对象接口
2. 结构接口更灵活、更轻量，所以应该避免使用继承
3. 针对单元测试，使用mock对象即接口的替代实现来提供可复验的行为

### 区分数组对象和类数组对象
1. 绝不重载与其它类型有重叠的结构类型
2. 当重载一个结构类型与其它类型时，先测试其它类型
3. 当重载其它对象类型时，接收真数组而不是类数组对象
4. 文档标注你的API是否接收针数组或类数组值
5. 使用ES5提供的Array.isArray方法测试真数组

### 避免过度的强制转换
1. 避免强制转换和重载的复用
	- 强制转换会将方法的参数强制转换从而完全破坏重载
	- [方法重载](http://baike.baidu.com/link?url=4K_F59Sw4JtanVpVeXzvXrph47UpLAkPPzuRGq34MKnKYa7WQyiXmuZX6u6gatKDm2L0qnOnWaEGATgOnTWBma)
2. 考虑防御性地监视非预期的输入
	- 防御式编程:试图以额外的检查来抵御潜在的错误(抵御所有的错误是不可能的)
	- 防御式编程可以帮助更早的捕获错误，但是其可能扰乱代码库并潜在地影响应用程序的性能。
	- 是否使用防御式编程:成本(不得不编写和执行额外测试的数量)和收益(更早捕获错误数，节省开发和调试时间)

### 支持方法链
- 使用方法链来连接无状态的操作
	- 重复的方法调用风格叫做方法链.
	- 消除临时变量，中间结果只是得到最终结果的一个重要步骤而已
	- 方法链的方式非常灵活
	- 如果一个API产生了1个接口对象，调用这个接口对象的方法产生的对象如果具有相同的接口，那么就可以使用方法链

	```
	function escapeBasicHTML(str){
    	return str.replace(/&/g, "&amp;")
                .replace(/</g, "&lt;")
                .replace(/>/g, "&gt;")
                .replace(/"/g, "&quot;")
                .replace(/'/g, "&apos;")
	}
	var html = '<span class="vote-count">175</span>'
	escapeBasicHTML(html);
	```
- 通过在无状态的方法中返回新对象来支持方法链
- 通过在有状态的方法中返回this来支持方法链
	- 有状态的API的方法链有时被称为流畅式(fluent style,一个对单个对象调用多个方法的内置的语法)
	- 前端库jQuery普遍采用这种方法，它有一组(无状态的)方法用于从用户界面元素中查询网页,还有一组(有状态的)方法用于更新这些元素。

	```
	$('#notification')     // 查找notification元素
	    .html('Server not responding.')   // 设置notification消息
	    .removeClass('info')    // 移除设置样式
	    .addClass('error')    // 添加样式
	```

## 并发

JS是一种嵌入式的脚本语言，JS不是以独立的应用程序运行，而是作为大型应用程序环境下的脚本运行。

使用事件和异步API是JS编程的基础部分。

### 不要阻塞I/O事件队列
1. 异步API使用回调函数来延缓处理代价高昂的操作以避免阻塞主应用程序.
	- 异步的API用在基于事件的环境中事安全的，因为它们迫使应用程序逻辑在一个独立的事件循环‘轮询’中继续处理
2. JS并发地接收事件，但会使用一个事件队列按序地处理事件处理程序
	- 并行执行子计算:允许程序的一部分停下来等待(阻塞)一个低速的输入，而程序的另一部分可以继续进行独立的工作
3. 在应用程序事件队列中绝不要使用阻塞的I/O
	- 大多数的I/O操作都提供了异步的或非阻塞的API

### 在异步序列中使用嵌套或命名的回调函数
1. 使用嵌套或命名的回调函数按顺序地执行多个异步操作
	- 理解操作序列的最简单的方式是异步API是发起操作而不是执行操作
2. 尝试在过多的嵌套的回调函数和尴尬的命名的非嵌套回调函数之间取得平衡
	- 嵌套的异步操作很容易，但当扩展到更长的序列时会很快变得笨拙
	- 减少过多嵌套的方法之一是将嵌套的回调函数作为命名的函数
3. 避免将可被并行执行的操作顺序化

### 当心丢弃错误
1. 通过编写共享的错误处理函数来避免复制和粘贴错误处理代码
2. 确保明确地处理所有的错误条件以避免丢弃错误
	- 多部的处理通常被分隔到事件队列的单独轮次中
	- 异步的API甚至不可能抛出异常，异步的API倾向于将错误表示为回调函数的特定参数，或使用一个附加的错误处理回调函数(有事被称为errbacks)
	- 另一种错误处理API，主要一个回调函数，该回调函数的第一个参数如果有错误发生那就表示为一个错误，否则就为一个假值,比如null

### 对异步循环使用递归
1. 循环不能是异步的

	```
	function downloadOneSync(urls){
	    for(var i = 0; n = urls.length; i++){
	        try{
	            return downloadSync(urls[i]);
	        }catch(e){}
	    }
	    throw new Error('all downloads failed');
	}
	// 以上使用循环，会启动所有下载
	```
2. 使用递归函数再事件循环的单独轮次中执行迭代

	```
	function downloadOneSync(urls, onsuccess, onerror){
	    var n = urls.length;
	    function tryNextURL(i){
	        if(i >= n){
	            onerror('all downloads failed');
	            return;
	        }
	        downloadSync(urls[i], onsuccess, function(){
	            tryNextURL(i + 1);
	        });
	    }
	    tryNextURL(0);
	}
	```
3. 在事件循环的单独轮次中执行递归，并不会导致调用栈溢出
	- JS环境通常在内存中会保存一块固定的区域，称为调用栈，用于记录函数调用返回前下一步该做什么。
	- 当一个程序执行中有太多的函数调用，它会耗尽栈空间，最终抛出异常。这种情况被称为栈溢出

### 不要在计算时阻塞事件队列
1. 避免在主事件队列中执行代价高昂的算法
	- 为了保持客户端应用程序的高度交互性和确保所有传入的请求在服务器应用程序中得到充分的服务，保持事件循环的每个轮次尽可能短是至关重要的。
	- 一个页面的用户界面无响应多数是由于在运行JS代码
2. 在支持Worker API的平台，该API可以用来在一个独立的事件队列中运行长计算程序
3. 在Worker API不可用或代价昂贵的环境中，考虑将计算程序分解到事件循环的多个轮次中

### 使用计数器来执行并行操作
1. JS应用程序中的事件发生是不确定的，即顺序是不可预测的

	```
	function downloadAllAsync(urls, onsuccess, onerror){
	    var result = [], length = urls.length;
	    if(length === 0){
	        setTimeout(onsuccess.bind(null, result), 0);
	        return;
	    }
	    urls.forEach(function(url){
	        downloadSync(url, function(text){
	            if(result){
	                result.push(text);
	                if(result.length === urls.length){
	                    onsuccess(result);
	                }
	            }
	        }, function(error){
	            if(result){
	                result = null;
	                onerror(error);
	            }
	        })
	    });
	}
	// 以上代码异步的启动文件下载，当文件下载完成就会将中间结果保存在result数组的末尾，因此保存下载文件内容的数组的顺序是未知的，因此调用者无法找出哪个结果对应哪个文件
	```

	- 如果行为不可预知，则不能信赖程序中不确定的行为，即程序的执行顺序不能保证与事件发生的顺序一致

2. 使用计数器避免并行操作中的数据竞争
	- 数据竞争是指多个并发操作可以修改共享的数据结构，这取决于它们发生的顺序

	```
	function downloadAllAsync(urls, onsuccess, onerror){
    var result = [], pending = urls.length;
    if(pending === 0){
        setTimeout(onsuccess.bind(null, result), 0);
        return;
    }
    urls.forEach(function(url, i){
        downloadSync(url, function(text){
            if(result){
                result[i] = text;  //存储在固定index
                pending--;
                if(pending === 0){
                    onsuccess(result);
                }
            }
        }, function(error){
            if(result){
                result = null;
                onerror(error);
            }
        })
    });
	}
	```

### 绝不要同步地调用异步的回调函数
1. 即使可以立即得到数据，也绝不要同步地调用异步回调函数
2. 同步地调用异步的回调函数扰乱了预期的操作序列，并可能导致意想不到的交错代码
3. 同步地调用异步的回调函数可能导致栈溢出或错误地处理程序
4. 使用异步的API，比如setTimeout函数来调度异步回调函数，使其运行于另一个回合

```
var cache = new Dict();
function downloadCachingAsync(url, onsuccess, onerror){
    if(cache.has(url)){
        onsuccess(cache.get(url));  // 同步调用
        // var cached = cache.get(url);
        // setTimeout(onsuccess.bind(null, cached), 0);  // 异步调用
        return;
    }
    return downloadAsync(url, function(file){
        cache.set(url, file);
        onsuccess(file);
    }, onerror);
}
```

### 使用promise模式清洁异步逻辑
1. promise代表最终值，即并行操作完成时最终产生的结果
	- 基于promise的API不接收回调函数作为参数,相反它返回一个promise对象，该对象通过其自身的then方法接收回调函数。
	- 传递给then的回调函数不仅产生影响，也可以产生结果(resolve中返回值在下一个then中接收)
2. 使用promise组合不同的并行操作
	- promise.all、promise.race等
3. 使用promise模式的API避免数据竞争
4. 在要求有意的竞争条件时使用select(也被称为choose)

# 参考文献
1. 函数[柯里化](http://www.cnblogs.com/pigtail/p/3447660.html)
2. [Unicode与JS]([http://www.ruanyifeng.com/blog/2014/12/unicode.html)
3. [Effective JavaScript](https://book.douban.com/subject/25786138/)

