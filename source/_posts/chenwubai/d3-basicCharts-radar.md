title: 基于D3.js的雷达图的实现
date: 2015-11-24 15:28:00
categories: chenwubai
tags:
- 数据可视化
- svg  
- D3.js
---

&emsp;&emsp;基本图表一共有六种，分别是柱状图、折线图、散点图、气泡图、饼图和雷达图。前面五种图形都已经介绍过如何实现了，今天我们一起来看看最后的雷达图。  
<!-- more -->       
&emsp;&emsp;依然是先把简单的画图框架搭起来，添加SVG画布。这里和饼图有点类似，为了方便后面的绘制，我们把组合这些元素的g元素移动到画布的中心：  

	<!DOCTYPE html>
	<html lang="en">
		<head>
		    <meta charset="UTF-8">
		    <title>雷达图</title>
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
		                    .attr('transform', "translate(" + width/2 + ',' + height/2 + ')');
		
		        };
		        function getColor(idx) {
		            var palette = [
		                '#2ec7c9', '#b6a2de', '#5ab1ef', '#ffb980', '#d87a80',
		                '#8d98b3', '#e5cf0d', '#97b552', '#95706d', '#dc69aa',
		                '#07a2a4', '#9a7fd1', '#588dd5', '#f5994e', '#c05050',
		                '#59678c', '#c9ab00', '#7eb00a', '#6f5553', '#c14089'
		            ]
		            return palette[idx % palette.length];
		        }
		    </script>
		</body>
	</html>
&emsp;&emsp;这里为什么我会说雷达图和饼图会有点类似呢？看一下下面这张图。  
<img src="/uploads/chenwubai/d3-basicCharts-radar/radarAnalysis.png" width="400" height="289" />   
&emsp;&emsp;可以看到，雷达图的网轴（蓝色部分）是由多个正多边形所组成的，而正多边形的绘制正好是可以利用圆半径的特性来绘制的，所以从一开始把绘制的原点移动到画布的中心是很方便后面的绘制工作的。  
## 模拟数据  
&emsp;&emsp;我们先模拟一些原始数据。  

	var data = {
		fieldNames: ['语文','数学','外语','物理','化学','生物','政治','历史'],
		values: [
		    [10,20,30,40,50,60,70,80]
		]
	};
## 计算网轴坐标并绘制  
&emsp;&emsp;在前面的其他图表的实现中，都有比例尺或者布局这样的东西来为我们转化数据提供便利，雷达图是否也存在这样的工具函数呢？答案是没有！没有！没有！重要的事情说三遍！(-_-) 所以，我们只能开动自己的小脑瓜自己算了。  

	// 设定一些方便计算的常量
	var radius = 100,
	    // 指标的个数，即fieldNames的长度
	    total = 8,
	    // 需要将网轴分成几级，即网轴上从小到大有多少个正多边形
	    level = 4,
	    // 网轴的范围，类似坐标轴
	    rangeMin = 0,
	    rangeMax = 100,
	    arc = 2 * Math.PI;
	// 每项指标所在的角度
	var onePiece = arc/total;
	// 计算网轴的正多边形的坐标
	var polygons = {
	    webs: [],
	    webPoints: []
	};
	for(var k=level;k>0;k--) {
	    var webs = '',
	            webPoints = [];
	    var r = radius/level * k;
	    for(var i=0;i<total;i++) {
	        var x = r * Math.sin(i * onePiece),
	            y = r * Math.cos(i * onePiece);
	        webs += x + ',' + y + ' ';
	        webPoints.push({
	            x: x,
	            y: y
	        });
	    }
	    polygons.webs.push(webs);
	    polygons.webPoints.push(webPoints);
	}  
&emsp;&emsp;计算网轴的坐标就是计算一个个多边形的各点坐标，为了后面添加polygon元素时方便绘制（points属性的赋值），我们需要在求点坐标的时候顺便把它们拼成字符串。上述代码的for循环中，外层循环代表一个多边形，内层循环代表多边形上的点，多边形与多边形之间差异仅仅在于它们的外圆的半径不同，而同一多边形的点与点之间的差异在于它们的角度不同。点的坐标由半径乘以角度的正弦或者余弦来求得。  
&emsp;&emsp;得到了计算好的坐标以后，我们就开始添加网轴。  
	
	// 绘制网轴
	var webs = main.append('g')
	        .classed('webs', true);
	webs.selectAll('polygon')
	        .data(polygons.webs)
	        .enter()
	        .append('polygon')
	        .attr('points', function(d) {
	            return d;
	        });
&emsp;&emsp;添加一个g元素用来组合所有代表网轴的元素，选择其中的polygon元素并绑定polygons.webs数组，enter()搭配append()添加新的polygon元素，对points属性进行复制。完成这一系列在前面几篇文章中已经反复练习的操作以后，为了让网轴更加的明显，我们给它加一点样式。  

	.webs polygon {
	    fill: white;
	    fill-opacity: 0.5;
	    stroke: gray;
	    stroke-dasharray: 10 5;
	}  
&emsp;&emsp;我们得到了如下图所示的网轴。  
<img src="/uploads/chenwubai/d3-basicCharts-radar/web.png" width="320" height="160" />   
## 添加纵轴  
&emsp;&emsp;接着我们把纵轴也添加上。纵轴就是添加一根根的线条，连接中心点和最外层的多边形上的点，需要的数据可以从polygons.webPoints[0]中取。  

	// 添加纵轴
	var lines = main.append('g')
	        .classed('lines', true);
	lines.selectAll('line')
	        .data(polygons.webPoints[0])
	        .enter()
	        .append('line')
	        .attr('x1', 0)
	        .attr('y1', 0)
	        .attr('x2', function(d) {
	            return d.x;
	        })
	        .attr('y2', function(d) {
	            return d.y;
	        });
&emsp;&emsp;雷达图的坐标轴部分就完成了。  
<img src="/uploads/chenwubai/d3-basicCharts-radar/webWithLine.png" width="320" height="160" />  
## 计算雷达图区域并添加  
&emsp;&emsp;雷达图区域也是一个多边形，只不过是一个不规则的多边形。但是他的几个点始终处在纵轴上，并且点在纵轴上的位置可以通过点所代表的值在纵轴范围内的占比计算出来的。  

	// 计算雷达图表的坐标
	var areasData = [];
	var values = data.values;
	for(var i=0;i<values.length;i++) {
	    var value = values[i],
	            area = '',
	            points = [];
	    for(var k=0;k<total;k++) {
	        var r = radius * (value[k] - rangeMin)/(rangeMax - rangeMin);
	        var x = r * Math.sin(k * onePiece),
	            y = r * Math.cos(k * onePiece);
	        area += x + ',' + y + ' ';
	        points.push({
	            x: x,
	            y: y
	        })
	    }
	    areasData.push({
	        polygon: area,
	        points: points
	    });
	}
&emsp;&emsp;计算完点的坐标以后我们就可以添加雷达图区域了。为了使雷达图更可观，我们除了添加多边形表示雷达图的区域以外，也把多边形在各纵轴上的点标记出来。  

	// 添加g分组包含所有雷达图区域
	var areas = main.append('g')
	    .classed('areas', true);
	// 添加g分组用来包含一个雷达图区域下的多边形以及圆点 
	areas.selectAll('g')
	    .data(areasData)
	    .enter()
	    .append('g')
	    .attr('class',function(d, i) {
	        return 'area' + (i+1);
	    });
	for(var i=0;i<areasData.length;i++) {
		// 依次循环每个雷达图区域
		var area = areas.select('.area' + (i+1)),
		        areaData = areasData[i];
    	// 绘制雷达图区域下的多边形
		area.append('polygon')
		        .attr('points', areaData.polygon)
		        .attr('stroke', function(d, index) {
		            return getColor(i);
		        })
		        .attr('fill', function(d, index) {
		            return getColor(i);
		        });
		// 绘制雷达图区域下的点    
		var circles = area.append('g')
		        .classed('circles', true);
		circles.selectAll('circle')
		        .data(areaData.points)
		        .enter()
		        .append('circle')
		        .attr('cx', function(d) {
		            return d.x;
		        })
		        .attr('cy', function(d) {
		            return d.y;
		        })
		        .attr('r', 3)
		        .attr('stroke', function(d, index) {
		            return getColor(i);
		        });  
	}
&emsp;&emsp;这里为了体验层次关系，我用areas包含住所有雷达图区域，又在里面用一个g分组表示一个雷达图区域，在雷达图区域里包含组成该区域的多边形和圆点。这里因为我们数据用一个雷达图区域就表示了，所以这个for循环只会循环一次。给绘制好的区域加上样式。  

	.areas polygon {
	    fill-opacity: 0.5;
	    stroke-width: 3;
	}
	.areas circle {
	    fill: white;
	    stroke-width: 3;
	}
&emsp;&emsp;于是得到了下图这个样子的图表。  
<img src="/uploads/chenwubai/d3-basicCharts-radar/radar.png" width="320" height="160" />   
## 计算文字标签坐标并添加  
&emsp;&emsp;为了让上面的图表更完整一些，我们给它加上文字标签。文字标签标注在网轴的外围，所以可以以计算网轴多边形点坐标的同样的原理计算文字标签的坐标。  

	// 计算文字标签坐标
	var textPoints = [];
	var textRadius = radius + 20;
	for(var i=0;i<total;i++) {
	    var x = textRadius * Math.sin(i * onePiece),
	            y = textRadius * Math.cos(i * onePiece);
	    textPoints.push({
	        x: x,
	        y: y
	    });
	}  
计算好坐标以后再添加到画布中。  

	// 绘制文字标签
	var texts = main.append('g')
	        .classed('texts', true);
	texts.selectAll('text')
	        .data(textPoints)
	        .enter()
	        .append('text')
	        .attr('x', function(d) {
	            return d.x;
	        })
	        .attr('y', function(d) {
	            return d.y;
	        })
	        .text(function(d,i) {
	            return data.fieldNames[i];
	        });  
&emsp;&emsp;最后的样子是这样的。  
<img src="/uploads/chenwubai/d3-basicCharts-radar/radarWithText.png" width="320" height="160" />  
&emsp;&emsp;完整的代码及展示可参见[radar.html](/uploads/chenwubai/d3-basicCharts-radar/radar.html)。