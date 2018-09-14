title: 原型和原型链
date: 2018-07-29
categories: juga
tags:
- prototype
- prototype chain

---
对原型和原型链的关系进行探讨,通过简单的例子加深对原型和原型链的理解



##如何理解JavaScript的原型?

**这里有几句总结的话**

- 引用类型都具有对象特性.
- 引用类型都有一个\_\_proto__属性,属性值是一个对象(特例:使用Object.create(null)创建的对象是没有\_\_proto__属性的)
- 函数都有一个prototype属性,属性值也是一个对象
- 引用类型的\_\_proto__属性值指向它的构造函数的prototype属性值

##demo

```
// 构造函数
function Foo(name) {
    this.name = name;
}
Foo.prototype.alertName = function () {
    alert(this.name);
}
// 创建示例
var f = new Foo('zhangsan')
f.printName = function () {
    console.log(this.name);
}
// 测试
f.printName();
f.alertName();
console.log(f.toString());
```

##构造函数
上面使用构造函数模式创建了一个自定义的构造函数Foo,然后可以定义自定义对象类型的属性和方法.上面就定义了name属性和alertName方法.一般我们创建构造函数会以一个大写字母开头,主要是为了区别于ECMAScript中的其他函数,其实构造函数本身也是函数,只不过是可以用来创建对象而已.
构造函数通过其prototype来存储要共享的属性和方法.
然后再用Foo构造函数创建对象f,对象f为此构造函数的一个实例.
我们可以对已定义的对象添加属性或者方法,例如上面的f.printName,而且这个不会影响任何用Foo创建的其他对象.
关于继承则是通过设置f的\_\_proto__指向构造函数的prototype来实现继承,下面会有验证.

##new操作符
在创建新实例的时候用到了new操作符.当在用new这种方式调用构造函数时,实际上经历了以下四个步骤:
1).先创建一个新对象;
2).将新对象的\_\_proto__指向构造函数的prototype.
3)将构造函数的作用域赋值给新对象(因此this就指向了这个新对象);
4).执行构造函数中的代码(为这个新对象添加属性)
5).返回新对象
使用new操作符创建的对象都会有一个constructor属性,该属性指向Foo
console.log(f instanceof Foo);//true

##原型与原型链
JS是通过\_\_proto__和prototype的合作一起来完成原型链的构造和对象的继承.
上面例子中,对象f,本身是没有toString()这个方法的,并且f.\_\_proto__ (即Foo.prototype)也是没有toString()方法.当代码运行时试图得到一个对象的某个属性时,如果这个对象本身没有这个属性,那么会去这个对象的\_\_proto__ (即它的构造函数的prototype)中寻找.
如果在f.\_\_proto__ 中还是没有找到toString,那么就会继续到f.\_\_proto__ .\_\_proto__中寻找,因为f.\_\_proto__就是一个对象.

这样一路向上寻找某属性方法的过程就会形成一个链式的结构,因而可称作原型链,假如一直找到最上层都没有找到要找的属性方法,就会返回undefined.这里要提到的是最上层是什么呢---应该大家都知道的:
Object.prototype.\_\_proto__ === null

- f.\_\_proto__即Foo.prototype,没有toString(),继续往上面找
- f.\_\_proto__ .\_\_proto__ 即Foo.prototype.\_\_proto__ . 这里Foo.prototype也是一个对象而已,故而Foo.prototype.\_\_proto__就是Object.prototype,此时便找到了toString方法.
- 到这里就找到了,f.toString()对应到Object.prototype.toString



##验证
```
console.log(f instanceof Foo);//true
console.log(f.__proto__ === Foo.prototype);//true
console.log(Foo.__proto__ === Function.prototype);//true
console.log(Function.prototype.__proto__ === Object.prototype);//true
console.log(Foo.prototype.__proto__ === Object.prototype);//true
console.log( f.__proto__.__proto__ === Object.prototype);//true
console.log(Foo.__proto__.__proto__ === Object.prototype);//true
```

![原型链图](https://github.com/jugaaaa/react-native_demo/blob/master/components/yxl.svg)

##总结
f 是 Foo 函数的一个实例， 那么（根据每个引用类型都有一个\_\_proto__ 属性，此属性是一个对象的规则）f.\_\_proto__ （根据每个引用类型的\_\_proto__ 属性值指向构造函数的prototype 属性值的规则）指向了Foo.prototype.  
而Foo.\_\_proto__ 同时也是指向了Function.prototype。而Function.prototype.\_\_proto__ 指向Object.prototype;

f属于实例,没有prototype属性,而Foo是函数，Foo.prototype.\_\_proto__ 指向Object.prototype, Function.prototype.\_\_proto__ 指向 Object.prototype;
这里发现一个有趣的事情,Function.prototype和Foo.prototype的\_\_proto__ 属性都是指向Object.prototype.

进而推出,f.\_\_proto__ .\_\_proto__ 和f.\_\_proto__ .\_\_proto__ 都指向Object.prototype.
从\_\_proto__ 角度上来看,f和它的构造函数Foo同属于原型链最底层,而Foo.prototype与Foo.\_\_proto__ 并不是同一个东西.