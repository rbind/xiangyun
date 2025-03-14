---
title: 我曾用过的 ImageMagick 命令
author: 黄湘云
date: '2025-03-14'
slug: imagemagick
categories:
  - 开源软件
tags:
  - ImageMagick
---

{{< toc >}}

[ImageMagick](https://imagemagick.org/) 是一个功能非常丰富且强大的图像处理工具，本文积攒一些平时用到的命令。

# 安装 ImageMagick

```bash
brew install imagemagick
```

# 将 HEIC 图片转为 JPG 格式

苹果手机拍照获得的图片是 HEIC 格式的，当传输到电脑里，当想在博客、文章中使用时，必须先转化为 jpg 或 png 格式。
将 HEIC 格式图片转化为其他格式，如 jpg 。

```bash
magick input.heic -quality 100% output.jpg
```

批量转化 HEIC 格式图片，将 HEIC 格式图片都转化为 jpg 格式。

```bash
magick mogrify -format jpg *.HEIC
```

# 裁剪图片中多余的内容


`magick` 命令可以操作图片，添加参数 `-chop` 可以裁剪图片，参数 `-gravity` 指定方向。
从图片左侧开始裁剪掉 500 像素/行。（每一张图片都有以像素为单位的长度和宽度）


```bash
magick input.png -gravity West -chop 500x0 output.png
```

`-gravity South` 从图片下面开始裁剪掉 500 像素/行

```bash
magick input.jpg -gravity South -chop 500x0 output.jpg
```

类似地，从右侧、上面分别裁剪

```bash
magick input.jpg -gravity East -chop 500x0 output.jpg
magick input.jpg -gravity North -chop x500 output.jpg
```

我的博客主页挂出的图片就是这样裁剪出来的。

{{< figure
src="/img/song2.jpg"
caption="原图"
>}}

{{< figure
src="/img/song.jpg"
caption="裁剪后的图"
>}}

# 缩放图片以适应尺寸要求


将图片的长宽按照相同的比例缩小或放大。
比如原图的长为 200 像素，宽为 100 像素，那么执行如下命令后，
图片的长缩小为 100 像素，宽缩小为 50 像素。

```bash
magick input.jpg -resize 50% output.jpg
```

{{< figure
src="/img/song3.jpg"
caption="缩小后的图"
>}}

# 转 PDF 文档为 GIF 动图

将 LaTeX 制作的幻灯片转化为 GIF 格式动图

```bash
magick -delay 250 -density 300x300 -geometry 960x720 beamer.pdf beamer.gif
```

- 参数 `-delay` 幻灯片每一页切换时的延时
- 参数 `-density` 幻灯片的清晰程度
- 参数 `-geometry` 幻灯片的长和宽

我在文章[《R Markdown 制作 beamer 幻灯片（2022 版）》](/2022/08/beamer-not-down/)中大量使用了这招，
为的是让读者快速看到编译 LaTeX 代码后的文档效果。

![](https://user-images.githubusercontent.com/12031874/182385716-21d5f3de-4292-40a3-bcfb-25686b91585d.gif)

# 转 PDF 图片为 PNG 图片

如果是一张 PDF 格式的矢量图形，将其转化为其它格式，如 PNG 格式，命令如下

```bash
magick -density 300x300 -geometry 960x720 input.pdf output.png
```

与转动态 GIF 图类似，仅仅去掉参数 `-delay`。
