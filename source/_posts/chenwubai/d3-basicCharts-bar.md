title: 基于D3.js的柱状图的实现
date: 2015-11-23 00:00:00
categories: chenwubai
tags:
- 数据可视化
- svg  
- D3.js
---

&emsp;&emsp;数据可视化一直是前端领域中不容忽略的一块领域。简而言之，数据可视化就是借助图形化的手段把生硬的数据生动化，以此来展示出数据想要表达的信息。而图表是大家最最最通常的一种数据可视化手段，可全靠自己纯手动编写各种图表实在是让人头疼，各种计算各种烦。没事儿，现在就为大家打开一道新世界的大门——用D3.js来实现柱状图。  
<!-- more -->  

## [D3.js](http://d3js.org/)是什么？  
&emsp;&emsp;首先，我们来看一下D3.js是什么，官方首页的介绍是这样的。  
  > D3.js is a JavaScript library for manipulating documents based on data. D3 helps you bring data to life using HTML, SVG, and CSS. D3’s emphasis on web standards gives you the full capabilities of modern browsers without tying yourself to a proprietary framework, combining powerful visualization components and a data-driven approach to DOM manipulation.  

&emsp;&emsp;由此可见(英文不好？怪我咯~)，D3.js是一个帮助开发者操纵基于数据的文档的JavaScript类库。这里也可以看到它是用SVG来呈现图表的，所以使用D3.js是需要一定的SVG基础的。    

## 如何实现？  
&emsp;&emsp;柱状图里面有坐标轴和柱子。然而我们还需要SVG画布来画这些东西。先把大概的画图框架搭起来，代码如下（请注意此时我在body标签里添加了D3.js的script标签。这样我们后面才能使用D3的方法）：  

	<!DOCTYPE html>
	<html lang="en">
		<head>
		    <meta charset="UTF-8">
		    <title>柱状图</title>
		    <style>
		        .container {
		            margin: 30px auto;
		            width: 600px;
		            height: 300px;
		            border: 1px solid #000;
		        }
		    </style>
		</head>
		<body>
		    <div class="container">
		        <svg width="100%" height="100%"></svg>
		    </div>
		    <script src="http://d3js.org/d3.v3.min.js" charset="utf-8"></script>
		    <script>
        	<script>
	        	window.onload = function() {
	            	var width = 600, height = 300;
	            	// SVG画布边缘与图表内容的距离
	            	var padding = { top: 50, right: 50, bottom: 50, left: 50 };
	            	// 创建一个分组用来组合要画的图表元素
	            	var main = d3.select('.container svg').append('g')
        				// 给这个分组加上main类
	                    .classed('main')
                		// 设置该分组的transform属性
	                    .attr('transform', "translate(" + padding.top + ',' + padding.left + ')');
	        	};
    		</script>
		</body>
	</html>
  
### 坐标轴的实现
&emsp;&emsp;为了把真实的数据与SVG画布上的坐标轴上的坐标联系起来，我们需要定义比例尺来描述这样的对应关系。D3中常用的比例尺有线性比例尺和序数比例尺，它们的区别如图所示：   
<img src="/uploads/chenwubai/d3-basicCharts-bar/ordinalAndLinear.png" width="720" height="120" />  
&emsp;&emsp;从图上可以看出，线性比例尺的对应关系是连续的，而序数比例尺的对应关系是离散的。分析柱状图的展现意义可以得出x轴应该选用序数比例尺，而y轴选用线性比例尺。   

	// 模拟数据
    var dataset = {
        x: ["赵","钱","孙","李","周","吴","郑","王"],
        y: [40, 30, 50, 70, 90, 20, 10, 40]
    };
    // 定义x轴的比例尺(序数比例尺)
    var xScale = d3.scale.ordinal()
            .domain(dataset.x)
            .rangeRoundBands([0, width - padding.left - padding.right],0,0);
    // 定义y轴的比例尺(线性比例尺)
    var yScale = d3.scale.linear()
            .domain([0, d3.max(dataset.y)])
            .range([height - padding.top - padding.bottom, 0]);
    // 定义x轴和y轴
    var xAxis = d3.svg.axis()
            .scale(xScale)
            .orient('bottom');
    var yAxis = d3.svg.axis()
            .scale(yScale)
            .orient('left');
    // 添加坐标轴元素
    main.append('g')
            .attr('class', 'axis')
            .attr('transform', 'translate(0,' + (height - padding.bottom - padding.top) + ')')
            .call(xAxis);
    main.append('g')
            .attr('class', 'axis')
            .call(yAxis);  
            
&emsp;&emsp;我们模拟了一些数据，每个姓氏对应了一个数值（从这里也可以看出序数比例尺的定义域上的值不一定是连续关系）。[d3.scale.ordinal()](https://github.com/mbostock/d3/wiki/Ordinal-Scales#ordinal)创建了一个序数比例尺，而[ordinal.domain()](https://github.com/mbostock/d3/wiki/Ordinal-Scales#ordinal_domain)设置了该比例尺的定义域，[ordinal.rangRoundBands()](https://github.com/mbostock/d3/wiki/Ordinal-Scales#ordinal_rangeRoundBands)设置了值域。同理，[d3.scale.linear()](https://github.com/mbostock/d3/wiki/Quantitative-Scales#linear)创建了一个线性比例尺，[linear.domain()](https://github.com/mbostock/d3/wiki/Quantitative-Scales#linear_domain)定义定义域，[linear.range()](https://github.com/mbostock/d3/wiki/Quantitative-Scales#linear_range)定义值域。接着，我们用[d3.svg.axis()](https://github.com/mbostock/d3/wiki/SVG-Axes#axis)创建了两个坐标轴，把比例尺应用到它们上面，并且用[axis.orient()](https://github.com/mbostock/d3/wiki/SVG-Axes#orient)设置了坐标轴的刻度尺的方向。最后，添加SVG元素，用[call()](https://github.com/mbostock/d3/wiki/Selections#call)把定义好的坐标轴与SVG元素联系起来。通过设置它们的transform属性来移动元素，使它们看起来像是一个坐标系。  

这里需要注意以下几点：  
- ordinal.domain的参数是一个表示一系列值的数组，而linear.domain的参数是一个表示范围的数组。  
- 比例尺的本质是一个函数，它接收定义域上的值来得出对应的值域上的值。  

&emsp;&emsp;应用序数比例尺的坐标轴与线性比例尺的有很大不同，这里大概说明一下。  
<img src="/uploads/chenwubai/d3-basicCharts-bar/ordinal.range.png" width="660" height="260" />  
&emsp;&emsp;rangeRoundBands(interval, padding, outerPadding)中的padding和outerPadding都是可选的，默认为0。如上图所示的比例尺的代码是这样的。  
	
	var o = d3.scale.ordinal()
		.domain([0, 1, 2])
		.rangeRoundBands([0, 100], 0.4, 0.1);
&emsp;&emsp;domain的参数数组有多少个元素，就会有多少个rangeBand，rangeBand之间的间隔为padding\*step（padding取值范围为0到1），它与rangeBand的关系是均分一个step，比如padding为0.4，则rangeBand的长度为0.6\*step。根据上述代码可得最终坐标轴的长度等于(0.1 + 2 + 0.6 + 0.1) * step，由此算出step的长度，再推出外间距、rangeBand、内间距的长度。而定义域上的取值刻度定位在每个rangeBand的中间。于是得到了示意图中的坐标轴（红色标注）。  

&emsp;&emsp;我们接着来画柱状图，给坐标轴设置一下样式：  

	.axis path,
	.axis line {
        stroke: #000;
        fill: none;
    }
&emsp;&emsp;最终得到的柱状图的坐标轴如下图所示：  
<img src="/uploads/chenwubai/d3-basicCharts-bar/axis-bar.png" width="320" height="160" />
### 柱子的实现  
&emsp;&emsp;柱子无非就是一个个矩形，在SVG中可以使用rect元素来画。先选择到main下所有bar类的元素（此时选择到的是一个空的集合），把dataset.y绑定到这个集合上，用[enter()](https://github.com/mbostock/d3/wiki/Selections#enter)对比绑定的数组元素个数与集合中的SVG元素个数，与[append()](https://github.com/mbostock/d3/wiki/Selections#append)搭配使用，会自动补齐至两边个数相等。每一次的append都对应dataset.y中的一个数组元素。利用前面创建的比例尺函数计算出值并赋给举行元素的x、y属性。具体的代码如下：

	// 矩形之间的间距
    var rectMargin = 10;
    // 添加矩形
    main.selectAll('.bar')
            .data(dataset.y)
            .enter()
            .append('rect')
            .attr('class', 'bar')
            .attr('x', function(d, i) {
                return xScale(dataset.x[i]) + rectMargin;
            })
            .attr('y', function(d, i) {
                return yScale(d);
            })
            .attr('width', xScale.rangeBand() - 2*rectMargin)
            .attr('height', function(d, i) {
                return height - padding.top - padding.bottom - yScale(d);
            })
            .attr('fill', function(d, i) {
                return getColor(i);
            });
&emsp;&emsp;至此，得到了如下图所示的柱状图。  
<img src="/uploads/chenwubai/d3-basicCharts-bar/bar.png" width="320" height="160" />

&emsp;&emsp;完整的代码和例子展示请移步[bar.html](/uploads/chenwubai/d3-basicCharts-bar/bar.html)。
