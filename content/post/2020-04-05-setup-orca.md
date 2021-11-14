---
date: "2020-04-05"
slug: setup-orca
title: 安装配置 orca
categories:
  - 统计软件
tags:
  - plotly
  - orca
toc: true
---

[plotly.js](https://github.com/plotly/plotly.js) 是以 MIT 协议发布的，允许商业用途，所以无论是在开源社区还是在商业公司，它都有很大的用户群。加之，它的 R 接口 [plotly](https://github.com/ropensci/plotly) 功能非常丰富，可以方便地从 ggplot2 图形渲染出动态图形，可以和 shiny 无缝结合，作为 [Carson Sievert](https://cpsievert.me/) 的成名器[^jsm-plotly]，一致处于活跃维护中[^update-plotly]。

[^update-plotly]: JS 库的迭代更新非常快，活跃维护一个这样的 R 包，需要持续地投入时间精力，才能保持其生命力，这是一件很不容易的事！
[^jsm-plotly]: Carson Sievert 正是凭借 plotly 获得 2017 年 [John M. Chambers](https://statweb.stanford.edu/~jmc4/vitae.html) 统计软件奖 <http://stat-computing.org/awards/jmc/winners.html> 。

> 注意
>
> 软件配置环境： Fedora 29，适用于红帽系的操作系统，其它系统环境参照修改即可，详见 <https://github.com/plotly/orca>。截至写作时间，最新版 orca 是 1.3.1，介绍 orca 的起因是在 plotly 大受欢迎的背景下，如何导出为各种格式的高质量图形以适应出版发行的需要，配置过程相对麻烦，故而写了这么一篇短文。


# 常用配置过程 {#common-setup}

运行 orca 需要一些系统依赖

```bash
sudo dnf install -y fuse
```

准备存放位置

```bash
# 创建目录
sudo mkdir -p /opt/orca
# 给当前登陆用户权限
sudo chown -R $(whoami):$(whoami) /opt/orca
```

下载 orca-1.3.1.AppImage 到上面准备好的目录下 `/opt/orca`

```bash
curl -fLo /opt/orca/orca-1.3.1.AppImage https://github.com/plotly/orca/releases/download/v1.3.1/orca-1.3.1.AppImage
```

添加执行权限

```bash
chmod +x /opt/orca/orca-1.3.1.AppImage
```

添加软链接，相当于快捷方式[^rm-link]

```bash
sudo ln -s /opt/orca/orca-1.3.1.AppImage /usr/local/bin/orca
```

[^rm-link]: 移除软链接，只需 `rm -rf /usr/local/bin/orca`

查看状态

```bash
which orca
orca --help
```

# 在服务器上配置 {#server-setup}

orca 需要 x11 显示器，服务器黑乎乎的界面，一般是不安装图形界面的。所以需要 xvfb，本文以 Fedora 29 为例，安装 xorg-x11-server-Xvfb 即可

```bash
sudo dnf install -y xorg-x11-server-Xvfb
```

在服务器系统上安装，在目录 `/opt/orca/` 下创建 `orca.sh` 文件，文件内容如下

```bash
#!/bin/bash
xvfb-run -a /opt/orca/orca-1.3.1.AppImage "$@"
```

添加执行权限

```bash
chmod +x /opt/orca/orca.sh
```

创建新的软链接

```bash
sudo ln -s /opt/orca/orca.sh  /usr/local/bin/orca
```

# 在命令行中测试 {#test-in-cmd}

```bash
# 导出为 png 格式
orca graph '{ "data": [{"y": [1,2,1]}] }' -o demo.png
# 导出为 svg 格式
orca graph '{ "data": [{"y": [1,2,1]}] }' --format svg -o demo.svg
```

![demo](https://user-images.githubusercontent.com/12031874/78466574-1e16bc80-7735-11ea-889a-95510b3dfaec.png)

```bash
# 网速好就可以在线方式
orca graph https://plot.ly/~empet/14324.json --format svg -o sunpy-image.svg
```

推荐先下载下来，因为这个 JSON 文件大约 70M 

```bash
# 下载文件
wget https://plotly.com/~empet/14324.json
# 导出图形
orca graph ./14324.json --format svg  -o sunpy-image.svg
```

效果图如下

![sunpy-image](https://user-images.githubusercontent.com/12031874/78466578-2969e800-7735-11ea-9a51-2d4ca8e0474e.png)


# 在 R 环境中测试 {#test-in-r}

检查 orca 工具是否就绪

```r
plotly:::orca_available()
[1] TRUE
```

就绪后，测试

```r
library(plotly)
(p <- plot_ly(x = c(0,1,2), y = c(1,2,1), color = I("orange"), type = "scatter", mode = "lines+markers+text"))
```

导出图形

```r
orca(p, "demo.svg")
```

# 运行环境 {#session-info}

```r
sessionInfo()
```
```
R version 3.6.1 (2019-07-05)
Platform: x86_64-redhat-linux-gnu (64-bit)
Running under: Fedora 29 (Twenty Nine)

Matrix products: default
BLAS/LAPACK: /usr/lib64/R/lib/libRblas.so

locale:
 [1] LC_CTYPE=zh_CN.UTF-8       LC_NUMERIC=C              
 [3] LC_TIME=zh_CN.UTF-8        LC_COLLATE=zh_CN.UTF-8    
 [5] LC_MONETARY=zh_CN.UTF-8    LC_MESSAGES=zh_CN.UTF-8   
 [7] LC_PAPER=zh_CN.UTF-8       LC_NAME=C                 
 [9] LC_ADDRESS=C               LC_TELEPHONE=C            
[11] LC_MEASUREMENT=zh_CN.UTF-8 LC_IDENTIFICATION=C       

attached base packages:
[1] stats     graphics  grDevices utils     datasets  methods   base     

other attached packages:
[1] plotly_4.9.2.1 ggplot2_3.3.0 

loaded via a namespace (and not attached):
 [1] Rcpp_1.0.4        magrittr_1.5      colorout_1.2-2    tidyselect_1.0.0 
 [5] munsell_0.5.0     viridisLite_0.3.0 colorspace_1.4-1  R6_2.4.1         
 [9] rlang_0.4.5.9000  fansi_0.4.1       httr_1.4.1        dplyr_0.8.99.9002
[13] tools_3.6.1       grid_3.6.1        data.table_1.12.8 gtable_0.3.0     
[17] cli_2.0.2         withr_2.1.2       htmltools_0.4.0   ellipsis_0.3.0   
[21] lazyeval_0.2.2    digest_0.6.25     assertthat_0.2.1  tibble_3.0.0     
[25] lifecycle_0.2.0   crayon_1.3.4      tidyr_1.0.2       purrr_0.3.3      
[29] htmlwidgets_1.5.1 vctrs_0.2.99.9010 glue_1.4.0        compiler_3.6.1   
[33] pillar_1.4.3      generics_0.0.2    scales_1.1.0      jsonlite_1.6.1   
[37] pkgconfig_2.0.3  
```
