---
date: "2021-11-13"
author: "黄湘云"
slug: data-product-with-shiny-app
title: 数据产品与 R Shiny 应用
toc: true
draft: true
categories:
  - 统计软件
tags:
  - 数据产品
  - R Shiny
  - R Markdown
  - DT
  - plotly
  - flexdashboard
bibliography: 
  - refer.bib
thumbnail: /img/shiny.svg
link-citations: true
description: "本文适合对 R 语言有一定了解的读者，准备将 R Shiny 和 R Markdown 作为生产力工具来使用，因此，本文将基于 R Shiny + R Markdown + Flexdashboard + Plotly + DT 从零开始搭建完整的网页应用模版，也将作为我在2021年中国 R 语言大会软件工具场的主要分享内容。"
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

.todo {
  display: block;
  border: 1px solid #4285f4;
  border-left-width: 5px;
  border-radius: 5px;
  padding: 0.5em 1em;
  margin: 1em 0;
}

.todo::before {
  content: "TO DO: ";
  font-weight: bold;
  color: #4285f4;
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

blockquote > p:last-child {
  text-align: right;
}
blockquote > p:first-child {
  text-align: inherit;
}

div.img {
  text-align: center;
  display: block; 
  margin-left: auto; 
  margin-right: auto;
}
</style>
<style type="text/css">
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
</style>

> 登险峰可观天下景，临深渊可识万人心。
>
> –— 《秦时明月之沧海横流·罗网之门》棠梨听雪

<div class="rmdinfo">

本文引用的所有信息均为公开信息，仅代表作者本人观点，与就职单位无关。

</div>

{{% figure src="/img/shiny.svg" width="25%" caption="R Shiny 框架" link="https://github.com/rstudio/shiny" alt="R Shiny 框架" target="_blank" %}}

1.  产品目标：什么是数据产品？为什么要做数据产品？
2.  行业竟对：目前行业内的数据产品有哪些类型？分别应用到什么场景下？
3.  工具生态：数据产品的左邻右舍？前驱后继上下游？
4.  技术架构：R 语言如何做数据产品的？之前怎么做，现在怎么做，未来会怎么做？
5.  未来展望：本文主要依赖 R 语言，未来会不会失业？数据产品这个行业未来会怎么样？

本文将围绕页面布局、筛选器、CSS 样式、SQL 渲染、交互图形和表格等方面，从零开始介绍一个完整的 Shiny 应用 制作过程，最终打造一个符合企业级水准的应用模版。所以，本文面向的是对 R 语言和 Shiny 框架有些基础的用户。在介绍内容干货之前，先讲讲为什么要用 R Shiny 来做数据型产品，以及数据型产品需要符合什么样的条件。R Shiny + R Markdown + Flexdashboard + Plotly + DT

从 tcltk ([Lawrence and Verzani 2012](#ref-Lawrence2012)) 到 RGtk2 ([Lawrence and Temple Lang 2010](#ref-RGtk2))，再到 Shiny，自 2001 年 Peter Dalgaard 在《R News》介绍 tcltk ([Dalgaard 2001](#ref-tcltk2001)) 算起，整整 20 年过去了， 打造数据产品的主力工具换了一茬又一茬，过程中出现了一些优秀的代表作品，基于 tcltk 的 Rcmdr ([Fox 2005](#ref-Rcmdr2005))，基于 RGtk2 的 rattle ([Williams 2011](#ref-Williams2011))，基于 Shiny 的 radiant ([Nijs 2021](#ref-radiant))。数据探索分析

[**Rcmdr**](https://socialsciences.mcmaster.ca/jfox/Misc/Rcmdr)

![](https://user-images.githubusercontent.com/12031874/142166767-92dcf166-7f62-44df-87dc-a923c1c64dc8.png)

rattle

![Figure 1: **rattle** 包：探索性分析与 R Shiny 应用](https://user-images.githubusercontent.com/12031874/142166760-91408f3a-1a30-4c0d-9e22-6e7993a678bc.png)

radiant

![Figure 2: **radiant** 包：探索性分析与 R Shiny 应用](https://user-images.githubusercontent.com/12031874/142166747-3c0f0f04-31c5-45cc-93a7-2d8da008df8f.png)

[**shinybrms**](https://github.com/fweber144/shinybrms)

![Figure 3: **shinybrms** 包：贝叶斯分析与 R Shiny 应用](https://user-images.githubusercontent.com/12031874/142166772-bfecdca9-f920-418e-8812-234a6c08ec85.png)

[**explor**](https://github.com/juba/explor)

<figure>
<img src="https://camo.githubusercontent.com/1c0263124ed874d655cfdb2aabaf983820eac1ed6b9bcda88a58af32f7d4c2f8/68747470733a2f2f7261772e6769746875622e636f6d2f6a7562612f6578706c6f722f6d61737465722f7265736f75726365732f73637265656e636173745f302e332e676966" class="full" alt="Figure 4: explor 包：多元分析与 R Shiny 应用" /><figcaption aria-hidden="true">Figure 4: <strong>explor</strong> 包：多元分析与 R Shiny 应用</figcaption>
</figure>

[Apache Superset](https://github.com/apache/superset) 是数据可视化（Data Visualization）和数据探索（Data Exploration）平台，同类产品有[Redash](https://github.com/getredash/redash)

[Apache ECharts](https://github.com/apache/echarts) 是交互式网页绘图和数据可视化的库，

同类产品有 [Plotly](https://github.com/plotly/plotly.js) 提供各种各样的图形，涵盖统计、三维、科学、地理、金融等五大类。

[bokeh](https://github.com/bokeh/bokeh) 是一个交互式网页可视化的 Python 模块

[Observable Plot](https://github.com/observablehq/plot) 探索性数据可视化，像是 Jupyter Notebook 和 bokeh 的合体。

[D3](https://github.com/d3/d3) 采用 Web 标准的数据可视化库，支持 SVG、Canvas 和 HTML 渲染方式。

[fastpages](https://github.com/fastai/fastpages) 是易于使用的博客平台，深度结合静态网站生成器[Jekyll](https://github.com/jekyll/jekyll)，有来自 Jupyter Notebook 的增强支持，可以让博客看起来是一个个的数据报告或仪表盘，以 [COVID-19](https://github.com/github/covid19-dashboard) 为例，可以看出它是 blogdown + R Markdown + Netlify + Hugo + Pandoc 的合体。

以数据产品承载数据分析模型，交互式探索性数据分析

交互图形用于，

做数据型产品是当前数据分析的一种方向

the-future-of-data-analysis

探索型数据产品

哈佛商业评论 如何构建伟大的数据产品
https://hbr.org/2018/10/how-to-build-great-data-products

可以玩的数据产品，沉浸式体验，关键是找到有价值的业务场景，写好剧本（布局设计），做好道具（筛选器、图表），没有任何说明，用户一进来看到城市分析主题，产品就能给他所预期的东西，让用户能在里面玩上一天，不停地探索不停地获取输入。需求模块、供给模块，结合时间、空间精细划分，实现城市概览、城市对比、业务趋势、业务对比。

# 数据产品

## 探索性数据分析

IBM 探索性数据分析
https://www.ibm.com/cloud/learn/exploratory-data-analysis

Hadley 数据科学与 R 语言
https://r4ds.had.co.nz/exploratory-data-analysis.html

《哈佛商业评论》在 [如何构建伟大的数据产品](https://hbr.org/2018/10/how-to-build-great-data-products) 一文中提出以下几个观点：

## 数据分析的未来

## 数据分析工作流

数据分析师/工程师日常需要搭建数据指标体系，制作数据报表和看板，数据洞察和专项分析，行业供需分析，经营诊断和追踪。制作数据报表和看板是最常见的一种形式，这里，统一一下术语，都称作数据产品。制作一款数据产品，包含提出需求、PRD 评审、产品设计、前后端开发、数据开发、测试验收、最终上线等流程。能力比较全面的工程师，能够主动发现业务痛点，提出产品需求，完成产品设计，数据开发校验，产品开发，测试上线，收集反馈，迭代优化，形成闭环。小厂或者数据团队比较小的时候，需要的能力会比较全面，差别主要在粗放和精细化之间的程度不同。其中，数据开发和产品开发耗时最多，下面的介绍都假定产品需求没啥大的问题，产品开发如何节约时间，当然，既然是独立负责完整项目，项目管理自然也是非常关键的，做好及时的向上反馈，全流程的时间安排，不至于全程紧张或先松后紧或先紧后松的情况。这些都需要在实际工作中才能锻炼出来的，因此，多说事倍功半，数据开发和产品开发偏重技术，又可批量化、标准化地整理出来，沉淀下来做技术推广，可以迁移到读者对应的具体业务场景中去。

做数据型产品是当前数据分析的一个方向，大屏产品、数据探索、和OLAP产品等都可以合并到商业智能分析，具备一定探索和交互能力的数据产品。典型的产品见下表，主要来自百度、阿里、腾讯、字节等大厂。

| 产品                                                    | 能力                               | 费用              | 场景 | 公司 |
|:--------------------------------------------------------|:-----------------------------------|:------------------|:-----|:-----|
| [Sugar](https://cloud.baidu.com/product/sugar.html)     | 自助BI报表分析和制作可视化数据大屏 | 订阅费 3万/年起   | 大屏 | 百度 |
| [DataV](https://cn.aliyun.com/product/bigdata/datav)    | 数据可视化应用搭建工具             | 订阅费 2.4万/年起 | 大屏 | 阿里 |
| [RayData](https://cloud.tencent.com/product/raydata)    | 三维数据可视化编辑工具             | 预估数万/年起     | 大屏 | 腾讯 |
| [DataWind](https://www.volcengine.com/product/datawind) | 数据分析、探索和洞察工具           | 预估数万/年起     | 报表 | 字节 |
| [Quick BI](https://cn.aliyun.com/product/bigdata/bi)    | 数据分析、自助分析、数据报表平台   | 预估数万/年起     | 报表 | 阿里 |
| [Apache Superset](https://github.com/apache/superset)   | 数据可视化和探索平台               | 免费              | 报表 | 开源 |

除了 Sugar 等三款商业解决方案，还有[51WORLD](https://www.51aes.com/)等，除了 Apache Superset 也还有很多 OLAP 分析工具，比如[redash](https://github.com/getredash/redash)等。商业智能分析 BI（Business Intelligence，BI）软件阿里 [Quick BI](https://cn.aliyun.com/product/bigdata/bi)、腾讯[BI](https://cloud.tencent.com/product/bi) 围绕自助分析、即席分析和自主取数、数据分析和可视化等方面，当然大都支持数据库连接、数据权限管控、应用权限管控、高级定制分析。大屏产品，特别是ToC 的情况下，对前后端的开发要求很高，也会增加交互设计、视觉设计等环节，开发周期也会相对长很多。既是大屏应用，常出现于中控室，指挥中心等有独立/拼凑的大型电子显示屏的地方。一旦定型，一般也不会有太多的探索交互，大屏呈现的就是最重要的部分，主要负责实时监控，路演展示、市场宣传等。

Shiny 作为 BI 工具的可能 [esquisse](https://github.com/dreamRs/esquisse) 提供拖拉拽的支持

<figure>
<img src="https://user-images.githubusercontent.com/12031874/140589317-7ab512e1-fdb1-4969-a4c6-30723ef627fb.gif" title="esquisse" class="full" alt="Figure 5: esquisse 包：BI 工具与 R Shiny 应用" /><figcaption aria-hidden="true">Figure 5: <strong>esquisse</strong> 包：BI 工具与 R Shiny 应用</figcaption>
</figure>

[Hiplot](https://hiplot.com.cn/) 在线科研数据可视化云平台

头部数据可视化组件如 [Apache ECharts](https://github.com/apache/echarts)、[three.js](https://github.com/mrdoob/three.js)、[G2](https://github.com/antvis/G2)、[Highcharts](https://github.com/highcharts/highcharts)等，典型的大屏示例见[iDataV](https://github.com/yyhsong/iDataV) 项目，图<a href="#fig:screen">6</a> 是其中一个示例的截图。

<figure>
<img src="https://user-images.githubusercontent.com/12031874/139688957-3826d8fa-c03e-4539-b857-19a305d5aa32.png" title="Apache ECharts" class="full" alt="Figure 6: 大屏工具与数据可视化" /><figcaption aria-hidden="true">Figure 6: 大屏工具与数据可视化</figcaption>
</figure>

面对不同的数据量级，SQL 写法是不一样的，一般来说，数据量级越大，SQL 越复杂，SQL 函数的理解要求越深入，性能调优要求越高，处理 GB 级和 TB 级数据的 SQL 已经不是一个样子了。

复杂性在于很多不同的数据情况需要考虑，带来很多判断逻辑，如何处理和组织这些判断逻辑是最难的事情，不能让复杂度膨胀，控制维护成本，数据适应性强一点，代码灵活性高一点，而处理和组织判断逻辑需要对业务有深入的了解。

<!--
<iframe height="600" width="100%" frameborder="0" src="https://yyhsong.github.io/iDataV/case09/index.html"></iframe>
-->

## 环境信息

在 RStudio IDE 内编辑本文的 R Markdown 源文件，用 **blogdown** 构建网站，[Hugo](https://github.com/gohugoio/hugo) 渲染 knitr 之后的 Markdown 文件，得益于 **blogdown** 对 R Markdown 格式的支持，图、表和参考文献的交叉引用非常方便，省了不少文字编辑功夫。文中使用了多个 R 包，为方便复现本文内容，下面列出详细的环境信息：

``` r
xfun::session_info(packages = c(
  "knitr", "rmarkdown", "blogdown",
  "shiny", "flexdashboard", "DT", "plotly"
), dependencies = TRUE)
```

    ## R version 4.1.1 (2021-08-10)
    ## Platform: x86_64-apple-darwin17.0 (64-bit)
    ## Running under: macOS Big Sur 10.16
    ## 
    ## Locale: en_US.UTF-8 / en_US.UTF-8 / en_US.UTF-8 / C / en_US.UTF-8 / en_US.UTF-8
    ## 
    ## Package version:
    ##   askpass_1.1         base64enc_0.1.3     blogdown_1.6       
    ##   bookdown_0.24       bslib_0.3.1         cachem_1.0.6       
    ##   cli_3.1.0           colorspace_2.0.2    commonmark_1.7     
    ##   cpp11_0.4.1         crayon_1.4.2        crosstalk_1.2.0    
    ##   curl_4.3.2          data.table_1.14.2   digest_0.6.28      
    ##   dplyr_1.0.7         DT_0.19             ellipsis_0.3.2     
    ##   evaluate_0.14       fansi_0.5.0         farver_2.1.0       
    ##   fastmap_1.1.0       flexdashboard_0.5.2 fontawesome_0.2.2  
    ##   fs_1.5.0            generics_0.1.1      ggplot2_3.3.5      
    ##   glue_1.5.0          graphics_4.1.1      grDevices_4.1.1    
    ##   grid_4.1.1          gtable_0.3.0        highr_0.9          
    ##   htmltools_0.5.2     htmlwidgets_1.5.4   httpuv_1.6.3       
    ##   httr_1.4.2          isoband_0.2.5       jquerylib_0.1.4    
    ##   jsonlite_1.7.2      knitr_1.36          labeling_0.4.2     
    ##   later_1.3.0         lattice_0.20.45     lazyeval_0.2.2     
    ##   lifecycle_1.0.1     magrittr_2.0.1      MASS_7.3.54        
    ##   Matrix_1.3.4        methods_4.1.1       mgcv_1.8.38        
    ##   mime_0.12           munsell_0.5.0       nlme_3.1.153       
    ##   openssl_1.4.5       pillar_1.6.4        pkgconfig_2.0.3    
    ##   plotly_4.10.0       promises_1.2.0.1    purrr_0.3.4        
    ##   R6_2.5.1            rappdirs_0.3.3      RColorBrewer_1.1.2 
    ##   Rcpp_1.0.7          rlang_0.4.12        rmarkdown_2.11     
    ##   sass_0.4.0          scales_1.1.1        servr_0.23         
    ##   shiny_1.7.1         sourcetools_0.1.7   splines_4.1.1      
    ##   stats_4.1.1         stringi_1.7.5       stringr_1.4.0      
    ##   sys_3.4             tibble_3.1.6        tidyr_1.1.4        
    ##   tidyselect_1.1.1    tinytex_0.35        tools_4.1.1        
    ##   utf8_1.2.2          utils_4.1.1         vctrs_0.3.8        
    ##   viridisLite_0.4.0   withr_2.4.2         xfun_0.28          
    ##   xtable_1.8.4        yaml_2.2.1         
    ## 
    ## Pandoc version: 2.16.1
    ## 
    ## Hugo version: 0.89.2

## 参考文献

<div id="refs" class="references csl-bib-body hanging-indent">

<div id="ref-tcltk2001" class="csl-entry">

Dalgaard, Peter. 2001. “The R Commander: A Basic Statistics Graphical User Interface to R.” *R News* 1 (3): 27–31. <https://www.r-project.org/doc/Rnews/Rnews_2001-3.pdf>.

</div>

<div id="ref-Rcmdr2005" class="csl-entry">

Fox, John. 2005. “The R Commander: A Basic Statistics Graphical User Interface to R.” *Journal of Statistical Software* 14 (9): 1–42. <https://www.jstatsoft.org/article/view/v014i09>.

</div>

<div id="ref-RGtk2" class="csl-entry">

Lawrence, Michael, and Duncan Temple Lang. 2010. “RGtk2: A Graphical User Interface Toolkit for R.” *Journal of Statistical Software* 37 (8): 1–52. <https://www.jstatsoft.org/v37/i08/>.

</div>

<div id="ref-Lawrence2012" class="csl-entry">

Lawrence, Michael, and John Verzani. 2012. *Programming Graphical User Interfaces in R*. Boca Raton, Florida: Chapman; Hall/CRC.

</div>

<div id="ref-radiant" class="csl-entry">

Nijs, Vincent. 2021. *<span class="nocase">radiant</span>: Business Analytics Using R and Shiny*. <https://CRAN.R-project.org/package=radiant>.

</div>

<div id="ref-Williams2011" class="csl-entry">

Williams, Graham J. 2011. *Data Mining with <span class="nocase">rattle</span> and R: The Art of Excavating Data for Knowledge Discovery*. Use r! Springer. <https://rattle.togaware.com/>.

</div>

</div>
