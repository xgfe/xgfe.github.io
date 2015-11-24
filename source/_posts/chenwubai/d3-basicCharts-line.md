title: 基于D3.js的折线图的实现
date: 2015-11-23 15:00:00
categories: chenwubai
tags:
- 数据可视化
- svg  
- D3.js
---

&emsp;&emsp;在[《基于D3.js的柱状图的实现》](http://xgfe.github.io/blog/2015/11/23/chenwubai/d3-basicCharts-bar/#more)中已经介绍过如何用D3.js来实现一个简单的柱状图了。现在就让这道新世界的大门再打开一些，我们来用D3.js来实现折线图。  
<!-- more -->        
&emsp;&emsp;折线图由坐标轴、线条和点组成。和实现柱状图一样，我们还是先把大概的画图框架搭起来，代码如下（别忘了添加D3.js）：  

	<!DOCTYPE html>
	<html lang="en">
		<head>
		    <meta charset="UTF-8">
		    <title>折线图</title>
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
  
## 坐标轴的实现
&emsp;&emsp;要创建坐标轴，需要先创建比例尺。在《基于D3.js的柱状图的实现》中提到过序数比例尺和线性比例尺，因为折线的点与点之间是存在连续的关系的，所以折线图的x轴和y轴我们都采用线性比例尺。   
 
	// 模拟数据
	var dataset = [
	    {x: 0, y: 11}, {x: 1, y: 35},
	    {x: 2, y: 23}, {x: 3, y: 78},
	    {x: 4, y: 55}, {x: 5, y: 18},
	    {x: 6, y: 98}, {x: 7, y: 100},
	    {x: 8, y: 22}, {x: 9, y: 65}
	];
	// 创建x轴的比例尺(线性比例尺)
	var xScale = d3.scale.linear()
	        .domain(d3.extent(dataset, function(d) {
	            return d.x;
	        }))
	        .range([0, width - padding.left - padding.right]);
	// 创建y轴的比例尺(线性比例尺)
	var yScale = d3.scale.linear()
	        .domain([0, d3.max(dataset,function(d) {
	            return d.y;
	        })])
	        .range([height - padding.top - padding.bottom, 0]);
	// 创建x轴
	var xAxis = d3.svg.axis()
	        .scale(xScale)
	        .orient('bottom');
	// 创建y轴
	var yAxis = d3.svg.axis()
	        .scale(yScale)
	        .orient('left');
	// 添加SVG元素并与x轴进行“绑定”
	main.append('g')
	        .attr('class', 'axis')
	        .attr('transform', 'translate(0,' + (height - padding.top - padding.bottom) + ')')
	        .call(xAxis);
	// 添加SVG元素并与y轴进行“绑定”
	main.append('g')
	        .attr('class', 'axis')
	        .call(yAxis);  
            
&emsp;&emsp;这次我们模拟了一些点的数据来进行折线的绘制。[d3.scale.linear()](https://github.com/mbostock/d3/wiki/Quantitative-Scales#linear)创建了线性比例尺，[linear.domain()](https://github.com/mbostock/d3/wiki/Quantitative-Scales#linear_domain)定义定义域，[linear.range()](https://github.com/mbostock/d3/wiki/Quantitative-Scales#linear_range)定义值域。这里需要注意一下，因为SVG画布的y轴与传统认知上的y轴的方向是反着来的，所以在定义y轴的定义域和值域对应关系时，也需要反着来。[d3.extent](https://github.com/mbostock/d3/wiki/Arrays#d3_extent)可以得到参数数组中的最大值和最小值，并以数组的形式返回。然后用[d3.svg.axis()](https://github.com/mbostock/d3/wiki/SVG-Axes#axis)创建了两个坐标轴，把比例尺应用到它们上面，并且用[axis.orient()](https://github.com/mbostock/d3/wiki/SVG-Axes#orient)设置了坐标轴的刻度尺的方向。最后，添加SVG元素，用[call()](https://github.com/mbostock/d3/wiki/Selections#call)把定义好的坐标轴与SVG元素联系起来。通过设置它们的transform属性来移动元素，使它们看起来像是一个坐标系。  
<img src="/blog/uploads/chenwubai/d3-basicCharts-line/axis-line.png" width="320" height="160" /> 
## 折线的实现  
&emsp;&emsp;在D3.js中，需要先创建一个线的函数，然后由该函数得出的值赋给代表折线的path元素的d属性，才能绘制出折线。需要明确，line是一个函数，不是一个对象。具体的代码如下：

	// 添加折线
	var line = d3.svg.line()
	        .x(function(d) {
	            return xScale(d.x)
	        })
	        .y(function(d) {
	            return yScale(d.y);
	        })
	        // 选择线条的类型
	        .interpolate('linear');
	// 添加path元素，并通过line()计算出值来赋值
	main.append('path')
	        .attr('class', 'line')
	        .attr('d', line(dataset));
&emsp;&emsp;这样做了以后，我们得到了如下图所示的一条线。  
<img src="/blog/uploads/chenwubai/d3-basicCharts-line/lineShape.png" width="320" height="160" />  
## 点的实现
&emsp;&emsp;点其实就是一个个的圆，所以在这里我们用SVG里的circle元素来画点。  

	// 添加点
	main.selectAll('circle')
	        .data(dataset)
	        .enter()
	        .append('circle')
	        .attr('cx', function(d) {
	            return xScale(d.x);
	        })
	        .attr('cy', function(d) {
	            return yScale(d.y);
	        })
	        .attr('r', 5)
	        .attr('fill', function(d, i) {
	            return getColor(i);
	        });
&emsp;&emsp;在main元素中选择到所有的圆先“占位”（因为此时选择到的是一个空的集合，只是这个集合代表main中所有的圆），然后绑定dataset到此集合上，通过[enter()](https://github.com/mbostock/d3/wiki/Selections#enter)和append()搭配使用添加新的circle元素直到集合元素个数与dataset子元素个数相同为止。用比例尺计算出各圆的坐标并对其相关属性进行赋值，就完成了点的添加。  
<img src="/blog/uploads/chenwubai/d3-basicCharts-line/line.png" width="320" height="160" />
&emsp;&emsp;完整的代码和例子展示请移步line.html。
