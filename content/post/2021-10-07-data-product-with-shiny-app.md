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

本文将围绕页面布局、筛选器、CSS 样式、SQL 渲染、交互图形和表格等方面，从零开始介绍一个完整的 Shiny 应用 制作过程，最终打造一个符合企业级水准的应用模版。所以，本文面向的是对 R 语言和 Shiny 框架有些基础的用户。在介绍内容干货之前，先讲讲为什么要用 R Shiny 来做数据型产品，以及数据型产品需要符合什么样的条件。

R Shiny + R Markdown + Flexdashboard + Plotly + DT

# 回顾历史

从 **tcltk** ([Lawrence and Verzani 2012](#ref-Lawrence2012)) 到 **RGtk2** ([Lawrence and Temple Lang 2010](#ref-RGtk2))，再到 **shiny**([Chang et al. 2021](#ref-shiny))，自 2001 年 Peter Dalgaard 在《R News》介绍 **tcltk** ([Dalgaard 2001](#ref-tcltk2001)) 算起，整整 **20** 年过去了， 打造数据产品的主力工具换了一茬又一茬，过程中出现了一些优秀的代表作品，基于 **tcltk** 的 **Rcmdr** ([Fox 2005](#ref-Rcmdr2005))（**2003** 年首发），基于 **rJava** 的 [JGR](https://www.rforge.net/JGR/)([Helbig, Theus, and Urbanek 2005](#ref-Helbig2005))（**2006** 年首发），基于 **RGtk2** 的 **rattle** ([Williams 2011](#ref-Williams2011))（**2013** 年首发），基于 **shiny** 的 **radiant** ([Nijs 2021](#ref-radiant))（**2015** 年首发），风水轮流转，十年一轮回。除了 Shiny 应用，其它都有很重的系统软件依赖，在不同系统上的安装过程复杂不一，为开发应用的学习成本比较高，我想主要还是受历史局限，2003 年，国内有笔记本电脑的怕是也屈指可数，浏览器和网页技术远没有现在这么流行。

## Rcmdr

[**Rcmdr**](https://socialsciences.mcmaster.ca/jfox/Misc/Rcmdr) 包主要由 [John Fox](https://socialsciences.mcmaster.ca/jfox) 开发，在 R 软件工作空间中加载后，会出现如图<a href="#fig:tcltk-rcmdr">1</a>所示的图形用户界面，它是基于 R 内置的 **tcltk** 包开发的，顾名思义，是 [Tcl (Tool Command Language) 和 Tk (Graphical User Interface Toolkit)](https://www.tcl.tk/) 的合体。

<figure>
<img src="https://user-images.githubusercontent.com/12031874/142166767-92dcf166-7f62-44df-87dc-a923c1c64dc8.png" class="full" alt="Figure 1: Rcmdr 包：统计分析与 tcltk 应用" /><figcaption aria-hidden="true">Figure 1: <strong>Rcmdr</strong> 包：统计分析与 tcltk 应用</figcaption>
</figure>

**Rcmdr** 具有非常多的统计功能，还有很多开发者帮助建设周边，目前 CRAN 上扩展插件包就有 42 个，早年号称是 [IBM SPSS](https://www.ibm.com/analytics/spss-statistics-software) 的开源替代品。

     [1] "RcmdrPlugin.aRnova"         "RcmdrPlugin.BiclustGUI"    
     [3] "RcmdrPlugin.BWS1"           "RcmdrPlugin.coin"          
     [5] "RcmdrPlugin.DCCV"           "RcmdrPlugin.DCE"           
     [7] "RcmdrPlugin.depthTools"     "RcmdrPlugin.DoE"           
     [9] "RcmdrPlugin.EACSPIR"        "RcmdrPlugin.EBM"           
    [11] "RcmdrPlugin.EcoVirtual"     "RcmdrPlugin.Export"        
    [13] "RcmdrPlugin.EZR"            "RcmdrPlugin.FactoMineR"    
    [15] "RcmdrPlugin.FuzzyClust"     "RcmdrPlugin.GWRM"          
    [17] "RcmdrPlugin.HH"             "RcmdrPlugin.IPSUR"         
    [19] "RcmdrPlugin.KMggplot2"      "RcmdrPlugin.lfstat"        
    [21] "RcmdrPlugin.MA"             "RcmdrPlugin.MPAStats"      
    [23] "RcmdrPlugin.NMBU"           "RcmdrPlugin.orloca"        
    [25] "RcmdrPlugin.PcaRobust"      "RcmdrPlugin.plotByGroup"   
    [27] "RcmdrPlugin.pointG"         "RcmdrPlugin.RiskDemo"      
    [29] "RcmdrPlugin.RMTCJags"       "RcmdrPlugin.ROC"           
    [31] "RcmdrPlugin.sampling"       "RcmdrPlugin.SCDA"          
    [33] "RcmdrPlugin.SLC"            "RcmdrPlugin.sos"           
    [35] "RcmdrPlugin.steepness"      "RcmdrPlugin.survival"      
    [37] "RcmdrPlugin.sutteForecastR" "RcmdrPlugin.TeachingDemos" 
    [39] "RcmdrPlugin.TeachStat"      "RcmdrPlugin.temis"         
    [41] "RcmdrPlugin.UCA"            "RcmdrPlugin.WorldFlora"    

## JGR

[**JGR**](https://github.com/markush81/JGR) (**J**ava **G**ui for **R**) 主要由 Markus Helbig 开发，它非常小巧，但是提供了大部分常用的数据操作和统计分析功能，如单样本、两样本和 K 样本检验，相关性分析、列联分析、线性和广义线性模型等，在那个年代以如此迅速的手法集成 R 语言和学术界的成果是非常厉害的，也不怪乎它敢对标 [SPSS](https://en.wikipedia.org/wiki/SPSS)、 [JMP](https://en.wikipedia.org/wiki/JMP_(statistical_software)) 和 [Minitab](https://en.wikipedia.org/wiki/Minitab) 等商业统计分析软件。

<figure>
<img src="https://user-images.githubusercontent.com/12031874/142404769-e9d078e4-6355-4f03-b53e-a2bf5f6ae9bc.png" class="full" alt="Figure 2: JGR 包：统计分析与 rJava 应用" /><figcaption aria-hidden="true">Figure 2: <strong>JGR</strong> 包：统计分析与 <strong>rJava</strong> 应用</figcaption>
</figure>

## rattle

[**rattle**](https://rattle.togaware.com/) 包主要由 Graham J. Williams 基于 **RGtk2** 开发，类似 **tcltk** 包， 它是另一个跨平台开源框架[GTK](https://www.gtk.org/)的 R 语言接口，面向数据挖掘工作者，因此，集成了大量常见的算法模型，如关联规则、随机森林、支撑向量机、决策树、聚类分析、因子分析、生存分析、时序分析等，支持连接数据库，做数据变换和数据可视化等探索分析，用户在图形用户界面<a href="#fig:gtk-rattle">3</a>上的操作都会被记录下来，对应成 R 语言代码，方便后续修改和脚本化。

<figure>
<img src="https://user-images.githubusercontent.com/12031874/142166760-91408f3a-1a30-4c0d-9e22-6e7993a678bc.png" class="full" alt="Figure 3: rattle 包：数据挖掘与 Gtk+ 应用" /><figcaption aria-hidden="true">Figure 3: <strong>rattle</strong> 包：数据挖掘与 Gtk+ 应用</figcaption>
</figure>

期间，还陆续出现了一些开源统计分析软件，比如 [GNU PSPP](https://www.gnu.org/software/pspp/) 和 [JASP](https://jasp-stats.org)，都提供图形化的用户界面，也都号称是 SPSS 软件 的免费替代，但是从来没有真的替代过。专门化的贝叶斯分析软件有 [JAGS](https://mcmc-jags.sourceforge.io/) 和 [Stan](https://mc-stan.org/) 等，而商业化的软件更是可以列出一个长长的单子，此处略去。下面仅就 JASP 简单介绍，JASP 是一款独立免费开源的统计软件，不是一个 R 包，源代码托管在 [Github](https://github.com/jasp-stats/jasp-desktop) 上，主要由阿姆斯特丹大学 [E. J. Wagenmakers](https://www.ejwagenmakers.com/) 教授领导的团队维护开发，实现了很多贝叶斯和频率统计方法，具体功能见[这里](https://jasp-stats.org/current-functionality/)，统计方法和原理见[博客](https://www.bayesianspectacles.org/)，相似的图形用户界面使得 JASP 可以作为 SPSS 的替代，也远非前面的 JGR 可比，实际上，后者已经多年未更新功能了，笔者亲测已经不可用。

| Analysis                                                          | Frequentist | Bayesian |
|:------------------------------------------------------------------|:------------|:---------|
| A/B Test（A/B 测试）                                              | –           | ✓        |
| ANOVA（方差分析）                                                 | ✓           | ✓        |
| ANCOVA（协方差分析）                                              | ✓           | ✓        |
| AUDIT (module)                                                    | ✓           | ✓        |
| Bain (module)                                                     | –           | ✓        |
| Binomial Test（二项检验）                                         | ✓           | ✓        |
| Confirmatory Factor Analysis (CFA)                                | ✓           | –        |
| Contingency Tables（列联分析，又叫卡方检验）                      | ✓           | ✓        |
| Correlation: Pearson, Spearman, Kendall（相关性检验）             | ✓           | ✓        |
| Distributions (module)（统计分布）                                | ✓           | ✓        |
| Equivalence T-Tests: Independent, Paired, One-Sample (module)[^1] | ✓           | ✓        |
| Exploratory Factor Analysis (EFA)（探索因子分析）                 | ✓           | –        |
| Generalized Linear Mixed Models（广义线性混合效应模型）           | ✓           | ✓        |
| JAGS (module)（贝叶斯软件 JAGS）                                  | –           | ✓        |
| Learn Bayes (module)（贝叶斯学习）                                | –           | ✓        |
| Linear Mixed Models（线性混合效应模型）                           | ✓           | ✓        |
| Linear Regression（线性回归）                                     | ✓           | ✓        |
| Logistic Regression （逻辑回归）                                  | ✓           | –        |
| Log-Linear Regression（对数线性回归）                             | ✓           | ✓        |
| Machine Learning (module)（机器学习）                             | ✓           | –        |
| MANOVA（多元单因素方差分析）                                      | ✓           | –        |
| Mediation Analysis（中介分析）[^2]                                | ✓           | –        |
| Meta-Analysis (module)（元分析）                                  | ✓           | ✓        |
| Multinomial （多项回归）                                          | ✓           | ✓        |
| Network (module) （网络分析）                                     | ✓           | –        |
| Principal Component Analysis (主成分分析)                         | ✓           | –        |
| Prophet (module)（贝叶斯时间序列分析）                            | –           | ✓        |
| Repeated Measures ANOVA（重复测量方差分析）                       | ✓           | ✓        |
| Reliability (module)（可靠性）                                    | ✓           | ✓        |
| Structural Equation Modeling (module) （结构方程模型）            | ✓           | –        |
| Summary Statistics (module)（描述统计）                           | –           | ✓        |
| T-Tests: Independent, Paired, One-Sample （T 检验）               | ✓           | ✓        |
| Visual Modeling: Linear, Mixed, Generalized Linear (module)       | ✓           | –        |

Table 1: JASP 软件的主要统计分析功能

2021 年 Gartner 对分析和商业平台的定义是易于使用且能支撑全分析工作流 — 即从数据准备到可视化探索和洞察生成。魔力象限中的产品都具有数据可视化能力，可以接入各种各样的数据源，使用交互式图表搭建刻画关键指标的仪表盘，区别在于增强分析（Augmented Analytics）方面的支持程度 — 机器学习和人工智能技术在数据准备、洞察生成和解释等方面为决策者和分析师赋能提效的有多少，以及在帮助非技术序列的终端用户自助探索分析的有多少。简而言之，就是教机器给人讲好数据故事。从图<a href="#fig:magic-quadrant">4</a>中不难看出，领先的都是国外老牌的 IT 企业，国内唯一入选的是阿里云，且评测中的 12 项能力全面弱于平均水平。

<figure>
<img src="https://user-images.githubusercontent.com/12031874/142556557-997700a0-e449-4849-a0db-8aa00317225b.png" class="full" alt="Figure 4: 2021 年 Gartner 分析和商业智能平台魔力象限" /><figcaption aria-hidden="true">Figure 4: 2021 年 Gartner 分析和商业智能平台魔力象限</figcaption>
</figure>

## shiny

[**shiny**](https://shiny.rstudio.com/) 是 2012 年正式登陆 R 语言官方仓库 [CRAN](https://cran.r-project.org/) （Comprehensive R Archive Network）的，在 2015 年以后才开始形成生产力，经过最近几年的快速发展，截止当前，直接或间接依赖 shiny 的 R 包已有近 1000 个[^3]，还不算 [Bioconductor](https://www.bioconductor.org/) 上发布的，实际上还有很多存放在 Github 上。类似 **Rcmdr**，**shiny** 也有很多插件包，提供一些附加功能，比如交互反馈 **shinyFeedback**、主题配色 **shinythemes**、输入校验 **shinyvalidate** 等，下面列出部分：

     [1] "shiny"              "shiny.i18n"         "shiny.info"        
     [4] "shiny.pwa"          "shiny.react"        "shiny.reglog"      
     [7] "shiny.router"       "shiny.semantic"     "shiny.worker"      
    [10] "shinyAce"           "shinyaframe"        "shinyalert"        
    [13] "shinyanimate"       "shinyauthr"         "shinybootstrap2"   
    [16] "shinybrms"          "shinyBS"            "shinybusy"         
    [19] "shinyChakraSlider"  "shinyChakraUI"      "shinycssloaders"   
    [22] "shinycustomloader"  "shinyCyJS"          "shinydashboard"    
    [25] "shinydashboardPlus" "shinydisconnect"    "shinydlplot"       
    [28] "shinyDND"           "shinydrive"         "shinyEffects"      
    [31] "shinyFeedback"      "shinyFiles"         "shinyfilter"       
    [34] "shinyfullscreen"    "shinyglide"         "shinyGovstyle"     
    [37] "shinyHeatmaply"     "shinyhelper"        "shinyhttr"         
    [40] "shinyIRT"           "shinyjqui"          "shinyjs"           
    [43] "shinyKGode"         "shinyKnobs"         "shinyloadtest"     
    [46] "shinylogs"          "shinyLP"            "shinymanager"      
    [49] "shinymaterial"      "shinyMatrix"        "shinyMergely"      
    [52] "shinymeta"          "shinyML"            "shinyMobile"       
    [55] "shinymodels"        "shinyMolBio"        "shinyMonacoEditor" 
    [58] "shinyNotes"         "shinyobjects"       "shinypanel"        
    [61] "shinypanels"        "shinypivottabler"   "shinyPredict"      
    [64] "shinyr"             "shinyRadioMatrix"   "shinyrecap"        
    [67] "shinyrecipes"       "shinyreforms"       "shinyRGL"          
    [70] "shinyscreenshot"    "shinySearchbar"     "shinySelect"       
    [73] "shinyservicebot"    "shinyShortcut"      "shinySIR"          
    [76] "shinystan"          "shinysurveys"       "shinytest"         
    [79] "shinythemes"        "shinyTime"          "shinytitle"        
    [82] "shinyToastify"      "shinytoastr"        "shinyTree"         
    [85] "shinyvalidate"      "shinyWidgets"      

相比于之前介绍的 **Rcmdr**、**JGR** 和 **rattle**， **shiny** 扩展包 没有系统软件依赖，这无论是对生态开发者还是应用开发者来说，都是非常友好的。另外，入门的学习成本非常低，应用的前后端代码可以纯用 R 语言实现。一个工具是否成熟，还可以看书写出得多不多，文档全不全，面对企业级大规模应用够不够稳定高效，好在已有多本书详细介绍，如 Sievert ([2020](#ref-Sievert2020));Wickham ([2021](#ref-Hadley2021));Fay et al. ([2021](#ref-Colin2021)) 。

Shiny 是一个开发 Web 应用的框架，相当于前面提及的 **tcltk**，在它之上可以开发出各种各样的应用，在一些 R 服务框架 的帮助下，一些计算密集型的任务可以剥离开，打包成模型服务，供 Shiny 应用的服务端调用。

<div class="rmdnote">

shiny 首字母大写的时候表示 Web 开发框架，否则表示 R 语言扩展包。

</div>

### radiant

Vincent Nijs 在 2015 年开发了 [**radiant**](https://github.com/radiant-rstats/radiant) 应用，完全基于 R 语言和 Shiny 框架，定位商业分析，包含基础统计计算、实验设计分析、多元统计分析和常用数据挖掘模型等，算是相当早的具备一定规模和流行度的 Shiny 应用。

<figure>
<img src="https://user-images.githubusercontent.com/12031874/142166747-3c0f0f04-31c5-45cc-93a7-2d8da008df8f.png" class="full" alt="Figure 5: radiant 包：商业分析与 R Shiny 应用" /><figcaption aria-hidden="true">Figure 5: <strong>radiant</strong> 包：商业分析与 R Shiny 应用</figcaption>
</figure>

### shinybrms

顾名思义，[**shinybrms**](https://github.com/fweber144/shinybrms) 是另一个 R 包 [**brms**](https://github.com/paul-buerkner/brms) 的 Shiny 扩展，由 Frank Weber 开发，2020 年登陆 CRAN 仓库。它依赖贝叶斯计算框架 [Stan](https://mc-stan.org/) 的 R 接口 [**rstan**](https://github.com/stan-dev/rstan) 包，预编译非常多的贝叶斯统计模型，比如线性模型、广义线性模型、线性混合效应模型、广义线性混合效应模型、广义可加混合效应模型等，站在 Shiny 的肩膀上，**shinybrms** 调用 Stan 编写的模型，实现模型计算、模型诊断、过程分析、模型评估和可视化，让贝叶斯数据分析过程在拖拉拽中完成。

<figure>
<img src="https://user-images.githubusercontent.com/12031874/142166772-bfecdca9-f920-418e-8812-234a6c08ec85.png" class="full" alt="Figure 6: shinybrms 包：贝叶斯分析与 R Shiny 应用" /><figcaption aria-hidden="true">Figure 6: <strong>shinybrms</strong> 包：贝叶斯分析与 R Shiny 应用</figcaption>
</figure>

### explor

Julien Barnier 开发的 [**explor**](https://github.com/juba/explor) 包也集成了一个 Shiny 应用，用于可视化探索多元统计分析的结果，效果见动图<a href="#fig:shiny-explor">7</a>。

<figure>
<img src="https://user-images.githubusercontent.com/12031874/142581106-5690732f-edde-48af-ab31-03bdfedde5d6.gif" class="full" alt="Figure 7: explor 包：多元分析与 R Shiny 应用" /><figcaption aria-hidden="true">Figure 7: <strong>explor</strong> 包：多元分析与 R Shiny 应用</figcaption>
</figure>

### hiplot

在线科研数据可视化云平台 [hiplot](https://hiplot.com.cn/) 主打在线科研绘图，其中很多绘图应用是基于 Shiny 开发的，熟悉 Shiny 的用户也一定非常熟悉它的界面，熟悉 R 语言的用户也一定非常熟悉它绘制的图形。虽不太清楚绘图模块的整个制作过程，因为它不开源，但看起来得到了 [esquisse](https://github.com/dreamRs/esquisse) 的真传，拖拉拽就可以完成图形制作，连上数据源，自助 BI 分析工具的雏形就出现了。

<figure>
<img src="https://user-images.githubusercontent.com/12031874/140589317-7ab512e1-fdb1-4969-a4c6-30723ef627fb.gif" title="esquisse" class="full" alt="Figure 8: esquisse 包：BI 工具与 R Shiny 应用" /><figcaption aria-hidden="true">Figure 8: <strong>esquisse</strong> 包：BI 工具与 R Shiny 应用</figcaption>
</figure>

<iframe width="960" height="600" src="//player.bilibili.com/player.html?aid=585046473&amp;bvid=BV16z4y1o7u9&amp;cid=249744610&amp;page=1" scrolling="no" border="0" frameborder="no" framespacing="0" allowfullscreen="true">
</iframe>

## 小结

都说现在是看脸的时代，自然少不了数据可视化组件，而且是易用、流畅、美观，总之一句话，体验要好。这些组件当中，有的能力比较综合，可以连接各类数据库，提供 SQL 编辑窗口，直接对取数结果可视化分析，比如 [Apache Superset](https://github.com/apache/superset) 是数据可视化（Data Visualization）和数据探索（Data Exploration）平台，同类产品还有[Redash](https://github.com/getredash/redash)。有的专注数据可视化，比如[Apache ECharts](https://github.com/apache/echarts) 是交互式网页绘图和数据可视化的库，同类产品还有 [Plotly](https://github.com/plotly/plotly.js)，它 提供各种各样的图形，涵盖统计、三维、科学、地理、金融等五大类。还有的面向特定的语言，比如[bokeh](https://github.com/bokeh/bokeh) 是一个交互式网页可视化的 Python 模块。还有的，如 [Observable Plot](https://github.com/observablehq/plot) 主打探索性数据可视化，像是 Jupyter Notebook 和 bokeh 的合体。而[fastpages](https://github.com/fastai/fastpages) 是易于使用的博客平台，深度结合静态网站生成器[Jekyll](https://github.com/jekyll/jekyll)，有来自 Jupyter Notebook 的增强支持，可以让博客看起来是一个个的数据报告或仪表盘，以 [COVID-19](https://github.com/github/covid19-dashboard) 为例，可以看出它是 blogdown + R Markdown + Netlify + Hugo + Pandoc 的合体。还有的，比如[D3](https://github.com/d3/d3) 采用 Web 标准的数据可视化库，支持 SVG、Canvas 和 HTML 渲染方式，是一个非常基础的 JavaScript 库，在许多项目中使用，比如做日志监控的[Grafana](https://github.com/grafana/grafana)。
作为新一代通用技术写作工具，[Quarto](https://quarto.org/) 支持各类编程语言，Markdown、R Markdown 和 Jupyter Notebook 等主流文档格式，可以输出多种格式的文档，如动态网页 HTML、便携文档 PDF、移动优先的电子书籍 MOBI 和 EPUB 等。总之，无论技术如何更新换代，更加易用，更加便携，更加美观，更加通用的全能型选手必将引领潮流。

# 数据产品

Shiny 应用可以是统计分析软件

我们可以基于 Shiny 框架开发统计分析软件

以数据产品承载数据分析模型，交互式探索性数据分析

交互图形用于，

做数据型产品是当前数据分析的一种方向

the-future-of-data-analysis

探索型数据产品

可以玩的数据产品，沉浸式体验，关键是找到有价值的业务场景，写好剧本（布局设计），做好道具（筛选器、图表），没有任何说明，用户一进来看到城市分析主题，产品就能给他所预期的东西，让用户能在里面玩上一天，不停地探索不停地获取输入。需求模块、供给模块，结合时间、空间精细划分，实现城市概览、城市对比、业务趋势、业务对比。

IBM 探索性数据分析
https://www.ibm.com/cloud/learn/exploratory-data-analysis

统计学最高奖项 COPSS 奖获得者

Hadley 数据科学与 R 语言
https://r4ds.had.co.nz/exploratory-data-analysis.html

探索性分析的总结

面对不同的数据量级，SQL 写法是不一样的，一般来说，数据量级越大，SQL 越复杂，SQL 函数的理解要求越深入，性能调优要求越高，处理 GB 级和 TB 级数据的 SQL 已经不是一个样子了。

复杂性在于很多不同的数据情况需要考虑，带来很多判断逻辑，如何处理和组织这些判断逻辑是最难的事情，不能让复杂度膨胀，控制维护成本，数据适应性强一点，代码灵活性高一点，而处理和组织判断逻辑需要对业务有深入的了解。

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

<figure>
<img src="https://user-images.githubusercontent.com/12031874/142594440-b67203fe-8e3a-4a56-9565-92e3bd45cd25.gif" class="full" alt="Figure 9: 大屏数据可视化产品" /><figcaption aria-hidden="true">Figure 9: 大屏数据可视化产品</figcaption>
</figure>

2018 年美团技术博客介绍了大规模的餐饮娱乐知识图谱—[美团大脑](https://tech.meituan.com/2018/12/06/ai-in-meituan-csdn.html)，其前端展示层面就采用了业内通用的开源三维可视化库 [three.js](https://github.com/mrdoob/three.js)，[夏华夏](https://ai.meituan.com/)在 **2020 国际智能城市峰会**上做了美团大脑的具体演示[^4]，《第一财经》新闻栏目也做了报道！

<!--
<iframe height="600" width="100%" frameborder="0" src="https://yyhsong.github.io/iDataV/case09/index.html"></iframe>

## 探索性数据分析 {#exploratory-data-analysis}

## 数据分析工作流 {#the-workflow-data-analysis}


## 重定义数据分析 {#rethinking-of-data-analysis}


# 展望未来

## 数据分析的未来 {#the-future-of-data-analysis}


## 数据分析的挑战 {#the-challenge-of-data-analysis}


## 数据分析的机会 {#the-chance-of-data-analysis}

-->

# 环境信息

在 RStudio IDE 内编辑本文的 R Markdown 源文件，用 **blogdown** 构建网站，[Hugo](https://github.com/gohugoio/hugo) 渲染 knitr 之后的 Markdown 文件，得益于 **blogdown** 对 R Markdown 格式的支持，图、表和参考文献的交叉引用非常方便，省了不少文字编辑功夫。文中使用了多个 R 包，为方便复现本文内容，下面列出详细的环境信息：

``` r
xfun::session_info(packages = c(
  "knitr", "rmarkdown", "blogdown",
  "shiny", "flexdashboard", "DT", "plotly",
  "rJava", "JGR", "Rcmdr", 
  "radiant", "rattle", "shinybrms"
), dependencies = FALSE)
```

    ## R version 4.1.1 (2021-08-10)
    ## Platform: x86_64-apple-darwin17.0 (64-bit)
    ## Running under: macOS Big Sur 10.16
    ## 
    ## Locale: en_US.UTF-8 / en_US.UTF-8 / en_US.UTF-8 / C / en_US.UTF-8 / en_US.UTF-8
    ## 
    ## Package version:
    ##   blogdown_1.6        DT_0.19             flexdashboard_0.5.2
    ##   JGR_1.8.7           knitr_1.36          plotly_4.10.0      
    ##   radiant_1.4.0       rattle_5.4.0        Rcmdr_2.7.1        
    ##   rJava_1.0.5         rmarkdown_2.11      shiny_1.7.1        
    ##   shinybrms_1.6.0    
    ## 
    ## Pandoc version: 2.16.1
    ## 
    ## Hugo version: 0.89.3

# 参考文献

<div id="refs" class="references csl-bib-body hanging-indent">

<div id="ref-shiny" class="csl-entry">

Chang, Winston, Joe Cheng, JJ Allaire, Carson Sievert, Barret Schloerke, Yihui Xie, Jeff Allen, Jonathan McPherson, Alan Dipert, and Barbara Borges. 2021. *<span class="nocase">shiny</span>: Web Application Framework for R*. <https://CRAN.R-project.org/package=shiny>.

</div>

<div id="ref-tcltk2001" class="csl-entry">

Dalgaard, Peter. 2001. “The R Commander: A Basic Statistics Graphical User Interface to R.” *R News* 1 (3): 27–31. <https://www.r-project.org/doc/Rnews/Rnews_2001-3.pdf>.

</div>

<div id="ref-Colin2021" class="csl-entry">

Fay, Colin, Sébastien Rochette, Vincent Guyader, and Cervan Girard. 2021. *Engineering Production-Grade Shiny Apps*. Boca Raton, Florida: Chapman; Hall/CRC. <https://engineering-shiny.org/>.

</div>

<div id="ref-Rcmdr2005" class="csl-entry">

Fox, John. 2005. “The R Commander: A Basic Statistics Graphical User Interface to R.” *Journal of Statistical Software* 14 (9): 1–42. <https://www.jstatsoft.org/article/view/v014i09>.

</div>

<div id="ref-Helbig2005" class="csl-entry">

Helbig, Markus, Martin Theus, and Simon Urbanek. 2005. “JGR: Java GUI for R.” *Statistical Computing and Graphics* 16 (2): 9–12. <http://stat-computing.org/newsletter/issues/scgn-16-2.pdf>.

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

<div id="ref-Sievert2020" class="csl-entry">

Sievert, Carson. 2020. *Interactive Web-Based Data Visualization with R, <span class="nocase">plotly</span>, and <span class="nocase">shiny</span>*. 1st ed. Boca Raton, Florida: Chapman; Hall/CRC. <https://plotly-r.com/>.

</div>

<div id="ref-Tingley2014" class="csl-entry">

Tingley, Dustin, Teppei Yamamoto, Kentaro Hirose, Luke Keele, and Kosuke Imai. 2014. “<span class="nocase">mediation</span>: R Package for Causal Mediation Analysis.” *Journal of Statistical Software* 59 (5): 1–38. <http://www.jstatsoft.org/v59/i05/>.

</div>

<div id="ref-Hadley2021" class="csl-entry">

Wickham, Hadley. 2021. *Mastering Shiny*. O’Reilly Media, Inc. <https://mastering-shiny.org/>.

</div>

<div id="ref-Williams2011" class="csl-entry">

Williams, Graham J. 2011. *Data Mining with <span class="nocase">rattle</span> and R: The Art of Excavating Data for Knowledge Discovery*. Use R! New York, NY. <https://rattle.togaware.com/>.

</div>

</div>

[^1]: 等效 T 检验：零假设是 `\(\mu = \mu_0\)` 而备择假设是 `\(\mu \neq \mu_0\)`，其中 `\(\mu_0\)` 已知，它是一般 T 检验的特殊形式。

[^2]: 中介分析是因果推断中非常重要的部分，R 语言扩展包 **mediation** ([Tingley et al. 2014](#ref-Tingley2014)) 是典型的代表。

[^3]: 数字根据 `tools::dependsOnPkgs('shiny', installed = tools::CRAN_package_db())` 统计得到。

[^4]: 马斯克研究无人航天器登陆火星，美团研究无人飞行器送外卖。<https://www.yicai.com/news/100695161.html>
