---
title: beamer 不 down
subtitle: R Markdown 制作 beamer 学术幻灯片
author: 黄湘云
date: '2021-05-01'
slug: beamer-down
categories:
  - 统计软件
tags:
  - TinyTeX
  - LaTeX
  - beamer
  - R Markdown
description: "LaTeX 提供 beamer 文类主要用于学术报告，从面上来看，好多主题是大学开发的，大家不约而同地使用蓝调，看多了想睡觉。目前，现代风格的 beamer 主题已经陆续涌现出来，本文旨在介绍一条 R Markdown 制作 beamer 幻灯片的入坑路径，让 beamer 看起来更加清爽些！"
---

相信绝大多数人对 beamer 制作的学术幻灯片记忆犹新，作者之前收集和修改过很多幻灯片的模版，见[awesome-beamers](https://github.com/XiangyunHuang/awesome-beamers)列表，本文准备介绍如何将 beamer 主题搬迁到 R Markdown 生态里，提及迷你的 LaTeX 发行版 TinyTeX，metropolis 主题模版等。

## 安装 TinyTeX

在平时常用 R Markdown 相关工具，建议先安装 R 包 [**tinytex**](https://github.com/yihui/tinytex)，然后用它安装 TinyTeX 这个发行版，在 R 环境里，这一切会比较顺畅，讲真，配置环境什么的最烦了，一次两次三四次，五次六次七八次，但是学什么的时候最好从配置环境开始，记录从第一次安装开始，后面会越来越快！

```r
tinytex::install_tinytex()
```

遇到啥问题，先去益辉的网站瞅瞅 <https://yihui.org/tinytex/>，要还没找到解决方案，就来论坛 <https://d.cosx.org/> 发帖。

## 安装字体

安装字体的过程分2步走

1. 这里用 **tinytex** 安装 [fira](https://www.ctan.org/pkg/fira) 系列英文字体，[firamath](https://github.com/firamath/firamath) 和 [xits](https://www.ctan.org/pkg/xits) 数学字体，后续用作 beamer 幻灯片的主要字体，相信大家看惯了千篇一律的字体，也想换换口味吧！

    ```r
    tinytex::tlmgr_install(c("fira", "firamath-otf", "xits"))
    ```

2. 通过观察我们知道上面安装的字体都放在了 TinyTeX 的安装目录下，而且不能直接被调用，故而将它们拷贝到系统的字体目录，刷新字体目录后，通过 **fontspec** 宏包调用。为了将来更快地处理此过程，我已经代码化了，如下 

    ```r
    # TinyTeX 字体目录
    basedir <- paste(tinytex::tinytex_root(), "texmf-dist/fonts/opentype/public", sep = "/")
    # MacOS 系统字体放在 ~/Library/Fonts/ 而 Linux 系统字体放在 ~/.fonts
    distdir <- if (Sys.info()["sysname"] == "Darwin") "~/Library/Fonts/" else "~/.fonts"
    # 获取字体文件的完整路径
    fontfiles <- list.files(path = paste(basedir, c("fira", "xits", "firamath"), sep = "/"), full.names = T)
    # 拷贝到对应系统的字体目录下
    file.copy(from = fontfiles, to = distdir, overwrite = TRUE)
    ```

## metropolis 主题模版

unicode-math 数学字体样式有点怪，以前排版毕业论文的时候[坑过我一回](https://d.cosx.org/d/419931-pandoc-latex)，但未来是趋势，Pandoc 内建的 LaTeX 模版默认是 unicode-math 样式的，除非编译 LaTeX 的时候，启用 `mathspec: yes` 变量。Fira 系列字体配 metropolis 主题是比较常见的，只是 Fira Math 提供的字形有限，不得不借助 XITS Math 补位（比如下面矩阵转置的符号），后者支持是最广的。在 unicode-math 的世界里，公式环境里，加粗希腊字母，得用 `\symbf` 而不是 `\boldsymbol`。XITS Math、Fira Math 等字体数学符号的支持情况详见[文档](http://mirrors.ctan.org/macros/unicodetex/latex/unicode-math/unimath-symbols.pdf)。

metropolis 主题的特点就是干净利索，越简洁越好！在之前的文章[可重复性数据分析](https://xiangyun.rbind.io/2021-01-03-reproducible-analysis) 介绍过 [林莲枝](https://github.com/liantze/) 开发的汉风主题幻灯片，它也是基于 metropolis 主题。话不多说，直接上代码，说了这么多，实际只有十几行哈哈！！

```tex
\documentclass[169]{beamer}

\usefonttheme{professionalfonts}
\usetheme{metropolis}

\usepackage{fontspec}
\setsansfont[BoldFont={Fira Sans SemiBold}]{Fira Sans Book}

\usepackage{amsmath}
\usepackage{amssymb}

\usepackage[
  mathrm=sym,
  math-style=ISO,  % Greek letters also in italics
  bold-style=ISO,  % bold letters also in italics
]{unicode-math}

\setmathfont{Fira Math} % https://github.com/firamath/firamath
% top is still missing in Fira Math, get it from another font
\setmathfont[range={\top}]{XITS Math}

\begin{document}
  \begin{frame}[t]{Example}
    \begin{align}
      \symbf{\theta} &= (1, 2, 3)^\top \\
            \theta_0 &= 1
    \end{align}
  \end{frame}
\end{document}
```


学过 MCMC 算法的都知道 metropolis 是啥，其实也不是啥东西，只是我当年掉在 MCMC 的大坑里好多时间，以至于将 metropolis 和 MCMC 建立了极强的关联，可能这也是我介绍 beamer 主题也拿它来举例的原因吧！回到正题，Pandoc 内建的 [LaTeX 模版](https://github.com/jgm/pandoc/blob/master/data/templates/default.latex) 功能已经很丰富了，通常用不着自己配置了，R Markdown 自从接入 tinytex 自动装缺失的 LaTeX 宏包的功能后，在产出 PDF 文档方面已经方便多了。

将上面的模版内容保存到文件 `slide-template.tex`，接下来，有两种编译 LaTeX 文件的方式，一种在 RStudio 内打开，点击 `Compile PDF` 按钮，一种是调用命令

```r
tinytex::xelatex(file = "slide-template.tex")
```

编译出来的效果如下

![slide-template](https://user-images.githubusercontent.com/12031874/116777926-a1722100-aaa1-11eb-92c7-034ebfb90922.png)


用 Adobe Acrobat Reader DC 打开 `文件->属性->字体` 可以看到 PDF 文档中确切使用的字体，如图所示

![check-fonts](https://user-images.githubusercontent.com/12031874/119227132-0bc92f00-bb3f-11eb-8610-8d3eb6572401.png)

beamer 默认的主题提供了一些 block 样式，比如 exampleblock、alertblock、block 等。

````
::: {.exampleblock data-latex="{提示}"}
提示
:::
````

当然，有些主题还有自定义的 block 样式，像引用

````
::: {.quotation data-latex="[John Gruber]"}
A Markdown-formatted document should be publishable as-is, as plain text, 
without looking like it’s been marked up with tags or formatting instructions.  
:::
````

此处，不一一介绍，详情见讨论贴[don't respect beamer theme's buildin theorem/proof block](https://github.com/rstudio/bookdown/issues/1143)，上述完整的 R Markdown 模版幻灯片见[链接](https://github.com/XiangyunHuang/masr/blob/master/examples/beamer-verona.Rmd)。最近，R Markdown 又提供一些新的特性，读者不妨去看看 <https://blog.rstudio.com/2021/04/15/2021-spring-rmd-news/>。


## R Markdown 模版

R Markdown 文档开头处为 YAML 元数据，它分两部分：其一是 Pandoc 变量值，其二是文档输出设置。下面是一份完整的 YAML，内容十分丰富，读者可以注释和编译交替进行，细节就不说了，可以看看后面的参考文献，慢慢把玩！

````yaml
---
title: "R Markdown 制作 beamer 幻灯片"
author:
  - 黄湘云
  - 李四
institute: "xxx 大学学院"
date: "`r Sys.Date()`"
documentclass: ctexbeamer
output: 
  bookdown::pdf_book: 
    number_sections: yes
    toc: no
    base_format: rmarkdown::beamer_presentation
    latex_engine: xelatex
    citation_package: natbib
    keep_tex: no
    template: null
    dev: "cairo_pdf"
    theme: Verona
header-includes:
  - \logo{\includegraphics[height=0.8cm]{`r R.home('doc/html/Rlogo')`}}
  - \usepackage{pifont}
  - \usepackage{iitem}
  - \setbeamertemplate{itemize item}{\ding{47}}
  - \setbeamertemplate{itemize subitem}{\ding{46}}
themeoptions: 
  - colorblocks
  - showheader
  - red
biblio-style: apalike
bibliography: 
  - packages.bib
classoption: "UTF8,fontset=adobe,zihao=false"
link-citations: yes
section-titles: false
biblio-title: 参考文献
colorlinks: yes
---
````

结合 Pandoc 内建 LaTeX 模版，你会发现，除了 output 字段下的键值对，其它都在。`header-includes` 相当于 premble （LaTeX 文档的导言区）。下面再以 beamer 文档中主题的设置为例，加以说明

```latex
$if(beamer)$
$if(theme)$
\usetheme[$for(themeoptions)$$themeoptions$$sep$,$endfor$]{$theme$}
$endif$
$if(colortheme)$
\usecolortheme{$colortheme$}
$endif$
$if(fonttheme)$
\usefonttheme{$fonttheme$}
$endif$
$if(mainfont)$
\usefonttheme{serif} % use mainfont rather than sansfont for slide text
$endif$
$if(innertheme)$
\useinnertheme{$innertheme$}
$endif$
$if(outertheme)$
\useoutertheme{$outertheme$}
$endif$
$endif$
```

而 `bookdown::pdf_book` 下的 `number_sections`、`toc` 等皆是其参数，详情可查看帮助文档 `?bookdown::pdf_book`。

> 提示
>
> 上面将 `rmarkdown::beamer_presentation` 作为 `bookdown::pdf_book` 的 `base_format` 而不是像默认的 beamer 模版那样直接引用，是为了获得交叉引用的能力。


## 参考文献

1. LaTeX 数学符号合集 <https://www.ctan.org/pkg/comprehensive/>.

1. Pandoc options for LaTeX output <https://bookdown.org/yihui/rmarkdown-cookbook/latex-variables.html>

1. Beamer presentation <https://bookdown.org/yihui/rmarkdown/beamer-presentation.html>

1. Cross-references <https://bookdown.org/yihui/bookdown/cross-references.html>
