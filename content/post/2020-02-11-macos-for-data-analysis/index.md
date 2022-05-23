---
title: R 软件源码 MacOS
date: '2022-02-11'
author: 黄湘云
slug: r-devel-macos
categories:
  - R 语言
tags:
  - 源码编译
link-citations: true
bibliography: 
  - refer.bib
description: "R 软件源码编译"
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

blockquote > p:last-child {
  text-align: right;
}
blockquote > p:first-child {
  text-align: inherit;
}
</style>

<div class="rmdinfo">

本文引用的所有信息均为公开信息，仅代表作者本人观点，与就职单位无关。

</div>

# 编译安装

``` bash
brew install ghostscript imagemagick optipng graphviz 
brew install openjdk@11
```

``` bash
../source/configure --prefix=/Users/xiangyun/R-devel \
  --x-libraries=/opt/X11/lib/ --x-includes=/opt/X11/include \
  --enable-R-shlib --enable-BLAS-shlib --enable-memory-profiling
```

# 字体配置

``` bash
# 字体库
brew tap homebrew/cask-fonts
# 中文字体
brew install --cask font-noto-sans-cjk-sc font-noto-serif-cjk-sc
# 英文字体
brew install --cask font-source-code-pro font-source-sans-pro  font-source-serif-pro
# 漫画字体
brew install --cask font-xkcd
# 表情字体
brew install --cask font-noto-emoji font-noto-color-emoji
```

## 字体使用

LaTeX 宏包 **xecjk** 支持中文，不必使用 **ctex** 宏包，MacOS 系统上，在 LaTeX 文档里使用 Windows 系统上的黑体、宋体、仿宋、楷体四款中文字体。

``` tex
\setCJKmainfont[ItalicFont={KaiTi_GB2312}, BoldFont={SimHei}]{SimSun}
\setCJKsansfont{SimHei}
\setCJKmonofont{FangSong_GB2312}

\setCJKfamilyfont{heiti}{SimHei}             
\newcommand{\heiti}{\CJKfamily{heiti}}

\setCJKfamilyfont{kaishu}{KaiTi_GB2312}             
\newcommand{\kaishu}{\CJKfamily{kaishu}}

\setCJKfamilyfont{songti}{SimSun}             
\newcommand{\songti}{\CJKfamily{songti}}

\setCJKfamilyfont{fangsong}{FangSong_GB2312}             
\newcommand{\fangsong}{\CJKfamily{fangsong}}
```
