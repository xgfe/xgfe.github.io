title: 原型和原型链
date: 2018-07-31
categories: juga
tags:
- prototype
- prototype chain

---

本文是在学习JavaScript的原型和原型链的时候整理的学习笔记.

##如何理解JavaScript的原型?

**这里有几条我们要首先理解并记住**

- 所有的引用类型,都具有对象特性,可以自由的扩展属性(null除外)
- 所有的引用类型,都有一个\_\_proto__属性,属性值是一个普通的对象
- 所有的函数,都有一个prototype属性,属性值也是一个普通对象
- 所有的引用类型,\_\_proto__属性值指向它的构造函数的prototype属性值

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

上面例子中,函数f,本身是没有toString()这个方法的,并且f.\_\_proto__ (即Foo.prototype)也是没有toString()方法.当编译器试图得到一个对象的某个属性时,如果这个对象本身没有这个属性,那么会去这个对象的\_\_proto__ (即它的构造函数的prototype)中寻找.
如果在f.\_\_proto__ 中还是没有找到toString,那么就会继续到f.\_\_proto__ .\_\_proto__中寻找,因为f.\_\_proto__就是一个普通对象.

- f.\_\_proto__即Foo.prototype,没有toString(),继续往上面找
- f.\_\_proto__ .\_\_proto__ 即Foo.prototype.\_\_proto__ . 这里Foo.prototype也是一个普通对象而已,故而Foo.prototype.\_\_proto__就是Object.prototype,此时便找到了toString方法.
- 到这里就找到了,f.toString()对应到Object.prototype.toString

这样一路向上寻找某属性方法的过程就会形成一个链式的结构,因而可称作原型链,假如一直找到最上层都没有找到要找的属性方法,就会返回undefined.这里要提到的是最上层是什么呢---应该大家都知道的:
Object.prototype.\_\_proto__ === null

##验证
```
console.log(f.__proto__ === Foo.prototype);//true
console.log(Foo.__proto__ === Function.prototype);//true
console.log(Function.prototype.__proto__ === Object.prototype);//true
console.log(Foo.prototype.__proto__ === Object.prototype);//true
console.log( f.__proto__.__proto__ === Object.prototype);//true
console.log(Foo.__proto__.__proto__ === Object.prototype);//true
```

##总结
f 函数是 Foo 函数的一个实例， 那么（根据每个引用类型都有一个\_\_proto__ 属性，此属性是一个普通对象的规则）f.\_\_proto__ （根据每个引用类型的\_\_proto__ 属性值指向构造函数的prototype 属性值的规则）指向了Foo.prototype.  
而Foo.\_\_proto__ 同时也是指向了Function.prototype。而Function.prototype.\_\_proto__ 指向Object.prototype;

f属于实例,没有prototype属性,而Foo是函数，Foo.prototype.\_\_proto__ 指向Object.prototype, Function.prototype.\_\_proto__ 指向 Object.prototype;
这里发现一个有趣的事情,Function.prototype和Foo.prototype的\_\_proto__ 属性都是指向Object.prototype.

进而推出,f.\_\_proto__ .\_\_proto__ 和f.\_\_proto__ .\_\_proto__ 都指向Object.prototype.
从\_\_proto__ 角度上来看,f和它的构造函数Foo同属于原型链最底层,而Foo.prototype与Foo.\_\_proto__ 并不是同一个东西.
