---
title: 地泽万物，神农不死，beamer 不 down
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
thumbnail: https://user-images.githubusercontent.com/12031874/116777926-a1722100-aaa1-11eb-92c7-034ebfb90922.png
description: "LaTeX 提供 beamer 文类主要用于学术报告，从面上来看，好多主题是大学开发的，大家不约而同地使用蓝调，看多了想睡觉。目前，现代风格的 beamer 主题已经陆续涌现出来，本文旨在介绍一条 R Markdown 制作 beamer 幻灯片的入坑路径，让 beamer 看起来更加清爽些！"
---

相信很多人对 beamer 制作的学术幻灯片记忆犹新，本人之前收集和修改过很多幻灯片的模版，见[awesome-beamers](https://github.com/XiangyunHuang/awesome-beamers)列表，下面介绍如何将 beamer 主题搬迁到 R Markdown 生态里，涉及迷你的 LaTeX 发行版 TinyTeX，metropolis 主题模版等。

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
    tinytex::tlmgr_install(c("fira", "firamath", "firamath-otf", "xits"))
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

## 数学符号

在遇到花体数学符号，如常用来表示域或空间的 `$\mathcal{A,S},\mathscr{A},\mathbb{A,R}$`，抑或是常见的损失函数符号 `$\mathcal{L}$`。
unicode-math 定义的数学样式有点怪，和通常见到的不一样，以前排版毕业论文的时候[坑过我一回](https://d.cosx.org/d/419931-pandoc-latex)。

![unicode-math](https://user-images.githubusercontent.com/12031874/38676377-70e45fa4-3e8d-11e8-93d7-100e3585f490.png)

但未来是趋势，为啥？统一性，各大数学公式宏包的作用都可以集于一身，类似等价的命令，下面是对应列表

Pandoc 内建的 LaTeX 模版默认是 unicode-math 样式的，除非编译 LaTeX 的时候，启用 `mathspec: yes` 变量。Fira 系列字体配 metropolis 主题是比较常见的，只是 Fira Math 提供的字形有限，不得不借助 XITS Math 补位（比如下面矩阵转置的符号），后者支持是最广的。在 unicode-math 的世界里，公式环境里，加粗希腊字母，得用 `\symbf` 而不是 `\boldsymbol`。XITS Math、Fira Math 等字体数学符号的支持情况详见[unicode-math 宏包的官方文档](http://mirrors.ctan.org/macros/unicodetex/latex/unicode-math/unimath-symbols.pdf)。

<center>表1：不同的数学字体支持的符号数量不同 </center>

| 数学字体                                                     | 符号数量 |
| :------------------------------------------------------------ | :-------- |
| [Latin Modern Math](https://ctan.org/pkg/lm)                 | 1585     |
| [XITS Math](https://ctan.org/pkg/xits)                       | 2427     |
| [STIX Math Two](https://ctan.org/pkg/stix2-otf)              | 2422     |
| [TeX Gyre Pagella Math](https://ctan.org/pkg/tex-gyre-math-pagella) | 1638     |
| [DejaVu Math TeX Gyre](https://ctan.org/pkg/tex-gyre-math-dejavu) | 1640     |
| [Fira Math](https://ctan.org/pkg/firamath)                   | 1052     |




## metropolis 主题模版

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

![check-fonts](https://user-images.githubusercontent.com/12031874/135288310-4dad120c-a883-4732-9033-72be7b8ffe28.png)

---

最近统计之都论坛里又有人[踩](https://d.cosx.org/d/422613)到我以前[踩](https://d.cosx.org/d/419931)过的坑，这里不妨简单说一下。

````
---
title: "测试"
author:
  - 无
documentclass: ctexart
keywords:
  - 无
output:
  rticles::ctex:
    fig_caption: yes
    number_sections: yes
    toc: yes
geometry: tmargin=1.8cm,bmargin=1.8cm,lmargin=2.1cm,rmargin=2.1cm  
---

$\mathbf{\Sigma}$
````

他准备在公式环境里用 `\mathbf` 命令加粗希腊字母 `$\Sigma$`，这本身是不行的，它只能用来加粗普通的字母，如 `$A,B,C,a,b,c,X,Y,Z,x,y,z$`。加粗希腊字母，需要 `\boldsymbol` 命令，而 `rticles::ctex` 中文模版，在默认设置下，会使用 Pandoc 内建 LaTeX 模版，调用 XeLaTeX 编译，加载 unicode-math 宏包处理数学公式，此时，希腊字母对 `\boldsymbol` 命令免疫，要加粗特效，必须用 unicode-math 的专用命令 `\symbf`。

如果准备在文中统一采用 unicode-math 处理数学公式，那么，把 `\mathbf` 换成 `\symbf`，问题即告结束。但是，目前排版数学公式比较通用的方式不是 unicode-math，还是原来的 amsmath 及其扩展宏包。如何转过去呢？其实，很简单，在 YAML 里添加一行 `mathspec: yes` 即可，Pandoc 的 LaTeX 模版支持原先的方案，此时编译还是会报错，报错的主要信息如下：

```
! LaTeX Error: Option clash for package fontspec.
```

这是因为 ctexart 文类自动加载了 fontspec 宏包，而它与 mathspec 宏包冲突，所以要替换为原始的 article 文类，同时加载 ctex 宏包处理中文字符，这里采用 fandol 中文字体作为演示，所以目前最佳的解决方案如下：

````
---
title: "测试"
author:
  - 无
documentclass: article
mathspec: yes
keywords:
  - 无
output:
  rticles::ctex:
    fig_caption: yes
    number_sections: yes
    toc: yes
    template: null
    extra_dependencies:
      ctex:
       - fontset=fandol
geometry: tmargin=1.8cm,bmargin=1.8cm,lmargin=2.1cm,rmargin=2.1cm  
---

$\boldsymbol{\Sigma}$ 是希腊字母 $\Sigma$ 的加粗形式，$\mathcal{A}$ 是普通字母 $A$ 的花体形式。
````

> 提示
>
> RStudio IDE 使用 [MathJaX](https://www.mathjax.org/) 来渲染 R Markdown 文档里的数学公式，MathJaX 不支持的数学符号命令是不能预览的。来自 unicode-math 的 `\symbf` 命令是不受支持的，会高亮成红色。那支持的有哪些呢？完整的支持列表见这个[文档](https://docs.mathjax.org/en/latest/input/tex/macros/index.html)，常见的 `\mathbb` 空心体 `$\mathbb{A}$` 和 `\mathfrak` 火星体 `$\mathfrak{A}$` 来自宏包 amsfonts，`\mathscr` 花体 `$\mathscr{A}$` 和 `\bm` 粗体 `$\bm{A}$` 命令分别来自 mathrsfs 和 bm。amsmath 相关的大都支持，较为精细地调整数学公式可以去看[amsmath 文档](https://www.latex-project.org/help/documentation/amsldoc.pdf)，此处仅摘抄一例 `$\sqrt{x} +\sqrt{y} + \sqrt{z}$` 和 `$\sqrt{x} +\sqrt{\smash[b]{y}} + \sqrt{z}$`，能看出来差别的一定有一双火眼金睛！
>
> ![rstudio-mathjax](https://i.loli.net/2021/09/27/42otHGvZDOuJIxi.png)




---

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
