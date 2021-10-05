---
title: 画个地图，我容易么！
author: 黄湘云
date: '2019-07-21'
slug: rongelap-map
categories:
  - 统计图形
tags:
  - ggplot2
  - raster
  - sp
description: "空间数据分析和建模的怕是离不开画地图，本文尝试几乎所有画图手段让你明白掌握原始数据的重要性，数据处理的坑有多深！如果基于别人文章中加工过的数据，想做进一步的探索是很难的，只有沿着前人走过的路，把算法提升下，这是很多人的路子，复现也是很有希望的，新花样就别想了！哪有那么好的事情让你在别人的数据集上做出新模型、新算法的同时创新！"
---

事情源起于复现一篇论文

# 作者主页

数据集来源 Paulo Justiniano Ribeiro Jr 的主页 <http://www.leg.ufpr.br>

```r
rongelap <- read.table(
  file =
    paste("http://www.leg.ufpr.br/lib/exe/fetch.php",
      "pessoais:paulojus:mbgbook:datasets:rongelap.txt",
      sep = "/"
    ), header = TRUE
)
plot(cY ~ cX, data = rongelap)
```

![源起论文供图](https://wp-contents.netlify.com/2019/07/rongelap.png)

我想添加个边界信息，但是这个数据源不知道采用了什么坐标参考系，作者没有说明。

# 求助 R 包

经过一番搜索，我发现 geostatsp 包提供了一份 UTM 参考系下的数据，有些小激动，跃跃欲试，心想，先找来 mapdata 包内的边界信息，再把该岛采样点信息加上

```r
library(maps)
library(mapdata)
library(ggplot2)
mhl_map <- map_data(map = "worldHires", region = "Marshall Islands") 

# Marshall Islands 马绍尔群岛
ggplot(fortify(mhl_map), aes(x = long, y = lat)) +
  geom_polygon(aes(group = group, fill = group), show.legend = FALSE) +
  coord_map() +
  theme_minimal()
  
# 用 geom_path 还可以看到黑点
ggplot(fortify(mhl_map), aes(x = long, y = lat)) +
  geom_path(aes(group = group)) +
  coord_map() +
  theme_minimal()  
```

![马绍尔群岛](https://wp-contents.netlify.com/2019/07/marshall-islands.png)

毕竟都是些岛屿，在整个马绍尔群岛里，朗格拉普岛都看不到了，事实上，不止朗格拉普岛，不仔细看，什么岛都没有，岛屿的大小和群岛横跨的经纬度相比可以忽略！！ 所以，接下来单独把朗格拉普岛的边界数据画出来

```r
# Rongelap Atoll
rongelap_map <- subset(mhl_map, subregion == "Rongelap Atoll")
ggplot(fortify(rongelap_map), aes(x = long, y = lat)) +
  geom_path(aes(group = group)) +
  coord_map()
```

![朗格拉普岛](https://wp-contents.netlify.com/2019/07/rongelap-islands.png)

关于朗格拉普岛的边界太粗略了，这样的边界信息何堪再用！所以，接下来要寻找更加精细的边界，首先想到的是 [GADM 网站](https://gadm.org) 提供的数据集，继续探索！

# GADM

根据维基百科资料显示 [朗格拉普岛](https://en.wikipedia.org/wiki/Rongelap_Atoll) 是马绍尔群岛共和国（ISO3 国家代码是 MHL）的一部分，所以先下载 MHL，到了网站 <https://gadm.org/download_country_v3.html> 我发现只提供了 level 0 的数据，即国家和地区级行政边界。这显然不够，但是转念一想，可以根据 rongelapUTM 坐标在 马绍尔群岛上圈出来。现在开始下载数据，这些数据的坐标是 [经纬度](https://en.wikipedia.org/wiki/Geographic_coordinate_system)，参考系是 [WGS84](https://en.wikipedia.org/wiki/World_Geodetic_System) 即 World Geodetic System 翻译过来叫世界大地测量系统，制定于1984年，全球定位系统就使用该坐标系。

```r
library(sp)
library(raster)
mhl_map <- getData('GADM', country = 'MHL', level = 0)
mhl_map@data
```
```
       GID_0           NAME_0
260010   MHL Marshall Islands
```

这就是 `level = 0` 的数据特点，里面的岛屿是不能分割出来的！快速预览一下

```r
plot(mhl_map, axes = T)
```

![马绍尔群岛GADM](https://wp-contents.netlify.com/2019/07/sp-mhl-map.png)

维基百科上有马绍尔群岛的图示

![维基马绍尔群岛](https://upload.wikimedia.org/wikipedia/commons/c/ca/Marshall_islands-map.png)

看起来有点希望！根据 `rongelapUTM` 的坐标信息，可以从 `mhl_map` 截出一部分来，再将`rongelapUTM`中的投影坐标系 UTM 转化为地理坐标系 WGS84 即可画图，

```r
data("rongelapUTM", package = "geostatsp") 
class(rongelapUTM)
```
```
[1] "SpatialPointsDataFrame"
attr(,"package")
[1] "sp"
```

geostatsp 包作者已将 rongelap 数据集打包成 sp 类型数据对象，下面查看一下

```r
rongelapUTM@data
```
```
           x       y count time
1   700900.3 1233469    75  300
2   700913.7 1233573   371  300
3   701017.9 1233403  1931  300
4   701037.6 1233557  4357  300
中间省略
154 707117.5 1235949 12278 1800
155 707144.7 1235138  1248  300
156 707190.0 1235334  1074  200
157 707215.4 1235533  1205  200
```

为了不污染原始数据，拷贝一份

```r
rongelapWGS84 <- rongelapUTM
```

坐标参考系转化

```r
library(rgdal) 
sps <- SpatialPoints(rongelapWGS84@data[, c("x", "y")], proj4string = CRS("+proj=utm +zone=28"))
spst <- spTransform(sps, CRS("+proj=longlat +datum=WGS84"))
rongelapWGS84@data[, c("long", "lat")] <- coordinates(spst)
```

查看转化前后的坐标

```r
rongelapWGS84@data
```
```
           x       y count time      long      lat
1   700900.3 1233469    75  300 -13.16033 11.15253
2   700913.7 1233573   371  300 -13.16021 11.15347
3   701017.9 1233403  1931  300 -13.15926 11.15193
中间省略
155 707144.7 1235138  1248  300 -13.10308 11.16727
156 707190.0 1235334  1074  200 -13.10265 11.16903
157 707215.4 1235533  1205  200 -13.10241 11.17082
```

吊诡的是转化后的坐标压根没有出现在马绍尔群岛共和国内！！这说明geostatsp包内置的rongelapUTM数据可能不是 UTM 坐标参考系，画图再确认一下，你看

```r
ggplot(fortify(mhl_map), aes(x = long, y = lat)) +
  geom_path(aes(group = group)) +
  coord_map()
```

![马绍尔群岛GADM-ggplot2](https://wp-contents.netlify.com/2019/07/mhl-map.png)

若是把采样点加上，没法看了，添加背景的意义不在了！

```r
ggplot(fortify(mhl_map), aes(x = long, y = lat)) +
  geom_path(aes(group = group)) +
  geom_point(data = as.data.frame(rongelapWGS84), aes(x = long,y = lat)) +
  xlim(-14, 175)
```

# leaflet

接下来使用 leaflet 却定位到非洲了，所以要搞清楚 leaflet 使用的坐标参照系，但是更大的可能性是rongelapUTM本身的坐标是错误的。[Leaflet 坐标参考系](https://rstudio.github.io/leaflet/projections.html) 默认是 [EPSG:3857](https://epsg.io/3857)，图中放射强度为单位时间内放射的粒子数目，即 `count / time`，因为数据不对，画在这也不好看！

```r
library(leaflet)
pal <- colorBin("Spectral", bins = c(0, 3, 6, 9, 12, 15, 20), reverse = TRUE)
leaflet(rongelapWGS84@data) %>%
  addProviderTiles(providers$CartoDB.Positron) %>%
  addCircles(lng = ~long, lat = ~lat, color = ~pal(count / time)) %>%
  addLegend("bottomright",
    pal = pal, values = ~count / time,
    title = "放射强度"
  ) %>%
  addScaleBar(position = c("bottomleft"))
```

事实上，在 leaflet 地图中，朗格拉普到的所处位置范围是 `bbox = c(166.835,11.145,166.900,11.185)` 和 mapdata 包内置的地图数据是吻合的，和 GADM 提供的数据也是吻合的！所以问题就出现在 rongelapUTM 数据集上，它的坐标是如何转化得来的？暂时不得而知

```r
library(leaflet)
data(quakes)
pal <- colorBin("Spectral", bins = c(4, 4.5, 5.0, 5.5, 6.5), reverse = TRUE)
p <- leaflet(quakes) %>%
  addProviderTiles(providers$CartoDB.Positron) %>%
  addCircles(lng = ~long, lat = ~lat, color = ~pal(mag)) %>%
  addLegend("bottomright",
    pal = pal, values = ~mag,
    title = "地震震级"
  ) %>%
  addScaleBar(position = c("bottomleft"))
# 保存
library(htmlwidgets)
saveWidget(p, "fiji-map.html", selfcontained = T)
```
<center>
<iframe seamless src="https://wp-contents.netlify.com/2019/07/fiji-map.html" width="70%" height="500" frameborder="0"></iframe>
</center>

从图中不难看出 R 内置的斐济地震数据所含坐标和 leaflet 的坐标参考系也是一致

> 掌握原始数据的重要性不言而喻，数据处理的坑有多深也毋庸赘言！

所以最终根据 leaflet 找到朗格拉普岛的边界，基于 GADM 的国界数据，从马绍尔群岛中框出朗格拉普岛的范围

```r
library(sp)
library(raster)
mhl_map <- getData("GADM", country = "MHL", level = 0)
plot(mhl_map, axes = T)
# 边界
bbox(mhl_map)
# 画图
png(
  filename = "rongelap.png", res = 200, width = 480 * 200 / 72, height = 480 * 200 / 72,
  type = "cairo", bg = "transparent"
)
par(mar = c(4, 4, 2.5, 0.5))
plot(mhl_map,
  xlim = c(166.835, 166.900), ylim = c(11.145, 11.185),
  axes = T, xlab = "经度", ylab = "纬度", main = "朗格拉普岛", family = "GB1"
)
dev.off()
```

![朗格拉普岛最终版](https://wp-contents.netlify.com/2019/07/rongelap-final.png)

但是数据集 rongelapUTM 包含的信息是加不上了，因为里面的坐标系未知！

# 画中国地图

> GADM 上中国地图数据不是合在一块的，港澳台地区需要合并进来

下载中国大陆、香港、澳门和台湾地区的地图数据

```r
library(sp)
library(raster)
china_mainland_map <- getData('GADM', country='CHN', level=1)
hongkong_map <- getData('GADM', country='HKG', level=1)
macao_map <- getData('GADM', country='MAC', level=1)
taiwan_map <- getData('GADM', country='TWN', level=1)
```

合并 sp 对象

```r
china_map <- rbind(china_mainland_map, hongkong_map, macao_map, taiwan_map)
plot(china_map, axes = TRUE)
```

![中国地图边界](https://wp-contents.netlify.com/2019/07/sp-china-map.png)

观察 sp 对象

```r
# 字段
names(china_map)
```
```
 [1] "GID_0"     "NAME_0"    "GID_1"     "NAME_1"    "VARNAME_1" "NL_NAME_1"
 [7] "TYPE_1"    "ENGTYPE_1" "CC_1"      "HASC_1"  
```

```r
# 数据
china_map@data
```
```
   GID_0 NAME_0   GID_1    NAME_1 VARNAME_1 NL_NAME_1    TYPE_1    ENGTYPE_1 CC_1 HASC_1
1    CHN  China CHN.1_1     Anhui     ānhuī 安徽|安徽     Shěng     Province <NA>  CN.AH
12   CHN  China CHN.2_1   Beijing   Běijīng 北京|北京 Zhíxiáshì Municipality <NA>  CN.BJ
23   CHN  China CHN.3_1 Chongqing Chóngqìng 重慶|重庆 Zhíxiáshì Municipality <NA>  CN.CQ
中间省略
211   TWN Taiwan TWN.2_1  Kaohsiung            Gaoxiong      高雄 Zhíxiáshì Special Municipality <NA>  TW.KH
32    TWN Taiwan TWN.3_1 New Taipei                <NA>      新北 Zhíxiáshì Special Municipality <NA>  TW.NT
41    TWN Taiwan TWN.4_1   Taichung                <NA>      台中 Zhíxiáshì Special Municipality <NA>  TW.TG
51    TWN Taiwan TWN.5_1     Tainan                <NA>      台南 Zhíxiáshì Special Municipality <NA>  TW.TN
61    TWN Taiwan TWN.6_1     Taipei Taibei|Taipé|Taipeh      台北 Zhíxiáshì Special Municipality <NA>  TW.TP
71    TWN Taiwan TWN.7_1     Taiwan                <NA>      台灣     Shěng             Province <NA>  TW.TA
```

`china_map$NAME_0` 是国家和地区级的全称，`china_map$GID_0` 是国家和地区级的缩写，`china_map$GID_1` 所属编号，`china_map$NAME_1` 是省级名称，`china_map$VARNAME_1` 是省级汉语拼音

S4 对象类型数据的访问，用 `@` 而不是 `$`

```r
china_map@data        
china_map@polygons    
china_map@plotOrder   
china_map@bbox        
china_map@proj4string
```

完整的中国地图

```r
library(ggplot2)
china_map_df = fortify(china_map, region = "NAME_1") # 需要一些时间转化
ggplot(china_map_df, aes(x = long, y = lat)) + geom_path(aes(group = group))
```

![中国地图](https://wp-contents.netlify.com/2019/07/ggplot2-china-map.png)

取其中一部分绘制，如北京市

```r
# beijing_map = subset(china_map_df, grepl("Beijing", group))
beijing_map = subset(china_map_df, id == "Beijing")
ggplot(beijing_map, aes(x = long, y = lat)) + 
  geom_path(aes(group = group))
```

![北京市地图](https://wp-contents.netlify.com/2019/07/beijing-map.png)

给中国地图填充颜色

```r
ggplot(china_map, aes(x = long, y = lat)) + 
  geom_polygon(aes(group = group,fill = group), show.legend = FALSE)
```

![彩色的中国地图](https://wp-contents.netlify.com/2019/07/china-map.png)

# 运行环境

```r
xfun::session_info(packages = c(
  "geostatsp", "sp", "raster",
  "ggplot2", "maps", "mapdata",
  "rgdal", "rgdal"
))
```
```
R version 3.6.1 (2019-07-05)
Platform: x86_64-w64-mingw32/x64 (64-bit)
Running under: Windows 8.1 x64 (build 9600)

Locale:
  LC_COLLATE=Chinese (Simplified)_China.936 
  LC_CTYPE=Chinese (Simplified)_China.936   
  LC_MONETARY=Chinese (Simplified)_China.936
  LC_NUMERIC=C                              
  LC_TIME=Chinese (Simplified)_China.936    

Package version:
  abind_1.4.7         assertthat_0.2.1    backports_1.1.4    
  cli_1.1.0           colorspace_1.4.1    crayon_1.3.4       
  digest_0.6.20       ellipsis_0.2.0.1    fansi_0.4.0        
  geostatsp_1.7.8     ggplot2_3.2.0       glue_1.3.1         
  graphics_3.6.1      grDevices_3.6.1     grid_3.6.1         
  gtable_0.3.0        labeling_0.3        lattice_0.20.38    
  lazyeval_0.2.2      magrittr_1.5        mapdata_2.3.0      
  maps_3.3.0          MASS_7.3.51.4       Matrix_1.2.17      
  methods_3.6.1       mgcv_1.8.28         munsell_0.5.0      
  nlme_3.1.140        numDeriv_2016.8.1.1 pillar_1.4.2       
  pkgconfig_2.0.2     plyr_1.8.4          R6_2.4.0           
  raster_2.9-23       RColorBrewer_1.1.2  Rcpp_1.0.2         
  reshape2_1.4.3      rlang_0.4.0         scales_1.0.0       
  sp_1.3-1            splines_3.6.0       stats_3.6.1        
  stringi_1.4.3       stringr_1.4.0       tibble_2.1.3       
  tools_3.6.1         utf8_1.1.4          utils_3.6.1        
  vctrs_0.2.0         viridisLite_0.3.0   withr_2.1.2        
  zeallot_0.1.0      
```

## 附录

既然文中提到了如何保存 html 格式图片的问题，下面这个是保存 rgl 图形的方式

```r
library(htmlwidgets)
library(rgl)
plot3d(iris$Sepal.Length, iris$Sepal.Width, iris$Petal.Length,
       type = "s", col = hcl.colors(3)[unclass(iris$Species)])
# 要求安装 pandoc 软件和 rmarkdown 包
htmlwidgets::saveWidget(rglwidget(width = 500, height = 500), "iris-rgl.html")
```

<center>
<iframe seamless src="https://wp-contents.netlify.com/2019/07/iris-rgl.html" height="600" width="600" frameborder="0"></iframe>
</center>
