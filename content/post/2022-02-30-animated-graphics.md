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
  - rgl
  - OpenGL
  - WebGL
  - Python 语言
  - matplotlib
  - Julia 语言
  - Plots.jl
  - JavaScript
  - three.js
draft: true
toc: true
thumbnail: /img/gganimate.svg
link-citations: true
bibliography: 
  - refer.bib
  - packages.bib
description: "本文是把动态图形的范围稍微扩展了一下，凡是可以自己动的图形都称之为「动态图形」，涵盖动图、动画、影视等一切可以自动播放一帧帧画面的图形图像。本文会先介绍 **ggplot2** 静态图，然后介绍 **gganimate** 动态图， **echarts4r** 二维平面动画，**rgl** 三维立体动画，以及相关的一些 R 包和软件，为保持行文连贯，均以 gapminder 数据集为基础予以介绍，希望读者能举一反三。"
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

<div class="rmdtip">

本文含有多个动画和短视频，在流畅的网络环境中阅读效果会更佳。

</div>

# 本文概览

本文源起笔者在统计之都上发的一个[帖子](https://d.cosx.org/d/422311)，后因工作需要，自己抽空也整理了一下，遂成此文。

2006 年 Hans Rosling（汉斯·罗琳）在 TED 上的演讲 — [The best stats you’ve ever seen](https://www.ted.com/talks/hans_rosling_the_best_stats_you_ve_ever_seen)，期间展示了一系列生动形象的动画，用数据呈现的事实帮助大家解读世界的变化，可谓是动态图形的惊世之作。后来，创立了 <https://www.gapminder.org/tools> 建立基于事实的世界观，理解不断变化的世界，网站名字 gap minder 意在提醒大家关注差异和理解变化。数据可视化在数据科学中扮演数据探索、展示和交流的关键角色，在合适的数据集和应用场景上，动态图形包含的信息更加丰富，说不定还能像汉斯·罗琳那样收到奇效。

简单交代交待一下与之前介绍的[交互式图形](/2021/11/interactive-web-graphics)的区别，提及一下《现代统计图形》里关于 [**rgl**](https://github.com/dmurdoch/rgl) 和 [**animation**](https://github.com/yihui/animation) 包的介绍，本文重点介绍 [**gganimate**](https://github.com/thomasp85/gganimate) 和 [**echarts4r**](https://github.com/JohnCoene/echarts4r) 等更加现代化的工具和技术，以及笔者在使用动态图形展示数据方面的经验和教训。

稍微扩展一下，动态图形包含动图、动画、影视等一切可以自动播放一帧帧画面的图形图像，这就包含各种各样的形式，如 GIF 动图，SWF 动画，MP4 视频，以及网页渲染的动画，当然还有三维动画。本文会先介绍 **ggplot2** 静态图，然后介绍 **gganimate** 动态图， **echarts4r** 二维平面动画，**rgl** 三维立体动画，以及相关的一些 R 包和软件，为保持行文连贯，均以 [**gapminder**](https://github.com/jennybc/gapminder) 包内置的 gapminder 数据集为基础予以介绍，希望读者能举一反三。

Thomas Lin Pedersen 从 David Robinson 接手维护后，大刀阔斧地开发 **gganimate** ，打造「A Grammar of Animated Graphics」，他还是另一个图形语法的开山之作 **ggplot2** 的维护者。

领域内相关商业软件有很多，Adobe Flash 是早年的二维平面动画，Adobe 的 AE 和 PR 主打影视后期制作，Autodesk 的 Maya 和 3D Max 在三维场景建模、动画渲染等领域几成行业标准。开源软件也有不少，面向网页输出、支持 GPU 渲染的 three.js，[Blender](https://www.blender.org/) 是 GPL 协议开源的自由免费软件，GitHub 上存放了[源码镜像](https://github.com/blender/blender)。

相比于常见的用函数 `persp()` 制作的三维透视图，**rgl** 算是非常**早**的实现**真**三维图形绘制的 R 包，它在 2004 年就发布在 CRAN 上了，时间一晃，17 年过去了。

<!-- 
动画使用不当真的会弄巧成拙！
-->

mikefc 戏称自己造了好看不中用的 [ggrgl](https://github.com/coolbutuseless/ggrgl) 包，其 Github ID 正是 coolbutuseless，按字面意思拆开来就是「cool but useless」[^1]。这让我一下想到贾宝玉在假山下和林黛玉一起偷看《西厢记》的场景，贾宝玉问：银样蜡枪头是什么意思？林黛玉回答说：中看不中用。有些图形实在没有必要升维做成立体的，比如条形图或柱形图，一些反面例子可以在[漫谈条形图](https://cosx.org/2017/10/discussion-about-bar-graph)和[你问我答](https://msg2020.pzhao.org/qa/)两篇文章中找到。

[**rayrender**](https://github.com/tylermorganwall/rayrender) 不依赖 rgl 包，主打 3D 建模，渲染复杂场景，没有外部依赖，可制作三维立体感的 **ggplot2** 图形，推荐其替代 **rgl** 制作三维动画。[**rayshader**](https://github.com/tylermorganwall/rayshader) 依赖 **rgl** 和 **rayrender** 等提供阴影特效，适合地形景观图，Tyler Morgan-Wall 也曾在 RStudio 大会上介绍过 **rayshader**，Github 星赞超过 1500，算是比较流行的 R 包了。

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

阐述收入二八定律，分布变化的动态图形

``` r
# 准备 Noto 中英文字体
sysfonts::font_paths(new = "~/Library/Fonts/")
## 宋体
sysfonts::font_add(
  family = "Noto Serif CJK SC",
  regular = "NotoSerifCJKsc-Regular.otf",
  bold = "NotoSerifCJKsc-Bold.otf"
)

sysfonts::font_add(
  family = "Noto Sans",
  regular = "NotoSans-Regular.ttf",
  bold = "NotoSans-Bold.ttf",
  italic = "NotoSans-Italic.ttf",
  bolditalic = "NotoSans-BoldItalic.ttf"
)

svglite::svglite(filename = "gapminder-ggplot.svg")

ggplot(
  data = gapminder[gapminder$year == "2002", ],
  aes(x = gdpPercap, y = stat(density * n), fill = continent)
) +
  geom_density(position = "stack", colour = "white") +
  scale_fill_brewer(palette = "Spectral") +
  scale_x_log10() +
  theme_minimal(base_family = "Noto Serif CJK SC", base_size = 15) +
  labs(
    x = "人均 GDP（美元）", y = "国家数量（个）", fill = "大洲",
    title = "人均GDP的国家分布关系（2002年）"
  ) +
  theme(
    axis.text.x = element_text(family = "Noto Sans", color = "black"),
    axis.text.y = element_text(
      family = "Noto Sans", color = "black",
      angle = 90, vjust = 1.5, hjust = 0.5
    ),
    legend.text = element_text(family = "Noto Sans"),
    plot.tag = element_text(family = "Noto Serif CJK SC", color = "black"),
    plot.tag.position = "topright"
  )
dev.off()
```

如图<a href="#fig:gapminder-ggplot">2</a> 所示，各个洲的收入分布图

<figure>
<img src="/img/gapminder-ggplot.svg" class="full" alt="Figure 2: ggplot2 制作累积分布图" /><figcaption aria-hidden="true">Figure 2: ggplot2 制作累积分布图</figcaption>
</figure>

抓住最具代表性的指标，找最能引起观众共鸣和达成共识的点，比如先入为主的偏见，发达国家收入高寿命长，发展中国家收入中等寿命较长，不发达国家收入低寿命短，以及婴儿死亡率高、家庭成员多等主观印象出发。收集尽可能准确的数据，包括来自开放组织的数据和亲自设计实验收集数据，从一些看似简单实则富含统计和因果推理理论的实验中发现一系列反事实（先入为主的偏见）的结论。比如成对的两个国家的婴儿死亡率之间至少有两倍的差距，以确保数据之间的差距远大于数据本身的误差（组间误差和组内误差，系统误差和随机误差，干预效应和随机效应），再将问卷对象从学生扩展到教授，再拿大猩猩做对照，整个实验既有生动性又有戏剧性，强烈的反差给观众留下深刻的印象，真是一个精彩的数据故事。

汉斯·罗琳从健康和经济的关系看发展中国家和发达国家

``` r
library(gapminder)

ggplot(gapminder, aes(gdpPercap, lifeExp, size = pop, colour = country)) +
  geom_point(alpha = 0.7, show.legend = FALSE) +
  scale_colour_manual(values = country_colors) +
  scale_size(range = c(2, 12)) +
  scale_x_log10() +
  facet_wrap(~continent) +
  # gganimate 
  labs(title = 'Year: {frame_time}', x = 'GDP per capita', y = 'life expectancy') +
  transition_time(year) +
  ease_aes('linear')
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
<video src="https://user-images.githubusercontent.com/12031874/145657748-0db6c4ee-47e9-4b1b-941d-1022937dcf4a.mov" class="full" controls=""><a href="https://user-images.githubusercontent.com/12031874/145657748-0db6c4ee-47e9-4b1b-941d-1022937dcf4a.mov">Figure 3: echarts4r 制作网页动画</a></video><figcaption aria-hidden="true">Figure 3: echarts4r 制作网页动画</figcaption>
</figure>

<div class="rmdnote">

对照 Apache ECharts 时间轴 [timeline](https://echarts.apache.org/zh/option.html#timeline) 组件的帮助文档，设置以上参数，echarts4r 有的参数名称和 Apache ECharts 略微不同，函数 `e_timeline_opts()` 的 `axis_type` 对应 `axisType`，`e_timeline_serie()` 的 `index` 对应 `currentIndex`。

</div>

<div class="rmdwarn">

动画里，大气泡覆盖小气泡，尽管设置了透明度，可以看到小气泡的位置，但是鼠标悬浮在小气泡上无法显示 tooltip，这很有可能是 Apache ECharts 的问题，因为官方示例也有此[问题](https://echarts.apache.org/examples/zh/editor.html?c=scatter-life-expectancy-timeline)。

</div>

## plotly （R 语言版）

下面采用 Carson Sievert 开发的 [plotly](https://github.com/plotly/plotly.R) 包([Sievert 2020](#ref-Sievert2020))制作网页动画，仍是以 gapminder 数据集为例，示例修改自 plotly 官网的 [动画示例](https://plotly.com/r/animations/)。关于 plotly 以及绘制散点图的介绍，见前文[交互式网页图形与 R 语言](/2021/11/interactive-web-graphics/)，此处不再赘述[^2]。

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
    # 帧与帧之间播放的时间间隔，包含转场时间
    frame = 1000, 
    # 转场的效果
    easing = "linear", 
    redraw = FALSE,
    # 动画帧与帧之间转场的时间间隔，单位毫秒
    transition = 1000,
    mode = "immediate"
  ) |>
  animation_slider(
    currentvalue = list(
      prefix = "年份 ",
      xanchor = "right",
      font = list(color = "gray", size = 30)
    )
  ) |>
  # 下面的参数会传递给 layout.updatemenus 的 button 对象
  animation_button(
    # 按钮位置
    x = 0, xanchor = "right",
    y = -0.3, yanchor = "bottom",
    visible = TRUE, # 显示播放按钮
    label = "播放", # 按钮文本
    # bgcolor = "#5b89f7", # 按钮背景色
    font = list(color = "orange")# 文本颜色
  ) |>
  config(
    # 去掉图片右上角工具条
    displayModeBar = FALSE
  )
```

<figure>
<video src="https://user-images.githubusercontent.com/12031874/145713395-5f692a24-e4b7-4900-94f2-bc0a4911ac28.mov" class="full" controls=""><a href="https://user-images.githubusercontent.com/12031874/145713395-5f692a24-e4b7-4900-94f2-bc0a4911ac28.mov">Figure 4: plotly 制作网页动画</a></video><figcaption aria-hidden="true">Figure 4: plotly 制作网页动画</figcaption>
</figure>

如图 <a href="#fig:gapminder-plotly">4</a> 所示，相比于 **echarts4r**， 气泡即使有重叠和覆盖，只要鼠标悬浮其上，就能显示被覆盖的 tooltip。

动画控制参数 `animation_opts()`，详见 Plotly [动画属性](https://github.com/plotly/plotly.js/blob/master/src/plots/animation_attributes.js)，结合此帮助文档，可知参数 `easing` 除了上面的取值 `linear`，还有很多，全部参数值见表<a href="#tab:easing">2</a>。

|             |            |               |                |             |               |
|:------------|:-----------|:--------------|:---------------|:------------|:--------------|
| linear      | quad       | cubic         | sin            | exp         | circle        |
| elastic     | back       | bounce        | linear-in      | quad-in     | cubic-in      |
| sin-in      | exp-in     | circle-in     | elastic-in     | back-in     | bounce-in     |
| linear-out  | quad-out   | cubic-out     | sin-out        | exp-out     | circle-out    |
| elastic-out | back-out   | bounce-out    | linear-in-out  | quad-in-out | cubic-in-out  |
| sin-in-out  | exp-in-out | circle-in-out | elastic-in-out | back-in-out | bounce-in-out |

Table 2: 动画转场特效

`animation_opts()` 的其它默认参数设置见 `plotly:::animation_opts_defaults()`。

<div class="rmdwarn">

动画播放和暂停的控制按钮一直有问题，即点击播放后，按钮不会切换为暂停按钮，点击暂停后也不能恢复，详见 plotly 包的 Github [问题贴](https://github.com/plotly/plotly.R/issues/1207)。然而，Python 版的 plotly 模块制作此[动画](https://plotly.com/python/animations/)，一切正常，代码也紧凑很多，请读者接着往下看[^3]。

</div>

## plotly （Python 语言版）

<!-- 
plotly express io color 等子组件，绘图组件包含的图形种类
绘制结构图，提供概览
-->

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
    # 动画标题
    title = "各国人均寿命与人均GDP关系演变",
    # 设置横纵坐标轴标题
    labels={
        "gdpPercap": "人均 GDP (美元)",
        "lifeExp": "人均寿命 (岁)",
        "year": "年份",
        "continent": "大洲",
        "country": "国家",
        "pop": "人口总数"
    },
    # 调用来自 colorbrewer 的 Set2 调色板
    color_discrete_sequence=px.colors.colorbrewer.Set2
)
```

<figure>
<video src="https://user-images.githubusercontent.com/12031874/145701692-d2847ae6-6646-4fc7-bf9d-031a4e262555.mov" class="full" controls=""><a href="https://user-images.githubusercontent.com/12031874/145701692-d2847ae6-6646-4fc7-bf9d-031a4e262555.mov">Figure 5: Python 版 plotly 制作动画</a></video><figcaption aria-hidden="true">Figure 5: Python 版 plotly 制作动画</figcaption>
</figure>

### 调色板

值得一提的是，支持丰富的调色板，涵盖常用的三大类型：无序的分类调色板、有序的分类调色板、连续型的调色板。调用其中一个调色板，只需 `px.colors.qualitative.Set2` 或者其逆序版本 `px.colors.qualitative.Set2_r`。也只需两行代码即可预览任意一组调色板， colorbrewer 调色板见图<a href="#fig:plotly-colorbrewer">6</a>。

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
<img src="/img/plotly-colorbrewer.png" class="full" alt="Figure 6: plotly 的 colorbrewer 调色板" /><figcaption aria-hidden="true">Figure 6: plotly 的 colorbrewer 调色板</figcaption>
</figure>

``` python
import plotly.express as px
# 提取 2007 年的数据
df = px.data.gapminder().query("year == 2007")
# 2007 年世界平均寿命
avg_lifeExp = (df["lifeExp"] * df["pop"]).sum() / df["pop"].sum()
# 绘制瓦片图/围栏图
fig = px.choropleth(
    df,
    locations="iso_alpha",
    color="lifeExp",
    color_continuous_scale=px.colors.diverging.BrBG,
    color_continuous_midpoint=avg_lifeExp,
    title="2007 年世界平均寿命 %.1f（岁）" % avg_lifeExp,
    labels={
        "iso_alpha": "国家编码",
        "lifeExp": "人均寿命 (岁)"
    }
)
fig.show()
```

<!-- 
补充 plotly 保存 SVG 图形的代码

fig.write_image('gapminder-plotly-choropleth.svg')
-->

### 图形主题

类似 ggplot2 的主题设置，Plotly Express 也是支持 自定义[风格样式](https://plotly.com/python/styling-plotly-express/)的，其中[图形主题](https://plotly.com/python/templates/) 最为方便快捷。默认主题为 `plotly`，可用的有：

``` python
import plotly.io as pio
pio.templates
```

    Templates configuration
    -----------------------
        Default template: 'plotly'
        Available templates:
            ['ggplot2', 'seaborn', 'simple_white', 'plotly',
             'plotly_white', 'plotly_dark', 'presentation', 'xgridoff',
             'ygridoff', 'gridon', 'none']

只需将 `template="none"` 换为以上任意一种即可获得不一样的效果。

<figure>
<video src="https://user-images.githubusercontent.com/12031874/145711359-1fc543bd-d371-408b-abc0-929ae8fba4e4.mov" class="full" controls=""><a href="https://user-images.githubusercontent.com/12031874/145711359-1fc543bd-d371-408b-abc0-929ae8fba4e4.mov">Figure 7: plotly 的暗黑主题</a></video><figcaption aria-hidden="true">Figure 7: plotly 的暗黑主题</figcaption>
</figure>

## 举一反三

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

熟悉 **ggplot2** 绘图的读者，可能立马联想到这不和函数 `qplot()` 一样吗？是的，惊人地相似，请注意看下面绘图部分的代码和图<a href="#fig:gapminder-qplot">8</a>，也是将数据和几何元素、图层建立关系。

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
# 关闭图形设备
dev.off()
```

<figure>
<img src="/img/gapminder-qplot.svg" class="full" alt="Figure 8: ggplot2 快速绘图函数qplot()" /><figcaption aria-hidden="true">Figure 8: <strong>ggplot2</strong> 快速绘图函数<code>qplot()</code></figcaption>
</figure>

当然，如果想更加精细地绘制复杂图形，还是要学习 [`ggplot()` 函数](https://ggplot2.tidyverse.org/reference/ggplot.html)，在 Python 里也是一样，你需要放弃调用 **plotly.express** 组件，转向学习低水平绘图的 API [Graph Objects](https://plotly.com/python-api-reference/plotly.graph_objects.html#graph-objects)。

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

[WebGL](https://www.khronos.org/webgl/)是一种 JavaScript API，可以使用计算机的 GPU 硬件资源加速 2D 和 3D 图形渲染，2011 年发布 1.0 规范，2017 年完成 2.0 规范，目前，主流浏览器 Safari、Chrome、Edge 和 Firefox 等均已支持。

本节利用 **ggplot2** 包内置的钻石数据集 diamonds，它有 53940 条记录，
WebGL 技术可以极大地加速大规模数据集渲染展示，虽说在这个数据集用 WebGL，有点杀鸡用牛刀，但是足以展示用和不用之间的差异，而在更大规模的数据集上，比如百万、千万级别，性能差异将会更加凸显 WebGL 的相对优势。

[plotly.js](https://github.com/plotly/plotly.js) 提供很多图层用于绘制各类图形，见[plotly.js 源码库](https://github.com/plotly/plotly.js/tree/master/src/traces)，其中支持 WebGL 的有热力图 `heatmapgl`、 散点图 `scattergl` 和极坐标系下的散点图 `scatterpolargl`。

Apache Echarts 支持 WebGL 的图形有散点图、路径图、矢量场图、网络图，详见官方[示例文档](https://echarts.apache.org/examples/zh/index.html)，大规模的数据可视化需要比较好的硬件资源支持。

[**mapdeck**](https://github.com/SymbolixAU/mapdeck) 提供了 [Deck.gl](https://github.com/visgl/deck.gl) 和 [Mapbox](https://github.com/mapbox/mapbox-gl-js) 的 R 语言接口，Deck.gl 号称是 WebGL 2.0 加持的高性能大规模数据可视化渲染组件，也是以 MIT 协议开源的软件，而后者是商业收费软件。

## echarts4r

## plotly

函数 `plot_ly()` 的图形类型参数 `type= "scatter"` 替换为 `type= "scattergl"`，即可从普通散点图切换到有 WebGL 加速的散点图，直观感受就是鼠标悬浮散点上并拖动带来的流畅感。**plotly** 包还提供函数 `toWebGL()` 实现转化 WebGL 的转化。

``` r
# 普通散点图
plot_ly(data = diamonds,
  x = ~carat, y = ~price, color = ~cut,
  type = "scatter", mode = "markers"
)
# WebGL 散点图
plot_ly(data = diamonds,
  x = ~carat, y = ~price, color = ~cut,
  type = "scattergl", mode = "markers"
)
# 普通散点图转化为 WebGL 散点图
plot_ly(data = diamonds,
  x = ~carat, y = ~price, color = ~cut,
  type = "scatter", mode = "markers"
) %>% 
  toWebGL()
```

[rasterly](https://github.com/plotly/rasterly) 包是受到[datashader](https://github.com/holoviz/datashader/)项目启发，希望借助 plotly.js 和 **plotly** 实现百万、乃至千万级别的空间位置数据的渲染和可视化，探索和分析空间点模式，挖掘空间聚集分布规律。

``` r
library(rasterly)
plotly::plot_ly(quakes, x = ~long, y = ~lat) %>%
  add_rasterly_heatmap()

rasterly(data = quakes, mapping = aes(x = long, y = lat)) %>%
  rasterly_points()

# 读取原始数据
# uber 轨迹数据来自 https://github.com/plotly/rasterly
uber <- readRDS(file = 'data/uber.rds')
```

# 其它工具

## Python 的 matplotlib

Python 绘图模块 matplotlib 的[animation](https://matplotlib.org/stable/api/animation_api.html)

## Julia 的 Plots.jl

Julia 的 [Plots.jl](https://github.com/JuliaPlots/Plots.jl) 包

企业级数据大屏、数据可视化 [MapGL](https://github.com/shiliangL/vue-datav-mapgl)

## JavaScript 的 three.js

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

[^1]: 话又说回来，mikefc 的个人博客干货很多，而且非常高产，推荐读者看看 <https://coolbutuseless.github.io/>。

[^2]: 读者看到 `plot_ly(fill = ~"",...)` 可能会奇怪，为什么参数 `fill` 的值是空字符串？这应该是 plotly 的 R 包或 JS 库的问题，不加会有很多警告：

        `line.width` does not currently support multiple values.

    笔者是参考[SO](https://stackoverflow.com/questions/52692760/)的帖子加上的。

[^3]: 最后，顺便一说，添加如下 CSS 可以去掉图形右上角烦人的工具条。

    ``` css
    .modebar {
      display: none !important;
    }
    ```
