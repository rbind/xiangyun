---
title: 如何用 R 语言绘制中国地图
author: 黄湘云
date: '2022-02-09'
slug: draw-china-maps
categories:
  - 统计图形
tags:
  - 数据可视化
  - 空间数据
  - ggplot2
  - leaflet
  - leafletCN
  - lattice
  - sf
  - terra
  - sp
  - raster
toc: true
link-citations: true
bibliography: 
  - refer.bib
  - packages.bib
description: "本文介绍如何使用 R 语言绘制中国地图，以及绘制过程中需要注意的制图规范问题。地理信息是比较敏感的数据，从大的层面上来说，涉及国家安全、主权和领土完整。笔者合著的书籍《现代统计图形》曾因此将所有地图相关的部分摘除，本文也意图去梳理和填补这方面的坑点。"
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

# 中国地图数据

R 语言社区有不少 R 包涉及中国地图数据，但是质量不一，比如 **maps** ([Brownrigg 2021](#ref-maps))和 **mapdata** 包([Richard A. Becker and Ray Brownrigg. 2018](#ref-mapdata))内置的中国地图，精度不够也不完整，下面再简单说下几个主要的数据源。

## 矢量数据

[**rnaturalearth**](https://github.com/ropenscilabs/rnaturalearth) ([South 2017](#ref-rnaturalearth))和 [**rnaturalearthdata**](https://github.com/ropenscilabs/rnaturalearthdata) 提供 [美国国家地理](https://www.naturalearthdata.com/) 网站的 R 语言接口，可以免费下载矢量和栅格地图数据。精度稍高一点的地图数据需要下载**rnaturalearthhires** 包，它有 20 多 M，不在 CRAN 上，安装命令如下：

``` r
install.packages(
  pkgs = "rnaturalearthhires",
  repos = "http://packages.ropensci.org",
  type = "source"
)
```

``` r
## 加载 R 包
library(rnaturalearth)
library(rnaturalearthdata)
library(rnaturalearthhires)
```

下载数据，调用 **sp** 包([Pebesma and Bivand 2005](#ref-Pebesma2005))绘制中国地图数据，如图<a href="#fig:china-map">1</a>。

``` r
# 中国大陆地区
chn_map <- rnaturalearth::ne_countries(
  country = "China",
  continent = "Asia",
  type = "countries",
  scale = 10, returnclass = "sp"
)
# 台湾地区
twn_map <- rnaturalearth::ne_countries(
  country = "Taiwan",
  continent = "Asia",
  type = "countries",
  scale = 10, returnclass = "sp"
)
# 绘图
sp::plot(chn_map)
# 追加
sp::plot(twn_map, add = TRUE)
```

<figure>
<img src="/img/maps-in-r/china-map.png" class="full" alt="Figure 1: 美国国家地理网站提供的中国地图数据" /><figcaption aria-hidden="true">Figure 1: 美国国家地理网站提供的中国地图数据</figcaption>
</figure>

这个地图数据有些明显的问题，将台湾地区的数据和中国分离开，南海诸岛的数据缺失很多，关于地图，这是一点都不能少的！笔者在美国国家地理网站的[声明](https://www.naturalearthdata.com/downloads/50m-cultural-vectors/50m-admin-0-countries-2/)里了解到，地区边界是根据实际控制划分的。

## 栅格数据

下面再看看网站提供的栅格数据，以海拔数据为例，采用 **raster** 包([Hijmans 2022a](#ref-raster))下载数据，**terra** 包([Hijmans 2022b](#ref-terra))来绘制地图。

``` r
# 创建目录存储地形文件
xfun::dir_create("~/data/") 
# 从 raster::getData('ISO3') 可以知道各个国家或地区的 ISO3 代码
# 下载数据 
# 中国大陆地区
chn_map <- raster::getData(name = "alt", country = "CHN", mask = TRUE, path = "~/data/")
# 台湾地区
twn_map <- raster::getData(name = "alt", country = "TWN", mask = TRUE, path = "~/data/")
# 香港地区
hkg_map <- raster::getData(name = "alt", country = "HKG", mask = TRUE, path = "~/data/")
# 澳门地区
mac_map <- raster::getData(name = "alt", country = "MAC", mask = TRUE, path = "~/data/")

# 若已经下载到本地，可直接读取
chn_map <- raster::raster(x = "~/data/CHN_msk_alt.grd")
twn_map <- raster::raster(x = "~/data/TWN_msk_alt.grd")
hkg_map <- raster::raster(x = "~/data/HKG_msk_alt.grd")
mac_map <- raster::raster(x = "~/data/MAC_msk_alt.grd")
# 合并 Raster 数据
china_map = terra::merge(chn_map, twn_map, hkg_map, mac_map)
# 查看数据类型
class(china_map)
# 调 terra 包绘图速度快
terra::plot(china_map, col = terrain.colors(20, rev = F))
```

<figure>
<img src="/img/maps-in-r/china-elevation.png" class="full" alt="Figure 2: 中国地图海拔数据" /><figcaption aria-hidden="true">Figure 2: 中国地图海拔数据</figcaption>
</figure>

## 交互地图

本节主要采用 **leaflet** 包([Cheng, Karambelkar, and Xie 2021](#ref-leaflet))绘制交互地图，**leafletCN**([Lang 2017](#ref-leafletCN)) 包内置一部分中国省、市边界地图数据，支持调用高德瓦片地图服务，提供部分合规的中国地图，核心函数是 `geojsonMap()`，它封装了 GeoJSON 格式的地图数据和绘图功能，更多定制参考`leaflet::leaflet()`。只要数据包含的一列区域名称和地图数据能映射上，就可以绘制出图<a href="#fig:china-leafletcn">3</a>，图中数据是随机生成的，调色板采用 `RdBu`，将连续的数据分段，每段对应一个色块。

``` r
library(leaflet)
library(leafletCN) # 提供 geojsonMap 函数
dat <- data.frame(name = regionNames("china"), value = runif(34))
# 还有很多其他参数设置，类似 leaflet::leaflet
geojsonMap(dat, mapName = "china", palette = "RdBu", colorMethod = "bin")
```

<figure>
<img src="/img/maps-in-r/china-leafletcn.png" class="full" alt="Figure 3: 交互地图数据可视化" /><figcaption aria-hidden="true">Figure 3: 交互地图数据可视化</figcaption>
</figure>

绘制某个省份、直辖市、地级市的数据，图<a href="#fig:china-beijing">4</a>和图<a href="#fig:china-shaoyang">5</a>分别展示北京市、邵阳市下各个区县的数据。不难发现，**leafletCN** 包内置的地图边界和名称等数据尚未更新，下图<a href="#fig:china-beijing">4</a>还是崇文、宣武区，实际它们已经合并至东、西城区，图<a href="#fig:china-shaoyang">5</a>还是邵东县，实际已经升级为邵东市，是由邵阳市代管的县级市。

``` r
dat <- data.frame(name = regionNames("北京"), value = runif(18))
geojsonMap(dat, mapName = "北京", palette = "RdBu", colorMethod = "bin")
```

<figure>
<img src="/img/maps-in-r/china-beijing.png" class="full" alt="Figure 4: 北京地区" /><figcaption aria-hidden="true">Figure 4: 北京地区</figcaption>
</figure>

``` r
dat <- data.frame(name = regionNames("邵阳"), value = runif(12))
geojsonMap(dat, mapName = "邵阳", palette = "RdBu", colorMethod = "bin")
```

<figure>
<img src="/img/maps-in-r/china-shaoyang.png" class="full" alt="Figure 5: 邵阳地区" /><figcaption aria-hidden="true">Figure 5: 邵阳地区</figcaption>
</figure>

可见，市和区县级地图边界数据是存在问题的，省级边界地图数据配合高德提供的背景地图数据是基本可用。一个更可靠的方式是不要使用此边界数据，只使用高德地图，以气泡图代替，类似图<a href="#fig:bubble-map">6</a>，要点是需要准备各个区县级以上城市的经纬度坐标，并且和高德地图采用的坐标系是一致的，这样气泡的位置和地图上显示的城市名称是基本重合的。

<figure>
<img src="/img/maps-in-r/bubble-map.png" class="full" alt="Figure 6: 部分区县级城市的气泡散点图" /><figcaption aria-hidden="true">Figure 6: 部分区县级城市的气泡散点图</figcaption>
</figure>

另一个解决办法的使用[阿里 DataV 数据可视化平台](https://datav.aliyun.com/portal/school/atlas/area_selector)开放出来的地图数据，它来自[高德开放平台](https://lbs.amap.com/api/webservice/guide/api/district)。下载到本地保存为文件`邵阳市.json`，检查后，发现地图数据的参考系是 WGS 84，这和 OpenStreetMap 所要求的坐标系正好一致，下面就采用 **leaflet** 包来绘制。以邵阳市地区的数据为例，从[邵阳市统计局](https://www.shaoyang.gov.cn/sytjj/tjsj/rlist.shtml)发布的统计年鉴获取2010年、2015年和2020年邵阳市各个区县的人口数（单位：万人）。邵阳市各个区县近5年和近10年的人口增长率，如图<a href="#fig:shaoyang-pop">7</a>所示，邵东市近5年的人口呈**负增长**，笔者在图上还补充了很多数据信息，供读者参考。如果能够收集到全国所有区县级城市的人口数据，还可以发现中国各个经济带的地域差异，沿海内陆差异，南北差异等一系列有用的信息，进一步洞悉人口流动的方向。

``` r
library(leaflet)
library(sf)
# 读取 GeoJSON 格式的多边形矢量地图数据
shaoyang_map <- sf::read_sf("data/邵阳市.json") 
# 添加 2020年、2015年和2010年邵阳市各个区县的人口数（单位：万人）
shaoyang_data <- tibble::tribble(
  ~adcode, ~name2, ~pop20, ~pop10, ~pop15,
  430502, "双清区", 26.76, 27.97, 27.82,
  430503, "大祥区", 32.05, 32.16, 32.52,
  430511, "北塔区", 10.21, 9.06, 9.72,
  430522, "新邵县", 82.04, 80.4, 82.81,
  430523, "邵阳县", 105.82, 103.62, 104.82,
  430524, "隆回县", 129.41, 120.31, 126.29,
  430525, "洞口县", 89.53, 84.66,88.1,
  430527, "绥宁县", 38.29, 37.55, 38.39,
  430528, "新宁县", 64.52, 61.67, 64.97,
  430529, "城步苗族自治县", 27.95, 27.32, 27.6,
  430581, "武冈市", 82.69, 81.12, 84.13,
  430582, "邵东市", 133.06, 128.13, 133.59
)
# 近 5 年人口增长率
shaoyang_data <- transform(shaoyang_data, pop = (pop20 - pop15) / pop15)
# sf 转化为数据框
shaoyang_map <- as.data.frame(shaoyang_map)
# 观测数据和地图数据按行政区划编码合并
shaoyang <- merge(shaoyang_map, shaoyang_data, by = "adcode")
# 数据框转化为 sf 
shaoyang <- sf::st_as_sf(shaoyang, sf_column_name = "geometry")
# 可以设置分段离散的调色板
# pal <- colorBin("Spectral", bins = pretty(shaoyang$pop), reverse = TRUE)
pal <- colorNumeric("Spectral", domain = NULL)
# 将数据绘制到地图上
leaflet(shaoyang) |>
  addTiles(
    urlTemplate = "http://webrd02.is.autonavi.com/appmaptile?lang=zh_cn&size=1&scale=1&style=8&x={x}&y={y}&z={z}", # 来自 leafletCN::amap()
    options = tileOptions(tileSize = 256, minZoom = 3, maxZoom = 17),
    attribution = "&copy; <a href=\"http://amap.com\">amp.com</a >"
  ) |>
  addPolygons(
    stroke = F, # 不显示各个区县的边界线
    weight = 1, # 设置边界线宽度
    fillOpacity = 0.7, # 填充多边形的透明度
    fillColor = ~ pal(pop),
    label = lapply(paste0(
      "城市：", "<b>", shaoyang$name, "</b>", "<br/>",
      "5年人口增长率：", sprintf("%.3f%%", 100 * (shaoyang$pop20 - shaoyang$pop15) / shaoyang$pop15), "<br/>",
      "10年人口增长率：", sprintf("%.3f%%", 100 * (shaoyang$pop20 - shaoyang$pop10) / shaoyang$pop10)
    ), htmltools::HTML),
    popup = ~ paste0(
      "城市：", name, "<br/>",
      "<hr/>",
      "2020年人口：", pop20, "（万）", "<br/>",
      "2015年人口：", pop15, "（万）", "<br/>",
      "2010年人口：", pop10, "（万）", "<br/>",
      "10年人口增长率：", sprintf("%.2f%%", 100 * (pop20 - pop10) / pop10), "<br/>",
      "10年间平均每年增加人口：", format((pop20 - pop10) / 10, digit = 4), "（万）", "<br/>"
    )
  ) |>
  addLegend(
    position = "bottomright", title = "5年人口增长率",
    pal = pal, values = ~pop, opacity = 1.0,
    labFormat = labelFormat(
      suffix = "%",
      transform = function(x) round(100 * x, digits = 2)
    )
  ) |>
  addScaleBar(position = "bottomleft")
```

<figure>
<img src="/img/maps-in-r/shaoyang-pop.png" class="full" alt="Figure 7: 邵阳市各个区县人口增长率" /><figcaption aria-hidden="true">Figure 7: 邵阳市各个区县人口增长率</figcaption>
</figure>

另一个提供地图数据的是商业软件 [Highcharts Maps](https://www.highcharts.com/)，国内外有不少商业公司是它的客户，它也有一个 R 包[**highcharter**](https://github.com/jbkunst/highcharter)，
有一个以美国地图数据为背景的博客详细介绍了使用过程，详见 [Highcharts 官方博客](https://www.highcharts.com/blog/tutorials/using-highcharter-in-tidytuesday-internet-access/)。[简数科技](https://www.highcharts.com.cn/) 定制了一份 GeoJSON 格式的中国地图数据，还提供了地图预览和下载的服务，因为涉及商业版权和地图数据合规性，使用需要注意，读者可前往[网站](https://www.highcharts.com.cn/mapdata)了解。另一个 R 包[**hchinamap**](https://github.com/czxa/hchinamap) 也是使用这份中国地图数据和 JavaScript 库 [Highcharts JS](https://github.com/highcharts/highcharts)。

``` r
library(hchinamap)
# name 是地图数据中的各个区域单元的名称
hchinamap(
  name = c("北京", "天津", "上海", "湖南", "台湾", "海南"),
  value = c(120, 200, 126, 300, 150, 225),
  width = "100%",
  height = "650px",
  title = "分省地图",
  region = "China",
  minColor = "#f1eef6",
  maxColor = "#980043",
  itermName = "指标",
  hoverColor = "#f6acf5"
)
```

<figure>
<img src="/img/maps-in-r/china-hchinamap.png" class="full" alt="Figure 8: 中国地图数据" /><figcaption aria-hidden="true">Figure 8: 中国地图数据</figcaption>
</figure>

## 静态地图

[中华人民共和国民政部](http://xzqh.mca.gov.cn)提供了中国地图数据，是 GeoJSON 格式的，属于权威数据源，推荐使用。

``` r
library(sf)
china_map = st_read(dsn = "http://xzqh.mca.gov.cn/data/quanguo_Line.geojson", stringsAsFactors = FALSE)
```

    Reading layer `线' from data source 
      `http://xzqh.mca.gov.cn/data/quanguo_Line.geojson' using driver `GeoJSON'
    Simple feature collection with 104 features and 3 fields
    Geometry type: LINESTRING
    Dimension:     XY
    Bounding box:  xmin: 73.68 ymin: 3.554 xmax: 135.2 ymax: 53.65
    Geodetic CRS:  WGS 84

``` r
china_map
```

    Simple feature collection with 104 features and 3 fields
    Geometry type: LINESTRING
    Dimension:     XY
    Bounding box:  xmin: 73.68 ymin: 3.554 xmax: 135.2 ymax: 53.65
    Geodetic CRS:  WGS 84
    First 10 features:
         NAME  QUHUADAIMA strZTValue                       geometry
    1         hainansheng            LINESTRING (121.9 30.84, 12...
    2         hainansheng            LINESTRING (121.4 30.82, 12...
    3         hainansheng            LINESTRING (121.5 31.64, 12...
    4          tiaohuijie            LINESTRING (124.4 40.08, 12...
    5          tiaohuijie            LINESTRING (124.5 40.13, 12...
    6  台湾岛      daoyu6            LINESTRING (121.4 22.46, 12...
    7  海南岛      daoyu5            LINESTRING (111.5 19, 112.4...
    8  钓鱼岛      daoyu6            LINESTRING (122.8 26.07, 12...
    9  赤尾屿      daoyu6            LINESTRING (125.2 25.86, 12...
    10 黄岩岛      daoyu6            LINESTRING (117.2 14.61, 11...

``` r
plot(china_map)
```

<figure>
<img src="/img/maps-in-r/china-linestring.png" class="full" alt="Figure 9: 静态地图数据" /><figcaption aria-hidden="true">Figure 9: 静态地图数据</figcaption>
</figure>

另一份地图数据是全国各地的行政区域，只有省一级。

``` r
china_map = st_read(dsn = "http://xzqh.mca.gov.cn/data/quanguo.json", stringsAsFactors = FALSE)
# 原数据集没有坐标系信息，因此设置一下
st_crs(china_map) = 4326
plot(china_map["QUHUADAIMA"])
```

<figure>
<img src="/img/maps-in-r/china-province.png" class="full" alt="Figure 10: 静态地图数据" /><figcaption aria-hidden="true">Figure 10: 静态地图数据</figcaption>
</figure>

# 环境信息

本文的 R Markdown 源文件是在 RStudio IDE 内编辑的，用 **blogdown** ([Xie, Hill, and Thomas 2017](#ref-Xie2017)) 构建网站，[Hugo](https://github.com/gohugoio/hugo) 渲染 **knitr** 之后的 Markdown 文件，得益于 **blogdown** 对 R Markdown 格式的支持，图、表和参考文献的交叉引用非常方便，省了不少文字编辑功夫。文中使用了多个 R 包，为方便复现本文内容，下面列出详细的环境信息：

``` r
xfun::session_info(packages = c(
  "knitr", "rmarkdown", "blogdown",
  "ggplot2", "leaflet", "lattice",
  "sp", "raster", "sf", "terra"
), dependencies = FALSE)
# R version 4.1.1 (2021-08-10)
# Platform: x86_64-apple-darwin17.0 (64-bit)
# Running under: macOS Big Sur 10.16
# 
# Locale: en_US.UTF-8 / en_US.UTF-8 / en_US.UTF-8 / C / en_US.UTF-8 / en_US.UTF-8
# 
# Package version:
#   blogdown_1.7    ggplot2_3.3.5   knitr_1.37      lattice_0.20.45 leaflet_2.0.4.1
#   raster_3.5.15   rmarkdown_2.11  sf_1.0.6        sp_1.4.6        terra_1.5.17   
# 
# Pandoc version: 2.16.2
# 
# Hugo version: 0.91.2
```

# 参考文献

<div id="refs" class="references csl-bib-body hanging-indent">

<div id="ref-maps" class="csl-entry">

Brownrigg, Ray. 2021. *Maps: Draw Geographical Maps*. <https://CRAN.R-project.org/package=maps>.

</div>

<div id="ref-leaflet" class="csl-entry">

Cheng, Joe, Bhaskar Karambelkar, and Yihui Xie. 2021. *Leaflet: Create Interactive Web Maps with the JavaScript Leaflet Library*. <https://rstudio.github.io/leaflet/>.

</div>

<div id="ref-raster" class="csl-entry">

Hijmans, Robert J. 2022a. *Raster: Geographic Data Analysis and Modeling*. <https://rspatial.org/raster>.

</div>

<div id="ref-terra" class="csl-entry">

———. 2022b. *Terra: Spatial Data Analysis*. <https://rspatial.org/terra/>.

</div>

<div id="ref-leafletCN" class="csl-entry">

Lang, Dawei. 2017. *leafletCN: An r Gallery for China and Other Geojson Choropleth Map in Leaflet*. <https://CRAN.R-project.org/package=leafletCN>.

</div>

<div id="ref-Pebesma2005" class="csl-entry">

Pebesma, Edzer J., and Roger S. Bivand. 2005. “Classes and Methods for Spatial Data in R.” *R News* 5 (2): 9–13. <https://CRAN.R-project.org/doc/Rnews/>.

</div>

<div id="ref-mapdata" class="csl-entry">

Richard A. Becker, Original S code by, and Allan R. Wilks. R version by Ray Brownrigg. 2018. *Mapdata: Extra Map Databases*. <https://CRAN.R-project.org/package=mapdata>.

</div>

<div id="ref-rnaturalearth" class="csl-entry">

South, Andy. 2017. *Rnaturalearth: World Map Data from Natural Earth*. <https://github.com/ropenscilabs/rnaturalearth>.

</div>

<div id="ref-Xie2017" class="csl-entry">

Xie, Yihui, Alison Presmanes Hill, and Amber Thomas. 2017. *<span class="nocase">blogdown</span>: Creating Websites with R Markdown*. Boca Raton, Florida: Chapman; Hall/CRC. <https://bookdown.org/yihui/blogdown/>.

</div>

</div>
