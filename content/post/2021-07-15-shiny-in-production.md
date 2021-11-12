---
date: "2021-08-29"
slug: shiny-in-production
title: 开发企业级 Shiny 应用的技术栈
toc: true
categories:
  - 统计软件
  - R 语言
tags:
  - shiny
  - ggplot2
  - DT
  - plotly
  - flexdashboard
  - data.table
  - R Markdown
description: "本文适合对 R 语言有一定了解的读者，试图从全景出发介绍 R Markdown 和 R Shiny 的各个组件，着重在主要特点上，不深入细节。"
---

> 声明：本文引用的所有信息均为公开信息，仅代表作者本人观点，与就职单位无关。

> To write it, it took three months; to conceive it – three minutes; to collect the data in it – all my life.
>
> --- [F. Scott Fitzgerald](https://en.wikipedia.org/wiki/F._Scott_Fitzgerald)


阅读本文烦请带着几个疑问：R Markdown 和 R Shiny 分别是什么？R Markdown 和 R Shiny 有什么能力？适合在什么样的场景下使用？一个完整的 R Markdown 和 R Shiny 应用通常都包含哪些部分？如何去学习和使用 R Markdown 和 R Shiny 两个工具？


## 一、背景简介

R Markdown 和 R Shiny 是 R 语言社区开发的两个开源框架。顾名思义，R Markdown 即是将 Markdown 这种简洁的编辑语法和 R 语言在交互式数据分析的优势结合，形成的一个新的文档格式，也是一个新的探索性数据分析模式。R Markdown 文档中，可以混合自然语言和各种编程语言，让数据分析的过程以动态、可重复的方式呈现出来。R Shiny 是一个 R 社区开发的轻量级的 Web 开发框架，学习曲线低，容易上手，只要熟悉 R 语言，几乎不需要前后端知识即可完成应用的开发。R Markdown 和 R Shiny 都严重依附于 R 语言及其社区，下面再简单介绍一下 R 语言本身。

R 语言最初由两位统计学家 Robert Gentleman 和 Ross Ihaka 开发，于 1997 年 4 月发布第一个版本，距今 25 年，继承了 S 语言的很多特性，拷贝复制修改、S3 对象类型、公式语法、交互执行等，R 的底层核心主要 C 和 Fortran 语言编写，上层扩展由 R 语言编写。和 S 语言一样，R 是一门高级语言，主要用于数据分析和作图，不同的是 R 以 GPL-2/GPL-3 协议开源。经过开源社区多年的努力，相较于其它语言，R 语言在数据分析、数据挖掘、数据可视化、重复性分析报告、统计建模等场景优势比较明显。相应地发展了大大小小的部落群体，尤以 R Markdown 可重复分析、tidyverse 数据分析、 DBI 数据连接、Spark 大数据计算、tidymoels 统计学习、[bioconductor](https://www.bioconductor.org/) 生物信息为甚。

目前，bioconductor (<https://www.bioconductor.org/>) 发布超过 **2000** 个生物统计相关的 R 包， CRAN (<https://cran.r-project.org/>) 上发布近 **18000** 个 R 包，涉及 **40** 多个主题，如统计图形、可重复性研究、稳健统计、空间分析、时空统计、生存分析、缺失数据、多元统计、时间序列分析、聚类分析、贝叶斯统计、试验设计、社科统计、自然语言处理、机器学习、高性能计算、微分方程、运筹优化、数据库、计量经济、金融统计、临床试验统计、心理学等。

几乎每年国内外都会举办大大小小的 R 语言会议，就规模和影响力而言，比较大的有[useR! 2021 大会](https://user2021.r-project.org/)、[BioC 2021 大会](https://bioc2021.bioconductor.org/)、[RStudio 年会](https://www.rstudio.com/conference/)、[中国 R 语言大会](https://china-r.org/)。正如《the Art of R Programming》作者，R Journal 主编 Norm Matloff 所言 --- R is written by statisticians, for statisticians. 源于统计学家，用于统计学家！R 语言相关的会议几乎都由各地著名的大学主办。

## 二、能力介绍

R Markdown 的核心组件是 rmarkdown 扩展包，它最初由 RStudio 的厂长 J.J. Allaire 开发，目前主要由 Yihui Xie 开发维护，它基本实现了 [唐纳德·高德纳](https://en.wikipedia.org/wiki/Donald_Knuth) 提出的文学编程思想。在学术界和工业界有很多应用，经过多年的打磨，形成了较为成熟的生态环境，比如[写书做笔记](https://bookdown.org/)、[搭建个人博客](https://github.com/rbind)、[发送电子邮件](https://github.com/rstudio/blastula)、[制作网页幻灯片](https://malco.io/slides/hs_ggplot2/)、[开发数据面板](https://github.com/rstudio/flexdashboard)等等。

<img src="https://user-images.githubusercontent.com/12031874/104081077-58366100-5267-11eb-87a3-28c84e24bbaf.png" alt="rmarkdown-family" width="75%">

R Shiny 的核心组件是 shiny 扩展包，它最初由 RStudio 的首席技术官 Joe Cheng 开发，目前主要由 Joe Cheng 和 Winston Chang 开发维护。除了 [RStudio](https://github.com/rstudio) 外，一些组织机构，如 [Appsilon](https://github.com/Appsilon)、[RinteRface](https://github.com/RinteRface)、[ThinkR-open](https://github.com/ThinkR-open)、[dreamRs](https://github.com/dreamRs) 和 [datastorm-open](https://github.com/datastorm-open) 专门开发应用扩展，提供解决方案。R Shiny 提供了短、平、快的方式开发数据产品，广泛应用于企业内部数据面板开发，也是学校老师教授统计学知识的辅助工具。

<img src="https://user-images.githubusercontent.com/12031874/120100215-13598b00-c172-11eb-8c64-0fc564dab3cc.png" alt="shiny-family" width="75%">

目前，只要安装部署 RStudio Server 和 Shiny Server （开源版本就可以）即可支持 R Markdown 和 R Shiny 两类模块的开发，一般大型企业里会自主研发拖拉拽式的支持通用基础能力的报表配置工具，小型企业研发资源有限，常常会选择开源社区的产品，比如 [redash](https://github.com/getredash/redash) 和[superset](https://github.com/apache/superset) 等，非常适合模式固定的报表开发需求，而 R Markdown 适合定制化的需求，R Shiny 提供更强的交互能力和响应能力。工作中，常常需要根据具体的应用场景选择不同的开发工具，下面从常用的能力出发，对比某企内部工具（纯属臆造）、R Markdown 和 R Shiny 的能力：

|          | R Shiny       | R Markdown       | 某企内部工具     |
| :------- | :------------ | ---------------- | :--------------- |
| 图形种类 | 不受限        | 不受限           | 10余种           |
| 指标计算 | 不受限        | 不受限           | 受限于同环比     |
| 统计能力 | 不受限        | 不受限           | 无               |
| 交互能力 | 不受限        | 受限于筛选器     | 受限于筛选器     |
| 开发成本 | 高            | 高               | 低               |
| 复用能力 | 高            | 高               | 低               |
| 适用场景 | 定制化需求    | 定制化需求       | 常规需求         |
| 运维成本 | 较高          | 一般             | 低               |
| 交付类型 | 数据产品/工具 | 数据报告         | 数据产品/工具    |
| 查询速度 | 要求秒级      | 要求秒级至小时级 | 要求秒级至分钟级 |
| 学习成本 | 高            | 一般             | 低               |

R Shiny 要求可以从后端的数据源快速查询出结果，尽量采用 MySQL/Doris 等查询速度快的引擎，不然容易拖垮前端，甚至让人觉得 R Shiny 这套工具性能有问题。

## 三、应用开发

大型企业的数据都存储在集群环境中，数据处理常常是从写 SQL 开始，接着进行探索性数据分析，获取数据后，把探索的过程记录在 R Markdown 文档中，逐步凝练出来有价值的信息，一般沉淀为单页的、网页承载的数据报告和工具。相比之下，R Shiny 更加灵活，在复杂的交互场景中，有更大的发挥空间。

<img src="https://user-images.githubusercontent.com/12031874/124708320-b26d6180-df2c-11eb-8dd6-6a552a052a85.png" alt="数据应用" width="95%">


开发 R Shiny 应用涉及到方方面面的东西，一般地，数据产品设计定下来后，需要考虑交互设计，至少包含筛选器和图表的交互、筛选器之间的依赖（比如级联筛选器）、筛选器和用户的交互（比如给定筛选条件下没有数据，此时应该给用户反馈）、筛选器和控制按钮的交互（比如设置一个 [actionButton](https://shiny.rstudio.com/reference/shiny/1.6.0/actionButton.html) 让用户决定何时执行后续图表的渲染）。交互设计是开发 R Shiny 应用的关键环节，它直接决定了产品的易用性、复杂性，也基本决定了开发成本。接下来，需要考虑的是页面布局设计，比如横向分几个页签，是折叠还是并列；纵向分几节，一般循着从上往下、先总后分、先粗后细的思路模块化；再者，就是设置页面整体的配色和字体，配色是颇有讲究的，需要联系产品内容。开发一个完整的 R Markdown 或 R Shiny 应用，还包含以 SQL 为主的数据处理过程，以交互图形为主的数据可视化过程和以交互表格为主的数据展示过程。虽说 R Markdown 或 R Shiny 应用的开发不需要前端知识，但涉及到细节处理，是绕不开 HTML、CSS 和 JavaScript 的。

<img src="https://user-images.githubusercontent.com/12031874/120408326-6190a900-c381-11eb-9dcf-9881d33fa2b6.png" alt="Shiny Design" width="85%">

<!-- 上图中的 R 包可在 <https://github.com/> 或者 <https://cran.r-project.org/> 找到。 -->

魔鬼在于细节，如果能解决 Top 20% 的细节问题，就能让整个工具提升一个档次。R 语言这一层，处理细节主要依靠 [htmltools](https://github.com/rstudio/htmltools)、[htmlwidgets](https://github.com/ramnathv/htmlwidgets) 和 [crosstalk](https://github.com/rstudio/crosstalk)。[htmltools](https://github.com/rstudio/htmltools) 方便 R 创建、操作和写 HTML 组件，进而自定义 R Shiny 和 R Markdown 的用户界面（User Interface，简称 UI）。
截止写作时间，htmltools 提供 181 个组件，可在 R 控制台输入 `names(htmltools::tags)` 查看，更加详细的使用介绍见[这里](https://shiny.rstudio.com/articles/html-tags.html)。 站在 htmltools 的肩膀上，[htmlwidgets](https://github.com/ramnathv/htmlwidgets) 和 [crosstalk](https://github.com/rstudio/crosstalk) 提供更加丰富的 HTML 内容，htmlwidgets 极大地方便了 R 语言捆绑 JavaScript 库，并无缝集成到 R Markdown 文档和 R Shiny 应用中，还可以保存为独立的网页文档，方便邮件传输、云盘共享等，crosstalk 进一步扩展了 htmlwidgets 的功能，在没有 Shiny 的情况下，也能实现多个动态组件之间的交互。更多网页技术和 R 语言的交互介绍，详见 John Coene 的书 [JavaScript for R](https://book.javascript-for-r.com/)。



## 四、快速上手

目前，R Markdown 和 R Shiny 已经积累了很多案例，比如 [shiny-examples](https://github.com/rstudio/shiny-examples) 和往届 RStudio 举办的竞赛。开源社区也有不错的案例可以学习，如 <https://github.com/swsoyee/2019-ncov-japan>。鉴于实际案例的复杂性，下面从零开始介绍一个简单的应用。

### 4.1 软件准备

安装 R 软件和 RStudio 集成开发环境

```bash
brew install --cask r
brew install --cask rstudio
```

安装本文需要的 R 包

```r
install.packages(c(
  "rmarkdown", "flexdashboard", "shiny",
  "DT", "data.table", "ggplot2", "magrittr", "plotly"
))
```

### 4.2 数据连接

R Shiny 后端的数据源可以是多样化的，一般来讲，为了速度，不会采用 Hive/Presto 引擎查询 Hadoop 数据源，而是把聚合计算好的数据存储在 MySQL 或 Doris 上。[R + databases](https://github.com/r-dbi) 开发了大量数据库的 R 接口，从数据库把数据导入 R 内存已经不是什么难事。作者在去年也写过一篇相关文章详细介绍了[从 R 连接 MySQL](https://cosx.org/2020/06/connect-mysql-from-r/)的过程。


### 4.3 交互图形（初级）

Carson Sievert 开发的 plotly 包，其语法风格接近 ggplot2，提供的 `ggplotly()` 可以将 ggplot2 静态图形直接转化为 plotly 交互图形，同时支持 Shiny 应用集成，一般情况下，这种方式省心省力，方便快捷，学习成本低。话不多说，直接看代码：

```r
library(ggplot2)
ggplot(data = faithful, aes(x = waiting, y = eruptions)) +
  geom_point()
```

<img src="https://user-images.githubusercontent.com/12031874/131251180-ea82a16f-ccf8-4f61-8d89-d95893faa56e.png" alt="ggplot2" width="75%">


```r
library(plotly, warn.conflicts = FALSE)
plot_ly(data = faithful) %>%
  add_markers(x = ~waiting, y = ~eruptions)
```

<img src="https://user-images.githubusercontent.com/12031874/131251130-61e12390-e9c3-4ef9-988d-b5ecd76df85c.png" alt="plotly" width="75%">


将交互图形集成到 R Shiny 应用，仅需调用 `renderPlotly()` 函数，将绘图代码包裹起来即可。

```r
renderPlotly({
  plot_ly(data = faithful) %>%
    add_markers(x = ~waiting, y = ~eruptions)
})
```


### 4.5 交互图形（高级）

如前所述，数据可视化是 R 语言强项，社区开源的交互图形库有很多，[plotly](https://github.com/ropensci/plotly) 和 [echarts4r](https://github.com/JohnCoene/echarts4r) 都背靠大型商业公司，处于活跃维护中，支持的图形种类很多，基本可以满足需求。当然，还有一些不错的专门化的 R 包，比如时间序列库 [dygraphs](https://github.com/rstudio/dygraphs)、地图库 [leaflet](https://github.com/rstudio/leaflet) 等。有的企业内部会基于开源的可视化库做二次开发，那么应当尽量使图表库作为 R 包独立于平台，做好隔离，方便后序维护和开发。否则，图形库就会存在很多问题：

1. 灵活性差：没有现成的图形，就要打回去学习原始的那一套从头开始绘制。
1. 命名混乱：不符合 R 的编码风格和习惯，比如 BAR_BGROUP、BarGroup 等混杂了各种语言编码习惯，可谓五花八门，让人眼花缭乱！
1. 功能阉割：传参限制在字符串且与社区做法不一致带来更多学习成本。
1. 代码冗余：每个图形都包含一堆类似的代码造成大量冗余，没有全局设计的思维等。

当然还有很多图表类型和细节处理能力没有接入进来，此时，需要借助原始的 R 包和函数，以 [plotly](https://github.com/ropensci/plotly) 为例，网站 (<https://plotly.com/r/>) 提供了很多绘图示例，比如描述数据分布的小提琴图 (<https://plotly.com/r/violin/>)，动态图形 (<https://plotly.com/r/animations/>) 等。

以 plotly 为例，这个 R 包的问题就是依赖太重，而且参数配置起来比较麻烦，层层嵌套，跟俄罗斯套娃似的。
二次封装的主要任务在于将一些常用的设置固化下来，把一些常用的参数打平。下面以布局函数 layout 为例，讲一下打平的过程，主要有三点，其一清楚 JavaScript 库的数据格式 JSON 和 R 语言提供的列表 list 的映射关系，说白了，两者都可以任意层次嵌套；其二，找到 R 语言中 layout 函数和 plotly 包封装的 plotly.js 库里 layout 模块 <https://github.com/plotly/plotly.js/blob/master/src/plots/layout_attributes.js>，两下一对照，自然就清楚映射关系了；其三，plotly 包的 layout 函数对 plotly.js 库的 layout 模块的封装过程，见 <https://github.com/ropensci/plotly/blob/master/R/layout.R>。从使用者角度，第三点一般不需要了解，开发者需要关注。Carson Sievert 为 [plotly](https://github.com/ropensci/plotly) 包，写了一本书 [Interactive web-based data visualization with R, plotly, and shiny](https://plotly-r.com/)，里面做了系统性介绍，此处不再赘言。

除了 plotly 包，还有 [visNetwork](https://github.com/datastorm-open/visNetwork)、 [leaflet](https://github.com/rstudio/leaflet)、[leafletCN](https://github.com/Lchiffon/leafletCN)、[leaflet.extras](https://github.com/bhaskarvk/leaflet.extras)、 [timevis](https://github.com/shosaco/vistime) 等绘图包。除了绘图，在工作中常用 [formattable](https://github.com/renkun-ken/formattable) 和 [DT](https://github.com/rstudio/DT) 包来绘制交互表格。工具的整体布局都是用 [flexdashboard](https://github.com/rstudio/flexdashboard) 来实现的。其它间或用到的 R 包还有[rAmCharts](https://github.com/datastorm-open/rAmCharts)、[sparkline](https://github.com/htmlwidgets/sparkline)、[sunburstR](https://github.com/timelyportfolio/sunburstR)、[treemapify](https://github.com/wilkox/treemapify)。

### 4.6 制作表格

本节主要介绍一下 [DT](https://github.com/rstudio/DT)，除了 Yihui Xie，DT 包的重要维护者还包括 [Xianying Tan](https://github.com/shrektan)，都是华人。常用的功能有：水平滚动，列/行分组，自定义表格头，提供下载按钮，格式化列呈现。下面这个示例就是将原始表格的每个列按照给定的格式显示：添加百分比符号、保留三位有效数字等。

```r
library(DT)
df <- data.frame(
  A = rpois(100, 1e4),
  B = runif(100),
  C = rpois(100, 1e3),
  D = rnorm(100),
  E = Sys.Date() + 1:100
)
datatable(df) %>%
  formatCurrency(c('A', 'C'), '€') %>%
  formatPercentage('B', 2) %>%
  formatRound('D', 3) %>%
  formatDate('E', 'toDateString')
```

<img src="https://user-images.githubusercontent.com/12031874/125621947-9638de00-23f1-4bee-bc48-36ce18dd0797.png" alt="DT" width="85%">


篇幅所限，仅介绍这些，更多功能的介绍见[DT 文档](https://rstudio.github.io/DT/)。实际上，DT 包封装了 jQuery 插件 [DataTables](https://datatables.net/)，这和 plotly 封装 plotly.js 库类似， 以 `DT::datatable()` 里的 option 参数为例，想要知道 DT 包的函数封装过程，参数值传递的层次关系可以见[API 文档](https://datatables.net/reference/option/)，此处不再赘述。

除了 [DT](https://github.com/rstudio/DT) 包，还有封装了 [React Table](https://github.com/tannerlinsley/react-table) 的 [reactable](https://github.com/glin/reactable) 包，及其扩展 [reactablefmtr](https://github.com/kcuilla/reactablefmtr) 包，二次封装了很多功能函数，已发布 1.0.0 版本，趋于稳定了。顺便一提，制作漂亮的静态表格可以用 [kableExtra](https://github.com/haozhu233/kableExtra) 包，它对 LaTeX 输出非常友好，还配有相当丰富的中文示例 --- [网页版](https://haozhu233.github.io/kableExtra/awesome_table_in_html_cn.html)、[PDF版](https://haozhu233.github.io/kableExtra/awesome_table_in_pdf.pdf)。
其它比较流行的有 Rich Iannone 的 [gt](https://github.com/rstudio/gt/)，David Gohel 的 [flextable](https://github.com/hughjonesd/huxtable)， David Hugh-Jones 的 [huxtable](https://github.com/davidgohel/flextable/)，表格制作相关的综述见 <https://bookdown.org/yihui/rmarkdown-cookbook/tables.html>。



### 4.7 页面布局


[flexdashboard](https://github.com/rstudio/flexdashboard) 是 rmarkdown 的一个扩展包，引入了一些布局样式和 JavaScript 库，提供了更多的成形组件，非常适合快速制作单页应用，支持 Shiny，提供交互能力。比如[justgage](https://github.com/toorshia/justgage) 库，它是 [raphael](https://github.com/DmitryBaranovskiy/raphael) 的一个扩展，用于制作动态的压力表。下面主要介绍全局文档配置和局部段落配置，其它常用的组件（如压力表、豆腐块）就不一一介绍了，详见 <https://pkgs.rstudio.com/flexdashboard/>。

#### 4.6.1 全局文档配置

```yaml
---
title: "Shiny 模版"
runtime: shiny                   # Shiny 运行环境
output: 
  flexdashboard::flex_dashboard:
    theme: bootstrap            # 页面主题样式
    orientation: rows           # 横向，按行排
    vertical_layout: scroll     # 页面垂直滚动布局
    mathjax: null               # 不加载 MathJax 库
---
```

以上内容称之为 YAML，它和 JSON 类似，也是键值对，用缩进控制层级。分两部分，其一是文档的元数据配置，如 title， date， author 等字段；其二是文档的输出控制，这部分内容非常丰富，完整详情可以见帮助文档 `?flexdashboard::flex_dashboard`。下面仅简略列出部分内容

| 参数                | 描述                                                       |
| ------------------ | ------------------------------------------------------------ |
| fig_width          | 图片的宽度，默认 6                                           |
| fig_height         | 图片的高度，默认 4.8                                         |
| fig_retina         | retina 屏，默认 2                                            |
| fig_mobile         | 是否创建额外的图片，适合移动设备显示，默认 TRUE              |
| dev                | 图形设备类型，默认 png                                       |
| smart              | 生成排版正确的输出，默认 TRUE，比如直引号转弯引号，--- 转长破折号，-- 转短划线，... 转省略号。 |
| self_contained     | 是否将渲染结果打包成一个独立的 HTML 文件，默认 TRUE          |
| favicon            | 提供路径，给 dashboard 添加 icon                             |
| logo               | 提供路径，给 dashboard 添加 logo                             |
| social             | 提供字符串向量，给 dashboard 添加分享按钮，会出现在导航栏上  |
| source_code        | 提供 URL 链接指向 dashboard 源码，或者指定 embed ，代码随附  |
| orientation        | 'rows' 或 'columns'，  二级标题当作 dashboard 的行还是列     |
| vertical_layout    | 'fill' 或 'scroll' 垂直布局行为，fill 表示自适应填充页面，scroll 表示根据段落高度滚动 |
| storyboard         | 是否启用 storyboard 布局，默认 FALSE，一旦启用， orientation 和 vertical_layout 参数就会被忽略 |
| theme              | 页面整体的颜色样式："default", "bootstrap", "cerulean", "journal", "flatly", "readable", "spacelab", "united", "cosmo", "lumen", "paper", "sandstone", "simplex", or "yeti") |
| highlight          | 语法高亮："default", "tango", "pygments", "kate", "monochrome", "espresso", "zenburn", and "haddock" |
| mathjax            | MathJax 渲染数学公式，默认从 MathJax CDN 获取                |
| extra_dependencies | 外部依赖                                                     |
| css                | CSS 样式文件                                                 |
| includes           | 外部文档内容                                                 |
| lib_dir            | 外部 HTML 库                                                 |
| md_extensions      | 添加或移除 R Markdown 定义的 markdown 扩展                   |
| pandoc_args        | 传递给 Pandoc 的命令行参数                                   |
| resize_reload      | 窗口大小改变是否自动重加载 dashboard，默认 TRUE                   |

大部分参数的详细介绍见 <https://bookdown.org/yihui/rmarkdown/dashboards.html>，参数 `includes` 和 `pandoc_args` 的用法见 <https://bookdown.org/yihui/rmarkdown/output-formats.html>。


#### 4.6.2 局部段落配置

局部段落配置是什么意思呢？一篇文档一般来讲，会有一级、二级、三级标题，分别对应章、节、小节，在由 flexdashboard 控制布局的 R Markdown 文档里，一级标题负责分页，二级标题控制页签，三级标题是各个Tab 页的标题，这个逻辑是 flexdashboard 定义。

> 一级标题

```
Visualizations
===================================== 
```

> 二级标题

```
Row
-------------------------------------
```


> 带两个页签的二级标题，并排放置

```
Row
-------------------------------------

### Tab A

### Tab B
```

Tab 页的排列方式由二级标题的属性控制，折叠放置

```
Row {.tabset}
------------------

### Tab A

### Tab B
```

下图是一个迷你完整 R Markdown 文档的示例

<img src="https://user-images.githubusercontent.com/12031874/125879973-1321ba1f-9f7e-44db-9845-65c22027f929.png" alt="layout-input-ui" width="85%">

下表列出了用来控制一级、二级标题的行为属性，详细介绍见 <https://pkgs.rstudio.com/flexdashboard/articles/using.html>。

| 设置                        | 描述                                            |
| --------------------------- | ----------------------------------------------- |
| {.mobile}                   | 只在移动端显示                                  |
| {.no-mobile}                | 移动端不显示                                    |
| {.no-padding}               | 无边距图标 (默认边距8像素)                      |
| {.no-title}                 | 去除组件名称                                    |
| {.sidebar}                  | 以左侧边栏显示                                  |
| {.storyboard}               | 添加故事板(也可以在yaml中配置 storyboard: true) |
| {.tabset}                   | 以选项卡方式显示子页面                          |
| {.tabset-fade}              | 添加带有渐变效果的选项卡                        |
| {data-padding=10}           | 数据填充边距设置 （默认边距10像素）             |
| {data-height=650}           | 设置组件的相对高度                              |
| {data-width=350}            | 设置组件的相对宽度                              |
| {data-icon="fa-list"}       | 增加字体或者图标作为菜单栏标志                  |
| {data-orientation=rows}     | 设置页面布局方向                                |
| {data-navmenu="Menu A"}     | 菜单栏设定                                      |
| {data-commentary-width=400} | 故事板组件的相对宽度                            |



## 五、R Shiny 的定制开发（高级）

目前，Shiny 正朝着可全面配置化的方向发展，Carson Sievert 开发的 [thematic](https://github.com/rstudio/thematic) 简化了 **ggplot2**、**lattice**、Base R 图形的主题调整，主要是借助 [bslib](https://github.com/rstudio/bslib) 和 [sass](https://github.com/rstudio/sass) 将 Bootstrap 引入 R Markdown 和 R Shiny，在 R 环境中自定义 Bootstrap 的 CSS 样式，调整图形渲染效果。[jquerylib](https://github.com/rstudio/jquerylib) 将 [jquery](https://github.com/jquery/jquery) 打包进来，[htmltools](https://github.com/rstudio/htmltools) 将 HTML 也打包进来。R Shiny 本就是依赖 Bootstrap 提供前端 UI 渲染，一些自定义就离不开网页三剑客 --- HTML、CSS 和 JavaScript。

为了简化页面布局设计，除了 Shiny 自带的一些前端组件外，社区比较流行的有 R Markdown 环境下的 [flexdashboard](https://github.com/rstudio/flexdashboard) 和 R Shiny 环境下的 [bs4Dash](https://github.com/RinteRface/bs4Dash)。bs4Dash 发布了 2.0.0 版，对 [shinydashboard](https://github.com/rstudio/shinydashboard) 和 [shinydashboardPlus](https://github.com/RinteRface/shinydashboardPlus) 有极好的替代性，推荐迁移升级。


### 5.1 前端组件初探

Shiny 的 UI 组件是紧紧依赖 [Bootstrap](https://getbootstrap.com/) 的，它给 Shiny 提供了灵活且自适应的前端，以布局函数 `column()` 为例，它常用于筛选器的位置排列，我们看看它是怎么实现的位置排列，

```r
function (width, ..., offset = 0) 
{
    if (!is.numeric(width) || (width < 1) || (width > 12)) 
        stop("column width must be between 1 and 12")
    colClass <- paste0("col-sm-", width)
    if (offset > 0) {
        colClass <- paste0(colClass, " offset-md-", offset, " col-sm-offset-", 
            offset)
    }
    div(class = colClass, ...)
}
```

其中， `div()` 函数来自 htmltools 包，在包装 HTML 的 DIV 标签，给定参数 `width = 6` 和 `offset = 0`，函数 `column()` 就简化为

```r
div(class = "col-sm-6 offset-md-0 col-sm-offset-0", ...)
```

进一步，将其退化为 HTML 代码，即为

```html
<div class="col-sm-6 offset-md-0 col-sm-offset-0"></div>
```

和 Bootstrap 提供的[网格布局样式](https://getbootstrap.com/docs/5.0/layout/columns/#offsetting-columns) 对比，惊人的相似，本质是一个东西，改了改参数罢了。这样，我们就清楚了 Shiny 和 Bootstrap 的关系，如果需要调整筛选器的排列方式，比如想从左侧顶格开始排列筛选器，通过查看 Bootstrap 的文档 <https://getbootstrap.com/docs/5.0/layout/columns/>，只需将

```r
div(class = "row justify-content-start", ...)
```

套在 `column()` 函数外面，像这样

```r
div(
  class = "row justify-content-start",
    column(
      width = 4,
      dateRangeInput("daterange1", label = "分析时段",
        start = Sys.Date() - 7, end = Sys.Date() -1,
        min = "2019-01-01", max = Sys.Date() -1,
        language = "zh-CN"
      )
    ),
    column(
      width = 4,
      dateRangeInput("daterange2", label = "对比时段",
        start = Sys.Date() - 14, end = Sys.Date() - 8,
        min = "2019-01-01", max = Sys.Date() -1,
        language = "zh-CN"
      )
    ),
    column(
      width = 2,
      actionButton("action1",
        label = "查询",
        style = "margin-top:25px; color: #fff; background-color: #5b89f7; border-color: #5b89f7"
      )
    )
)
```

即可获得如下效果：

<img src="https://user-images.githubusercontent.com/12031874/124723180-5828cc80-df3d-11eb-83f9-c42240852fbc.png" alt="layout-input-ui" width="95%">


## 六、tidyverse 生态 （高级）

目前 R 语言社区基本分裂成两个阵营了，一个是 Base R，另一个是 tidyverse，二者在语法风格上截然不同，后者主要由 Hadley Wickham 开发和维护。Hadley Wickham 因在统计软件领域的突出贡献获得 2019 年的 [COPSS 会长奖](https://imstat.org/2019/09/02/copss-presidents-award-hadley-wickham/) --- 统计学领域的最高奖项，走上巅峰。2019 年也是 tidyverse 风刮得最猛烈的时候，毕竟背靠 RStudio 大厂，有资金支持，出了系列书籍，再加上个人影响力，R 包层面硬依赖等营销和倾销手段，已蔚然成风，期间虽有一些反对的声音，只是过于脆弱了。 tidyverse 包含一系列 R 包，覆盖数据获取、数据处理、数据可视化等领域，安装一个包就会把其它都安装上，比较核心的 dplyr 包不断更改 API 接口，且不向下兼容，稳定性很差，贬一个捧一个，在社交软件、RStudio 年度大会等各种场合反复洗脑宣传。它的好处在于统一代码风格，一旦入坑就要跟着 Hadley Wickham 走到底，花费大精力维护代码，线上环境要做好隔离和版本管理，谨慎升级。 

<img src="https://user-images.githubusercontent.com/12031874/124468598-e0876000-ddcb-11eb-855b-9c759fbcf485.png" alt="tidyverse-family" width="85%">

除了数据分析、数据可视化，相比于其它编程语言，R 语言另一大优势是统计建模，学术前沿成果会很快集成到 R 包里，tidymodels 就意图整合这一切。

<img src="https://user-images.githubusercontent.com/12031874/124468719-0d3b7780-ddcc-11eb-8a05-74df62bbb1b2.png" alt="tidymodels-family" width="85%">

## 七、案例学习（高级）

苏玮开发的[新型冠状病毒疫情速报](https://github.com/swsoyee/2019-ncov-japan) 可以作为案例学习一下，主要考虑到其代码量过万，访问量过千万，有一定的工程和设计思维在里面。项目目录结构如下，可按此线索，对照网站和代码去深入学习。

```md
.
├── 00_System             # 将原始数据预处理
├── 01_Settings           # 配色、文件路径和 GA 设置
├── 02_Utils              # 其它非全局共享的数据处理函数
├── 03_Components         # 渲染各个页面各个模块的前、后端代码
├── 04_Pages              # 渲染各个页面各个模块的前、后端代码
├── 2019-ncov-japan.Rproj # R 项目文件
├── 50_Data               # 存放数据的目录
├── LICENSE               # MIT 协议内容
├── README.cn.md          # 项目中文说明
├── README.en.md          # 项目英文说明
├── README.md             # 项目日文说明
├── global.R              # 应用内全局共享的函数、变量、数据等
├── rsconnect             # 部署 R Shiny 应用的残留文件，本可以不上传
├── server.R              # 服务端代码
├── ui.R                  # 前端代码
└── www                   # 一些用于前端的文件
```

其它值得学习的资源有 [Shiny 竞赛](https://blog.rstudio.com/2021/06/24/winners-of-the-3rd-annual-shiny-contest/)发布的获奖作品，比如[The Hotshots Racing Dashboard](https://github.com/rpodcast/hotshots.dashboard)  和[commute-explorer](https://github.com/nz-stefan/commute-explorer-2)，这两个的规模相对简单，但是内容很惊艳，值得一学。

## 八、其他 Web 框架

<!-- > 不能说人家不好，只是适用场景不同罢了，分享的目的是分享，不是引起战争，面对挑战的时候要冷静分析 -->

Python 社区有很多 Web 框架，比较流行的有 [Flask](https://github.com/pallets/flask/) 和 [Django](https://github.com/django/django)，它们是和 Shiny 同类的框架，一般来说，当我们的数据产品是面向 C 端消费者，Shiny 的局限就会暴露出来，此时，不得不前、后端分离，换能扛住并发场景的前后端架构。JavaScript 社区有很多前端框架，比较流行的有基于 [React](https://github.com/facebook/react) 的 [React native](https://github.com/facebook/react-native) 和基于 [Vue](https://github.com/vuejs/vue) 的[vue-element-admin](https://github.com/PanJiaChen/vue-element-admin)，这部分的介绍已经远远超出本文的范围，故略去。

[bokeh](https://github.com/bokeh/bokeh) 和 [plotly](https://github.com/plotly/plotly.js) 是两个比较流行的交互式绘图库，通过扩展提供一些 Web 开发的能力，前者完全开源，后者有削减功能的开源版和收费的服务器版本；前者提供部分简单的，不过，相比于 Shiny，它们的易用性都比较差，灵活性也不高。可以借助案例体验一下 bokeh 和 shiny 的差别 --- [bokeh 应用](https://demo.bokeh.org/movies) 和 [shiny 应用](https://gallery.shinyapps.io/051-movie-explorer/)，应用对应的代码分别为<https://github.com/bokeh/bokeh/tree/branch-2.4/examples/app/movies> 和 <https://github.com/rstudio/shiny-examples/tree/master/051-movie-explorer>。


## 九、参考文献

1. 【R Shiny 总纲】Mastering Shiny, Hadley Wickham, 2021. <https://mastering-shiny.org/>.

1. 【R Shiny 介绍】shiny 官网. <https://shiny.rstudio.com/>.

1. 【R Shiny 工程化】Engineering Production-Grade Shiny Apps, Colin Fay, Sébastien Rochette, Vincent Guyader, Cervan Girard, 2021. <https://engineering-shiny.org/>.

1. 【R 快速入门】Fast Lane to Learning R! Norm Matloff, 2021, <https://github.com/matloff/fasteR>.

1. 【有偏的 R 和 Python 对比】R vs. Python for Data Science, Norm Matloff, 2019, <https://github.com/matloff/R-vs.-Python-for-Data-Science>.

1. 【R 社区在割裂】An alternate view of the Tidyverse "dialect" of the R language, and its promotion by RStudio. Norm Matloff, 2020, <https://github.com/matloff/TidyverseSkeptic>.

1. 【R 入门卡片】Getting Started in R, Dirk Eddelbuettel, 2019, <https://github.com/eddelbuettel/gsir-te>.

1. 【R Markdown 食谱】R Markdown Cookbook,  Yihui Xie, Christophe Dervieux, Emily Riederer, 2020, <https://bookdown.org/yihui/rmarkdown-cookbook/>.

1. 【R 绘图食谱】R Graphics Cookbook, 2nd edition, Winston Chang, 2020, <https://r-graphics.org/>.

1. 【数据科学与 R 语言】R for Data Science, 2nd edition, Hadley Wickham and Garrett Grolemund, 2021, <https://r4ds.had.co.nz/>.

1. 【数据可视化】Fundamentals of Data Visualization, Claus O. Wilke, 2020, <https://clauswilke.com/dataviz/>.

1. 【R 高频问题集】The R FAQ, Kurt Hornik, 2020, <https://CRAN.R-project.org/doc/FAQ/R-FAQ.html>.

1. 【R 语言介绍】An Introduction to R, R Core Team, 2021, <https://cran.r-project.org/doc/manuals/R-intro.html>.
1. 【R Shiny 高级】Shiny in production: Principles, practices, and tools, Joe Cheng, 2019, <https://www.youtube.com/watch?v=Wy3TY0gOmJw&ab_channel=RStudio>.

1. 【R 语言基础】R 语言教程, 李东风, 2020, <https://www.math.pku.edu.cn/teachers/lidf/docs/Rbook/html/_Rbook/index.html>.
