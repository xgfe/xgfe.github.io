
title: angularjs的双向数据绑定               
date: 2018-08-15 21:00:00                   
categories: yangxiaotong                                                     
tags:                                      
- angularjs
---
angularjs的双向数据绑定原理及简单的实现。

<!--more-->
之前对vue.js的双向绑定比较感兴趣，自己动手实现了一个类似于vue.js的mvvm框架。vue.js 采用数据劫持结合发布者-订阅者模式的方式，通过Object.defineProperty()来劫持各个属性的setter，getter，在数据变动时发布消息给订阅者，触发相应的监听回调。其核心代码：

```
	this.watch = function(obj, callback) {
		this.$observeObj = function() {
			var that = this;
			this.callback = callback;
			//console.log(Object.keys(obj));
			Object.keys(obj).forEach(function(prop) {
				var val = obj[prop];
				Object.defineProperty(obj, prop, {
					get: function() {
						return val;
					},
					set: function(newVal) {
						var temp = val;
						//console.log(newVal);
						val = newVal;
						//通知所有订阅者改变
						
						that.cache.forEach(function(item) {
							if (item[prop]) {
								item[prop] = newVal;
							}
						});
						that.callback();
					},    
					enumerable: true,
    				configurable: true
				});
			});
		}

		this.$observeObj();
	};
```

`set`属性在改变数据的同时触发视图的更新。

angularjs实现数据双向绑定与vue.js有所不同，它依赖于脏值检测，这里我写了一个简易的版本，其主要代码：


```
initWatch() {  
    for (let i = 0, len = this.elements.length; i < len; i++) {
        //用来保证初值的正常加载，以及当我改变input框中的值为空时能正常显示
        this.flags.push(false);
        this.watch(() => {
            let value = this.elements[i].value;
            return value;
        }, (newVal, oldVal) => {
            let key = this.elements[i].getAttribute('ng-model');
            const elementType = this.elements[i].tagName.toLowerCase();

            this.data[key] = this.flags[i] ? newVal : this.data[key];
            //设置属性值
            if (elementType === 'input' || elementType === 'textarea' || elementType === 'select') {
                this.elements[i].value = this.flags[i] ? newVal : this.data[key];
            } else {
                this.elements[i].innerHTML = this.flags[i] ? newVal : this.data[key];
            }

            for (let j = 0, len = this.bind.length; j < len; j++) {
                let item = this.bind[i].getAttribute('ng-bind');
                if (item === key) {
                    this.bind[i].innerHTML = this.flags[i] ? newVal : this.data[key];
                }
            }
        });
    }

    document.addEventListener('keyup', () => {
        this.digest();
    }, false);
    document.addEventListener('change', () => {
        this.digest();
    }, false);
}

//监听函数
watch(watchFn, callback) {
    this.watchers.push({
        watchFn: watchFn,
        callback: callback || function() {}
    });
}

//更新数据
digest() {
    let dirty;
    do {
        dirty = false;

    for (let i = 0, len = this.watchers.length; i < len; i++) {
        let newVal = this.watchers[i].watchFn();
        let oldVal = this.watchers[i].last;

        if (newVal !== oldVal) {
            this.watchers[i].callback(newVal, oldVal);
            dirty = true;
            this.watchers[i].last = newVal;
            this.flags[i] = true;
        }
    }

} while(dirty);
 
```

`watch`接受两个参数（这里只考虑了单值的情况，用`ng-bind`来绑定值），监听的数据与监听的回调函数。digest函数只会在指定事件触发后，才执行，比如这里input框	,改变输入的值会触发keyup事件，调用`digest`函数，这个函数会遍历所有的`watchers`，对比以前的值和新值是否一样，如果不一样就执行回调函数更新数据和视图。  
我自己实现的版本很基础也很片面，我们可以看看angularjs源码对这部分的描述（这里看angularjs 1.3.20版本）：

### $parse

`parse`是一个解析函数，angularjs中单独在一个名叫parse.js的文件中。我们从`$get`方法出发，它最后会返回一个`$parse`函数，这个函数的核心部分：

```
var lexer = new Lexer(parseOptions);
var parser = new Parser(lexer, $filter, parseOptions);
parsedExpression = parser.parse(exp);
```

其中，`Lexer`这个构造函数中的`lex`方法用于解析传入数据的所有特殊情况，比如当我检测到这个监控数据为带有引号的字符串时（检查到第一个字符为单引号或者双引号），readString方法就会继续解析后面的字符，最后将结果存到this.tokens中，同理，当检测到是number类型的便会执行readNumber方法，将结果存在this.tokens中。`parse`就是处理`lexer`实例返回的this.tokens值，生成执行表达式，其实就是返回一个执行函数。因为这个函数中对四则运算也做了处理，所以当输入1+2的表达式时，最终会返回结果3。  

### $watch

```
$watch: function(watchExp, listener, objectEquality) {
    var get = $parse(watchExp);

    if (get.$$watchDelegate) {
      return get.$$watchDelegate(this, listener, objectEquality, get);
    }
    var scope = this,
        array = scope.$$watchers,
        watcher = {
          fn: listener,
          last: initWatchVal,
          get: get,
          exp: watchExp,
          eq: !!objectEquality
        };

    lastDirtyWatch = null;

    if (!isFunction(listener)) {
      watcher.fn = noop;
    }

    if (!array) {
      array = scope.$$watchers = [];
    }
    // we use unshift since we use a while loop in $digest for speed.
    // the while loop reads in reverse order.
    array.unshift(watcher);

    return function deregisterWatch() {
      arrayRemove(array, watcher);
      lastDirtyWatch = null;
    };
  }
```

`$watch`主要接收三个参数:监听的数据，监听的回调函数，是否深度监听。  
- watch参数：  
- fn：监听函数，当新旧值不想等的时候会执行  
- last：存放旧值  
- get：保存监控表达式对应的函数，主要用来获取表达式的值做新旧值的对比  
- exp：原始监控表达式  
- eq：是否深度比较，存储的是`$watch`的第三个参数  

当需要监听数据的时候，`get.$$watchDelegate`是否存在取决于`parse`中的parsedExpression.constant的值，而它的值取决于`$watch`监听的数据是否为常量，如果是常量的话，这个监听函数只会执行一次，不会被push进`$$watchers`的队列中，如果监听的是变量，那么这个`watch`会被push到`$$watchers`队列的最前面。最后会返回一个函数，这个函数的功能就是删除当前的`watch`，所以如果我们想取消这个监听，可以用一个变量接收`$watch`的返回值，再执行这个函数就达到了效果。

### $evalAsync
```
$evalAsync: function(expr, locals) {
	// if we are outside of an $digest loop and this is the first time we are scheduling async
	// task also schedule async auto-flush
	if (!$rootScope.$$phase && !asyncQueue.length) {
	  $browser.defer(function() {
	    if (asyncQueue.length) {
	      $rootScope.$digest();
	    }
	  });
	}
	
	asyncQueue.push({scope: this, expression: expr, locals: locals});
},
```

`$evalAsync`函数的作用是延迟执行表达式，`$$asyncQueue`是一个异步的队列，保存着所有需要异步执行的表达式。`$bowser.defer`是用setTimeout来实现的。

  
### $digest
```
 $digest: function() {
        var watch, value, last,
            watchers,
            length,
            dirty, ttl = TTL,
            next, current, target = this,
            watchLog = [],
            logIdx, logMsg, asyncTask;

        beginPhase('$digest');
        // Check for changes to browser url that happened in sync before the call to $digest
        $browser.$$checkUrlChange();

        if (this === $rootScope && applyAsyncId !== null) {
          // If this is the root scope, and $applyAsync has scheduled a deferred $apply(), then
          // cancel the scheduled $apply and flush the queue of expressions to be evaluated.
          $browser.defer.cancel(applyAsyncId);
          flushApplyAsync();
        }

        lastDirtyWatch = null;

        do { // "while dirty" loop
          dirty = false;
          current = target;

          while (asyncQueue.length) {
            try {
              asyncTask = asyncQueue.shift();
              asyncTask.scope.$eval(asyncTask.expression, asyncTask.locals);
            } catch (e) {
              $exceptionHandler(e);
            }
            lastDirtyWatch = null;
          }

          traverseScopesLoop:
           do { // "traverse the scopes" loop
            if ((watchers = current.$$watchers)) {
              // process our watches
              length = watchers.length;
              while (length--) {
                try {
                  watch = watchers[length];
                  // Most common watches are on primitives, in which case we can short
                  // circuit it with === operator, only when === fails do we use .equals
                  if (watch) {
                    if ((value = watch.get(current)) !== (last = watch.last) &&
                        !(watch.eq
                            ? equals(value, last)
                            : (typeof value === 'number' && typeof last === 'number'
                               && isNaN(value) && isNaN(last)))) {
                      dirty = true;
                      lastDirtyWatch = watch;
                      watch.last = watch.eq ? copy(value, null) : value;
                      watch.fn(value, ((last === initWatchVal) ? value : last), current);
                      if (ttl < 5) {
                        logIdx = 4 - ttl;
                        if (!watchLog[logIdx]) watchLog[logIdx] = [];
                        watchLog[logIdx].push({
                          msg: isFunction(watch.exp) ? 'fn: ' + (watch.exp.name || watch.exp.toString()) : watch.exp,
                          newVal: value,
                          oldVal: last
                        });
                      }
                    } else if (watch === lastDirtyWatch) {
                      // If the most recently dirty watcher is now clean, short circuit since the remaining watchers
                      // have already been tested.
                      dirty = false;
                      break traverseScopesLoop;
                    }
                  }
                } catch (e) {
                  $exceptionHandler(e);
                }
              }
            }
            
             // Insanity Warning: scope depth-first traversal
            // yes, this code is a bit crazy, but it works and we have tests to prove it!
            // this piece should be kept in sync with the traversal in $broadcast
            if (!(next = (current.$$childHead ||
                (current !== target && current.$$nextSibling)))) {
              while (current !== target && !(next = current.$$nextSibling)) {
                current = current.$parent;
              }
            }
          } while ((current = next));

          // `break traverseScopesLoop;` takes us to here

          if ((dirty || asyncQueue.length) && !(ttl--)) {
            clearPhase();
            throw $rootScopeMinErr('infdig',
                '{0} $digest() iterations reached. Aborting!\n' +
                'Watchers fired in the last 5 iterations: {1}',
                TTL, watchLog);
          }

        } while (dirty || asyncQueue.length);

        clearPhase();

        while (postDigestQueue.length) {
          try {
            postDigestQueue.shift()();
          } catch (e) {
            $exceptionHandler(e);
          }
        }
      },

```
`asyncQueue`代表异步队列，这里有两层循环，外层循环是为了保证所有的model都能被检测到，循环的两个条件，一是asyncQueue.length不为空；二是dirty为true,在监控watch的值的变化时，会将dirty置为true，循环开始会执行`asyncQueue`队列中的表达式。

内层循环用来遍历所有的watch函数，

```
if(value = watch.get(current)) !== (last = watch.last) &&  
!(watch.eq
    ? equals(value, last)
    : (typeof value === 'number' && typeof last === 'number'
       && isNaN(value) && isNaN(last))))
```
     
判断新值和旧值是否发生了变化，并且用watch.eq判断是否为深度监听，`equals`函数用来比较两个值是否相等，这个函数把所有可能的情况都考虑了进去，以前自己实现过两个值的比较，但是对于像DateRegExp这种类型的值的比较是没有考虑的，也正好查漏补缺。  
内层循环的代码：

```
if (!(next = (current.$$childHead || (current !== target && current.$$nextSibling)))) {
  while (current !== target && !(next = current.$$nextSibling)) {
    current = current.$parent;
  }
}
```
这段代码表示，在当前作用域下执行完对watch的监控之后，还要继续查找它的子作用域，兄弟作用域，父作用域，如果next有值就会一直循环，直到这一段代码：

```
if (ttl < 5) {
    logIdx = 4 - ttl;
    if (!watchLog[logIdx]) watchLog[logIdx] = [];
    watchLog[logIdx].push({
      msg: isFunction(watch.exp) ? 'fn: ' + (watch.exp.name || watch.exp.toString()) : watch.exp,
      newVal: value,
      oldVal: last
    });
  }
} else if (watch === lastDirtyWatch) {
  // If the most recently dirty watcher is now clean, short circuit since the remaining watchers
  // have already been tested.
  dirty = false;
  break traverseScopesLoop;
}

```

设置的ttl的初始值为10（默认值），ttl的存在就是为了防止循环次数过多，如果超过最大次数，就会throw错误并告诉开发者循环可能永远不会稳定。当ttl小于5的时候开始记录`watchLog`对象，如果当前的watch与最后一次检查的`lastDirtyWatch`相等的话就跳出内层循环同时结束外层循环。最后会执行`postDigestQueue`队列中的函数，这个跟asyncQueue不同的是，它不会主动触发`digest`方法,只是往`postDigestQueue`队列中增加执行表达式，在`digest`内最后执行。


通过阅读angularjs脏值检测的源码部分，对它底层的实现有了大致的了解，对于parse.js可以作为一个字符串的解析器，实际场景比如实现一个计算器，equals函数用来比较两个值是否相等，都是值得借鉴的部分。与之前实现的简易版本比较，实际angularjs框架做的东西就多得多了。

