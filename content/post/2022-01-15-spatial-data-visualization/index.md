---
title: 空间数据可视化与 R 语言（中篇）
author: 黄湘云
date: '2022-02-22'
slug: spatial-data-visualization
categories:
  - 统计图形
tags:
  - 空间数据
  - 专题地图
  - 地图服务
  - 坐标系统
  - ggplot2
  - mapdeck
  - sf
  - leaflet
  - httr
toc: true
thumbnail: /img/maps-in-r/beijing-sf.png
link-citations: true
bibliography: 
  - refer.bib
  - packages.bib
description: "数据可视化在数据探索分析中扮演了及其重要的角色，帮助了解数据的质量、分布和潜在规律，为建模和分析提供思路和假设。同时，又有助于阐述分析结果，交流分享。但要注意使用场景，切记过于花哨，引入一些不必要的炫酷手段，比如各种 3D 图，蜂窝图等。"
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

# 本文概览

数据可视化在数据探索分析中扮演了极其重要的角色，帮助了解数据的质量、分布和潜在规律，为建模和分析提供思路和假设。同时，有助于阐述分析结果，交流分享。但要注意使用场景，切记过于花哨，引入一些不必要的炫酷手段，比如各种 3D 图，蜂窝图等。

本文告诉读者如何在 R 语言中调用生活中常见的谷歌、必应、百度和高德等地图服务。介绍一些网址地位、地理编码和坐标转化的 R 包，为空间数据操作、可视化奠定基础。然后，介绍展示空间数据分布的常用图形及其R包实现，再重点介绍专题地图，并以不同 R 包的不同风格实现。最后，以两个实例简要阐述空间数据操作、分析、可视化的过程。

# 地图服务

比较常见的地图服务，国外有谷歌、微软，国内有百度、高德，凡是提供本地生活服务的公司都或多或少地依赖高精地图，如美团外卖，阿里飞猪等。本节主要带领读者了解地图服务，以及使用 R 语言来调地图服务，为增加代入感，笔者就从「中国矿业大学（北京）学院路校区」这个地标的 IP 定位开始。首先用 [curl](https://curl.se/) 工具请求网站 <https://ipinfo.io/>[^1]，它会自动获取用户上网使用的 IP 以及 IP 所处的地理位置，如下：

``` bash
curl ipinfo.io
```

    {
      "ip": "223.71.83.98",
      "city": "Beijing",
      "region": "Beijing",
      "country": "CN",
      "loc": "39.9288,116.3890",
      "org": "AS56048 China Mobile Communicaitons Corporation"
    }

可知学校所处位置：纬度 39.9288 经度 116.3890，当然这离高精地图还有十万八千里。

## 百度地图

杜亚磊开发的[baidumap](https://github.com/badbye/baidumap)包可以调用[百度地图服务](https://map.baidu.com/)获取地理可视化的背景底图。百度是国内比较早的互联网公司，之前介绍的 Apache Echarts 也是百度可视化团队领头开发的，百度地理信息可视化平台使用的地理可视化组件来自开源的[mapv](https://github.com/huiyan-fe/mapv)。

在百度地图上，根据地理名称获得经纬度信息，获得经纬度后，可以将位置标记在地图上，下面以「中国矿业大学（北京）」为例。

``` r
remotes::install_github('badbye/baidumap')
```

`BaiduMap_API_Key` 是从[百度 LBS 云服务](https://lbsyun.baidu.com/)申请到的地图 API 访问令牌，保存到本地 `.Renviron` 文件里 `BaiduMap_API_Key=[key]`，这样启动 R 软件时就会自动载入。

``` r
library(baidumap)
options(baidumap.key = Sys.getenv("BaiduMap_API_Key"))
getCoordinate('中国矿业大学（北京）学院路校区', formatted = T)
#   longtitude     latitude 
# 116.35376693  40.00382807
```

如图<a href="#fig:cumtb-baidu">1</a>，在地图上显示解析出来的位置，可见定位在**矿大1号楼**。

``` r
cumtb_map <- getBaiduMap("中国矿业大学（北京）学院路校区", zoom = 17)
cumtb_coordinate <- getCoordinate("中国矿业大学（北京）学院路校区", formatted = T)
cumtb_coordinate <- data.frame(t(cumtb_coordinate))
# 调 ggmap 绘制背景地图
ggmap::ggmap(cumtb_map) +
  ggplot2::geom_point(aes(x = longtitude, y = latitude),
    data = cumtb_coordinate, col = "red", size = 5
  )
```

<figure>
<img src="img/cumtb-baidu.png" class="full" alt="图 1: 百度地图-中国矿业大学（北京）学院路校区" />
<figcaption aria-hidden="true">图 1: 百度地图-中国矿业大学（北京）学院路校区</figcaption>
</figure>

## 高德地图

高德和百度都是有甲级测绘资质的单位，意味着地图数据符合国家要求，来源权威可用。大家熟知的全球定位系统（GPS）采用 WGS 84，而 GCJ 02 由 WGS 84 加密后的坐标系，是由中国国家测绘局制定的地理坐标系统，又称火星坐标系。高德地图采用火星坐标系 GCJ 02（国测局 **G**uo **C**e **J**u，即国家测绘局），百度地图的坐标系 BD 09 在 GCJ 02 坐标系基础上再次加密，加密过程不可逆，是一种非线性加密方式，反向解密后的坐标在部分区域的定位差别很大。另外，值得注意的是对同一目标不同公司提供的定位可能是不同的，因为所选的地理参考系不同，常用的三种坐标系见文档[坐标系](https://lbsyun.baidu.com/index.php?title=coordinate)。

高德提供很多调用地图服务的 API 接口，如将其它坐标转化为高德坐标的[坐标转化服务](https://lbs.amap.com/api/webservice/guide/api/convert)，前提是先在[高德开放平台](https://lbs.amap.com/)上申请Web服务API类型KEY。继续以地标「中国矿业大学（北京）学院路校区」为例，下面在 R 语言环境中，使用 **httr** 包([Wickham 2022b](#ref-httr))调用高德地图服务将百度坐标转化为高德坐标。

``` r
library(httr)
# 向高德地图 API 发 GET 请求
tmp <- GET(
  url = "https://restapi.amap.com/",
  path = "v3/assistant/coordinate/convert",
  query = list(
    # 原坐标，经纬度小数点后不得超过6位
    locations = "40.003828,116.353766", 
    # 原坐标参考系，还支持 GPS 坐标，取值 'gps'
    coordsys = "baidu", 
    # 返回数据格式，还支持 xml
    output = "json", 
    # 高德地图 WEB 服务 API 访问令牌
    key = Sys.getenv("AMAP_KEY") 
  )
)
# 抽取转化后的高德坐标
content(tmp)$locations
# [1] "39.997202126977,116.347817690225"
```

接着，采用 **leaflet** 包将高德坐标系下的经纬度绘制在地图上。由于 **leaflet** 包默认采用 OpenStreetMap 开放街道地图服务，需要切换一下地图服务，而郎大为开发的 [**leafletCN**](https://github.com/Lchiffon/leafletCN) 包([Lang 2017](#ref-leafletCN)) 正好用函数 `amap()` 封装了高德瓦片地图服务。如图<a href="#fig:cumtb-amp">2</a>所示，定位在**矿大学10楼**，从百度地图转化过来，这有上百米的距离。一方面开放的高德地图 API 不支持转化高精度的经纬度坐标，另一方面转化是有损失的。

``` r
library(leaflet)
library(leafletCN)
# 绘图
leaflet(options = leafletOptions(
  minZoom = 4, maxZoom = 18, 
  zoomControl = FALSE
)) |> 
  amap() |> 
  setView(lng = 116.347817690225, lat = 39.997202126977, zoom = 18) |> 
  addCircles(
    data = data.frame(lon = 116.347817690225, lat = 39.997202126977, size = 10),
    lng = ~lon, lat = ~lat, radius = ~size, color = "red",
    fillOpacity = 0.55, stroke = T, weight = 1,
    label = htmltools::HTML("这里是 <b>学院路校区</b>, 中国矿业大学（北京）")
  )
```

<figure>
<img src="img/cumtb-amp.png" class="full" alt="图 2: 高德地图-中国矿业大学（北京）学院路校区" />
<figcaption aria-hidden="true">图 2: 高德地图-中国矿业大学（北京）学院路校区</figcaption>
</figure>

下面试试看，将原百度坐标不转化，直接绘制在高德地图上，如图<a href="#fig:cumtb-amp-baidu">3</a>所示，可见定位到**中国农业大学**去了，真是失之毫厘，差之千里！

``` r
# 绘图
leaflet(options = leafletOptions(
  minZoom = 4, maxZoom = 18, 
  zoomControl = FALSE
)) |> 
  amap() |> 
  setView(lng = 116.35376693, lat = 40.00382807, zoom = 18) |> 
  addCircles(
    data = data.frame(lon = 116.35376693, lat = 40.00382807, size = 10),
    lng = ~lon, lat = ~lat, radius = ~size, color = "red",
    fillOpacity = 0.55, stroke = T, weight = 1,
    label = htmltools::HTML("这里是 <b>学院路校区</b>, 中国矿业大学（北京）")
  )
```

<figure>
<img src="img/cumtb-amp-baidu.png" class="full" alt="图 3: 高德地图-中国矿业大学（北京）" />
<figcaption aria-hidden="true">图 3: 高德地图-中国矿业大学（北京）</figcaption>
</figure>

## 必应地图

与 **ggmap** 包相比，[**RgoogleMaps**](https://github.com/markusloecher/rgooglemaps)包 ([Loecher and Ropkins 2015](#ref-Loecher2015)) 支持调用更多的地图服务，除了 Google 地图外，还支持必应地图，以及基于 **lattice** 包的可视化，借助 [**loa**](https://r-forge.r-project.org/scm/?group_id=1400) ([Ropkins 2021](#ref-loa))和 [**latticeExtra**](https://r-forge.r-project.org/projects/latticeextra/) ([Sarkar and Andrews 2019](#ref-latticeExtra))还可以支持高级的自定义，如何使用见[**ggmap** 使用案例](https://github.com/vertica/Vertica-Geospatial)、[**loa** 文档](https://loa.r-forge.r-project.org/loa.intro.html)和[**latticeExtra** 文档](https://latticeextra.r-forge.r-project.org/)。

``` r
library(RgoogleMaps) # 同时需要 RCurl
library(RCurl)
```

使用 Bing 地图服务也是需要 `API_KEY` 的，可先去 [Bing 地图开发中心](https://www.bingmapsportal.com/) 用 Outlook 邮箱创建账户，然后申请免费的基础版，过程见[说明](https://www.microsoft.com/en-us/maps/create-a-bing-maps-key)。继续以地标「中国矿业大学（北京）学院路校区」为例，将百度坐标绘制在必应地图上，如图<a href="#fig:cumtb-bing">4</a>所示，也定位在**中国农业大学**校园内了，而且显示的兴趣点 POI 少很多了！

``` r
# 保存背景地图
map_cumtb <- GetBingMap(
  center = c(lat = 40.00382807, lon = 116.35376693),
  zoom = 17, apiKey = Sys.getenv("BingMap_API_KEY"),
  verbose = 0, destfile = "cumtb-bing.png"
)
# 将点绘制到地图上
PlotOnStaticMap(map_cumtb,
  lat = 40.00382807, lon = 116.35376693,
  col = "red", FUN = points,
  pch = 19, cex = 2
)
```

<figure>
<img src="img/cumtb-bing.png" class="full" alt="图 4: 必应地图-中国矿业大学（北京）学院路校区" />
<figcaption aria-hidden="true">图 4: 必应地图-中国矿业大学（北京）学院路校区</figcaption>
</figure>

## 谷歌地图

David Kahle 开发的[**ggmap**](https://github.com/dkahle/ggmap) ([Kahle and Wickham 2013](#ref-Kahle2013)) 包在 2011 年发布在 CRAN 上，是一个基于 ggplot2 的空间可视化包，背景地图来自谷歌地图。目前，由于 Google 地图服务策略调整，需要申请 Google 地图服务的访问令牌才可以使用地图服务。
可将申请到的 `GGMAP_GOOGLE_API_KEY` 保存到本地文件 `~/.Renviron`，以供 **ggmap** 后续使用。

``` r
library(ggmap)
p <- ggmap::get_googlemap(
  center = c(lon = 116.35376693, lat = 40.00382807),
  zoom = 12, size = c(640, 640), scale = 2
)
ggmap::ggmap(p)
```

Google 提供一种瓦片地图，即由一张张小图片拼凑起来形成一张完整的地图，就好像盖房用的瓦片，精度由瓦片的分辨率决定，如图 <a href="#fig:ggmap-tile">5</a> 所示。

<!-- 
http://tile.stamen.com/terrain-background/5/4/10.png 
-->

<figure>
<img src="img/google-tile.png" class="full" alt="图 5: ggmap 地形图" />
<figcaption aria-hidden="true">图 5: ggmap 地形图</figcaption>
</figure>

**ggmap** 也可以调用多种风格样式的地图，地形图、水彩图等，如图<a href="#fig:ggmap-tiles">6</a> 所示。

``` r
library(ggplot2)
library(ggmap)
library(patchwork)

us <- c(left = -125, bottom = 25.75, right = -67, top = 49)
# 从 tile server 服务器上下载 Stamen Maps 数据，组成一个图片
dat1 <- get_stamenmap(
  bbox = us, zoom = 5, maptype = "toner-lite"
  )
p1 <- ggmap(dat1)
# 地形图
dat2 <- get_stamenmap(
  bbox = us, zoom = 5, maptype = "terrain"
)
p2 <- ggmap(dat2)

dat3 <- get_stamenmap(
  bbox = us, zoom = 5, maptype = "watercolor"
)
p3 <- ggmap(dat3)

dat4 <- get_stamenmap(
  bbox = us, zoom = 5, maptype = "terrain-background"
)
p4 <- ggmap(dat4)

p1 / p2 | p3 / p4
```

<figure>
<img src="img/ggmap-tiles.png" class="full" alt="图 6: ggmap 几种常用背景地图" />
<figcaption aria-hidden="true">图 6: ggmap 几种常用背景地图</figcaption>
</figure>

# 基础知识

与地图相关的基础知识有很多，一个简易版本可参考[高德教程](https://lbs.amap.com/api/jsapi-v2/guide/abc/components)。

## 网址定位

Os Keyes 开发的 R 包 [**rgeolocate**](https://github.com/ironholds/rgeolocate) ([Keyes et al. 2021](#ref-rgeolocate)) 可以解析 IP 地址，根据 IP 地址数据库提取位置信息，其内置 `GeoLite2-Country.mmdb` 数据支持定位到国家，是一个 [MaxMind](https://github.com/maxmind) 的 GeoIP2 数据库文件。

``` r
library(rgeolocate)
# IP 地址 111.203.130.69 在中国矿业大学（北京）校区内。
maxmind(
  ips = "111.203.130.69",
  file = system.file("extdata", "GeoLite2-Country.mmdb", package = "rgeolocate"),
  fields = c(
    "continent_name", "country_code", "country_name",
    "region_name", "city_name", "city_geoname_id",
    "timezone", "longitude", "latitude"
  )
)
#   continent_name country_code country_name region_name city_name city_geoname_id
# 1           Asia           CN        China        <NA>      <NA>              NA
#   timezone longitude latitude
# 1     <NA>        NA       NA
```

依次是洲、国家编码简称、国家名称、区域（省级）名称、城市名称、城市代码（不确定编码体系，类似国家行政区划编码）、时区、经度和纬度。内置的数据库定位精度有限，可以去[MaxMind 官网](https://dev.maxmind.com/geoip/geolite2-free-geolocation-data)下载免费的可以定位到城市的数据库。**rgeolocate** 包还提供连接其它 IP 定位服务的接口，比如前面提及的 <https://ipinfo.io/>。

``` r
ip_info('111.203.130.69')
#      city  region country              loc                                          org
# 1 Beijing Beijing      CN 39.9075,116.3972 AS4808 China Unicom Beijing Province Network
#        timezone hostname postal phone
# 1 Asia/Shanghai       NA     NA    NA
```

依次将城市、省份、国家、经纬度、网络服务提供商和时区都提供了。除了 **rgeolocate** 包，还可以使用 **httr** 包向 **ipinfo.io** 发 GET 请求，获取定位信息。

``` r
library(httr)
ip_geocode <- GET(url = "ipinfo.io")
content(ip_geocode)$loc
# [1] "39.9075,116.3972"
```

或者调用高德地图 IP 定位服务，定位到省、市，并返回一个两个坐标表示的矩形区域。

``` r
# 向高德地图 API 发 GET 请求
library(httr)
tmp <- GET(
    url = "https://restapi.amap.com/",
    path = "v3/ip",
    query = list(
      ip = "111.203.130.69", # IP 地址
      output = "json",       # 返回数据格式
      # 高德地图 WEB 服务 API 访问令牌
      key = Sys.getenv("AMAP_KEY")
    )
  )
# 查看全部返回信息
# content(tmp)
# 抽取位置区域
content(tmp)$rectangle
# [1] "116.0119343,39.66127144;116.7829835,40.2164962"
```

## 瓦片地图

使用高德[静态地图](https://lbs.amap.com/api/webservice/guide/api/staticmaps)遵守[自定义地图服务协议](https://lbs.amap.com/pages/customize-map-terms/)，
应国家要求，国内的地图服务厂商必须是 GCJ-02 或 BD-09 坐标系统，用户必须拿着这两个坐标系下的空间数据，调用各大 Web 地图服务制图，比如地图瓦片，它们采用 Web 墨卡托投影，坐标参考系是 EPSG:3857 或某种再次转化加密过的 Web 墨卡托投影。

继续以地标「中国矿业大学（北京）学院路校区」为例，之前已经获得它的定位 `116.347817,39.997202`，调用高德静态地图服务，返回一个静态图片地址。

``` r
library(httr)
GET(
  url = "https://restapi.amap.com/",
  path = "v3/staticmap",
  query = list(
    location = "116.347817,39.997202", # 图的中心位置
    zoom = 16, # 缩放水平
    size = "600*400", # 图片长宽
    scale = 2, # 返回高清图
    labels = sprintf("%s,%s,%s,%s,%s,%s:%s",
      content = "矿大北京", # 标签内容
      font = 0, # 微软雅黑
      bold = 1, # 粗体
      fontSize = 24, # 字体大小
      fontColor = "0xFF0000",  # 字体颜色：红色
      background = "0xFFFFFF", # 字体背景：白色
      location = "116.347817,39.997202" # 标签位置
    ),
    # 高德地图 WEB 服务 API 访问令牌
    key = Sys.getenv("AMAP_KEY")
  )
)
```

将返回的链接输入浏览器，会得到一张如下的图片。

<figure>
<img src="img/cumtb.png" class="full" alt="图 7: 中国矿业大学（北京）学院路校区" />
<figcaption aria-hidden="true">图 7: 中国矿业大学（北京）学院路校区</figcaption>
</figure>

## 地理编码

地球上每一块区域都对应有一个唯一的 GeoHash 值，八位 GeoHash 码的定位精度可达400平米，更多详细的介绍可见维基百科[Geohash](https://en.wikipedia.org/wiki/Geohash)，比起区、县、乡、镇行政单元，它是用来刻画规则的更小的网格单元，广泛用于本地生活服务场景，比如外卖、打车、配送等。[**geohashTools**](https://github.com/MichaelChirico/geohashTools) 包([Chirico 2020](#ref-geohashTools))可以非常高效地将 GeoHash 编码的地理区域转为经纬度坐标。

``` r
# 随意造几个位置
geohash_df <- data.frame(geohash = c(
  "wmd0k2ktr", "wmd0k2kv3", "wmd0k2kv7",
  "wmd0k2kvq", "wmd0k2mj0", "wmd0k2mj4"
))
# 转码为经纬度
dat <- geohashTools::gh_decode(geohashes = geohash_df$geohash)
# 将位置绘制在地图上
leaflet::leaflet() |> 
  leafletCN::amap() |> 
  leaflet::addCircles(lng = dat$longitude, lat = dat$latitude, radius = 3)
```

<figure>
<img src="img/sf-geohash.png" class="full" alt="图 8: GeoHash 地理区域编码" />
<figcaption aria-hidden="true">图 8: GeoHash 地理区域编码</figcaption>
</figure>

而 **lwgeom** 包([E. Pebesma 2021](#ref-lwgeom))提供函数 `st_geohash()` 可将经纬度坐标转为 GeoHash 码。在数据规模很大的情况下，这编码解码的过程方便聚合 GeoHash 粒度的数据，并呈现在地图上去观察数据中的空间规律，比如一些局部热点效应。

``` r
library(sf)
# Linking to GEOS 3.10.2, GDAL 3.4.2, PROJ 8.2.1; sf_use_s2() is TRUE
library(lwgeom)
# Linking to liblwgeom 3.0.0beta1 r16016, GEOS 3.10.2, PROJ 8.2.1
st_geohash(st_sfc(st_point(c(116.35688, 40.00314)), st_point(c(0, 90))), 9)
# [1] "wx4exf27p" "upbpbpbpb"
```

## 坐标系统

地球既不是圆球的也不是标准的椭球，将三维的球面投影到二维的平面有不同的方法，每一种方法都对应一种坐标转化，选定坐标原点后即构成坐标参考系统（Coordinate Reference System，简称 CRS）。**maps** 包([Brownrigg 2021](#ref-maps))内置了一份世界地图数据，它采用 WGS 84 坐标系，此坐标系的详细描述，读者可在 R 软件 控制台运行 `sf::st_crs("EPSG:4326")` 获取。下面以此为例介绍，本节空间数据的操作都用 **sf**包([E. Pebesma 2022](#ref-sf))来完成。

``` r
library(sf)
library(maps)
# st_as_sf 将 map 类转化为 sf 类
world1 <- st_as_sf(map("world", plot = FALSE, fill = TRUE))
## 检索坐标参考系统
st_crs(world1)
# Coordinate Reference System:
#   User input: EPSG:4326 
#   wkt:
# GEOGCRS["WGS 84",
#     ENSEMBLE["World Geodetic System 1984 ensemble",
#         MEMBER["World Geodetic System 1984 (Transit)"],
#         MEMBER["World Geodetic System 1984 (G730)"],
#         MEMBER["World Geodetic System 1984 (G873)"],
#         MEMBER["World Geodetic System 1984 (G1150)"],
#         MEMBER["World Geodetic System 1984 (G1674)"],
#         MEMBER["World Geodetic System 1984 (G1762)"],
#         MEMBER["World Geodetic System 1984 (G2139)"],
#         ELLIPSOID["WGS 84",6378137,298.257223563,
#             LENGTHUNIT["metre",1]],
#         ENSEMBLEACCURACY[2.0]],
#     PRIMEM["Greenwich",0,
#         ANGLEUNIT["degree",0.0174532925199433]],
#     CS[ellipsoidal,2],
#         AXIS["geodetic latitude (Lat)",north,
#             ORDER[1],
#             ANGLEUNIT["degree",0.0174532925199433]],
#         AXIS["geodetic longitude (Lon)",east,
#             ORDER[2],
#             ANGLEUNIT["degree",0.0174532925199433]],
#     USAGE[
#         SCOPE["Horizontal component of 3D system."],
#         AREA["World."],
#         BBOX[-90,-180,90,180]],
#     ID["EPSG",4326]]
```

**sf** 包提供 `st_as_sf()` 函数将 map 类转化为 sf 类，`st_crs()` 函数检索地图数据中附带的坐标参考系信息。接下来，用 `st_transform()` 函数转化坐标，参数 `crs` 指定新的坐标系统，示例里 `+proj=laea` 表示 Lambert Azimuthal Equal Area 投影，而 `+ellps=WGS84` 即 [WGS 1984](https://en.wikipedia.org/wiki/World_Geodetic_System)，或称 [EPSG:4326](https://en.wikipedia.org/wiki/EPSG_Geodetic_Parameter_Dataset)。`+lon_0=155` 和 `+lat_0=-90` 分别是经纬度，东经 155 度，南纬 90 度，也就是观测视角到南极去了。

``` r
# 坐标转化
world2 <- st_transform(
  x = world1,
  crs = st_crs("ESRI:102020")
)
## 检索坐标参考系统
st_crs(world2)
# Coordinate Reference System:
#   User input: ESRI:102020 
#   wkt:
# PROJCRS["South_Pole_Lambert_Azimuthal_Equal_Area",
#     BASEGEOGCRS["WGS 84",
#         DATUM["World Geodetic System 1984",
#             ELLIPSOID["WGS 84",6378137,298.257223563,
#                 LENGTHUNIT["metre",1]]],
#         PRIMEM["Greenwich",0,
#             ANGLEUNIT["Degree",0.0174532925199433]]],
#     CONVERSION["South_Pole_Lambert_Azimuthal_Equal_Area",
#         METHOD["Lambert Azimuthal Equal Area",
#             ID["EPSG",9820]],
#         PARAMETER["Latitude of natural origin",-90,
#             ANGLEUNIT["Degree",0.0174532925199433],
#             ID["EPSG",8801]],
#         PARAMETER["Longitude of natural origin",0,
#             ANGLEUNIT["Degree",0.0174532925199433],
#             ID["EPSG",8802]],
#         PARAMETER["False easting",0,
#             LENGTHUNIT["metre",1],
#             ID["EPSG",8806]],
#         PARAMETER["False northing",0,
#             LENGTHUNIT["metre",1],
#             ID["EPSG",8807]]],
#     CS[Cartesian,2],
#         AXIS["(E)",north,
#             MERIDIAN[90,
#                 ANGLEUNIT["degree",0.0174532925199433]],
#             ORDER[1],
#             LENGTHUNIT["metre",1]],
#         AXIS["(N)",north,
#             MERIDIAN[0,
#                 ANGLEUNIT["degree",0.0174532925199433]],
#             ORDER[2],
#             LENGTHUNIT["metre",1]],
#     USAGE[
#         SCOPE["Not known."],
#         AREA["Southern hemisphere."],
#         BBOX[-90,-180,0,180]],
#     ID["ESRI",102020]]
```

下面将两个不同坐标系统下的世界地图绘制出来，如图 <a href="#fig:sf-crs">9</a> 所示。

``` r
library(ggplot2)
library(patchwork)
p1 <- ggplot() +
  geom_sf(data = world1)

p2 <- ggplot() +
  geom_sf(data = world2)

p1 + p2
```

<div class="figure">

<img src="{{< blogdown/postref >}}index_files/figure-html/sf-crs-1.png" alt="WGS 84 和坐标系统" width="768" />
<p class="caption">
图 9: WGS 84 和坐标系统
</p>

</div>

# 空间分布

相比于上一篇可视化的文章，本篇示例有一点数据规模，数万或数十万规模的数据，本节以 R 语言复现[百度地图慧眼](https://huiyan.baidu.com/)的地理可视化示例，笔者利用开源免费的软件可以获得同样的效果。展示空间点数据的图形有散点图、热力图、蜂窝图、柱状图、飞线图等等，最常见、最常用的莫过于散点图，简单明了地呈现数据随空间位置的分布，快速透视数据的空间模式。

[百度地图慧眼](https://huiyan.baidu.com/)开源了一些地理信息可视化库，特别是[Mapv](https://github.com/huiyan-fe/mapv)，还有很多[示例](https://mapv.baidu.com/gl/examples/)及使用[文档](https://lbsyun.baidu.com/solutions/mapvdata)。感兴趣的读者不妨看看。下面以示例中的热力柱图为例，数据[下载地址](https://mapv.baidu.com/gl/examples/static/beijing.07102610.json)[^2]。

``` bash
# 示例首页 https://mapv.baidu.com/gl/examples/
curl -fLo beijing.07102610.json https://mapv.baidu.com/gl/examples/static/beijing.07102610.json
```

下载完成后导入到 R 环境中，并提取其中有效的数据部分，整理成 data.frame 数据类型，以便后续进一步操作。注意，这只是个普通 JSON 格式文件，而不是 GeoJSON 格式，不能用 `sf::read_sf()` 读取，推荐使用 Jeroen Ooms 开发的[**jsonlite** 包](https://github.com/jeroen/jsonlite)，它效率比较高，依赖也少。

``` r
beijing <- jsonlite::fromJSON("data/mapv-data/beijing.07102610.json")
# 提取 JSON 文件中的数据
beijing <- matrix(as.numeric(beijing$result$data$bound[[1]]), ncol = 3, byrow = F)
# 设置列名便于后续操作
colnames(beijing) <- c("x", "y", "den")
# 将 matrix 转化 data.frame 数据类型
beijing <- as.data.frame(beijing)
```

## 散点图

R 语言数据操作常常离不开 data.frame，有很多空间数据也是按照一张张二维表格存储的，为了能够使用 **sf** 包及其生态环境，将 data.frame 类型转化为空间数据类型 sf 是非常必要的。之前，介绍过如何用 **sp** 包将 data.frame 转化为 sp 类型，进一步，**sf** 包提供的泛型函数 `st_as_sf()` 支持将多种数据类型转化为 sf 类型。目前支持 12 种数据类型转化，基本覆盖日常所需。

``` r
methods("st_as_sf")
#  [1] st_as_sf.data.frame*   st_as_sf.lpp*          st_as_sf.map*         
#  [4] st_as_sf.owin*         st_as_sf.ppp*          st_as_sf.ppplist*     
#  [7] st_as_sf.psp*          st_as_sf.s2_geography* st_as_sf.sf*          
# [10] st_as_sf.sfc*          st_as_sf.Spatial*      st_as_sf.SpatVector*  
# [13] st_as_sf.wk_crc*       st_as_sf.wk_rct*       st_as_sf.wk_wkb*      
# [16] st_as_sf.wk_wkt*       st_as_sf.wk_xy*       
# see '?methods' for accessing help and source code
```

另外，值得一提的是**sfheaders**包([Cooley 2020](#ref-sfheaders))，它可以非常方便高效地将普通数据框 data.frame 类型转化为空间数据 sf（Simple feature）类型，据其官网介绍，转化性能可以和 **data.table** 媲美，上游依赖很少，甚至不需要依赖 **sf** 包。

``` r
library(sf)
# library(sfheaders)
# beijing_sf <- sf_point(beijing, x = "x", y = "y", keep = TRUE)
# 将 data.frame 转化为 sf 类型
beijing_sf <- st_as_sf(beijing, coords = c("x", "y"))
# 指定原数据的坐标参考系
st_crs(beijing) <- 3857
# 转到日常用的经纬度坐标参考系
beijing_sf <- st_transform(beijing_sf, crs = 4326)
# 快速绘图查看数据
plot(beijing_sf["den"], pch = 19, cex = 0.2)
```

<figure>
<img src="img/beijing-sf.png" class="full" alt="图 10: 北京市热点分布图" />
<figcaption aria-hidden="true">图 10: 北京市热点分布图</figcaption>
</figure>

**ggplot2** 早已支持 sf 数据类型，不强调精雕细琢，绘图过程也十分简单。

``` r
library(ggplot2)
ggplot() +
  geom_sf(data = beijing_sf, aes(color = den), cex = 0.2)
```

<figure>
<img src="img/beijing-ggplot2.png" class="full" alt="图 11: 北京市热点分布图" />
<figcaption aria-hidden="true">图 11: 北京市热点分布图</figcaption>
</figure>

[**rasterly**](https://github.com/plotly/rasterly) 渲染 35058 多个点毫无压力，使用方式和 **ggplot2** 非常相近，配合 **plotly** 包支持渲染交互式图形，如图<a href="#fig:beijing-rasterly">12</a>所示。**rasterly** 的基本想法来自 Python 模块[datashader](https://github.com/holoviz/datashader/)，将数据点映射到网格中，聚合每个网格中的点得到代表点，即像素点，接着照常绘图，简而言之，连续空间离散化以近似，空间点数据转栅格数据。

``` r
library(rasterly)
# 静态散点图
rasterly(data = beijing, aes(x = x, y = y)) |> 
  rasterly_points() 
# 静态散点图：点密度、图片长宽
rasterly(data = beijing, aes(x = x, y = y, color = den), 
         plot_width = 700, plot_height = 500) |> 
  rasterly_points()
# 也可以绘制交互式的热力图
LogTransform <- function(z) {
  log(z)
}
plotly::plot_ly(beijing, x = ~x, y = ~y) |>
  add_rasterly_heatmap(
    on = ~den, # 对 den 变量取对数
    reduction_func = "max", # 聚合方式是求极大
    scaling = LogTransform, # 对数变换
    plot_width = 600, plot_height = 400
  ) |> 
  plotly::layout(
    xaxis = list(
      title = "x"
    ),
    yaxis = list(
      title = "y"
    )
  )
```

<figure>
<img src="img/beijing-rasterly.png" class="full" alt="图 12: 北京市热点分布图" />
<figcaption aria-hidden="true">图 12: 北京市热点分布图</figcaption>
</figure>

最后，补充介绍一下 **sp** 包绘制图形的过程，短期内恐还有必要。先将 data.frame 数据类型转为 sp 空间数据类型，以便调用更加高效且丰富的数据处理和可视化函数。

``` r
# 调 sp 包转化为 sp 类型
library(sp)
beijing_sp <- beijing
# 指定坐标变量
coordinates(beijing_sp) <- ~ x + y
# 指定参考系 EPSG:3857
proj4string(beijing_sp) <- CRS("EPSG:3857")
# 查看数据
summary(beijing_sp)
# Object of class SpatialPointsDataFrame
# Coordinates:
#        min      max
# x 12855679 13079460
# y  4761527  4985306
# Is projected: TRUE 
# proj4string :
# [+proj=merc +a=6378137 +b=6378137 +lat_ts=0 +lon_0=0 +x_0=0 +y_0=0 +k=1 +units=m
# +nadgrids=@null +wktext +no_defs]
# Number of points: 35058
# Data attributes:
#       den       
#  Min.   : 1.00  
#  1st Qu.: 1.00  
#  Median : 2.00  
#  Mean   : 2.48  
#  3rd Qu.: 3.00  
#  Max.   :81.00
# 转化坐标参考系 EPSG:4326
beijing_sp <- spTransform(beijing_sp, CRSobj = CRS("EPSG:4326"))
# 查看转化后的数据
summary(beijing_sp)
# Object of class SpatialPointsDataFrame
# Coordinates:
#      min    max
# x 115.48 117.49
# y  39.28  40.82
# Is projected: FALSE 
# proj4string : [+proj=longlat +datum=WGS84 +no_defs]
# Number of points: 35058
# Data attributes:
#       den       
#  Min.   : 1.00  
#  1st Qu.: 1.00  
#  Median : 2.00  
#  Mean   : 2.48  
#  3rd Qu.: 3.00  
#  Max.   :81.00
```

``` r
# 最后绘图
spplot(beijing_sp, "den",
  colorkey = TRUE,     # 连续型图例
  alpha = 0.4,         # 散点透明度
  key.space = "right", # 图例位置
  cex = 0.3,           # 点的大小
  aspect = 0.7,        # 图形长宽比例
  scales = list(
    draw = T,
    # 去掉图形上边、右边多余的刻度线
    x = list(alternating = 1, tck = c(1, 0)),
    y = list(alternating = 1, tck = c(1, 0))
  )
)
```

<figure>
<img src="img/beijing-spplot.png" class="full" alt="图 13: 北京市热点分布图" />
<figcaption aria-hidden="true">图 13: 北京市热点分布图</figcaption>
</figure>

## 热力图

OpenStreetMap 是开放街道地图数据，由来自世界各地的贡献者维护，但不提供免费的地图 API。使用此地图服务，不会将自己的数据上传至 OpenStreetMap 的服务器上。而 Leaflet 是开源的交互式地理可视化 JS 库。Joe Cheng 开发维护的 [**leaflet**](https://github.com/rstudio/leaflet) 包([Cheng, Karambelkar, and Xie 2022](#ref-leaflet))是 JavaScript 库 [Leaflet](https://github.com/Leaflet/Leaflet) 的 R 语言接口。一个提供基础地图服务，一个提供数据渲染可视化，一个提供封装好的 R 语言接口。

<figure>
<img src="/img/leaflet.svg" class="full" alt="图 14: 开源交互式 JavaScript 库 Leaflet" />
<figcaption aria-hidden="true">图 14: 开源交互式 JavaScript 库 Leaflet</figcaption>
</figure>

``` r
library(leaflet)
# 提供 addHeatmap 函数绘制热力图 
library(leaflet.extras) 
leaflet() |>
  addTiles() |>
  addHeatmap(
    data = beijing,
    lng = ~x, lat = ~y,
    intensity = ~den, # 密度
    blur = 20, max = 0.05, radius = 15
  ) |>
  addScaleBar(position = "bottomleft")
```

<figure>
<img src="img/beijing-leaflet.png" class="full" alt="图 15: 北京市热点分布图" />
<figcaption aria-hidden="true">图 15: 北京市热点分布图</figcaption>
</figure>

[**mapdeck**](https://github.com/SymbolixAU/mapdeck) 包将 [MapBox GL](https://www.mapbox.com/) 的地图服务和[deck.gl](https://github.com/visgl/deck.gl)的大规模可视化能力封装到一起，功能还是很强的，函数 `add_heatmap()` 可用来绘制热力图，数万散点毫无压力，如图<a href="#fig:beijing-heatmap">16</a>。

``` r
mapdeck(style = mapdeck_style("dark"), pitch = 45) |> 
  add_heatmap(
    data = beijing, lat = "y", lon = "x",
    weight = "den", colour_range = hcl.colors(6)
  )
```

<figure>
<img src="img/beijing-heatmap.png" class="full" alt="图 16: 北京市热点分布图" />
<figcaption aria-hidden="true">图 16: 北京市热点分布图</figcaption>
</figure>

## 蜂窝图

除了热力图，**mapdeck** 调用 `add_hexagon()` 和 `add_screengrid()` 还可以绘制蜂窝图，如图<a href="#fig:beijing-hexagons">17</a>。

``` r
mapdeck(style = mapdeck_style("dark"), pitch = 45) |> 
  add_screengrid(
    data = beijing,
    lat = "y",
    lon = "x",
    weight = "den",
    layer_id = "screengrid_layer",
    cell_size = 5,
    opacity = 0.6,
    colour_range = hcl.colors(6)
  )
```

<figure>
<img src="img/beijing-hexagons.png" class="full" alt="图 17: 北京市热点分布图" />
<figcaption aria-hidden="true">图 17: 北京市热点分布图</figcaption>
</figure>

## 柱状图

咋一看，读者可能会疑惑，怎么柱状图也能归到地理可视化？它在蜂窝图的基础上，用柱子的高低表示密度值大小，整个地图是三维的，可拖拽。**mapdeck** 提供函数 `add_grid()` / `add_hexagon()` 绘制三维柱状图，如图<a href="#fig:beijing-mapdeck">18</a>。

``` r
library(mapdeck)
mapdeck(style = mapdeck_style("dark"), pitch = 45) |> 
  add_hexagon(
    data = beijing,
    lat = "y", lon = "x", elevation = "den",
    layer_id = "hex_layer",
    elevation_scale = 30,
    colour_range = hcl.colors(6)
  )
```

<figure>
<img src="img/beijing-mapdeck.png" class="full" alt="图 18: 北京市热点分布图" />
<figcaption aria-hidden="true">图 18: 北京市热点分布图</figcaption>
</figure>

## 飞线图

以 **nycflights13** ([Wickham 2021](#ref-nycflights13)) 包提供航班数据做飞线图，数据由 Hadley Wickham 收集自[OpenFlights Airports Database](https://openflights.org/data.html)，从纽约三大机场 JFK, LGA 或 EWR 的准点起飞数据。

``` r
library(nycflights13)
data("flights") # 航班
data("airports") # 机场
```

提取2013年1月1日的航班数据，出发地 origin 和目的地 dest。数据集 airports 包含 FAA 机场代码，经纬度（经纬度精确到小数点后6位，坐标参考系 `EPSG:4326`）等信息。

``` r
# 提取部分航班数据
sub_flights <- subset(
  x = flights, subset = year == 2013 & month == 1 & day == 1,
  select = c("origin", "dest", "time_hour")
)
# 统计航班架次
sub_flights <- aggregate(formula = time_hour ~ origin + dest, data = sub_flights, FUN = length)
# 准备机场位置信息
sub_airports <- subset(
  x = airports, select = c("faa", "lon", "lat")
)
```

关联机场位置信息，获取起飞机场和落地机场的经纬度信息。

``` r
# 起飞机场
tmp <- merge(sub_flights, sub_airports, by.x = "origin", by.y = "faa")
colnames(tmp) <- c("origin", "dest", "cnt", "origin_lon", "origin_lat")
# 落地机场
tmp <- merge(tmp, sub_airports, by.x = "dest", by.y = "faa")
colnames(tmp) <- c(
  "origin", "dest", "cnt", "origin_lon", "origin_lat",
  "dest_lon", "dest_lat"
)
```

[mapdeck](https://github.com/SymbolixAU/mapdeck) 提供 `add_greatcircle()` 图层绘制飞线图。

``` r
mapdeck(style = "mapbox://styles/mapbox/dark-v9") |> 
  add_greatcircle(
    data = tmp,
    layer_id = "arc_layer",
    origin = c("origin_lon", "origin_lat"),
    destination = c("dest_lon", "dest_lat"),
    stroke_from = "cnt",
    stroke_width = 3, # 弧线宽度
    palette = "viridis", # 调色板 "plasma"
    legend = TRUE
  ) |>  
  mapdeck_view(
    # 视角位置
    location = c(-110, 48),
    # 设置缩放水平
    zoom = 2,
    # 俯仰角
    pitch = 45
  )
```

<figure>
<img src="img/us-flights.png" class="full" alt="图 19: 2013年1月1日纽约机场出发的航班" />
<figcaption aria-hidden="true">图 19: 2013年1月1日纽约机场出发的航班</figcaption>
</figure>

# 专题地图

Thematic Maps (or Statistical Maps) 专题地图或统计地图，重点在于呈现一个或多个地理属性（变量）的空间模式，属于制图学 Cartography 范畴。一种常见的 Thematic Maps 是 Choropleth map, 地图上每个单元（或数据收集的单元，比如州、郡、县）用色彩填充表示属性的大小。专题地图具体形式可以有比例符号图（气泡图），散点图，迁徙/流向图等。据 Michael Friendly 等[考证](https://www.datavis.ca/milestones/)，最早的 Choropleth Map 可追溯到 1819 年，一位叫 Baron Pierre Charles Dupin 的法国人，统计法国各个地区的文盲分布和比例，用从黑到白的颜色表示文盲比例的高低。

一个现代化的示例图<a href="#fig:us-census-2020">20</a>来自[美国人口普查局](https://www.census.gov/)官网，展示2020年美国各个城镇的人口密度及相关信息，采用 Tableau 制作而成。

<figure>
<img src="img/us-census-2020.png" class="full" alt="图 20: 2020年美国各个城镇的人口密度" />
<figcaption aria-hidden="true">图 20: 2020年美国各个城镇的人口密度</figcaption>
</figure>

下面引用 **leaflet** 包[官方文档](https://rstudio.github.io/leaflet/choropleths.html)中的示例—2011 年美国各个州的人口密度。数据存储以[GeoJSON 格式](https://leafletjs.com/examples/geojson/)存储在文件 `us-states.geojson`里，它是矢量多边形数据，坐标参考系是 WGS 84，包含美国各个州的边界 geometry，各州人口密度数据 density（每平方英里的人口数）。[us-states.geojson](https://rstudio.github.io/leaflet/json/us-states.geojson)的数据源头是 2011 年美国人口普查局。顺便一说，2020年的最新数据可从[维基百科文章](https://en.wikipedia.org/wiki/List_of_states_and_territories_of_the_United_States_by_population_density)获取。

笔者在此示例的基础上有几个改进点：

1.  示例中调用 Mapbox 地图的方法不可用，可用 **leaflet** 自带的 OpenStreetMap 瓦片地图替换，或用函数 `addTiles()` 自定义地图瓦片的方式调用 Mapbox 地图；
2.  示例中使用[**geojsonio**](https://github.com/ropensci/geojsonio)包读取 GeoJSON 格式的地图数据文件性能差，且上游过时的依赖很多，改用 **sf** 包读取，性能高、速度快；
3.  添加一些数据集和代码的中文描述，补充一些细节说明；
4.  空间数据处理从 **sp** 升级到 **sf**，使得整个数据可视化过程仅依赖 **sf** 和 **leaflet** 包，达到了稳定、高效和可靠。

``` r
library(sf)
# 读取数据
states <- st_read("data/us-states.geojson")
# Reading layer `us-states' from data source 
#   `/Users/xiangyun/Documents/xiangyun/content/post/2022-01-15-spatial-data-visualization/data/us-states.geojson' 
#   using driver `GeoJSON'
# Simple feature collection with 52 features and 3 fields
# Geometry type: MULTIPOLYGON
# Dimension:     XY
# Bounding box:  xmin: -188.9 ymin: 17.93 xmax: -65.63 ymax: 71.35
# Geodetic CRS:  WGS 84
```

查看数据采用的坐标参考系。

``` r
st_crs(states)
# Coordinate Reference System:
#   User input: WGS 84 
#   wkt:
# GEOGCRS["WGS 84",
#     DATUM["World Geodetic System 1984",
#         ELLIPSOID["WGS 84",6378137,298.257223563,
#             LENGTHUNIT["metre",1]]],
#     PRIMEM["Greenwich",0,
#         ANGLEUNIT["degree",0.0174532925199433]],
#     CS[ellipsoidal,2],
#         AXIS["geodetic latitude (Lat)",north,
#             ORDER[1],
#             ANGLEUNIT["degree",0.0174532925199433]],
#         AXIS["geodetic longitude (Lon)",east,
#             ORDER[2],
#             ANGLEUNIT["degree",0.0174532925199433]],
#     ID["EPSG",4326]]
```

查看地图数据的边界信息。

``` r
st_bbox(states)
#    xmin    ymin    xmax    ymax 
# -188.90   17.93  -65.63   71.35
```

做一点说明，西经 -188.90491，也就是东经 360 - 188.90491 = 180 - 8.90491 = 171.0951，西经 -65.62680 至西经 -188.90491 跨越范围 188.90491 - 65.62680 = 123.2781。
中心位置经度 ((-65.62680) + (-188.90491) )/ 2 = -127.2659，纬度 (17.92956 + 71.35163)/2 = 44.64059。此中心位置不在美国大陆。

<div class="rmdtip">

本初子午线定义为 0 度经线，是经过英国格林尼治天文台的一条经线，向东、向西分别定义为东经、西经。东经 180 度 和西经 180 度是同一条经线，穿越新西兰罗斯属地，也穿越美国阿拉斯加州。美国国土东西跨度很大，跨越了东（西）经 180 度。

</div>

## leaflet

``` r
library(leaflet)
# 人口密度分段
bins <- c(0, 10, 20, 50, 100, 200, 500, 1000, Inf)
# 构造调色板
pal <- colorBin("YlOrRd", domain = states$density, bins = bins)
# 准备悬浮提示
labels <- sprintf(
  "<strong>%s</strong><br/>%g people / mi<sup>2</sup>",
  states$name, states$density
) |>  lapply(htmltools::HTML)

# 绘图
leaflet(states) |> 
  setView(lng = -96, lat = 37.8, zoom = 4) |> 
  # 添加默认的 OSM 瓦片服务
  addTiles() |> 
  addPolygons(
    color = "white", # 边界线颜色
    opacity = 1,     # 颜色透明度
    weight = 2,      # 边界线宽度
    fillOpacity = 0.6,   # 填充色透明度
    fillColor = ~ pal(density),  # 填充色
    label = labels
  ) |> 
  addLegend(
    pal = pal, 
    values = ~density,
    opacity = 0.7, 
    title = "人口密度",
    position = "bottomright"
  )
```

<figure>
<img src="img/us-states-leaflet.png" class="full" alt="图 21: leaflet 包专题地图" />
<figcaption aria-hidden="true">图 21: <strong>leaflet</strong> 包专题地图</figcaption>
</figure>

LeafLet JS 在专题地图[choropleth](https://leafletjs.com/examples/choropleth/)示例里调用了 Mapbox 瓦片服务和[地图风格](https://docs.mapbox.com/api/maps/styles/)。下面在函数 `addTiles()` 里替换瓦片服务 URL 模版路径，**leaflet** 也可用上 Mapbox 瓦片地图。

``` r
leaflet(states) |> 
  setView(lng = -96, lat = 37.8, zoom = 4) |> 
  addTiles(urlTemplate = sprintf(
    paste(
      "https://api.mapbox.com/styles/v1/mapbox/light-v9",
      "tiles/{z}/{x}/{y}?access_token=%s",
      sep = "/"
    ),
    Sys.getenv("MAPBOX_TOKEN") # 准备个人访问令牌
  ), attribution = sprintf(
    paste(
      "Map data &copy; <a href='%s'>OpenStreetMap</a>",
      "contributors, Imagery © <a href='%s'>Mapbox</a>"
    ),
    "https://www.openstreetmap.org/copyright",
    "https://www.mapbox.com/"
  )) |> 
  addPolygons(
    color = "white", # 边界线颜色
    opacity = 1, # 颜色透明度
    weight = 2, # 边界线宽度
    fillOpacity = 0.6, # 填充色透明度
    fillColor = ~ pal(density), # 填充色
    label = labels
  ) |> 
  addLegend(
    pal = pal,
    values = ~density,
    opacity = 0.7,
    title = "人口密度",
    position = "bottomright"
  )
```

<figure>
<img src="img/us-states-mapbox.png" class="full" alt="图 22: leaflet 包专题地图" />
<figcaption aria-hidden="true">图 22: <strong>leaflet</strong> 包专题地图</figcaption>
</figure>

借助[leaflet-providers](https://github.com/leaflet-extras/leaflet-providers)，Leaflet 已经支持很多[瓦片服务](https://leaflet-extras.github.io/leaflet-providers/preview/)，除了以上两种，比如夜景图<a href="#fig:cumtb-nasa">23</a>。

``` r
library(leaflet)
leaflet() |> 
  addProviderTiles("NASAGIBS.ViirsEarthAtNight2012") |> 
  addMarkers(
    lng = 116.35376693,
    lat = 40.00382807,
    popup = "中国矿业大学（北京）学院路校区"
  )
```

<figure>
<img src="img/cumtb-nasa.png" class="full" alt="图 23: leaflet 包调 NASA 瓦片服务" />
<figcaption aria-hidden="true">图 23: <strong>leaflet</strong> 包调 NASA 瓦片服务</figcaption>
</figure>

## mapdeck

与 **leaflet** 要求类似，**mapdeck** 也要求空间数据的坐标参考系是 `EPSG:4326`。

``` r
library(mapdeck)
states <- transform(states, density_log10 = log10(density))
mapdeck() |> 
  add_polygon(
    data = states,
    fill_colour = "density_log10",
    fill_opacity = 0.8,
    palette = "plasma",
    legend = TRUE
  )
```

<figure>
<img src="img/us-states-mapdeck.png" class="full" alt="图 24: mapdeck 包专题地图" />
<figcaption aria-hidden="true">图 24: <strong>mapdeck</strong> 包专题地图</figcaption>
</figure>

## sf

地理单元的编码具有唯一性，即一套编码体系下，同一块地方不能有两个编码值，可以将其视为主键，则每一块区域上的人口密度就是属性值。

``` r
plot(states["density"], logz = TRUE)
```

<figure>
<img src="img/us-states-sf.png" class="full" alt="图 25: sf 包专题地图" />
<figcaption aria-hidden="true">图 25: <strong>sf</strong> 包专题地图</figcaption>
</figure>

## ggplot2

``` r
library(ggplot2)
ggplot() +
  geom_sf(data = states, aes(geometry = geometry, fill = density), colour = NA) +
  scale_fill_gradientn(
    trans = "log10", colors = sf.colors(10),
    guide = guide_colourbar(
      barwidth = 25, barheight = 0.4,
      title.position = "left"
    )
  ) +
  theme(
    panel.grid = element_line(colour = "gray90"),
    legend.position = "top",
    panel.background = element_blank()
  )
```

<figure>
<img src="img/us-states-ggplot2.png" class="full" alt="图 26: ggplot2 包专题地图" />
<figcaption aria-hidden="true">图 26: <strong>ggplot2</strong> 包专题地图</figcaption>
</figure>

# 邵东市房地产行业分析

《爱情碟中谍》里宋丹丹说买房子最重要的是：Location、Location、Location（位置，位置，还是位置）！POI（Point of Interest 兴趣点）周围的商业价值，发展潜力，增值空间，如房子周边的学校、商场、交通，反映在时间距离、空间距离，最终体现在房价上。买房子、卖房子，中介和销售玩的就是**信息不对称**。如果能从不同层面，比如地区经济发展状况，和其它地区对比，和市内其它商圈对比，和其它楼盘房子对比，就可以做到不被轻易忽悠了。

``` r
library(httr)
# 向高德地图 API 发 GET 请求
GetCoord <- function(address = "仁为峰邵东壹号", city = "邵东市") {
  tmp <- GET(
    url = "https://restapi.amap.com/",
    path = "v3/geocode/geo",
    query = list(
      # 原坐标，经纬度小数点后不得超过6位
      address = address,
      # 原坐标参考系，还支持 GPS 坐标，取值 'gps'
      city = city,
      # 返回数据格式，还支持 xml
      output = "json",
      # 高德地图 WEB 服务 API 访问令牌
      key = Sys.getenv("AMAP_KEY")
    )
  )
  as.numeric(strsplit(x = content(tmp)$geocodes[[1]]$location, split = ",")[[1]])
}
# 测试一下
GetCoord(address = "仁为峰邵东壹号", city = "湖南省邵阳市邵东市")
```

    # [1] 111.751713  27.270619

接下来将函数向量化，以便批量解析地址，获取经纬度数据。可用 `Vectorize()` 函数实现，只需指定待向量化的参数向量。

``` r
# 函数向量化
GetCoordVec <- Vectorize(FUN = GetCoord, vectorize.args = c("address", "city"), USE.NAMES = F, SIMPLIFY = F)
# 测试一下
GetCoordVec(address = "仁为峰邵东壹号", city = "湖南省邵阳市邵东市")
```

首先准备各个楼盘和地址信息，有的提供楼盘就能比较好的定位，有的定位不行，可见高德的数据不是百分百准确的。实际上任何数据都别想百分百精确，一些楼盘可能是新开的，周围配套还未建立，高德数据未及时更新等。

``` r
# 批量解析地址
house <- c(
  "中际城市森林", "仁为峰邵东壹号", "龙熙府邸",
  "邦盛凤凰城（御玺）", "碧桂园·星钻", "泰丰城",
  "中驰晨曦桐江府", "悦富时代广场", "横科·佳润国际",
  "碧桂园·珑璟台", "中伟·国际公馆", "福星御景城",
  "中翔·龙玺", "金裕名都", "横科·金泉华府", "富景鑫城"
)
# 地址来自安居客 App
address <- paste0("湖南省邵阳市邵东市", c(
  "中际城市森林", "仁为峰邵东壹号", "梨园路与金石路交汇处",
  "邦盛凤凰城（御玺）", "绿汀大道与336省道交汇处", "泰丰城",
  "中驰晨曦桐江府", "悦富时代广场", "公园路与新辉路交汇处",
  "宋家塘梨园路168号", "建设北路与景秀路交互处", "福星御景城",
  "中翔·龙玺", "金裕名都", "横科·金泉华府", "兴和大道与光大路交叉口"
))
```

调用 `mapply()` 函数批量发送请求获取数据，返回的 list 列表数据对象，可用函数 `do.call()` 配合 `rbind()` 合并成 matrix 类型，再转为通用的 data.frame 类型。

``` r
# 获取数据
dat <- mapply(FUN = GetCoordVec, address = address, MoreArgs = list(city = "湖南省邵阳市邵东市"))
# 整理数据
dat2 <- do.call("rbind", dat)
dat2 <- as.data.frame(dat2)
colnames(dat2) <- c("long", "lat")
dat2$house <- house
```

最后，调用 **leaflet** 包，将数据导入绘图函数即可。如图<a href="#fig:shaodong-house">27</a>所示，图中红点是邵东市各个在售楼盘的空间位置，仅考虑了安居客 App 的数据。

``` r
library(leaflet)
library(leafletCN)
# 绘图
leaflet(options = leafletOptions(
  minZoom = 4, maxZoom = 18,
  zoomControl = FALSE
)) |>
  setView(lng = mean(dat2$long), lat = mean(dat2$lat), zoom = 14) |>
  leafletCN::amap() |>
  addCircles(
    data = dat2,
    lng = ~long, lat = ~lat, label = ~house,
    radius = 50, color = "red",
    fillOpacity = 0.55, stroke = T, weight = 1
  )
```

<figure>
<img src="img/shaodong-house.png" class="full" alt="图 27: 邵东市各个楼盘的空间位置" />
<figcaption aria-hidden="true">图 27: 邵东市各个楼盘的空间位置</figcaption>
</figure>

值得注意的是「龙熙府邸」和「碧桂园珑璟台」的定位重合了，地理位置上，二者确实也接近。经过这一番使用，可见高德开放平台给的经纬度地址解析服务一般。

图中信息比较丰富，简单说下：

1.  各个楼盘在城市主干道昭阳大道、绿汀大道两侧排开。
2.  高铁邵东站、国际商贸城、邦盛凤凰城地理位置价值依次降低，后者短期内发展不起来。
3.  百富广场、邵东工业品市场、邵东市中医院、邵东一中属于老城区。
4.  2019年邵东撤县划市，建设新城区，邵东高铁站开通，楼市炒贵族学校、区位优势，县政府推波助澜，房价已翻倍。
5.  建设新城区，碧桂园等头部房企进场，对房价有推动作用，但整体上供给充足。

另外，结合最近几年邵东市发布的统计年鉴数据，笔者了解到，邵东市最近几年人口增长为负，经济增长主要靠固定资产投资，换个说法，就是房地产投资。大城市各个行业，特别是产业互联网下沉战略促使三、四、五线城市消费升级，但是小城人民薪资待遇并没有升级，形成收入消费倒挂。因此，小城房地产价格近年猛增已到极限，没有足够配套建设，特别是没有大城市的高质量劳动力回流，城市发展会很慢。结合笔者对邵东市近年来人才引进政策、人力市场需求和薪资待遇的了解，特别是对公务员、中学教师、工程师等岗位的分析，对大城市高质量劳动力吸引不足，也承接不了。

目前，邵东房价整体在 5000至6000，如果资金充裕，不用选，找最贵的房子买，大家都不傻，地段越好，价格越高。未来城市资源配套都往这集中，等着升值，当下越贵的房子未来升值空间也越高，这就是马太效应！2021年房价基本稳定，国家出台系列政策调控，国家若不出手，房地产就只剩下泡沫了，楼市也将迟早崩盘，这对邵东经济发展是致命的。

# 地表土壤重金属污染分析

数据来自 2011 年全国大学生数据[建模竞赛 A 题](http://www.mcm.edu.cn/html_cn/node/a1ffc4c5587c8a6f96eacefb8dbcc34e.html)，下载数据到本地后，首先读取城市地形数据，即采样点的位置及所属功能区。功能区代码 1 对应「生活区」，2 对应「工业区」，3 对应「山区」，4 对应「交通区」和 5 对应「公园绿地区」。

``` r
library(readxl)
# 采样点的城市地形数据
dat1 <- read_xls(
  path = "data/cumcm2011A附件_数据.xls",
  col_names = TRUE, sheet = "附件1", range = "A3:E322"
)
dat1
# # A tibble: 319 × 5
#     编号 `x(m)` `y(m)` `海拔(m)` 功能区
#    <dbl>  <dbl>  <dbl>     <dbl>  <dbl>
#  1     1     74    781         5      4
#  2     2   1373    731        11      4
#  3     3   1321   1791        28      4
....
```

``` r
library(tibble)
tmp <- tribble(
  ~`功能区编号`, ~`功能区名称`,
  1, "生活区",
  2, "工业区",
  3, "山区",
  4, "交通区",
  5, "公园绿地区"
)
# 合并数据
dat2 <- merge(x = dat1, y = tmp, by.x = "功能区", by.y = "功能区编号", sort = FALSE)
dat2
#     功能区 编号  x(m)  y(m) 海拔(m) 功能区名称
# 1        4    1    74   781       5     交通区
# 2        4    2  1373   731      11     交通区
# 3        4    3  1321  1791      28     交通区
# 4        4   44  8457  8991      21     交通区
# 5        4    5  1049  2127      12     交通区
....
```

读取地表土壤各种重金属浓度的数据，它在同一个Excel文件的另一个工作区里。

``` r
# 土壤重金属浓度
dat3 <- read_xls(
  path = "data/cumcm2011A附件_数据.xls",
  col_names = TRUE, sheet = "附件2", range = "A3:I322"
)
# 篇幅所限，铅 Pb (μg/g) 和锌 Zn (μg/g) 两列未显示
dat3
# # A tibble: 319 × 9
#     编号 `As (μg/g)` `Cd (ng/g)` `Cr (μg/g)` `Cu (μg/g)` `Hg (ng/g)` `Ni (μg/g)`
#    <dbl>       <dbl>       <dbl>       <dbl>       <dbl>       <dbl>       <dbl>
#  1     1        7.84        154.        44.3        20.6         266        18.2
#  2     2        5.93        146.        45.0        22.5          86        17.2
#  3     3        4.9         439.        29.1        64.6         109        10.6
....
```

将采样点的地形数据和土壤重金属浓度数据合并在一起。

``` r
dat4 <- merge(x = dat2, y = dat3, by.x = "编号", by.y = "编号", sort = TRUE)
dat4
#     编号 功能区  x(m)  y(m) 海拔(m) 功能区名称 As (μg/g) Cd (ng/g) Cr (μg/g) Cu (μg/g)
# 1      1      4    74   781       5     交通区      7.84     153.8     44.31     20.56
# 2      2      4  1373   731      11     交通区      5.93     146.2     45.05     22.51
# 3      3      4  1321  1791      28     交通区      4.90     439.2     29.07     64.56
# 4      4      2     0  1787       4     工业区      6.56     223.9     40.08     25.17
# 5      5      4  1049  2127      12     交通区      6.35     525.2     59.35    117.53
....
```

以上8种主要重金属元素的背景参考值如下：

``` r
# 土壤重金属浓度的背景参考值
dat5 <- read_xls(
  path = "data/cumcm2011A附件_数据.xls",
  col_names = TRUE, sheet = "附件3", range = "A3:D11"
)
dat5
# # A tibble: 8 × 4
#   元素      平均值 标准偏差 范围    
#   <chr>      <dbl>    <dbl> <chr>   
# 1 As (μg/g)    3.6      0.9 1.8~5.4 
# 2 Cd (ng/g)  130       30   70~190  
# 3 Cr (μg/g)   31        9   13~49   
# 4 Cu (μg/g)   13.2      3.6 6.0~20.4
# 5 Hg (ng/g)   35        8   19~51   
# 6 Ni (μg/g)   12.3      3.8 4.7~19.9
# 7 Pb (μg/g)   31        6   19~43   
# 8 Zn (μg/g)   69       14   41~97
```

既然提供了各重金属浓度的背景参考值，可以先将原浓度数据标准化。

``` r
# 相比于 transform 函数 within 更友好一些，特别是在列名处理上
# 详见 https://bugs.r-project.org/show_bug.cgi?id=17890
dat6 <- within(dat4, {
  `As (μg/g)` <- (`As (μg/g)` - 3.6) / 0.9
  `Cd (ng/g)` <- (`Cd (ng/g)` - 130) / 30
  `Cr (μg/g)` <- (`Cr (μg/g)` - 31) / 9
  `Cu (μg/g)` <- (`Cu (μg/g)` - 13.2) / 3.6
  `Hg (ng/g)` <- (`Hg (ng/g)` - 35) / 8
  `Ni (μg/g)` <- (`Ni (μg/g)` - 12.3) / 3.8
  `Pb (μg/g)` <- (`Pb (μg/g)` - 31) / 6
  `Zn (μg/g)` <- (`Zn (μg/g)` - 69) / 14
})
# 篇幅所限，仅展示部分列
dat6
#     编号 功能区  x(m)  y(m) 海拔(m) 功能区名称 As (μg/g) Cd (ng/g) Cr (μg/g) Cu (μg/g)
# 1      1      4    74   781       5     交通区   4.71111   0.79333  1.478889   2.04444
# 2      2      4  1373   731      11     交通区   2.58889   0.54000  1.561111   2.58611
# 3      3      4  1321  1791      28     交通区   1.44444  10.30667 -0.214444  14.26667
# 4      4      2     0  1787       4     工业区   3.28889   3.13000  1.008889   3.32500
# 5      5      4  1049  2127      12     交通区   3.05556  13.17333  3.150000  28.98056
....
```

为了方便后续数据处理和分析，重命名数据框各个列名。

``` r
# 查看各个列名
colnames(dat6)
#  [1] "编号"       "功能区"     "x(m)"       "y(m)"       "海拔(m)"    "功能区名称"
#  [7] "As (μg/g)"  "Cd (ng/g)"  "Cr (μg/g)"  "Cu (μg/g)"  "Hg (ng/g)"  "Ni (μg/g)" 
# [13] "Pb (μg/g)"  "Zn (μg/g)"
# 重命名各个列
colnames(dat6) <- c(
  "编号", "功能区", "x", "y", "海拔", "功能区名称",
  "As", "Cd", "Cr", "Cu", "Hg", "Ni", "Pb", "Zn"
)
```

``` r
# 调色板
# RColorBrewer::brewer.pal(n = 5, name = "Set2")
# 查看颜色
# RColorBrewer::display.brewer.pal(n = 5, name = "Set2")
colorize_factor <- function(x) {
  # 注意因子水平个数
  scales::col_factor(palette = "Set2", levels = unique(x))(x)
}
# 给每个功能区设置一个颜色
dat6 <- transform(dat6, color = colorize_factor(`功能区名称`))
dat6
#     编号 功能区     x     y 海拔 功能区名称       As       Cd        Cr        Cu
# 1      1      4    74   781    5     交通区  4.71111  0.79333  1.478889   2.04444
# 2      2      4  1373   731   11     交通区  2.58889  0.54000  1.561111   2.58611
# 3      3      4  1321  1791   28     交通区  1.44444 10.30667 -0.214444  14.26667
# 4      4      2     0  1787    4     工业区  3.28889  3.13000  1.008889   3.32500
# 5      5      4  1049  2127   12     交通区  3.05556 13.17333  3.150000  28.98056
....
```

查看各个功能区采样点的数量，以及各个功能区的配色。

``` r
aggregate(`编号` ~ color + `功能区名称`, data = dat6, FUN = function(x) length(unique(x)))
#     color 功能区名称 编号
# 1 #66C2A5     交通区  138
# 2 #8DA0CB 公园绿地区   35
# 3 #A6D854       山区   66
# 4 #FC8D62     工业区   36
# 5 #E78AC3     生活区   44
```

采样点在各个功能区的分布情况，如图<a href="#fig:elevation-cloud">28</a>所示，城市地势西南低东北高，西北边界主要分布工业区，交通连接城市各个功能区，东北方向主要是山区。

``` r
library(lattice)
# 绘图涉及中文，调用 showtext 包处理
library(showtext)
showtext_auto()
# 三维分组散点图
cloud(`海拔` ~ x * y,
  data = dat6, pch = 19,
  col = dat6$color, # 散点颜色映射功能区
  # z 轴标签旋转 90 度
  scales = list(
    arrows = FALSE, col = "black",
    z = list(rot = 90)
  ),
  key = list( # 制作图例
    # space = "right",
    corner = c(1.0, 0.5), # 右侧居中
    points = list(col = c("#66C2A5", "#FC8D62", "#8DA0CB", "#E78AC3", "#A6D854"), pch = 19),
    text = list(c("交通区", "工业区", "公园绿地区", "生活区", "山区"))
  ),
  # 减少三维图形的边空
  lattice.options = list(
    layout.widths = list(
      left.padding = list(x = -.6, units = "inches"),
      right.padding = list(x = -1.0, units = "inches")
    ),
    layout.heights = list(
      bottom.padding = list(x = -.8, units = "inches"),
      top.padding = list(x = -1.0, units = "inches")
    )
  ),
  # 设置坐标轴字体大小
  par.settings = list(
    axis.line = list(col = "transparent"),
    fontsize = list(text = 15, points = 10)
  ),
  # 设置三维图的观察方位
  screen = list(z = 30, x = -65, y = 0)
)
```

<figure>
<img src="img/elevation-cloud.png" class="full" alt="图 28: 采样点在城市各个功能区的空间分布" />
<figcaption aria-hidden="true">图 28: 采样点在城市各个功能区的空间分布</figcaption>
</figure>

接下来，根据此数据框 data.frame 类型构造空间数据类型 **sp** （对应 **Sp**atial 类），以便后续调用空间数据分析方法。

``` r
library(sp)
coordinates(dat6) <- ~ x + y
summary(dat6)
# Object of class SpatialPointsDataFrame
# Coordinates:
#   min   max
# x   0 28654
# y   0 18449
# Is projected: NA 
# proj4string : [NA]
# Number of points: 319
# Data attributes:
#       编号           功能区          海拔        功能区名称              As        
#  Min.   :  1.0   Min.   :1.00   Min.   :  0.0   Length:319         Min.   :-2.211  
#  1st Qu.: 80.5   1st Qu.:2.50   1st Qu.: 14.0   Class :character   1st Qu.: 0.189  
#  Median :160.0   Median :4.00   Median : 29.0   Mode  :character   Median : 1.900  
#  Mean   :160.0   Mean   :3.26   Mean   : 42.5                      Mean   : 2.307  
#  3rd Qu.:239.5   3rd Qu.:4.00   3rd Qu.: 55.5                      3rd Qu.: 3.522  
#  Max.   :319.0   Max.   :5.00   Max.   :308.0                      Max.   :29.478  
#        Cd              Cr              Cu              Hg               Ni       
#  Min.   :-3.00   Min.   :-1.74   Min.   : -3.0   Min.   :  -3.3   Min.   :-2.11  
#  1st Qu.: 0.62   1st Qu.: 0.31   1st Qu.:  1.6   1st Qu.:  -0.6   1st Qu.: 0.05  
#  Median : 3.62   Median : 1.22   Median :  4.1   Median :   1.9   Median : 0.97  
#  Mean   : 5.75   Mean   : 2.50   Mean   : 11.6   Mean   :  33.1   Mean   : 1.31  
#  3rd Qu.: 7.97   3rd Qu.: 2.61   3rd Qu.: 11.1   3rd Qu.:   9.7   3rd Qu.: 1.97  
#  Max.   :49.66   Max.   :98.87   Max.   :698.7   Max.   :1995.6   Max.   :34.26  
#        Pb              Zn            color          
#  Min.   :-1.89   Min.   : -2.58   Length:319        
#  1st Qu.: 0.45   1st Qu.:  0.46   Class :character  
#  Median : 2.47   Median :  2.67   Mode  :character  
#  Mean   : 5.12   Mean   :  9.44                     
#  3rd Qu.: 6.68   3rd Qu.:  9.11                     
#  Max.   :73.58   Max.   :263.70
```

``` r
spplot(dat6,
  zcol = c("海拔"),
  main = "",
  as.table = TRUE, # 面板自左上开始
  scales = list(
    draw = TRUE, # 坐标轴刻度
    # 去掉图形上边、右边多余的刻度线
    x = list(alternating = 1, tck = c(1, 0)),
    y = list(alternating = 1, tck = c(1, 0))
  ),
  colorkey = TRUE,
  alpha = 0.7,
  key.space = "right"
)
```

<figure>
<img src="img/elevation-spplot.png" class="full" alt="图 29: 采样点在城市各个功能区的空间分布" />
<figcaption aria-hidden="true">图 29: 采样点在城市各个功能区的空间分布</figcaption>
</figure>

由图<a href="#fig:elevation-spplot">29</a>不难看出，采样点的位置是以图中左下角的点为参照，城市整体上的地势是西南低东北高，城市中间间或有两座小山。

``` r
As <- bubble(dat6, zcol = c("As"), col = c("#4dac26", "#d01c8b"), fill = F, key.space = "bottom")
Cd <- bubble(dat6, zcol = c("Cd"), col = c("#4dac26", "#d01c8b"), fill = F, key.space = "bottom")
Cr <- bubble(dat6, zcol = c("Cr"), col = c("#4dac26", "#d01c8b"), fill = F, key.space = "bottom")
Cu <- bubble(dat6, zcol = c("Cu"), col = c("#4dac26", "#d01c8b"), fill = F, key.space = "bottom")
Hg <- bubble(dat6, zcol = c("Hg"), col = c("#4dac26", "#d01c8b"), fill = F, key.space = "bottom")
Ni <- bubble(dat6, zcol = c("Ni"), col = c("#4dac26", "#d01c8b"), fill = F, key.space = "bottom")
Pb <- bubble(dat6, zcol = c("Pb"), col = c("#4dac26", "#d01c8b"), fill = F, key.space = "bottom")
Zn <- bubble(dat6, zcol = c("Zn"), col = c("#4dac26", "#d01c8b"), fill = F, key.space = "bottom")

# 4 列 2 行，图按列
print(As, split = c(1, 1, 4, 2), more = TRUE)
print(Cd, split = c(1, 2, 4, 2), more = TRUE)
print(Cr, split = c(2, 1, 4, 2), more = TRUE)
print(Cu, split = c(2, 2, 4, 2), more = TRUE)
print(Hg, split = c(3, 1, 4, 2), more = TRUE)
print(Ni, split = c(3, 2, 4, 2), more = TRUE)
print(Pb, split = c(4, 1, 4, 2), more = TRUE)
print(Zn, split = c(4, 2, 4, 2), more = FALSE)
```

<figure>
<img src="img/heavy-metal-concentrations.png" class="full" alt="图 30: 地表土壤重金属浓度分布" />
<figcaption aria-hidden="true">图 30: 地表土壤重金属浓度分布</figcaption>
</figure>

图中，绿色气泡表示重金属浓度低于背景值，红色气泡反之，气泡大小对应不同区间的浓度值，根据浓度值数据的五个分位点划分区间，以砷 As 为例，浓度的分位点如下：

``` r
quantile(dat6$As)
#      0%     25%     50%     75%    100% 
# -2.2111  0.1889  1.9000  3.5222 29.4778
```

现在数据准备好了，通过上述探索，也有了基本的了解，接下来的问题是如何找到城市的重金属污染源？

# 本文小结

空间数据最核心的概念还是几何元素的表示，关系及其应用。
结合地图服务绘图需要注意坐标参考系统及其转化关系 ([Brown 2016](#ref-Brown2016))，同时需要验证/注意地图服务提供的数据的准确性。

R 语言社区在时空数据分析、可视化方面有很多工具，继 [**sp**](https://github.com/edzer/sp) ([E. J. Pebesma and Bivand 2005](#ref-Pebesma2005)) 之后，Edzer Pebesma 开发了 [**sf**](https://github.com/r-spatial/sf) ([E. J. Pebesma 2018](#ref-Pebesma2018))，提供更加高效的矢量空间数据处理方式。紧接着，Robert J. Hijmans 也将处理栅格数据的 [**raster**](https://github.com/rspatial/raster) ([Hijmans 2022a](#ref-raster)) 升级到 [**terra**](https://github.com/rspatial/terra/) ([Hijmans 2022b](#ref-terra))，提供性能强劲且向后兼容性极好的函数接口。[**satellite**](https://github.com/environmentalinformatics-marburg/satellite)包 ([Nauss et al. 2021](#ref-satellite)) 和 **landsat** 包 ([Goslee 2011](#ref-Goslee2011)) 可以处理卫星遥感数据，[**rasterbc**](https://github.com/deankoch/rasterbc) ([Koch 2022](#ref-rasterbc)) 内置 2001-2018 年加拿大英属哥伦比亚省 raster 格式的栅格数据，用于森林生态学研究。

相比于 [**ggplot2**](https://github.com/tidyverse/ggplot2) ([Wickham 2022a](#ref-Wickham2022))，[**lattice**](https://github.com/deepayan/lattice) ([Sarkar 2008](#ref-Sarkar2008)) 是被严重低估的数据可视化包，性能不输 **ggplot2**，而且更加稳定，与上一代空间数据处理框架 **sp** 和 **raster** 有很好的集成。[**ggspatial**](https://github.com/paleolimbot/ggspatial) 提供很多针对空间数据可视化的定制，比如指北针、比例尺等。

[**cartography**](https://github.com/riatelab/cartography) 除了基本的维护，不再添加新的功能，推荐读者转移到 [**mapsf**](https://github.com/riatelab/mapsf) 上。[**mapsf**](https://github.com/riatelab/mapsf) ([Giraud 2022](#ref-mapsf)) 基于 Base R 图形系统将 sf 数据对象绘制在地图上，获得出版级的效果，支持比例气泡图、专题地图和拓扑地图等。[**tmap**](https://github.com/r-tmap/tmap) ([Tennekes 2018](#ref-Tennekes2018)) 功能与之类似，使用方式和 **ggplot2** 提供的图形语法一致。

数据产品很多都基于 Web 呈现，交互式图形成为必须的组件，[**leaflet**](https://github.com/rstudio/leaflet) ([Cheng, Karambelkar, and Xie 2022](#ref-leaflet)) 在交互式地理可视化方面是比较成熟的，中小规模数据集下，性能还不错。 [**mapdeck**](https://github.com/SymbolixAU/mapdeck) 包站在 [deck.gl](https://github.com/visgl/deck.gl) 的肩膀上渲染初具规模的空间数据毫无压力。[**mapview**](https://github.com/r-spatial/mapview) ([Appelhans et al. 2022](#ref-mapview))意在提供快速地交互式探索空间数据的能力，支持 **leaflet** 和 **mapdeck** 渲染方法。而[**mapedit**](https://github.com/r-spatial/mapedit) ([Appelhans, Russell, and Busetto 2020](#ref-mapedit))提供空间数据交互式编辑能力。

# 环境信息

在 RStudio IDE 内编辑本文的 R Markdown 源文件，用 **blogdown** ([Xie, Hill, and Thomas 2017](#ref-Xie2017)) 构建网站，[Hugo](https://github.com/gohugoio/hugo) 渲染 **knitr** 之后的 Markdown 文件，得益于 **blogdown** 对 R Markdown 格式的支持，图、表和参考文献的交叉引用非常方便，省了不少文字编辑功夫。文中使用了多个 R 包，为方便复现本文内容，下面列出详细的环境信息：

``` r
xfun::session_info(packages = c(
  "knitr", "rmarkdown", "blogdown",
  "httr", "jsonlite", "nycflights13",
  "ggmap", "ggplot2", "patchwork", "spData",
  "leaflet", "leafletCN", "leaflet.extras",
  "baidumap", "RgoogleMaps", "mapdeck",
  "geohashTools", "lwgeom", "rgeolocate",
  "lattice", "sf", "terra", "stars",
  "sp", "maps", "raster", "rasterly"
), dependencies = FALSE)
# R version 4.2.0 (2022-04-22)
# Platform: x86_64-apple-darwin17.0 (64-bit)
# Running under: macOS Big Sur/Monterey 10.16
# 
# Locale: en_US.UTF-8 / en_US.UTF-8 / en_US.UTF-8 / C / en_US.UTF-8 / en_US.UTF-8
# 
# Package version:
#   baidumap_0.2.2       blogdown_1.10        geohashTools_0.3.1   ggmap_3.0.0         
#   ggplot2_3.3.6.9000   httr_1.4.3           jsonlite_1.8.0       knitr_1.39          
#   lattice_0.20-45      leaflet_2.1.1        leaflet.extras_1.0.0 leafletCN_0.2.1     
#   lwgeom_0.2-8         mapdeck_0.3.4        maps_3.4.0           nycflights13_1.0.2  
#   patchwork_1.1.1      raster_3.5.15        rasterly_0.2.0       rgeolocate_1.4.2    
#   RgoogleMaps_1.4.5.3  rmarkdown_2.14       sf_1.0-7             sp_1.4-7            
#   spData_2.0.1         stars_0.5.5          terra_1.5.21        
# 
# Pandoc version: 2.18
# 
# Hugo version: 0.98.0
```

# 参考文献

<div id="refs" class="references csl-bib-body hanging-indent">

<div id="ref-mapview" class="csl-entry">

Appelhans, Tim, Florian Detsch, Christoph Reudenbach, and Stefan Woellauer. 2022. *Mapview: Interactive Viewing of Spatial Data in r*. <https://github.com/r-spatial/mapview>.

</div>

<div id="ref-mapedit" class="csl-entry">

Appelhans, Tim, Kenton Russell, and Lorenzo Busetto. 2020. *Mapedit: Interactive Editing of Spatial Data in r*. <https://github.com/r-spatial/mapedit>.

</div>

<div id="ref-Brown2016" class="csl-entry">

Brown, Patrick E. 2016. “Maps, Coordinate Reference Systems and Visualising Geographic Data with <span class="nocase">mapmisc</span>.” *R Journal* 8 (1): 64–91. <https://journal.r-project.org/archive/2016-1/brown.pdf>.

</div>

<div id="ref-maps" class="csl-entry">

Brownrigg, Ray. 2021. *Maps: Draw Geographical Maps*. <https://CRAN.R-project.org/package=maps>.

</div>

<div id="ref-leaflet" class="csl-entry">

Cheng, Joe, Bhaskar Karambelkar, and Yihui Xie. 2022. *Leaflet: Create Interactive Web Maps with the JavaScript Leaflet Library*. <https://rstudio.github.io/leaflet/>.

</div>

<div id="ref-geohashTools" class="csl-entry">

Chirico, Michael. 2020. *geohashTools: Tools for Working with Geohashes*. <https://github.com/MichaelChirico/geohashTools>.

</div>

<div id="ref-sfheaders" class="csl-entry">

Cooley, David. 2020. *Sfheaders: Converts Between r Objects and Simple Feature Objects*. <https://dcooley.github.io/sfheaders/>.

</div>

<div id="ref-mapsf" class="csl-entry">

Giraud, Timothée. 2022. *Mapsf: Thematic Cartography*. <https://CRAN.R-project.org/package=mapsf>.

</div>

<div id="ref-Goslee2011" class="csl-entry">

Goslee, Sarah C. 2011. “Analyzing Remote Sensing Data in R: The <span class="nocase">landsat</span> Package.” *Journal of Statistical Software* 43 (4): 1–25. <http://www.jstatsoft.org/v43/i04/>.

</div>

<div id="ref-raster" class="csl-entry">

Hijmans, Robert J. 2022a. *Raster: Geographic Data Analysis and Modeling*. <https://rspatial.org/raster>.

</div>

<div id="ref-terra" class="csl-entry">

———. 2022b. *Terra: Spatial Data Analysis*. <https://rspatial.org/terra/>.

</div>

<div id="ref-Kahle2013" class="csl-entry">

Kahle, David, and Hadley Wickham. 2013. “<span class="nocase">ggmap</span>: Spatial Visualization with <span class="nocase">ggplot2</span>.” *The R Journal* 5 (1): 144–61. <https://journal.r-project.org/archive/2013-1/kahle-wickham.pdf>.

</div>

<div id="ref-rgeolocate" class="csl-entry">

Keyes, Os, Drew Schmidt, David Robinson, Chris Davis, Bob Rudis, Maxmind, Inc., Pascal Gloor, and IP2Location.com. 2021. *Rgeolocate: IP Address Geolocation*. <https://CRAN.R-project.org/package=rgeolocate>.

</div>

<div id="ref-rasterbc" class="csl-entry">

Koch, Dean. 2022. *Rasterbc: Access Forest Ecology Layers for British Columbia in 2001-2018*. <https://CRAN.R-project.org/package=rasterbc>.

</div>

<div id="ref-leafletCN" class="csl-entry">

Lang, Dawei. 2017. *leafletCN: An r Gallery for China and Other Geojson Choropleth Map in Leaflet*. <https://CRAN.R-project.org/package=leafletCN>.

</div>

<div id="ref-Loecher2015" class="csl-entry">

Loecher, Markus, and Karl Ropkins. 2015. “RgoogleMaps and <span class="nocase">loa</span>: Unleashing R Graphics Power on Map Tiles.” *Journal of Statistical Software* 63 (4): 1–18. <http://www.jstatsoft.org/v63/i04/>.

</div>

<div id="ref-satellite" class="csl-entry">

Nauss, Thomas, Hanna Meyer, Tim Appelhans, and Florian Detsch. 2021. *Satellite: Handling and Manipulating Remote Sensing Data*. <https://CRAN.R-project.org/package=satellite>.

</div>

<div id="ref-lwgeom" class="csl-entry">

Pebesma, Edzer. 2021. *Lwgeom: Bindings to Selected Liblwgeom Functions for Simple Features*. <https://github.com/r-spatial/lwgeom/>.

</div>

<div id="ref-sf" class="csl-entry">

———. 2022. *Sf: Simple Features for r*. <https://CRAN.R-project.org/package=sf>.

</div>

<div id="ref-Pebesma2018" class="csl-entry">

Pebesma, Edzer J. 2018. “<span class="nocase">Simple Features for R: Standardized Support for Spatial Vector Data</span>.” *The R Journal* 10 (1): 439–46. <https://doi.org/10.32614/RJ-2018-009>.

</div>

<div id="ref-Pebesma2005" class="csl-entry">

Pebesma, Edzer J., and Roger S. Bivand. 2005. “Classes and Methods for Spatial Data in R.” *R News* 5 (2): 9–13. <https://CRAN.R-project.org/doc/Rnews/>.

</div>

<div id="ref-loa" class="csl-entry">

Ropkins, Karl. 2021. *Loa: Lattice Options and Add-Ins*. <http://loa.r-forge.r-project.org/loa.intro.html>.

</div>

<div id="ref-Sarkar2008" class="csl-entry">

Sarkar, Deepayan. 2008. *<span class="nocase">lattice</span>: Multivariate Data Visualization with R*. New York: Springer-Verlag. <http://lmdvr.r-forge.r-project.org>.

</div>

<div id="ref-latticeExtra" class="csl-entry">

Sarkar, Deepayan, and Felix Andrews. 2019. *latticeExtra: Extra Graphical Utilities Based on Lattice*. <http://latticeextra.r-forge.r-project.org/>.

</div>

<div id="ref-Tennekes2018" class="csl-entry">

Tennekes, Martijn. 2018. “<span class="nocase">tmap</span>: Thematic Maps in R.” *Journal of Statistical Software* 84 (6): 1–39. <https://doi.org/10.18637/jss.v084.i06>.

</div>

<div id="ref-nycflights13" class="csl-entry">

Wickham, Hadley. 2021. *Nycflights13: Flights That Departed NYC in 2013*. <https://github.com/hadley/nycflights13>.

</div>

<div id="ref-Wickham2022" class="csl-entry">

———. 2022a. *<span class="nocase">ggplot2</span>: Elegant Graphics for Data Analysis*. 3rd ed. Springer-Verlag New York. <https://ggplot2-book.org/>.

</div>

<div id="ref-httr" class="csl-entry">

———. 2022b. *Httr: Tools for Working with URLs and HTTP*. <https://CRAN.R-project.org/package=httr>.

</div>

<div id="ref-Xie2017" class="csl-entry">

Xie, Yihui, Alison Presmanes Hill, and Amber Thomas. 2017. *<span class="nocase">blogdown</span>: Creating Websites with R Markdown*. Boca Raton, Florida: Chapman; Hall/CRC. <https://bookdown.org/yihui/blogdown/>.

</div>

</div>

[^1]: [ipinfo](https://github.com/ipinfo) 工具是开源可商用的，由前 Facebook 工程师 Ben Dowling 于 2013 年创建，后来发展成 IPinfo 公司，专门提供 IP 定位服务，服务的公司包括腾讯、戴尔、耐克等。

[^2]: 查看示例可以看到源数据的地址， 其它示例数据可以通过类似的方法获取，比如点图层中的全国点效果示例：

    ``` bash
    curl -fLo chinalocation.json https://mapv.baidu.com/gl/examples/data/chinalocation.json
    ```
