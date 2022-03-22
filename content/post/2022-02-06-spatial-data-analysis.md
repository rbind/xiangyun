---
title: 空间数据分析与 R 语言
author: 黄湘云
date: '2022-04-20'
slug: spatial-data-analysis
categories:
  - 统计模型
tags:
  - 空间随机过程
  - 地统计学
  - 克里金插值
  - 数据可视化
  - 交互式图形
  - 轨迹分析
  - 房价分析
  - 深圳房价
  - 供需分析
  - sp
  - gstat
toc: true
draft: true
thumbnail: /img/logo/gdal.svg
link-citations: true
bibliography: 
  - refer.bib
  - packages.bib
description: "本文以四个真实数据为背景，介绍空间点数据、轨迹数据和区域数据的分析、建模和可视化。地统计学方法分析城市地表土壤重金属污染状况，空间点模式统计方法分析北京出租车轨迹，加权地理神经网络分析美国波士顿和中国深圳房价，时空统计方法分析近40年中日美区县级人口增长率。"
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

<div class="rmdinfo">

本文引用的所有信息均为公开信息，仅代表作者本人观点，与就职单位无关。

</div>

# 概览

在地统计分析方面，比较流行的 R 包有 **gstat** ([Pebesma 2004](#ref-Pebesma2004)) 包，**geoR** 包， **geoRglm** 包([Christensen and Ribeiro Jr. 2002](#ref-geoRglm2002))和 **PrevMap** 包([Giorgi and Diggle 2017](#ref-PrevMap2017))等，而点过程分析方面，**splance** 包和 **spatstat** 包([Baddeley and Turner 2005](#ref-Baddeley2005))。

空间和时空点模式分析《Statistical Analysis of Spatial and Spatio-Temporal Point Patterns》([Diggle 2013](#ref-Diggle2013))

本文以 **sp** 包 ([Pebesma and Bivand 2005](#ref-Pebesma2005)) 内置的 meuse 数据集为例介绍空间数据分析、建模的过程。主要使用的 R 包有 **sp** 包 和 **gstat** 包，继续围绕 sp 空间数据进行介绍，一方面 sp 的生态非常成熟，完全迁移到 **sf** 包 ([Pebesma 2018](#ref-Pebesma2018)) 为核心的生态尚需要时日；另一方面，笔者也在摸索学习过程中，以空间统计为重，以后可以再将本文的代码升级到 **sf** 为核心的生态。

本文主要的参考材料来自[**sp**](https://github.com/edzer/sp/)包 的[帮助文档](https://edzer.github.io/sp/) 和 [**gstat**](https://github.com/r-spatial/gstat/) 包的[帮助文档](https://edzer.github.io/sp/)，
以及三本参考书籍《Model-based Geostatistics》([Diggle and Ribeiro Jr. 2007](#ref-Diggle2007)) 和《Applied spatial data analysis with R》([Bivand, Pebesma, and Gomez-Rubio 2013](#ref-Bivand2013))，
最后一本是《lattice: Multivariate Data Visualization with R》([Sarkar 2008](#ref-Sarkar2008))，供绘制图形时，充当查询手册。

# 软件准备

``` r
library(ggplot2)   # https://github.com/tidyverse/ggplot2
library(gganimate) # 动态可视化
library(ggspatial) # 静态可视化
library(leaflet)   # 交互可视化
library(mapview)   # https://github.com/r-spatial/mapview
library(mapedit)   # https://github.com/r-spatial/mapedit
# 空间点数据处理、分析
library(sp)
library(sf)
# Linking to GEOS 3.9.1, GDAL 3.4.0, PROJ 8.1.1; sf_use_s2() is TRUE
library(gstat)
library(lattice)
library(mapsf)
library(maptiles)
# 栅格数据处理
library(raster)
library(rasterVis)
library(stars)
# Loading required package: abind
# 设置 WebGL 渲染
options(rgl.useNULL = TRUE)
options(rgl.printRglwidget = TRUE)
library(rgl)
```

# 数据结构

连续空间数据：地统计数据和空间点数据，离散空间数据：栅格数据

线下有需求，通过 App 表达需求，线上用户行为是结果，理解用户意图需要从线下出发。

栅格数据，连续和离散型变量

## 栅格数据 raster

关于栅格数据的介绍，还是以 raster 为主，因为读者肯定还会遇到大量以 raster 为主的分析代码，同时提供 terra 替代介绍，后者是升级替代，性能更好。raster 和 terra 在栅格数据的抽象表示上和 stars 是不同的。

``` r
data(grain, package = "spData")
terra::plot(grain,
  asp = NA,
  col = hcl.colors(4, palette = "Plasma")
)
```

<figure>
<img src="/img/maps-in-r/raster-grain.png" class="full" alt="图 1: terra 包绘制栅格数据" />
<figcaption aria-hidden="true">图 1: <strong>terra</strong> 包绘制栅格数据</figcaption>
</figure>

## 栅格数据 terra

[**spData**](https://github.com/Nowosad/spData/) 包内的 wheat 数据集来自非常经典的空间统计书籍《Statistics for Spatial Data》([Cressie 1993](#ref-Cressie1993))。

``` r
# sf 读取 shp 文件
library(sf)
wheat <- st_read(system.file("shapes/wheat.shp", package = "spData"))
# Reading layer `wheat' from data source 
#   `/Library/Frameworks/R.framework/Versions/4.1/Resources/library/spData/shapes/wheat.shp' 
#   using driver `ESRI Shapefile'
# Simple feature collection with 500 features and 8 fields
# Geometry type: POLYGON
# Dimension:     XY
# Bounding box:  xmin: 1.255 ymin: 1.35 xmax: 64 ymax: 67.35
# CRS:           NA
wheat
# Simple feature collection with 500 features and 8 fields
# Geometry type: POLYGON
# Dimension:     XY
# Bounding box:  xmin: 1.255 ymin: 1.35 xmax: 64 ymax: 67.35
# CRS:           NA
# First 10 features:
#    SP_ID SP_ID_1 lat yield    r     c   lon lat1                       geometry
# 1      0      g1 3.3  3.63 65.7  2.51  2.51 65.7 POLYGON ((1.255 64.05, 1.25...
# 2      1      g2 3.3  4.15 65.7  5.02  5.02 65.7 POLYGON ((3.765 64.05, 3.76...
# 3      2      g3 3.3  4.06 65.7  7.53  7.53 65.7 POLYGON ((6.275 64.05, 6.27...
# 4      3      g4 3.3  5.13 65.7 10.04 10.04 65.7 POLYGON ((8.785 64.05, 8.78...
# 5      4      g5 3.3  3.04 65.7 12.55 12.55 65.7 POLYGON ((11.3 64.05, 11.3 ...
# 6      5      g6 3.3  4.48 65.7 15.06 15.06 65.7 POLYGON ((13.8 64.05, 13.8 ...
# 7      6      g7 3.3  4.75 65.7 17.57 17.57 65.7 POLYGON ((16.32 64.05, 16.3...
# 8      7      g8 3.3  4.04 65.7 20.08 20.08 65.7 POLYGON ((18.82 64.05, 18.8...
# 9      8      g9 3.3  4.14 65.7 22.59 22.59 65.7 POLYGON ((21.34 64.05, 21.3...
# 10     9     g10 3.3  4.00 65.7  25.1 25.10 65.7 POLYGON ((23.85 64.05, 23.8...
```

``` r
plot(wheat["yield"])
```

<figure>
<img src="/img/maps-in-r/sf-wheat.png" class="full" alt="图 2: 小麦产量空间分布图" />
<figcaption aria-hidden="true">图 2: 小麦产量空间分布图</figcaption>
</figure>

## 栅格数据 stars

相比于 **terra**，**stars** 采用数组的概念，和 **sf** 的理念更加贴合一些，用多维数组表示时空数据，而不管空间数据是矢量还是栅格的。

``` r
install.packages("starsdata",
  repos = "http://gis-bigdata.uni-muenster.de/pebesma",
  type = "source", lib = "~/Documents/R-packages"
)
```

# 栅格图形

## ggplot2

iPhone 12 Pro 拍摄的照片默认采用 HEIC (High Efficiency Image Container) 格式保存，这是一张层次很丰富的乌云照片，原始尺寸为 `\(4032 \times 3024\)`，这里先用 [ImageMagick](https://imagemagick.org/) 将 HEIC 格式转化为 Tiff 格式，长宽尺寸均缩小为原来的十分之一，方便后续处理。

``` bash
magick dark_cloud.HEIC -resize 10% dark_cloud.tif
```

``` r
library(stars)
dark_cloud <- stars::read_stars("../../static/img/maps-in-r/dark-cloud.tif")
plot(dark_cloud)
# 调用 ggplot2 绘图
library(ggplot2)
ggplot() +
  geom_stars(data = dark_cloud) +
  facet_wrap(~band, ncol = 2) +
  coord_equal() +
  theme_void() +
  scale_x_discrete(expand = c(0, 0)) +
  scale_y_discrete(expand = c(0, 0)) +
  scale_fill_viridis_c()
```

<figure>
<img src="/img/maps-in-r/cloud-stars.png" class="full" alt="图 3: stars 包读取 raster 数据" />
<figcaption aria-hidden="true">图 3: <strong>stars</strong> 包读取 raster 数据</figcaption>
</figure>

颜色越深，乌云越厚，真正的 GeoTIFF 图片一般包含 RGB 三颜色和 alpha 通道，笔者用 iPhone 12 Pro 拍摄的天空照片，与之相似但是缺少了 alpha 通道。卫星拍摄的 TIFF 照片与此大致相仿，所使用的镜头不同而已。剩下的就是图像处理，这一块内容很多，如检测 detection，分割 segmentation，识别 recognition 等等，鉴于笔者对这一领域全然不了解，就不班门弄斧了。

# 案例：波士顿郊区房价分析

[Arya A. Pourzanjani](https://github.com/pourzanj)采用[贝叶斯神经网络分析方法](https://github.com/pourzanj/Bayesian_Neural_Networks) 预测房价。

[中国深圳房价估值模型](https://arxiv.org/abs/2202.04358)

<!-- 补充波士顿的地图  leaflet  usmap -->

本节分析 R 包 **MASS** 内置的波士顿郊区房价数据集 *Boston*，一共**506**条记录和**14**个特征变量，由 Boston Standard Metropolitan Statistical Area (SMSA) 在 **1970** 年收集，在做分析之前，首先要对每个特征变量的含义有充分的理解。

crim  
城镇人均犯罪率 per capita crime rate by town

zn  
占地面积超过25,000平方尺的住宅用地比例 proportion of residential land zoned for lots over 25,000 sq.ft.

indus  
每个城镇非零售业务的比例 proportion of non-retail business acres per town.

chas  
查尔斯河 Charles River dummy variable (= 1 if tract bounds river; 0 otherwise).

nox  
氮氧化物浓度 nitrogen oxides concentration (parts per 10 million).

rm  
每栋住宅的平均房间数量 average number of rooms per dwelling.
容积率

age  
1940年以前建造的自住单位比例 proportion of owner-occupied units built prior to 1940.
房龄

dis  
到波士顿五个就业中心的加权平均值 weighted mean of distances to five Boston employment centres.
商圈

rad  
径向高速公路可达性指数 index of accessibility to radial highways.
交通

tax  
每10,000美元的全额物业税率 full-value property-tax rate per \$10,000.
物业

ptratio  
城镇的师生比例 pupil-teacher ratio by town.
教育

black  
城镇黑人比例 `$1000(Bk - 0.63)^2$` where Bk is the proportion of blacks by town.
安全

lstat  
较低的人口状况（百分比）lower status of the population (percent).

medv  
自住房屋的中位数为1000美元 median value of owner-occupied homes in \$1000s. 房价，这是响应变量

``` r
data("Boston", package = "MASS")
Boston
#         crim    zn indus chas    nox    rm   age    dis rad tax ptratio  black lstat
# 1    0.00632  18.0  2.31    0 0.5380 6.575  65.2  4.090   1 296    15.3 396.90  4.98
# 2    0.02731   0.0  7.07    0 0.4690 6.421  78.9  4.967   2 242    17.8 396.90  9.14
# 3    0.02729   0.0  7.07    0 0.4690 7.185  61.1  4.967   2 242    17.8 392.83  4.03
# 4    0.03237   0.0  2.18    0 0.4580 6.998  45.8  6.062   3 222    18.7 394.63  2.94
# 5    0.06905   0.0  2.18    0 0.4580 7.147  54.2  6.062   3 222    18.7 396.90  5.33
....
```

# 案例：中日美人口增长率分析

改革开放40年为背景，尽量获取近40年区县级几个宏观指标，分别是人口增长率，失业率，城镇化率和固定资产投资增速/占比。

## 数据获取

数据说明

-   中国国家、省、市、县统计年鉴数据
-   日本
-   美国人口普查数据
    [Analyzing US Census Data: Methods, Maps, and Models in R](https://walker-data.com/census-r/mapping-census-data-with-r.html)

[tigris](https://github.com/walkerke/tigris)
[tidycensus](https://github.com/walkerke/tidycensus)

## 静态可视化

ggplot2

## 动态可视化

ggplot2 和 gganimate 配合动态可视化

## 交互式动态可视化

Python 版 plotly 绘制 choropleth map 交互式动态可视化。

## 沉浸式探索性分析

shiny 沉浸式探索性分析

# 环境信息

在 RStudio IDE 内编辑本文的 R Markdown 源文件，用 **blogdown** ([Xie, Hill, and Thomas 2017](#ref-Xie2017)) 构建网站，[Hugo](https://github.com/gohugoio/hugo) 渲染 **knitr** 之后的 Markdown 文件，得益于 **blogdown** 对 R Markdown 格式的支持，图、表和参考文献的交叉引用非常方便，省了不少文字编辑功夫。文中使用了多个 R 包，为方便复现本文内容，下面列出详细的环境信息：

``` r
xfun::session_info(packages = c(
  "knitr", "rmarkdown", "blogdown",
  "sp", "gstat", "lattice"
), dependencies = FALSE)
# R version 4.1.3 (2022-03-10)
# Platform: x86_64-apple-darwin17.0 (64-bit)
# Running under: macOS Big Sur/Monterey 10.16
# 
# Locale: en_US.UTF-8 / en_US.UTF-8 / en_US.UTF-8 / C / en_US.UTF-8 / en_US.UTF-8
# 
# Package version:
#   blogdown_1.8    gstat_2.0-9     knitr_1.37      lattice_0.20-45 rmarkdown_2.13 
#   sp_1.4-6       
# 
# Pandoc version: 2.17.1.1
# 
# Hugo version: 0.91.2
```

# 参考文献

<div id="refs" class="references csl-bib-body hanging-indent">

<div id="ref-Baddeley2005" class="csl-entry">

Baddeley, Adrian, and Rolf Turner. 2005. “<span class="nocase">spatstat</span>: An R Package for Analyzing Spatial Point Patterns.” *Journal of Statistical Software* 12 (6): 1–42. <https://doi.org/10.18637/jss.v012.i06>.

</div>

<div id="ref-Bivand2013" class="csl-entry">

Bivand, Roger S., Edzer Pebesma, and Virgilio Gomez-Rubio. 2013. *Applied Spatial Data Analysis with R*. 2nd ed. Springer, NY. <https://asdar-book.org/>.

</div>

<div id="ref-geoRglm2002" class="csl-entry">

Christensen, O. F., and P. J. Ribeiro Jr. 2002. “<span class="nocase">geoRglm</span>: A Package for Generalised Linear Spatial Models.” *R News* 2 (2): 26–28.

</div>

<div id="ref-Cressie1993" class="csl-entry">

Cressie, Noel A. C. 1993. *Statistics for Spatial Data*. Revised. London: John Wiley; Sons Inc.

</div>

<div id="ref-Diggle2013" class="csl-entry">

Diggle, Peter J. 2013. *Statistical Analysis of Spatial and Spatio-Temporal Point Patterns*. Third. Boca Raton, Florida: Chapman; Hall/CRC.

</div>

<div id="ref-Diggle2007" class="csl-entry">

Diggle, Peter J., and Paulo J. Ribeiro Jr. 2007. *Model-Based Geostatistics*. New York, NY: Springer-Verlag. <https://doi.org/10.1007%2F978-0-387-48536-2>.

</div>

<div id="ref-PrevMap2017" class="csl-entry">

Giorgi, Emanuele, and Peter J. Diggle. 2017. “PrevMap: An R Package for Prevalence Mapping.” *Journal of Statistical Software* 78 (8): 1–29.

</div>

<div id="ref-Pebesma2004" class="csl-entry">

Pebesma, Edzer J. 2004. “Multivariable Geostatistics in S: The <span class="nocase">gstat</span> Package.” *Computers & Geosciences* 30: 683–91.

</div>

<div id="ref-Pebesma2018" class="csl-entry">

———. 2018. “<span class="nocase">Simple Features for R: Standardized Support for Spatial Vector Data</span>.” *The R Journal* 10 (1): 439–46. <https://doi.org/10.32614/RJ-2018-009>.

</div>

<div id="ref-Pebesma2005" class="csl-entry">

Pebesma, Edzer J., and Roger S. Bivand. 2005. “Classes and Methods for Spatial Data in R.” *R News* 5 (2): 9–13. <https://CRAN.R-project.org/doc/Rnews/>.

</div>

<div id="ref-Sarkar2008" class="csl-entry">

Sarkar, Deepayan. 2008. *<span class="nocase">lattice</span>: Multivariate Data Visualization with R*. New York: Springer-Verlag. <http://lmdvr.r-forge.r-project.org>.

</div>

<div id="ref-Xie2017" class="csl-entry">

Xie, Yihui, Alison Presmanes Hill, and Amber Thomas. 2017. *<span class="nocase">blogdown</span>: Creating Websites with R Markdown*. Boca Raton, Florida: Chapman; Hall/CRC. <https://bookdown.org/yihui/blogdown/>.

</div>

</div>
