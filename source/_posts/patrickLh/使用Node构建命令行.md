title: 使用Node构建命令行
date: 2019-12-20 09:00:00
categories: patrickLh
tags: 
- 前端
---

本文主要是讲解如何使用Node构建自己的命令行，并对其实现原理做了一定的解析。

<!-- more -->

## 构建命令行
### 扩展Node参数解析
我们执行一个node命令
```
node index.js
```
使用`process.argv`，可以拿到相关`node`命令执行的所有参数。
```
// index.js
console.log(process.argv);
// 运行以下指令
node index x y; // ['/usr/local/bin/node', '.../index', 'x', 'y']
```
可以根据业务逻辑来自行解析处理这些参数，也可以引入`commander`库来帮助扩展命令行参数解析，`commaneder`将所有的参数结构化，在使用的时候更加方便。
#### option
使用`commander.option()`的方法，可以扩展当前指令能够支持的参数，并使用`commander.parse(process.argv)`将命令行参数告知`commander`进行处理。
```
// index.js
let program = require('commander');
// 增加命令支持的参数
program.option('-x, --extend', 'get all');
program.option('-y, --yield <type>', 'set block type', 'defaultValue');
//  program.option('-y, --yield <type>', 'set block type', (newValue, previous) => {
//    return newValue
//  })
// 将node参数转为program对象中使用
program.parse(process.argv);

if (program.extend) {
    console.log(program.opts());
}
if (program.yield) {
    console.log(program.yield);
}
```
执行命令后，可以看到相关输出结果
```
node index.js -x value1 -y value2 // { extend: true, yield: 'value2' }, value2
```
PS：
1. `option`第三个参数可以设置默认值，也可以使用函数，对解析后的参数值进行处理。
2. `-x`中的`x`将作为简称在命令行执行时候使用，`--extend`中的`extend`将作为最后对象的属性使用。

#### version
使用`commander.version()`函数可以指定当前命令行工具的版本，通常版本信息从`package.json`中读取
```
let program = require('commander');
let pkg = require('./package.json');
program.version(pkg.version, '-v, --vers', 'description');
program.parse(process.argv);
```
之后执行以下命令获取到版本信息
```
node index.js -v
```
#### command
如果需要扩展子命令（例如：`vue create`），可以使用`commander.command()`方法，并利用`comander.action()`函数，可以获得子命令中定义的参数`<arg1>`(必填) ,`[arg2]`（可选）和`option()`设置的命令行参数
```
let program = require('commander');
program.command('create <arg1> [arg2]')
.description('description')
.option('-x, --extend <type>', 'extend a message')
.option('-y, --yield <type>', 'yield a message')
.action((arg1, arg2, cmdObj) => {
    // todo
    console.log(arg1, arg2, cmdObj);
})
program.parse(process.argv);
```
执行命令
```
node index create infile outfile -x 1 -y 2; // infile, outfile, {...}
```
PS：每次运行`command()`方法，内部都会实例化一个新的对象，之后的`option`和`action`都是会绑定在新`command`的对象上
```
let program = require('commander');
program.command('create <arg1> [arg2]')
.description('description')
.option('-x, --extend', 'create option') // 这里-x是create命令的参数
.command('drop <arg1>')
.options('-y, --yield', 'drop option') // 这里-y是drop命令的参数
```
### 控制台交互
在使用命令行工具的时候，我们通常会使用到很多交互操作，以@`vue/cli`为例，命令行在创建项目的过程中，会提出问题，需要用户进行输入，选择某些特性。要实现这样的交互，我们可以使用`inquirer`库来进行辅助。

`inquirer`的使用十分简单，以`prompt`函数作为入口
```
let inquirer = require('inquirer');
inquirer.prompt([{
    type<string>: '', // 输入类型包括：input, confirm, list, rawlist(有序列表)，expand, checkbox, password(隐藏输入模式)，editor（进入vi编辑模式）
    name<string>: '', // 必须，answers中获取时对应的属性名
    message<string|Function>: '', // 提示信息
    default<string|number|Array|Function>: '', // 默认值设置
    choices<Array|Function>: '', // 选项，用于list，rowlist，expand，checkbox
    validate<Function>: '', // 验证输入值是否符合要求
    filter<Function>: '', // 对当前requestion的结果做处理
    when<Function|boolean>: '', // 后续的question可以获取谦虚前序的所有answers
    pageSize<number>: '', // 选项的分页数量
    prefix<String>: '', // 提示问题显示的前缀
    suffix<String>: '', // 提示问题显示的后缀
}]).then(answers => {
    // 多结果数组
})
```
`prompt`接受一个`question`数组，每个`question`设置`type`和`name`，在用户交互以后，通过`then`回调拿到对应的数据，所有的结果数据通过`anwsers[name]`的方式获取，这里的`name`就是在每一个`question`中配置的`name`，所以`name`必须要唯一。
### 安装命令行
在使用相关命令构建好命令行代码片段以后，我们想直接使用例如：`kibo create`的方式来执行命令行而不是`node kibo.js create`，可以将本地的包推到`npm`上，再利用`npm`的`install -g`特性进行安装，安装以后则可以全局使用，于是可以通过以下方式将包上传到`npm`
#### 初始化项目
在编写好`js`脚本以后，首先需要创建`package.json`文件，可以使用
```
npm init
```
#### 配置相关依赖
之后配置可以安装我们脚本中所需要使用到的依赖包，可以直接修改`package.json`文件，也可以执行：
```
npm install --save commender inquirer
```
PS：由于我们需要将包上传到npm并使用，所以如果手动配置，这里的依赖是需要放到`package.json`中的`dependences`中
#### 配置bin属性
我们需要增加/修改`pacakge.json`的`bin`属性，并将我们希望使用的命令行指令指向入口文件
```
{
    bin: {
        'kibo': './index.js'
    }
}
```
#### 登陆npm发布
最后，配置完成以后，检查`pacakge.json`的名称，版本号，描述，就可以登陆`npm`进行发布，发布成功以后就可以通过`npm install`使用
```
// npm登陆
npm login
// 执行推送，注意package.json中的name不能有所重复
npm publish
// 如果要取消发布，可以使用以下命令
npm unpublish --force
```
### 其他
控制台输出内容的颜色和背景色默认都是系统颜色，对于警告，错误我们通常会使用更醒目的颜色来显示，所以我们可以使用`chalk`库，通过其提供的方法`chalk.<style>(text)`来对我们输出内容的文本颜色进行设置，例如设置一个文本输出为红色：
```
let chalk = require('chalk');
console.log(chalk.red('this is a danger message'));
```
### 完整代码示例
根据上面的描述，写一个简单的在当前目录下创建一个特定文件，且文件中包含输入的内容
```
let program = require('commander');
let inquirer = require('inquirer');
let fs = require('fs');

program.command('create <filename>')
.description('创建一个新的文件')
.option('-d, --dest <path>', '文件路径', '.')
.action((filename, cmdObj) => {
  // 判断文件路径是否存在，如果不存在需要创建文件结构
  mkdir(cmdObj.dest);
  inquirer.prompt([{
    name: 'extend',
    type: 'list',
    message: '选择需要创建的文件类型',
    choices: [{name: 'html文件', value: 'html'},
              {name: 'css文件', value: 'css'},
              {name: 'javascript文件', value: 'js'}]
  }, {
    name: 'content',
    type: 'editor',
    message: '输入文件内容'
  }]).then(answers => {
    fs.writeFileSync(`${cmdObj.dest}/${filename}.${answers.extend}`, answers.content);
  });
});

function mkdir(path) {
  let p = path.split('/');
  let dir = p.reduce((accumulate, item) => {
    if (!fs.existsSync(accumulate)) {
      fs.mkdirSync(accumulate);
    }
    return accumulate + '/' + item;
  }, '.');
  // 创建最后的目录
  if (!fs.existsSync(dir)) {
    fs.mkdirSync(dir);
  }
}

program.parse(process.argv);
// 如果参数少于2个弹出帮助提示
if (!process.argv.slice(2).length) {
  program.outputHelp();
}
```
## 核心源码解析
### commander
之前已经提及了`commander`如何使用，我们认为其目的是主要对`process.argv`进行了解析，那么如何解析？可以通过查看源码来学习

入口文件中，引入对是一个`Command`对象实例
```
// index.js
function Command(name) {
  this.commands = [];
  this.options = [];
  this._execs = new Set();
  this._allowUnknownOption = false;
  this._args = [];
  this._name = name || '';

  this._helpFlags = '-h, --help';
  this._helpDescription = 'output usage information';
  this._helpShortFlag = '-h';
  this._helpLongFlag = '--help';
}
```
之后我们通过调用`option()`方法来扩展命令，`option`方法主要会将所有设置的内容存放到`Command`对象的`options`属性中，并绑定特定事件
```
Command.prototype._optionEx = function(config, flags, description, fn, defaultValue) {
    ...
    // 第419行
    this.options.push(option);
    // 绑定事件
    this.on('option:' + oname, function(val) {
        ...
    })
    ...
}
```
需要说明一下，这里的事件绑定是使用`node`的`events`来扩展到`Command`对象上实现的
```
// 第6行
var EventEmitter = require('events').EventEmitter;
// 第16行
require('util').inherits(Command, EventEmitter);
```
而我们在调用`command()`方法的时候，则会在`commands`属性中增加内容，并将返回当前对象，也就是说，在调用`command()`之后，之后配置都会挂载到新设置到`Command`中
```
Command.prototype.command = function(nameAndArgs, actionOptsOrExecDesc, execOpts) {
    ...
    // 172行
    var cmd = new Command(args.shift());
    ...
    // 188行
    this.commands.push(cmd);
    cmd.parseExpectedArgs(args);
    cmd.parent = this;
    if (desc) return this;
    return cmd;
    ...
}
```
对于`action()`方法调用的时候，会调用当前`command`的事件绑定
```
Command.prototype.action = function(fn) {
    ...
    // 362行
    var parent = this.parent || this;
    var name = parent === this ? '*' : this._name;
    parent.on('command:' + name, listener);
    ...
}
```
最后调用`parse()`方法，完成对输入`node`参数的解析（通过触发设置的事件）
```
// 542行
Command.prototype.parse = function(argv) {
    ...
}
```
### inquirer
从表现上来看，`inquirer`要完成交互，需要处理两个问题：第一个是如何处理键盘的操作（输入，方向键），另一个是如何在输入操作以后对输入结果进行渲染。

以`prompt()`方法来作为入口，在调用的时候，会创建以下的实例，并运行`run`方法（根据`type`不同，这里的`ui`对象也不同，简单的工厂模式）
```
// inquirer.js
// 25行
inquirer.createPromptModule = function(opt) {
    ...
    var ui = new inquirer.ui.Prompt(promptModule.prompts, opt);
    var promise = ui.run(questions);
    ...
}
```
以`type: list`为例，可以看到主要进行了键位监听，处理光标，渲染操作：
```
// prompts/list.js
// 49行
  _run(cb) {
    this.done = cb;
    var self = this;
    // 事件监听
    var events = observe(this.rl);
    events.normalizedUpKey.pipe(takeUntil(events.line)).forEach(this.onUpKey.bind(this));
    events.normalizedDownKey
      .pipe(takeUntil(events.line))
      .forEach(this.onDownKey.bind(this));
    events.numberKey.pipe(takeUntil(events.line)).forEach(this.onNumberKey.bind(this));
    events.line
      .pipe(
        take(1),
        map(this.getCurrentValue.bind(this)),
        flatMap(value => runAsync(self.opt.filter)(value).catch(err => err))
      )
      .forEach(this.onSubmit.bind(this));

    // Init the prompt
    cliCursor.hide();
    // 输出渲染
    this.render();
    return this;
}
```
#### 键盘监听
源码中使用了`rxjs`，但是核心代码是监听键盘输入
```
// utils/events
// 10行
// 这里的fromEvent，takeUntil，pipe，filter都是rxjs相关的api
// rl是node自带的readline库的实例
var keypress = fromEvent(rl.input, 'keypress', normalizeKeypressEvents)
    .pipe(takeUntil(fromEvent(rl, 'close')))
    // Ignore `enter` key. On the readline, we only care about the `line` event.
    .pipe(filter(({ key }) => key.name !== 'enter' && key.name !== 'return'));
```
可以看到，在`rl.input`监听了`keypress`事件，将以上代码转换为非`rxjs`的方式
```
const readline = require('readline');
// 如果增加mute-stream
// var MuteStream = require('mute-stream');
// var ms = new MuteStream();
// ms.pipe(process.stdout);
// 设置输入输出流
let rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout,
  // output: ms,
});
// 监听每行输入，当输入回车的时候会触发改读入行操作
rl.on('line', (input) => {
  console.log(`Received: ${input}`);
});
// 增加输入键盘监听
rl.input.on('keypress', (value, key) => {
    console.log(`key.name: ${key.name}`);
});
```
本质核心是`process.stdin`的键盘监听
```
process.stdin.on('keypress', (value, key) => {
    console.log(`key.name: ${key.name}`);
});
```
#### 渲染处理
渲染处理引用了`mute-stream`的库来进行辅助，可以在调用相关方法（`mute`,`unmute`）的时候，存储内容一次性输出内容，渲染的核心代码
```
this.screen.render(message);
// utils/screen-manager
// 25行
render(content, bottomContent) {
    this.rl.output.unmute();
    this.clean(this.extraLinesUnderPrompt);
    ...
    this.rl.output.write(fullContent);
    ...
    this.rl.output.mute();
}

// 94行
clean(extraLines) {
    if (extraLines > 0) {
      util.down(this.rl, extraLines);
    }
    util.clearLine(this.rl, this.height);
}
```
渲染中最需要解决的问题在于，如何将控制台输出的内容清空后重新渲染，使用扩展库`ansi-escapes`可以实现这一效果
```
let ansiEscapes = require('ansi-escapes');
rl.output.write(ansiEscapes.eraseLines(1));
```
但是扩展库的本质是通过什么操作使得清空能得以实现？进一步阅读扩展库方法，可以看到扩展库在我们输出的字符串中增加了相关的内容，从而实现了清空控制台已输出内容
```
// 6行
const ESC = '\u001B[';
// 41行
ansiEscapes.cursorUp = (count = 1) => ESC + count + 'A';
// 51行
ansiEscapes.cursorLeft = ESC + 'G';
// 60行
ansiEscapes.eraseLines = count => {
  let clear = '';
  for (let i = 0; i < count; i++) {
    clear += ansiEscapes.eraseLine + (i < count - 1 ? ansiEscapes.cursorUp() : '');
  }
  if (count) {
    clear += ansiEscapes.cursorLeft;
  }
  return clear;
};
// 76行
ansiEscapes.eraseLine = ESC + '2K';
```
对方法进行调用，实际上输出结果
```
// 如果调用改方法，则返回
ansiEscapes.eraseLines(1); // '\u001B[2K\u001B[1A\u001B[G'; 
```
也就是说，如果我们在`node`脚本中使用以下内容，可以发现第二个输出并不会出现
```
// 用标准输出流试一下
console.log(1);
console.log(2);
process.stdout.write('\u001B[2K\u001B[1A\u001B[G');
```
### chalk
`chalk`可以使得文本输出颜色发生改变，那么具体是如何改变的呢？调查源码，发现引用了外部库`ansi-styles`
```
// source/index.js 第2行
const ansiStyles = require('ansi-styles');
```
外部库的核心操作，是在输出内容的前后增加了一段文本
```
// index.js  第125行
styles[styleName] = {
    open: `\u001B[${style[0]}m`,
    close: `\u001B[${style[1]}m`
};
```
其中，这里的`style`对象，以红色为例的开闭值为：[31, 39]，所以，如果想在控制台输出红色文本，在浏览器/`node`中可以使用以下输出：
```
console.log(`\u001B[31m 测试 \u001B[39m`)
```
最后为什么增加文本能输出红色呢？初步认为`node`和浏览器中的`console.log`参照了ANSI的颜色解析规则，在使用相关的[`ANSI colors`](https://tintin.sourceforge.io/info/ansicolor)的解析规则，从而使得输出文本可以显示颜色，然而具体底层细节实现是怎么做到的就不清楚了

## 总结
要构建一个完整的命令行，其本质上从需要解决什么问题出发，然后推及到每一步操作如何实现（解析参数，输入交互，变为可执行命令行），同时再拆分到每一步的实现过程中的具体技术，最后将所有的组合起来。

对于第三方库的使用，能很快的解决问题，但是如果有时间，了解代码本质的实现逻辑，可以扩展自己对编程的认知，便于以后解决问题的思路扩展。

## 参考
[commander](https://github.com/tj/commander.js)

[inquirer](https://github.com/SBoudrias/Inquirer.js#readme)

[chalk](https://github.com/chalk/chalk)

[ANSI Colors](https://tintin.sourceforge.io/info/ansicolor)

[Node readline](https://nodejs.org/docs/latest/api/readline.html)

[Node process](https://nodejs.org/docs/latest/api/process.html)