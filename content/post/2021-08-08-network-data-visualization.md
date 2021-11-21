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

本文首先概览 R 语言在网络数据分析和可视化方面的情况；然后介绍图的表示（矩阵），图的计算（矩阵计算），图的展示（点、线等），图的工具（R 和其它软件）；最后以 CRAN 上 R 包的元数据为基础，介绍网络分析和可视化的过程，也发现了 R 语言社区中一些非常有意思的现象。

网络图是表示节点之间关系的图，核心在于关系的刻画， 用来表达网络关系的是稀疏矩阵，以及为处理这种矩阵而专门优化的矩阵计算库，如 Matrix 和 RcppEigen，PageRank 应该是大家最为熟悉的网络数据挖掘算法，图关系挖掘和计算的应用场景非常广泛，如推荐、搜索等。

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

| R 包                                                                                          | 简介                                                             | 维护者              | 网站                                                                               | 协议                 |
|:----------------------------------------------------------------------------------------------|:-----------------------------------------------------------------|:--------------------|:-----------------------------------------------------------------------------------|:---------------------|
| **visNetwork** ([Almende B.V. and Contributors, Thieurmel, and Robert 2021](#ref-visNetwork)) | Network Visualization using vis.js Library                       | Benoit Thieurmel    | http://datastorm-open.github.io/visNetwork/                                        | MIT + file LICENSE   |
| **graphlayouts** ([Schoch 2020](#ref-graphlayouts))                                           | Additional Layout Algorithms for Network Visualizations          | David Schoch        | http://graphlayouts.schochastics.net/ https://github.com/schochastics/graphlayouts | MIT + file LICENSE   |
| **ggnetwork** ([Briatte 2021](#ref-ggnetwork))                                                | Geometries to Plot Networks with ggplot2                         | François Briatte    | https://github.com/briatte/ggnetwork                                               | GPL-3                |
| **statnet** ([Handcock et al. 2019](#ref-statnet))                                            | Software Tools for the Statistical Analysis of Network Data      | Martina Morris      | http://statnet.org                                                                 | GPL-3 + file LICENSE |
| **DiagrammeR** ([Iannone 2020](#ref-DiagrammeR))                                              | Graph/Network Visualization                                      | Richard Iannone     | https://github.com/rich-iannone/DiagrammeR                                         | MIT + file LICENSE   |
| **igraph** ([file. 2021](#ref-igraph))                                                        | Network Analysis and Visualization                               | Tamás Nepusz        | https://igraph.org                                                                 | GPL (>= 2)           |
| **ggraph** ([Pedersen 2021](#ref-ggraph))                                                     | An Implementation of Grammar of Graphics for Graphs and Networks | Thomas Lin Pedersen | https://ggraph.data-imaginist.com https://github.com/thomasp85/ggraph              | MIT + file LICENSE   |
| **tidygraph** ([Pedersen 2020](#ref-tidygraph))                                               | A Tidy API for Graph Manipulation                                | Thomas Lin Pedersen | https://tidygraph.data-imaginist.com https://github.com/thomasp85/tidygraph        | MIT + file LICENSE   |

Table 1: 网络分析的 R 包（排名不分先后）

推荐 Github 上 [超棒的网络分析](https://github.com/briatte/awesome-network-analysis) 资源集合，ggplot2 关于网络数据可视化的[介绍](https://ggplot2-book.org/networks.html)，阅读 Erick Kolaczyk 的书籍《Statistical Analysis of Network Data with R》([Kolaczyk and Csárdi 2014](#ref-Kolaczyk2014))和发表在《R Journal》上的文章《Network Visualization with ggplot2》([Tyner, Briatte, and Hofmann 2017](#ref-Tyner2017))及其配套 R 包 [ggnetwork](https://github.com/briatte/ggnetwork)。Katherine Ognyanova 在个人博客上持续维护的材料 — [Static and dynamic network visualization with R](https://kateto.net/network-visualization)，David Schoch 介绍用 R 包 ggraph 和 graphlayouts 做网络数据可视化的材料 — [Network Visualizations in R: using ggraph and graphlayouts](http://mr.schochastics.net/netVizR.html)，Albert-László Barabási 的在线书籍[《Network Science》](http://networksciencebook.com/)，Douglas Luke 的《A User’s Guide to Network Analysis in R》([Luke 2015](#ref-Luke2015))。无论是软件工具还是相关文献，笔者相信这只是列举了很小的一部分而已，但是应该足够应付绝大部分使用场景，读者若还有补充，欢迎来统计之都论坛留言评论 — [中等规模及以上的网络图，怎么用 R 高效地绘制](https://d.cosx.org/d/419292)或灌水 — [R 社区的开发人员知多少](https://d.cosx.org/d/420670)。

# 网络基础

## 安装

Rgraphviz [Graphviz](https://www.graphviz.org/)

``` r
if(!"BiocManager" %in% .packages(T)) install.packages("BiocManager")
if(!"graph" %in% .packages(T)) BiocManager::install(pkgs = "graph")
if(!"Rgraphviz" %in% .packages(T)) BiocManager::install(pkgs = "Rgraphviz")
```

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
<img src="https://user-images.githubusercontent.com/12031874/67205314-193da500-f442-11e9-834f-2617220aa084.png" style="width:35.0%" alt="Figure 2: 用 graph 包绘制4个顶点的简单网络图" /><figcaption aria-hidden="true">Figure 2: 用 <strong>graph</strong> 包绘制4个顶点的简单网络图</figcaption>
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
```

V 和 M 的数量，以及 p 的值决定图的稠密程度。

``` r
plot(g2)
```

<figure>
<img src="https://user-images.githubusercontent.com/12031874/67205315-193da500-f442-11e9-88c8-e053a35a2168.png" style="width:45.0%" alt="Figure 3: 用 graph 包生成10个顶点的随机网络图" /><figcaption aria-hidden="true">Figure 3: 用 <strong>graph</strong> 包生成10个顶点的随机网络图</figcaption>
</figure>

换个布局

``` r
plot(g2, "neato")
```

<figure>
<img src="https://user-images.githubusercontent.com/12031874/67205319-19d63b80-f442-11e9-83c8-6c68b1793526.png" style="width:55.0%" alt="Figure 4: neato 布局" /><figcaption aria-hidden="true">Figure 4: neato 布局</figcaption>
</figure>

``` r
plot(g2, "twopi")
```

<figure>
<img src="https://user-images.githubusercontent.com/12031874/67205321-19d63b80-f442-11e9-88e0-b783d3daa5f7.png" style="width:55.0%" alt="Figure 5: twopi 布局" /><figcaption aria-hidden="true">Figure 5: twopi 布局</figcaption>
</figure>

# CRAN 关系网络

network-with-r 基于 CRAN 数据，分析 R 语言社区开发者关系网络。首先展示当前 R 语言社区的一些基本概览信息，目的是让外行或入坑不深的人有所了解。
分析对象是人及其关系，价值会更高，更能吸引读者，其次 R 包依赖和贡献关系。
邮箱后缀 @符号后面的部分，根据邮箱查所属国家，地区，开发者的邮箱分布，所属大学、企业分布。单个人物和集体人物。
在 R 会开始之前发出来，比较应景。已经在这个事情上搞来搞去，搞了很多时间了，今天算是交作业了。围绕生态环境来写和分析，最后思考，如何引领，站在核心开发者的视角，基金会的视角来看，对统计之都有没有一些启示。

[R 语言历史—再回首，已恍然如梦](http://blog.revolutionanalytics.com/2017/10/updated-history-of-r.html) 歌声响起。

[明朝那些事儿的那些事儿](https://bjt.name/2012/09/04/ming-dynasty.html) 人物关系分析，

[十八般武艺，谁主天下？](https://cosx.org/2013/02/jinyong-fiction-mining)。

[谈学习](https://d.cosx.org/d/419662)贴了一个 R 包作者关系网络的例子，

[如何提取R包中贡献者名字](https://d.cosx.org/d/419629)，

``` r
# 逆向依赖
tools::package_dependencies(reverse = TRUE, which = "most", recursive = "strong")
```

``` r
Sys.setenv(R_CRAN_WEB = "https://mirrors.tuna.tsinghua.edu.cn/CRAN")
pdb <- tools::CRAN_package_db()
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
<img src="https://user-images.githubusercontent.com/12031874/138590902-8d631fc8-37d2-4adc-8710-561cefe40697.jpg" style="width:55.0%" alt="Figure 6: R 包依赖关系网络" /><figcaption aria-hidden="true">Figure 6: R 包依赖关系网络</figcaption>
</figure>

# 环境信息

在 RStudio IDE 内编辑本文的 R Markdown 源文件，用 **blogdown** 构建网站，[Hugo](https://github.com/gohugoio/hugo) 渲染 knitr 之后的 Markdown 文件，得益于 **blogdown** 对 R Markdown 格式的支持，图、表和参考文献的交叉引用非常方便，省了不少文字编辑功夫。文中使用了多个 R 包，为方便复现本文内容，下面列出详细的环境信息：

``` r
xfun::session_info(packages = c(
  "knitr", "rmarkdown", "blogdown", "data.table"
))
# R version 4.1.2 (2021-11-01)
# Platform: x86_64-apple-darwin17.0 (64-bit)
# Running under: macOS Big Sur 10.16
# 
# Locale: en_US.UTF-8 / en_US.UTF-8 / en_US.UTF-8 / C / en_US.UTF-8 / en_US.UTF-8
# 
# Package version:
#   base64enc_0.1.3   blogdown_1.6      bookdown_0.24    
#   data.table_1.14.2 digest_0.6.28     evaluate_0.14    
#   fastmap_1.1.0     glue_1.5.0        graphics_4.1.2   
#   grDevices_4.1.2   highr_0.9         htmltools_0.5.2  
#   httpuv_1.6.3      jquerylib_0.1.4   jsonlite_1.7.2   
#   knitr_1.36        later_1.3.0       magrittr_2.0.1   
#   methods_4.1.2     mime_0.12         promises_1.2.0.1 
#   R6_2.5.1          Rcpp_1.0.7        rlang_0.4.12     
#   rmarkdown_2.11    servr_0.24        stats_4.1.2      
#   stringi_1.7.5     stringr_1.4.0     tinytex_0.35     
#   tools_4.1.2       utils_4.1.2       xfun_0.28        
#   yaml_2.2.1       
# 
# Pandoc version: 2.16.1
# 
# Hugo version: 0.89.2
```

# 参考文献

<div id="refs" class="references csl-bib-body hanging-indent">

<div id="ref-visNetwork" class="csl-entry">

Almende B.V. and Contributors, Benoit Thieurmel, and Titouan Robert. 2021. *visNetwork: Network Visualization Using Vis.js Library*. <http://datastorm-open.github.io/visNetwork/>.

</div>

<div id="ref-ggnetwork" class="csl-entry">

Briatte, François. 2021. *Ggnetwork: Geometries to Plot Networks with Ggplot2*. <https://github.com/briatte/ggnetwork>.

</div>

<div id="ref-igraph" class="csl-entry">

file., See AUTHORS. 2021. *Igraph: Network Analysis and Visualization*. <https://igraph.org>.

</div>

<div id="ref-statnet" class="csl-entry">

Handcock, Mark S., David R. Hunter, Carter T. Butts, Steven M. Goodreau, Pavel N. Krivitsky, Skye Bender-deMoll, and Martina Morris. 2019. *Statnet: Software Tools for the Statistical Analysis of Network Data*. <http://statnet.org>.

</div>

<div id="ref-DiagrammeR" class="csl-entry">

Iannone, Richard. 2020. *DiagrammeR: Graph/Network Visualization*. <https://github.com/rich-iannone/DiagrammeR>.

</div>

<div id="ref-Kolaczyk2014" class="csl-entry">

Kolaczyk, Eric D., and Gábor Csárdi. 2014. *Statistical Analysis of Network Data with r*. Springer, New York, NY. <https://doi.org/10.1007/978-1-4939-0983-4>.

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

<div id="ref-graphlayouts" class="csl-entry">

Schoch, David. 2020. *Graphlayouts: Additional Layout Algorithms for Network Visualizations*. <https://CRAN.R-project.org/package=graphlayouts>.

</div>

<div id="ref-Tyner2017" class="csl-entry">

Tyner, Sam, François Briatte, and Heike Hofmann. 2017. “<span class="nocase">Network Visualization with ggplot2</span>.” *The R Journal* 9 (1): 27–59. <https://doi.org/10.32614/RJ-2017-023>.

</div>

</div>
