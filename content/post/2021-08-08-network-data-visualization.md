---
title: 网络数据可视化与 R 语言
author: 黄湘云
date: '2021-11-08'
slug: network-data-visualization
categories:
  - 统计图形
tags:
  - 网络分析
  - ggplot2
  - Rgraphviz
  - igraph 
  - DiagrammeR
bibliography: 
  - refer.bib
  - packages.bib
draft: true
toc: true
thumbnail: /img/DiagrammeR.svg
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
</style>

<div class="rmdtip">

时隔四年，Gephi 发布了 0.9.3 版，写一篇文章庆祝一下。

</div>

本文首先概览 R 语言在网络数据分析和可视化方面的情况；然后介绍图的表示（矩阵），图的计算（矩阵计算），图的展示（点、线等），图的工具（R 和其它软件）；最后以 CRAN 上 R 包的元数据为基础，介绍网络分析和可视化的过程，也发现了 R 语言社区中一些非常有意思的现象。

网络图是表示节点之间关系的图，核心在于关系的刻画， 用来表达网络关系的是稀疏矩阵，以及为处理这种矩阵而专门优化的矩阵计算库，如 **Matrix** 、[**rsparse**](https://github.com/rexyai/rsparse)和 **RcppEigen** ([Bates and Eddelbuettel 2013](#ref-Bates2013))，PageRank 应该是大家最为熟悉的网络数据挖掘算法，图关系挖掘和计算的应用场景非常广泛，如社交推荐（社交 App）、风险控制（银行征信、企业查）、深度学习（图神经网络）、知识图谱（商户、商家、客户的实体关系网络）、区块链、物联网（IoT）、反洗钱（金融监管）、数据治理（数据血缘图谱）等。

企业级的图存储和计算框架，比较有名（可能是最有名的），反正，笔者最先听说的是[Neo4j](https://github.com/neo4j/neo4j) ，它有以 AGPL 协议发布的开源版本，还有商业版本。[Nebula Graph](https://github.com/vesoft-inc/nebula) 分布式开源图数据库，高扩展性和高可用性，支持千亿节点、万亿条边、毫秒级查询，有[中文文档](https://github.com/vesoft-inc/nebula-docs-cn/)，有企业应用案例，[美团图数据库平台建设及业务实践](https://mp.weixin.qq.com/s/aYd5tqwogJYfkJXhVNuNpg)。阿里研发的[GraphScope](https://github.com/alibaba/GraphScope) 提供一站式大规模图计算系统，支持图神经网络计算。[HugeGraph](https://github.com/hugegraph/hugegraph)图数据库应用于[金融反欺诈实践](https://zhuanlan.zhihu.com/p/114665466)。

[node2vec](https://cran.r-project.org/package=node2vec)包实现等人提出的大规模网络特征学习([Grover and Leskovec 2016](#ref-Grover2016))。[networkx](https://github.com/networkx/networkx)是做网络分析的 Python 模块。
[**rsparse**](https://github.com/rexyai/rsparse) 包提供很多基于稀疏矩阵的统计学习算法，支持基于 OpenMP 的并行计算。[RSpectra](https://github.com/yixuan/RSpectra) 包是 C++ 库 [Spectra](https://spectralib.org/) 的 R 接口，仅有两个函数 `eigs()` 和 `svds()` 分别用来计算 `\(N\)` 阶矩阵（稀疏或稠密都行） Top K 个最大的特征值/特征向量，适合大规模特征值和奇异值分解问题，在 k 远远小于 N 时，特别能体现优越性。后面从 CRAN 网络数据中获取 Top K 个主要的组织、个人和 R 包。

<!--
葛底斯堡战役七桥问题，图作为文章 logo

[**RcppSparse**](https://github.com/zdebruine/RcppSparse)  RcppArmadillo 和 RcppEigen 深拷贝deep copy 操作，而 RcppSparse zero-copy 零拷贝，无缝衔接，而计算结果是一致的，详细描述见 [Constructing a Sparse Matrix Class in Rcpp](https://gallery.rcpp.org/articles/sparse-matrix-class/)
-->

# 软件概览

[igraph](https://github.com/igraph/igraph) 是非常流行和核心的网络分析 C 语言库，它提供有多种语言的接口，其 R 语言接口 [igraph](https://github.com/igraph/rigraph) 包也被很多其它做网络分析的 R 包所引用。开源的 [Gephi](https://github.com/gephi/gephi) 软件适合处理中等规模的网络分析和可视化。大规模图计算可以用 Apache Spark 的 [GraphX](https://spark.apache.org/graphx/)。R 语言这层，主要还是对应数据分析和数据产品，用于在内部咨询和商业分析。

[David Schoch](http://mr.schochastics.net/) 开发的 [graphlayouts](https://github.com/schochastics/graphlayouts) 包添加布局算法用于网络可视化，他个人网站上还有一些介绍 R 语言网络分析的文章。他开发的另一个 R 包[networkdata](https://github.com/schochastics/networkdata)收集了**980**个网络相关的数据集，用于教学、文章和书籍介绍相关知识应该足够，用不着自己还到处去找了。Thomas Lin Pedersen 开发的[ggraph](https://github.com/thomasp85/ggraph)包实现图和网络的绘图语法，类似 ggplot2 的设计，和以往的使用习惯保持一致，这就非常方便。他开发的另一个 R 包[tidygraph](https://github.com/thomasp85/tidygraph) 将净土应用到图操作上面。Martina Morris 等人开发了一批用于网络分析和建模的 R 包，类似 tidyverse 的做法都整合在 [statnet](https://github.com/statnet) 包里。

[visNetwork](https://github.com/datastorm-open/visNetwork) 包 可以制作交互式网络图形，Richard Iannone 而开发的[DiagrammeR](https://github.com/rich-iannone/DiagrammeR) 包可以制作静态的矢量网页图形。

<div class="rmdnote">

[networkD3](https://github.com/christophergandrud/networkD3) CRAN 上次更新还在 2017 年，[Sam Tyner](https://sctyner.me/) 开发的 [geomnet](https://github.com/sctyner/geomnet) 包给 ggplot2 添加了网络图层 `geom_net`，目前未在 CRAN 上发布。François Briatte 开发的 [ggnet](https://github.com/briatte/ggnet) 目前也未在 CRAN 上发布，但是其帮助文档值得一看，[](https://briatte.github.io/ggnet/)。

</div>

另一类表达关系的是流程图或项目架构图，比较流行的制作工具（软件）有[graphviz](https://gitlab.com/graphviz/graphviz)、[plantuml](https://github.com/plantuml/plantuml)、[drawio-desktop](https://github.com/jgraph/drawio-desktop) 和[flowchart.js](https://github.com/adrai/flowchart.js)。在 R Markdown 文档中，knitr 包可以调用 [Graphviz](https://www.graphviz.org/) 软件生成网络图并插入到文档中，而 [nomnoml](https://github.com/rstudio/nomnoml) 包没有外部软件依赖，非常方便，下图<a href="#fig:nomnoml">1</a>即为该 R 包制作。

<figure>
<img src="https://user-images.githubusercontent.com/12031874/120408326-6190a900-c381-11eb-9dcf-9881d33fa2b6.png" class="full" alt="Figure 1: 开发 R Shiny 应用的技术栈" /><figcaption aria-hidden="true">Figure 1: 开发 R Shiny 应用的技术栈</figcaption>
</figure>

| R 包                                                                                          | 简介                                                                                   | 维护者              | 协议                 |
|:----------------------------------------------------------------------------------------------|:---------------------------------------------------------------------------------------|:--------------------|:---------------------|
| **GGally** ([Schloerke et al. 2021](#ref-GGally))                                             | Extension to ggplot2                                                                   | Barret Schloerke    | GPL (>= 2.0)         |
| **visNetwork** ([Almende B.V. and Contributors, Thieurmel, and Robert 2021](#ref-visNetwork)) | Network Visualization using vis.js Library                                             | Benoit Thieurmel    | MIT + file LICENSE   |
| **network** ([Butts 2021](#ref-network))                                                      | Classes for Relational Data                                                            | Carter T. Butts     | GPL (>= 2)           |
| **sna** ([Butts 2020](#ref-sna))                                                              | Tools for Social Network Analysis                                                      | Carter T. Butts     | GPL (>= 2)           |
| **networkD3** ([Allaire et al. 2017](#ref-networkD3))                                         | D3 JavaScript Network Graphs from R                                                    | Christopher Gandrud | GPL (>= 3)           |
| **graphlayouts** ([Schoch 2020](#ref-graphlayouts))                                           | Additional Layout Algorithms for Network Visualizations                                | David Schoch        | MIT + file LICENSE   |
| **sand** ([E. Kolaczyk and Csárdi 2020](#ref-sand))                                           | Statistical Analysis of Network Data with R, 2nd Edition                               | Eric Kolaczyk       | GPL-3                |
| **ggnetwork** ([Briatte 2021](#ref-ggnetwork))                                                | Geometries to Plot Networks with ggplot2                                               | François Briatte    | GPL-3                |
| **statnet** ([Handcock et al. 2019](#ref-statnet))                                            | Software Tools for the Statistical Analysis of Network Data                            | Martina Morris      | GPL-3 + file LICENSE |
| **DiagrammeR** ([Iannone 2020](#ref-DiagrammeR))                                              | Graph/Network Visualization                                                            | Richard Iannone     | MIT + file LICENSE   |
| **qgraph** ([Epskamp et al. 2021](#ref-qgraph))                                               | Graph Plotting Methods, Psychometric Data Visualization and Graphical Model Estimation | Sacha Epskamp       | GPL-2                |
| **igraph** ([file. 2021](#ref-igraph))                                                        | Network Analysis and Visualization                                                     | Tamás Nepusz        | GPL (>= 2)           |
| **ggraph** ([Pedersen 2021](#ref-ggraph))                                                     | An Implementation of Grammar of Graphics for Graphs and Networks                       | Thomas Lin Pedersen | MIT + file LICENSE   |
| **tidygraph** ([Pedersen 2020](#ref-tidygraph))                                               | A Tidy API for Graph Manipulation                                                      | Thomas Lin Pedersen | MIT + file LICENSE   |
| **node2vec** ([Tian, Li, and Ren 2021](#ref-node2vec))                                        | Algorithmic Framework for Representational Learning on Graphs                          | Yang Tian           | GPL (>= 3)           |

Table 1: 网络分析的 R 包（排名不分先后）

推荐 Github 上 [超棒的网络分析](https://github.com/briatte/awesome-network-analysis) 资源集合，ggplot2 关于网络数据可视化的[介绍](https://ggplot2-book.org/networks.html)，阅读 Erick Kolaczyk 的书籍《Statistical Analysis of Network Data with R》([E. D. Kolaczyk and Csárdi 2014](#ref-Kolaczyk2014), [2020](#ref-Kolaczyk2020))和发表在《R Journal》上的文章《Network Visualization with ggplot2》([Tyner, Briatte, and Hofmann 2017](#ref-Tyner2017))及其配套 R 包 [ggnetwork](https://github.com/briatte/ggnetwork)。Katherine Ognyanova 在个人博客上持续维护的材料 — [Static and dynamic network visualization with R](https://kateto.net/network-visualization)，David Schoch 介绍用 R 包 ggraph 和 graphlayouts 做网络数据可视化的材料 — [Network Visualizations in R: using ggraph and graphlayouts](http://mr.schochastics.net/netVizR.html)，Albert-László Barabási 的在线书籍[《Network Science》](http://networksciencebook.com/)，Douglas Luke 的《A User’s Guide to Network Analysis in R》([Luke 2015](#ref-Luke2015))。无论是软件工具还是相关文献，笔者相信这只是列举了很小的一部分而已，但是应该足够应付绝大部分使用场景，读者若还有补充，欢迎来统计之都论坛留言评论 — [中等规模及以上的网络图，怎么用 R 高效地绘制](https://d.cosx.org/d/419292)或灌水 — [R 社区的开发人员知多少](https://d.cosx.org/d/420670)。

落园园主的博文[十八般武艺，谁主天下？](https://cosx.org/2013/02/jinyong-fiction-mining)分析金庸先生小说揭密最受欢迎的兵器，刘思喆的博文[从北京地铁规划再看地段的重要性](https://bjt.name/2021/02/13/subway.html)分析地铁网络寻找房价洼地。

# 网络基础

柯尼斯堡七桥问题：在所有桥都只走一遍的情况下，如何才能把这个地方所有的桥都走遍？欧拉将每一座桥抽象为一条线，桥所连接地区抽象为点[^1]。此处，用[tikz-network](https://ctan.org/pkg/tikz-network) 绘制网络图，如图<a href="#fig:seven-bridges">2</a>所示， `\(1,2,\cdots,7\)` 分别表示七座桥， `\(A,B,C,D\)` 分别表示四块区域。

<figure>
<img src="/img/seven-bridges.png" style="width:65.0%" alt="Figure 2: 欧拉用图抽象的柯尼斯堡七桥" /><figcaption aria-hidden="true">Figure 2: 欧拉用图抽象的柯尼斯堡七桥</figcaption>
</figure>

## 安装 R 包

Rgraphviz [Graphviz](https://www.graphviz.org/)

``` r
if(!"BiocManager" %in% .packages(T)) install.packages("BiocManager")
if(!"graph" %in% .packages(T)) BiocManager::install(pkgs = "graph")
if(!"Rgraphviz" %in% .packages(T)) BiocManager::install(pkgs = "Rgraphviz")
```

## 图的表示

## 图的计算

## 图的展示

4个节点，给定邻接矩阵，即可画出关系图

``` r
library(graph)
# Loading required package: BiocGenerics
# 
# Attaching package: 'BiocGenerics'
# The following objects are masked from 'package:stats':
# 
#     IQR, mad, sd, var, xtabs
# The following objects are masked from 'package:base':
# 
#     anyDuplicated, append, as.data.frame, basename, cbind,
#     colnames, dirname, do.call, duplicated, eval, evalq,
#     Filter, Find, get, grep, grepl, intersect, is.unsorted,
#     lapply, Map, mapply, match, mget, order, paste, pmax,
#     pmax.int, pmin, pmin.int, Position, rank, rbind, Reduce,
#     rownames, sapply, setdiff, sort, table, tapply, union,
#     unique, unsplit, which.max, which.min
mat <- matrix(c(
  0, 0, 1, 1,
  0, 0, 1, 1,
  1, 1, 0, 1,
  1, 1, 1, 0
), byrow = TRUE, ncol = 4)
rownames(mat) <- letters[1:4]
colnames(mat) <- letters[1:4]
```

``` r
g1 <- graphAM(adjMat = mat)
plot(g1)
```

<figure>
<img src="https://user-images.githubusercontent.com/12031874/67205314-193da500-f442-11e9-834f-2617220aa084.png" style="width:35.0%" alt="Figure 3: 用 graph 包绘制4个顶点的简单网络图" /><figcaption aria-hidden="true">Figure 3: 用 <strong>graph</strong> 包绘制4个顶点的简单网络图</figcaption>
</figure>

用函数 `randomGraph()` 随机生成一个网络图

``` r
set.seed(123)
V <- letters[1:10] # 图的顶点
M <- 1:4  # 选择生成图的
g2 <- randomGraph(V, M, p = 0.2)
numEdges(g2)  # 边的个数
# [1] 16
edgeNames(g2) # 边的名字，无向图顶点之间用 ~ 连接
#  [1] "a~b" "a~d" "a~e" "a~f" "a~h" "b~f" "b~d" "b~e" "b~h" "c~h"
# [11] "d~e" "d~f" "d~h" "e~f" "e~h" "f~h"
g2
# A graphNEL graph with undirected edges
# Number of Nodes = 10 
# Number of Edges = 16
edges(g2) # 边
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
edgeWeights(g2) # 边的权重
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

V 表示图的顶点， M 表示一组元素的集合，
p 表示从集合 M 中选出一个元素的概率。随机图的构造方法如下：
从 M 中以概率 p 选出一个元素，比如 1 （或者没有选），然后将 1 随机地指给 V 中的一个顶点 a，重复这个过程 4 次（次数取决于 M 中元素的个数）完成对一个顶点的随机指定，此时，顶点 a 对应一个长度为 4 的逻辑向量，有值的位置记为 TRUE，反之记为 FALSE，对其他顶点操作类似，这样就可以得到一个 10 \* 4 的矩阵。如果某一列有两个顶点共有一个元素，比如 1， 则这两个顶点有边连接，反之则无。如果两个顶点共用2和3两个元素，则连接两个顶点的边的权重为 2。可见，V 和 M 的数量，以及 p 的值决定图的稠密程度。

``` r
plot(g2)
```

<figure>
<img src="https://user-images.githubusercontent.com/12031874/67205315-193da500-f442-11e9-88c8-e053a35a2168.png" style="width:45.0%" alt="Figure 4: 用 graph 包生成10个顶点的随机网络图" /><figcaption aria-hidden="true">Figure 4: 用 <strong>graph</strong> 包生成10个顶点的随机网络图</figcaption>
</figure>

换个布局

``` r
plot(g2, "neato")
```

<figure>
<img src="https://user-images.githubusercontent.com/12031874/67205319-19d63b80-f442-11e9-83c8-6c68b1793526.png" style="width:55.0%" alt="Figure 5: neato 布局" /><figcaption aria-hidden="true">Figure 5: neato 布局</figcaption>
</figure>

``` r
plot(g2, "twopi")
```

<figure>
<img src="https://user-images.githubusercontent.com/12031874/67205321-19d63b80-f442-11e9-88e0-b783d3daa5f7.png" style="width:55.0%" alt="Figure 6: twopi 布局" /><figcaption aria-hidden="true">Figure 6: twopi 布局</figcaption>
</figure>

# CRAN 网络

之前肯定有人分析过，但是我的分析更加全面，更加深刻，涉及 R 包，开发者和组织生态三个层次。

network-with-r 基于 CRAN 数据，分析 R 语言社区开发者关系网络。首先展示当前 R 语言社区的一些基本概览信息，目的是让外行或入坑不深的人有所了解。
分析对象是人及其关系，价值会更高，更能吸引读者，其次 R 包依赖和贡献关系。
邮箱后缀 @符号后面的部分，根据邮箱查所属国家，地区，开发者的邮箱分布，所属大学、企业分布。单个人物和集体人物。
在 R 会开始之前发出来，比较应景。已经在这个事情上搞来搞去，搞了很多时间了，今天算是交作业了。围绕生态环境来写和分析，最后思考，如何引领，站在核心开发者的视角，基金会的视角来看，对统计之都有没有一些启示。

## R 包

只考虑 CRAN 范围内的数据

影响力
关键 R 包

用什么协议发布 MIT 还是 GPL
在什么平台开发，Github 还是线下

R 包关系
一度关系，安装 A 包，必须安装 B 包，则 B 包为 A 包的前置依赖。

## 开发者

关键开发者

所属组织性质，学校、公司

开发者关系

## 组织

关键组织

``` r
# 逆向依赖
tools::package_dependencies(reverse = TRUE, which = "most", recursive = "strong")
```

``` r
# 选择就近的 CRAN 镜像站点
Sys.setenv(R_CRAN_WEB = "https://mirrors.tuna.tsinghua.edu.cn/CRAN")
# 下载 R 包元数据
pdb <- tools::CRAN_package_db()
```

``` r
# 强依赖 igraph 包的 R 包
igraph_deps <- tools::dependsOnPkgs('igraph', installed = pdb, recursive = FALSE)
```

``` r
pdb2 <- subset(pdb, select = c("Package", "Maintainer"), subset = Package %in% igraph_deps)
pdb2
#                    Package
# 123               adegenet
# 188                    AFM
# 247                    akc
# 255               alakazam
# 357   AnimalHabitatNetwork
# 362               anipaths
# 431               apisensr
# 473             archeofrag
# 542              arulesViz
....
```

<figure>
<img src="https://user-images.githubusercontent.com/12031874/138590902-8d631fc8-37d2-4adc-8710-561cefe40697.jpg" style="width:55.0%" alt="Figure 7: R 包依赖关系网络" /><figcaption aria-hidden="true">Figure 7: R 包依赖关系网络</figcaption>
</figure>

# 环境信息

在 RStudio IDE 内编辑本文的 R Markdown 源文件，用 **blogdown** 构建网站，[Hugo](https://github.com/gohugoio/hugo) 渲染 knitr 之后的 Markdown 文件，得益于 **blogdown** 对 R Markdown 格式的支持，图、表和参考文献的交叉引用非常方便，省了不少文字编辑功夫。文中使用了多个 R 包，为方便复现本文内容，下面列出详细的环境信息：

``` r
xfun::session_info(packages = c(
  "knitr", "rmarkdown", "blogdown",
  "data.table", "node2vec"
))
# R version 4.1.2 (2021-11-01)
# Platform: x86_64-apple-darwin17.0 (64-bit)
# Running under: macOS Big Sur 10.16
# 
# Locale: en_US.UTF-8 / en_US.UTF-8 / en_US.UTF-8 / C / en_US.UTF-8 / en_US.UTF-8
# 
# Package version:
#   base64enc_0.1.3    blogdown_1.6       bookdown_0.24     
#   cli_3.1.0          cluster_2.1.2      crayon_1.4.2      
#   data.table_1.14.2  digest_0.6.28      dplyr_1.0.7       
#   ellipsis_0.3.2     evaluate_0.14      fansi_0.5.0       
#   fastmap_1.1.0      generics_0.1.1     glue_1.5.0        
#   graphics_4.1.2     grDevices_4.1.2    grid_4.1.2        
#   highr_0.9          htmltools_0.5.2    httpuv_1.6.3      
#   igraph_1.2.8       jquerylib_0.1.4    jsonlite_1.7.2    
#   knitr_1.36         later_1.3.0        lattice_0.20.45   
#   lifecycle_1.0.1    magrittr_2.0.1     MASS_7.3.54       
#   Matrix_1.3.4       methods_4.1.2      mgcv_1.8.38       
#   mime_0.12          nlme_3.1.153       node2vec_0.1.0    
#   permute_0.9.5      pillar_1.6.4       pkgconfig_2.0.3   
#   promises_1.2.0.1   purrr_0.3.4        R6_2.5.1          
#   Rcpp_1.0.7         RcppProgress_0.4.2 rlang_0.4.12      
#   rlist_0.4.6.2      rmarkdown_2.11     servr_0.24        
#   splines_4.1.2      stats_4.1.2        stringi_1.7.5     
#   stringr_1.4.0      tibble_3.1.6       tidyselect_1.1.1  
#   tinytex_0.35       tools_4.1.2        utf8_1.2.2        
#   utils_4.1.2        vctrs_0.3.8        vegan_2.5.7       
#   word2vec_0.3.4     xfun_0.28          XML_3.99.0.8      
#   yaml_2.2.1        
# 
# Pandoc version: 2.16.2
# 
# Hugo version: 0.89.4
```

# 参考文献

<div id="refs" class="references csl-bib-body hanging-indent">

<div id="ref-networkD3" class="csl-entry">

Allaire, J. J., Christopher Gandrud, Kenton Russell, and CJ Yetman. 2017. *networkD3: D3 JavaScript Network Graphs from r*. <https://CRAN.R-project.org/package=networkD3>.

</div>

<div id="ref-visNetwork" class="csl-entry">

Almende B.V. and Contributors, Benoit Thieurmel, and Titouan Robert. 2021. *visNetwork: Network Visualization Using Vis.js Library*. <http://datastorm-open.github.io/visNetwork/>.

</div>

<div id="ref-Bates2013" class="csl-entry">

Bates, Douglas, and Dirk Eddelbuettel. 2013. “Fast and Elegant Numerical Linear Algebra Using the RcppEigen Package.” *Journal of Statistical Software* 52 (5): 1–24. <https://www.jstatsoft.org/v52/i05/>.

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

<div id="ref-qgraph" class="csl-entry">

Epskamp, Sacha, Giulio Costantini, Jonas Haslbeck, and Adela Isvoranu. 2021. *Qgraph: Graph Plotting Methods, Psychometric Data Visualization and Graphical Model Estimation*. <https://CRAN.R-project.org/package=qgraph>.

</div>

<div id="ref-igraph" class="csl-entry">

file., See AUTHORS. 2021. *Igraph: Network Analysis and Visualization*. <https://igraph.org>.

</div>

<div id="ref-Grover2016" class="csl-entry">

Grover, Aditya, and Jure Leskovec. 2016. “Node2vec: Scalable Feature Learning for Networks.” In *Proceedings of the 22nd ACM SIGKDD International Conference on Knowledge Discovery and Data Mining*, 855–64. KDD ’16. New York, NY, USA: Association for Computing Machinery. <https://doi.org/10.1145/2939672.2939754>.

</div>

<div id="ref-statnet" class="csl-entry">

Handcock, Mark S., David R. Hunter, Carter T. Butts, Steven M. Goodreau, Pavel N. Krivitsky, Skye Bender-deMoll, and Martina Morris. 2019. *Statnet: Software Tools for the Statistical Analysis of Network Data*. <http://statnet.org>.

</div>

<div id="ref-DiagrammeR" class="csl-entry">

Iannone, Richard. 2020. *DiagrammeR: Graph/Network Visualization*. <https://github.com/rich-iannone/DiagrammeR>.

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

<div id="ref-Luke2015" class="csl-entry">

Luke, Douglas. 2015. *A User’s Guide to Network Analysis in r*. Springer, Cham. <https://doi.org/10.1007/978-3-319-23883-8>.

</div>

<div id="ref-tidygraph" class="csl-entry">

Pedersen, Thomas Lin. 2020. *Tidygraph: A Tidy API for Graph Manipulation*. <https://CRAN.R-project.org/package=tidygraph>.

</div>

<div id="ref-ggraph" class="csl-entry">

———. 2021. *Ggraph: An Implementation of Grammar of Graphics for Graphs and Networks*. <https://CRAN.R-project.org/package=ggraph>.

</div>

<div id="ref-GGally" class="csl-entry">

Schloerke, Barret, Di Cook, Joseph Larmarange, Francois Briatte, Moritz Marbach, Edwin Thoen, Amos Elberg, and Jason Crowley. 2021. *GGally: Extension to Ggplot2*. <https://CRAN.R-project.org/package=GGally>.

</div>

<div id="ref-graphlayouts" class="csl-entry">

Schoch, David. 2020. *Graphlayouts: Additional Layout Algorithms for Network Visualizations*. <https://CRAN.R-project.org/package=graphlayouts>.

</div>

<div id="ref-node2vec" class="csl-entry">

Tian, Yang, Xu Li, and Jing Ren. 2021. *Node2vec: Algorithmic Framework for Representational Learning on Graphs*. <https://CRAN.R-project.org/package=node2vec>.

</div>

<div id="ref-Tyner2017" class="csl-entry">

Tyner, Sam, François Briatte, and Heike Hofmann. 2017. “<span class="nocase">Network Visualization with ggplot2</span>.” *The R Journal* 9 (1): 27–59. <https://doi.org/10.32614/RJ-2017-023>.

</div>

</div>

[^1]: <https://en.wikipedia.org/wiki/Seven_Bridges_of_K%C3%B6nigsberg>
