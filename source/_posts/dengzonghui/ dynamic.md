title: 动态规划
date: 2019-03-25
categories:
- dengzonghui
tags:
- 算法
---
本文主要总结了动态规划的几种经典题型。本文分为四个部分，第一部分是经典01背包，第二部分是最少硬币，第三部分是最大正方形，第四部分是最大加号标志。

<!--more-->

## 一、经典01背包

### 1. 题目
背包容量capacity=5，有三个物品(value, weight)，分别是(3,2),(4,3),(5,4)求出其搭配组合，使得背包内总价最大，且最大价值为多少？

### 2.思路

首先理清思路列出表格：
如果背包总容量为0，那么很显然地，任何物品都无法装进背包，那么背包内总价值必然是0。所以第一步先填满 j=0 的情况。
接下来将从上到下，从左往右地填写这个表格。分析第i行时，它的物品组合仅能是小于等于i的情况。所以现在把注意力定位到 i =0, j = 1 的空格上。
i=0 j=1 : 背包总容量为1，但是物品0 的重量为 2，无法装下去，所以这一格应该填 0。
i=0 j=2 : 背包总容量为2，刚好可以装下物品0 ，由于物品0 的价值为3，因此这一格填 3。
后面同理。
i=1 j=1 : 背包总容量为1，但是物品0 的重量为 2，物品1重量为3，背包无法装下任何物品，所以填 0。

|  | val | weight | j=0 | j=1 | j=2 | j=3 | j=4 | j=5 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
|i=0| 3 | 2 | 0 | 0 | 3 | 3 | 3 | 3 |
|i=1| 4 | 3 | 0 | 0 | 3 | 4 | 4 | 7 |
|i=2| 5 | 4 | 0 | 0 | 3 | 4 | 5 | 7 |

伪代码：
```
if(j>w[i]){
    T[i][j] = T[i-1][j]
}else{
    T[i][j] = max(T[i-1][j-w[i]]+val[i], T[i-1][j])
}
```

### 3.代码
```
function backpack(w,val,capacity,n){
    var T = []

    for(let i = 0;i < n;i++){
        T[i] = [];
        for(let j=0;j <= capacity;j++){
            if(j === 0){ //容量为0
                T[i][j] = 0;
                continue;
            }	
            if(j < w[i]){ //容量小于物品重量，本行hold不住
                if(i === 0){
                    T[i][j] = 0; // i = 0时，不存在i-1，所以T[i][j]取0

                }else{
                    T[i][j] = T[i-1][j]; //容量小于物品重量，参照上一行
                }
                continue;
            }
            if(i === 0){
                T[i][j] = val[i]; //第0行，不存在 i-1, 最多只能放这一行的那一个物品
            }else{
                T[i][j] = Math.max(val[i] + T[i-1][j-w[i]],T[i-1][j]);
            }
        }
    }
    findValue(w,val,capacity,n,T);
    return T;
}
//找到需要的物品
function findValue(w,val,capacity,n,T){
    var i = n-1, j = capacity;
    while ( i > 0 && j > 0 ){
        if(T[i][j] != T[i-1][j]){
            console.log('选择物品'+i+',重量：'+ w[i] +',价值：' + values[i]);
            j = j- w[i];
            i--;
        }else{
            i--;  //如果相等，那么就到 i-1 行
        }
    }
    if(i == 0 ){
        if(T[i][j] != 0){ //那么第一行的物品也可以取
            console.log('选择物品'+i+',重量：'+ w[i] +',价值：' + values[i]);
        }
    }
}
var values = [3,4,5],
weights = [2,3,4],
capacity = 5,
n = values.length;

console.log(backpack(weights,values,capacity,n));
```

## 二、最少硬币

### 1. 题目
4种硬币 1分、2分、5分、6分
总共需要11分，求最少的硬币数以及组合

### 2.思路

首先理清思路列出表格：
与经典背包相同，填写第i行表示只能用i和比i小的硬币。硬币数组coins[]，需要的钱数j。
当我们只能使用面额为1分的硬币时，根据上面的规则，那么很显然，总额为几分，就需要几个硬币。
当我们有1分和2分两种面额时，那么组合方式就相对多了点。
i=1 j = 1：总额为1时，只能使用1分的面额。即填1。 
i=1 j = 2：总额为2时，可以使用2个1分的，也可以使用1个2分的。
因为我们要求最少硬币，所以使用1个2分的。表格里填1。
以此类推：

|  | j=0 | j=1 | j=2 | j=3 | j=4 | j=5 | j=6 |  j=7| j=8 | j=9 | j=10 | j=11 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
|i=0 1分| 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 | 11 |
|i=1 2分| 0 | 1 | 1 | 2 | 2 | 3 | 3 | 4 | 4 | 5 | 5 | 6 |
|i=2 5分| 0 | 1 | 1 | 2 | 2 | 1 | 2 | 2 | 3 | 3 | 2 | 3 |
|i=3 6分| 0 | 1 | 1 | 2 | 2 | 1 | 1 | 2 | 2 | 3 |  3 | 2 |

伪代码：
```
if(j<coins[i]){
    T[i][j] = T[i-1][j]
}else{
    T[i][j] = min(T[i-1][j], T[i][j-coins[i]]+1)
}
```

### 3.代码
```
    /**
    * @param {number[]} coins
    * @param {number} amount
    * @return {number}
    */
    var coinChange = function(coins, amount) {
        coins.sort((a,b)=>(a-b));
        var T = [];
        for(let i=0; i<coins.length; i++){
            T[i] = [];
            for(let j=0; j<=amount; j++){
                T[i][j] = 0;
            }
        }
        for(let i=0; i<T.length; i++){
            for(let j=0; j<T[i].length; j++){
                if(j==0){
                    T[i][j] = 0;
                    continue;
                }
                if(i==0){
                    if(Number.isInteger(j/coins[i])){
                        T[i][j] = j/coins[i];
                    }else{
                        T[i][j] = Infinity;
                    }
                }else{
                    if(j<coins[i]){
                        T[i][j] = T[i-1][j];
                    }else{
                        T[i][j] = Math.min(T[i-1][j], T[i][j-coins[i]]+1);
                    }
                }
            }
        }
        return T[T.length-1][T[0].length-1]===Infinity?-1:T[T.length-1][T[0].length-1];
    };
```

## 三、最大正方形

### 1. 题目
在一个由 0 和 1 组成的二维矩阵内，找到只包含 1 的最大正方形，并返回其面积。
示例:

输入: 

1 0 1 0 0
1 0 1 1 1
1 1 1 1 1
1 0 0 1 0

输出: 4

### 2.思路

首先用例中不一定会给正方形，也可能是长方形，所以必须分别求长和宽。
其次如果此点的值是0，则直接将结果设为0；如果此点的值为1，则它等于它左方、上方、左上方三者的最小值+1。
最后是需要一个变量max，在遍历的过程中不断修改自身获取dp中的最大值。

![最大正方形的获取](http://p0.meituan.net/xgfe/62e9135edf9a68df2624aba1d50b9582537777.jpg)

### 3.代码
```
/**
 * @param {character[][]} matrix
 * @return {number}
 */
var maximalSquare = function(matrix) {
    let len1 = matrix.length, len2;
    var dp = new Array(len1);//设置长度
    let max = 0;//记录矩阵中最大值
    for(let i=0; i<len1; i++){
        len2 = matrix[i].length;
        dp[i] = new Array(len2);
    }
    for(let i=0; i<len1; i++){
        for(let j=0; j<len2; j++){
            if(i==0 || j==0){
                dp[i][j] = matrix[i][j] == '1'?1:0;
            }else{
                dp[i][j] = matrix[i][j] == '1'? (Math.min(dp[i-1][j],dp[i][j-1],dp[i-1][j-1])+1):0;
            }
            max = Math.max(max, dp[i][j]);
        }
    }
    return max*max;
};
```

## 四、最大加号标志

### 1. 题目
在一个大小在 (0, 0) 到 (N-1, N-1) 的2D网格 grid 中，除了在 mines 中给出的单元为 0，其他每个单元都是 1。网格中包含 1 的最大的轴对齐加号标志是多少阶？返回加号标志的阶数。如果未找到加号标志，则返回 0。

一个 k" 阶由 1 组成的“轴对称”加号标志具有中心网格  grid[x][y] = 1 ，以及4个从中心向上、向下、向左、向右延伸，长度为 k-1，由 1 组成的臂。下面给出 k" 阶“轴对称”加号标志的示例。注意，只有加号标志的所有网格要求为 1，别的网格可能为 0 也可能为 1。

k 阶轴对称加号标志示例:

阶 1:
000
010
000

阶 2:
00000
00100
01110
00100
00000

阶 3:
0000000
0001000
0001000
0111110
0001000
0001000
0000000
 

示例 1：

输入: N = 5, mines = [[4, 2]]
输出: 2
解释:

11111
11111
11111
11111
11011

在上面的网格中，最大加号标志的阶只能是2。一个标志已在图中标出。
 

示例 2：

输入: N = 2, mines = []
输出: 1
解释:

11
11

没有 2 阶加号标志，有 1 阶加号标志。
 

示例 3：

输入: N = 1, mines = [[0, 0]]
输出: 0
解释:

0

没有加号标志，返回 0 。

### 2.思路

首先要给所有位置设置最大值即边长N。
```
let dp = [...Array(N)].map(() => Array(N).fill(N));
```
循环遍历所有行，从四个方向更新dp。
```
for(let i=0; i<N; i++){
        for(let l=0, left=0; l<N; l++){
            dp[i][l] = Math.min(dp[i][l], left = (dp[i][l] == 0 ? 0: left+1));
        }
        for(let r=N-1, right=0; r>=0; r--){
            dp[i][r] = Math.min(dp[i][r], right = (dp[i][r] == 0 ? 0: right+1));
        }
        for(let u=0, up=0; u<N; u++){
            dp[u][i] = Math.min(dp[u][i], up = (dp[u][i] == 0 ? 0: up+1));
        }
        for(let d=N-1, down=0; d>=0; d--){
            dp[d][i] = Math.min(dp[d][i], down = (dp[d][i] == 0 ? 0: down+1));
        }
    }
```
**left right up down注意每遍历一行都要更新为0。**

### 3.代码
```
/**
 * @param {number} N
 * @param {number[][]} mines
 * @return {number}
 */
var orderOfLargestPlusSign = function(N, mines) {
    let dp = [...Array(N)].map(() => Array(N).fill(N));
    for(let i=0; i<mines.length; i++){
        dp[mines[i][0]][mines[i][1]] = 0;
    }
    let left, right, up, down;
    for(let i=0; i<N; i++){
        for(let l=0, left=0; l<N; l++){
            dp[i][l] = Math.min(dp[i][l], left = (dp[i][l] == 0 ? 0: left+1));
        }
        for(let r=N-1, right=0; r>=0; r--){
            dp[i][r] = Math.min(dp[i][r], right = (dp[i][r] == 0 ? 0: right+1));
        }
        for(let u=0, up=0; u<N; u++){
            dp[u][i] = Math.min(dp[u][i], up = (dp[u][i] == 0 ? 0: up+1));
        }
        for(let d=N-1, down=0; d>=0; d--){
            dp[d][i] = Math.min(dp[d][i], down = (dp[d][i] == 0 ? 0: down+1));
        }
    }
    var max = 0;
    for(let i=0; i<N; i++){
        for(let j=0; j<N; j++){
            max = Math.max(max, dp[i][j]);
        }
    }
    return max;
};
```

总结：
本文主要对动态规划几种经典题做了简单介绍，希望对大家对算法方面的学习有所帮助，总结不到位的地方还请大家批评指正。
友情参考链接：
https://juejin.im/post/5affed3951882567161ad511
https://juejin.im/post/5b0a8e0f51882538b2592963
https://leetcode-cn.com/problemset/all/
