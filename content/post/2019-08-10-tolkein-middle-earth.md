---
title: 托尔金小说里的中土世界
author: 黄湘云
date: '2019-08-10'
slug: tolkein-middle-earth
categories:
  - 统计图形
tags: 
  - 空间数据可视化
draft: true
description: "本文的目的是 Tolkein's Middle Earth 托尔金小说中的中土世界 --- 基于[ME-GIS数据集](https://github.com/jvangeld/ME-GIS)学习 ggplot2 可视化 sf 对象。因此，主要介绍 sf 对象，已经存在 sp 和 raster 对象，为什么还要 sf 对象？"
---

Tolkein's Middle Earth 即托尔金小说中的中土世界，系列小说包括《魔戒》、《霍比特人》和《指环王》。本文的目的就是基于 [ME-GIS数据集](https://github.com/jvangeld/ME-GIS) 学习 ggplot2  可视化 sf 对象

```r
# copy and modified from https://www.r-chart.com/2016/10/map-of-middle-earth-map-above-was.html
library(ggplot2)
library(maptools) # rgdal  sf
# 切换到数据文件所在的目录
setwd('/path/to/downloaded/ME-GIS/')
# 读取数据文件
contours <- readShapeSpatial('Contours_18.shp') # 轮廓
coastline <- readShapeSpatial('Coastline2.shp') # 海岸线
forests <- readShapeSpatial('Forests.shp') # 森林
lakes <- readShapeSpatial('Lakes2.shp') # 湖泊
rivers <- readShapeSpatial('Rivers19.shp') # 河流

# 画图
middle_map <- ggplot() +
  geom_polygon(data = fortify(contours), 
               aes(x = long, y = lat, group = group),
               color = '#f0f0f0', fill='#f0f0f0', size = .2) +
  geom_path(data = fortify(coastline), 
            aes(x = long, y = lat, group = group),
            color = 'black', size = .2) +
  geom_polygon(data = fortify(forests), 
               aes(x = long, y = lat, group = group),
               color = '#31a354', fill='#31a354', size = .2) +
  geom_polygon(data = fortify(lakes), 
               aes(x = long, y = lat, group = group),
               color = '#a6bddb', fill='#a6bddb', size = .2) +
  geom_path(data = fortify(rivers), 
            aes(x = long, y = lat, group = group),
            color = '#a6bddb', size = .2) + 
  scale_x_continuous(labels = scales::unit_format(unit = "km", scale = 1e-3)) +
  scale_y_continuous(labels = scales::unit_format(unit = "km", scale = 1e-3)) +
  labs(title = 'Middle Earth', x = 'Shapefiles: https://github.com/jvangeld/ME-GIS', y = '')
# 保存图
pdf(file = 'midddle-map.pdf') 
print(middle_map)
dev.off()
```

![tolkein-middle-earth](https://wp-contents.netlify.com/2019/08/tolkein-middle-earth.png)

```r
library(ggplot2)
library(sf)
# 读取数据文件
contours <- sf::st_read('Contours_18.shp')
coastline <- sf::st_read('Coastline2.shp')
forests <- sf::st_read('Forests.shp')
lakes <- sf::st_read('Lakes2.shp')
rivers <- sf::st_read('Rivers19.shp')

png(filename = "tolkein-middle-earth-sf.png", width = 10*80, height = 10*80, res = 150, type = "cairo")
# 画图
ggplot() +
  geom_sf(data = contours, color = '#f0f0f0', fill='#f0f0f0') +
  geom_sf(data = coastline, color = 'black') +
  geom_sf(data = forests, color = '#31a354', fill='#31a354') +
  geom_sf(data = lakes, color = '#a6bddb', fill='#a6bddb') +
  geom_sf(data = rivers, color = '#a6bddb')
dev.off()
```

![Tolkein's Mmiddle Earth sf](https://wp-contents.netlify.com/2019/08/tolkein-middle-earth-sf.png)

## 小结

相比而言，sf 有极快的处理速度， ggplot2 的 `geom_sf` 也有极快的渲染速度。maptools 包读取 `*.shp` 文件的方式也不推荐，已伴随警告，将来会退出历史舞台。


## 运行环境

```r
sessionInfo()
```
```
R version 3.6.1 (2019-07-05)
Platform: x86_64-w64-mingw32/x64 (64-bit)
Running under: Windows 8.1 x64 (build 9600)

Matrix products: default

locale:
[1] LC_COLLATE=Chinese (Simplified)_China.936 
[2] LC_CTYPE=Chinese (Simplified)_China.936   
[3] LC_MONETARY=Chinese (Simplified)_China.936
[4] LC_NUMERIC=C                              
[5] LC_TIME=Chinese (Simplified)_China.936    

attached base packages:
[1] stats     graphics  grDevices utils     datasets  methods   base     

other attached packages:
[1] sf_0.7-7      ggplot2_3.2.0

loaded via a namespace (and not attached):
 [1] Rcpp_1.0.2         class_7.3-15       withr_2.1.2       
 [4] crayon_1.3.4       dplyr_0.8.3        assertthat_0.2.1  
 [7] grid_3.6.1         R6_2.4.0           DBI_1.0.0         
[10] gtable_0.3.0       magrittr_1.5       units_0.6-3       
[13] e1071_1.7-2        scales_1.0.0       KernSmooth_2.23-15
[16] pillar_1.4.2       rlang_0.4.0        lazyeval_0.2.2    
[19] tools_3.6.1        glue_1.3.1         purrr_0.3.2       
[22] munsell_0.5.0      compiler_3.6.1     pkgconfig_2.0.2   
[25] colorspace_1.4-1   classInt_0.4-1     tidyselect_0.2.5  
[28] tibble_2.1.3      
```

## 参考文献

1. 中土世界的高程数据集来自 <https://github.com/jvangeld/ME-GIS>

1. 代码来自 <https://www.r-chart.com/2016/10/map-of-middle-earth-map-above-was.html>

1. 中土世界 <https://en.wikipedia.org/wiki/Middle-earth>

1. 更多关于 sf 和 ggplot2 的作图介绍 <https://github.com/melimore86/ggplot2-sf>
