title: Day.js 源码学习
date: 2018-07-11 12:00:00
categories: guanxiaofeng
tags:
    - dayjs
    - momentjs
---
dayjs 是一个轻量的 JavaScript 时间日期处理库，其用法（api）和 Moment.js 完全一样。
<!--more-->

📚[官方 API 文档（中文）](https://github.com/iamkun/dayjs/blob/master/docs/zh-cn/API-reference.md)

## 一 特性
* 和 Moment.js 相同的 API 和用法
* 不可变数据（Immutable）
* 支持链式操作（Chainable）
* l18n 国际化
* 仅 2kb 大小
* 全浏览器兼容

基本用法如下：
```javascript
    dayjs().startOf('month').add(1, 'day').set('year', 2018).format('YYYY-MM-DD HH:mm:ss');
```

## 二 解析
### 构造器 dayjs(existing?: string | number | Date | Dayjs)
从源码可以看出，调用 dayjs 时会返回一个 Dayjs 对象，Dayjs 构造器调用了 parseDate 方法，返回了一个全新的包含 Javascript Date 对象的 Dayjs 的对象；其他的值都是根据 Javascript Date 对象得来的。
```javascript
    // 部分源码
    const dayjs = (date, c) => {
      if (isDayjs(date)) {
        return date.clone()
      }
      const cfg = c || {}
      cfg.date = date
      return new Dayjs(cfg) // eslint-disable-line no-use-before-define
    }
    const parseDate = (date) => {
      let reg
      if (date === null) return new Date(NaN) // Treat null as an invalid date
      if (Utils.isUndefined(date)) return new Date()
      if (date instanceof Date) return date
      // eslint-disable-next-line no-cond-assign
      if ((typeof date === 'string')
        && (/.*[^Z]$/i.test(date)) // looking for a better way
        && (reg = date.match(C.REGEX_PARSE))) {
        // 2018-08-08 or 20180808
        return new Date(
          reg[1], reg[2] - 1, reg[3] || 1,
          reg[5] || 0, reg[6] || 0, reg[7] || 0, reg[8] || 0
        )
      }
      return new Date(date) // timestamp
    }
    class Dayjs {
      constructor(cfg) {
        this.parse(cfg) // for plugin
      }
      parse(cfg) {
        this.$d = parseDate(cfg.date)
        this.init(cfg)
      }
      init(cfg) {
        this.$y = this.$d.getFullYear()
        this.$M = this.$d.getMonth()
        this.$D = this.$d.getDate()
        this.$W = this.$d.getDay()
        this.$H = this.$d.getHours()
        this.$m = this.$d.getMinutes()
        this.$s = this.$d.getSeconds()
        this.$ms = this.$d.getMilliseconds()
        this.$L = this.$L || parseLocale(cfg.locale, null, true) || L
      }
      //...
    }
```
在 init 实例方法中，使用实例属性 $d（为 JavaScript 原生 Date 对象）来获取 年、月、日、周、时、分、秒、毫秒，且保存在实例中。并且调用 parseLocale 函数来获取语言，赋值给 Dayjs 实例的 $L 属性。

可传参数有5类：  
##### 1.当前时间
dayjs 本质上是个函数，因此可以直接运行该函数，得到包含当前时间和日期的 Dayjs 对象。
```javascript
     dayjs();
```
##### 2.标准的 ISO 8601 时间字符串
```javascript
     dayjs("2018-07-14");
```
##### 3.解析 Unix 时间戳(毫秒)
```javascript
     dayjs(1531469940578);
```
##### 4.解析 Date 对象
```javascript
     dayjs(new Date(2018,5,3));
```
##### 5.解析 dayjs 对象
```javascript
     dayjs(dayjs());
```
### 克隆
dayjs 对象是不可变的如果要复制对象，需要调用 .clone()，或者是在解析一个 dayjs 对象。 向 dayjs() 里传入一个 Dayjs 对象也能实现同样的效果。
```console
     dayjs().clone();
     dayjs(Dayjs);
```
部分源码如下：
```javascript
    const wrapper = (date, instance) => dayjs(date, { locale: instance.$L })
    clone() {
      return wrapper(this.toDate(), this)
    }
```
    
### 验证
检测当前 Dayjs 对象是否是一个有效的时间。
```javascript
     dayjs().isValid();
```
部分源码如下：
```javascript
    isValid() {
      return !(this.$d.toString() === 'Invalid Date')
    }
```

## 三 获取+设置
##### 获取各种时间
```javascript
     dayjs().year();        // 年
     dayjs().month();       // 月
     dayjs().date();        // 日
     dayjs().day();         // 星期(星期天 0, 星期六 6)
     dayjs().hour();        // 时
     dayjs().minute();      // 分
     dayjs().second();      // 秒
     dayjs().millisecond(); // 毫秒
```
##### 设置各种时间
```javascript   
     dayjs().set(unit : String, value : Int);
     dayjs().set('date', 1);
     dayjs().set('month', 3); // 四月
     dayjs().set('second', 30);
```
设置时间也是通过返回一个新的对象
```javascript
  set(string, int) {
    return this.clone().$set(string, int)
  }
```
  
## 四 格式化显示
格式化显示和 momentjs 一样，通过 .format() 即可，返回的是 String 。
```javascript
dayjs().format(String);
dayjs().format();             // "2018-07-13T20:10:31+08:00"
dayjs().format('YYYY-MM-DD'); // "2018-07-13"
dayjs().format('YYYY/MM/DD'); // "2018/07/13"
```

## 五 操作
##### 增加和减少
在此之前先看看源码实现的逻辑：

```javascript
   // 部分源码
  add(number, units) {
    number = Number(number) // eslint-disable-line no-param-reassign
    const unit = Utils.prettyUnit(units)
    const instanceFactory = (u, n) => {
      const date = this.set(C.DATE, 1).set(u, n + number)
      return date.set(C.DATE, Math.min(this.$D, date.daysInMonth()))
    }
    if (unit === C.M) {
      return instanceFactory(C.M, this.$M)
    }
    if (unit === C.Y) {
      return instanceFactory(C.Y, this.$y)
    }
    let step
    switch (unit) {
      case C.MIN:
        step = C.MILLISECONDS_A_MINUTE
        break
      case C.H:
        step = C.MILLISECONDS_A_HOUR
        break
      case C.D:
        step = C.MILLISECONDS_A_DAY
        break
      case C.W:
        step = C.MILLISECONDS_A_WEEK
        break
      case C.S:
        step = C.MILLISECONDS_A_SECOND
        break
      default: // ms
        step = 1
    }
    const nextTimeStamp = this.valueOf() + (number * step)
    return wrapper(nextTimeStamp, this)
  }
  subtract(number, string) {
    return this.add(number * -1, string)
  }
```
在 Dayjs 类中 add、subtract 等方法，都会通过 wrapper 返回一个新的 Dayjs 实例，是通过使用 Dayjs 类中的 clone() 方法实现的。所以，通过这个 clone() 方法，实现了 dayjs 的 immutable 特性。
当增加或减少的单位是年或月时，会先将日设置为1，然后再加减，最后再比较当前月的总天数和原来的天数（主要是解决像2月只有28天这类问题），取较小的值再返回；对于天／周／时／分／秒则是按照时间戳来计算，再通过 wrapper 返回一个新的 Date 对象。
```javascript
     dayjs().add(value : Number, unit : String);
     dayjs().add(5, 'day');
     dayjs().subtract(value : Number, unit : String);
     dayjs().subtract(2, 'year');
```
    
##### 开头和末尾
返回当前时间的开头时间的 Dayjs 对象，如月份的第一天。
```javascript
    dayjs().startOf(unit : String);
    dayjs().startOf('year').format('YYYY-MM-DD');  // 2018-01-01  
```
返回当前时间的末尾时间的 Dayjs 对象，如月份的最后一天。

```javascript
    dayjs().endOf(unit : String);
    dayjs().endOf('month').format('YYYY-MM-DD'); // 2018-07-31 
```

## 六 时间差
时间差是两个 dayjs 对象的之差所得的毫秒数。
```javascript
dayjs().diff(Dayjs, unit);
dayjs().diff(dayjs('2000-2-1'), 'years'); // 18
```
源码逻辑是先计算出两个时间相差的毫秒数和月数，再根据传入的单位去选择计算。
```javascript
diff(input, units, float) {
    const unit = Utils.prettyUnit(units)
    const that = dayjs(input)
    const diff = this - that
    let result = Utils.monthDiff(this, that)
    switch (unit) {
      case C.Y:
        result /= 12
        break
      case C.M:
        break
      case C.Q:
        result /= 3
        break
      case C.W:
        result = diff / C.MILLISECONDS_A_WEEK
        break
      case C.D:
        result = diff / C.MILLISECONDS_A_DAY
        break
      case C.H:
        result = diff / C.MILLISECONDS_A_HOUR
        break
      case C.MIN:
        result = diff / C.MILLISECONDS_A_MINUTE
        break
      case C.S:
        result = diff / C.MILLISECONDS_A_SECOND
        break
      default: // milliseconds
        result = diff
    }
    return float ? result : Utils.absFloor(result)
  }
```

## 七 其他方法
##### 获取 unix 毫秒时间戳：
```javascript
dayjs().valueOf(); // 1531633650522
```
##### 获取 unix 秒级时间戳：
```javascript
dayjs().unix(); // 1531633677
```
##### 返回月份的天数：
```javascript
dayjs().daysInMonth(); // 31
```
##### 获取 Date 对象：
```javascript
dayjs().toDate(); // Sun Jul 15 2018 13:48:41 GMT+0800 (CST)
```
##### 获取数组格式：
```javascript
dayjs().toArray(); //[2018, 6, 13, 20, 34, 13, 424];
```
##### 获取对象格式：
```javascript
dayjs().toObject();// {years: 2018, months: 6, date: 13, hours: 20, minutes: 34...}
```

## 八 dayjs 插件用法
dayjs 的插件，通过挂载到 dayjs 函数下的 extend 函数加载，然后使用：
```javascript
import plugin // 导入插件
dayjs.extend(plugin, options) // 加载插件的同时，加入插件所需要的参数
```
使用官方的 IsLeapYear 插件(判断是否是闰年):
```javascript
import isLeapYear from 'dayjs/plugin/isLeapYear'
dayjs.extend(isLeapYear)
dayjs('2000-01-01').isLeapYear() // true
dayjs('2018-01-01').isLeapYear() // false
```
dayjs.extend() 方法，接受两个参数，即插件（函数）和插件的选项。
```javascript
// 扩展插件的方法
// plugin：插件函数
// option：插件的选项
dayjs.extend = (plugin, option) => {
  // 插件函数接受三个参数
  // 1.插件选项 2.Dayjs 类 3.dayjs 函数
  // 插件的方法都是挂载在 Dayjs 类的原型对象上的（Dayjs.prototype）。
  plugin(option, Dayjs, dayjs)
  return dayjs
}
```
IsLeapYear 的源码如下：
```javascript
export default (o, c) => {
  const proto = c.prototype
  proto.isLeapYear = function () {
    return ((this.$y % 4 === 0) && (this.$y % 100 !== 0)) || (this.$y % 400 === 0)
  }
}
```
将 isLeapYear 函数挂载到 Dayjs 类的原型上，所以每个 Dayjs 实例都可以使用 isLeapYear 方法。
