title: Vue2.0+Vue-router2.0+Vuex2.0搭建简书
date: 2016-12-22
categories: zhouxiong
tags:
- Vue2.0
- Vue-router2.0
- Vuex2.0
---
随着Vue2.0的发布，Vue系列生态Vue-router、Vuex等也都升级到了2.0版本，但是关于Vue2.0版本的例子还比较少，而且由于Vue2.0相比Vue1.0版本改动较大，其中也有不少的坑，这里就从零开始利用Vue2.0系列搭建简书网站雏形。

<!--more-->
## Vue2.0+Vue-router2.0+Vuex2.0搭建简书
### 前言
随着Vue2.0的发布，Vue系列生态Vue-router、Vuex等也都升级到了2.0版本，但是关于Vue2.0版本的例子还比较少，而且由于Vue2.0相比Vue1.0版本改动较大，其中也有不少的坑，这里就从零开始利用Vue2.0系列搭建简书网站雏形。

**注意：本篇文章只介绍了比较重要的几个文件的内容，有些文件内容类似就没有拿出来讲解。所以代码并不是全部的，所以按照本文的内容并不能完全搭建起一个网站，想要全部的代码可以从下面的github仓库中获取**

github地址：[https://github.com/zhouxiongking/vue2.0-vuex2.0-demo-jianshu](https://github.com/zhouxiongking/vue2.0-vuex2.0-demo-jianshu)

### 准备知识
- vue2.0

 本文中使用的是.vue文件格式编写组件。Vue.js设计了一个.vue格式的文件，另每一个组件的模板、脚本、样式都集成在一个文件里，每个文件都是一个组件，同时包含了组件之间的依赖关系，整个组件从外观到结构到特性再到依赖性都一览无余
 
- vue-router2.0

 vue-router是vue框架提供的用于路由控制的库

- vuex2.0

 vuex是专门为vue应用提供状态管理的库，它为vue应用的所有组件提供一个数据存储中心（store），所有组件遵循特定的规则通过这个store进行数据交互，让组件的通信变得更容易维护
 
- es6

 vue2.0中使用的都是es6的语法，带来了书写上的方便，这就要求对es6语法有最基本的掌握

- webpack

  webpack主要的作用是把所有浏览器端需要发布的静态资源做相应的准备，比如资源的解析、合并和打包。同时webpack提供了强大的loader和plugin机制，loader机制支持加载各种类型的静态资源文件，例如babel-loader用于支持es6文件，css-loader用于支持css文件。而plugin则可以对整个webpack的流程进行控制。由于webpack提供了vue-loader，所以webpack支持vue的.vue文件格式的编写。


### 项目目录结构
本项目使用vue-cli脚手架自动生成，利用vue-cli配合webpack可以很方便的为搭建好项目的目录结构，项目结构如下所示

<img src="http://p0.meituan.net/dpnewvc/7b40c71206391a3e42d499d73cb001fb79952.png" height="450" alt="项目目录结构">

- **build**: webpack配置文件，以及开启server的文件，如果不涉及与后端的交互，这个文件夹的内容不用动；如果需要与后端进行交互，则要在里面编写处理请求的方法。
- **components**：包含页面所有组件
- **App.vue**: 主页面组件
- **main.js**: 应用入口，包含根节点
- **static**: 项目中存在的静态资源（图片或图标库）
- **vuex**：包含vuex相关文件，store.js，getter.js，action.js等

### 项目搭建

- 安装vue-cli

 `npm install -g vue-cli`
 
- 创建webpack项目

 `vue init webpack vue-demo-jianshu`
 
 `cd vue-demo-jianshu`
 
- 安装依赖

  `npm install`

- 安装vue-router

 `npm install vue-router --save-dev`
 
- 安装vuex

 `npm install vuex --save-dev`
 
- 运行

 `npm run dev`
 
如果以上步骤全都运行正确，则在浏览器输入http://localhost:8080，可以访问到如下页面
<img src="http://p1.meituan.net/dpnewvc/12b5ff26dd51f7a9cf96941764f856d9171798.png" height="400">

### 项目开发

在搭建完项目后，便可以开始项目代码的编写了，首先我们对页面的结构进行分析
![主页面](http://p1.meituan.net/dpnewvc/fc348abd3192c1d65c812f70f736547b1123026.png)

- 左侧绿色菜单栏框：每个页面都会有，故写在App.vue里
- 右侧黄色登录/注册框：多个页面都会有，故写在App.vue里
- 紫色展示框：页面主要内容，会随着左侧菜单栏进行变化，故写在Home.vue里
- 中间棕色列表框：展示页面列表内容，写在ArticleList.vue里

在整个系统中会有多个页面组件，下面我们只选取其中几个比较重要的组件，而且它们已经包含了应用程序的主流程：App.vue进入应用程序 --> 根据左侧导航栏动态展示Home.vue中的内容，其中包括文章列表ArticleList.vue -->  在文章列表页面，点击文章标题进入具体文章展示页面Article.vue。

#### main.js
main.js作为应用程序脚本文件的主入口，在main.js中引入vue，vue-router，vuex等，并对vue-router进行配置。**由于代码文件较大，只对代码文件中比较重要的部分贴出来进行讲解，后续的文件也是如此，如果想看全部的代码，自行clone上面的github仓库**

```
import Vue from 'vue'   //引入vue
import VueRouter from 'vue-router'   //引入vue-router
import store from '../vuex/store'    //引入vuex的store

Vue.use(VueRouter)     //注册vue-router

//配置路由，部分代码，不同于vue-router1.0，vue-router2.0利用routes参数进行路由配置，
//接收path和component属性组成的对象，子路由采用children参数
const router = new VueRouter({
    routes: [{
        path: '/home',
        component: Home,
        children: [{
            path: 'article/:type',
            component: ArticleList
        }]
    }, {
        path: '/topic',
        component: Topic,
        children: [{
            path: 'topic_article/:type',
            component: topicActicle
        }]
    }]
  ))
  
  var vm = new Vue({
    el: '#app',  //vue实例的根元素
    router,    //在vue实例中,引入定义的路由
    store,    //在vue实例中,引入vuex的store
    render: h => h(App)    //渲染App组件
})
```
#### App.vue

App.vue作为程序入口的主组件，与main.js绑定在一起

```
<template> 
<div class="container">
    <!-- 左边菜单栏 -->
    <div class="sidebar">
        
    </div>
    <!-- 中间主显示框 -->
    <div class="home">
        <transition name="display" node="out-in">
            <!--用于展示Home.vue部分的内容 -->
            <router-view></router-view>
        </transition>
    </div>
    
    <!-- 右侧登录/注册栏，这个articleFlag参数表示，如果是在文章显示的页面，则会删除掉右边的登录/注册部分 -->
    <div class="rightbar" v-if="articleFlag">  
        <nav>
            <ul class="nav-ul">
                <li @click="changeLoginway('login')">
                    <router-link to="/login">
                        <i class="fa fa-sign-in"></i>
                        登录
                    </router-link>
                </li>
                <li @click="changeLoginway('register')">
                    <router-link to="/login">
                        <i class="fa fa-user"></i>
                        注册
                    </router-link>
                </li>
            </ul>
        </nav>
    </div>
</div>
</template>
```

#### Home.vue

Home.vue作为中间核心展示组件，会随着左侧菜单栏的变化而变化。在Home.vue中，左侧是一张显示用的图片，可以固定；右侧顶部导航也可以固定，右侧中部的分类导航栏与下面的列表展示是动态变化的，故应该在这里使用路由。

```
<template>
  <div>
      <!-- 左侧展示图片区域 --> 
      <div class="showbar">
          <div class="cover-image"></div>
          <div class="text">
              <h1>简书</h1>
              <h3>交流故事</h3>
              <p>一个基于内容分享的社区</p>
              <router-link to="/write">
                  <i class="fa fa-home"></i>
                  提笔写文章
              </router-link>
          </div>
      </div>
      <div class="article-page">
          <!-- 右侧顶部导航栏 -->
          <nav>
              <span class="nav-text fir">
                  <a href="#">发现</a>
              </span>
              <span class="nav-text">
                  <router-link to="/bonus">2016精选</router-link>
              </span>
              <span class="search clearfloat">
                  <span class="input">
                      <input type="search" placeholder="搜索">
                      <span class="search-icon">
                          <i class="fa fa-search"></i>
                      </span>
                  </span>
              </span>
          </nav>
          <div class="article-list">
             <!-- 右侧中部分类导航栏 -->
              <ul class="btn-group">
                  <li :class="{active: show === 'hot'}" @click="displayArticles('hot')">
                      <router-link to="/home/article/hot">热门</router-link>
                  </li>
                  <li :class="{active: show === 'new'}" @click="displayArticles('new')">
                      <router-link to="/home/article/new">新上榜</router-link>
                  </li>
              </ul>
              <!-- 右侧中部分类列表展示 -->
              <router-view></router-view>
          </div>
      </div>

  </div>
</template>
```

#### ArticleList.vue

ArticleList.vue是用于展示文章列表的组件，每种类型的文章都会存在一个文章列表，在Home.vue中点击对应的分类会在ArticleList.vue中进行展示。

```
<template>
    <div>
        <ul>
            <li class="list" v-for="article in articles">
                <p class="list-top">
                    <a href="#" class="author">
                        <span>{{article.author}}</span>
                    </a>
                    <span class="time">
                        - {{article.time}}
                    </span>
                </p>
                <h2 class="title">
                    <!-- 点击文章的标题会进入到文章展示页面，在这里设置路由 -->
                    <router-link to="/article/123211">{{article.title}}</router-link>
                </h2>
                <span class="small-text">阅读 {{article.read}}</span>
                <span class="small-text">评论 {{article.comment}}</span>
                <span class="small-text">喜欢 {{article.like}}</span>
                <span class="small-text">打赏 {{article.pay}}</span>
                <span class="image"
                      :style="{ background: article.src, backgroundSize: '100%', backgroundRepeat: 'no-repeat' }"></span>
            </li>
        </ul>
    </div>
</template>
```

#### Article.vue

 Article.vue是展示具体文章的组件，通过在ArticleList.vue中点击文章标题后进入到具体文章页面。
 
 ```
 <template>
  <div class="article-container">
    <!-- Article activities for width under 768px -->
    <div class="related-avatar-group activities"></div>
    <div class="article">
      <div class="preview">
        <div class="author-info">
          <div class="btn btn-small btn-success follow" id="follow_user_445173">
            <a data-type="json" data-user-slug="29010e584814" data-remote="true" rel="nofollow" data-method="post" href="#"><i class="fa fa-plus"></i>  <span>添加关注</span></a>
          </div>

          <a class="avatar" href="#">
            <img src="http://upload.jianshu.io/users/upload_avatars/445173/693d39ebd6c5.jpg?imageMogr/thumbnail/90x90/quality/100" alt="100">
          </a>            <span class="label">
                作者
            </span>
          <a class="author-name blue-link" href="#">
            <span>东辉在线</span>
          </a>
          <span data-toggle="tooltip" data-original-title="最后编辑于 2016.12.07 16:29">2016.12.05 22:16</span>
          <div>
            <span>写了25144字</span>，<span>被91人关注</span>，<span>获得了293个喜欢</span>
          </div>
        </div>
        <h1 class="title">如何成为一个黑客？</h1>
        <div class="meta-top">
          <span class="wordage">字数1878</span>
          <span class="views-count">阅读1378</span>
          <span class="comments-count">评论20</span>
          <span class="likes-count">喜欢49</span>
        </div>

        <!-- Collection/Bookmark/Share for width under 768px -->
        <div class="article-share"></div>
        <!-- -->

        <div class="show-content">
            <p><b>很多人要成为高大上的黑客需要学习哪些基本功？</b></p>
        </div>
      </div>
    </div>

  </div>
</template>
 ```

### Vuex
自我感觉作为Vue系列里最重要的一环Vuex，它的诞生解决了各组件的之间的数据通信问题。它将组件共享的数据状态抽取出来，以一个全局单例模式管理，它所提供的单向数据流使得组件之间的状态变得很容易维护。

![vuex单向数据流](http://p0.meituan.net/dpnewvc/1532121bd9eda41196deb676f9572e84143104.png)

上面的数据流向图表示：

 - 整个store中的数据定义在一个state中
 - 可以通过getters对state中的数据进行读取
 - state中的数据只能通过mutations进行更改
 - 在actions中可以提交mutations，而且在actions中可以完成异步操作

#### store.js
store.js作为vuex的核心文件，从这个文件中export出一个vuex实例

```
import Vue from 'vue'
import Vuex from 'vuex'

//引入getters与actions
import * as getters from './getters'
import * as actions from './actions'
import mutations from './mutations'

//注册vuex
Vue.use(Vuex)  

//定义各组件需要进行通信的数据
const state = {
    show: 'hot',
    loginway: 'login',
    hotArticles: [{
        author: '小熊猫',
        title: '每天努力多一点点',
        time: '大约6小时前',
        read: '7231',
        comment: '247',
        like: '2341',
        pay: '2',
        src: 'url(../../static/images/vue-demo-hot.jpg)'
    }, {
        author: '大熊猫',
        title: '每天前进一点点',
        time: '大约6小时前',
        read: '7231',
        comment: '247',
        like: '2341',
        pay: '2',
        src: 'url(../../static/images/vue-demo-hot.jpg)'
    }]
}

//导出vuex的实例，其中包含state，mutations，getters，actions
export default new Vuex.Store({
    state,
    mutations,
    getters,
    actions
})

```

#### getters.js

getters.js用来获取state中的数据，可以认为是store中的计算属性，每个方法都会接收一个state对象作为参数

```
export const getShow = state => state.show

export const getArticles = state => state.articles

export const getTopicArticles = state => state.topicArticles

export const getBonus = state => state.texts

export const getLoginway = state => state.loginway

export const getArticleFlag = state => state.articleFlag
```

#### mutations.js

mutations.js用于修改state中的数据状态，vuex中的mutations类似于事件，每个mutation都有一个字符串的事件类型（type）和一个回调函数（handler）。在其回调函数中接收state作为第一个参数，还可以传入额外的参数，称为载荷（payload）。

不能直接调用一个mutation的handler，而是应该用commit方法去触发该mutation。

```
export default {
    DISPLAY_ARTICLES (state, type) {
        state.show = type
        state.articles = state[type + 'Articles']
    },
    DISPLAY_TOPIC (state, type) {
        state.show = type
        state.topicArticles = state[type + 'TopicArticles']
    },
    SORT_CONTENT (state, type) {

    },
    CHANGE_LOGINWAY (state, loginway) {
        state.loginway = loginway
    },
    CHANGE_ARTICLEFLAG (state, flag) {
        state.articleFlag = flag
    }
}
```

#### actions.js

Action提交的是mutation，而不是直接更改数据状态，而且在Action中可以包含任意的异步操作。Action函数接收一个与store实例具有相同方法和属性的context对象，因此可以调用context.commit提交mutation，或者通过context.getters，context.state来获取store的getters和state。

Action通过store.dispatch方法触发，由于mutation必须同步执行的限制，所以如果需要执行异步操作用Action将会非常方便

```
export const displayArticles = ({commit}, type) => {
    commit('DISPLAY_ARTICLES', type)
}

export const displayTopic = ({commit}, type) => {
    commit('DISPLAY_TOPIC', type)
}

export const sortContent = ({commit}, type) => {
    commit('SORT_CONTENT', type)
}

export const changeLoginway = ({commit}, loginway) => {
    commit('CHANGE_LOGINWAY', loginway)
}

export const changeArticleFlag = ({commit}, flag) => {
    commit('CHANGE_ARTICLEFLAG', flag)
}
```

#### vuex在组件中的调用

上面定义好vuex各个部分，接下来看怎么在各个组价中进行调用。vuex1.0与vuex2.0在组件中的调用也有不同，在vuex1.0中，export default {}可以使用vuex属性，该属性包含getters和actions等参数。vuex1.0版本的.vue文件script标签内容类似于：

```
import { displayArticle} from '../vuex/actions'
export default{
    vuex: {
        getters: {
            show: state => state.show
        },
        actions: {
            displayArticle
        }
    }
}
```

在vuex2.0版本中废弃了这种方法，而是采用类似于下面的方法，这里也选取几个比较典型的页面

- App.vue

 ```
 <script>
  //在vuex2.0中提供mapGetters用于获取getters中的内容，接收一个key: value类型的对象
  import { mapGetters } from 'vuex'

  export default {
      data () {
          return {
              show: 'home'
          }
      },
      //mapGetters接收的参数表示，页面上定义的变量articleFlag通过getters的getArticleFlag方法来获取
      computed: mapGetters({
          articleFlag: 'getArticleFlag'
      }),
      methods: {
           //每个组件可以通过this.$store获取vuex的store，然后可以通过dispatch方法来触发一个action，
           //在action中接收一个loginway参数
          changeLoginway (loginway) {
              this.$store.dispatch('changeLoginway', loginway)
          }
      }
  }
</script>
 ```
 
- Home.vue
 
  ```
  <script>
    import { mapGetters } from 'vuex'

    export default {
        //mapGetters中接收的参数表示，在页面上定义的show参数通过getters的getShow方法来获取
        computed: mapGetters({
            show: 'getShow'
        }),
        methods: {
            //该方法表示触发store的actions中的displayArticles
            displayArticles (type) {
                this.$store.dispatch('displayArticles', type)
            }
        },
        //页面加载完后，触发store的actions中的displayArticles和changeArticleFlag
        mounted () {
            this.$store.dispatch('displayArticles', 'hot')
            this.$store.dispatch('changeArticleFlag', true)
        }
    }

 </script>
  ```
  
- ArticleList.vue

 ```
 <script>
    import { mapGetters } from 'vuex'

    export default {
        //计算属性articles通过store的getters中的getArticles方法获取
        computed: mapGetters({
            articles: 'getArticles'
        }),
        mounted () {
            this.$store.dispatch('changeArticleFlag', true)
        }
    }

 </script>
 ``` 
 
在其他页面中也都采用类似的方式编写，所以就不一一赘述。
本文暂且写到这里，后续会对项目继续进行完善，而且接入后端server，打造前后端连通的系统

### 参考资料
- Vue2.0中文文档：[https://vuefe.cn/v2/guide/](https://vuefe.cn/v2/guide/)
- Vue-router2.0中文文档：[https://gongph.gitbooks.io/vue-router-2/content/](https://gongph.gitbooks.io/vue-router-2/content/)
- Vuex2.0中文文档：[https://vuex.vuejs.org/zh-cn/](https://vuex.vuejs.org/zh-cn/)
- webpack中文文档：[https://chenyiqiao.gitbooks.io/webpack/content/](https://chenyiqiao.gitbooks.io/webpack/content/)
- webpack英文文档：[https://webpack.github.io/docs/configuration.html](https://webpack.github.io/docs/configuration.html)
- express使用指南：[http://javascript.ruanyifeng.com/nodejs/express.html#toc1](http://javascript.ruanyifeng.com/nodejs/express.html#toc1)

	
