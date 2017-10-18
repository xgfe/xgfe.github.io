title: 基于IntersectionObserver的曝光统计测试
date: 2017-10-18 17:23:00
categories: lulutia
tags: 
- data
---
本文主要介绍了IntersectionObserver API，并且就如何将其用于数据埋点给出了尝试。

<!-- more -->

#### 背景介绍
  作为一款产品，往往希望能得到用户的反馈，从而通过对用户行为的分析进行功能、交互等方方面面的改进。然而直接的一对一的用户交流是低效且困难的，因此最普遍的做法便是通过数据埋点来反推用户的行为。那么数据埋点中很重要的一环便是：曝光。
  所谓曝光，便是页面被展示的时候进行打点。举个简单的例子：用户进入分类页面，商品以行为单位从上而下进行排列。当用户滚动页面时，之前不在视窗范围内的商品就会出现，此时，这部分商品就算曝光了。需要进行一次记录。
  那么为了实现上面功能，最普遍的做法有两个。其一：跟踪滚动事件，然后计算某个商品与视窗的相对位置，从而判断是否可见。其二：维持一个timer，然后以固定的时间为间隔计算某个商品与视窗的相对位置。
  上面两种做法在某种程度上能够实现我们的目的，但是会有一些问题，比如最明显的：慢。因为计算相对位置时会调用getBoundingClientRect()，这个操作会导致浏览器进行全页面的重新布局，不用我说，大家都知道这个性能开销是很大的，特别是在频繁进行时。除此之外，如果页面是作为一个iframe包裹的也会产生问题，因为同源策略和浏览器不会允许你获取包裹iframe的页面的数据。然而在现有情况下，很多广告都是通过iframe的形式镶嵌在网页内的。
  基于以上的情况，我们急需一种性能良好且iframe友好的方式来实现曝光的功能，因此IntersectionObserver API进入了我们的视野。
#### IntersectionObserver API介绍
关于IntersectionObserver API的官方文档[见此](https://w3c.github.io/IntersectionObserver/)。截止本文为止，其兼容性如下图所示:
![API 兼容性](http://okzzg7ifm.bkt.clouddn.com/IntersectionObserver.png)简单的说IntersectionObserver让你知道什么时候observe的元素进入或者存在在root区域里了。下面我们来看下这个API的具体内容:

```js
// 用构造函数生成观察者实例，回调函数是必须的，后面的配置对象是可选的
var observer = new IntersectionObserver(changes => {
  for (const change of changes) {
    console.log(change.time);               // 相交发生时经过的时间
    console.log(change.rootBounds);         // 表示发生相交时根元素可见区域的矩形信息，是一个对象值
    console.log(change.boundingClientRect); // target.boundingClientRect()发生相交时目标元素的矩形信息，也是个对象值
    console.log(change.intersectionRect);   // 根元素与目标元素相交时的矩形信息
    console.log(change.intersectionRatio);  // 表示相交区域占目标区域的百分比，是一个0到1的值
    console.log(change.target);             // 相交发生时的目标元素
  }
}, {
	root: null,
  	threshold: [0, 0.5, 1],
  	rootMargin: "50px"
});

// 实例属性
observer.root

observer.rootMargin

observer.thresholds

// 实例方法
observer.observe(target); // 观察针对某个特定元素的相交事件

observer.unobserve(target); // 停止对某个特定元素的相交事件的观察

observer.disconnect(); // 停止对所有目标元素的阈值事件的观察，简单的说就是停用整个IntersectionObserver

// 除了上面三个实例方法，还有一个takeRecords()的方法，之后会详细介绍
```
IntersectionObserver API允许开发人员了解目标dom元素相对于intersection root的可见性。这个root可以通过实例属性获取。默认情况下它为null，此时它不是真正意义上的元素，它指视窗范围，因此只要视窗范围内的目标元素(当然是后代元素)滚入视窗时，就会触发回调函数[如果root元素不存在了，则执行其任何的observe都会出错]。下面举个栗子:

```js
<!DOCTYPE html>
<html lang="en">
	<head>
		<meta charset="utf-8" />
		<title>intersectionObserve</title>
		<style type="text/css">
			#target {
			   position: relative;
			   top: calc(100vh + 500px);
			   width: 100px;
			   height: 100px;
			   background: red;
			}
		</style>
	</head>
	<body>
		<div id="target"></div>
		<script type="text/javascript">
			let ele = new IntersectionObserver(
				(entries) => {
			  		console.log(entries);
			  }
			);

			ele.observe(target);
		</script>
	</body>
</html>
```
上面的栗子中，当红色的块滚入滚出视窗，都会触发回调函数，回调函数在调用时会传入一个由IntersectionObserverEntry 对象组成的数组。每个IntersectionObserverEntry 对象包含对应的observed元素的更新信息，大概数据结构如下，其具体意思在第一段代码里有详细说明:
![](http://okzzg7ifm.bkt.clouddn.com/intersectionObject.png)
我们可以在配置对象中将root改为具体的元素，此时当目标元素出现在root元素中时会触发回调，注意，在这种情况下相交可能发生在视窗下面。具体代码在下，感兴趣的孩子可以试一下:

```js
<!DOCTYPE html>
<html lang="en">
	<head>
		<meta charset="utf-8" />
		<title>intersectionObserve</title>
		<style type="text/css">
			#root {
				position: relative;
				width: 400px;
				height: calc(100vh + 200px);
				background: lightblue;
				overflow: scroll;
			}
			#target {
			   position: absolute;
			   top: calc(100vh + 800px);
			   width: 100px;
			   height: 100px;
			   background: red;
			}

		</style>
	</head>
	<body>
		<div id="root">
			<div id="target"></div>
		</div>
		<script type="text/javascript">
			let ele = new IntersectionObserver(
				(entries) => {
			  		console.log(entries);
			  }, {
			  	root: root
			  }
			);

			ele.observe(target);
		</script>
	</body>
</html>
```
在上面一条中，回调函数打印出来的对象中有一个intersectionRatio值，这个值其实涉及到了整个API的核心功能：当目标元素和根元素相交的面积占目标元素面积的百分比到达或跨过某些指定的临界值时就会触发回调函数。因此相对的在配置对象里有一个threshold来对这个百分比进行配置，默认情况下这个值是[0]，注意里面的值不能在0-1之外，否则会报错。我们举个栗子如下:

```js
......
let ele = new IntersectionObserver(
	(entries) => {
  		console.log(entries);
  }, {
  	threshold: [0, 0.5, 1.0]
  }
);

ele.observe(target);

```
在上面这个栗子中，我们设定了0，0.5，1.0这三个值，因此当交叉区域跨越0，0.5，1.0时都会触发回调函数。注意我这边的用词是跨越，而不是到达。因为会存在以下两种情况导致回调打印出来的intersectionRatio不为0，0.5和1.0.
其一： 浏览器对相交的检测是有时间间隔的。浏览器的渲染工作都是以帧为单位的，而IntersectionObserver是发生在帧里面的。因此假如你设定了[0,0.1,0.2,0.3,0.4,0.5]这个threshold，但是你的滚动过程特别快，导致所有的绘制在一帧里面结束了，此时回调只会挑最近的临界值触发一次。
其二： IntersectionObserver是异步的。在浏览器内部，当一个观察者实例观察到众多的相交行为时，它不会立即执行。关于IntersectionObserver的草案里面写明了其实现是基于requestIdleCallback()来异步的执行我们的回调函数的，并且规定了最大的延迟时间是100ms。关于这部分涉及到前面第一段代码里的一个实例方法takeRecords()。如果你很迫切的希望马上知道是否有相交，你不希望等待可能的100ms，此时你就能调用takeRecords()，此后你能马上获得包含IntersectionObserverEntry 对象的数组，里面有相交信息，如果没有任何相交行为发生，则返回一个空数组。但这个方法与正常的异步回调是互斥的，如果它先执行了则正常回调里面就没信息了，反之亦然。
除开上面的问题，如果目标元素的面积为0会产生什么情况呢？因为与0计算相交率是没有意义的，实际我们举个栗子：

```js
<!DOCTYPE html>
<html lang="en">
	<head>
		<meta charset="utf-8" />
		<title>intersectionObserve</title>
		<style type="text/css">
			#target {
			   position: relative;
			   top: calc(100vh + 500px);
			   width: 100px;
			   height: 100px;
			   background: red;
			}
		</style>
	</head>
	<body>
		<div id="target"></div>
		<div id="img"></div>
		<script type="text/javascript">
			let ele = new IntersectionObserver(
				(entries) => {
			  		console.log(entries);
			  }, {
			  	threshold: [0, 0.5, 1.0]
			  }
			);

			ele.observe(img);
		</script>
	</body>
</html>
```
我们会看到，虽然我们设定了0.5这个阈值，但实际回调只会在0与1.0时触发。这是一种特殊的处理方式。

上面我们讨论了整个API的核心功能，实际其内部遵循的逻辑如下: 每个观察者实例为所有的目标元素都维护着上次的相交率(previousThreshold)，在新执行Observe的时候会将previousThreshold置为0，之后每次检测到满足threshold的相交率，并且与previousThreshold不同，那么就会触发回调并将previousThreshold重置为这个新值。那么这里可能会有下面几个问题：
其一：既然初始值是0，如果阈值设置为0，且刚刚满足滚动到0的位置，回调还会触发吗？实际是会的，这是一种特例，与目标元素在根元素内部(此时相交率为1)滚动到刚刚要超出的位置依然会触发回调函数一样。但是这种情况可能导致一个问题，我们无法直接用intersectionRatio>0来判断目标是否滚入了根元素，因为在慢速滚动下，当目标元素的上边与根元素的下边相交时，此时intersectionRatio=0并且触发了回调，之后当intersectionRatio>0时并不会触发回调了(这里排除还有其他自定义阈值的情况)。这种情况下，可以自定义一个变量值来存展示状态，或者也可以定义一个无限接近0的threshold.
其二：如果一个元素初始化就在根元素内部了，然后再执行observe，依然会触发回调吗？会的，因为初始值默认为0，在下一次检测时更新为了实际的相交值。

这里需要强调一点的是，我们的目标元素在Observe的时候可以不存在的[注意这里的不存在是指没有插入dom结构，但是元素本身是需要存在的]，只需要在相交发生时存在就行了，我们来举个栗子：

```js
<!DOCTYPE html>
<html lang="en">
	<head>
		<meta charset="utf-8" />
		<title>intersectionObserve</title>
		<style type="text/css">
			#target {
			   position: relative;
			   top: calc(100vh + 500px);
			   width: 100px;
			   height: 100px;
			   background: red;
			}
		</style>
	</head>
	<body>
		<div id="target"></div>
		<script type="text/javascript">
			let ele = new IntersectionObserver(
				(entries) => {
			  		console.log(entries);
			  }, {
			  	threshold: [0, 0.5, 1.0]
			  }
			);

			let img = document.createElement('div');
			ele.observe(img);
			setTimeout(() => {
				document.body.appendChild(img);
			}, 5000);
		</script>
	</body>
</html>
```
同理，如果目标元素与根元素处于相交状态，但是在一段时间后目标元素不存在了(比如remove，或者display:none)了，那么此时依然会触发一次回调。但是如果本身就不处于相交状态，然后消失掉了，因为0->0没有变化，所以不会触发回调，具体如下面的栗子所示：

```js
<!DOCTYPE html>
<html lang="en">
	<head>
		<meta charset="utf-8" />
		<title>intersectionObserve</title>
		<style type="text/css">
			#target {
			   position: relative;
			   top: calc(100vh + 500px);
			   width: 100px;
			   height: 100px;
			   background: red;
			}
		</style>
	</head>
	<body>
		<div id="target"></div>
		<script type="text/javascript">
			let ele = new IntersectionObserver(
				(entries) => {
			  		console.log(entries);
			  }
			);

			ele.observe(target);
			setTimeout(() => {
				document.body.removeChild(target);
			}, 5000);
		</script>
	</body>
</html>
```
#### IntersectionObserver API与iframe
互联网上的很多小广告都是通过iframe嵌入的，而上面我们也说了现有的情况下很难获取iframe在顶层视窗内的曝光，但是使用IntersectionObserver API我们却可以做到这点。下面举个栗子：

```js
<!DOCTYPE html>
<html lang="en">
	<head>
		<meta charset="utf-8" />
		<title>intersectionObserve</title>
		<style type="text/css">
			#root {
			   position: relative;
			   top: calc(100vh + 800px);
			   width: 100px;
			   height: 100px;
			}
			#iframe {
				width: 600px;
				height: 600px;
				margin-bottom: 300px;
			}
		</style>
	</head>
	<body>
		<div id="root">
  			<iframe id="iframe"></iframe>
		</div>
		<script>
		  let iframeTemplate = `
		    <div id="target"><p>i am iframe</p></div>
		    <style>
		      #target {
		        width: 500px;
		        height: 500px;
		        background: red;
		      }
		      #target p {
		      	font-size: 90px;
		      }
		    </style>
		    <script>
		      let observer = new IntersectionObserver((entries) => {
		        console.log(entries)
		      }, {
		      	threshold: [0,0.5,1.0]
		      })
		      observer.observe(target)
		    <\/script>`

		  iframe.src = URL.createObjectURL(new Blob([iframeTemplate], {"type": "text/html"}))
		</script>
	</body>
</html>
```
从上面的栗子可以看出，使用此API不仅能够使iframe在视窗内出现时触发回调，而且threshold值同样能够起作用。这样一来，大大简化了此类情况下获取曝光的难度。

#### 延迟加载与无限滚动
上面我们关于配置参数已经提到了root和threshold，实际上还有一个值：rootMargin。这个值实际就是给根元素添加了一个假想的margin值。其使用场景最普遍的是用于延迟加载。因为如果真的等目标元素与根元素相交的时候再进行加载图片等功能就已经晚了，所以有一个rootMargin值，这样等于根元素延伸开去了，目标元素只要与延伸部分相交就会触发回调，下面我们来继续举个栗子:

```js
<!DOCTYPE html>
<html lang="en">
	<head>
		<meta charset="utf-8" />
		<title>intersectionObserve</title>
		<style type="text/css">
			#root {
				width: 500px;
				height: 800px;
				overflow: scroll;
				background-color: pink;
			}
			#target {
			   position: relative;
			   top: calc(100vh + 500px);
			   width: 100px;
			   height: 100px;
			   background: red;
			}
		</style>
	</head>
	<body>
		<div id="root">
			<div id="target"></div>
		</div>
		<script type="text/javascript">
			let ele = new IntersectionObserver(
				(entries) => {
			  		console.log(entries);
			  }, {
			  	rootMargin: '100px',
			  	root: root
			  }
			);

			ele.observe(target);
		</script>
	</body>
</html>
```
很明显，在上面的栗子中，目标元素并没有出现在根元素的视窗里的时候就已经触发回调了。

整个API可以用来实现无限滚动和延迟加载，下面就分别举出两个简单的栗子来启发思路，更完善健壮的功能就交给看官自己去尝试了哦：
延迟加载的栗子：

```js
<!DOCTYPE html>
<html lang="en">
	<head>
		<meta charset="utf-8" />
		<title>intersectionObserve</title>
		<style type="text/css">
			.img {
				height: 1000px;
				overflow-y: hidden;
			}
		</style>
	</head>
	<body>
		<ul>
			<li class="img">
				<img src="" class="img-item" data-src="http://okzzg7ifm.bkt.clouddn.com/cat.png"/>
			</li>
			<li class="img">
				<img src="" class="img-item" data-src="http://okzzg7ifm.bkt.clouddn.com/01.png"/>
			</li>
			<li class="img">
				<img src="" class="img-item" data-src="http://okzzg7ifm.bkt.clouddn.com/virtualdom.png"/>
			</li>
			<li class="img">
				<img src="" class="img-item" data-src="http://okzzg7ifm.bkt.clouddn.com/reactlife.png"/>
			</li>
		</ul>
		<script type="text/javascript">
			let ele = new IntersectionObserver(
				(entries) => {
			  		entries.forEach((entry) => {
			  			if (entry.intersectionRatio > 0) {
			  				entry.target.src = entry.target.dataset.src;
			  			}
			  		})
			  }, {
			  	rootMargin: '100px',
			  	threshold: [0.000001]
			  }
			);
			let eleArray = Array.from(document.getElementsByClassName('img-item'));
			eleArray.forEach((item) => {
				ele.observe(item);
			})
		</script>
	</body>
</html>
```
无限滚动的栗子:

```js
<!DOCTYPE html>
<html lang="en">
	<head>
		<meta charset="utf-8" />
		<title>intersectionObserve</title>
		<style type="text/css">
			.img {
				height: 1200px;
				overflow: hidden;
			}
			#flag {
				height: 20px;
				background-color: pink;
			}
		</style>
	</head>
	<body>
		<ul id="imgContainer">
			<li class="img">
				<img src="http://okzzg7ifm.bkt.clouddn.com/cat.png"/>
			</li>
			<li class="img">
				<img src="http://okzzg7ifm.bkt.clouddn.com/01.png"/>
			</li>
			<li class="img">
				<img src="http://okzzg7ifm.bkt.clouddn.com/virtualdom.png"/>
			</li>
			<li class="img">
				<img src="http://okzzg7ifm.bkt.clouddn.com/reactlife.png"/>
			</li>
		</ul>
		<div id="flag"></div>
		<script type="text/javascript">
			let imgList = [
				'http://okzzg7ifm.bkt.clouddn.com/immutable-coperation.png',
				'http://okzzg7ifm.bkt.clouddn.com/flexdirection.png',
				'http://okzzg7ifm.bkt.clouddn.com/immutable-exampleLayout.png'
			]
			let ele = new IntersectionObserver(
				(entries) => {
					if (entries[0].intersectionRatio > 0) {
						if (imgList.length) {
							let newImgli = document.createElement('li');
							newImgli.setAttribute("class", "img");
							let newImg = document.createElement('img');
							newImg.setAttribute("src", imgList[0]);
							newImgli.appendChild(newImg);
							document.getElementById('imgContainer').appendChild(newImgli);
							imgList.shift();
						}
					}

			  }, {
			  	rootMargin: '100px',
			  	threshold: [0.000001]
			  }
			);
			ele.observe(flag);
		</script>
	</body>
</html>

```
通篇看下来大家是不是感觉这个API还是很好玩的，然而因为其兼容性，所以使用区域还是受限的。基于此，规范制订者在github上发布了其[Polyfill](https://github.com/w3c/IntersectionObserver)，不过因为是Polyfill，所以在实现性能上肯定是比不上原生的。而且就其github来看，待解决的issue数量还是比较多的。

#### 具体集成到项目中【项目本身基于vue】
实际项目里面可能需要使用到曝光的地方相当的多，这里我们就首页进行了尝试，主要有以下几个问题需要解决：

*  实例的创建时间
*  observe()调用的时机
*  dom元素与埋点数据的关联

针对实例的创建时间，因为首页上需要划分区域进行曝光报告，因此我选择在整个页面的初始化的时候就进行实例的创建。同时，因为希望整个埋点的处理逻辑一致，在实例的回调里面进行了统一处理。具体如下：

```js
......
   this.ele = new IntersectionObserver((entries) => {
          entries.forEach((item) => {
            if (item.intersectionRatio > 0) {
              let node = item.target.querySelector('.need-data');
              console.log(node.attributes['code'].value);
            }
          })
        }, {
          threshold: [0.000001]
        });
```
observe()调用的时机，因为页面采用组件化的方式，在最初进行实例化的时候，需要的dom结构都是没有的。之后通过与后端进行数据，采用数据驱动进行页面渲染。因此在数据获取后在下一次DOM循环更新之后才进行observe()的调用。此时所需的dom结构都有了。

```js
this.$nextTick(() => {
            let newArray = Array.from(document.getElementsByClassName('need-data'));
            newArray.forEach((newItem) => {
              this.ele.observe(newItem);
            })
          })
```
dom元素与埋点数据的关联，因为之前的逻辑中我们的dom与业务数据耦合度不大，因此获取单纯的dom后无法获取需要上报的数据。同时我们希望这一块对于大部分的曝光需求能够进行逻辑统一。因此我们采取了最简单的方法，将需要上报的数据直接放在dom的一个属性中。因为这部分dom是组件化生成的一部分，所以逻辑上也是一致的。

```js
<div class="item-content clearfix" :class="'item-wrapper-type'+type" :code="needData.code">
....
</div>
```
基本进行这三个地方的改动后就能满足我们的大部分类型的需求了。其最后的结果如下:
![结果图](http://okzzg7ifm.bkt.clouddn.com/dataResult.png)
#### 利弊介绍
* 优
	* 性能比直接的监听scroll事件或者设置timer都好
	* 使用简单
	* 利用它的功能组合可以实现很多其他效果，比如无限滚动等
	* 对iframe的支持好
* 缺
	* 兼容性不好
	* 它不是完美像素与无延迟的，毕竟根本上是异步的。因此不适合做滚动动画
	
#### 参考
* [IntersectionObserver API](http://www.cnblogs.com/ziyunfei/p/5558712.html): 强烈推荐这篇文章，干货满满
* [Intersection Observer](https://w3c.github.io/IntersectionObserver/#intersection-observer-processing-model)
* [Intersection Observer API](https://developer.mozilla.org/en-US/docs/Web/API/Intersection_Observer_API)
* [Timing element visibility with the Intersection Observer API](https://developer.mozilla.org/en-US/docs/Web/API/Intersection_Observer_API/Timing_element_visibility)