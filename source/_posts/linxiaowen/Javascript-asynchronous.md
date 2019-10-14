title: JS异步语法
date: 2019-08-07
categories:
- Linxiaowen
tags:
- JS异步
---
本文主要针对Javascript中异步编程的几种语法以及使用方式进行了介绍。

<!--more-->

## 前言 同步与异步
在JS中，通常代码按顺序从上到下同步执行，但某些特殊场景/操作下需要以异步的方式执行，即将代码划分为至少两部分，先执行一部分代码，在进行耗时操作时将主线程的执行权交出，执行其他代码，待耗时任务完成后以一定规则触发使得另一部分代码被继续执行。

JS中常见的异步执行场景：网络请求（Ajax等）、定时器（SetTimeout等）、IO操作（readFile等）...

对于JS的这些异步场景，有两个重点：

1.得知异步任务何时结束，以便进行后续操作；
2.处理多个异步任务按顺序执行/并发执行的场景；

在处理JS异步场景方法的衍化过程当中，逐步出现了几种方式：
* 回调函数
* 事件监听
* 发布订阅
* Promise
* Generator/yield
* Async/await

---

## 回调函数
JS中最常见的处理异步问题的方法，将任务结束时要做的事（或者说必须拿到异步任务的结果才能进行的操作）包装成函数作为参数传递给异步操作，待异步操作结束后执行函数，称之为“回调”函数。如SetTimeout函数就接受一个函数参数作为回调函数，在指定延迟时间后执行该回调函数：

```
异步操作setTimeout示例
setTimeout(function(){//延迟100ms后执行“代码块”；延迟即视为异步操作，代码块则是异步操作结束后的“回调函数”；
  //代码块
}，100);
```

回调函数的异步方法简单易理解，但不利于代码维护，尤其在多个异步任务继发执行使得回调函数嵌套的情况下，代码耦合度高不利于代码的阅读和维护，且每个任务只能指定一个回调函数。此外它不能使用 try catch 捕获错误，不能直接 return。

虽然回调函数这种方式问题很多，但是不可否认的是在ES6之前，他就是处理异步问题普遍较好的方式，而且后面很多方式仍然基于回调函数。

---

## 事件监听
JS中关于DOM操作的一系列监听事件也属于异步方法，如监听各种元素的onclick、onload等方法。只有当监听元素对应的事件被发生时对应的代码才会被执行。

回调函数与事件监听的区别：

* 回调函数多是一对一的关系，事件监听可以是多对一。
* 运行异步函数，在一个不确定的时间段之后运行回调函数；不确定何时触发事件，但是触发事件同步响应事件的回调。
* 事件监听相对于回调函数，可配置的监听（可增可减）关系减少了耦合性。
* 不过事件监听也存在问题：
* 多对多的监听组成了一个复杂的事件网络，单个节点通常监听了多个事件，维护成本很大。
* 多个异步事件仍然还是回调的形式。

---

## 发布订阅
和事件监听非常类似的是发布/订阅者模式，在事件监听的基础上，假定存在一个 " 消息中心 "，某个任务执行完成，就向消息中心 " 发布 "（publish）一个消息，其他任务可以向消息中心 " 订阅 "（subscribe）这个消息，从而知道什么时候自己可以开始执行。（直观产品就是微信的公众号模式）

发布订阅模式在事件监听的基础上增加消息中心的概念，使得多个监听事件的运转流程和消息传递更加有序。但与事件监听相同的是发布订阅者模式也是“事件驱动”型，无法预知到事件何时发生/发布。

---

## Promise
Promise的三种状态：pending（进行中），fulfilled（已成功），rejected（已失败），其状态只能从进行中到成功或者是失败，不可逆。而当Promise成功/失败/发生错误时可以调用不同的回调函数来处理不同的情况。当状态定型后称为resolved(已定型)，为了方便表述，后续所有resolved统一只指fulfilled状态，不包含rejected状态。基本使用方法如下：

```
let promise1 = new Promise((resolve, reject) => {//传入resolve和reject两个函数(自带，名字也随意)来改变Promise的状态
  //一顿操作
  if(/*异步操作成功*/){
  	resolve('success'); //调用resolve函数使Promise状态从pengding=>fulfilled,reject则相反；
  }else{
  	 reject('reject');
  }
  //还可以操作，promise状态变化后仍会继续执行代码，但原则上不应该，因此可以用return resolve();的方式避免该情况；
});
promise1.then(//then方法是在Promise结束(成功/失败)后进行调用，可以传入两个回调函数作为参数分别对应成功/失败的状态；
  value => {//回调函数的参数(此为value)则是Promise状态转换时传递出的信息，resolve("success")中的“success”；
    console.log(value);
  },
  reason => {//then方法的第二个回调函数为可选；
    console.log(reason);//reject
  }
)
```

### 当resolve(a)传递的参数a也是一个Promise时

```
const p1 = new Promise(function (resolve, reject) {
  setTimeout(() => reject(new Error('fail')), 3000)
})
const p2 = new Promise(function (resolve, reject) {
  setTimeout(() => resolve(p1), 1000)
})
p2
  .then(result => console.log(result))
  .catch(error => console.log(error))
// Error: fail，3秒后
```
由于p2返回的是另一个 Promise，导致p2自己的状态无效了，由p1的状态决定p2的状态。所以，后面的then语句都变成针对后者（p1）。又过了 2 秒，p1变为rejected，导致触发catch方法指定的回调函数。

### Promise的链式调用(then)
then函数定义在原型对象Promise.prototype.then()上，then函数可以链式调用，因为每次调用返回的都是一个新的 Promise 实例；promise1.then().then().then()...

* 在 then 中使用了 return，那么 return 的值会被 Promise.resolve() 包装，传递给下一次 then 中的成功回调 ；
* then 中可以不传递参数，如果不传递（then().then(...)？）会透到下一个 then 中 ；
* 如果 then 中出现异常, 会走下一个 then 的失败回调/被最近的catch捕获；

### Promise的异常捕获（catch）

Promise.prototype.catch方法是.then(null, rejection)或.then(undefined, rejection)的别名，用于指定发生错误时的回调函数。当异步操作抛出错误时状态会变为rejected，then方法指定的回调函数，如果运行中抛出错误，也会被catch方法捕获。

```
a=new Promise(function(res,rej){//当Promise内抛出错误，且then函数有rejected的回调函数以及存在catch函数
	throw new Error("cuowu");
})
.then(null,function(val){
	console.log("rej"+val);
  throw new Error("reject error");//在rejected回调函数中抛出错误会被catch捕获
})
.catch(function(e){
	console.log("err"+e);
});
//rejError: cuowu		//即会直接被rejected回调函数捕获而不被catch捕获
//errError: reject error
```

1. Promise 在resolve语句后面，再抛出错误不会被捕获，等于没有抛出。因为 Promise 的状态一旦改变，就永久保持该状态，不会再变了。

2. Promise 对象的错误具有“冒泡”性质，会一直向后传递，直到被捕获为止。也就是说，错误总是会被下一个catch语句捕获。

3. 一般来说，不要在then方法里面定义 Reject 状态的回调函数（即then的第二个参数），总是使用catch方法(还可以捕获then中的错误)。

4. catch方法返回的还是一个 Promise 对象，状态变为resolve，因此后面还可以接着调用then方法。

5. catch不会捕获其之后的错误（catch().then().then(),后面两个then函数中错误与catch无关）。

6. catch中报错与then一样向下传递，若有catch则能被捕获。


若没有用catch方法捕获错误，Promise 对象抛出的错误不会传递到外层代码，即运行出错仍然会报错，但不会退出进程终止运行。
```
const someAsyncThing = function() {
  return new Promise(function(resolve, reject) {
    resolve(x + 2);// 下面一行会报错，因为x没有声明
  });
};
someAsyncThing().then(function() {
  console.log('everything is great');
});
setTimeout(() => { console.log(123) }, 2000);
// Uncaught (in promise) ReferenceError: x is not defined
// 123    	//即使报错但2秒后仍然输出123；
```

Promise 指定在下一轮“事件循环”再抛出错误。到了那个时候，Promise 的运行已经结束了，所以这个错误是在 Promise 函数体外抛出的，会冒泡到最外层，成了未捕获的错误。
```
a=new Promise(function(res,rej){
	rej("rej");
  //res("ok");
  setTimeout(()=>{throw new Error("cuowu")},0);
})
.then(val=>console.log("res:"+val),function(val){
	console.log("rej"+val);})
.catch(function(e){console.log("err"+e);});
//rejrej
//Uncaught Error: cuowu		//无论用rej还是res,Promise里设置延时报错都不会被catch捕获（Promise已经结束了）
```
### Promise.all/Promise.race
#### Promise.all
Promise.all方法用于将多个 Promise 实例，包装成一个新的 Promise 实例。（and的判定方式）

Promise.all一般使用方法
```
const p = Promise.all([p1, p2, p3]);
//p的状态由p1/p2/p3决定，p1&&p2&&p3的关系，均resolve才resolve,任意一个rejected就rejected.
//传值：p状态resolve时，p1/p2/p3的返回值组成数组传给p的回调函数，
	//p状态rejected时，第一个被rejected的实例返回值传给p的回调函数。
```

* 接受一个数组参数（非数组也可，必须有Iterator接口），且返回的每个成员都是Promise实例。
* 若参数成员不是Promise实例会调用Promise.resolve方法将其转为Promise实例，再进一步处理。
* 如果作为参数的 Promise 实例，自己定义了catch方法，那么它一旦被rejected，并不会触发Promise.all()的catch方法，会被自己的catch方法捕获，而后返回的实例状态变成resolve，使得Promise.all()的整体状态可能变成resolve。

#### Promise.race
Promise.race方法同样是将多个 Promise 实例，包装成一个新的 Promise 实例。（or的判定方式）
* 只要参数中有一个实例率先改变状态，p的状态就跟着改变。那个率先改变的 Promise 实例的返回值，就传递给p的回调函数。
* 若参数成员不是Promise实例会调用Promise.resolve方法将其转为Promise实例（与all相同）。

### Promise.resolve/Promise.reject
#### Promise.resolve()
Promise.resolve方法可以将现有对象转为Promise对象。根据resolve()方法参数的不同有4种情况：
1. 参数是Promise对象，则不做任何修改、原封不动返回实例。
2. 参数是一个thenable对象（即对象具有then方法）
 * thenable被转为Promise实例后会直接调用then方法。
 * thenable的then函数中，使用rej和res可以改变实例状态,return不会被当成res对待，error会被当成rej对待。
 * thenable的then函数中，不使用res和rej则状态为pending，p1将不会执行then和catch。
3. 参数不是具有then方法的对象，或根本就不是对象
 * 返回一个新的Promise对象，状态为resolved，同时可以传值给回调函数(Promise.resolve("abc"))。
4. 不带任何参数(Promise.resolve())
 * 直接返回Promise对象，状态为resolved。

```
let thenable = {//thenable被转为Promise实例后会直接调用then方法。
  then: function(res, rej) {
    rej(42);	//res(3);	//使用rej和res可以改变实例状态,return不会被当成res对待，error会被当成rej对待。
    //console.log(1);	//不使用res和rej则状态为pending，p1将不会执行then和catch。
  },
};
let p1 = Promise.resolve(thenable);
p1.then(function(value) {
  console.log(value);
}).catch(val=>console.log(val));//thenable中then函数rejected/error会被捕获
```

立即resolve()的 Promise 对象，是在本轮“事件循环”（event loop）的结束时执行，而不是在下一轮“事件循环”的开始时（宏任务与微任务）。

#### Promise.reject()
Promise.reject方法与Promise.resolve类似，返回一个新的Promise实例，只是状态为rejected。

Promise.reject()方法的参数，会原封不动地作为reject的理由，变成后续方法的参数。这一点与Promise.resolve方法不一致。

Promise.reject(thenable)参数的thenable函数reject后，其信息不会被后续catch捕获，而是thenable对象被捕获。
```
const thenable = {
  then(resolve, reject) {
    reject('出错了');
  }
};
Promise.reject(thenable)
.catch(e => {
  console.log(e === thenable)
})
//true  //catch方法的参数不是reject抛出的“出错了”这个字符串，而是thenable对象。
```
### Promise.prototype.finally()
* finally用于指定不管Promise对象最后状态如何都会执行的操作，ES2018引入。
* finally不接受任何参数，因此也无法得知Promise的状态是fulfilled还是rejected，这表明finally方法里面的操作，应该是与状态无关的，不依赖于 Promise 的执行结果。
* finally的回调函数中写不写return都不影响finally函数将前面Promise的状态和值（PromiseStatus和PromiseValue）往后传递。
* finally函数执行后返回的还是一个Promise。

finally特性（不接受参数+传递状态和值）
```
Promise.resolve(2).finally((val) => {console.log(val)});
//undefined   //finally中参数val无效
//[[PromiseStatus]]: "resolved"  [[PromiseValue]]: 2    //可以传递Promise的状态和值
Promise.resolve(2).finally((val=3) => {console.log(val+1)}) //4   //默认参数有效但与Promise无关
```

### *Promise.try()
用于处理不区分/确认是同步or异步操作的情况，可以做到若try(a)的a是同步函数则同步执行，是异步函数则异步执行。浏览器还未原生支持，romise 库Bluebird、Q和when提供了该方法。自己实现该功能则是使用立即执行函数+async/promise：

async函数实现-同步操作同步执行，异步操作异步执行
```
const f = () => console.log('now');
(async () => f())()//f若是同步则会立即得到同步结果（后续有then函数则进入then函数），
.then(...)          //若异步则可以用then和catch进行下一步操作。
.catch(...);      //async () => f()会吃掉f()抛出的错误。所以，如果想捕获错误，要使用promise.catch方法。
console.log('next');
// now
// next
```

new Promise实现-同步操作同步执行，异步操作异步执行
```
const f = () => console.log('now');
(() => new Promise(
    resolve => resolve(f());  //使用resolve时用”f()“立即执行f函数。
))();
console.log('next');
// now
// next
```

Promise.try可以更好地管理异常，不论是同步操作or异步操作时抛出的错误。

1. 在构造 Promise 的时候，构造函数内部的代码是立即执行的；
2. Promise一旦运行，不能终止。
3. 利用Promise处理一个异步的后续处理十分简便，但是处理多个请求按顺序执行仍然很不方便。
4. 如果不设置回调函数，Promise内部抛出的错误，不会反应到外部。
5. 当处于Pending状态时，无法得知目前进展到哪一个阶段（刚刚开始还是即将完成）。

---

## Generator/yield
ES6中提供的一种异步编程解决方案，中文称为生成器，生成器可以在执行的时候暂停，交出函数执行权给其他函数，然后其他函数可以在需要的时候让该函数再次运行。

1. function和函数名之间加星号*，函数内部用yield划分不同操作or状态来暂停函数，函数外部用next方法重新启动。
2. yield 表达式本身没有返回值，返回 undefined。next 方法可以带一个参数，该参数就会被当作上一个 yield 表达式的返回值。

generator函数使用基本方法
```
function* foo(x) {  //加星号（无规范，在function与函数名之间即可，空格在哪边或者没有空格均可）
  console.log("begin");
  let y = 2 * (yield (x + 1));  //yield表达式作为暂停标记
  let z = yield (y / 3);
  return (x + y + z); //若此处return换成yield，则next执行至此返回的done=false，需再执行一次next，done=true；
}
let it = foo(5);  //首次执行函数不会执行函数内部（begin不会被打印），只传递参数，返回的是一个指向内部状态的指针对象（遍历器）。
console.log(it.next());   //next执行后函数内部继续执行，停在下一个yield处，返回的对象包含value和done两个属性；
// => {value: 6, done: false} //value为yield后面的表达式的值，done表示遍历是否结束；
console.log(it.next(12))  //next(12)函数可以传入参数，会传到继续执行的yield处代替上一次的yield表达式；
// => {value: 8, done: false} //12代替(x+1)因此y=24,本次next停在y/3处所以next.value=8
console.log(it.next(13))  //13传入即z=13
// => {value: 42, done: true}   //next.value=5+24+13=42,因为本次next执行至return所以done=true；
```

当一个对象的属性是 Generator 函数，可以简写成 ：* 属性名(){}的形式。
```
let obj = {  * myGeneratorMethod() { ···}}; //属性前加*,表明属性是个generator函数。
let obj = { myGeneratorMethod : function* () {...}};  //两种写法等价
```

### yield与yield*
#### yield表达式
* yield关键词作为每次函数执行next方法的分界点，其后面跟着的表达式会等到调用了next方法并执行到此处时才会进行计算。
* 当generator函数里没有使用yield表达式时，此时函数变成一个单纯的暂缓执行函数。（f.()不会执行内部语句，f.().next();才会执行）
* yield关键词若不在generator函数里会报错（即函数是否加*)。

#### yield*
用来在一个generator函数里执行另一个generator函数。当yield后面跟着的对象是另一个generator函数时，使用yield*可以进入其内部继续遍历状态。

yield*使用对比
```
function* inner() {
  yield 'hello!';
}
function* outer() {
  yield 'open';
  yield inner();
  yield* inner();
  yield 'close';
}
var gen = outer();
gen.next().value // "open"
gen.next().value // 返回一个遍历器对象。（不会进入内部）
gen.next().value // "hello!"    //该yield带*表明后续表达式也是generator函数，会进入内部遍历状态。
gen.next().value // "close"
```

* yield*后面的 Generator 函数（没有return语句时），等同于在 Generator 函数内部，部署一个for...of循环。
* 有return语句时，则需要用let value = yield* iterator的形式获取return语句的值（done=true时会直接略过value跳出函数继续寻找yield，但整个函数返回值为return后的值）。
* 任何数据结构只要有 Iterator 接口，就可以被yield*遍历（数组，字符串等等）。

yield*后跟着一个带有return语句的generator
```
function* genFuncWithReturn() {
  yield 'a';
  yield 'b';
  return 'The result';
}
function* logReturned(genObj) {
  let result = yield* genObj;
  console.log(result);
}
[...logReturned(genFuncWithReturn())]
// The result
// 值为 [ 'a', 'b' ]
```

### next方法的参数
* yield表达式本身没有返回值，或者说总是返回undefined。next方法可以带一个参数，该参数就会被当作上一个yield表达式的返回值。
* 由于next方法的参数表示上一个yield表达式的返回值，所以在第一次使用next方法时，传递参数是无效的。

如果想要第一次调用next方法时，就能够输入值，可以在 Generator 函数外面再包一层。

包装generator函数，首次next()在内部执行，外部从第二次开始（对于外部而言为第一次）即可传入参数
```
function wrapper(generatorFunction) {
  return function (...args) { //return第一个函数：包涵generator函数并执行一次的next.
    let generatorObject = generatorFunction(...args);
    console.log(args[0]);
    generatorObject.next();
    return generatorObject;
  };
}
const wrapped = wrapper(function* () {
  console.log(`First input: ${yield}`);
  return 'DONE';
});
wrapped(1).next('hello!');  //1   // First input: hello!
```

### generator函数遍历--针对同步操作
（iterator接口：for...of、...扩展运算符、Array.from）

由于 Generator 函数就是遍历器生成函数，因此可以把 Generator 赋值给对象的Symbol.iterator属性，从而使得该对象具有 Iterator 接口。

generator函数执行后，返回的遍历器对象，其本身也具有Symbol.iterator属性，执行后返回自身。

gen() === gen()\[Symbol.iterator\]()
```
function* gen(){
  // some code
}
let g = gen();
g[Symbol.iterator]() === g   //// true
```
generator函数赋值给对象的Symbol.iterator后，对象就可以被”...“扩展运算符遍历。

generator函数赋值给Symbol.iterator
```
let myIterable = {};
myIterable[Symbol.iterator] = function* () {
  yield 1;
  yield 2;
  yield 3;
};
[...myIterable] // [1, 2, 3]
```
for...of循环可以自动遍历 Generator 函数运行时生成的Iterator对象，且此时不再需要调用next方法。

一旦next方法的返回对象的done属性为true，for...of循环就会中止，且不包含该返回对象，所以下面代码的return语句返回的7，不包括在for...of循环之中。

generator函数用for循环自动执行(方便地取出嵌套数组的内容)
```
let arr = [1, [[2, 3], 4], [5, 6]];
let flat = function* (a) {
  let length = a.length;
  for (let i = 0; i < length; i++) {
    let item = a[i];
    if (typeof item !== 'number') {
      yield* flat(item);
    } else {
      yield item;
    }
  }
  return 7； //for...of循环不会返回7，因为此时done=true。
};
for (let f of flat(arr)) {
  console.log(f);
}
// 1, 2, 3, 4, 5, 6
```

原生的 JavaScript 对象没有遍历接口，无法使用for...of循环，通过 generator 函数为它加上这个接口，就可以用了。可以把对象作为参数传递给generator函数，然后使用for...of  gen(object)方式来遍历对象属性。也可以直接把写好的generator函数赋值给对象的Symbol.iterator属性，然后再遍历（后者更直观）。

除了for...of循环以外，扩展运算符（...）、解构赋值和Array.from方法内部调用的，都是遍历器接口。这意味着，它们都可以将 Generator 函数返回的 Iterator 对象，作为参数。

扩展运算符，Array.from，解构赋值，for...of循环分别遍历generator函数。
```
function* numbers () {
  yield 1;
  yield 2;
  return 3;
}
[...numbers()]        // 扩展运算符  // [1, 2]
Array.from(numbers());    // Array.from 方法  // [1, 2]
let [x, y] = numbers();   // 解构赋值   //x=> 1,y => 2
for (let n of numbers()) {    // for...of 循环
  console.log(n);         // 1  // 2
}
```
### generator函数throw、return方法
#### throw()
Generator 函数返回的遍历器对象，都有一个throw方法，可以在函数体外抛出错误(gen.throw())，然后在 Generator 函数体内捕获(try...catch)。

gen.throw()示例
```
var g = function* () {
  try {
    yield 1;
    yield 2;
  } catch (e) {
    yield 2.5;    //2.5会成为throw的返回值，若没有执行throw方法此yield会被略过。
    yield 2.7;    //2.7因为throw只会被捕获一次，因此会被throw紧接着的next取得，若throw紧接着还是throw则略过。
    console.log('内部捕获', e);
  }
  yield 3;
};
var i = g();
i.next();   //value:1
try {
  i.throw('a');   //value=2.5; throw除了抛出错误的语义外同时兼顾执行一次yield（catch内部的或是后续的，try里的略过）。
  i.throw('b');   //第二次执行throw函数由于内部已经执行过catch了，不会再捕获一次。
} catch (e) {
  console.log('外部捕获', e);       // 内部捕获 a   // 外部捕获 b
}
i.next();   //value:undefined,done:true
i.next();   //由于第二次throw被外部捕获，对内部而言即出错终止了，因此后续都是undefined。
//若没有第二次throw，则后两次next函数的value为2.7和3（2被第一次throw方法跳过了）。
```

* generator函数的throw方法与全局throw方法不同，后者只能被函数外的catch捕获（即在generator函数内部用全局throw抛出错误）。
* 如果 generator 函数内部没有部署try...catch代码块，那么generator的throw方法抛出的错误，将被外部try...catch代码块捕获。generator函数则相当于出错终止继续执行外部代码，使用next方法会返回{value:undefined, done=true}。
* 如果 generator 函数内部和外部都没有部署try...catch代码，那么执行generator函数的throw方法程序将报错直接中断所有代码执行。
* throw方法抛出的错误要被内部捕获，前提是必须至少执行过一次next方法（这样才启动执行了内部代码）。
* throw方法被generator内部try模块捕获进入catch会默认执行一次next，停在catch内部或后续代码中的yield处。
* generator 函数体内抛出的错误，可以被函数体外的catch捕获。

#### return()
generator 函数返回的遍历器对象，还有一个return方法，可以返回给定的值，并且终结遍历 generator 函数。

gen.return()示例
```
function* numbers () {
  yield 1;
  try {
    yield 2;
    yield 3;
  } finally {   //当外部使用numbers.return()方法时，会等待finally执行完成后再执行return。
    yield 4;
    yield 5;
  }
  yield 6;
}
var g = numbers();
g.next() // { value: 1, done: false }
g.next() // { value: 2, done: false }
g.return(7) // { value: 4, done: false }  //本次return因为内部有finally存在因此返回其内部的4。
g.next() // { value: 5, done: false }
g.next() // { value: 7, done: true }  //finally模块内执行完成后的下一次next直接是当时return的效果。
```

#### next(),throw(),return()的共同点
next()、throw()、return()这三个方法本质上是同一件事，可以放在一起理解。它们的作用都是让 Generator 函数恢复执行，并且使用不同的语句替换yield表达式。
* next()是将yield表达式替换成一个值。
* throw()是将yield表达式替换成一个throw语句(需要被内部try模块catch，否则寻求外部try模块)。
* return()是将yield表达式替换成一个return语句(函数终止效果，遇上finally需等待finally内部执行完毕再终止)。

### generator函数的this
Generator 函数总是返回一个遍历器，ES6 规定这个遍历器是 Generator 函数的实例，也继承了 Generator 函数的prototype对象上的方法。但如果把generator函数当作普通的构造函数，并不会生效，因为其返回的总是遍历器对象，而不是this对象。

generator函数的this使用示例
```
function* g() { 
  this.a = 1; 
  yield this.b = 2;  
  yield this.c = 3; 
}
g.prototype.hello = function () { return 'hi!';};
let obj = g();
obj instanceof g // true    //obj是g的实例，继承了g.prototype
obj.hello() // 'hi!'
obj.next();
obj.a     //undefined   //obj拿不到this对象的属性。
new g();  /// TypeError: g is not a constructor   //使用new来创建实例报错，g不是构造函数。
​
//generator函数用call方法绑定对象，指向函数内部的this对象。
let o = {};
let gen = g.call(o);
gen.next(); gen.next();   // value分别为2和3 与正常generator函数相同。
console.log("a:"+o.a+" b:"+o.b+" c:"+o.c);  // a:1 b:2 c:3  
//obj对象成为了g函数的实例，但与g函数执行返回遍历器对象gen是分离的。
​
//将generator函数用call方法绑定自身prototype对象。
let gg = g.call(g.prototype);
gg.next();gg.next();  //value分别为2和3 与正常generator函数相同。
console.log("a:"+gg.a+" b:"+gg.b+" c:"+gg.c); // a:1 b:2 c:3
​
//将g改造成构造函数，就可以执行new命令
function G(){
  return g.call(g.prototype);
}
```

### generator函数自动执行--针对异步操作（thunk、co）
generator函数解决了使用Promise时多个异步操作顺序执行代码冗余、语义模糊的问题，在多个异步操作顺序执行的表示上非常清晰。

generator函数最大的问题是如何在函数外部用next重新启动函数，手动执行在多个异步操作嵌套时异常繁琐，因此有thunk函数、co库可以自动执行generator函数。而简易版实现就是配合Promise实现自动执行。

#### thunk函数
thunk函数在JavaScript中是用于将多参数函数封装成只接受一个回调函数参数的单参数函数。

现有的thunkify模块就是实现这样的一个封装器。

thunkify模块使用示例及源码
```
let thunkify = require('thunkify'); //事先需要安装模块  npm install thunkify 。
let f = thunkify(fn);   //封装方法：将需要封装的带有回调函数参数的方法传入thunkify即可。
f(para1,para2...)(cb);  //使用方法：将回调函数作为第二次执行（第一次执行后返回函数）的参数，其余参数在第一次执行时传入。
​
//源码
var assert = require('assert');
function thunkify(fn){
  assert('function' == typeof fn, 'function required'); //判断fn是否为函数。
​
  return function(){
    var args = new Array(arguments.length); //根据返回的function执行时传入的参数个数创建数组。
    var ctx = this;     //保留上下文环境this。
​
    for(var i = 0; i < args.length; ++i) {  //传入参数赋值给数组args。
      args[i] = arguments[i];         
    }
​
    return function(done){    //返回函数，参数为回调函数。
      var called;             //标记，是否执行过回调函数。
​
      args.push(function(){   //将回调函数封装推入args参数数组，作为最后一个参数。
        if (called) return;   //封装回调函数主要是判断是否已执行过回调函数，执行过则直接return，推入args的相当于一个空函数。
        called = true;
        done.apply(null, arguments);  
      });
​
      try {
        fn.apply(ctx, args);
      } catch (err) {
        done(err);
      }
    }
  }
};
```

thunk函数简单来说就是将带有回调函数的方法的执行方式从f(a, b, c, callback)包装成f(a, b, c)(callback)。
thunk函数的作用本身并不显著，关键在于和generator函数结合在一起，使generator函数可以自动执行。

thunk函数与generator函数结合，自动执行（针对异步操作）
```
//针对同步操作的generator函数自动执行方法有几种，核心都是借助generator函数执行后返回的是一个遍历器，但这仅仅适合同步操作。
//thunk函数自动执行generator函数的核心点在于用递归的方式在回调函数中使用next重新启动generator函数。
var fs = require('fs');var thunkify = require('thunkify');
var readFileThunk = thunkify(fs.readFile);//将文件读取函数封装为thunk函数。
​
//generator函数示例，内部包含两次文件读取操作。
var gen = function* (){
    console.log("进入generator");
      //当run函数第二次执行gen.next(data)时，r1=data取到文件读取结果。
      //value= readFileThunk('test2.txt', 'utf8')，执行后返回thunk函数接收回调函数作为参数。
    var r1 = yield readFileThunk('test.txt', 'utf8');//test1-When you look long into an abyss, the abyss looks into you.
    console.log(r1);    
    var r2 = yield readFileThunk('test2.txt', 'utf8');//test2-When you look long into an abyss, the abyss looks into you.
    console.log(r2);
};
​
//配合thunk递归调用自动执行generator函数
function thunkGenerator(f){
    let fn=f();     //执行一次generator函数，得到遍历器。
    let time=0;     
    function next(err,data){  //thunk回调函数，因此要求generator函数中yield后跟着的必须是一个thunk函数（接收回调函数参数）。
        if(err)throw err;
        console.log("第"+(++time)+"次进入自定义next函数");
        let res=fn.next(data);  //执行next，定位到下一个yield，传入data使gen函数拿到文件读取结果。
        if (res.done) return;  //若done=true表明generator函数执行完毕，直接返回。
        res.value(next);      //result.value是一个接收回调函数作为参数的thunk函数，next作为回调函数传入，当文件读取成功后执行。
                              //此处真正执行读取文件操作，待读取成功后执行回调函数next。
    }
    next();
}
thunkGenerator(gen);//用thunkGenerator函数自动执行gen函数。
//第1次进入自定义next函数
//进入generator
//第2次进入自定义next函数
//test1-When you look long into an abyss, the abyss looks into you.
//第3次进入自定义next函数
//test2-When you look long into an abyss, the abyss looks into you.
```

thunk函数跟在yield后面，在thunk的回调函数中执行next重新启动generator函数，递归方式遍历generator。

#### co模块
co模块是结合promise对象来使generator函数自动执行。co(gen)执行后返回一个promise对象，用then方法添加最后的回调函数。

co模块使用示例
```
var fs = require('fs');var co = require("co");var readFileThunk = thunkify(fs.readFile);
var gen = function* (){
    console.log("进入generator");
    var r1 = yield readFileThunk('test.txt', 'utf8');//test1-When you look long into an abyss, the abyss looks into you.
    console.log(r1);
    var r2 = yield readFileThunk('test2.txt', 'utf8');//test2-When you look long into an abyss, the abyss looks into you.
    console.log(r2);
};
​
//使用co函数库自动执行generator函数
//co(gen);co函数返回的事一个promise对象，可以用then添加回调函数；
co(gen).then(()=>{
    console.log("generator函数执行完毕。");
})
//进入generator
//test1-When you look long into an abyss, the abyss looks into you.
//test2-When you look long into an abyss, the abyss looks into you.
//generator函数执行完毕。
​```

co模块源码中，自动执行generator函数的next函数
```
function next(ret) {
  if (ret.done) return resolve(ret.value); //判断generator函数是否执行完毕。
  var value = toPromise.call(ctx, ret.value); //将每一步返回的value都转为promise对象。
  if (value && isPromise(value)) return value.then(onFulfilled, onRejected);  //用then方法传入回调函数onFulfilled和onRejected，在两个函数内部继续调用next函数。
  return onRejected(new TypeError('You may only yield a function, promise, generator, array, or object, '
     + 'but the following object was passed: "' + String(ret.value) + '"'));  //参数不符合要求（函数、promise、generator、array、object以外）的情况下直接rejected，终止执行。
}
```

* 对比thunk函数与co模块中自动执行generator的next函数，核心逻辑都是在递归调用next，在回调函数里重启generator。
* 在自动执行generator上，相较于使用 thunk函数, 使用co模块能够接受的参数种类更多。
* co 支持并发的异步操作，即允许某些操作同时进行，等到它们全部完成，才进行下一步。只需把并发的操作都放在数组或对象里面，跟在yield语句后面。

--- 

## Async/await
async函数在generator函数的基础上进行了改进。

* 语义清晰。async表示异步，await表示等待。
* 自动执行。async函数执行后，自动逐步执行内部各个语句，在await处等待操作完成后自动继续往下执行。
* 返回值为Promise对象。可以执行async函数后使用then函数进行下一步操作。

async函数使用示例
```
//函数声明
async function f(){}
//表达式
let fn = async function (){};
//对象的方法
let obj = {async f(){}};  obj.f().then();
//Class的方法
Class Test(){
  async fn(){}
}
let test = new Test();  test.fn().then();
//箭头函数
let func = async () => {};
```

基本使用方法：
* async函数内部用await暂停函数，用法类似yield，但await会在后面跟着的异步操作执行完成后自动继续执行。
* await命令后面，可以是 Promise 对象和原始类型的值（数值、字符串和布尔值，但这时会自动转成立即 resolved 的 Promise 对象）。
* 返回的Promise对象的状态取决于async函数内部，return  aa，则promise对象状态为resolved，aa作为then函数参数；throw 错误则promise对象状态为rejected，错误作为参数传入catch函数or then函数的第二个参数函数。
* async函数绑定的then方法必须等到async内部的所有异步操作执行完才会被调用，即遇到有return or 错误抛出，若都没有的话，执行完最后的语句后async函数仍然返回一个状态为resolved的promise对象，但无任何数据传递。

await后面跟着的命令：
* 通常await后面跟着promise对象，返回该对象的结果，如果不是promise对象，就直接返回对应值，如 await 123，若想向async函数外传值则可以 return await 123，等同于return 123。
* 若await后面跟着的promise对象状态返回为rejected，则会中断整个async函数，并且返回rejected传递的参数（前面不需要return，因为等同于报错，会被外面的catch捕获），若rejected的promise对象被try...catch模块包含or promise对象本身带有catch方法，可以捕获到该rejected或者错误，进行一些处理，并继续执行async函数。
* await后面若跟着一个thenable对象（定义了then方法的对象），await也会将其视为promise对象处理，执行其then方法。
* 多个异步操作可以同时触发，可以使用Promise.all/race 或用同步语句分别执行异步操作，后续使用await分别等待异步操作的返回结果。
* await命令在async函数外会报错。
* async函数在遇到await时暂停执行（转而执行await后面带的命令），此时会保留上下文环境。

async函数是目前最集大成的JS异步操作方式，但回调函数、promise、generator同样适合许多应用场景。在实际环境中，根据不同的需求来选取不同的方法才是最合适的。 

--- 

## demo演示
<p class="codepen" data-height="465" data-theme-id="0" data-default-tab="js,result" data-user="linxiaowen0127" data-slug-hash="BaBYMvN" style="height: 465px; box-sizing: border-box; display: flex; align-items: center; justify-content: center; border: 2px solid; margin: 1em 0; padding: 1em;" data-pen-title="BaBYMvN">
  <span>See the Pen <a href="https://codepen.io/linxiaowen0127/pen/BaBYMvN/">
  BaBYMvN</a> by linxiaowen0127 (<a href="https://codepen.io/linxiaowen0127">@linxiaowen0127</a>)
  on <a href="https://codepen.io">CodePen</a>.</span>
</p>
<script async src="https://static.codepen.io/assets/embed/ei.js"></script>

--- 

## 总结
| 异步方式 | 优点 | 缺点 | 备注 |
| --- | --- | --- | --- |
| 1、回调函数 | 简单、逻辑上易理解、易实现 | 多个嵌套时：代码耦合高难以维护，程序结构混乱；流程难以追踪；错误捕获困难；|1-2个异步操作按顺序执行时，使用回调函数显得很便捷很简单，也不会造成难以维护的情况。多个异步操作时谢绝直接使用回调函数进行流程控制。回调函数是其他所有异步操作的基石。|
|2、事件监听 | 理解也较为容易；有效去耦合；多对多（事件与触发的函数），更灵活；|事件驱动型，流程不清晰；多对多也会造成事件的监听与触发混乱；|非常常用，最多的应该是点击事件触发。事件监听同样不建议用来控制大型/较复杂的流程运转。|
|3、发布订阅（事件监听升级版）|消息中心的存在让消息（事件）、订阅者（回调函数）更加清晰且更好掌控；|实现较为复杂（特别是包含取消订阅等功能时）则占用内存也多；大量使用时跟踪bug较为困难；|Vue也是基于发布-订阅（可能3+版会更改实现方式）。要实现较为完备的发布订阅相当复杂。少数异步操作不建议使用。感觉是系统级的而不是用来操控几个异步流程。|
|4、Promise|链式调用，流程清晰；|配套方法较完善；可串行可并行执行多个异步操作；一旦开始，无法取消；pending状态无法确认是刚开始还是即将结束；复杂情况时代码冗余、语义不清；|也非常常用，并且可以配合async达到自动按顺序执行效果。实际运用中例如HTTP请求会封装在promise里，更好的进行请求返回的下一步操作以及错误捕获处理。|
|5、Generator（生成遍历器对象）|将异步操作表达得像同步操作一样；语法简单，流程清晰，代码实现简洁；外部调用next可携带数据到内部；|手动迭代较麻烦（有thunk、co库可辅助）；yield语义不清；|generator返回遍历器对象的特性，让其拥有了进行异步操作流程控制以外的功能，例如可利用generator进行对象的属性遍历并进行一定的操作。甚至可以被视为一种数据结构。|
|6、Async（基于Promise，Gnerator升级版）|可自动执行流程（对于generator的next方法的改进）；语法简单，流程清晰，代码实现简洁；|多个异步操作若不存在依赖关系时，使用async降低性能；|await后面直接跟着回调函数不生效（例如await setTimout(500,()=>{...})，并不会等延迟操作结束后再继续往下），需将其封装为Promise。|


本文主要JS的几种异步语法进行介绍，对JS异步语法的发展过程及各API进行了学习举例，其中很多结论及代码例子来源于下列参考文献，总结不到位的地方还请大家批评指正。

## 参考链接

阮一峰ES6入门 http://es6.ruanyifeng.com/#docs/
详解前端异步编程的六种方案 https://www.infoq.cn/article/zwowtega7KjC4Ad-trp4
夯实基础-JavaScript异步编程 https://segmentfault.com/a/1190000014874668
co源码 https://github.com/tj/co
thunkify 源码 https://github.com/tj/node-thunkify
Javascript设计模式之发布-订阅模式 https://juejin.im/post/5a9108b6f265da4e7527b1a4
JS 异步编程六种方案 https://juejin.im/post/5c30375851882525ec200027