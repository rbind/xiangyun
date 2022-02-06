---
title: 空间数据分析与 R 语言
author: 黄湘云
date: '2022-04-10'
slug: spatial-data-analysis
categories:
  - 统计模型
tags:
  - 空间随机过程
  - 地统计学
  - 克里金插值
  - sp
  - gstat
toc: true
draft: true
# thumbnail: /img/terra.png
link-citations: true
bibliography: 
  - refer.bib
  - packages.bib
description: "空间数据分析，空间点数据分析，地统计学"
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

在地统计分析方面，比较流行的 R 包有 **gstat** ([Pebesma 2004](#ref-Pebesma2004)) 包，**geoR** 包， **geoRglm** 包([Christensen and Ribeiro Jr. 2002](#ref-geoRglm2002))和 **PrevMap** 包([Giorgi and Diggle 2017](#ref-PrevMap2017))等，而点过程分析方面，**splance** 包和 **spatstat** 包 ([Baddeley and Turner 2005](#ref-Baddeley2005))。

空间和时空点模式分析《Statistical Analysis of Spatial and Spatio-Temporal Point Patterns》([Diggle 2013](#ref-Diggle2013))

本文以 **sp** 包 ([Pebesma and Bivand 2005](#ref-Pebesma2005)) 内置的 meuse 数据集为例介绍空间数据分析、建模的过程。主要使用的 R 包有 **sp** 包 和 **gstat** 包，继续围绕 sp 空间数据进行介绍，一方面 sp 的生态非常成熟，完全迁移到 **sf** 包 ([Pebesma 2018](#ref-Pebesma2018)) 为核心的生态尚需要时日；另一方面，笔者也在摸索学习过程中，以空间统计为重，以后可以再将本文的代码升级到 **sf** 为核心的生态。

本文主要的参考材料来自[**sp**](https://github.com/edzer/sp/)包 的[帮助文档](https://edzer.github.io/sp/) 和 [**gstat**](https://github.com/r-spatial/gstat/) 包的[帮助文档](https://edzer.github.io/sp/)，
以及三本参考书籍《Model-based Geostatistics》([Diggle and Ribeiro Jr. 2007](#ref-Diggle2007)) 和《Applied spatial data analysis with R》([Bivand, Pebesma, and Gomez-Rubio 2013](#ref-Bivand2013))，
最后一本是《lattice: Multivariate Data Visualization with R》([Sarkar 2008](#ref-Sarkar2008))，供绘制图形时，充当查询手册。

# 案例：地表土壤重金属浓度数据

## 数据描述

meuse 数据集中，x 和 y 坐标的参考系

-   x Easting (m) in Rijksdriehoek (RDH) (Netherlands topographical) map coordinates
-   y Northing (m) in RDH coordinates

meuse 数据集为例

``` r
library(sp)
data("meuse")
summary(meuse)
#        x                y             cadmium          copper     
#  Min.   :178605   Min.   :329714   Min.   : 0.20   Min.   : 14.0  
#  1st Qu.:179371   1st Qu.:330762   1st Qu.: 0.80   1st Qu.: 23.0  
#  Median :179991   Median :331633   Median : 2.10   Median : 31.0  
#  Mean   :180005   Mean   :331635   Mean   : 3.25   Mean   : 40.3  
#  3rd Qu.:180630   3rd Qu.:332463   3rd Qu.: 3.85   3rd Qu.: 49.5  
#  Max.   :181390   Max.   :333611   Max.   :18.10   Max.   :128.0  
#                                                                   
#       lead            zinc           elev            dist       
#  Min.   : 37.0   Min.   : 113   Min.   : 5.18   Min.   :0.0000  
#  1st Qu.: 72.5   1st Qu.: 198   1st Qu.: 7.55   1st Qu.:0.0757  
#  Median :123.0   Median : 326   Median : 8.18   Median :0.2118  
#  Mean   :153.4   Mean   : 470   Mean   : 8.16   Mean   :0.2400  
#  3rd Qu.:207.0   3rd Qu.: 674   3rd Qu.: 8.96   3rd Qu.:0.3641  
#  Max.   :654.0   Max.   :1839   Max.   :10.52   Max.   :0.8804  
#                                                                 
#        om        ffreq  soil   lime       landuse       dist.m    
#  Min.   : 1.00   1:84   1:97   0:111   W      :50   Min.   :  10  
#  1st Qu.: 5.30   2:48   2:46   1: 44   Ah     :39   1st Qu.:  80  
#  Median : 6.90   3:23   3:12           Am     :22   Median : 270  
#  Mean   : 7.48                         Fw     :10   Mean   : 290  
#  3rd Qu.: 9.00                         Ab     : 8   3rd Qu.: 450  
#  Max.   :17.00                         (Other):25   Max.   :1000  
#  NA's   :2                             NA's   : 1
```

Ruud van Rijn 和 Mathieu Rikken 最初收集了 Stein 村 Meuse 河洪泛区地表土壤重金属浓度数据，Edzer Pebesma 将数据整理打包后做成 **sp** 内置的数据集 meuse。除了几种重金属浓度，还包含土壤、周围环境相关的变量，共 155 个采样点，14 个观测变量，具体情况：

-   x 东西方向坐标，单位米，坐标参照系为 RDH（Rijksdriehoek） 荷兰地形。
-   y 南北方向坐标，单位米。
-   cadmium 表土**镉**浓度，每千克土壤中镉含量（按毫克计），因此，浓度单位为 ppm，若原始数据中镉浓度为 0，则漂移至 0.2，即最小的镉浓度的一半。
-   copper 表土**铜**浓度，单位 ppm。
-   lead 表土**铅**浓度，单位 ppm。
-   zinc 表土**锌**浓度，单位 ppm。
-   elev 以当地河床为水平面，相对高度，单位米。
-   dist 采样点至 Meuse 河的距离，距离归一化到 0-1 区间。
-   om 每100千克土壤中有机质的占比，百分数。
-   ffreq 洪水等级，1 表示两年一次，2 表示十年一次，3 表示 五十年一次。
-   soil 土壤类型，按照荷兰 1:50000 的土壤图划分，1 表示 Rd10A （钙质弱发育草甸土，轻质砂质粘土），2 表示 Rd90C/VII （非钙质弱发育草甸土，重砂质粘土至轻质粘土），3 表示 Bkd26/VII
    （红砖土、细砂质、粉质轻质粘土）。
-   landuse 土地利用类别：Aa 农业/未指定 = ，Ab = Agr/糖用甜菜，Ag = Agr/小谷物，Ah = Agr/??，Am = Agr/玉米，B = 树林，Bw = 牧场中的树木，DEN = ?? , Fh = 高果树，Fl = 矮果树； Fw = 牧场果树，Ga = 家庭花园，SPO = 运动场，STA = 马厩，Tv = ?? , W = 牧场。
-   dist.m 采样点到 Meuse 河的距离，单位以米计，数据来自实地调查。

最后，数据集 meuse 中的行名 `row.names` 表示原始的采样点的编号。

## 准备数据

meuse 指定坐标系，meuse 转化为 SpatialPointsDataFrame 类型

``` r
crs <- CRS("+proj=lcc +lat_1=49 +lat_2=77 +lat_0=0 +lon_0=-95 +x_0=0 +y_0=0 +ellps=GRS80 +datum=WGS84 +units=m +no_defs")
coordinates(meuse) <- ~ x + y
proj4string(meuse) <- crs
```

``` r
class(meuse)
# [1] "SpatialPointsDataFrame"
# attr(,"package")
# [1] "sp"
```

将普通的数据框 data.frame 转化为空间点数据框 SpatialPointsDataFrame， sp 包不仅提供了数据类型的转化方法，而且对这种新的数据类型提供相应的绘图方法，使用方法和普通的 `plot()` 函数一样，这也是 S3 泛型函数的特色。

``` r
plot(meuse)
```

<figure>
<img src="/img/maps-in-r/sp-meuse.png" class="full" alt="Figure 1: sp 包绘图空间点数据" /><figcaption aria-hidden="true">Figure 1: <strong>sp</strong> 包绘图空间点数据</figcaption>
</figure>

``` r
data("meuse.grid")
coordinates(meuse.grid) <- ~ x + y
proj4string(meuse.grid) <- crs
class(meuse.grid)
# [1] "SpatialPointsDataFrame"
# attr(,"package")
# [1] "sp"
```

meuse.grid 是 SpatialPointsDataFrame 类型

``` r
plot(meuse.grid)
```

``` r
# gridded 构造 Pixels
gridded(meuse.grid) <- TRUE
class(meuse.grid)
# [1] "SpatialPixelsDataFrame"
# attr(,"package")
# [1] "sp"
```

meuse.grid 是 SpatialPixelsDataFrame 类型

``` r
plot(meuse.grid)
```

查看数据

``` r
spplot(meuse.grid, "dist")
```

``` r
data("meuse.riv")
meuse.riv <- SpatialPolygons(list(Polygons(list(Polygon(meuse.riv)), "meuse.riv")))
proj4string(meuse.riv) <- crs
```

meuse.riv 是 SpatialPolygons 类型，一条河流

``` r
plot(meuse.riv)
```

## 模型计算

zinc 的浓度取对数，然后做普通克里金插值，

``` r
library(gstat) # 实现克里金插值方法
# 公式形式 函数 variogram 要求 meuse 是 sp 类型
v.ok <- gstat::variogram(log(zinc) ~ 1, data = meuse)
# 变差模型为指数型
ok.model <- gstat::fit.variogram(v.ok, gstat::vgm(1, "Exp", 500, 1))
# 绘制
plot(v.ok, ok.model, main = "ordinary kriging")

zn.ok <- gstat::krige(log(zinc) ~ 1, meuse, meuse.grid,
  model = ok.model, debug.level = 0
)
```

## 模型结果

锌浓度（取对数）预测值及其预测误差的空间分布

``` r
# 需要弄清楚各个参数的含义
rv <- list("sp.polygons", meuse.riv, fill = "blue", alpha = 0.1)
pts <- list("sp.points", meuse, pch = 3, col = "grey", alpha = .5)
text1 <- list("sp.text", c(180500, 329900), "0", cex = .5, which = 4)
text2 <- list("sp.text", c(181000, 329900), "500 m", cex = .5, which = 4)
scale <- list("SpatialPolygonsRescale", layout.scale.bar(),
  offset = c(180500, 329800), scale = 500,
  fill = c("transparent", "black"), which = 4
)
# 预测值
p1 <- spplot(zn.ok, c("var1.pred"),
  names.attr = c("ordinary kriging"),
  scales = list(
    draw = TRUE, # 坐标轴刻度
    # 去掉图形上边、右边多余的刻度线
    x = list(alternating = 1, tck = c(1, 0)),
    y = list(alternating = 1, tck = c(1, 0))
  ),
  as.table = TRUE, main = "预测值的空间分布",
  sp.layout = list(rv, scale, text1, text2)
)
# 预测误差
p2 <- spplot(zn.ok, c("var1.var"),
  names.attr = c("ordinary kriging"),
  scales = list(
    draw = TRUE, # 坐标轴刻度
    # 去掉图形上边、右边多余的刻度线
    x = list(alternating = 1, tck = c(1, 0)),
    y = list(alternating = 1, tck = c(1, 0))
  ),
  as.table = TRUE, main = "预测误差的空间分布",
  sp.layout = list(rv, scale, text1, text2)
)

print(p1, split = c(1, 1, 2, 1), more = TRUE)
print(p2, split = c(2, 1, 2, 1), more = FALSE)
```

# 环境信息

在 RStudio IDE 内编辑本文的 R Markdown 源文件，用 **blogdown** ([Xie, Hill, and Thomas 2017](#ref-Xie2017)) 构建网站，[Hugo](https://github.com/gohugoio/hugo) 渲染 **knitr** 之后的 Markdown 文件，得益于 **blogdown** 对 R Markdown 格式的支持，图、表和参考文献的交叉引用非常方便，省了不少文字编辑功夫。文中使用了多个 R 包，为方便复现本文内容，下面列出详细的环境信息：

``` r
xfun::session_info(packages = c(
  "knitr", "rmarkdown", "blogdown",
  "sp", "gstat", "lattice"
), dependencies = FALSE)
# R version 4.1.2 (2021-11-01)
# Platform: x86_64-apple-darwin17.0 (64-bit)
# Running under: macOS Big Sur 10.16
# 
# Locale: en_US.UTF-8 / en_US.UTF-8 / en_US.UTF-8 / C / en_US.UTF-8 / en_US.UTF-8
# 
# Package version:
#   blogdown_1.7    gstat_2.0.8     knitr_1.37      lattice_0.20-45
#   rmarkdown_2.11  sp_1.4-6       
# 
# Pandoc version: 2.16.2
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
