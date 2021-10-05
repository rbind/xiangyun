---
title: Hugo 和 Pandoc 对 Markdown 的扩展支持
slug: intro-to-markdown
author:
  - 黄湘云
date: '2019-05-09'
categories:
  - 统计软件
tags:
  - Markdown
  - Pandoc
  - Hugo
draft: true
description: "又一份介绍 Markdown 的入门文档，本文对比了 Hugo 和 Pandoc 提供的 Markdown 扩展支持"
thumbnail: /img/hugo.svg
---

这篇博文源自于 Yihui Xie 为 Hugo 主题 [hugo-xmag](https://themes.gohugo.io/hugo-xmag/) 写的英文介绍 [A Plain Markdown Post](https://xmag.yihui.name/post/2017/02/14/a-plain-markdown-post/)[^translation]。除翻译的内容外，补充了关于如何嵌入音频、视频和幻灯片的内容，也是这次 R 会上小伙伴们提问最多的地方。

这篇博文主要面向 [**blogdown**](https://github.com/rstudio/blogdown) 用户，如果你不使用 **blogdown**，你可以跳过第一节。想知道更多关于 Markdown 的基础语法，请看 [John Gruber's Markdown 语法](https://daringfireball.net/projects/markdown/) 和 [R Markdown: The Definitive Guide](https://bookdown.org/yihui/rmarkdown/markdown-syntax.html)。

[^translation]: 我知道很多人是不会耐着性子把原来的英文文档看完，所以翻译了一下。此外，更新原博文中的一点， Markdown 的任务列表，在较新版本的 Pandoc 2.6 及以上也支持了 <https://github.com/jgm/pandoc/releases/tag/2.6>。

> **注意**
> 
> 这篇文章含有丰富的多媒体内容，需要有较好的网速环境，也需要科学上网才能获得最佳的阅读体验！！

# 1. Markdown 还是 R Markdown {#markdown}

这篇博客是用纯 Markdown (`*.md`) 语法写的，而不是 R Markdown (`*.Rmd`)。 其主要的区别是：

1. Markdown 文档中不能运行任何代码，而在 R Markdown 文档中，你可以插入这样的 R 代码块 (```` ```{r} ````)；
1. Markdown 文档通过 Hugo 内建的 Markdown 处理器 [Blackfriday](https://github.com/russross/blackfriday) 渲染，R Markdown 文档需要先由 [**rmarkdown**](https://rmarkdown.rstudio.com) 和 [Pandoc](https://pandoc.org) 编译转化生成 HTML 网页。

> [John Gruber's Markdown](https://daringfireball.net/projects/markdown/) 是最原始的，Pandoc 和 Blackfriday 都是在它的基础上进行功能的扩充和加强

Pandoc 和 Blackfriday 一样都支持任务型列表[^pandoc-task-list]，而原始 Markdown 是不支持的

- [x] 开发一个R包。
- [ ] 写一本书。
- [ ] ...
- [ ] 搭建个人博客！

[^pandoc-task-list]: Pandoc 2.6 及以上支持任务列表 <https://pandoc.org/MANUAL.html#definition-lists>

[Blackfriday's Markdown](https://github.com/russross/blackfriday) 和 [Pandoc's Markdown](https://pandoc.org/MANUAL.html#pandocs-markdown) 之间有很多区别。比如 Blackfriday 不支持 LaTeX 数学公式，而 Pandoc 支持。 [谢益辉](https://yihui.name/) 在 [hugo-xmin](https://github.com/yihui/hugo-xmag) 主题中添加了 [MathJax](https://www.mathjax.org/) 支持，在 Markdown 文档中必须把数学表达式放在一对反引号中，行内公式： `` `$ $` ``；行间公式： `` `$$ $$` ``，举个小栗子，`$S_n = \sum_{i=1}^n X_i$`，`$$S_n = \sum_{i=1}^n X_i.$$` 在 R Markdown 文档里，不需要反引号，因为 Pandoc 能识别和处理数学表达式。^[这是因为我们必须保护数学表达式，防止被 Markdown 解释。如果你的数学表达式中不包含任何特殊的 Markdown 语法，如下划线或星号，你也许不需要反引号，但更安全的方式是始终添加反引号。] 

总的来说， Markdown、Hugo's Markdown、Pandoc's Markdown 和 R Markdown 的关系大致如下：

![all-markdown](https://wp-contents.netlify.com/2019/05/markdown.svg)

当你创建一篇新的博文时，我推荐你使用 RStudio 插件“新建博文” (New-Post)：

![RStudio addin New Post](https://bookdown.org/yihui/blogdown/images/new-post.png)

# 2. 样例文本 {#text}

## 二级标题

### 三级标题

#### 四级标题

一个有脚注的段落：

**Lorem ipsum** dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore _magna aliqua_. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.^[你肯定会对这里的文本感到无聊]

## 2.1 引用 {#quote}

下面插入一段引用，来自《红楼梦》第三回，林黛玉初到荣国府，曹雪芹对她的描写

> 两弯似蹙非蹙笼烟眉，一双似喜非喜含情目。态生两靥之愁，娇袭一身之病。泪光点点，娇喘微微。闲静似娇花照水，行动如弱柳扶风。心较比干多一窍，病如西子胜三分。

引用的左边有灰色条，背景是亮灰色，再引用名人名言

> Essentially, all models are wrong, but some are useful.  
> --- George Box

引用要被玩坏了，继续引用唐代诗人崔护的诗《题都城南庄》

> 去年今日此门中，人面桃花相映红。  
人面不知何处去，桃花依旧笑春风。

在 Markdown 中引用诗词或歌词，请看这篇博文 <https://yihui.name/cn/2018/07/quote-poem/>，还可以在 RStudio 里用 blogdown 提供的插件 （Quote Poem）快速实现 [诗歌的引用](https://yihui.name/en/2018/06/quote-poem-blogdown/)

> This is a block quote. This
paragraph has two lines.

> 1. This is a list inside a block quote.
2. Second item.

嵌套引用

> This is a block quote.
>
> > A block quote within a block quote.


## 2.2 插入代码 {#code}

插入一些 R 代码，可以语法高亮和带下拉的阴影效果哦！

```r
data(anscombe)
form <- paste(paste0("y", seq(4)), paste0("x", seq(4)), sep = "~")
fit <- lapply(form, lm, data = anscombe)
op <- par(mfrow = c(2, 2), mar = 0.1 + c(4, 4, 1, 1), oma = c(0, 0, 2, 0))
for (i in seq(4)) {
  plot(as.formula(form[i]),
    data = anscombe, col = hcl.colors(11),
    pch = 19, cex = 1.2,
    xlim = c(3, 19), ylim = c(3, 13),
    xlab = as.expression(substitute(x[i], list(i = i))),
    ylab = as.expression(substitute(y[i], list(i = i)))
  )
  abline(fit[[i]], col = "red", lwd = 2)
}
mtext("Anscombe's 4 Regression data sets", outer = TRUE, cex = 1.5)
par(op)
```

## 2.3 插入表格 {#table}

一张表格，表格的位置默认居中：

| Sepal.Length| Sepal.Width| Petal.Length| Petal.Width|Species |
|------------:|-----------:|------------:|-----------:|:-------|
|          5.1|         3.5|          1.4|         0.2|setosa  |
|          4.9|         3.0|          1.4|         0.2|setosa  |
|          4.7|         3.2|          1.3|         0.2|setosa  |
|          4.6|         3.1|          1.5|         0.2|setosa  |
|          5.0|         3.6|          1.4|         0.2|setosa  |
|          5.4|         3.9|          1.7|         0.4|setosa  |

```
| Sepal.Length| Sepal.Width| Petal.Length| Petal.Width|Species |
|------------:|-----------:|------------:|-----------:|:-------|
|          5.1|         3.5|          1.4|         0.2|setosa  |
|          4.9|         3.0|          1.4|         0.2|setosa  |
|          4.7|         3.2|          1.3|         0.2|setosa  |
|          4.6|         3.1|          1.5|         0.2|setosa  |
|          5.0|         3.6|          1.4|         0.2|setosa  |
|          5.4|         3.9|          1.7|         0.4|setosa  |
```

Pandoc 支持插入可以跨行的表格，就是一个 cell 里可以跨行，但是 Hugo 不支持

    -------------------------------------------------------------
     Centered   Default           Right Left
      Header    Aligned         Aligned Aligned
    ----------- ------- --------------- -------------------------
       First    row                12.0 Example of a row that
                                        spans multiple lines.
    
      Second    row                 5.0 Here's another one. Note
                                        the blank line between
                                        rows.
    -------------------------------------------------------------
    
    Table: Here's the caption. It, too, may span
    multiple lines.

类似地，Hugo 不支持插入 grid 表格

    +---------------+---------------+--------------------+
    | Fruit         | Price         | Advantages         |
    +===============+===============+====================+
    | Bananas       | $1.34         | - built-in wrapper |
    |               |               | - bright color     |
    +---------------+---------------+--------------------+
    | Oranges       | $2.10         | - cures scurvy     |
    |               |               | - tasty            |
    +---------------+---------------+--------------------+


## 2.4 插入图片 {#image}

插入一张图片，[hugo-xmag](https://github.com/yihui/hugo-xmag) 主题的 CSS 样式已经将其设置为自动居中：

![Happy Elmo](https://slides.yihui.name/gif/happy-elmo.gif)

```
![Happy Elmo](https://slides.yihui.name/gif/happy-elmo.gif)
```

看起来好吗？

---

插入矢量图片是一样的

![r-logo](https://cloud.r-project.org/Rlogo.svg)

```
![r-logo](https://cloud.r-project.org/Rlogo.svg)
```

太大了是不是，我们还可以控制插入的大小

<img width="50%" src="https://cloud.r-project.org/Rlogo.svg">

```
<img width="256" height="256" src="https://cloud.r-project.org/Rlogo.svg">
# 或者
<img width="50%" src="https://cloud.r-project.org/Rlogo.svg">
```

在 Pandoc 中更加简洁

```
![r-logo](https://cloud.r-project.org/Rlogo.svg){ width=50% }
```

Pandoc 还支持插入全宽图形，并且交叉引用 `\@ref(fig:r-logo)`

```
![(\#fig:r-logo) 一幅全宽的图片](https://www.r-project.org/logo/Rlogo.png){.full}
```

## 2.5 插入音频 {#audio}

```html
<iframe frameborder="0" marginwidth="0" marginheight="0" width=400 height=80 src="https://music.163.com/outchain/player?type=2&id=34341360&auto=0&height=66"></iframe>
```

<iframe frameborder="0" marginwidth="0" marginheight="0" width=400 height=80 src="https://music.163.com/outchain/player?type=2&id=34341360&auto=0&height=66"></iframe>

陈慧娴版《千千阙歌》

<iframe frameborder="0" marginwidth="0" marginheight="0" width=400 height=80 src="https://music.163.com/outchain/player?type=2&id=5244310&auto=0&height=66"></iframe>

张国荣版《千千阙歌》

<iframe frameborder="0" marginwidth="0" marginheight="0" width=400 height=80 src="https://music.163.com/outchain/player?type=2&id=34341388&auto=0&height=66"></iframe>


> 你不觉得天边的晚霞很美吗？只有看着她，我才能坚持向西走。
> --- 《悟空传》  


戴荃的《悟空》

<iframe frameborder="0" marginwidth="0" marginheight="0" width=400 height=80 src="https://music.163.com/outchain/player?type=2&id=33162226&auto=0&height=66"></iframe>

霍尊的《卷珠帘》

<iframe frameborder="0" marginwidth="0" marginheight="0" width=400 height=80 src="https://music.163.com/outchain/player?type=2&id=32063039&auto=0&height=66"></iframe>

更多可以播放的音乐，去网站搜索 <https://music.liuzhijin.cn/>

## 2.6 插入视频 {#video}

Rick Becker 在 2016 年国际 R 语言大会上的演讲 --- Forty Years of S

<iframe src="https://channel9.msdn.com/Events/useR-international-R-User-conference/useR2016/Forty-years-of-S/player" width="960" height="440" allowFullScreen frameBorder="0"></iframe>

```html
<iframe src="https://channel9.msdn.com/Events/useR-international-R-User-conference/useR2016/Forty-years-of-S/player" width="960" height="440" allowFullScreen frameBorder="0"></iframe>
```

[Statistics Views](https://www.statisticsviews.com/details/feature/10033491/Its-just-serendipity-that-I-ended-up-in-statistics-An-interview-with-Trevor-Hast.html)  对 Trevor Hastie 的采访

<iframe src="https://players.brightcove.net/87100274001/default_default/index.html?videoId=5193920344001" width="960" height="440" allowFullScreen frameBorder="0"></iframe>

> It’s just serendipity that I ended up in statistics.


统计之都海外沙龙第8期： [陈天奇](https://tqchen.com/)、 [何通](https://github.com/hetong007)、 [邱怡轩](https://statr.me/) 在聊 xgboost 统计软件奖背后的故事

<iframe width="960" height="600" src="https://player.bilibili.com/player.html?aid=4018491&cid=6479840&page=1" scrolling="no" border="0" frameborder="no" framespacing="0" allowfullscreen="true"> </iframe>

统计之都海外沙龙第26期：在谷歌、微软、Facebook 搬砖之感受

<iframe width="960" height="600" src="//player.bilibili.com/player.html?aid=15256742&cid=24831259&page=1" scrolling="no" border="0" frameborder="no" framespacing="0" allowfullscreen="true"> </iframe>

北京出租车的运行轨迹

<iframe src='https://gfycat.com/ifr/PartialMadeupAustraliancurlew' frameborder='0' scrolling='no' allowfullscreen width="800" height="600"></iframe>

插入腾讯视频

<iframe width="800" height="600" frameborder="0" src="https://v.qq.com/txp/iframe/player.html?vid=s0392uw1zzj" allowFullScreen="true"></iframe>

## 2.7 插入幻灯片 {#slide}

[Ryan Hafen](https://ryanhafen.com/) 在介绍 geofacet

<iframe src="//slides.com/hafen/geofacet-cascadia/embed" width="960" height="700" scrolling="no" frameborder="0" webkitallowfullscreen mozallowfullscreen allowfullscreen></iframe>

```html
<iframe src="//slides.com/hafen/geofacet-cascadia/embed" width="960" height="700" scrolling="no" frameborder="0" webkitallowfullscreen mozallowfullscreen allowfullscreen></iframe>
```

[Ryan Hafen](https://ryanhafen.com/) 在介绍 trelliscopejs

<iframe src="//slides.com/hafen/trelliscopejs-lightning/embed" width="960" height="700" scrolling="no" frameborder="0" webkitallowfullscreen mozallowfullscreen allowfullscreen></iframe>

除了从网站插入幻灯片，还支持直接插入 xaringan 制作的幻灯片，下面是我在2019年中国R语言大会（北京）上的幻灯片，也是创建本博客的技术栈。blogdown 出来已经有两年了，很多人使用它创建了自己的博客，统计之都主站是最早使用这套工具的，这次分享以现场操作为主。

<iframe src="//wp-contents.netlify.com/talks/2019-chinar12th-cos-blogdown" width="960" height="700" scrolling="no" frameborder="0" webkitallowfullscreen mozallowfullscreen allowfullscreen></iframe>

PDF 格式文档也是可以插入的，比如 beamer 制作的幻灯片，2016 年我去北大听 Cuihui Zhang 教授的高维线性模型，他人非常 nice，分享了他的幻灯片[^hlm]

<iframe src="//wp-contents.netlify.com/talks/Cunhui-Zhang16-Beida.pdf" width="800" height="600" scrolling="no" frameborder="0" webkitallowfullscreen mozallowfullscreen allowfullscreen></iframe>


[^hlm]: 这个课内容非常高深，听不大懂，但是知道个轮廓，感受下高维统计方向的研究前沿

## 2.8 插入列表 {#list}

定义类型的列表


    Cat
    : Fluffy animal everyone likes
    
    Internet
    : Vector of transmission for pictures of cats


Cat
: Fluffy animal everyone likes

Internet
: Vector of transmission for pictures of cats

插入无序列表

    * one
    * two
    * three

* one
* two
* three

插入有序的列表

    1.  one
    2.  two
    3.  three


1.  one
2.  two
3.  three

把前面的数字全部换成 1 也是可以的

    1.  one
    1.  two
    1.  three


1.  one
1.  two
1.  three


在列表中含有段落

  * First paragraph.

    Continued.

  * Second paragraph. With a code block, which must be indented
    eight spaces:

        { code }

  * First paragraph.

    Continued.



还可以在列表环境中插入图片

    -   One
    
    -   Two
    
         ![deploy-to-netlify](https://www.netlify.com/img/deploy/button.svg)
    
    -   Three

-   One

-   Two

     ![deploy-to-netlify](https://www.netlify.com/img/deploy/button.svg)

-   Three

插入多层的列表， Pandoc 支持多层，而 Hugo 支持两层

    * fruits
      + apples
        - macintosh
        - red delicious
      + pears
      + peaches
    * vegetables
      + broccoli
      + chard

* fruits
  + apples
    - macintosh
    - red delicious
  + pears
  + peaches
* vegetables
  + broccoli
  + chard


## 2.9 插入脚注 {#footnote}

这是内联形式的脚注，对于包含很长内容的脚注，我们建议使用文本引用的方式插入

    Here is an inline note.^[Inlines notes are easier to write, since
    you don't have to pick an identifier and move down to type the
    note.]

Here is an inline note.^[Inlines notes are easier to write, since
you don't have to pick an identifier and move down to type the
note.]

采用文本交叉引用的方式，插入脚注

    This is a footnote.[^1]
    
    [^1]: the footnote text.

This is a footnote.[^1]

[^1]: the footnote text.

脚注中包含段落只在 Pandoc 中支持， Hugo 中不支持


    Here is a footnote reference,[^2] and another.[^longnote]
    
    [^2]: Here is the footnote.
    
    [^longnote]: Here's one with multiple blocks.
    
        Subsequent paragraphs are indented to show that they
    belong to the previous footnote.
    
            { some.code }
    
        The whole paragraph can be indented, or just the first
        line.  In this way, multi-paragraph footnotes work like
        multi-paragraph list items.
    
    This paragraph won't be part of the note, because it
    isn't indented.


---

# 3. 参考文献 {#reference}

1. Markdown <https://daringfireball.net/projects/markdown/>
1. Github's Markdown <https://guides.github.com/features/mastering-markdown/>
1. Pandoc's Markdown <https://pandoc.org/MANUAL.html#pandocs-markdown>
1. Hugo's Markdown <https://github.com/russross/blackfriday#features>
1. 插入音视频 <https://www.sunyazhou.com/2017/12/27/20171227markdown-audio/>
1. 非常全面的 Markdown 入门参考 <http://xianbai.me/learn-md>

---

**我讨厌 CSDN 知乎，支持个人博客，下面是一些我写这篇文章遇到的个人博客**

- [Yifan](https://zyf.im/) 一名在帝都的软件工程师，~~对前端非常感兴趣~~ 现在专注于后端服务
- [AomanHao](https://www.aomanhao.top/) 热爱图像处理，图像优化世界 matlab
- [GcsSloop](https://www.gcssloop.com) 一名来自2.5次元的魔法师 Java Android
- [屈光宇](https://imququ.com/) 专注 WEB 端开发

---

本博客托管平台的设置类似博文 --- [Hexo 个人博客迁移到托管平台 Netlify](https://www.aomanhao.top/2019/05/03/Hexo_Netlify/)，补充一点，在自定义域名后，添加 SSL/TLS 认证[^ssl-tls]，只需在 Git Bash 中输入

```bash
curl -s -v https://xiangyunhuang.com.cn 2>&1 | grep Server
```

我的博客也以统计之都一样的风格搭建，基于几个原因：

1. 目前统计之都主站我参与维护，比较熟悉
1. 博客的 CSS 主题 hugo-xmag 由谢益辉开发维护，学习起来有近水楼台之便
1. 搬迁统计之都的博客到本站（限本人的），或以后投稿给统计之都，文档内容不需要丝毫改变

> **注意**
> 
> 本博客平台托管在 Netlify 上，国内的访问速度会是一个问题，所以科学上网后访问，效果更佳！！

[^ssl-tls]: https://www.netlify.com/docs/ssl/#troubleshooting
