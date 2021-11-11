---
title: "交互式网页图形与 R 语言"
author: "黄湘云"
date: '2021-10-10'
slug: interactive-web-graphics
toc: true
categories:
  - R 语言
  - 统计图形
tags:
  - plotly
  - highcharter
  - echarts4r
bibliography: 
  - refer.bib
  - packages.bib
link-citations: true
draft: true
thumbnail: /img/iris.svg
description: "R 语言在数据可视化方面有很长时间的积累，除了内置的基础作图系统和栅格作图系统，以及衍生出来的代表作 lattice 和 ggplot2 ，更加易用、便携、交互的网页图形逐渐形成新的主流。移动终端设备的大规模普及，探索性数据分析和可视化需求越来越强烈，得益于现代硬件设施和前端技术的落地，交互式网页图形逐渐成为数据展示中的标配。"
---

<style type="text/css">
.rmdinfo {
  border: 1px solid #ccc;
}

.rmdinfo {
  border-left-width: 5px;
  border-radius: 5px;
  padding: 1em;
  margin: 1em 0;
}

figure {
  text-align: center;
}
</style>

<div class="rmdinfo">

声明：本文引用的所有信息均为公开信息，仅代表作者本人观点，与就职单位无关。

</div>

R 语言在数据可视化方面有很长时间的积累，除了内置的基础作图系统和栅格作图系统，以及衍生出来的代表作 lattice 和 ggplot2 ，更加易用、便携、交互的网页图形逐渐形成新的主流。移动终端设备的大规模普及，探索性数据分析和可视化需求越来越强烈，得益于现代硬件设施和前端技术的落地，交互式网页图形逐渐成为数据展示中的标配。图形种类繁多，交互式的种类不比静态的少，本文亦无意全面罗列，而是以散点图为例，详细介绍几个常用 R 包的使用，望读者能举一反三。

## 概览

本文将主要介绍 R 语言绘制交互式网页图形的扩展包，综合考虑了使用权限，图形种类，接口成熟度等方面因素，挑选了 [plotly](https://github.com/plotly/plotly.R)、 [ggiraph](https://github.com/davidgohel/ggiraph)、 [scatterD3](https://github.com/juba/scatterD3)、 [apexcharter](https://github.com/dreamRs/apexcharter) 和 [echarts4r](https://github.com/JohnCoene/echarts4r) 等几个 R 包。R 语言还有一些专门化的可视化扩展包，比如绘制交互网络图的[visNetwork](https://github.com/datastorm-open/visNetwork) ，绘制交互地图的[leaflet](https://github.com/rstudio/leaflet) 等，更多详见[Ryan Hafen](https://github.com/hafen) 收集整理的交互式图形[展览网站](https://gallery.htmlwidgets.org/)。

| Package                                                  | Title                                                            | Maintainer          | URL                                                                           | License                 |
|:---------------------------------------------------------|:-----------------------------------------------------------------|:--------------------|:------------------------------------------------------------------------------|:------------------------|
| plotly ([Sievert et al. 2021](#ref-plotly))              | Create Interactive Web Graphics via plotly.js                    | Carson Sievert      | https://plotly-r.com https://github.com/plotly/plotly.R https://plotly.com/r/ | MIT + file LICENSE      |
| ggiraph ([Gohel and Skintzos 2021](#ref-ggiraph))        | Make ggplot2 Graphics Interactive                                | David Gohel         | https://davidgohel.github.io/ggiraph/                                         | GPL-3                   |
| echarts4r ([Coene 2021](#ref-echarts4r))                 | Create Interactive Graphs with Echarts JavaScript Version 5      | John Coene          | https://echarts4r.john-coene.com/ https://github.com/JohnCoene/echarts4r      | Apache License (>= 2.0) |
| scatterD3 ([Barnier et al. 2021](#ref-scatterD3))        | D3 JavaScript Scatterplot from R                                 | Julien Barnier      | https://juba.github.io/scatterD3/                                             | GPL (>= 3)              |
| ggplot2 ([Wickham et al. 2021](#ref-ggplot2))            | Create Elegant Data Visualisations Using the Grammar of Graphics | Thomas Lin Pedersen | https://ggplot2.tidyverse.org https://github.com/tidyverse/ggplot2            | MIT + file LICENSE      |
| apexcharter ([Perrier and Meyer 2021](#ref-apexcharter)) | Create Interactive Chart with the JavaScript ApexCharts Library  | Victor Perrier      | https://github.com/dreamRs/apexcharter https://dreamrs.github.io/apexcharter/ | MIT + file LICENSE      |

![老忠实间歇泉喷发规律](https://user-images.githubusercontent.com/12031874/110227135-11e04400-7f30-11eb-949d-61210ee37f5a.png)

-   [**plotly**](https://github.com/ropensci/plotly) 功能很全，但是很笨重，作者在这方面没有投入太多精力解决用户问题，处于维护

-   [**echarts4r**](https://github.com/JohnCoene/echarts4r) 功能很全，比较轻量，但是和 plotly 一样都严重依赖 dplyr，而我不喜欢 dplyr 特别是不喜欢画图的库还依赖 dplyr

-   [**highcharter**](https://github.com/jbkunst/highcharter) 函数接口命名很糟糕，轻量

-   [**apexcharter**](https://github.com/dreamRs/apexcharter) 支持的图形种类还比较少

-   轻量：一方面图形库本身，另一方面依赖

-   不仅仅是作者一人维护，而且有多位持续维护者

-   功能比较全面，比如 plotly 和 echarts4r 包

## plotly

Python 社区比较大，[pyecharts](https://github.com/pyecharts/pyecharts) 在 Github 上的星赞比较多，但是还要考虑做数据产品的方便，就是与类似 shiny 这样的 Web 库的协同情况

### Python 语言版本

JavaScript 库 Plotly 的 Python 接口绘制图<a href="#fig:plotly-python-iris">1</a>，iris 鸢尾花数据集按花种类分组线性回归，展示相关性。

Python

``` python
import plotly.express as px
px.scatter(
    px.data.iris(),
    x="sepal_width",
    y="sepal_length",
    color="species",
    trendline="ols",
    template="simple_white",
    labels={
        "sepal_length": "萼片长度 (cm)",
        "sepal_width": "萼片宽度 (cm)",
        "species": "种类",
    },
    title="Edgar Anderson 的鸢尾花数据",
    color_discrete_sequence=px.colors.qualitative.Set2
)
```

<figure>
<img src="https://user-images.githubusercontent.com/12031874/140610586-742caa14-c55a-460d-be04-f0810104f6d6.png" class="full" alt="Figure 1: 鸢尾花散点图" /><figcaption aria-hidden="true">Figure 1: 鸢尾花散点图</figcaption>
</figure>

RColorBrewer 包内置调色板见图 <a href="#fig:rcolorbrewer">2</a>

<figure>
<img src="https://user-images.githubusercontent.com/12031874/140612809-ffac9e3e-566e-4ed3-8375-9ae1460d2088.png" class="full" alt="Figure 2: RColorBrewer 包内置调色板" /><figcaption aria-hidden="true">Figure 2: RColorBrewer 包内置调色板</figcaption>
</figure>

### R 语言版本

R 语言版本 plotly ([Sievert 2020](#ref-Sievert2020))

``` r
library(plotly)

plot_ly(
  data = iris,
  # 横轴变量
  x = ~Sepal.Width,
  # 纵轴变量
  y = ~Sepal.Length,
  # 分类变量
  color = ~Species,
  # 调色板：RColorBrewer 包内置的调色板都支持
  colors = "Set2",
  # 图形种类：散点图
  type = "scatter",
  # 显示模式：散点，读者不妨试试 "markers+lines"
  mode = "markers",
  # 散点的样式
  marker = list(
    # 圆形
    symbol = "circle",
    # 如果有 size 变量，则映射到圆的直径，当然还可以映射到面积 area
    sizemode = "diameter",
    # 散点大小
    size = 15,
    # 圆的边界宽度为 2 和颜色为白色
    line = list(width = 2, color = "#FFFFFF"),
    # 圆的透明度，注意同一位置的圆点重合后颜色会加深
    opacity = 0.8
  ),
  text = ~ paste0(
    "萼片宽度：", Sepal.Width, "<br>",
    "萼片长度：", Sepal.Length
  ),
  hoverinfo = "text"
) %>%
  layout(
    title = "鸢尾花数据",
    # 添加横轴标题，去掉水平线，坐标轴刻度值保留一位小数，如果单位是百分比，则为 .1%
    xaxis = list(title = "萼片宽度", showgrid = FALSE, tickformat = ".1f"),
    # 添加纵轴标题，去掉垂直线
    yaxis = list(title = "萼片长度", showgrid = FALSE, tickformat = ".1f"),
    # 取消拖拽和局部缩放
    dragmode = FALSE,
    # 设置图例标题并加粗
    legend = list(title = list(text = "<b> 种类 </b>")),
    # 按照下 bottom 左 left 上 top 右 right 的顺序设置图形边空
    margin = list(b = 50, l = 50, t = 35, r = 0)
  ) %>%
  config(
    toImageButtonOptions = list(
      # 保存图片格式
      format = "svg", 
      # 图片宽度
      width = 800, 
      # 图片高度
      height = 600,
      # 图片文件名
      filename = paste("iris", Sys.Date(), sep = "_")
    )
  )
```

<figure>
<img src="/img/iris.svg" class="full" alt="Figure 3: 鸢尾花散点图" /><figcaption aria-hidden="true">Figure 3: 鸢尾花散点图</figcaption>
</figure>

<figure>
<img src="https://user-images.githubusercontent.com/12031874/140611946-2971d2e6-dab7-4814-8b22-ba57d505bbb3.png" class="full" alt="Figure 4: 鸢尾花散点图" /><figcaption aria-hidden="true">Figure 4: 鸢尾花散点图</figcaption>
</figure>

散点图更多详细设置见[文档](https://plotly.com/r/marker-style/)

<div class="rmdinfo">

Python 版本和 R 语言版本不要同时使用，以免 plotly 库版本不同带来冲突。另一个值得一提的是移除 plotly 图形右上方的工具条，可以添加全局的 CSS 设置。

``` css
.modebar {
  display: none !important;
}
```

不管是连续型还是离散型的调色板，数量都是 8-12 个有限值，一旦超出数量会触发警告：

    Warning message:
    In RColorBrewer::brewer.pal(n = 20, name = "Set2") :
      n too large, allowed maximum for palette Set2 is 8
    Returning the palette you asked for with that many colors

不过，plotly 还是会通过插值方式返回足够多的色块，读者也可以尝试使用 `viridis`、`plasma`、`magma` 或 `inferno` 调色板，它们既可以当连续的也可以当离散的用。

</div>

## ggiraph

ggplot2

[ggiraph](https://github.com/davidgohel/ggiraph)

Edgar Anderson 的鸢尾花数据 ggplot2 图 <a href="#fig:ggplot2-iris">5</a>

``` r
library(ggplot2)
ggplot(data = iris, aes(x = Sepal.Width, y = Sepal.Length, color = Species)) +
  geom_point() +
  geom_smooth(method = "lm", formula = y~x, se = FALSE) +
  labs(x = "萼片长度", y = "萼片宽度", color = "种类") +
  theme_bw(base_size = 13, base_family = "Noto Sans") +
  theme(title = element_text(family = "Noto Serif CJK SC"))
```

<figure>
<img src="https://user-images.githubusercontent.com/12031874/140610866-f142b14e-071c-48b2-b32d-b59c697516e2.png" class="full" alt="Figure 5: 鸢尾花散点图" /><figcaption aria-hidden="true">Figure 5: 鸢尾花散点图</figcaption>
</figure>

## scatterD3

[scatterD3](https://github.com/juba/scatterD3) 基于鼎鼎大名的 D3 图形库，在散点图方面的渲染效果非常好。

如图<a href="#fig:scatterd3-iris">6</a> 所示

``` r
# 加载 R 包
library(scatterD3)

scatterD3(
  # 数据集
  data = iris, 
  # 横轴变量
  x = Sepal.Length, 
  # 纵轴变量
  y = Sepal.Width,
  # 分类变量
  col_var = Species, 
  # 分类调色板 Tableau
  colors = "schemeTableau10",
  # 散点的大小
  point_size = 200, 
  # 散点的透明度
  point_opacity = 0.7,
  # 鼠标悬停处散点的大小
  hover_size = 4, 
  # 鼠标悬停处散点的透明度
  hover_opacity = 1,
  # 横轴标题
  xlab = "Sepal Length",
  # 纵轴标题
  ylab = "Sepal Width", 
  # 图例标题
  col_lab = "Species",
  # 坐标轴字体大小
  axes_font_size = "160%", 
  # 图例字体大小
  legend_font_size = "16px",
  # 提示符出现左上
  tooltip_position = "top left", 
  # 聚类椭圆
  ellipses = TRUE, 
  # 去掉导出
  menu = FALSE
)
```

<figure>
<img src="https://user-images.githubusercontent.com/12031874/140610124-7bc984cf-c3dc-474b-896a-fa87a22244f9.png" class="full" alt="Figure 6: 鸢尾花散点图" /><figcaption aria-hidden="true">Figure 6: 鸢尾花散点图</figcaption>
</figure>

[分类离散型](https://github.com/d3/d3-scale-chromatic#categorical)的调色板支持所有 RColorBrewer 包内置的离散型调色板，外加 schemeCategory10 和 schemeTableau10 两个调色板，注意使用时要色板名添加前缀 scheme，[数值连续型](https://github.com/d3/d3-scale-chromatic#diverging) 与之类似，不再赘述。

## apexcharter

[apexcharter](https://github.com/dreamRs/apexcharter) 是 [apexcharts.js](https://github.com/apexcharts/apexcharts.js) 的 R 接口，apexcharts.js 构建于 SVG 之上，原生支持矢量图形导出。

``` r
library(apexcharter)

apex(
  data = iris,
  aes(x = Sepal.Width, y = Sepal.Length, fill = Species),
  type = "scatter"
) |>
  # 设置调色板
  ax_colors(RColorBrewer::brewer.pal(n = 3, name = "Set2")) |>
  # 散点的透明度
  ax_fill(opacity = 0.7) |>
  # 显示图例
  ax_legend(show = TRUE) |>
  # 标题
  ax_title(text = "散点图") |>
  # 副标题
  ax_subtitle(text = "鸢尾花数据集")
```

<figure>
<img src="https://user-images.githubusercontent.com/12031874/140614562-691f12d3-3d59-4096-b087-3f01da4c4795.png" class="full" alt="Figure 7: 鸢尾花散点图" /><figcaption aria-hidden="true">Figure 7: 鸢尾花散点图</figcaption>
</figure>

设置调色板的部分，也可以采用手动一一指定的方式，用下述代码替换 `ax_colors()` 所在行。

``` r
ax_colors_manual(list(
  "setosa" = "#66C2A5",
  "versicolor" = "#FC8D62",
  "virginica" = "#8DA0CB"
))
```

## echarts4r

[echarts4r](https://github.com/JohnCoene/echarts4r)

``` r
# x/y 轴自适应，不要从 0 开始
library(echarts4r)

iris <- transform(iris,
  color = factor(
    Species,
    levels = c("setosa", "versicolor", "virginica"),
    labels = RColorBrewer::brewer.pal(n = 3, name = "Set2")
  )
)

e_chart(data = iris, x = Sepal.Width) |>
  e_scatter(serie = Sepal.Length, symbol_size = 10) |>
  e_add_nested("itemStyle", color)
```

## 其它 R 包

当然，此外还有很多可以绘制交互式图形的 R 包，如[**rAmCharts4**](https://github.com/stla/rAmCharts4)、[**highcharter**](https://github.com/jbkunst/highcharter)和 [rbokeh](https://github.com/bokeh/rbokeh) 等，不再一一介绍，希望读者能多练习，然后掌握其一般规律。

``` r
# 移除背景网格、按钮
library(rbokeh)
figure() %>%
  ly_points(Sepal.Length, Sepal.Width,
    data = iris,
    color = Species, glyph = Species,
    hover = list(Sepal.Length, Sepal.Width)
  )
```

**rAmCharts4** 和 **highcharter** 分别依赖商业的图形库[amCharts 4](https://www.amcharts.com/docs/v4/)和[highcharts](https://www.highcharts.com/)，有一定版权风险，因此，不推荐使用。

某些 R 包的接口使用起来比较复杂，或者某些高级的图形需要自定义，对于这种情况，已存在一些 R 包来填补 Gap。比如[simplevis](https://github.com/statisticsnz/simplevis/)

## 环境信息

在 RStudio IDE 内编辑本文的 Rmarkdown 源文件，用 **blogdown** ([Xie, Hill, and Thomas 2017](#ref-Xie2017)) 构建网站，[Hugo](https://github.com/gohugoio/hugo) 渲染 knitr 之后的 Markdown 文件，得益于 **blogdown** 对 Rmarkdown 格式的支持，图、表和参考文献的交叉引用非常方便，省了不少文字编辑功夫。文中使用了多个 R 包，为方便复现本文内容，下面列出详细的环境信息：

``` r
xfun::session_info(packages = c(
  "knitr", "rmarkdown", "blogdown", 
  "plotly", "scatterD3", "echarts4r", 
  "apexcharter", "ggplot2", "ggiraph"
), dependencies = FALSE)
```

    ## R version 4.1.2 (2021-11-01)
    ## Platform: x86_64-apple-darwin17.0 (64-bit)
    ## Running under: macOS Big Sur 10.16
    ## 
    ## Locale: en_US.UTF-8 / en_US.UTF-8 / en_US.UTF-8 / C / en_US.UTF-8 / en_US.UTF-8
    ## 
    ## Package version:
    ##   apexcharter_0.3.0 blogdown_1.6      echarts4r_0.4.2   ggiraph_0.7.10   
    ##   ggplot2_3.3.5     knitr_1.36        plotly_4.10.0     rmarkdown_2.11   
    ##   scatterD3_1.0.1  
    ## 
    ## Pandoc version: 2.14.2
    ## 
    ## Hugo version: 0.89.2

## 参考文献

<div id="refs" class="references csl-bib-body hanging-indent">

<div id="ref-scatterD3" class="csl-entry">

Barnier, Julien, Kent Russell, Mike Bostock, Susie Lu, Speros Kokenes, and Evan Wang. 2021. *scatterD3: D3 JavaScript Scatterplot from r*. <https://juba.github.io/scatterD3/>.

</div>

<div id="ref-echarts4r" class="csl-entry">

Coene, John. 2021. *Echarts4r: Create Interactive Graphs with Echarts JavaScript Version 5*. <https://CRAN.R-project.org/package=echarts4r>.

</div>

<div id="ref-ggiraph" class="csl-entry">

Gohel, David, and Panagiotis Skintzos. 2021. *Ggiraph: Make Ggplot2 Graphics Interactive*. <https://davidgohel.github.io/ggiraph/>.

</div>

<div id="ref-apexcharter" class="csl-entry">

Perrier, Victor, and Fanny Meyer. 2021. *Apexcharter: Create Interactive Chart with the JavaScript ApexCharts Library*. <https://CRAN.R-project.org/package=apexcharter>.

</div>

<div id="ref-Sievert2020" class="csl-entry">

Sievert, Carson. 2020. *Interactive Web-Based Data Visualization with r, Plotly, and Shiny*. Chapman; Hall/CRC. <https://plotly-r.com>.

</div>

<div id="ref-plotly" class="csl-entry">

Sievert, Carson, Chris Parmer, Toby Hocking, Scott Chamberlain, Karthik Ram, Marianne Corvellec, and Pedro Despouy. 2021. *Plotly: Create Interactive Web Graphics via Plotly.js*. <https://CRAN.R-project.org/package=plotly>.

</div>

<div id="ref-ggplot2" class="csl-entry">

Wickham, Hadley, Winston Chang, Lionel Henry, Thomas Lin Pedersen, Kohske Takahashi, Claus Wilke, Kara Woo, Hiroaki Yutani, and Dewey Dunnington. 2021. *Ggplot2: Create Elegant Data Visualisations Using the Grammar of Graphics*. <https://CRAN.R-project.org/package=ggplot2>.

</div>

<div id="ref-Xie2017" class="csl-entry">

Xie, Yihui, Alison Presmanes Hill, and Amber Thomas. 2017. *<span class="nocase">blogdown</span>: Creating Websites with R Markdown*. Boca Raton, Florida: Chapman; Hall/CRC. <https://bookdown.org/yihui/blogdown/>.

</div>

</div>
