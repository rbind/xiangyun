---
date: "2022-04-30"
slug: animated-graphics
title: 动态图形与 R 语言
categories:
  - 统计图形
tags:
  - R 语言
  - gganimate
  - plotly
  - echarts4r
  - animation
  - gifski
  - rayrender
draft: true
toc: true
thumbnail: /img/gganimate.svg
link-citations: true
bibliography: 
  - refer.bib
  - packages.bib
description: "本文是把动态图形的范围稍微扩展了一下，凡是可以自己动的图形都称之为「动态图形」，包含动图、动画、影视等一切可以自动播放一帧帧画面的图形图像，这就包含各种各样的形式，如 GIF 动图，SWF 动画，MP4 视频，以及网页渲染的动画，当然还有三维动画。本文会先介绍 **ggplot2** 静态图，然后介绍 **gganimate** 动态图， **echarts4r** 二维平面动画，rgl 三维立体动画，以及相关的一些 R 包和软件，为保持行文连贯，均以 gapminder 数据集为基础予以介绍，希望读者能举一反三。"
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

本文源起笔者在统计之都上发的一个[帖子](https://d.cosx.org/d/422311)，后因工作需要和自己抽空整理了一下，遂成此文。

简单交代交待一下与之前介绍的[交互式图形](/2021/11/interactive-web-graphics)的区别，提及一下《现代统计图形》里关于 [**rgl**](https://github.com/dmurdoch/rgl) 和 [**animation**](https://github.com/yihui/animation) 包的介绍，本文重点介绍 [**gganimate**](https://github.com/thomasp85/gganimate) 和 [**echarts4r**](https://github.com/JohnCoene/echarts4r) 等更加现代化的工具和技术，以及笔者在使用动态图形展示数据方面的经验和教训。

稍微扩展一下，动态图形包含动图、动画、影视等一切可以自动播放一帧帧画面的图形图像，这就包含各种各样的形式，如 GIF 动图，SWF 动画，MP4 视频，以及网页渲染的动画，当然还有三维动画。本文会先介绍 **ggplot2** 静态图，然后介绍 **gganimate** 动态图， **echarts4r** 二维平面动画，**rgl** 三维立体动画，以及相关的一些 R 包和软件，为保持行文连贯，均以 **gapminder** 包内置的 gapminder 数据集为基础予以介绍，希望读者能举一反三。

Thomas Lin Pedersen 从 David Robinson 接手维护后，大刀阔斧地开发 **gganimate** ，打造「A Grammar of Animated Graphics」，他还是另一个图形语法的开山之作 **ggplot2** 的维护者。

领域内相关商业软件有很多，Adobe Flash 是早年的二维平面动画，Adobe 的 AE 和 PR 主打影视后期制作，Autodesk 的 Maya 和 3D Max 在三维场景建模、动画渲染等领域几成行业标准。开源软件也有不少，面向网页输出、支持 GPU 渲染的 three.js，[Blender](https://www.blender.org/) 是 GPL 协议开源的自由免费软件，GitHub 上存放了[源码镜像](https://github.com/blender/blender)。

有人戏称 [**rayrender**](https://github.com/tylermorganwall/rayrender) 是 好看但是没什么卵用的 R 包，不依赖 rgl 包，主打 3D 建模，渲染复杂场景，没有外部依赖，可制作三维立体感的 **ggplot2** 图形，推荐其替代 **rgl** 制作三维动画。[**rayshader**](https://github.com/tylermorganwall/rayshader) 依赖 **rgl** 和 **rayrender** 等提供阴影特效，适合地形景观图，Tyler Morgan-Wall 也曾在 RStudio 大会上介绍过 **rayshader**，Github 星赞超过 1500，算是比较流行的 R 包了。

[gifski](https://gif.ski/) 是一个制作 GIF 动图的 Rust 库，[Jeroen Ooms](https://github.com/jeroen) 开发了同名的 R 语言接口 [**gifski**](https://github.com/r-rust/gifski) 包，**gganimate** 制作 ggplot2 风格的动图或 MP4 格式视频也是采用 **gifski** 做转化。

[imagemagick](https://imagemagick.org/) 是一个独立的图像后期处理软件，它可以将一系列静态图片合成 GIF 动图，[**magick**](https://github.com/ropensci/magick) 是 Jeroen Ooms 开发的又一 R 接口包，[ffmpeg](https://www.ffmpeg.org/) 是一个独立的视频处理软件。

LaTeX 宏包 [animate](https://ctan.org/pkg/animate)，常用于 [beamer](https://ctan.org/pkg/beamer) 幻灯片或 PDF 文档中，将一系列 PNG/PDF 图片合成动画，就是将一幅幅图片以快速地方式播放，形成动画效果，需要使用 Adobe 阅读器播放才可见效果。

| R 包                                                         | 简介                                                                     | 维护者              | 网站                                                                                   | 协议                    |
|:-------------------------------------------------------------|:-------------------------------------------------------------------------|:--------------------|:---------------------------------------------------------------------------------------|:------------------------|
| **plotly** ([Sievert et al. 2021](#ref-plotly))              | Create Interactive Web Graphics via plotly.js                            | Carson Sievert      | https://plotly-r.com https://github.com/plotly/plotly.R https://plotly.com/r/          | MIT + file LICENSE      |
| **rgl** ([Adler and Murdoch 2021](#ref-rgl))                 | 3D Visualization Using OpenGL                                            | Duncan Murdoch      | https://github.com/dmurdoch/rgl https://dmurdoch.github.io/rgl/                        | GPL                     |
| **magick** ([Ooms 2021](#ref-magick))                        | Advanced Graphics and Image-Processing in R                              | Jeroen Ooms         | https://docs.ropensci.org/magick/ (website) https://github.com/ropensci/magick (devel) | MIT + file LICENSE      |
| **echarts4r** ([Coene 2021](#ref-echarts4r))                 | Create Interactive Graphs with Echarts JavaScript Version 5              | John Coene          | https://echarts4r.john-coene.com/ https://github.com/JohnCoene/echarts4r               | Apache License (>= 2.0) |
| **gganimate** ([Pedersen and Robinson 2020](#ref-gganimate)) | A Grammar of Animated Graphics                                           | Thomas Lin Pedersen | https://gganimate.com https://github.com/thomasp85/gganimate                           | MIT + file LICENSE      |
| **rayrender** ([Morgan-Wall 2021](#ref-rayrender))           | Build and Raytrace 3D Scenes                                             | Tyler Morgan-Wall   | https://www.rayrender.net https://github.com/tylermorganwall/rayrender                 | GPL-3                   |
| **animation** ([Xie 2021](#ref-animation))                   | A Gallery of Animations in Statistics and Utilities to Create Animations | Yihui Xie           | https://yihui.org/animation/                                                           | GPL                     |

Table 1: 制作动画的 R 包（排名不分先后）

# 软件准备

限于笔者目前所拥有的设备，后续介绍均在 MacOS 系统上。首先安装 [Rust 软件](https://www.rust-lang.org/) 以及 [Gifski](https://gif.ski/) 转化器，它可将视频、图片文件转化为 GIF 动图，且转化效率和质量非常高。

``` bash
brew install rust
cargo install gifski
```

在 `~/.cargo/config` 里配置就近的镜像地址加快[cargo](https://github.com/nabijaczleweli/cargo-update)下载速度，下面配置的是上海交通大学 Linux 用户组 (SJTUG) 维护的[镜像站点](https://mirrors.sjtug.sjtu.edu.cn/)。

    [source.crates-io]
    replace-with = "sjtu"

    [source.sjtu]
    registry = "https://mirrors.sjtug.sjtu.edu.cn/git/crates.io-index"

将路径 `~/.cargo/bin` 添加到 PATH 变量里，接着就可以直接使用 gifski 命令行工具了，它有几个参数，如下：

``` bash
gifski --help
```

    gifski 1.5.1
    https://gif.ski by Kornel Lesiński

    USAGE:
        gifski [OPTIONS] <FILE>... --output <a.gif>

    OPTIONS:
        -o, --output <a.gif>      Destination file to write to; "-" means stdout
        -r, --fps <num>           Frame rate of animation. If using PNG files as 
                                  input, this means the speed, as all frames are 
                                  kept. If video is used, it will be resampled to 
                                  this constant rate by dropping and/or duplicating 
                                  frames [default: 20]
            --fast-forward <x>    Multiply speed of video by a factor
                                  (no effect when using images as input) [default: 1]
            --fast                3 times faster encoding, but 10% lower quality and 
                                  larger file size
        -Q, --quality <1-100>     Lower quality may give smaller file [default: 90]
        -W, --width <px>          Maximum width.
                                  By default anims are limited to about 800x600
        -H, --height <px>         Maximum height (stretches if the width is also set)
            --nosort              Use files exactly in the order given, rather than 
                                  sorted
        -q, --quiet               Do not display anything on standard output/console
            --repeat <num>        Number of times the animation is repeated 
                                  (-1 none, 0 forever or <value> repetitions
        -h, --help                Prints help information
        -V, --version             Prints version information

    ARGS:
        <FILE>...    one video file supported by FFmpeg, or multiple PNG image files

帮助文档非常简单，就不翻译了，举个例子，下面将一段视频 `INPUT.mov` 转化为 GIF 动图 `OUTPUT.gif`。

``` bash
gifski -W 800 -H 600 INPUT.mov -o OUTPUT.gif
```

# GIF 动画

## ggplot2

不是希望你也画如此糟糕的图形，此图的目的是告诉你，绘图的细节，涉及到的方方面面。掌握其一，你就能精通 ggplot2 和 plotly 等。

``` r
par(mar = c(2, 2, 2.5, 1))
plot(c(1, 5, 10), c(1, 5, 10),
  panel.first = grid(10, 10),
  type = "n", axes = FALSE, ann = FALSE
)
# 空白画布
axis(1, at = 0:11, labels = TRUE)
# 添加坐标轴
axis(2, at = 0:11, labels = TRUE)
par(new = TRUE) # 在当前图形上添加图形
# axes 坐标轴上的刻度 "xaxt" or "yaxt" ann 坐标轴和标题的标签
set.seed(1234)
# 添加二维核密度估计曲线
cols <- c(
  "#4285f4", # GoogleBlue
  "#34A853", # GoogleGreen
  "#FBBC05", # GoogleYellow
  "#EA4335" # GoogleRed
)
library(MASS)
Sigma <- matrix(c(10, 3, 3, 2), 2, 2)
x <- mvrnorm(n = 100, rep(5, 2), Sigma)
plot(x[, 2], x[, 1],
  cex = runif(100, 0, 2),
  col = cols[rep(seq(4), 100)],
  bg = paste0("gray", sample(x = 1:100, size = 100, replace = TRUE)),
  axes = FALSE, ann = FALSE, pch = 21, lwd = 2
)
title(main = "Bubble Plot")
legend("top",
  legend = paste0("class", 1:4),
  col = cols, pt.lwd = 2, pch = 21,
  box.col = "gray", horiz = TRUE
)
box()
```

``` r
library(showtext)
library(gapminder)
library(ggplot2)
library(ggrepel)
ggplot(
  data = gapminder[gapminder$year == 2002, ],
  aes(x = gdpPercap, y = lifeExp)
) +
  geom_point(aes(size = pop / 10^6, color = continent), alpha = 0.5) +
  geom_text_repel(
    data = gapminder[gapminder$year == 2002 & gapminder$pop > 50 * 10^6, ],
    aes(size = pop/(5*10^7), label = country), 
    alpha = 0.7, max.overlaps = 50, segment.colour = "gray", seed = 2021
  ) +
  scale_x_log10() +
  scale_size(breaks = c(1, 10, 100, 1000), range = c(1, 30)) +
  labs(
    x = "人均 GDP（美元，对数尺度）", y = "人均寿命（岁）",
    size = "人口总数\n（百万）", color = "地区"
  ) +
  theme_bw(base_size = 13, base_family = "sans") +
  theme(title = element_text(family = "wqy-microhei"))
```

gapminder 数据集中 2002 年数据为例，绘图气泡图 <a href="#fig:gapminder-ggplot2">1</a>

<figure>
<img src="https://user-images.githubusercontent.com/12031874/145673108-e6c143a9-3010-4a5d-8a91-59c1e5c13b6c.png" class="full" alt="Figure 1: ggplot2 制作静态气泡图" /><figcaption aria-hidden="true">Figure 1: ggplot2 制作静态气泡图</figcaption>
</figure>

## gganimate

``` r
library(gganimate)
```

# 网页动画

[Apache ECharts](https://github.com/apache/echarts)、[plotly](https://github.com/plotly/plotly.js)、[G2](https://github.com/antvis/g2)、[highcharts](https://github.com/highcharts/highcharts)（此为商业软件） 都支持一定的动画制作能力。相对比较成熟的 R 语言接口是前面几个，下面详细介绍一二。

<!--
Su Wei 为 [nivo](https://github.com/plouc/nivo) 开发的 R 包 [nivor](https://github.com/swsoyee/nivor)，
John (JP) Coene 为 [G2](https://github.com/antvis/g2) 开发的 R 包 [g2r](https://github.com/devOpifex/g2r) 都不成熟。
-->

## echarts4r

制作 **echarts4r** 基于 JS 库，生成面向网页展示的动画

``` r
library(echarts4r)
data("gapminder", package = "gapminder")
# 准备动画标题
titles <- lapply(unique(gapminder$year), FUN = function(x) {
  list(
    text = "各国人均寿命与人均GDP关系演变",
    left = "center"
  )
})
# 准备动画背景文字
years <- lapply(unique(gapminder$year), FUN = function(x) {
  list(
    subtext = x,
    left = "center",
    top = "center",
    z = 0,
    subtextStyle = list(
      fontSize = 100,
      color = "rgb(170, 170, 170, 0.5)",
      fontWeight = "bolder"
    )
  )
})
```

添加一列颜色，各大洲和颜色的对应关系可自定义，调整 levels 或 labels 里面的顺序即可，也可不指定 levels ，调用其它调色板

``` r
gapminder <- transform(gapminder,
  color = factor(
    continent,
    levels = c("Asia", "Africa", "Americas", "Europe", "Oceania"),
    labels = RColorBrewer::brewer.pal(n = 5, name = "Spectral")
  )
)
```

准备工作就绪后，绘制动画

``` r
gapminder |>
  group_by(year) |>
  # 横轴是人均 GDP
  e_charts(x = gdpPercap, timeline = TRUE) |>
  e_scatter(
    # 纵轴是人均寿命（预期寿命）
    serie = lifeExp,
    # 气泡大小表示人口总数
    size = pop,
    bind = country,
    # 气泡的样式
    symbol = "circle",
    # 气泡大小的 base 参照值
    symbol_size = 5,
    # 设置气泡的透明度，缓解重叠现象
    itemStyle = list(opacity = 0.8),
    # 用于tooltip的显示，legend 的图例筛选
    name = ""
  ) |>
  # https://echarts.apache.org/zh/option.html#series-scatter.itemStyle
  # 散点的样式设置，配色
  # color 必须是 gapminder 里由颜色值构成的分类变量
  e_add_nested("itemStyle", color) |>
  e_y_axis(
    min = 20, max = 85,
    # 纵轴标题到轴线的距离
    nameGap = 40,
    # 纵轴标题
    name = "人均寿命（岁）",
    # 纵轴标题位置
    nameLocation = "center",
    # 纵轴标题样式
    nameTextStyle = list(fontWeight = "bold", fontSize = 18)
  ) |>
  e_x_axis(
    # 设置横轴为对数尺度，默认以10为底
    type = "log",
    min = 100, max = 100000,
    nameGap = 30, name = "人均 GDP（美元）",
    nameLocation = "center",
    nameTextStyle = list(fontWeight = "bold", fontSize = 18)
  ) |>
  e_tooltip(
    # 数据项图形触发，用于散点图等，设置 'axis' 表示坐标轴触发，主要在柱状图/条形图
    trigger = "item",
    # 鼠标移动或点击时触发
    triggerOn = "mousemove|click",
    # 定制悬浮内容
    # params.name 取自 bind 变量
    formatter = htmlwidgets::JS("
      function(params){
        return('国家: <strong>' + params.name + '</strong>' +
               '<br />人均 GDP: ' + Math.round(params.value[0]) + '美元' +
               '<br />人均寿命: ' + Math.round(params.value[1]) + '岁' +
               '<br />人口总数: ' + Math.round(params.value[2] / 1000000 * 100) / 100 + '百万')
      }
    ")
  ) |>
  # 刻度单位
  e_format_x_axis(suffix = "$") |>
  e_format_y_axis(suffix = "岁") |>
  # 动画的主标题
  e_timeline_serie(title = titles, index = 1) |>
  # 动画的背景年份
  e_timeline_serie(title = years, index = 2) |>
  # 动画设置
  e_timeline_opts(
    axis_type = "time", # 时间轴的类型：数值型 "value" 和分类型 "category"
    symbol = "circle", # 时间轴上的点的符号，设置为 "none" 可以去掉符号
    autoPlay = TRUE, # 自动播放动画
    orient = "horizontal", # 时间轴水平放置，还可以垂直放置 'vertical'
    playInterval = 1000, # 播放的速度，单位毫秒
    loop = TRUE, # 是否循环播放动画
    lineStyle = list(show = TRUE), # 时间轴的样式
    itemStyle = list(color = "red"), # 时间轴上断点的样式
    checkpointStyle = list(symbol = "diamond"), # 时间轴上要强调的断点样式
    progress = list(itemStyle = list(color = "green")) # 进度条行进上的断点样式
  ) |>
  # 坐标系内网格距离容器下方的距离
  e_grid(bottom = 100)
```

<figure>
<img src="https://user-images.githubusercontent.com/12031874/145659289-cabd0c66-35e9-448c-adf3-f3934a72f4f2.gif" class="full" alt="Figure 2: echarts4r 制作网页动画" /><figcaption aria-hidden="true">Figure 2: echarts4r 制作网页动画</figcaption>
</figure>

因为 blogdown 不支持直接插入视频，而笔者也不想把视频传至商业视频网站，因此录制的高质量视频，读者可以[点击这里](https://user-images.githubusercontent.com/12031874/145657748-0db6c4ee-47e9-4b1b-941d-1022937dcf4a.mov)下载观看，最好还是在 R 控制台运行上述代码，效果会更好。

<div class="rmdnote">

对照 Apache ECharts 时间轴 [timeline](https://echarts.apache.org/zh/option.html#timeline) 组件的帮助文档，设置以上参数，echarts4r 有的参数名称和 Apache ECharts 略微不同，函数 `e_timeline_opts()` 的 `axis_type` 对应 `axisType`，`e_timeline_serie()` 的 `index` 对应 `currentIndex`。

</div>

<div class="sidebar">

上面的 GIF 动图是借助 GifSki 将录制的 MOV 视频转化来的，转化命令如下：

``` bash
gifski -W 800 -H 600 gapminder-echarts4r.mov -o gapminder-echarts4r.gif
```

</div>

<div class="rmdwarn">

动画里，大气泡覆盖小气泡，尽管设置了透明度，可以看到小气泡的位置，但是鼠标悬浮在小气泡上无法显示 tooltip，这有可能是 Apache ECharts 的问题，官方示例也有此[问题](https://echarts.apache.org/examples/zh/editor.html?c=scatter-life-expectancy-timeline)。

</div>

## plotly

下面采用 Carson Sievert 开发的 [plotly](https://github.com/plotly/plotly.R) 包([Sievert 2020](#ref-Sievert2020))制作网页动画，仍是以 gapminder 数据集为例，示例修改自 plotly 官网的 [动画示例](https://plotly.com/r/animations/)。关于 plotly 以及绘制散点图的介绍，见前文[交互式网页图形与 R 语言](/2021/11/interactive-web-graphics/)，此处不再赘述。

``` r
library(plotly)

plot_ly(
  data = gapminder,
  # 横轴
  x = ~gdpPercap,
  # 纵轴
  y = ~lifeExp,
  # 气泡大小
  size = ~pop,
  fill = ~"",
  # 分组配色
  color = ~continent,
  # 时间变量
  frame = ~year,
  # 悬浮提示
  text = ~ paste0(
    "年份：", year, "<br>",
    "国家：", country, "<br>",
    "人口总数：", round(pop / 10^6, 2), "百万", "<br>",
    "人均 GDP：", round(gdpPercap), "美元", "<br>",
    "预期寿命：", round(lifeExp), "岁"
  ),
  hoverinfo = "text",
  type = "scatter",
  mode = "markers",
  marker = list(
    symbol = "circle",
    sizemode = "diameter",
    line = list(width = 2, color = "#FFFFFF"),
    opacity = 0.8
  )
) |>
  layout(
    xaxis = list(
      type = "log", title = "人均 GDP（美元）"
    ),
    yaxis = list(title = "预期寿命（年）"),
    legend = list(title = list(text = "<b> 大洲 </b>"))
  ) |>
  animation_opts(
    frame = 1000, easing = "linear", redraw = FALSE,
    transition = 1000, mode = "immediate"
  ) |>
  animation_slider(
    currentvalue = list(
      prefix = "年份 ",
      xanchor = "right",
      font = list(color = "gray", size = 30)
    )
  ) |>
  animation_button(
    # 按钮位置
    x = 0, xanchor = "right",
    y = -0.2, yanchor = "bottom",
    label = "播放", # 按钮文本
    # bgcolor = "#5b89f7", # 按钮背景色
    # font = list(color = "#fff"), # 文本颜色
    visible = TRUE # 显示播放按钮
  ) |>
  config(
    # 去掉图片右上角工具条
    displayModeBar = FALSE
  )
```

<figure>
<img src="https://user-images.githubusercontent.com/12031874/145671224-e3617a52-e9be-4197-aa6b-cdde2d2b7724.gif" class="full" alt="Figure 3: plotly 制作网页动画" /><figcaption aria-hidden="true">Figure 3: plotly 制作网页动画</figcaption>
</figure>

如动图 <a href="#fig:gapminder-plotly">3</a> 所示，视频下载[点击这里](https://user-images.githubusercontent.com/12031874/145671216-8ef13eaf-3f19-4a36-808f-7e812a5bdf60.mov)，相比于 **echarts4r**， 气泡即使有重叠和覆盖，只要鼠标悬浮其上，就能显示被覆盖的 tooltip。

<div class="rmdwarn">

动画播放和暂停的控制按钮一直有问题，即点击播放后，按钮不会切换为暂停按钮，点击暂停后也不能恢复，详见 plotly 包的 Github [问题贴](https://github.com/plotly/plotly.R/issues/1207)。然而，Python 版的 plotly 模块制作此[动画](https://plotly.com/python/animations/)，一切正常，代码也紧凑很多，见下方。

``` python
import plotly.express as px

df = px.data.gapminder()
px.scatter(
    df,
    # 横轴
    x="gdpPercap",
    # 纵轴
    y="lifeExp",
    # 动画帧
    animation_frame="year",
    # 动画分组
    animation_group="country",
    # 气泡大小映射到总人口
    size="pop",
    # 颜色映射到地区/大洲
    color="continent",
    # 悬浮
    hover_name="country",
    # 图形主题
    template="none",
    # 横轴坐标取对数
    log_x=True,
    size_max=55,
    # 横轴范围
    range_x=[100, 100000],
    # 纵轴范围
    range_y=[25, 90],
    # 设置横纵坐标轴标题
    labels={
        "gdpPercap": "人均 GDP (美元)",
        "lifeExp": "人均寿命 (岁)",
        "year": "年份",
    },
    # 调用来自 colorbrewer 的 Set2 调色板
    color_discrete_sequence=px.colors.colorbrewer.Set2
)
```

值得一提的是，支持丰富的调色板，涵盖常用的三大类型：无序的分类调色板、有序的分类调色板、连续型的调色板。调用其中一个调色板，只需 `px.colors.qualitative.Set2` 或者其逆序版本 `px.colors.qualitative.Set2_r`。也只需两行代码即可预览任意一组调色板， colorbrewer 调色板见图<a href="#fig:plotly-colorbrewer">4</a>。

``` python
# 无序的分类调色板
fig = px.colors.qualitative.swatches()
fig.show()
# 发散型的调色板
fig = px.colors.diverging.swatches()
fig.show()
# 有序的分类调色板
fig = px.colors.sequential.swatches()
fig.show()
# 周期性的调色板
fig = px.colors.cyclical.swatches()
fig.show()
# 收录所有 colorbrewer 调色板
fig = px.colors.colorbrewer.swatches()
fig.show()
```

<figure>
<img src="/img/plotly-colorbrewer.png" class="full" alt="Figure 4: plotly 的 colorbrewer 调色板" /><figcaption aria-hidden="true">Figure 4: plotly 的 colorbrewer 调色板</figcaption>
</figure>

设置[图形主题](https://plotly.com/python/templates/)

实际上， plotly 模块的 [express 组件](https://plotly.com/python/plotly-express/)封装了 30 多种[图形](https://plotly.com/python-api-reference/plotly.express.html)，是一种高级/快速的绘图接口，非常类似 R 语言 **graphics** 包提供的系列函数，如柱形图/条形图 `barplot()`、箱线图 `boxplot()`、直方图 `hist()`、透视图 `persp()`、饼图 `pie()` 等等，下面是 **graphics** 包提供的所有高级绘图函数。

``` r
ls("package:graphics")
#  [1] "abline"          "arrows"          "assocplot"      
#  [4] "axis"            "Axis"            "axis.Date"      
#  [7] "axis.POSIXct"    "axTicks"         "barplot"        
# [10] "barplot.default" "box"             "boxplot"        
# [13] "boxplot.default" "boxplot.matrix"  "bxp"            
# [16] "cdplot"          "clip"            "close.screen"   
# [19] "co.intervals"    "contour"         "contour.default"
# [22] "coplot"          "curve"           "dotchart"       
# [25] "erase.screen"    "filled.contour"  "fourfoldplot"   
# [28] "frame"           "grconvertX"      "grconvertY"     
# [31] "grid"            "hist"            "hist.default"   
# [34] "identify"        "image"           "image.default"  
# [37] "layout"          "layout.show"     "lcm"            
# [40] "legend"          "lines"           "lines.default"  
# [43] "locator"         "matlines"        "matplot"        
# [46] "matpoints"       "mosaicplot"      "mtext"          
# [49] "pairs"           "pairs.default"   "panel.smooth"   
# [52] "par"             "persp"           "pie"            
# [55] "plot"            "plot.default"    "plot.design"    
# [58] "plot.function"   "plot.new"        "plot.window"    
# [61] "plot.xy"         "points"          "points.default" 
# [64] "polygon"         "polypath"        "rasterImage"    
# [67] "rect"            "rug"             "screen"         
# [70] "segments"        "smoothScatter"   "spineplot"      
# [73] "split.screen"    "stars"           "stem"           
# [76] "strheight"       "stripchart"      "strwidth"       
# [79] "sunflowerplot"   "symbols"         "text"           
# [82] "text.default"    "title"           "xinch"          
# [85] "xspline"         "xyinch"          "yinch"
```

熟悉 **ggplot2** 绘图的读者，可能立马联想到这不和函数 `qplot()` 一样吗？是的，惊人地相似，请注意看下面绘图部分的代码和图<a href="#fig:gapminder-qplot">5</a>，也是将数据和几何元素、图层建立关系。

``` r
# 加载数据
data(gapminder, package = "gapminder")
# 加载 ggplot2 包
library(ggplot2)
# 加载 showtext 包
library(showtext)
# 处理中文
showtext_auto()
# 调 svglite 包保存高质量矢量图片
svglite::svglite(filename = "gapminder-qplot.svg")
# 绘图部分
qplot(
  x = gdpPercap, y = lifeExp, 
  color = continent, size = pop / 10^6,
  data = gapminder[gapminder$year == "2002", ],
  log = "x", geom = "point", alpha = 0.8,
  main = "各国人均寿命与人均GDP关系（2002年）",
  xlab = "人均GDP（美元）",
  ylab = "人均寿命（岁）"
) +
  theme_minimal(base_family = "wqy-microhei", base_size = 15)
dev.off()
```

<figure>
<img src="/img/gapminder-qplot.svg" class="full" alt="Figure 5: ggplot2 快速绘图函数qplot()" /><figcaption aria-hidden="true">Figure 5: <strong>ggplot2</strong> 快速绘图函数<code>qplot()</code></figcaption>
</figure>

当然，如果想更加精细地绘制复杂图形，还是要学习 [`ggplot()` 函数](https://ggplot2.tidyverse.org/reference/ggplot.html)，在 Python 里也是一样，你需要放弃调用 **plotly.express** 组件，转向学习低水平绘图的 API [Graph Objects](https://plotly.com/python-api-reference/plotly.graph_objects.html#graph-objects)。

https://plotly.com/python/styling-plotly-express/

嘴周，顺便一说，添加如下 CSS 可以去掉图形右上角烦人的工具条。

``` css
.modebar {
  display: none !important;
}
```

</div>

<div class="rmdtip">

读者看到 `plot_ly(fill = ~"",...)` 可能会奇怪，为什么参数 `fill` 的值是空字符串？这应该是 plotly 的 R 包或 JS 库的问题，不加会有很多警告：

    `line.width` does not currently support multiple values.

笔者是参考[SO](https://stackoverflow.com/questions/52692760/)的帖子加上的。

</div>

# OpenGL 动画

[OpenGL](https://www.opengl.org/)

## rgl

``` r
library(rgl)
```

## rayrender

``` r
library(rayrender)
```

# WebGL 动画

[WebGL](https://developer.mozilla.org/zh-CN/docs/Web/API/WebGL_API)

[WebGL](https://www.khronos.org/webgl/)

GPU 加速，大规模数据集

## mapdeck

R 接口 Deck.gl 和 Mapbox

[mapdeck](https://github.com/SymbolixAU/mapdeck)

## echarts4r

## plotly

plotly type 参数类型，带 GL

# 其它工具

Python 绘图模块 matplotlib 的[animation](https://matplotlib.org/stable/api/animation_api.html)

Julia 的 [Plots.jl](https://github.com/JuliaPlots/Plots.jl) 包

企业级数据大屏、数据可视化 [MapGL](https://github.com/shiliangL/vue-datav-mapgl)

JavaScript 3D 图形库[three.js](https://github.com/mrdoob/three.js)

# 环境信息

在 RStudio IDE 内编辑本文的 R Markdown 源文件，用 **blogdown** 构建网站，[Hugo](https://github.com/gohugoio/hugo) 渲染 knitr 之后的 Markdown 文件，得益于 **blogdown** 对 R Markdown 格式的支持，图、表和参考文献的交叉引用非常方便，省了不少文字编辑功夫。文中使用了多个 R 包，为方便复现本文内容，下面列出详细的环境信息：

``` r
xfun::session_info(packages = c(
  "knitr", "rmarkdown", "blogdown",
  "plotly", "gapminder", "echarts4r",
  "gganimate", "ggplot2", "showtext",
  "MASS", "ggrepel", "rgl", "rayrender"
), dependencies = FALSE)
# R version 4.1.2 (2021-11-01)
# Platform: x86_64-apple-darwin17.0 (64-bit)
# Running under: macOS Big Sur 10.16
# 
# Locale: en_US.UTF-8 / en_US.UTF-8 / en_US.UTF-8 / C / en_US.UTF-8 / en_US.UTF-8
# 
# Package version:
#   blogdown_1.6     echarts4r_0.4.2  gapminder_0.3.0 
#   gganimate_1.0.7  ggplot2_3.3.5    ggrepel_0.9.1   
#   knitr_1.36       MASS_7.3.54      plotly_4.10.0   
#   rayrender_0.23.6 rgl_0.108.3      rmarkdown_2.11  
#   showtext_0.9.4  
# 
# Pandoc version: 2.16.2
# 
# Hugo version: 0.89.4
```

# 参考文献

<div id="refs" class="references csl-bib-body hanging-indent">

<div id="ref-rgl" class="csl-entry">

Adler, Daniel, and Duncan Murdoch. 2021. *Rgl: 3d Visualization Using OpenGL*. <https://CRAN.R-project.org/package=rgl>.

</div>

<div id="ref-echarts4r" class="csl-entry">

Coene, John. 2021. *Echarts4r: Create Interactive Graphs with Echarts JavaScript Version 5*. <https://CRAN.R-project.org/package=echarts4r>.

</div>

<div id="ref-rayrender" class="csl-entry">

Morgan-Wall, Tyler. 2021. *Rayrender: Build and Raytrace 3d Scenes*. <https://CRAN.R-project.org/package=rayrender>.

</div>

<div id="ref-magick" class="csl-entry">

Ooms, Jeroen. 2021. *Magick: Advanced Graphics and Image-Processing in r*. <https://CRAN.R-project.org/package=magick>.

</div>

<div id="ref-gganimate" class="csl-entry">

Pedersen, Thomas Lin, and David Robinson. 2020. *Gganimate: A Grammar of Animated Graphics*. <https://CRAN.R-project.org/package=gganimate>.

</div>

<div id="ref-Sievert2020" class="csl-entry">

Sievert, Carson. 2020. *Interactive Web-Based Data Visualization with R, <span class="nocase">plotly</span>, and <span class="nocase">shiny</span>*. 1st ed. Boca Raton, Florida: Chapman; Hall/CRC. <https://plotly-r.com/>.

</div>

<div id="ref-plotly" class="csl-entry">

Sievert, Carson, Chris Parmer, Toby Hocking, Scott Chamberlain, Karthik Ram, Marianne Corvellec, and Pedro Despouy. 2021. *Plotly: Create Interactive Web Graphics via Plotly.js*. <https://CRAN.R-project.org/package=plotly>.

</div>

<div id="ref-animation" class="csl-entry">

Xie, Yihui. 2021. *Animation: A Gallery of Animations in Statistics and Utilities to Create Animations*. <https://yihui.org/animation/>.

</div>

</div>
