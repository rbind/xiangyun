---
date: "2020-11-29"
slug: reproducible-analysis
title: 可重复性数据分析
categories:
  - R 语言
tags:
  - 文学编程
  - R Markdown
  - 可重复性研究
description: "文学编程是一种新的编程范式，在 1984 年由[唐纳德·高德纳](https://en.wikipedia.org/wiki/Donald_Knuth)首次提出，相比于传统的编程语言，它以自然语言的形式表达计算逻辑，文本和代码相互混合，从计算机代码的执行逻辑过渡到人的思维逻辑。"
draft: true
---

可重复性的层次：计算可重复性、本身是否能够可重复、可重复的成本是否足够低，越低越能够被人采纳和使用，推广更容易

## 文学编程

文学编程是一种新的编程范式，在 1984 年由 [唐纳德·高德纳](https://en.wikipedia.org/wiki/Donald_Knuth)  首次提出，相比于传统的编程语言，它以自然语言的形式表达计算逻辑，文本和代码相互混合，从计算机代码的执行逻辑过渡到人的思维逻辑。

大家熟知的 LaTeX 其实也是一种文学编程，发展到现在，Sweave、R Markdown 和 Jupyter 身上都由文学编程的影子。相比于 Word、Excel 和 PowerPoint，它们更易版本控制和团队协作，计算过程可重复，工作效率更高，经验可沉淀，更让我们专注思考本身，而尽量少去管排版，从编辑的工作中解放出来，做作者真正该做的事。

## R Markdown

R 软件自带的一种文学编程形式是 Sweave（编织）和 Stangle（缠结），[knitr](https://yihui.org/knitr/) 受此启发，这也是为什么后来 knitr 的图标设计成织毛衣的形象 <img width="3%" src="https://user-images.githubusercontent.com/12031874/103172964-86449a00-4892-11eb-8288-8bbdab506066.png">。下面先介绍一下 Sweave 的工作流程。

![sweave-workflow](https://user-images.githubusercontent.com/12031874/103164245-c6306080-4843-11eb-9e93-6c15354204b1.png)


**utils** 提供两个函数 `Sweave()` 和 `Stangle()` 

```r
testfile <- system.file("Sweave", "Sweave-test-1.Rnw", package = "utils")
```

调 R 解释器执行 Rnw 文档中的代码块，计算的计算，出图的出图

```r
Sweave(testfile)
```
```
Writing to file Sweave-test-1.tex
Processing code chunks with options ...
 1 : keep.source print term verbatim (Sweave-test-1.Rnw:15)
 2 : keep.source term hide (Sweave-test-1.Rnw:17)
 3 : echo keep.source print term verbatim (Sweave-test-1.Rnw:22)
 4 : keep.source term verbatim (Sweave-test-1.Rnw:30)
 5 : echo keep.source term verbatim (Sweave-test-1.Rnw:45)
 6 : echo keep.source term verbatim pdf  (Sweave-test-1.Rnw:53)
 7 : echo keep.source term verbatim pdf  (Sweave-test-1.Rnw:63)

You can now run (pdf)latex on 'Sweave-test-1.tex'
```

抽取 Rnw 文档中的代码块单独存成文件 Sweave-test-1.R

```r
Stangle(testfile)
```
```
Writing to file Sweave-test-1.R 
```

将 Sweave-test-1.tex 编译成 PDF 需要一些额外的 LaTeX 宏包

```r
tinytex::tlmgr_install(c('a4wide', 'ntgclass', 'ae'))
```
```
tlmgr install a4wide ntgclass ae
tlmgr: package repository https://mirrors.cqu.edu.cn/CTAN/systems/texlive/tlnet (verified)
[1/3, ??:??/??:??] install: a4wide [1k]
[2/3, 00:01/01:13] install: ae [57k]
[3/3, 00:01/00:01] install: ntgclass [16k]
running mktexlsr ...
done running mktexlsr.
tlmgr: package log updated: /opt/TinyTeX/texmf-var/web2c/tlmgr.log
```

然后编译

```r
tools::texi2pdf("Sweave-test-1.tex")
```

输出结果如下

![output](https://user-images.githubusercontent.com/12031874/103172742-8e9bd580-4890-11eb-8125-8d0826bbdb0d.png)


rmarkdown 自 2014 年登陆 CRAN 以来，自身功能不断加强，在 RStudio IDE 的加持下越来越易用，周边生态支持越来越完善，应用场景越来越多，比如写书做笔记、搭建个人博客、制作网页幻灯片、开发数据面板等等。它站在 Pandoc (<https://pandoc.org/>) 这个巨人的肩膀上，得益于开源社区的努力，近年来，Pandoc 发展越来越快，功能越来越强，也越来越稳定，个人感受最深的是对 LaTeX 支持，这也是让我的幻灯片和论文从 LaTeX 彻底切换到 R Markdown 的重要原因。

![rmarkdown-ecology](https://user-images.githubusercontent.com/12031874/103164243-c3357000-4843-11eb-8ccd-84c57bf0f526.png)

R Markdown 丰富的格式输出，灵活的定制方式，以 PDF 格式的报告为例，背景水印，双栏排版，交叉引用，定制环境，脚注公式、中英字体等 LaTeX 支持的文档设置都可以支持。完整的 R Markdown 模版见[链接](https://github.com/XiangyunHuang/masr/blob/master/examples/pdf-document.Rmd)

![pdf-documents](https://user-images.githubusercontent.com/12031874/103166609-d6a20480-485e-11eb-89d3-8f3882700912.png)

下面介绍 R Markdown 制作的幻灯片，此汉风主题由 [林莲枝](https://github.com/liantze/pgfornament-han/) 开发，LaTeX 宏包已发布在 [CTAN](https://www.ctan.org/pkg/pgfornament-han) 上，使用此幻灯片主题需要将相关的 LaTeX 宏包一块安装。

```bash
tlmgr install pgfornament pgfornament-han needspace xpatch
```

完整的 R Markdown 模版见[链接](https://github.com/XiangyunHuang/masr/blob/master/examples/beamer-pgfornament-han.Rmd)

![beamer-slides](https://user-images.githubusercontent.com/12031874/103167172-bc1e5a00-4863-11eb-89fb-d5378db3bc50.gif)

接着，我们再介绍一下 R Markdown 制作的书籍模版 [ElegantBookdown](https://github.com/XiangyunHuang/ElegantBookdown)，几年前，我看到[邓东升](https://ddswhu.me/)和[黄晨成](https://liam.page/)制作的 LaTeX 书籍模版 [ElegantBook](https://github.com/ElegantLaTeX/ElegantBook) 颜值很高，就想把它 bookdown 化，如今终于如愿了！而且，哈尔滨商业大学的张敬信老师用它来写书[《R语言编程--基于 tidyverse》](https://github.com/zhjx19/introR)，我自己的几本开源笔记也受此风格影响。


![ElegantBookdown](https://user-images.githubusercontent.com/12031874/103174181-f7884b00-489a-11eb-9464-7b254a1aaa23.gif)


## 可重复性研究


可重复计算，可容易重复，重复效率高，软件框架生态好，都对数据价值的交流带来重要影响。以贝叶斯数据分析领域的马尔可夫蒙特卡洛方法为例，1989  年剑桥大学临床医学院的生物统计系主导了 **BUGS**（**B**ayesian inference **U**sing **G**ibbs **S**ampling）项目，开发出了 [WinBUGS](https://www.mrc-bsu.cam.ac.uk/software/bugs/the-bugs-project-winbugs/)，后来项目停止开发，但是研究人员开发出了**开源跨平台**的替代品 [OpenBUGS](https://en.wikipedia.org/wiki/OpenBUGS)，再后来衍生出 [JAGS](https://en.wikipedia.org/wiki/Just_another_Gibbs_sampler)，在跨平台和效率提升方面不断前进。时至今日，为适应现代计算机的硬件架构和数据规模，贝叶斯主流计算框架已经开始过渡到 [Stan](https://github.com/stan-dev/) 和 [probability](https://github.com/tensorflow/probability)，提供更加丰富和强大的概率推理和统计分析能力，Stan 社区特别活跃，学术成果会很快更新到软件中，而后者隶属 tensorflow 生态，顶着的光环更大。近日，[Andrew Gelman](https://en.wikipedia.org/wiki/Andrew_Gelman) 等人牵头提出完整的现代贝叶斯数据分析工作流，见下图。

![bayesian-workflow](https://user-images.githubusercontent.com/12031874/103152445-07346080-47c3-11eb-90ce-531860e71689.png)

面对当前大数据环境下的挑战，以 Hadoop 生态为代表的大规模数据基础设施，以容器集群为代表的弹性扩展的分布式计算承担越来越重要的角色，计算成本和效率问题已经越来越突出。在计算可重复的数据分析流程中，处于底层支撑角色，常常看不到却是非常重要的。

郁彬探讨数据科学的三个原则：可预测性、稳定性和可计算性，并阐述在数据驱动决策中的内在联系和重要性。机器学习以预测为中心，计算为核心，实现了相当范围的数据驱动型成功。预测是检验当下的有用方式，好的预测建立在过去和未来的稳定性之上。相对于数据和模型，稳定性是数据结果可解释性和可重复性的最小要求，可重复性是可靠性和稳健性的基础保障。


数百位学术研究人员联名提出心理学实验的可重复性问题，研究结果表明大量研究结果不可重复，或者效果不显著，或者功效没有那么大。

![reproducible-analysis](https://user-images.githubusercontent.com/12031874/103152913-7dd35d00-47c7-11eb-9cd5-cdcea39f22b7.png)

如何让问题可重复、数据可重复、计算可重复、经验可沉淀，在第 13 届中国 R 语言会议上 [统计软件专场_黄湘云](https://www.bilibili.com/video/BV1Vp4y1B7N1) 重点谈了可重复性数据分析的工作流，我们身处大数据时代的潮头，挖掘数据中的价值。

数据可重复就是要保证数据的统一性，准确性和一致性，在企业里，数据最好只加工一次，只有一个出口，如果每个部门每个需要的人都定义和计算搜索的 QV_CTR，最后会浪费时间和资源，它的口径应当由搜索部唯一定义和维护，若其他部门需要，直接来同步就可以，千万不要自搞一套逻辑，计算逻辑本身很复杂，也别想着能整明白。计算可重复，上面已经介绍很多了，这里不再赘述。检验可沉淀，即数据到结论到价值的过程可以文档化管理，但是在企业里，往往是每个人只赋予工作所需的最小数据集和访问权限，即使有这么个文档中心，也不是人人可看的，甚至生产小组内都不是人人可获得的。


<!--
如果我们真的是为算法组服务，那么我们是需要真的了解他们的工作内容，了解的范围是算法模型相关的概念，知晓其原理和业务含义，数据分析和建模的流程，而不是弄清楚算法的底层实现和数理统计层面的公式推导，以及工程上的技术实现。后面三块是算法工程师的核心基础能力。作为数据研发工程师可以暂不关心，也不是短时间内可以搞得定的内功，具有相关背景当然更好。
-->


## 参考文献

1. Literate Programming, R Markdown, and Reproducible Research, Yihui Xie, 2020. <https://slides.yihui.org/2020-covid-rmarkdown.html>
1. Higher, further, faster with Marvelous R Markdown, [Thomas Mock](https://themockup.blog/), 2020, <https://bit.ly/marvelRMD>
1. 在 LaTeX 中进行文学编程, 黄晨成, 2015, <https://liam.page/2015/01/23/literate-programming-in-latex/>
1. <https://github.com/ElegantLaTeX/ElegantBook>
1. Sweave：打造一个可重复的统计研究流程, 谢益辉 <https://cosx.org/2010/11/reproducible-research-in-statistics/>
1. Sweave User Manual, Friedrich Leisch and R Core Team, <https://stat.ethz.ch/R-manual/R-devel/library/utils/doc/Sweave.pdf>
1. The Rocker Project: Docker Containers for the R Environment, Carl Boettiger & Dirk Eddelbuettel <https://github.com/rocker-org/rocker>
1. R 语言历史: R 进入 4.0 时代 <https://jozef.io/r921-happy-birthday-r/>
1. 数据科学工具学习指导 <https://github.com/shervinea/mit-15-003-data-science-tools>
1. Andrew Gelman, Aki Vehtari, Daniel Simpson, Charles C. Margossian, Bob Carpenter, Yuling Yao, Lauren Kennedy, Jonah Gabry, Paul-Christian Bürkner, and Martin Modrák (2020). Bayesian workflow. <https://arxiv.org/abs/2011.01808> and <https://github.com/jgabry/bayes-workflow-book>
1. Three Principles of Data Science: Predictability, Stability and Computability. 2017. Bin Yu,  <https://doi.org/10.1145/3097983.3105808>
1. Veridical Data Science, 2019, Bin Yu and Karl Kumbier <https://arxiv.org/abs/1901.08152>
1. 心理学的危机, 2017, 杨洵默, <https://cosx.org/2017/09/psychology-in-crisis/>
1. Estimating the reproducibility of psychological science. 2015, Science, 349 (6251). <https://science.sciencemag.org/content/349/6251/aac4716>
1. https://en.wikipedia.org/wiki/Literate_programming

---

## 附录

### 制作流程图

nomnoml 调 webshot 包对网页截图生成 PNG 格式的图片，其中 webshot 调 phantomjs 软件

```r
# R Markdown 生态图
nomnoml::nomnoml(" 
#stroke: #34A853
#fill: white
#fillArrows: false
#direction: down

[knitr]    -> [动态文档|rmarkdown]
[Pandoc]   -> [动态文档|rmarkdown]
[Markdown] -> [动态文档|rmarkdown]
[动态文档] -> [书籍笔记|bookdown]
[动态文档] -> [静态网站|blogdown]
[动态文档] -> [幻灯片|xaringan]
[幻灯片]   -> [PowerPoint|officedown]
[书籍笔记] -> [毕业论文|thesisdown]
[静态网站] -> [个人简历|pagedown]
[动态文档] -> [数据面板|flexdashboard]
[数据面板] --> [交互图形|plotly]
", png = 'rmarkdown-ecology.png')

# Sweave 工作流程图
nomnoml::nomnoml(" 
#stroke: #34A853
#.box: fill=#8f8 dashed visual=note
#direction: down

[Sweave-test-1.Rnw] -> utils::Sweave() [Sweave-test-1.tex|Sweave-test-1-006.pdf|Sweave-test-1-007.pdf]
[Sweave-test-1.Rnw] -> utils::Stangle() [Sweave-test-1.R]
[Sweave-test-1.tex] -> tools::texi2pdf() [Sweave-test-1.pdf]
[Sweave-test-1.tex] -> tools::texi2dvi() [Sweave-test-1.dvi]
", png = 'sweave-workflow.png')
```

### PDF 文档截图

将 PDF 文档高清晰截图操作如下

```bash
convert -quality 100 -density 300x300 pdf-document.pdf pdf-document.png
```

### 合成 GIF 图

```bash
# 图片合成 GIF 动图
convert -delay 60 input.png output.gif  
```
```bash
#!/bin/bash  
# 多页 PDF 转化为 PNG 图片
convert -quality 100 -density 300x300  input.pdf output.png
# 以白色背景替换透明背景
for i in $(seq 0 17)
do   
  echo convert input-$i.png -background white -alpha remove -flatten -alpha off output-$i.png
done 
```
