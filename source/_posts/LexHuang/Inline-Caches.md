title: 【译】用JavaScript解释JavaScript虚拟机-内联缓存（inline caches）
date: 2017-05-03 11:30:00
categories: LexHuang
tags: 
- JavaScript
- V8

---
```
本文来自Vyacheslav Egorov的[Explaining JavaScript VMs in JavaScript - Inline Caches](http://mrale.ph/blog/2012/06/03/explaining-js-vms-in-js-inline-caches.html)，其中的术语、代码请以原文为准。
```

我知道如何实现用语言（或者语言的子集）来实现运行该语言虚拟机。如果我在学校或者有更多的时间我肯定会用JavaScript实现一个JavaScript虚拟机。实际上这并不会变成一个独一无二的JavaScript项目，因为蒙特利尔大学的人所造的[Tachyon](https://github.com/Tachyon-Team/Tachyon/tree/master/source)已经在某种程度上达到了同样的目的，但是我也有些我自己想要追求的点子。

![](http://mrale.ph/s3/images/black-box.png)
我则有另一个和自循环虚拟机紧密相关的梦想。我想要帮助JavaScript开发者理解JS引擎的工作方式。我认为理解你正在使用的工具是我们职业生涯中最重要的。越多人不在把JS VM看作是将JavaScript源码转为0-1神秘的黑盒越好。

![](http://mrale.ph/s3/images/wr2012-assembly.png)
我应该说我不是一个人在追求如何解释虚拟机的内部机制并且帮助人们编写性能更好的代码。全世界有许多人正在尝试做同样的事情。但是我认为又一个问题正在阻止知识有效地被开发者所吸收——我们正在用错误的形式来传授我们的知识。我对此深感愧疚：

* 有事我将我对V8的了解包装成了很难消化的"做这个，别做那个"的教条化意见。这样的问题在于它对于解释起不到任何帮助并且很容易随着关注人的减少而消失。
* 有时候我们用了错误的抽象层次来解释虚拟机的工作机制。我喜欢一个想法：看见满是汇编代码的ppt演示可能会鼓励人们去学习汇编并且学会之后会去读ppt演示的内容。但我也害怕有时候这些ppt只会被人忽视和遗忘而对于实践毫无用处。

我一直在思考这些问题很长时间了并且我认为用JavaScript来解释JavaScript虚拟机是一个值得尝试的事情。我在WebRebels 2012发表的演讲"V8 Inside Out"追求的正是这一点[[视频](http://vimeo.com/43334972)][[演示](http://mrale.ph/s3/webrebels2012.pdf)]并且在本文中我像回顾我一直在奥斯陆所谈论的事情但是不同的是不会有任何音频的干扰。（我认为我写作的方式比我演讲的方式更加严肃些 ☺）。

## 用JavaScript来实现动态语言

想象你想要为了一个在语法上非常类似于JavaScript但是有着更简单的对象模型的语言——用表来映射key到任意类型的值来代替JavaScript对象——而来用JavaScript实现其虚拟机。简单起见，让我们想象Lua， 既像JavaScript但作为一个语言又很不一样。我最喜欢的"造出一个充满点的数组然后去计算向量合"的例子看起来大致如下：

```lua
function MakePoint(x, y)
  local point = {}
  point.x = x
  point.y = y
  return point
end

function MakeArrayOfPoints(N)
  local array = {}
  local m = -1
  for i = 0, N do
    m = m * -1
    array[i] = MakePoint(m * i, m * -i)
  end
  array.n = N
  return array
end

function SumArrayOfPoints(array)
  local sum = MakePoint(0, 0)
  for i = 0, array.n do
    sum.x = sum.x + array[i].x
    sum.y = sum.y + array[i].y
  end
  return sum
end

function CheckResult(sum)
  local x = sum.x
  local y = sum.y
  if x ~= 50000 or y ~= -50000 then
    error("failed: x = " .. x .. ", y = " .. y)
  end
end

local N = 100000
local array = MakeArrayOfPoints(N)
local start_ms = os.clock() * 1000;
for i = 0, 5 do
  local sum = SumArrayOfPoints(array)
  CheckResult(sum)
end
local end_ms = os.clock() * 1000;
print(end_ms - start_ms)
```

注意我有一个至少检查某些最终结果的微型基准测试的习惯。这有助于当有人发现我的革命性的jsperf测试用例只不过是我自己的bug时，让我不会太尴尬。

如果你拿上面的例子放入一个Lua编译器你会得到类似于下面的东西：

```
∮ lua points.lua
150.2
```

很好，但是对于了解虚拟机的工作过程起不到任何帮助。所以让我们想想如果我们有用JavaScript编写的类Lua虚拟机会长什么样。“类”是因为我不想实现完全类似于Lua的语法，我更喜欢只关注于用表来实现对象这一点上。原生编译器应该会将我们的代码编译成下面的JavaScript：

```javascript
function MakePoint(x, y) {
  var point = new Table();
  STORE(point, 'x', x);
  STORE(point, 'y', y);
  return point;
}

function MakeArrayOfPoints(N) {
  var array = new Table();
  var m = -1;
  for (var i = 0; i <= N; i++) {
    m = m * -1;
    STORE(array, i, MakePoint(m * i, m * -i));
  }
  STORE(array, 'n', N);
  return array;
}

function SumArrayOfPoints(array) {
  var sum = MakePoint(0, 0);
  for (var i = 0; i <= LOAD(array, 'n'); i++) {
    STORE(sum, 'x', LOAD(sum, 'x') + LOAD(LOAD(array, i), 'x'));
    STORE(sum, 'y', LOAD(sum, 'y') + LOAD(LOAD(array, i), 'y'));
  }
  return sum;
}

function CheckResult(sum) {
  var x = LOAD(sum, 'x');
  var y = LOAD(sum, 'y');
  if (x !== 50000 || y !== -50000) {
    throw new Error("failed: x = " + x + ", y = " + y);
  }
}

var N = 100000;
var array = MakeArrayOfPoints(N);
var start = LOAD(os, 'clock')() * 1000;
for (var i = 0; i <= 5; i++) {
  var sum = SumArrayOfPoints(array);
  CheckResult(sum);
}
var end = LOAD(os, 'clock')() * 1000;
print(end - start);
```

但是如果你尝试用d8（V8的独立shell）去运行编译后的代码，它会很礼貌的拒绝：

```
∮ d8 points.js
points.js:9: ReferenceError: Table is not defined
  var array = new Table();
                  ^
ReferenceError: Table is not defined
    at MakeArrayOfPoints (points.js:9:19)
    at points.js:37:13
```

失败的原因很简单：我们还缺少负责实现对象模型和存取语法的运行时系统代码。这可能看起来很明显，但是我想要强调的是：虚拟机从外面看起来像是黑盒，在内部实际上是一系列盒子为了得到出最佳性能的相互协作。这些盒子是：编译器、运行时例程、对象模型、垃圾回收等。幸运的是我们的语言和例子非常简单所以我们的运行时系统仅仅多了几行代码：

```javascript
function Table() {
  // Map from ES Harmony is a simple dictionary-style collection.
  this.map = new Map;
}

Table.prototype = {
  load: function (key) { return this.map.get(key); },
  store: function (key, value) { this.map.set(key, value); }
};

function CHECK_TABLE(t) {
  if (!(t instanceof Table)) {
    throw new Error("table expected");
  }
}

function LOAD(t, k) {
  CHECK_TABLE(t);
  return t.load(k);
}

function STORE(t, k, v) {
  CHECK_TABLE(t);
  t.store(k, v);
}

var os = new Table();

STORE(os, 'clock', function () {
  return Date.now() / 1000;
});
```

注意到我用了[ES6的Map](http://wiki.ecmascript.org/doku.php?id=harmony:simple_maps_and_sets)而不是一般的JavaScript对象因为潜在的表可以使用任何键，而不仅是字符串形式的。

```
∮ d8 --harmony quasi-lua-runtime.js points.js
737
```

![](http://mrale.ph/s3/images/wr2012-lookup.png)
现在我们编译后的代码可以执行但是却慢地令人失望，因为每一次读和写不得不跨越所有这些抽象层级后才能拿到值。让我们通过所有JavaScript虚拟机都有的最基本的优化inline caching来尝试减少这些开销。即使是用Java实现的JS虚拟机最终也会使用它因为动态调用的本质是被暴露在字节码层面的结构化的內联缓存。Inline caching（在V8资源里通常简写为IC）实际上是一门近30年的非常古老的技术，最初用在Smalltalk虚拟机上。

## 好鸭子总是叫得一模一样

内联缓存（Inline caching）背后的思想非常简单：创建一个高速路来绕过运行时系统来读取对象的属性:对传入的对象及其属性作出某种假设，然后通过一个低成本的方式验证这个假设是否正确，如果正确就读取上次缓存的结果。在充满了动态类型和晚绑定以及其他古怪行为——比如eval——的语言里对一个对象作出合理的假设是非常困难的，所以我们退而求其次，让我们的读／写操作能够有学习能力：一旦它们看见某个对象它们就可以以某种方式来自适应，使得之后的读取操作在遇到类似结构的对象时能够更快地进行。在某种意义上，我们将要在读／写操作上缓存关于之前见过的对象的布局的相关知识——这也是内联缓存这个名字的由来。内联缓存可以被用在几乎所有需要动态行为的操作上，只要你可以找到正确的高速路：算数操作、调用自由函数、方法调用等等。有些内联缓存还能缓存不止一条快速通道，这些内联缓存就变成了多态的。
![](http://mrale.ph/s3/images/wr2012-lookup-ic.png)

如果我们开始思考如何应用内联缓存到上面编译后的代码，答案就变得显而易见了：我们需要改变我们的对象模型。我们不可能从一个map中进行快速读取，因为我们总是要调用get方法。[如果我们能够窥探map后的纯哈希表，我们就可以通过缓存桶索引来让内联缓存替我们工作而不需要相处一个新的对象布局。]

## 探索隐藏结构
![](http://mrale.ph/s3/images/wr2012-hidden-classes.png)
处于效率角度考虑，用作数据结构的表应该更类似于C结构：带有固定偏移量的命名字段序列。这样表就和数组类似：我们希望数字形式的属性的存储类似于数组。但是很显然并不是所有表的键都是数字：键可以被设计成非字符串非数字或者包含太多字符串命名的属性，并且随着表的修改键也会随之修改。不幸的是，我们不能做任何昂贵的类型推断。取而代之我们必须找在程序运行期间的每一个表背后的结构，并且随着程序的运行可以创建和修改它们。幸运的是，有一个众所周知的技术 ☺：隐藏类（hidden classes）。

隐藏类背后的思想可以归结为以下两点：

1. 对于每个javascript对象，运行时系统都会将其合一个hidden class关联起来。就像Java VM会关联一个java.lang.Class的实例给每个对象一样。
2. 如果对象的布局改变了，则运行时就会 找到一个hidden class或者创建一个新的hidden class来匹配这个新对象布局并且连接到该对象上。

隐藏类有个非常重要的特性：它们运行虚拟机通过简单比对缓存过的隐藏类来检查关于某个对象布局的假设。这正是我们的内联缓存功能所需要的。让我们为我们的类-Lua运行时来实现一些简单的隐藏类系统。每个隐藏类本质上是属性描述符的集合，每个描述符要么是一个真正的属性，要么是一个过渡（transition）：从一个没有该属性的类指向一个有该属性的类。

```javascript
function Transition(klass) {
  this.klass = klass;
}

function Property(index) {
  this.index = index;
}

function Klass(kind) {
  // Classes are "fast" if they are C-struct like and "slow" is they are Map-like.
  this.kind = kind;
  this.descriptors = new Map;
  this.keys = [];
}
```

过渡之所以存在是为了让多个对象之间能共享隐藏类：如果你有两个对象共享了隐藏类并且你为它们同时增加了某些属性，你不希望得到不同的隐藏类。

```javascript
Klass.prototype = {
  // Create hidden class with a new property that does not exist on
  // the current hidden class.
  addProperty: function (key) {
    var klass = this.clone();
    klass.append(key);
    // Connect hidden classes with transition to enable sharing:
    //           this == add property key ==> klass
    this.descriptors.set(key, new Transition(klass));
    return klass;
  },

  hasProperty: function (key) {
    return this.descriptors.has(key);
  },

  getDescriptor: function (key) {
    return this.descriptors.get(key);
  },

  getIndex: function (key) {
    return this.getDescriptor(key).index;
  },

  // Create clone of this hidden class that has same properties
  // at same offsets (but does not have any transitions).
  clone: function () {
    var klass = new Klass(this.kind);
    klass.keys = this.keys.slice(0);
    for (var i = 0; i < this.keys.length; i++) {
      var key = this.keys[i];
      klass.descriptors.set(key, this.descriptors.get(key));
    }
    return klass;
  },

  // Add real property to descriptors.
  append: function (key) {
    this.keys.push(key);
    this.descriptors.set(key, new Property(this.keys.length - 1));
  }
};
```

现在我们可以让我们的表更佳灵活并且能允许它们适应其的构造过程

```javascript
var ROOT_KLASS = new Klass("fast");

function Table() {
  // All tables start from the fast empty root hidden class and form 
  // a single tree. In V8 hidden classes actually form a forest - 
  // there are multiple root classes, e.g. one for each constructor. 
  // This is partially due to the fact that hidden classes in V8 
  // encapsulate constructor specific information, e.g. prototype 
  // poiinter is actually stored in the hidden class and not in the 
  // object itself so classes with different prototypes must have 
  // different hidden classes even if they have the same structure.
  // However having multiple root classes also allows to evolve these
  // trees separately capturing class specific evolution independently.
  this.klass = ROOT_KLASS;
  this.properties = [];  // Array of named properties: 'x','y',...
  this.elements = [];  // Array of indexed properties: 0, 1, ...
  // We will actually cheat a little bit and allow any int32 to go here,
  // we will also allow V8 to select appropriate representation for
  // the array's backing store. There are too many details to cover in
  // a single blog post :-)
}

Table.prototype = {
  load: function (key) {
    if (this.klass.kind === "slow") {
      // Slow class => properties are represented as Map.
      return this.properties.get(key);
    }

    // This is fast table with indexed and named properties only.
    if (typeof key === "number" && (key | 0) === key) {  // Indexed property.
      return this.elements[key];
    } else if (typeof key === "string") {  // Named property.
      var idx = this.findPropertyForRead(key);
      return (idx >= 0) ? this.properties[idx] : void 0;
    }

    // There can be only string&number keys on fast table.
    return void 0;
  },

  store: function (key, value) {
    if (this.klass.kind === "slow") {
      // Slow class => properties are represented as Map.
      this.properties.set(key, value);
      return;
    }

    // This is fast table with indexed and named properties only.
    if (typeof key === "number" && (key | 0) === key) {  // Indexed property.
      this.elements[key] = value;
      return;
    } else if (typeof key === "string") {  // Named property.
      var index = this.findPropertyForWrite(key);
      if (index >= 0) {
        this.properties[index] = value;
        return;
      }
    }

    this.convertToSlow();
    this.store(key, value);
  },

  // Find property or add one if possible, returns property index
  // or -1 if we have too many properties and should switch to slow.
  findPropertyForWrite: function (key) {
    if (!this.klass.hasProperty(key)) {  // Try adding property if it does not exist.
      // To many properties! Achtung! Fast case kaput.
      if (this.klass.keys.length > 20) return -1;

      // Switch class to the one that has this property.
      this.klass = this.klass.addProperty(key);
      return this.klass.getIndex(key);
    }

    var desc = this.klass.getDescriptor(key);
    if (desc instanceof Transition) {
      // Property does not exist yet but we have a transition to the class that has it.
      this.klass = desc.klass;
      return this.klass.getIndex(key);
    }

    // Get index of existing property.
    return desc.index;
  },

  // Find property index if property exists, return -1 otherwise.
  findPropertyForRead: function (key) {
    if (!this.klass.hasProperty(key)) return -1;
    var desc = this.klass.getDescriptor(key);
    if (!(desc instanceof Property)) return -1;  // Here we are not interested in transitions.
    return desc.index;
  },

  // Copy all properties into the Map and switch to slow class.
  convertToSlow: function () {
    var map = new Map;
    for (var i = 0; i < this.klass.keys.length; i++) {
      var key = this.klass.keys[i];
      var val = this.properties[i];
      map.set(key, val);
    }

    Object.keys(this.elements).forEach(function (key) {
      var val = this.elements[key];
      map.set(key | 0, val);  // Funky JS, force key back to int32.
    }, this);

    this.properties = map;
    this.elements = null;
    this.klass = new Klass("slow");
  }
};
```

> [我不打算一行一行地解释上面的代码，因为它已经是用JavaScript书写的了；而不是C++ 或者 汇编...这正是使用JavaScript的意义所在。然而你可以通过评论或者邮件来询问任何不理解的地方。]

既然我们已经在运行时系统里加入了隐藏类，使得我们能够快速检查对象的结构并且通过它们的索引来快速读取属性，我们只差实现内联缓存了。这需要在编译器和运行时系统增加一些新的功能（还记得我谈论过虚拟机内不同成员之间的协作么？）。

## 打包生成后代码

实现内联缓存的途径之一是将其分割成两个部分：生成代码里的可变调用点和可以被调用点调用的一系列存根（stubs，一小片生成的本地代码）。非常重要的一点是：存根本身必须能从调用它们的调用点（或者运行时系统）中找到：存根只存放特定假设下的编译后的快速路径，如果这些假设对存根遇到的对象不适用，则存根可以初始化调用该存根的调用点的变动（打包，patching），使得该调用点能够适应新的情况。我们的纯JavaScript仍然包含两个部分：

1. 一个全局变量，每个ic都会使用一个全局变量来模拟可变调用指令;
2. 并使用闭包来代替存根。
![](http://mrale.ph/s3/images/wr2012-inline-cache.png)

在本地代码里， V8通过在栈上监听返回地址来找到要打包的内联缓存点。我们不能通过纯JavaScript来达到这一点（arguments.caller的粒度不够细）。所以我们将只会显式地传递内联缓存的id到内联缓存的存根。通过内联缓存优化后的代码如下：

```javascript
// Initially all ICs are in uninitialized state.
// They are not hitting the cache and always missing into runtime system.
var STORE$0 = NAMED_STORE_MISS;
var STORE$1 = NAMED_STORE_MISS;
var KEYED_STORE$2 = KEYED_STORE_MISS;
var STORE$3 = NAMED_STORE_MISS;
var LOAD$4 = NAMED_LOAD_MISS;
var STORE$5 = NAMED_STORE_MISS;
var LOAD$6 = NAMED_LOAD_MISS;
var LOAD$7 = NAMED_LOAD_MISS;
var KEYED_LOAD$8 = KEYED_LOAD_MISS;
var STORE$9 = NAMED_STORE_MISS;
var LOAD$10 = NAMED_LOAD_MISS;
var LOAD$11 = NAMED_LOAD_MISS;
var KEYED_LOAD$12 = KEYED_LOAD_MISS;
var LOAD$13 = NAMED_LOAD_MISS;
var LOAD$14 = NAMED_LOAD_MISS;

function MakePoint(x, y) {
  var point = new Table();
  STORE$0(point, 'x', x, 0);  // The last number is IC's id: STORE$0 &rArr; id is 0
  STORE$1(point, 'y', y, 1);
  return point;
}

function MakeArrayOfPoints(N) {
  var array = new Table();
  var m = -1;
  for (var i = 0; i <= N; i++) {
    m = m * -1;
    // Now we are also distinguishing between expressions x[p] and x.p.
    // The fist one is called keyed load/store and the second one is called
    // named load/store.
    // The main difference is that named load/stores use a fixed known
    // constant string key and thus can be specialized for a fixed property
    // offset.
    KEYED_STORE$2(array, i, MakePoint(m * i, m * -i), 2);
  }
  STORE$3(array, 'n', N, 3);
  return array;
}

function SumArrayOfPoints(array) {
  var sum = MakePoint(0, 0);
  for (var i = 0; i <= LOAD$4(array, 'n', 4); i++) {
    STORE$5(sum, 'x', LOAD$6(sum, 'x', 6) + LOAD$7(KEYED_LOAD$8(array, i, 8), 'x', 7), 5);
    STORE$9(sum, 'y', LOAD$10(sum, 'y', 10) + LOAD$11(KEYED_LOAD$12(array, i, 12), 'y', 11), 9);
  }
  return sum;
}

function CheckResults(sum) {
  var x = LOAD$13(sum, 'x', 13);
  var y = LOAD$14(sum, 'y', 14);
  if (x !== 50000 || y !== -50000) throw new Error("failed x: " + x + ", y:" + y);
}
```

上述的改变依旧是不言自明的：每一个属性的读/写点都有属于它们自己的、带有id的内联缓存。距离最终完成还剩一小步：实现未命中（MISS）存根和可以生存特定存根的存根"编译器"：

```javascript
function NAMED_LOAD_MISS(t, k, ic) {
  var v = LOAD(t, k);
  if (t.klass.kind === "fast") {
    // Create a load stub that is specialized for a fixed class and key k and
    // loads property from a fixed offset.
    var stub = CompileNamedLoadFastProperty(t.klass, k);
    PatchIC("LOAD", ic, stub);
  }
  return v;
}

function NAMED_STORE_MISS(t, k, v, ic) {
  var klass_before = t.klass;
  STORE(t, k, v);
  var klass_after = t.klass;
  if (klass_before.kind === "fast" &&
      klass_after.kind === "fast") {
    // Create a store stub that is specialized for a fixed transition between classes
    // and a fixed key k that stores property into a fixed offset and replaces
    // object's hidden class if necessary.
    var stub = CompileNamedStoreFastProperty(klass_before, klass_after, k);
    PatchIC("STORE", ic, stub);
  }
}

function KEYED_LOAD_MISS(t, k, ic) {
  var v = LOAD(t, k);
  if (t.klass.kind === "fast" && (typeof k === 'number' && (k | 0) === k)) {
    // Create a stub for the fast load from the elements array.
    // Does not actually depend on the class but could if we had more complicated
    // storage system.
    var stub = CompileKeyedLoadFastElement();
    PatchIC("KEYED_LOAD", ic, stub);
  }
  return v;
}

function KEYED_STORE_MISS(t, k, v, ic) {
  STORE(t, k, v);
  if (t.klass.kind === "fast" && (typeof k === 'number' && (k | 0) === k)) {
    // Create a stub for the fast store into the elements array.
    // Does not actually depend on the class but could if we had more complicated
    // storage system.
    var stub = CompileKeyedStoreFastElement();
    PatchIC("KEYED_STORE", ic, stub);
  }
}

function PatchIC(kind, id, stub) {
  this[kind + "$" + id] = stub;  // non-strict JS funkiness: this is global object.
}

function CompileNamedLoadFastProperty(klass, key) {
  // Key is known to be constant (named load). Specialize index.
  var index = klass.getIndex(key);

  function KeyedLoadFastProperty(t, k, ic) {
    if (t.klass !== klass) {
      // Expected klass does not match. Can't use cached index.
      // Fall through to the runtime system.
      return NAMED_LOAD_MISS(t, k, ic);
    }
    return t.properties[index];  // Veni. Vidi. Vici.
  }

  return KeyedLoadFastProperty;
}

function CompileNamedStoreFastProperty(klass_before, klass_after, key) {
  // Key is known to be constant (named load). Specialize index.
  var index = klass_after.getIndex(key);

  if (klass_before !== klass_after) {
    // Transition happens during the store.
    // Compile stub that updates hidden class.
    return function (t, k, v, ic) {
      if (t.klass !== klass_before) {
        // Expected klass does not match. Can't use cached index.
        // Fall through to the runtime system.
        return NAMED_STORE_MISS(t, k, v, ic);
      }
      t.properties[index] = v;  // Fast store.
      t.klass = klass_after;  // T-t-t-transition!
    }
  } else {
    // Write to an existing property. No transition.
    return function (t, k, v, ic) {
      if (t.klass !== klass_before) {
        // Expected klass does not match. Can't use cached index.
        // Fall through to the runtime system.
        return NAMED_STORE_MISS(t, k, v, ic);
      }
      t.properties[index] = v;  // Fast store.
    }
  }
}


function CompileKeyedLoadFastElement() {
  function KeyedLoadFastElement(t, k, ic) {
    if (t.klass.kind !== "fast" || !(typeof k === 'number' && (k | 0) === k)) {
      // If table is slow or key is not a number we can't use fast-path.
      // Fall through to the runtime system, it can handle everything.
      return KEYED_LOAD_MISS(t, k, ic);
    }
    return t.elements[k];
  }

  return KeyedLoadFastElement;
}

function CompileKeyedStoreFastElement() {
  function KeyedStoreFastElement(t, k, v, ic) {
    if (t.klass.kind !== "fast" || !(typeof k === 'number' && (k | 0) === k)) {
      // If table is slow or key is not a number we can't use fast-path.
      // Fall through to the runtime system, it can handle everything.
      return KEYED_STORE_MISS(t, k, v, ic);
    }
    t.elements[k] = v;
  }

  return KeyedStoreFastElement;
}
```

代码很长（以及注释），但是配合上面所有解释应该不难理解：内联缓存负责观察而存根编译器／工程负责生产自适应和特化后的存根[有心的读者可能注意到了我本可以初始化所有键控的存储内联缓存（keyed store ICs），用一开始的快速读取或者当它进入快速状态后就一直保持住]。

如果我们不管上面所有代码而回到我们的"基准测试",我们会得到非常令人满意的结果：

```
∮ d8 --harmony quasi-lua-runtime-ic.js points-ic.js
117
```

这要比我们一开始的天真尝试提升了6倍! 

## 关于JavaScript虚拟机优化永远也不会有结论

希望你在阅读这一部分的时候已经看完了之前所有内容...我尝试从不同的角度，JavaScript开发者的角度，来看某些驱动当今JavaScript引擎的点子。所写的代码越长，我越有一种盲人摸象的感觉。下面的事实只是为了给你一种望向深渊的感觉：V8有10种描述符，5种元素类型（+9外部元素类型），ic.cc里包含了几乎所有内联缓存状态选择的逻辑多达2500行，并且V8的内联缓存的状态不止2个（它们是uninitialized, premonomorphic, monomorphic, polymorphic, generic states，更别提用于键控读／写的内联缓存的特殊的状态或者是算数内敛缓存的完全不同的状态层级），ia32-specific手写的内联缓存存根多达5000行代码，等等。这些数字只会随着时间的流逝和V8为了识别和适应越来越多的对象布局的学习而增长。而且我甚至都还没谈到对象模型本身（objects.cc 13k行代码），或者垃圾回收，或者优化编译器。

话虽如此，在可预见的未来內，我确信基础将不会改变，如果变了肯定会引发一场你一定会注意到的巨大的爆炸！因此我认为这次尝试用JavaScript去理解基础的练习是非常非常非常重要的。

我希望明天或者几周之后你会停下来并且大喊"我找到了"！并且告诉你的同时为什么特定情况下在一个地方为一个对象增加属性会影响其余很远的接触这些对象的热回路的性能。你知道的，因为隐藏类变了！

