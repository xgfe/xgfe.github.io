title: 实现React国际化
date: 2018-04-26 15:00:00
categories: jiangxiang
tags:
    - React
    - 国际化
---

React技术栈由facebook团队提出，由于性能优势明显，很快获得了广泛关注和大规模的使用，如今发展已经非常成熟。
基于react的渲染原理可以实现很多有意思的功能，例如实现一个React的国际化工具。(React v16.3)

<!--more-->

## 一、现状
### 1.1 目前前端国际化常用解决方案：

1.打包时翻译
2.动态翻译
3.多版本

比较流行的为webpack团队的webpack-i18-plugin和yahoo团队的react-intl

### 1.2 对比

1.打包时翻译
优点:方案比较成熟，已有成功案例
缺点:翻译表一旦更新，需要重新打包发布，本地要维护大量的翻译表文件，过于繁琐
2.动态翻译
优点:灵活，翻译表放进cdn一句sql可以更新，可操作性强
缺点:兼容性有待考察，对于不同的项目结构要设置特有的配置
3.多版本
优点:产生的打包文件最小，无需配置
缺点:修改过程复杂，应用场景不广泛

## 二、整体思路

JSX仅是React.createElement(component, props, ...children)的语法糖，使用高阶函数React.createElement重新定义组件渲染逻辑，将需要翻译的文字筛选并进行处理。
以下两种写法经过babel转义，本质上没有区别

```
class Hello extends React.Component {
  render() {
    return React.createElement('div', null, `Hello ${this.props.toWhat}`);
  }
}

ReactDOM.render(
  React.createElement(Hello, {toWhat: 'World'}, null),
  document.getElementById('root')
);
```
基于这个想法，改写createElement，就可做到对照翻译表动态检测data-translate翻译属性，来更新单独标签的文字
代码如下：
```
import React from 'react';

const createElement = React.createElement;
React.createElement = (...args) => {
    const newArgs = doSomething(...args);
    return createElement(newArgs)
}
```
如果每个要翻译的文本都要加属性也太过于繁琐，因此为了做到整段翻译，实现TranslateWrapper类，通过包裹特定的对象达到整段翻译的效果也非常必要


## 三、分析

### 3.1 翻译语法

语法分为批量翻译语法、单句翻译语法
通过Provider形式包裹或通过date-translate实现两种形式的翻译
```
// 批量翻译
<TranslateWrapper>
    ... (要翻译的代码块)
</TranslateWrapper>
// 单句翻译
<Dom data-translate>...(要翻译的代码块)</Dom>
```

### 3.2 动态请求
对于网络请求下载翻译表的需求，我们也需要考虑设置一些必要的hook，来控制整个工具的life cycle
```
beforeRequest(): void;
afterRequest(): void;
initial(): void;
onRender(process<Object>): React.ReactElement<any>;
afterRender(): void;
```

## 四、实现

### 4.1 translate函数

独立的翻译函数，这里省略了请求的过程，假设翻译表是固定的
middleware1处可以加个彩蛋（其实不是很常用），比如加个emoji？reverse()？或者搞成火星文？

```
import EN from './languages/trans-EN';
const languageMap = {
    'en': EN,
    'cn': '',
};
const translate = (content,language) => {
    // middleware1
    // middleware1 && middleware1()
    if (language && languageMap[language]) {
        languageMap[language][content] && (content = languageMap[language][content]);
    }
    return content;
}

export default {
    translate
}
```

### 4.2 TranslateWrapper类

这里将翻译的语言类型放入Context保存，被TranslateWrapper包裹的对象将被翻译
可以看到一个ReactDom，包含了$$typeof,props,ref等属性，将其children对象取到，并通过相应逻辑判断对照翻译表进行翻译
其中如果children类型时string，则代表没有其他子节点，可以直接翻译返回
类型为其他则递归，直到所有返回值均为string类型

```
import React,{Component} from 'react';
import {Consumer} from "./context";
import {translate} from "./translate";


class TranslateWrapper extends Component{
    constructor(...args){
        super(...args);
    }

    renderElement = (target) => {
        const child = target.props.children;
        if(typeof child === 'string'){
            return translate(child);
        }
        target = child && child.map(item=>{
            if(typeof item === 'string'){
                return translate(item);
            }
            return this.renderElement(item);
        });
        return target;
    }

    render(){
        let children = this.props.children;
        children = this.renderElement(children);
        return <div>
            {children}
        </div>;
    }
}

export default props => (
    <Consumer>
        {language => <TranslateWrapper {...props} language={language} />}
    </Consumer>
);
```
## 五、改写React.createElement

与React.Component不同 ...args这里得到了ReactDom的另一种属性格式 形如 $$typeof,props,... 或 null,...children,...
这里仍然沿用TranslateWrapper类的处理思路，translate函数与之前相同
```
const createElement = React.createElement;
React.createElement = (...args) => {
    let children = args.slice(2);

    children = children.map(child => {
        if (typeof child === 'string' && args[1] && args[1]['data-translate']) {
            return translate(child,language)
        }
        return child;
    });

    return createElement(args[0], args[1], ...children);
};
```
这样可以再翻译带有data-translate属性的标签

## 六、兼容性

如果想在项目中使用，秩序按如下方式导入即可即可
```
import React,{Component,PropTypes} from 'react';
import ReactDom from 'react-dom';
import './translate.js'; // 改写React.createElement
import TranslateWrapper from './translateWrapper';
import {Provider} from './context';

class App extends Component {
    constructor(...args){
        super(...args);
    }

    render(){
        return <Provider value="en">
                你好
                <div data-translate>
                    你好
                    <TranslateWrapper>
                        <span>你好
                            <span>你好React</span>
                        </span>
                    </TranslateWrapper>
                </div>
        </Provider>
    }
}

ReactDom.render(<App/>,document.body.appendChild(document.createElement('div')));

//翻译格式：
//export default {
//    '你好':'Hello'
//}

//结果：你好HelloHello你好React
```

正常来说兼容性还是不错的
但由于目前出现了很多前端流行的组件库，ant-design，.element of react
寄希望于无缝兼容 不如提供中间件接口来让使用者自行配置 o(╥﹏╥)o

### 6.1 ant-design
例如，在ant-design组件库中，input的placeholder属性，如不进行检测，将不会被翻译

```
import {filter} from 'myTranslate';

filter.forAntDesign = (props,language) => {
    let props = Object.assign({}, props);
            if (language && props.placeholder) {
                if (languageMap[language]) {
                    if (/[^\u4e00-\u9fa5]/g.test(props.placeholder)) {
                        props.placeholder = props.placeholder.replace(/([\u4e00-\u9fa5]+)/g, (match) => {
                            return languageMap[language][match] ? languageMap[language][match] : match
                        })
                    } else {
                        languageMap[language][props.placeholder] && (props.placeholder = languageMap[language][props.placeholder]);
                    }
                }
            }
            return <input {...props} ref="input" data-translated onInput={e => {this.value = e.target.value; this.props.onInput && this.props.onInput(e);}}>{this.props.children}</input>
}
```
Select的组件的选中时对比value和children.text的 所以如果翻译的话 也要将value一起翻译，这些都可以通过增加中间件，修改props.children的过滤规则处理

### 6.2 也有一些框架或者自行编写的组件，如.element for react, 某滴的自研UI内容并不会放在text中，这就需要额外的编写特殊loader了

## 七、总结
经过这样的设计，React国际化工具已经简单实现了，需要demo的我的仓库里有
这可以说是动态翻译的一种思路

这种实现至今还是有不合理的地方，还请各位拍砖指正，感谢！
