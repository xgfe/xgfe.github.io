title: 函数防抖与函数节流
date: 2019-03-09 16:15
categories:
- yangfan
tags:
- javascript
- debounce&throttle
- 性能优化
---

在开发过程中,我们经常以各种方式控制事件的触发。防抖和节流可以使我们在实现功能的同时提升用户体验和页面性能。接下来我将从概念、应用场景、及简单的代码实现来介绍防抖和节流。

<!--more-->

## Debounce（防抖）

### 概念
> 当调用动作过n毫秒后，才会执行该动作，若在这n毫秒内又调用此动作则将重新计算执行时间。

### 典型应用场景
用户注册时验证用户名是否被占用为例在输入的时候就在判断这个用户名是否已被注册。
<div style="overflow:hidden;">
<div style="float:left;width:50%;text-align: center;">
使用防抖函数前
<img src="/uploads/yangfan/DebounceThrottle/debouncebefore.gif" width="400px">
</div><div style="float:left;width:50%;text-align: center;">
使用防抖函数后
<img src="/uploads/yangfan/DebounceThrottle/debounceafter.gif" width="400px">
</div>
</div>

使用防抖函数前做法存在明显缺陷当用户输入发生变化的时候，就请求判断了，不仅对服务器的压力增大了，而且用户在输入中时频繁的校验提示中断用户交互明显降低了用户体验。而理想的做法应该是，用户输入发生变化后的一段时间内如果还有字符输入的话，那就暂时不去请求判断用户名是否被占用。而函数防抖所做的工作就是延迟一段时间去执行函数而在延迟期间又调用了此动作则重新计时。

### DemoCode
```html
<ul>
    <li>
        <label for="ordinary">普通</label>
        <input type="text" name='ordinary' id='ordinary'>
    </li>
    <li>
        <label for="debounce">防抖</label>
        <input type="text" name='debounce' id='debounce'>
    </li>
</ul>
```
```javascript
function ajax(e) {
    console.log(`ajax requestDtae:${e.target.value}`);
}
const ordinaryInput = document.getElementById('ordinary');
const debounceInput = document.getElementById('debounce');
const debounceAjax = _.debounce(ajax, 1000)
ordinaryInput.addEventListener('keyup', ajax);
debounceInput.addEventListener('keyup', debounceAjax);
```

### 实现
```javascript
/**
 *
 * @param {function} func 传入函数
 * @param {number} wait 表示时间间隔
 * @return {function} 返回客户调用函数
 */
const debounce = function (func, wait) {
    let timer;
    return function (args) {
        clearTimeout(timer);
        timer = setTimeout(() =>{
            func(args);
        }, wait);
    }
};
```

## Throttle（节流）

### 概念
> 预先设定一个执行周期，当调用动作的时刻大于等于执行周期则执行该动作，然后进入下一个新周期。

### 典型应用场景
在瀑布流式布局的页面中，随着页面滚动条向下滚动，这种布局还会不断加载数据块并附加至当前尾部。在发生滚动时就需要判断页面是否滚动到底部。
<div style="overflow:hidden;">
<div style="float:left;width:50%;text-align: center;">
使用节流函数前
<img src="/uploads/yangfan/DebounceThrottle/throttlebefore.gif" width="400px">
</div><div style="float:left;width:50%;text-align: center;">
使用节流函数后
<img src="/uploads/yangfan/DebounceThrottle/throttleafter.gif" width="400px">
</div>
</div>

使用节流函数前明显缺点是消耗性能，因为当在滚动的时候，浏览器会无时不刻地在计算判断是否滚动到底部的逻辑，而在实际的场景中是不需要这么做的，在实际场景中可能是这样的：在滚动过程中，每隔一段时间在去计算这个判断逻辑。而函数节流所做的工作就是每隔一段时间去执行一次原本需要无时不刻地在执行的函数。

### DemoCode
```javascript
const body = document.body;
function scrollAnimation() {
    console.log(`scroll bodyY:${body.getBoundingClientRect().y}`);
}
const throttleScrollAnimation = _.throttle(scrollAnimation, 200);
//window.addEventListener('scroll', scrollAnimation);
window.addEventListener('scroll', throttleScrollAnimation);
```

### 实现
```javascript
/**
 *
 * @param {function} func 传入函数
 * @param {number} wait 表示时间窗口的间隔
 * @return {function} 返回客户调用函数
 */
const throttle = function (func, wait) {
    let timeout;
    let start = +new Date();
    return function (args) {
        curr = +new Date();
        clearTimeout(timeout);
        if (curr - start >= wait) {
            func(args);
            start = curr;
        } else {
            timeout = setTimeout(() => {
                func(args);
            }, wait);
        }
    }
}
```
## 总结
如果还是不能完全体会 debounce 和 throttle 的差异，可以到 [这个页面](http://demo.nimius.net/debounce_throttle/) 看一下两者可视化的比较。     
在实际的开发中根据根据需求的不同合理使用 debounce 或 throttle。
例如：在模糊查询时使用 debounce 在无限滚动时使用 throttle。（requestAnimationFrame）

## 附lodash实现代码

```javascript
import isObject from './isObject.js'
import root from './.internal/root.js'

/**
 * Creates a debounced function that delays invoking `func` until after `wait`
 * milliseconds have elapsed since the last time the debounced function was
 * invoked, or until the next browser frame is drawn. The debounced function
 * comes with a `cancel` method to cancel delayed `func` invocations and a
 * `flush` method to immediately invoke them. Provide `options` to indicate
 * whether `func` should be invoked on the leading and/or trailing edge of the
 * `wait` timeout. The `func` is invoked with the last arguments provided to the
 * debounced function. Subsequent calls to the debounced function return the
 * result of the last `func` invocation.
 *
 * **Note:** If `leading` and `trailing` options are `true`, `func` is
 * invoked on the trailing edge of the timeout only if the debounced function
 * is invoked more than once during the `wait` timeout.
 *
 * If `wait` is `0` and `leading` is `false`, `func` invocation is deferred
 * until the next tick, similar to `setTimeout` with a timeout of `0`.
 *
 * If `wait` is omitted in an environment with `requestAnimationFrame`, `func`
 * invocation will be deferred until the next frame is drawn (typically about
 * 16ms).
 *
 * See [David Corbacho's article](https://css-tricks.com/debouncing-throttling-explained-examples/)
 * for details over the differences between `debounce` and `throttle`.
 *
 * @since 0.1.0
 * @category Function
 * @param {Function} func The function to debounce.
 * @param {number} [wait=0]
 *  The number of milliseconds to delay; if omitted, `requestAnimationFrame` is
 *  used (if available).
 * @param {Object} [options={}] The options object.
 * @param {boolean} [options.leading=false]
 *  Specify invoking on the leading edge of the timeout.
 * @param {number} [options.maxWait]
 *  The maximum time `func` is allowed to be delayed before it's invoked.
 * @param {boolean} [options.trailing=true]
 *  Specify invoking on the trailing edge of the timeout.
 * @returns {Function} Returns the new debounced function.
 * @example
 *
 * // Avoid costly calculations while the window size is in flux.
 * jQuery(window).on('resize', debounce(calculateLayout, 150))
 *
 * // Invoke `sendMail` when clicked, debouncing subsequent calls.
 * jQuery(element).on('click', debounce(sendMail, 300, {
 *   'leading': true,
 *   'trailing': false
 * }))
 *
 * // Ensure `batchLog` is invoked once after 1 second of debounced calls.
 * const debounced = debounce(batchLog, 250, { 'maxWait': 1000 })
 * const source = new EventSource('/stream')
 * jQuery(source).on('message', debounced)
 *
 * // Cancel the trailing debounced invocation.
 * jQuery(window).on('popstate', debounced.cancel)
 *
 * // Check for pending invocations.
 * const status = debounced.pending() ? "Pending..." : "Ready"
 */
function debounce(func, wait, options) {
    let lastArgs, 
        lastThis,
        maxWait,
        result,
        timerId,
        lastCallTime

    let lastInvokeTime = 0
    let leading = false
    let maxing = false
    let trailing = true

    // Bypass `requestAnimationFrame` by explicitly setting `wait=0`.
    const useRAF = (!wait && wait !== 0 && typeof root.requestAnimationFrame === 'function')

    if (typeof func !== 'function') {
        throw new TypeError('Expected a function')
    }
    wait = +wait || 0
    if (isObject(options)) {
        leading = !!options.leading
        maxing = 'maxWait' in options
        maxWait = maxing ? Math.max(+options.maxWait || 0, wait) : maxWait
        trailing = 'trailing' in options ? !!options.trailing : trailing
    }

    function invokeFunc(time) {
        const args = lastArgs
        const thisArg = lastThis

        lastArgs = lastThis = undefined
        lastInvokeTime = time
        result = func.apply(thisArg, args)
        return result
    }

    function startTimer(pendingFunc, wait) {
        if (useRAF) {
            root.cancelAnimationFrame(timerId);
            return root.requestAnimationFrame(pendingFunc)
        }
        return setTimeout(pendingFunc, wait)
    }

    function cancelTimer(id) {
        if (useRAF) {
            return root.cancelAnimationFrame(id)
        }
        clearTimeout(id)
    }

    function leadingEdge(time) {
        // Reset any `maxWait` timer.
        lastInvokeTime = time
        // Start the timer for the trailing edge.
        timerId = startTimer(timerExpired, wait)
        // Invoke the leading edge.
        return leading ? invokeFunc(time) : result
    }

    function remainingWait(time) {
        const timeSinceLastCall = time - lastCallTime
        const timeSinceLastInvoke = time - lastInvokeTime
        const timeWaiting = wait - timeSinceLastCall

        return maxing ?
            Math.min(timeWaiting, maxWait - timeSinceLastInvoke) :
            timeWaiting
    }

    function shouldInvoke(time) {
        const timeSinceLastCall = time - lastCallTime
        const timeSinceLastInvoke = time - lastInvokeTime

        // Either this is the first call, activity has stopped and we're at the
        // trailing edge, the system time has gone backwards and we're treating
        // it as the trailing edge, or we've hit the `maxWait` limit.
        // timeSinceLastCall < 0 修改系统时间时不会出现bug
        return (lastCallTime === undefined || (timeSinceLastCall >= wait) ||
            (timeSinceLastCall < 0) || (maxing && timeSinceLastInvoke >= maxWait))
    }

    function timerExpired() {
        const time = Date.now()
        if (shouldInvoke(time)) {
            return trailingEdge(time)
        }
        // Restart the timer.
        timerId = startTimer(timerExpired, remainingWait(time))
    }

    function trailingEdge(time) {
        timerId = undefined

        // Only invoke if we have `lastArgs` which means `func` has been
        // debounced at least once.
        if (trailing && lastArgs) {
            return invokeFunc(time)
        }
        lastArgs = lastThis = undefined
        return result
    }

    function cancel() {
        if (timerId !== undefined) {
            cancelTimer(timerId)
        }
        lastInvokeTime = 0
        lastArgs = lastCallTime = lastThis = timerId = undefined
    }

    function flush() {
        return timerId === undefined ? result : trailingEdge(Date.now())
    }

    function pending() {
        return timerId !== undefined
    }

    function debounced(...args) {
        const time = Date.now()
        const isInvoking = shouldInvoke(time)

        lastArgs = args
        lastThis = this
        lastCallTime = time

        if (isInvoking) {
            if (timerId === undefined) {
                return leadingEdge(lastCallTime)
            }
            if (maxing) {
                // Handle invocations in a tight loop.
                timerId = startTimer(timerExpired, wait)
                return invokeFunc(lastCallTime)
            }
        }
        if (timerId === undefined) {
            timerId = startTimer(timerExpired, wait)
        }
        return result
    }
    debounced.cancel = cancel
    debounced.flush = flush
    debounced.pending = pending
    return debounced
}

function throttle(func, wait, options) {
    let leading = true
    let trailing = true

    if (typeof func !== 'function') {
        throw new TypeError('Expected a function')
    }
    if (isObject(options)) {
        leading = 'leading' in options ? !!options.leading : leading
        trailing = 'trailing' in options ? !!options.trailing : trailing
    }
    return debounce(func, wait, {
        leading,
        trailing,
        'maxWait': wait,
    })
}
```

## 参考资料

* [lodash](https://lodash.com/)
* [Debouncing and Throttling Explained Through Examples](https://css-tricks.com/debouncing-throttling-explained-examples/)