---
date: "2021-01-03"
slug: reproducible-analysis
title: 可重复性数据分析
categories:
  - R 语言
tags:
  - 文学编程
  - R Markdown
  - 可重复性研究
description: "唐纳德·高德纳在 1984 年首次提出文学编程的概念，文学编程是一种新的编程范式，相比于传统的编程语言，它以自然语言的形式，文本和代码相互混合方式表达计算逻辑，注意力从计算机代码的执行逻辑过渡到人的思维逻辑。"
---


在当今这个时代，「数据分析」这个词不说家喻户晓，也是耳熟能详，要是回到大约 60 年前，John W. Tukey 那个年代，你能想象吗？他不仅想了，还在思考数据分析的未来，他提到的未来就是我们的现在。数据分析，从过去到现在，面临的挑战也在变，以前的算力问题，现在似乎解决了。真的解决了吗？还是只是解决了以前的算力问题，毕竟那个年代收集处理 1MB 的数据也是很困难的，现在要面对 1PB 的数据呐！从大的层面上讲，困难是相对的，甚至比之前更困难。得益于现代的计算和存储设备，在数据层面上的探索、分析和交流更加可重复和高效，加速了数据价值的沉淀。可重复性本身也有不同的层次，今天主要讲的就是计算层面的可重复性，并且假定问题本身是具备可重复性的，用代码连贯地串起来数据分析的过程，用版本管理工具记录数据探索的过程，让这两个过程走得越顺利，意味着可重复的成本越低，成本越低越能够被人采纳和使用，推广起来更容易。下面从文学编程开始，介绍可重复性的代表工具 R Markdown，以及可重复性研究的现状，一起期待一下未来吧。

## 文学编程

谈到可重复性，不得不提及文学编程，它是一种新的编程范式，在 1984 年由 [唐纳德·高德纳](https://en.wikipedia.org/wiki/Donald_Knuth)  首次提出，相比于传统的编程语言，它强调以自然语言呈现计算逻辑，文本和代码相互混合的方式，并且从计算机代码的执行逻辑过渡到人的思维逻辑。大家熟知的 LaTeX 其实也是一种文学编程，发展到现在，文学编程的工具在不断迭代，R Sweave、[R Markdown](https://rmarkdown.rstudio.com/) 和 [Jupyter](https://jupyter.org/) 身上都有文学编程的影子。相比于 Word、Excel 和 PowerPoint，它们更易版本控制和团队协作，计算过程可重复，工作效率更高，经验可沉淀，让我们更加专注思考，而尽量少去管排版的细枝末节，从编辑的工作中解放出来，做作者主要该做的事。想象一下，一本 300 多页图文并茂的书，全程用 Word 排版面临的挑战会有多大？图、表、引用的增、删、改牵一发而动全身，仅此一项就可以让人精疲力尽。

## R Markdown

可重复性数据分析工具，首推 R Markdown，它主要使用 R 语言做数据分析，而 R 语言可以说是为数据分析而生，
最早可追溯其前身 S 语言，距今已有 40 多年历史，由 Richard A. Becker，John M. Chambers 和 Allan R. Wilks 在贝尔实验室做数据分析时开发。在 R Markdown 出现以前，已经有 R Sweave 了，两种工具形式上最大的不同在于前者将 R 语言混在 Markdown 文本中，而后者是混在 LaTeX 文本中。目前，R Sweave 内置在 R 软件中，由两个函数 Sweave（编织）和 Stangle（缠结）来实现主要功能，[knitr](https://yihui.org/knitr/) 受此启发，这也是为什么后来 knitr 的图标设计成织毛衣的形象 <img width="3%" src="https://user-images.githubusercontent.com/12031874/103172964-86449a00-4892-11eb-8288-8bbdab506066.png">。下面先介绍一下 R Sweave 的工作流程。

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

![sweave-output](https://user-images.githubusercontent.com/12031874/103172742-8e9bd580-4890-11eb-8125-8d0826bbdb0d.png)

rmarkdown 自 2014 年登陆 CRAN 以来，自身功能不断加强，在 RStudio IDE 的加持下越来越易用，周边生态支持越来越完善，应用场景越来越多，比如写书做笔记、搭建个人博客、制作网页幻灯片、开发数据面板等等。目前，可重复性角色的主要承担者 R Markdown 已经相当成熟，周边生态也正在逐步壮大。

![rmarkdown-family](https://user-images.githubusercontent.com/12031874/104081077-58366100-5267-11eb-87a3-28c84e24bbaf.png)

它站在 Pandoc (<https://pandoc.org/>) 这个巨人的肩膀上，得益于开源社区的努力，近年来，Pandoc 迭代更新越来越快，功能覆盖面越来越广，个人感受最深的是对 LaTeX 支持，这是我将幻灯片和论文从 LaTeX 彻底切换到 R Markdown 的重要原因。

![rmarkdown-application](https://user-images.githubusercontent.com/12031874/103164243-c3357000-4843-11eb-8ccd-84c57bf0f526.png)

R Markdown 支持丰富的格式输出，灵活的定制方式，以 PDF 格式的报告为例，背景水印，双栏排版，交叉引用，定制环境，脚注公式、中英字体等 LaTeX 支持的文档设置都可以支持。如下图所示，完整的 R Markdown 模版见[链接](https://github.com/XiangyunHuang/masr/blob/master/examples/pdf-document.Rmd)

![pdf-documents](https://user-images.githubusercontent.com/12031874/103166609-d6a20480-485e-11eb-89d3-8f3882700912.png)

R Markdown 也可以制作 beamer 风的幻灯片，确切地说是将 beamer 主题迁移到 R Markdown 中，下面要介绍的这个汉风主题由 [林莲枝](https://github.com/liantze/) 开发，已正式发布在 [CTAN](https://www.ctan.org/pkg/pgfornament-han) 上。网络上 beamer 主题已经很多了，两年前，笔者曾收集整理了一个 [awesome-beamers](https://github.com/XiangyunHuang/awesome-beamers) 列表，毕业后，也没再更新了，却还在缓慢加🌟。一个不务专业的过来人建议不搞学术的话，还是从 beamer 弃坑吧，它定制化成本太高，捣鼓各种主题还不如多读几篇论文，新的主题迟早也会用腻。单独拎出来讲，是因为这是我见过风格清新、简洁、看不出 beamer 风、非常具有中国特色的主题。哎！我是个劝人跳坑，自己却还在坑里的人，这种人该怎么办？后来，硬是把它迁移到 R Markdown 环境中才罢手，完整的 R Markdown 模版见[链接](https://github.com/XiangyunHuang/masr/blob/master/examples/beamer-pgfornament-han.Rmd)。前段时间已经注意到 [TC 君](https://github.com/tcgriffith) 和 [李家郡](https://github.com/llijiajun) 准备[接锅](https://github.com/cosname/cosx.org/issues/901)介绍迁移这类模版背后的黑历史，详见[用 R Markdown 写毕业论文](https://github.com/cosname/cosx.org/pull/917)和[R Markdown 与 LaTeX 的结合](https://github.com/cosname/cosx.org/pull/914)，不甚欣喜，感兴趣的读者敬请期待。

![beamer-slides](https://user-images.githubusercontent.com/12031874/103167172-bc1e5a00-4863-11eb-89fb-d5378db3bc50.gif)

R Markdown 还可以用来写书，特别是数据科学领域相关的书籍，笔者参与的书[《现代统计图形》](https://github.com/XiangyunHuang/MSG-Book)[^msg]和个人技术笔记[《现代应用统计》](https://github.com/XiangyunHuang/masr)[^masr]都是用 R Markdown 编写的。下面再介绍一下我从 LaTeX 环境迁移过来的 R Markdown 书籍模版 [ElegantBookdown](https://github.com/XiangyunHuang/ElegantBookdown)，大约也是两年前，我看到[邓东升](https://ddswhu.me/)和[黄晨成](https://liam.page/) 制作的 LaTeX 书籍模版 [ElegantBook](https://github.com/ElegantLaTeX/ElegantBook) 颜值很高，就想把它 bookdown 化，直到今年上半年才抽出一些时间，特别是在[叶飞](https://github.com/fyemath/)的帮助下一起完成了迁移工作！后来，偶然的机会得知哈尔滨商业大学的张敬信老师用它来写书[《R语言编程--基于 tidyverse》](https://github.com/zhjx19/introR)，感觉自己的工作对别人有一些帮助是一件很愉快的事。


![ElegantBookdown](https://user-images.githubusercontent.com/12031874/103174181-f7884b00-489a-11eb-9464-7b254a1aaa23.gif)


[^msg]: 我在此书的贡献主要是将差不多 10 年前的 [LyX](https://www.lyx.org) 书稿搬迁到 R Markdown 里，利用开源的工具配置了测试和部署的环境，更新了不少代码，形成了当前 HTML 网页和 PDF 两种格式。后来，在翻新维护的过程中，又得到许多人的帮助，第一次真正意义上感受到开源和协作的力量。[赵鹏老师](https://pzhao.org/zh/) 回国之后，给书增添了很多新的内容，和出版社的沟通也全靠他，我真是左手右手一边抱了一条大腿。此书历经十余年，有望在今年上半年出版。原计划在去年下半年面世，因为内容审查的原因，后又做了一次较大修改。

[^masr]: 在学校里可能还有成块的时间去读论文，写笔记，工作之后，记录的都是工作之中零零碎碎的东西，很多、很杂，也不成体系，对我来说，最大的作用是当作字典一样的工具去搜索和查找，短期来看投入产出比很低，长期来看却是可以节省大量时间的。曾有人跟我说，写书的话不要把什么都堆放在一起，他是对的，如果写书的话，首先要有较为清晰的规划和目标读者，深吸一口气，集中精力写完第一章。但是，我目前的话还是以厚积为主，时间稍多的时候就整理个一章半节的。

## 可重复性研究

老实说，我对可重复性没什么研究，在做数据分析和毕业论文的过程中，感受最深的是如何提升计算效率和计算过程的可重复性。我用大约 2 个小时将 20 年前的 S 代码更新修改，在 R 环境下复现了老教授论文里的一幅图。是我厉害吗？不是，主要得益于 S 和 R 语言的兼容性和稳定性，要改的也不多。所以，我想表达的是什么呢？只是希望在更短的时间内跑通数据分析的整个流程，只是这个过程并不容易，无论学界还是业界。计算效率高也意味着重复起来更快，软件、框架、生态好更意味着交流方便，复现起来更容易。

![data-workflow-1](https://user-images.githubusercontent.com/12031874/103472843-305d7e00-4dcd-11eb-852e-3e5ceb8f1056.png)


以贝叶斯数据分析领域的马尔可夫蒙特卡洛方法为例，再挖一点历史讲讲，1989 年剑桥大学临床医学院的生物统计系主导了 **BUGS**（**B**ayesian inference **U**sing **G**ibbs **S**ampling）项目，开发出了贝叶斯计算的标杆 [WinBUGS](https://www.mrc-bsu.cam.ac.uk/software/bugs/the-bugs-project-winbugs/)，后来项目停止开发，研究人员开发出了**开源跨平台**的替代品 [OpenBUGS](https://en.wikipedia.org/wiki/OpenBUGS)，再后来衍生出 [JAGS](https://en.wikipedia.org/wiki/Just_another_Gibbs_sampler)，在跨平台和效率提升方面不断前进。时至今日，为适应现代计算机的硬件架构和数据规模，贝叶斯主流计算框架已经开始过渡到 [Stan](https://github.com/stan-dev/) 和 [probability](https://github.com/tensorflow/probability)，提供更加丰富和强大的概率推理和统计分析能力，Stan 社区特别活跃，学术成果会很快更新到软件中，而后者隶属 tensorflow 生态，顶着的光环更大，前途似乎更好。近日，[Andrew Gelman](https://en.wikipedia.org/wiki/Andrew_Gelman) 等人牵头提出完整的现代贝叶斯数据分析工作流，见下图。

![bayesian-workflow](https://user-images.githubusercontent.com/12031874/103152445-07346080-47c3-11eb-90ce-531860e71689.png)

面对当前大数据环境下的挑战，以 Hadoop 生态为代表的大规模数据基础设施，以容器集群为代表的弹性扩展的分布式计算承担越来越重要的角色，计算成本和效率问题已经越来越突出。在计算可重复的数据分析流程中，它们处于底层支撑角色，常常看不到却是非常重要的。


2015 年《自然》杂志刊登数百位学术研究人员联名提出心理学实验的可重复性问题，研究结果表明大量研究结果不可重复，或者效果不显著，或者功效没有那么大。

![reproducible-analysis](https://user-images.githubusercontent.com/12031874/103152913-7dd35d00-47c7-11eb-9cd5-cdcea39f22b7.png)

2017 年郁彬探讨数据科学的三个原则：可预测性、稳定性和可计算性，并阐述在数据驱动决策中的内在联系和重要性。机器学习以预测为中心，计算为核心，实现了相当范围的数据驱动型成功。预测是检验当下的有用方式，好的预测建立在过去和未来的稳定性之上。相对于数据和模型，稳定性是数据结果可解释性和可重复性的最小要求，可重复性是可靠性和稳健性的基础保障。


如何让问题可重复、数据可重复、计算可重复、经验可沉淀，在第 13 届中国 R 语言会议上 [统计软件专场_黄湘云](https://www.bilibili.com/video/BV1Vp4y1B7N1) **粗浅**地谈了可重复性数据分析的工作流，特别是实际工作和学习过程中遇到的一些困难。

最后，这堆砌三个材料，只想说明一点，可重复性数据分析的理想很丰满，道路很曲折，大数据分析的道路更加曲折。原想在结尾处给大家更多正能量，又正值 2021 年新年之际，可这就是现状，接受它吧！一首[黄沾](https://en.wikipedia.org/wiki/James_Wong_Jim)作词郑少秋演唱的「笑看风云」送给大家。

<iframe frameborder="no" border="0" marginwidth="0" marginheight="0" width=330 height=86 src="//music.163.com/outchain/player?type=2&id=1477530893&auto=1&height=66"></iframe>


<!--
Yihui Xie R Markdown Recipes 一分鐘學一道菜 https://vimeo.com/469252441
Yihui Xie 随机漫步十八年的傻瓜 https://vimeo.com/492610094 https://slides.yihui.org/2020-random-walk.html
-->


## 参考文献

1. Literate Programming, R Markdown, and Reproducible Research, Yihui Xie, 2020. <https://slides.yihui.org/2020-covid-rmarkdown.html>
1. Higher, further, faster with Marvelous R Markdown, [Thomas Mock](https://themockup.blog/), 2020, <https://bit.ly/marvelRMD>
1. 在 LaTeX 中进行文学编程, 黄晨成, 2015, <https://liam.page/2015/01/23/literate-programming-in-latex/>
1. ElegantBook 优美的 LaTeX 书籍模板, 邓东升和黄晨成, 2020, <https://github.com/ElegantLaTeX/ElegantBook>
1. Sweave：打造一个可重复的统计研究流程, 谢益辉, 2010, <https://cosx.org/2010/11/reproducible-research-in-statistics/>
1. Sweave User Manual, Friedrich Leisch and R Core Team, 2020, <https://stat.ethz.ch/R-manual/R-devel/library/utils/doc/Sweave.pdf>
1. Bayesian workflow. Andrew Gelman, Aki Vehtari, Daniel Simpson, Charles C. Margossian, Bob Carpenter, Yuling Yao, Lauren Kennedy, Jonah Gabry, Paul-Christian Bürkner, and Martin Modrák, 2020. <https://arxiv.org/abs/2011.01808>
1. Three Principles of Data Science: Predictability, Stability and Computability. 2017. Bin Yu,  <https://doi.org/10.1145/3097983.3105808>
1. 心理学的危机, 杨洵默, 2017, <https://cosx.org/2017/09/psychology-in-crisis/>
1. Estimating the reproducibility of psychological science. Science, 2015, 349 (6251). <https://science.sciencemag.org/content/349/6251/aac4716>
1. <https://en.wikipedia.org/wiki/Literate_programming>
1. R 语言历史: R 进入 4.0 时代, Jozef, 2020, <https://jozef.io/r921-happy-birthday-r/>
1. S, R, and Data Science. John M. Chambers, The R Journal, 2020, 12(1), pages 462-476. <https://doi.org/10.32614/RJ-2020-028>
1. The Future of Data Analysis, John W. Tukey, The Annals of Mathematical Statistics, 1962, 33(1), pages 1-67. <https://www.jstor.org/stable/2237638>
