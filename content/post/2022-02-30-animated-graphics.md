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
thumbnail: /img/gganimate.svg
link-citations: true
bibliography: 
  - refer.bib
description: "凡是可以自己动的图形都称之为「动态图形」，这种图形的存在形式有 Flash、GIF 和 MP4 等"
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

简单交代交待一下与之前介绍的[交互式图形](/2021/11/interactive-web-graphics)的区别，提及一下《现代统计图形》里关于 **rgl** 和 **animation** 包的介绍，本文重点介绍 gganimate 和 echarts4r 等更加现代化的工具和技术，以及笔者在使用动态图形展示数据方面的经验和教训。

**rayrender** 渲染复杂场景，没有外部依赖
RStudio 大会上的介绍，推荐其替代 rgl 制作 。

三维场景建模、动画渲染等领域，Autodesk 的 Maya 和 3D Max

领域内相关商业软件有 相关开源软件有 three.js

[Blender](https://www.blender.org/) GPL 协议开源的自由免费软件，GitHub 上存放了[源码镜像](https://github.com/blender/blender)。

好看但是没什么卵用的 R 包 [rayrender](https://github.com/tylermorganwall/rayrender) 3D 图形

《动画制作与 R 语言》animated-graphics 近 10 余年中国市级 GDP 分布，用 **echarts4r** 和 **plotly** 制作动画 gdp-animation

-   rust 库 [gifski](https://gif.ski/) 和 [gifski](https://github.com/r-rust/gifski) R 包制作动图
-   imagemagick 独立软件 制作动图
-   ffmpeg 独立软件 制作视频
-   gganimate R包 制作动图或视频

``` bash
brew install rust
cargo install gifski
```

在 `~/.cargo/config` 里配置就近的镜像地址加快[cargo](https://github.com/nabijaczleweli/cargo-update)下载速度

    [source.crates-io]
    replace-with = "sjtu"

    [source.sjtu]
    registry = "https://mirrors.sjtug.sjtu.edu.cn/git/crates.io-index"

将路径 `~/.cargo/bin` 添加到 PATH 变量里
