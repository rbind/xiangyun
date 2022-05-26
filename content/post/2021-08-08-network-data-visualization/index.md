---
title: 网络数据可视化与 R 语言
author: 黄湘云
date: '2022-05-30'
slug: network-data-visualization
categories:
  - 统计图形
tags:
  - 网络分析
  - ggplot2
  - Rgraphviz
  - igraph 
  - ggraph
  - DiagrammeR
bibliography: 
  - refer.bib
  - packages.bib
draft: true
output:
  blogdown::html_page:
    toc: true
thumbnail: /img/seven-bridges.png
link-citations: true
description: "本文首先概览 R 语言在网络数据分析和可视化方面的情况；然后介绍图的表示（矩阵），图的计算（矩阵计算），图的展示（点、线等），图的工具（R 和其它软件）；最后以 CRAN 上 R 包的元数据为基础，介绍网络分析和可视化的过程，也发现了 R 语言社区中一些非常有意思的现象。"
---

<style type="text/css">
.sidebar {
  border: 1px solid #ccc;
}

.rmdwarn {
  border: 1px solid #EA4335;
}

.rmdnote {
  border: 1px solid #FBBC05;
}

.rmdtip {
  border: 1px solid #34A853;
}

.sidebar, .rmdwarn, .rmdnote, .rmdtip {
  border-left-width: 5px;
  border-radius: 5px;
  padding: 1em;
  margin: 1em 0;
}

div.rmdwarn::before, div.rmdnote::before, div.rmdtip::before {
  display: block;
  font-size: 1.1em;
  font-weight: bold;
  margin-bottom: 0.25em;
}

div.rmdwarn::before {
  content: "警告";
  color: #EA4335;
}

div.rmdnote::before {
  content: "注意";
  color: #FBBC05;
}

div.rmdtip::before {
  content: "提示";
  color: #34A853;
}

.rmdinfo {
  border: 1px solid #ccc;
  border-left-width: 5px;
  border-radius: 5px;
  padding: 1em;
  margin: 1em 0;
}
div.rmdinfo::before {
  content: "声明";
  color: block;
  display: block;
  font-size: 1.1em;
  font-weight: bold;
  margin-bottom: 0.25em;
}

figure {
  text-align: center;
}

div.img {
  text-align: center;
  display: block; 
  margin-left: auto; 
  margin-right: auto;
}

.columns {
  display: flex;
}
</style>

<div class="rmdtip">

时隔四年，Gephi 发布了 1.0.0 版，写一篇文章庆祝一下。

</div>

# 本文概览

本文首先概览 R 语言在网络数据分析和可视化方面的情况；然后介绍图的表示（矩阵），图的计算（矩阵计算），图的展示（点、线等），图的工具（R 和其它软件）；最后以 CRAN 上 R 包的元数据为基础，介绍网络分析和可视化的过程，也发现了 R 语言社区中一些非常有意思的现象。

网络图是表示节点之间关系的图，核心在于关系的刻画， 用来表达网络关系的是稀疏矩阵，以及为处理这种矩阵而专门优化的矩阵计算库，如 **Matrix** 、[**rsparse**](https://github.com/rexyai/rsparse)和 **RcppEigen** ([Bates and Eddelbuettel 2013](#ref-Bates2013))，PageRank 应该是大家最为熟悉的网络数据挖掘算法，图关系挖掘和计算的应用场景非常广泛，如社交推荐（社交 App）、风险控制（银行征信、企业查）、深度学习（图神经网络）、知识图谱（商户、商家、客户的实体关系网络）、区块链、物联网（IoT）、反洗钱（金融监管）、数据治理（数据血缘图谱）等。

企业级的图存储和计算框架，比较有名（可能是最有名的），反正，笔者最先听说的是[Neo4j](https://github.com/neo4j/neo4j) ，它有以 AGPL 协议发布的开源版本，还有商业版本。[Nebula Graph](https://github.com/vesoft-inc/nebula) 分布式开源图数据库，高扩展性和高可用性，支持千亿节点、万亿条边、毫秒级查询，有[中文文档](https://github.com/vesoft-inc/nebula-docs-cn/)，有企业应用案例，[美团图数据库平台建设及业务实践](https://mp.weixin.qq.com/s/aYd5tqwogJYfkJXhVNuNpg)。阿里研发的[GraphScope](https://github.com/alibaba/GraphScope) 提供一站式大规模图计算系统，支持图神经网络计算。[HugeGraph](https://github.com/hugegraph/hugegraph)图数据库应用于[金融反欺诈实践](https://zhuanlan.zhihu.com/p/114665466)。

[node2vec](https://cran.r-project.org/package=node2vec)包实现等人提出的大规模网络特征学习([Grover and Leskovec 2016](#ref-Grover2016))。[networkx](https://github.com/networkx/networkx)是做网络分析的 Python 模块。
[**rsparse**](https://github.com/rexyai/rsparse) 包提供很多基于稀疏矩阵的统计学习算法，支持基于 OpenMP 的并行计算。[RSpectra](https://github.com/yixuan/RSpectra) 包是 C++ 库 [Spectra](https://spectralib.org/) 的 R 接口，仅有两个函数 `eigs()` 和 `svds()` 分别用来计算 `\(N\)` 阶矩阵（稀疏或稠密都行） Top K 个最大的特征值/特征向量，适合大规模特征值和奇异值分解问题，在 k 远远小于 N 时，特别能体现优越性。后面从 CRAN 网络数据中获取 Top K 个主要的组织、个人和 R 包。

<!--

[**RcppSparse**](https://github.com/zdebruine/RcppSparse)  RcppArmadillo 和 RcppEigen 深拷贝deep copy 操作，而 RcppSparse zero-copy 零拷贝，无缝衔接，而计算结果是一致的，详细描述见 [Constructing a Sparse Matrix Class in Rcpp](https://gallery.rcpp.org/articles/sparse-matrix-class/)

1. Roger Bivand 分析源码提交记录 <https://github.com/rsbivand/eRum18>
1. 基本数据操作到两大阵营的对话 <https://d.cosx.org/d/420697>
1. 分析 CRAN 上 R 包元数据，挖掘 R 社区中隐藏的信息 <https://r-graphics.netlify.com/cs-cran-network.html>
-->

# R 包概览

[igraph](https://github.com/igraph/igraph) 是非常流行和核心的网络分析 C 语言库，它提供有多种语言的接口，其 R 语言接口 [igraph](https://github.com/igraph/rigraph) 包也被很多其它做网络分析的 R 包所引用。开源的 [Gephi](https://github.com/gephi/gephi) 软件适合处理中等规模的网络分析和可视化。大规模图计算可以用 Apache Spark 的 [GraphX](https://spark.apache.org/graphx/)。R 语言这层，主要还是对应数据分析和数据产品，用于在内部咨询和商业分析。

[David Schoch](http://mr.schochastics.net/) 开发的 [graphlayouts](https://github.com/schochastics/graphlayouts) 包添加布局算法用于网络可视化，他个人网站上还有一些介绍 R 语言网络分析的文章。他开发的另一个 R 包[networkdata](https://github.com/schochastics/networkdata)收集了**980**个网络相关的数据集，用于教学、文章和书籍介绍相关知识应该足够，用不着自己还到处去找了。Thomas Lin Pedersen 开发的[ggraph](https://github.com/thomasp85/ggraph)包实现图和网络的绘图语法，类似 ggplot2 的设计，和以往的使用习惯保持一致，这就非常方便。他开发的另一个 R 包[tidygraph](https://github.com/thomasp85/tidygraph) 将净土应用到图操作上面。Martina Morris 等人开发了一批用于网络分析和建模的 R 包，类似 tidyverse 的做法都整合在 [statnet](https://github.com/statnet) 包里。

[BDgraph](https://cran.r-project.org/package=BDgraph) ([Mohammadi and Wit 2019](#ref-BDgraph2019)) 基于生灭过程的贝叶斯结构学习用于图模型，

[qgraph](https://github.com/SachaEpskamp/qgraph) ([Epskamp et al. 2012](#ref-qgraph2012)) 网络数据可视化和分析，高斯图模型计算

[DoubleML](https://github.com/DoubleML/doubleml-for-r/)([Bach et al. 2021](#ref-DoubleML2021)) 构建在 mlr3 及生态上，实现 Double/Debiased 机器学习框架([Chernozhukov et al. 2018](#ref-Chernozhukov2018))。
[text2map](https://gitlab.com/culturalcartography/text2map) ([Stoltz and Taylor 2021](#ref-text2map2021)) 文本分析，词嵌入，文本网络
[mlpack](https://github.com/mlpack/mlpack) ([Curtin et al. 2018](#ref-mlpack2018)) 是前沿机器学习算法合集。

[visNetwork](https://github.com/datastorm-open/visNetwork) 包 可以制作交互式网络图形，它是 JS 库 [vis-network](https://github.com/visjs/vis-network) 的 R 语言接口。Richard Iannone 而开发的[DiagrammeR](https://github.com/rich-iannone/DiagrammeR) 包可以制作静态的矢量网页图形。

<div class="rmdnote">

[networkD3](https://github.com/christophergandrud/networkD3) CRAN 上次更新还在 2017 年，[Sam Tyner](https://sctyner.me/) 开发的 [geomnet](https://github.com/sctyner/geomnet) 包给 ggplot2 添加了网络图层 `geom_net`，目前未在 CRAN 上发布。François Briatte 开发的 [ggnet](https://github.com/briatte/ggnet) 目前也未在 CRAN 上发布，但是其帮助文档值得一看，[](https://briatte.github.io/ggnet/)。

</div>

另一类表达关系的是流程图或项目架构图，比较流行的制作工具（软件）有[graphviz](https://gitlab.com/graphviz/graphviz)、[plantuml](https://github.com/plantuml/plantuml)、[drawio-desktop](https://github.com/jgraph/drawio-desktop) 和[flowchart.js](https://github.com/adrai/flowchart.js)。在 R Markdown 文档中，knitr 包可以调用 [Graphviz](https://www.graphviz.org/) 软件生成网络图并插入到文档中，而 [nomnoml](https://github.com/rstudio/nomnoml) 包没有外部软件依赖，非常方便，下图<a href="#fig:nomnoml">1</a>即为该 R 包制作。

<figure>
<img src="https://user-images.githubusercontent.com/12031874/120408326-6190a900-c381-11eb-9dcf-9881d33fa2b6.png" class="full" alt="图 1: 开发 R Shiny 应用的技术栈" />
<figcaption aria-hidden="true">图 1: 开发 R Shiny 应用的技术栈</figcaption>
</figure>

| R 包                                                                                          | 简介                                                                                   | 维护者              |
|:----------------------------------------------------------------------------------------------|:---------------------------------------------------------------------------------------|:--------------------|
| **GGally** ([Schloerke et al. 2021](#ref-GGally))                                             | Extension to ggplot2                                                                   | Barret Schloerke    |
| **visNetwork** ([Almende B.V. and Contributors, Thieurmel, and Robert 2021](#ref-visNetwork)) | Network Visualization using vis.js Library                                             | Benoit Thieurmel    |
| **network** ([Butts 2021](#ref-network))                                                      | Classes for Relational Data                                                            | Carter T. Butts     |
| **sna** ([Butts 2020](#ref-sna))                                                              | Tools for Social Network Analysis                                                      | Carter T. Butts     |
| **networkD3** ([Allaire et al. 2017](#ref-networkD3))                                         | D3 JavaScript Network Graphs from R                                                    | Christopher Gandrud |
| **graphlayouts** ([Schoch 2022](#ref-graphlayouts))                                           | Additional Layout Algorithms for Network Visualizations                                | David Schoch        |
| **sand** ([E. Kolaczyk and Csárdi 2020](#ref-sand))                                           | Statistical Analysis of Network Data with R, 2nd Edition                               | Eric Kolaczyk       |
| **ggnetwork** ([Briatte 2021](#ref-ggnetwork))                                                | Geometries to Plot Networks with ggplot2                                               | François Briatte    |
| **statnet** ([Handcock et al. 2019](#ref-statnet))                                            | Software Tools for the Statistical Analysis of Network Data                            | Martina Morris      |
| **DiagrammeR** ([Iannone 2022](#ref-DiagrammeR))                                              | Graph/Network Visualization                                                            | Richard Iannone     |
| **qgraph** ([Epskamp et al. 2022](#ref-qgraph))                                               | Graph Plotting Methods, Psychometric Data Visualization and Graphical Model Estimation | Sacha Epskamp       |
| **igraph** ([file. 2022](#ref-igraph))                                                        | Network Analysis and Visualization                                                     | Tamás Nepusz        |
| **ggraph** ([Pedersen 2021](#ref-ggraph))                                                     | An Implementation of Grammar of Graphics for Graphs and Networks                       | Thomas Lin Pedersen |
| **tidygraph** ([Pedersen 2022](#ref-tidygraph))                                               | A Tidy API for Graph Manipulation                                                      | Thomas Lin Pedersen |
| **node2vec** ([Tian, Li, and Ren 2021](#ref-node2vec))                                        | Algorithmic Framework for Representational Learning on Graphs                          | Yang Tian           |

表 1: 网络分析的 R 包（排名不分先后）

推荐 Github 上 [超棒的网络分析](https://github.com/briatte/awesome-network-analysis) 资源集合，ggplot2 关于网络数据可视化的[介绍](https://ggplot2-book.org/networks.html)，阅读 Erick Kolaczyk 的书籍《Statistical Analysis of Network Data with R》([E. D. Kolaczyk and Csárdi 2014](#ref-Kolaczyk2014), [2020](#ref-Kolaczyk2020))和发表在《R Journal》上的文章《Network Visualization with ggplot2》([Tyner, Briatte, and Hofmann 2017](#ref-Tyner2017))及其配套 R 包 [ggnetwork](https://github.com/briatte/ggnetwork)。Katherine Ognyanova 在个人博客上持续维护的材料 — [Static and dynamic network visualization with R](https://kateto.net/network-visualization)，David Schoch 介绍用 R 包 ggraph 和 graphlayouts 做网络数据可视化的材料 — [Network Visualizations in R: using ggraph and graphlayouts](http://mr.schochastics.net/netVizR.html)，Albert-László Barabási 的在线书籍[《Network Science》](http://networksciencebook.com/)，Douglas Luke 的《A User’s Guide to Network Analysis in R》([Luke 2015](#ref-Luke2015))。无论是软件工具还是相关文献，笔者相信这只是列举了很小的一部分而已，但是应该足够应付绝大部分使用场景，读者若还有补充，欢迎来统计之都论坛留言评论 — [中等规模及以上的网络图，怎么用 R 高效地绘制](https://d.cosx.org/d/419292)或灌水 — [R 社区的开发人员知多少](https://d.cosx.org/d/420670)。

落园园主的博文[十八般武艺，谁主天下？](https://cosx.org/2013/02/jinyong-fiction-mining)分析金庸先生小说揭密最受欢迎的兵器，刘思喆的博文[从北京地铁规划再看地段的重要性](https://bjt.name/2021/02/13/subway.html)分析地铁网络寻找房价洼地。

# 网络分析基础

回顾一下柯尼斯堡七桥问题：在所有桥都只走一遍的情况下，如何才能把这个地方所有的桥都走遍？欧拉将每一座桥抽象为一条线，桥所连接地区抽象为点[^1]。此处，用[tikz-network](https://ctan.org/pkg/tikz-network) 绘制网络图，如图<a href="#fig:seven-bridges">2</a>所示， `\(1,2,\cdots,7\)` 分别表示七座桥， `\(A,B,C,D\)` 分别表示四块区域。

<figure>
<img src="/img/seven-bridges.png" style="width:65.0%" alt="图 2: 欧拉用图抽象的柯尼斯堡七桥" />
<figcaption aria-hidden="true">图 2: 欧拉用图抽象的柯尼斯堡七桥</figcaption>
</figure>

柯尼斯堡七桥图的数据以 igraph 数据类型整理收录在 **igraphdata** 包里，数据集名称就叫 Koenigsberg。**igraph** 包集图数据表示、计算和可视化于一体，功能十分丰富，如图<a href="#fig:koenigsberg">3</a>是用**igraph** 包画的。

``` r
set.seed(6666)
data(Koenigsberg, package = "igraphdata")
par(mar = c(0, 0, 0, 0))
library(igraph)
plot(Koenigsberg)
```

<div class="figure">

<img src="{{< blogdown/postref >}}index_files/figure-html/koenigsberg-1.png" alt="柯尼斯堡七桥" width="672" />
<p class="caption">
图 3: 柯尼斯堡七桥
</p>

</div>

## 安装 R 包

后续的内容使用到一些 R 包，需要先安装一下。

-   **graph** 包：提供基础的类型定义和功能。
-   **RBGL** 包：基于 BOOST 图库提供图算法，如最短路径，连通性等。
-   **Rgraphviz** 包：基于 [Graphviz](https://www.graphviz.org/) 提供多种布局算法，渲染顶点、边、颜色等图形元素。
-   **pkgDepTools** 包：快速制作 CRAN 上 R 包依赖关系图。

``` r
if(!"BiocManager" %in% .packages(T)) install.packages("BiocManager")
if(!"graph" %in% .packages(T)) BiocManager::install(pkgs = "graph")
if(!"Rgraphviz" %in% .packages(T)) BiocManager::install(pkgs = "Rgraphviz")
if(!"pkgDepTools" %in% .packages(T)) BiocManager::install(pkgs = "pkgDepTools")
```

## 图的表示

### 从邻接矩阵构造图

在 R 环境中，邻接矩阵可从 matrix 数据类型构造，行名和列名是顶点，用1-0表示顶点之间是否有边，由0-1构造的邻接矩阵表示图。下面一个有4个顶点的简单图，邻接矩阵如下：

``` r
# library(graph)
mat <- matrix(c(
  0, 0, 1, 1,
  0, 0, 1, 1,
  1, 1, 0, 1,
  1, 1, 1, 0
),
byrow = TRUE, ncol = 4,
dimnames = list(letters[1:4], letters[1:4])
)
mat
#   a b c d
# a 0 0 1 1
# b 0 0 1 1
# c 1 1 0 1
# d 1 1 1 0
```

**graph** 包可以非常方便地将 matrix 类型的邻接矩阵转化为 graph 类型的图，还可以快速绘制图形，如图<a href="#fig:graph">4</a>所示。

``` r
# 邻接矩阵转化为 graph 类型的图
g1 <- graph::graphAM(adjMat = mat)
class(g1)
# [1] "graphAM"
# attr(,"package")
# [1] "graph"
graph::plot(g1)
```

<div class="figure">

<img src="{{< blogdown/postref >}}index_files/figure-html/graph-1.png" alt="用 graph 包绘制4个顶点的简单网络图" width="672" />
<p class="caption">
图 4: 用 <strong>graph</strong> 包绘制4个顶点的简单网络图
</p>

</div>

### 随机模拟无向图

用函数 `randomGraph()` 随机生成一个无向网络图

``` r
set.seed(123)
V <- letters[1:10] # 图的顶点
M <- 1:4  # 选择生成图的
g2 <- graph::randomGraph(V, M, p = 0.2)
graph::numEdges(g2)  # 边的个数
# [1] 16
graph::edgeNames(g2) # 边的名字，无向图顶点之间用 ~ 连接
#  [1] "a~b" "a~d" "a~e" "a~f" "a~h" "b~f" "b~d" "b~e" "b~h" "c~h"
# [11] "d~e" "d~f" "d~h" "e~f" "e~h" "f~h"
# 图的概览
g2
# A graphNEL graph with undirected edges
# Number of Nodes = 10 
# Number of Edges = 16
```

<div class="columns">

<div class="column" width="47.5%" data-latex="{0.475\textwidth}">

``` r
graph::edges(g2) # 边
# $a
# [1] "b" "d" "e" "f" "h"
# 
# $b
# [1] "f" "a" "d" "e" "h"
# 
# $c
# [1] "h"
# 
# $d
# [1] "a" "b" "e" "f" "h"
# 
# $e
# [1] "a" "b" "d" "f" "h"
# 
# $f
# [1] "b" "a" "d" "e" "h"
# 
# $g
# character(0)
# 
# $h
# [1] "c" "a" "b" "d" "e" "f"
# 
# $i
# character(0)
# 
# $j
# character(0)
```

</div>

<div class="column" width="5%" data-latex="{0.05\textwidth}">

 
<!-- an empty Div (with a white space), serving as
a column separator -->

</div>

<div class="column" width="47.5%" data-latex="{0.475\textwidth}">

``` r
graph::edgeWeights(g2) # 边的权重
# $a
# b d e f h 
# 1 1 1 1 1 
# 
# $b
# f a d e h 
# 2 1 1 1 1 
# 
# $c
# h 
# 1 
# 
# $d
# a b e f h 
# 1 1 1 1 1 
# 
# $e
# a b d f h 
# 1 1 1 1 1 
# 
# $f
# b a d e h 
# 2 1 1 1 1 
# 
# $g
# numeric(0)
# 
# $h
# c a b d e f 
# 1 1 1 1 1 1 
# 
# $i
# numeric(0)
# 
# $j
# numeric(0)
```

</div>

</div>

V 表示图的顶点， M 表示一组元素的集合，
p 表示从集合 M 中选出一个元素的概率。随机图的构造方法如下：
从 M 中以概率 p 选出一个元素，比如 1 （或者没有选），然后将 1 随机地指给 V 中的一个顶点 a，重复这个过程 4 次（次数取决于 M 中元素的个数）完成对一个顶点的随机指定，此时，顶点 a 对应一个长度为 4 的逻辑向量，有值的位置记为 TRUE，反之记为 FALSE，对其他顶点操作类似，这样就可以得到一个 10 \* 4 的矩阵。如果某一列有两个顶点共有一个元素，比如 1， 则这两个顶点有边连接，反之则无。如果两个顶点共用2和3两个元素，则连接两个顶点的边的权重为 2。可见，V 和 M 的数量，以及 p 的值决定图的稠密程度。

<div class="figure">

<img src="{{< blogdown/postref >}}index_files/figure-html/random-graph-1.png" alt="用 graph 包生成10个顶点的随机网络图" width="672" />
<p class="caption">
图 5: 用 <strong>graph</strong> 包生成10个顶点的随机网络图
</p>

</div>

<div class="figure">

<img src="{{< blogdown/postref >}}index_files/figure-html/layout-graph-1.png" alt="图的布局：左图 neato 布局，右图 twopi 布局" width="672" />
<p class="caption">
图 6: 图的布局：左图 neato 布局，右图 twopi 布局
</p>

</div>

### mlr3 包的生态图

下面是一个真实的网络图示例，取自 Deepayan Sarkar 在 2010 年介绍 R 语言的[材料](https://www.isid.ac.in/~deepayan/R-tutorials/docs/roverview.pdf)，该材料涵盖 R 语言的来龙去脉，辅以丰富的示例介绍统计计算、统计图形。

``` r
library(graph)
library(RBGL)
library(pkgDepTools)
g <- makeDepGraph("https://cran.r-project.org", keep.builtin = TRUE)
g
```

    # A graphNEL graph with directed edges
    # Number of Nodes = 19056 
    # Number of Edges = 95625

截至2022年04月28日，CRAN 上的 R 包有 19056 个（即网络的顶点），组成的依赖关系网包含 95625 条边。下面以 **mlr3** 包为例，提取后向依赖图，即依赖**mlr3** 包的 R 包的关系网，作为 R 包开发者，常常需要关心自己的 R 包改动会对下游 R 包的影响。CRAN 也有政策，防止开发者**肆意**引入破坏性改动。

``` r
revDepGraph <- function(g, pkg) {
  olen <- 0
  pkgKeep <- pkg
  elist <- g@edgeL
  elist <- elist[!(sapply(elist, is.null))]
  while (length(pkgKeep) > olen) {
    olen <- length(pkgKeep)
    w <- which(g@nodes %in% pkgKeep)
    revdep <- sapply(elist, function(x) any(w %in% x$edges))
    pkgKeep <- union(pkgKeep, names(revdep)[revdep])
  }
  subGraph(pkgKeep, g)
}
graph_mlr3 <- revDepGraph(g, "mlr3")
graph_mlr3
# A graphNEL graph with directed edges
# Number of Nodes = 25 
# Number of Edges = 50
```

可知目前有 25 个 R 包直接或间接强依赖 **mlr3** 包，而这个依赖关系网有 50 条边，如图<a href="#fig:mlr3-dep-graph">7</a>所示，这其实就是 **mlr3** 包的生态。

``` r
library(Rgraphviz)
# 顶点的形状为椭圆
graph.par(nodes = list(shape = "ellipse"))
# 布局算法 twopi
graph_mlr3_layout <- layoutGraph(graph_mlr3, layoutType = "twopi")
# 渲染图
renderGraph(graph_mlr3_layout)
```

<div class="figure">

<img src="{{< blogdown/postref >}}index_files/figure-html/mlr3-dep-graph-1.png" alt="mlr3 包的后向依赖图" width="768" />
<p class="caption">
图 7: <strong>mlr3</strong> 包的后向依赖图
</p>

</div>

# CRAN 网络分析

网络上已有的一些分析结果：

-   Duncan Temple Lang 对 R 包内的文件分析，分析代码见[CRANAnalysis](https://github.com/duncantl/CRANAnalysis)

目前 R 社区在鼓励大家将 R 包的开发迁移到 Github，而 Github 会保存代码提交的历史记录，这将有助于获得数据。已迁移到 Github 开发的 R 包占总量的比例。GitHub 在 R 社区的渗透，对比其他代码托管平台。
Github 上的一键三连，关注（watch）、点击（star）和转发（fork）。

CRAN 生态分析

-   R 包
    -   数量：总量、增速、更新、开发活跃度，留存/活跃
    -   质量：R 包质量分
        -   结果指标：星赞数、下载量、下游依赖数
        -   过程指标：CRAN 上存在时间、单元测试、覆盖测试、帮助文档、发布协议
    -   分类：有的 R 包已经归类，即打上 TaskView 的标记，还有的没有，是否可以通过算法归类。文本相似度？关联规则？
    -   
-   R 包关系
    -   网络结构：关键节点，入度/出度分布
    -   pagerank 算法
-   开发者
    -   数量：
        -   开发者的总量、增速、
        -   提交代码的活跃度、
        -   更新自己 R 包的频次
    -   个人：
        -   开发 R 包数量
        -   Github 活跃情况
        -   CRAN 更新频次
        -   对外贡献其他 R 包：PR
        -   开发者的空间分布？国家
    -   团体：学术机构和工业团体
        -   开发 R 包数量
        -   Github 活跃情况
        -   CRAN 更新频次
        -   对外贡献其他 R 包：PR
        -   团体的空间分布？
        -   会议/workshop等
-   开发者关系
    -   网络结构：关键节点，入度/出度分布
    -   开发者：协作网络
    -   pagerank 算法

帮助读者了解 R 语言社区，学习 R 语言，选择高质量 R 包，开发和维护 R 包等。此外，在网络数据分析、可视化和建模等方面提供一些思路。

基于 CRAN 数据，分析 R 语言社区开发者关系网络。首先展示当前 R 语言社区的一些基本概览信息，目的是让外行或入坑不深的人有所了解。

邮箱后缀 @符号后面的部分，根据邮箱查所属国家，地区，开发者的邮箱分布，所属大学、企业分布。单个人物和集体人物。
在 R 会开始之前发出来，比较应景。

围绕生态环境来写和分析，最后思考，如何引领，站在核心开发者的视角，基金会的视角来看，对统计之都有没有一些启示。

## R 包

只考虑 CRAN 范围内的数据

影响力
关键 R 包

在什么平台开发，Github 还是线下

R 包关系
一度关系，安装 A 包，必须安装 B 包，则 B 包为 A 包的前置依赖。

选择合适的 R 包，软件质量问题 Ohloh 网站，从 R 包开发者，依赖情况等，发现一批优质的 R 包和厉害的开发者。

### 发布协议

R 软件以 GPL 2.0 或 GPL 3.0 协议发布

| R 包协议                     | R 包数量 |
|:-----------------------------|---------:|
| GPL (\>= 2)                  |     4364 |
| GPL-3                        |     4282 |
| MIT + file LICENSE           |     3346 |
| GPL-2                        |     2567 |
| GPL (\>= 3)                  |     1126 |
| GPL                          |      499 |
| GPL-2 \| GPL-3               |      333 |
| CC0                          |      200 |
| GPL-3 \| file LICENSE        |      158 |
| LGPL-3                       |      157 |
| BSD_3\_clause + file LICENSE |      134 |
| AGPL-3                       |      123 |
| Artistic-2.0                 |      111 |
| BSD_2\_clause + file LICENSE |      110 |
| GPL (\>= 2.0)                |      104 |

表 2: CRAN 上受开发者欢迎的 R 包发布协议（Top 15）

GPL 协议占主导地位，MIT 协议次之。

CRAN 会检测 R 包的授权，只有授权协议包含在[数据库](https://svn.r-project.org/R/trunk/share/licenses/license.db)中的才可以在 CRAN 上发布。

### 更新频次

距今10余年未更新

    #       Package                              Title  Published
    # 11464    pack Convert values to/from raw vectors 2008-09-08

18000 多个 R 包，距离上次更新的时间间隔分布

    #   0%  25%  50%  75% 100% 
    #    0  177  534 1280 4980

半年时间更新 25% 的 R 包，一年半时间更新 50% 的 R 包，三年半时间也只更新 75% 的 R 包。

<div class="rmdtip">

非常值得和 Python 对比一下，Python 模块仓库 <https://pypi.org/>。
Python 编程风格指南 <https://www.python.org/dev/peps/pep-0008/>。

</div>

### 增长速度

目前手头只有一份昨天的 CRAN 日志，没法和历史对比，若有历史的 CRAN 快照日志，就可以站在 2012 年看 2000-2012 年的净增长量和速度。

下图以 2022-04-28 观测日，统计过去每个月份的净增长量。

<div class="figure">

<img src="{{< blogdown/postref >}}index_files/figure-html/unnamed-chunk-17-1.png" alt="R 包增长量" width="672" />
<p class="caption">
图 8: R 包增长量
</p>

</div>

<div class="figure">

<img src="{{< blogdown/postref >}}index_files/figure-html/unnamed-chunk-18-1.png" alt="R 包增长速度" width="672" />
<p class="caption">
图 9: R 包增长速度
</p>

</div>

### 选择 R 包

挑选合适的 R 包是一件比较困难的事情，R 社区开发的 R 包实在太多了，重复造的轮子也很多，哪个轮子结实好用就选哪个。

[packagemetrics](https://github.com/sfirke/packagemetrics) 可以统计 R 包各个方面的信息，从而帮助你选择该使用哪个 R 包

## R 包关系

作为开发者，既要关心上游 R 包的变动，也有关心对下游 R 包的影响。除了 Base R 内置的那些基础核心 R 包外，CRAN 上发布的 R 包几乎都有上游 R 包依赖。

## 开发者

<!-- 
关键开发者、所属组织性质，学校、公司 
-->

一个人有多个邮箱的情况比较多，因此清理了 Maintainer 字段中的邮箱，按照习惯来说，人名通常只有一种写法，国外会加入头衔、爵号什么的，这种难以清理合并了。截止目前，R 社区开发者数量已超过 **10000** 人，而根据 Python 官方网站数字 <https://pypi.org/>，Python 社区开发者超过 **55** 万人。

    # [1] 10123

### 一些组织

有的组织基本停止了开发，如[Omegahat](https://github.com/omegahat)，有的被商业公司收购后，不再活跃了，如[Revolution Analytics](https://github.com/RevolutionAnalytics)。

除了众所周知的 [tidyverse](https://github.com/tidyverse/tidyverse) ([Wickham et al. 2019](#ref-Wickham2019)) 和 [tidymodels](https://github.com/tidymodels/tidymodels)([Kuhn and Wickham 2020](#ref-Kuhn2020))，还有很多数据分析、建模的工具箱，如[mlr3verse](https://github.com/mlr-org/mlr3verse) ([Lang and Schratz 2021](#ref-Lang2021))、[easystats](https://github.com/easystats/easystats)([Makowski, Ben-Shachar, and Lüdecke 2020](#ref-Makowski2020))、[strengejacke](https://github.com/strengejacke/strengejacke)([Lüdecke 2019](#ref-Daniel2019))和[DrWhy](https://github.com/ModelOriented/DrWhy)([Biecek 2021](#ref-DrWhy2021))。不存在明显的规律，因此下面从开发者的邮箱出发，隶属企业组织往往有统一的邮箱后缀。

<table class="kable_wrapper">
<caption>
表 3: 最受欢迎的邮箱（Top 30）
</caption>
<tbody>
<tr>
<td>

| 邮箱后缀       | R 包数量 |
|:---------------|---------:|
| gmail.com      |     6770 |
| rstudio.com    |      207 |
| hotmail.com    |      179 |
| outlook.com    |      143 |
| R-project.org  |      107 |
| 163.com        |       92 |
| umich.edu      |       87 |
| uw.edu         |       83 |
| berkeley.edu   |       81 |
| umn.edu        |       77 |
| yahoo.com      |       72 |
| debian.org     |       67 |
| protonmail.com |       66 |
| stanford.edu   |       60 |
| gmx.de         |       57 |

</td>
<td>

| 邮箱后缀          | R 包数量 |
|:------------------|---------:|
| ncsu.edu          |       57 |
| auckland.ac.nz    |       56 |
| stat.math.ethz.ch |       55 |
| wisc.edu          |       54 |
| googlemail.com    |       52 |
| r-project.org     |       50 |
| duke.edu          |       47 |
| uwaterloo.ca      |       46 |
| ucl.ac.uk         |       45 |
| mailbox.org       |       44 |
| columbia.edu      |       42 |
| outlook.fr        |       42 |
| yale.edu          |       41 |
| inrae.fr          |       39 |
| uiowa.edu         |       38 |

</td>
</tr>
</tbody>
</table>

看到这个结果还是蛮震惊的，竟有 6584 个 R 包使用 Gmail 邮箱，截止写作时间，CRAN 上全部 R 包 18000 多个，Gmail 邮箱覆盖率超过 1/3！

### 教育机构

我们知道 R 语言社区的很多开发者来自学界，使用学校邮箱的应该不少，因此，决定看看 Top 的大学有哪些，以及总数能否超过 Gmail 邮箱？

<table class="kable_wrapper">
<caption>
表 4: 贡献 R 包最多的大学（Top 30）
</caption>
<tbody>
<tr>
<td>

| 邮箱后缀          | R 包数量 |
|:------------------|---------:|
| umich.edu         |       87 |
| uw.edu            |       83 |
| berkeley.edu      |       81 |
| umn.edu           |       77 |
| stanford.edu      |       60 |
| ncsu.edu          |       57 |
| wisc.edu          |       54 |
| duke.edu          |       47 |
| columbia.edu      |       42 |
| yale.edu          |       41 |
| uiowa.edu         |       38 |
| illinois.edu      |       34 |
| ucdavis.edu       |       34 |
| wharton.upenn.edu |       31 |
| cornell.edu       |       30 |

</td>
<td>

| 邮箱后缀        | R 包数量 |
|:----------------|---------:|
| nd.edu          |       30 |
| fas.harvard.edu |       29 |
| mayo.edu        |       29 |
| monash.edu      |       29 |
| psu.edu         |       26 |
| unc.edu         |       26 |
| usc.edu         |       25 |
| vt.edu          |       25 |
| msu.edu         |       23 |
| ucla.edu        |       23 |
| osu.edu         |       22 |
| vanderbilt.edu  |       21 |
| iastate.edu     |       20 |
| jhu.edu         |       20 |
| ucsd.edu        |       20 |

</td>
</tr>
</tbody>
</table>

好吧，几乎全是欧美各个 NB 大学的，比如华盛顿大学（ uw.edu）、密歇根大学（umich.edu）、加州伯克利大学（berkeley.edu）等等。顺便一说，欧美各个大学的网站，特别是统计院系很厉害的，已经帮大家收集得差不多了，有留学打算的读者自取，邮箱后缀就是学校/院官网。

而使用大学邮箱的 R 包总数竟不及 Gmail 邮箱，可见谷歌邮箱服务在全球 R 语言社区的影响力，赤裸裸的数字，赤裸裸的伤害！虽然有的学校邮箱不以 edu 结尾，有的人虽在学校，但是使用了 Gmail 邮箱，但是巨大的数字鸿沟，几乎可以断定 R 语言社区的开发主力已经从学术界转移到工业界。

    # [1] 1164

<div class="rmdtip">

有些邮箱后缀带有院系，但是并没有向上合并到学校这一级，比如 `stanford.edu` 、`stat.stanford.edu` 和 `alumni.stanford.edu` 等没有合并统计，所以排名仅供参考。
有的邮箱来自教育机构，但是不以 `edu` 结尾，实际使用 `edu` 邮箱的教育机构大部份位于美国，比如新西兰奥克兰大学 `auckland.ac.nz` 瑞士苏黎世联邦理工学院 `stat.math.ethz.ch`
如果读者还知道其他一般规律的，或者提供大学邮箱列表或者有其它更好的办法，就可以把这个数字做得更加精准一些。只是改变这个结论恐怕很难。

</div>

一般人我都不告诉他，勾搭 NB 院校老师的机会来了，我们先来看看斯坦佛大学（stanford.edu）的哪些老师贡献了哪些 R 包。

开发者、R 包数量、R 包文本

<table class="kable_wrapper">
<caption>
表 5: 斯坦福大学开发者（部分）
</caption>
<tbody>
<tr>
<td>

| R 包               | 开发者              |
|:-------------------|:--------------------|
| QuantileGradeR     | Zoe Ashwood         |
| GenoScan           | Zihuai He           |
| GhostKnockoff      | Zihuai He           |
| KnockoffScreen     | Zihuai He           |
| WGScan             | Zihuai He           |
| Rdsdp              | Zhisu Zhu           |
| gsynth             | Yiqing Xu           |
| panelView          | Yiqing Xu           |
| gam                | Trevor Hastie       |
| gamsel             | Trevor Hastie       |
| glmnet             | Trevor Hastie       |
| ISLR               | Trevor Hastie       |
| ISLR2              | Trevor Hastie       |
| lars               | Trevor Hastie       |
| mda                | Trevor Hastie       |
| ProDenICA          | Trevor Hastie       |
| softImpute         | Trevor Hastie       |
| sparsenet          | Trevor Hastie       |
| svmpath            | Trevor Hastie       |
| COCONUT            | Timothy E Sweeney   |
| igraphtosonia      | Sean J Westwood     |
| NetCluster         | Sean J Westwood     |
| mdsdt              | Robert X.D. Hawkins |
| clusterRepro       | Rob Tibshirani      |
| glasso             | Rob Tibshirani      |
| GSA                | Rob Tibshirani      |
| pamr               | Rob Tibshirani      |
| pcLasso            | Rob Tibshirani      |
| PMA                | Rob Tibshirani      |
| samr               | Rob Tibshirani      |
| selectiveInference | Rob Tibshirani      |
| xtreg2way          | Paulo Somaini       |
| dagwood            | Noah Haber          |
| BHMSMAfMRI         | Nilotpal Sanyal     |
| EValue             | Maya B. Mathur      |
| MetaUtility        | Maya B. Mathur      |
| NRejections        | Maya B. Mathur      |

</td>
<td>

| R 包            | 开发者                     |
|:----------------|:---------------------------|
| PublicationBias | Maya B. Mathur             |
| Replicate       | Maya B. Mathur             |
| SimTimeVar      | Maya B. Mathur             |
| SNPknock        | Matteo Sesia               |
| Counternull     | Mabene Yasmine             |
| pcdpca          | Lukasz Kidzinski           |
| CVcalibration   | Lu Tian                    |
| exactmeta       | Lu Tian                    |
| PBIR            | Lu Tian                    |
| RandMeta        | Lu Tian                    |
| VDSPCalibration | Lu Tian                    |
| ptycho          | Laurel Stell               |
| LocFDRPois      | Kris Sankaran              |
| freqdom         | Kidzinski L.               |
| freqdom.fda     | Kidzinski L.               |
| relgam          | Kenneth Tay                |
| akmeans         | Jungsuk Kwac               |
| grf             | Julie Tibshirani           |
| ebal            | Jens Hainmueller           |
| KRLS            | Jens Hainmueller           |
| Synth           | Jens Hainmueller           |
| rma.exact       | Haben Michael              |
| policytree      | Erik Sverdrup              |
| CHOIRBM         | Eric Cramer                |
| texteffect      | Christian Fong             |
| bcaboot         | Balasubramanian Narasimhan |
| cubature        | Balasubramanian Narasimhan |
| sglr            | Balasubramanian Narasimhan |
| sp23design      | Balasubramanian Narasimhan |
| CVXR            | Anqi Fu                    |
| RCA             | Amir Goldberg              |
| TableHC         | Alon Kipnis                |
| MetaLonDA       | Ahmed A. Metwally          |
| MetaIntegrator  | Aditya M. Rao              |
| lrgs            | Adam Mantz                 |
| rgw             | Adam Mantz                 |

</td>
</tr>
</tbody>
</table>

### 高产开发者

<table class="kable_wrapper">
<caption>
表 6: 开发 R 包数量最多的人（Top 30）
</caption>
<tbody>
<tr>
<td>

| 开发者             | R 包数量 |
|:-------------------|---------:|
| Dirk Eddelbuettel  |       67 |
| Gábor Csárdi       |       57 |
| Hadley Wickham     |       48 |
| Jeroen Ooms        |       47 |
| Scott Chamberlain  |       47 |
| Stéphane Laurent   |       40 |
| Robin K. S. Hankin |       33 |
| Henrik Bengtsson   |       31 |
| Kartikeya Bolar    |       29 |
| Kurt Hornik        |       28 |
| Jan Wijffels       |       27 |
| Bob Rudis          |       26 |
| Kirill Müller      |       26 |
| Torsten Hothorn    |       26 |
| Martin Maechler    |       25 |

</td>
<td>

| 开发者               | R 包数量 |
|:---------------------|---------:|
| Muhammad Yaseen      |       25 |
| Achim Zeileis        |       24 |
| Richard Cotton       |       24 |
| Guangchuang Yu       |       23 |
| Max Kuhn             |       22 |
| Yihui Xie            |       22 |
| Florian Schwendinger |       21 |
| John Muschelli       |       21 |
| Kevin R. Coombes     |       21 |
| Michael D. Sumner    |       21 |
| Paul Gilbert         |       21 |
| Carl Boettiger       |       20 |
| Joe Thorley          |       20 |
| Thomas Lin Pedersen  |       20 |
| Hana Sevcikova       |       19 |

</td>
</tr>
</tbody>
</table>

看到这个结果既有意料之中的，又有很多意料之外的。比如谢益辉竟没有进入前 Top 15，还有好多人是我不知的，甚至是第一次看到，足见我的孤陋寡闻！顺便一提，这其实是一个值得关注的 R 语言社区顶级开发者列表。

### CRAN 团队

[R Foundation 成员](https://www.r-project.org/foundation/members.html)
初始的成员包含 R Development Core Team 列入 R 软件 1.5.0 版本

[Journal of Statistical Software 杂志编委](https://www.jstatsoft.org/about/editorialTeam)

[R Journal 编委](https://journal.r-project.org/board.html)

    Authors of R.

    R was initially written by Robert Gentleman and Ross Ihaka—also known as "R & R"
    of the Statistics Department of the University of Auckland.

    Since mid-1997 there has been a core group with write access to the R
    source, currently consisting of

    Douglas Bates
    John Chambers
    Peter Dalgaard
    Robert Gentleman
    Kurt Hornik
    Ross Ihaka
    Tomas Kalibera
    Michael Lawrence
    Friedrich Leisch
    Uwe Ligges
    Thomas Lumley
    Martin Maechler
    Sebastian Meyer
    Paul Murrell
    Martyn Plummer
    Brian Ripley
    Deepayan Sarkar
    Duncan Temple Lang
    Luke Tierney
    Simon Urbanek

    plus Heiner Schwarte up to October 1999, Guido Masarotto up to June 2003,
    Stefano Iacus up to July 2014, Seth Falcon up to August 2015, Duncan Murdoch
    up to September 2017, and Martin Morgan up to June 2021.


    Current R-core members can be contacted via email to R-project.org
    with name made up by replacing spaces by dots in the name listed above.

    (The authors of code from other projects included in the R distribution
    are listed in the COPYRIGHTS file.)

<table class="kable_wrapper">
<caption>
表 7: CRAN 团队开发维护 R 包数量情况
</caption>
<tbody>
<tr>
<td>

| 团队成员           | R 包数量 |
|:-------------------|---------:|
| Kurt Hornik        |       28 |
| Simon Urbanek      |       26 |
| Torsten Hothorn    |       26 |
| Martin Maechler    |       25 |
| Achim Zeileis      |       24 |
| Paul Murrell       |       19 |
| Toby Dylan Hocking |       16 |
| Brian Ripley       |       12 |
| Thomas Lumley      |       11 |
| Uwe Ligges         |        9 |
| David Meyer        |        6 |
| Duncan Murdoch     |        6 |
| CRAN Team          |        5 |

</td>
<td>

| 团队成员         | R 包数量 |
|:-----------------|---------:|
| Friedrich Leisch |        5 |
| Luke Tierney     |        5 |
| Stefan Theussl   |        5 |
| Stefano M. Iacus |        5 |
| John Chambers    |        4 |
| Michael Lawrence |        4 |
| Bettina Grün     |        3 |
| Douglas Bates    |        3 |
| Simon Wood       |        3 |
| Bettina Gruen    |        2 |
| Deepayan Sarkar  |        2 |
| Martyn Plummer   |        2 |
| Peter Dalgaard   |        1 |

</td>
</tr>
</tbody>
</table>

Martin Maechler、Simon Urbanek、Kurt Hornik、Torsten Hothorn、Achim Zeileis 等真是高产呐！除了维护 R 语言核心代码，还开发维护了**20**多个 R 包！以 Brian Ripley 为例，看看他都开发了哪些 R 包。

| Package    | Title                                                                    |
|:-----------|:-------------------------------------------------------------------------|
| boot       | Bootstrap Functions (Originally by Angelo Canty for S)                   |
| class      | Functions for Classification                                             |
| fastICA    | FastICA Algorithms to Perform ICA and Projection Pursuit                 |
| gee        | Generalized Estimation Equation Solver                                   |
| KernSmooth | Functions for Kernel Smoothing Supporting Wand & Jones (1995)            |
| MASS       | Support Functions and Datasets for Venables and Ripley’s MASS            |
| mix        | Estimation/Multiple Imputation for Mixed Categorical and Continuous Data |
| nnet       | Feed-Forward Neural Networks and Multinomial Log-Linear Models           |
| pspline    | Penalized Smoothing Splines                                              |
| RODBC      | ODBC Database Access                                                     |
| spatial    | Functions for Kriging and Point Pattern Analysis                         |
| tree       | Classification and Regression Trees                                      |

震惊！有一半收录在 R 软件中，所以已经持续维护 **20** 多年了。

<div class="rmdtip">

根据邮箱后缀匹配抽取的 R 包及开发者，规则也许不能覆盖所有的情况，读者若有补充，欢迎 PR 给我。举个例子，Brian Ripley 的邮箱 <ripley@stats.ox.ac.uk> 就不是一路，需要单独添加。

</div>

看看他们开发的 R 包之间的依赖关系，数据范围就是他们开发的 R 包

### RStudio 团队

<table class="kable_wrapper">
<caption>
表 8: RStudio 团队开发维护 R 包数量情况（部分）
</caption>
<tbody>
<tr>
<td>

| 团队成员            | R 包数量 |
|:--------------------|---------:|
| Hadley Wickham      |       48 |
| Max Kuhn            |       22 |
| Davis Vaughan       |       15 |
| Lionel Henry        |       15 |
| Winston Chang       |       14 |
| Daniel Falbel       |       13 |
| Jennifer Bryan      |       13 |
| Carson Sievert      |        8 |
| Barret Schloerke    |        7 |
| Thomas Lin Pedersen |        6 |
| Tomasz Kalinowski   |        6 |
| JJ Allaire          |        4 |
| Joe Cheng           |        4 |
| Kevin Ushey         |        4 |

</td>
<td>

| 团队成员            | R 包数量 |
|:--------------------|---------:|
| Richard Iannone     |        4 |
| Edgar Ruiz          |        3 |
| Julia Silge         |        3 |
| Kevin Kuo           |        3 |
| Aron Atkins         |        2 |
| Christophe Dervieux |        2 |
| Cole Arendt         |        2 |
| Romain François     |        2 |
| Yitao Li            |        2 |
| Brian Smith         |        1 |
| Hannah Frick        |        1 |
| James Blair         |        1 |
| Nathan Stephens     |        1 |
| Nick Strayer        |        1 |

</td>
</tr>
</tbody>
</table>

在开发维护的 R 包里，谢益辉所给的联系邮箱是 <xie@yihui.name>，就不在上述之列，因此，表<a href="#tab:rstudio-developers">8</a>中所列仅是部分而已。

CRAN 和 RStudio 团队是 R 语言社区最为熟悉的，其它团队需借助一些网络分析算法挖掘了。

## 开发者关系

选择一个 R 包需要考虑很多因素，最关键的因素还是人，以 data.table 为例，外部依赖很少，运行效率很高，功能覆盖很广，向后兼容很好，帮助文档很全，单测回测很足。R 包的品质可以看出做人做事的品质，Code Style Should Taste Well!

依赖 10 个 R 包，就是依赖 10 个维护者，如果是依赖自个的 R 包，维护者数量就没有 10 个了。

通过 R 包贡献合作的关系

### 贡献者

以 **data.table** 包为例，从元数据中抽取贡献者名单

    #  [1] "Matt Dowle"               "Arun Srinivasan"         
    #  [3] "Jan Gorecki"              "Michael Chirico"         
    #  [5] "Pasha Stetsenko"          "Tom Short"               
    #  [7] "Steve Lianoglou"          "Eduard Antonyan"         
    #  [9] "Markus Bonsch"            "Hugh Parsonage"          
    # [11] "Scott Ritchie"            "Kun Ren"                 
    # [13] "Xianying Tan"             "Rick Saporta"            
    # [15] "Otto Seiskari"            "Xianghui Dong"           
    # [17] "Michel Lang"              "Watal Iwasaki"           
    # [19] "Seth Wenchel"             "Karl Broman"             
    # [21] "Tobias Schmidt"           "David Arenburg"          
    # [23] "Ethan Smith"              "Francois Cocquemas"      
    # [25] "Matthieu Gomez"           "Philippe Chataignon"     
    # [27] "Nello Blaser"             "Dmitry Selivanov"        
    # [29] "Andrey Riabushenko"       "Cheng Lee"               
    # [31] "Declan Groves"            "Daniel Possenriede"      
    # [33] "Felipe Parages"           "Denes Toth"              
    # [35] "Mus Yaramaz-David"        "Ayappan Perumal"         
    # [37] "James Sams"               "Martin Morgan"           
    # [39] "Michael Quinn"            "@javrucebo"              
    # [41] "@marc-outins"             "Roy Storey"              
    # [43] "Manish Saraswat"          "Morgan Jacob"            
    # [45] "Michael Schubmehl"        "Davis Vaughan"           
    # [47] "Toby Hocking"             "Leonardo Silvestri"      
    # [49] "Tyson Barrett"            "Jim Hester"              
    # [51] "Anthony Damico"           "Sebastian Freundt"       
    # [53] "David Simons"             "Elliott Sales de Andrade"
    # [55] "Cole Miller"              "Jens Peder Meldgaard"    
    # [57] "Vaclav Tlapak"            "Kevin Ushey"             
    # [59] "Dirk Eddelbuettel"        "Ben Schwen"

其中，`@javrucebo` 和 `@marc-outins` 是 Github ID 并不是姓名。各个贡献者

    #  [1] "[aut, cre]" "[aut]"      "[ctb]"      "[ctb]"      "[ctb]"     
    #  [6] "[ctb]"      "[ctb]"      "[ctb]"      "[ctb]"      "[ctb]"     
    # [11] "[ctb]"      "[ctb]"      "[ctb]"      "[ctb]"      "[ctb]"     
    # [16] "[ctb]"      "[ctb]"      "[ctb]"      "[ctb]"      "[ctb]"     
    # [21] "[ctb]"      "[ctb]"      "[ctb]"      "[ctb]"      "[ctb]"     
    # [26] "[ctb]"      "[ctb]"      "[ctb]"      "[ctb]"      "[ctb]"     
    # [31] "[ctb]"      "[ctb]"      "[ctb]"      "[ctb]"      "[ctb]"     
    # [36] "[ctb]"      "[ctb]"      "[ctb]"      "[ctb]"      "[ctb]"     
    # [41] "[ctb]"      "[ctb]"      "[ctb]"      "[ctb]"      "[ctb]"     
    # [46] "[ctb]"      "[ctb]"      "[ctb]"      "[ctb]"      "[ctb]"     
    # [51] "[ctb]"      "[ctb]"      "[ctb]"      "[ctb]"      "[ctb]"     
    # [56] "[ctb]"      "[ctb]"      "[ctb]"      "[ctb]"      "[ctb]"

data.table 的维护者，建立60个贡献者到维护者的有向图关系

    # [1] "Matt Dowle <mattjdowle@gmail.com>"

直接依赖 data.table 的 R 包近 1000 个

    #    [1] "Ac3net"                       
    #    [2] "actel"                        
    #    [3] "ActivePathways"               
    #    [4] "ActivityIndex"                
    #    [5] "AdhereR"                      
    #    [6] "AdhereRViz"                   
    ....

若算上逆向间接依赖的数量，则多达 2700 多个 R 包。

前向依赖更是达到了惊人的 4350 个 R 包

<figure>
<img src="https://user-images.githubusercontent.com/12031874/138590902-8d631fc8-37d2-4adc-8710-561cefe40697.jpg" style="width:55.0%" alt="图 10: R 包依赖关系网络" />
<figcaption aria-hidden="true">图 10: R 包依赖关系网络</figcaption>
</figure>

<!-- 
# 案例：博客网络分析

2021-11-25 再发10篇文章后，才做此分析 

我和益辉的文章有很大的相似性，各自文章内的相似性，二者文章间的相似性。
节点和边的定义，仿照落园园主的金庸小说做法。
-->

# 未来展望

远期规划：掌握网络分析，有一定的架构思维，建立全局意识。

中期规划：Query 网络，需求结构分析，掌握 Gephi 等软件，大规模图计算的一般原理，能够使用企业级图计算引擎解决 Query 网络计算。

短期规划：网络结构分析，不同的网络结构对应什么样的未来发展，对整个生态有什么影响？要采取什么样的措施去不断调整网络结构促使朝着正确的方向发展？

R 语言做网络分析的综述，以 CRAN 日志数据为例做介绍。不要乱发散。

社区组织分析
目标是什么？发掘生态的秘密，同时将 Python 社区模块的元数据提取出来，作为对比。
组织的数量，组织增长

CRAN 团队，引领的 R 包，头部集中的趋势。随机过程里面，两级分化加剧，国家不断调整结构，同样地，CRAN 团队如何引领，让社区朝着健康的形态发展，也是非常重要的。开源社区和商业组织的关系？
RStudio PBC 的商业模式是和开源社区关联在一起的。

# 环境信息

在 RStudio IDE 内编辑本文的 R Markdown 源文件，用 **blogdown** 构建网站，[Hugo](https://github.com/gohugoio/hugo) 渲染 knitr 之后的 Markdown 文件，得益于 **blogdown** 对 R Markdown 格式的支持，图、表和参考文献的交叉引用非常方便，省了不少文字编辑功夫。文中使用了多个 R 包，为方便复现本文内容，下面列出详细的环境信息：

``` r
xfun::session_info(packages = c(
  "knitr", "rmarkdown", "blogdown",
  "igraphdata", "igraph", "graph",
  "BiocManager", "Rgraphviz", "pkgDepTools",
  "ggplot2", "RBGL"
), dependencies = FALSE)
# R version 4.2.0 (2022-04-22)
# Platform: x86_64-apple-darwin17.0 (64-bit)
# Running under: macOS Big Sur/Monterey 10.16
# 
# Locale: en_US.UTF-8 / en_US.UTF-8 / en_US.UTF-8 / C / en_US.UTF-8 / en_US.UTF-8
# 
# Package version:
#   BiocManager_1.30.17 blogdown_1.9        ggplot2_3.3.5      
#   graph_1.73.0        igraph_1.3.1        igraphdata_1.0.1   
#   knitr_1.39          pkgDepTools_1.61.0  RBGL_1.71.0        
#   Rgraphviz_2.39.1    rmarkdown_2.14     
# 
# Pandoc version: 2.17.1.1
# 
# Hugo version: 0.91.2
```

# 参考文献

<div id="refs" class="references csl-bib-body hanging-indent">

<div id="ref-networkD3" class="csl-entry">

Allaire, J. J., Christopher Gandrud, Kenton Russell, and CJ Yetman. 2017. *networkD3: D3 JavaScript Network Graphs from r*. <https://CRAN.R-project.org/package=networkD3>.

</div>

<div id="ref-visNetwork" class="csl-entry">

Almende B.V. and Contributors, Benoit Thieurmel, and Titouan Robert. 2021. *visNetwork: Network Visualization Using Vis.js Library*. <http://datastorm-open.github.io/visNetwork/>.

</div>

<div id="ref-DoubleML2021" class="csl-entry">

Bach, P., V. Chernozhukov, M. S. Kurz, and M. Spindler. 2021. “DoubleML – An Object-Oriented Implementation of Double Machine Learning in R.” <https://arxiv.org/abs/2103.09603>.

</div>

<div id="ref-Bates2013" class="csl-entry">

Bates, Douglas, and Dirk Eddelbuettel. 2013. “Fast and Elegant Numerical Linear Algebra Using the RcppEigen Package.” *Journal of Statistical Software* 52 (5): 1–24. <https://www.jstatsoft.org/v52/i05/>.

</div>

<div id="ref-DrWhy2021" class="csl-entry">

Biecek, Przemyslaw. 2021. *DrWhy: Explain, Explore and Debug Predictive Machine Learning Models*. <https://github.com/ModelOriented/DrWhy>.

</div>

<div id="ref-ggnetwork" class="csl-entry">

Briatte, François. 2021. *Ggnetwork: Geometries to Plot Networks with Ggplot2*. <https://github.com/briatte/ggnetwork>.

</div>

<div id="ref-sna" class="csl-entry">

Butts, Carter T. 2020. *Sna: Tools for Social Network Analysis*. <http://statnet.org>.

</div>

<div id="ref-network" class="csl-entry">

———. 2021. *Network: Classes for Relational Data*. <http://statnet.org/>.

</div>

<div id="ref-Chernozhukov2018" class="csl-entry">

Chernozhukov, Victor, Denis Chetverikov, Mert Demirer, Esther Duflo, Christian Hansen, Whitney Newey, and James Robins. 2018. “Double/Debiased Machine Learning for Treatment and Structural Parameters.” *The Econometrics Journal* 21 (1): C1–68. <https://doi.org/10.1111/ectj.12097>.

</div>

<div id="ref-mlpack2018" class="csl-entry">

Curtin, Ryan R., Marcus Edel, Mikhail Lozhnikov, Yannis Mentekidis, Sumedh Ghaisas, and Shangtong Zhang. 2018. “Mlpack 3: A Fast, Flexible Machine Learning Library.” *Journal of Open Source Software* 3: 726. <https://doi.org/10.21105/joss.00726>.

</div>

<div id="ref-qgraph" class="csl-entry">

Epskamp, Sacha, Giulio Costantini, Jonas Haslbeck, and Adela Isvoranu. 2022. *Qgraph: Graph Plotting Methods, Psychometric Data Visualization and Graphical Model Estimation*. <https://CRAN.R-project.org/package=qgraph>.

</div>

<div id="ref-qgraph2012" class="csl-entry">

Epskamp, Sacha, Angélique O. J. Cramer, Lourens J. Waldorp, Verena D. Schmittmann, and Denny Borsboom. 2012. “<span class="nocase">qgraph</span>: Network Visualizations of Relationships in Psychometric Data.” *Journal of Statistical Software* 48 (4): 1–18.

</div>

<div id="ref-igraph" class="csl-entry">

file., See AUTHORS. 2022. *Igraph: Network Analysis and Visualization*. <https://CRAN.R-project.org/package=igraph>.

</div>

<div id="ref-Grover2016" class="csl-entry">

Grover, Aditya, and Jure Leskovec. 2016. “Node2vec: Scalable Feature Learning for Networks.” In *Proceedings of the 22nd ACM SIGKDD International Conference on Knowledge Discovery and Data Mining*, 855–64. KDD ’16. New York, NY, USA: Association for Computing Machinery. <https://doi.org/10.1145/2939672.2939754>.

</div>

<div id="ref-statnet" class="csl-entry">

Handcock, Mark S., David R. Hunter, Carter T. Butts, Steven M. Goodreau, Pavel N. Krivitsky, Skye Bender-deMoll, and Martina Morris. 2019. *Statnet: Software Tools for the Statistical Analysis of Network Data*. <http://statnet.org>.

</div>

<div id="ref-DiagrammeR" class="csl-entry">

Iannone, Richard. 2022. *DiagrammeR: Graph/Network Visualization*. <https://github.com/rich-iannone/DiagrammeR>.

</div>

<div id="ref-Kolaczyk2014" class="csl-entry">

Kolaczyk, Eric D., and Gábor Csárdi. 2014. *Statistical Analysis of Network Data with R*. Springer, New York, NY. <https://doi.org/10.1007/978-1-4939-0983-4>.

</div>

<div id="ref-Kolaczyk2020" class="csl-entry">

———. 2020. *Statistical Analysis of Network Data with R*. 2nd ed. Springer, New York, NY. <https://doi.org/10.1007/978-3-030-44129-6>.

</div>

<div id="ref-sand" class="csl-entry">

Kolaczyk, Eric, and Gábor Csárdi. 2020. *Sand: Statistical Analysis of Network Data with r, 2nd Edition*. <https://github.com/kolaczyk/sand>.

</div>

<div id="ref-Kuhn2020" class="csl-entry">

Kuhn, Max, and Hadley Wickham. 2020. *<span class="nocase">tidymodels</span>: A Collection of Packages for Modeling and Machine Learning Using <span class="nocase">tidyverse</span> Principles.* <https://www.tidymodels.org>.

</div>

<div id="ref-Lang2021" class="csl-entry">

Lang, Michel, and Patrick Schratz. 2021. *<span class="nocase">mlr3verse</span>: Easily Install and Load the <span class="nocase">mlr3</span> Package Family*. <https://CRAN.R-project.org/package=mlr3verse>.

</div>

<div id="ref-Daniel2019" class="csl-entry">

Lüdecke, Daniel. 2019. *<span class="nocase">strengejacke</span>: Load Packages Associated with Strenge Jacke!* <https://github.com/strengejacke/strengejacke>.

</div>

<div id="ref-Luke2015" class="csl-entry">

Luke, Douglas. 2015. *A User’s Guide to Network Analysis in r*. Springer, Cham. <https://doi.org/10.1007/978-3-319-23883-8>.

</div>

<div id="ref-Makowski2020" class="csl-entry">

Makowski, Dominique, Mattan S. Ben-Shachar, and Daniel Lüdecke. 2020. “The <span class="nocase">easystats</span> Collection of r Packages.” *GitHub*. <https://github.com/easystats/easystats>.

</div>

<div id="ref-BDgraph2019" class="csl-entry">

Mohammadi, Reza, and Ernst C. Wit. 2019. “BDgraph: An R Package for Bayesian Structure Learning in Graphical Models.” *Journal of Statistical Software* 89 (3): 1–30. <https://doi.org/10.18637/jss.v089.i03>.

</div>

<div id="ref-ggraph" class="csl-entry">

Pedersen, Thomas Lin. 2021. *Ggraph: An Implementation of Grammar of Graphics for Graphs and Networks*. <https://CRAN.R-project.org/package=ggraph>.

</div>

<div id="ref-tidygraph" class="csl-entry">

———. 2022. *Tidygraph: A Tidy API for Graph Manipulation*. <https://CRAN.R-project.org/package=tidygraph>.

</div>

<div id="ref-GGally" class="csl-entry">

Schloerke, Barret, Di Cook, Joseph Larmarange, Francois Briatte, Moritz Marbach, Edwin Thoen, Amos Elberg, and Jason Crowley. 2021. *GGally: Extension to Ggplot2*. <https://CRAN.R-project.org/package=GGally>.

</div>

<div id="ref-graphlayouts" class="csl-entry">

Schoch, David. 2022. *Graphlayouts: Additional Layout Algorithms for Network Visualizations*. <https://CRAN.R-project.org/package=graphlayouts>.

</div>

<div id="ref-text2map2021" class="csl-entry">

Stoltz, Dustin, and Marshall Taylor. 2021. *<span class="nocase">text2map</span>: R Tools for Text Matrices, Embeddings, and Networks*. <https://CRAN.R-project.org/package=text2map>.

</div>

<div id="ref-node2vec" class="csl-entry">

Tian, Yang, Xu Li, and Jing Ren. 2021. *Node2vec: Algorithmic Framework for Representational Learning on Graphs*. <https://CRAN.R-project.org/package=node2vec>.

</div>

<div id="ref-Tyner2017" class="csl-entry">

Tyner, Sam, François Briatte, and Heike Hofmann. 2017. “Network Visualization with <span class="nocase">ggplot2</span>.” *The R Journal* 9 (1): 27–59. <https://doi.org/10.32614/RJ-2017-023>.

</div>

<div id="ref-Wickham2019" class="csl-entry">

Wickham, Hadley, Mara Averick, Jennifer Bryan, Winston Chang, Lucy D’Agostino McGowan, Romain François, Garrett Grolemund, et al. 2019. “Welcome to the <span class="nocase">tidyverse</span>.” *Journal of Open Source Software* 4 (43): 1686. <https://doi.org/10.21105/joss.01686>.

</div>

</div>

[^1]: <https://en.wikipedia.org/wiki/Seven_Bridges_of_K%C3%B6nigsberg>
