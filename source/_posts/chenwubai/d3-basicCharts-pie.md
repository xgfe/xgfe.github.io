title: 基于D3.js的饼图的实现
date: 2015-11-24 14:00:00
categories: chenwubai
tags:
- 数据可视化
- svg  
- D3.js
---

&emsp;&emsp;在前面的几篇文章里，我已经介绍过怎样用柱状图、折线图、散点图和气泡图这四种基本图表。这四种图表都是有坐标轴的，现在来说一种没有坐标轴的图表——饼图。  
<!-- more -->       
&emsp;&emsp;还是和之前一样，我们先把简单的画图框架搭起来，添加SVG画布。但是这里需要注意的是，为了方便后面画饼图上的弧形，我们把组合这些元素的g元素移动到画布的中心：  

	<!DOCTYPE html>
	<html lang="en">
		<head>
		    <meta charset="UTF-8">
		    <title>饼图</title>
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
		        window.onload = function() {
		            var width = 600, height = 300;
		            // 创建一个分组用来组合要画的图表元素
		            var main = d3.select('.container svg').append('g')
		                    .classed('main', true)
		            	    // 注意这里和前面几种图表的差别
		                    .attr('transform', "translate(" + width/2 + ',' + height/2 + ')');
		
		        };
		    </script>
		</body>
	</html>   
## 模拟数据并转化  
&emsp;&emsp;为了画饼图，我们模拟了一些这样的数据。  

	// 模拟数据
	var dataset = [
	    {name: '购物', value: 983},
	    {name: '日常饮食', value: 300},
	    {name: '医药', value: 1400},
	    {name: '交通', value: 402},
	    {name: '杂费', value: 134}
	];
&emsp;&emsp;在柱状图等有坐标轴的图表中，我们通过创建合适的比例尺来将模拟好的数据转化成适合画图的数据，那在饼图里，又用什么来转化呢？看这里~  

	// 转换原始数据为能用于绘图的数据
	var pie = d3.layout.pie()
	                .sort(null)
	                .value(function(d) {
	                    return d.value;
	                });
	// pie是一个函数    
	var pieData = pie(dataset);
&emsp;&emsp;[layout](https://github.com/mbostock/d3/wiki/Layouts)叫做布局，在D3.js中它提供了一些转化成特定图表数据的函数，如其中就包括饼图。它提供一个基础的转化函数，在此基础上我们根据自己的需要再对该函数进行进一步的设置，就得到了如上述代码中pie变量保存的函数一样的转化工具，通过把原始的数据dataset传入pie中就能得到绘图数据pieData。具体的变化我们可以看下图。  
<img src="/blog/uploads/chenwubai/d3-basicCharts-pie/dataCompare.png" width="507" height="190" />  
&emsp;&emsp;左边是转化前的原始的数据结构，右边是转化后的适合绘图的数据结构。可以看到，在保留原本的数据的基础上，转化后的数据新增了该项在整个饼图中的起始角度（startAngle和endAngle），以及弧形之间的间隙角度（padAngle）。  
## 计算弧形路径  
&emsp;&emsp;在饼图中，我们用SVG中的path元素来表示每一块弧形，而从pieData到path元素的d属性还是有一定的距离，所以我还需要再通过一步操作来用pieData计算出d属性可用的值。  

	// 创建计算弧形路径的函数
	var radius = 100;
	var arc = d3.svg.arc()
	        .innerRadius(0)
	        .outerRadius(radius);  
## 添加弧形
&emsp;&emsp;上面的代码用[svg.arc()](https://github.com/mbostock/d3/wiki/SVG-Shapes#arc)创建了一个计算弧形路径的函数，通过这个函数就可以计算出path的d属性的值，就像下面这样。  

	// 添加弧形
	main.selectAll('g')
	        .data(pieData)
	        .enter()
	        .append('path')
	        .attr('fill', function(d, i) {
	            return getColor(i);
	        })
	        .attr('d', function(d){
	            return arc(d);
	        });
好了，饼图就这样画好了。  
<img src="/blog/uploads/chenwubai/d3-basicCharts-pie/pie.png" width="320" height="160" />  

&emsp;&emsp;给大家（虽然我知道目前没有什么人看这个但是我还是要像个神经病一样的装作有人看 =_= ）留个小小的拓展，如何加上下图这样的文字标签。答案就在[pie.html](/blog/uploads/chenwubai/d3-basicCharts-pie/pie.html)里。  
<img src="/blog/uploads/chenwubai/d3-basicCharts-pie/pieWithText.png" width="320" height="160" />
