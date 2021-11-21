---
date: "2021-11-20"
author: "黄湘云"
slug: intro-datatable-cn
title: data.table 导论（翻译）
toc: true
categories:
  - 统计软件
tags:
  - data.table
  - R 语言
  - 数据处理
bibliography: 
  - refer.bib
draft: true
thumbnail: /img/datatable.svg
link-citations: true
description: "本文翻译自 R 软件扩展包 data.table 的官网，希望能够帮助初学者入门，降低一些学习成本。笔者日常会使用 data.table，它是一个十分稳定高效的工具，推荐把它加入数据分析工具箱。限于水平，笔者也不是专业翻译人员，若翻译有不当之处，欢迎提出，责任在笔者，与原文无关，笔者会尽可能地朝着「信」、「达」、「雅」去做，偶有闲暇还会同步更新文档。如果读者经常阅读英文帮助文档或书籍，推荐直接看原文。"
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

<div class="rmdtip">

本文档翻译自 [Introduction to data.table](https://rdatatable.gitlab.io/data.table/articles/datatable-intro.html)

</div>

本文档介绍 `data.table` 的使用语法，它的一般形式，如何做行的筛选，如何做列的选择和计算，如何做分组聚合。对本文来说，熟悉 Base R 提供的数据结构 `data.frame` 是有用的，但不是必须的。

------------------------------------------------------------------------

# 用 `data.table` 做数据分析

数据操作，如选择子集 subset、分组 group、更新 update、合并 join。所有这些操作都是一脉相承的。将这些相关联的操作放在一起的好处有：

-   简洁而一致的语法，无论您要执行何种操作来实现最终目标。

-   流畅地执行分析，而不必承担执行分析之前必须将每个操作映射到特定功能的认知负担的潜在负担。

-   通过精确地知道每个操作所需的数据，在内部非常有效地自动优化操作，从而产生非常快速且内存有效的代码。

简单说，如果你有兴趣大大降低编程和计算的时间，那么这个包就是为你准备的。data.table 坚持的理念使这成为可能。我们的目标是通过这一系列的文档来说明这一点。

# 数据

在这个文档中，我们将使用来自 [flights](https://github.com/arunsrinivasan/flights) 包 (仅可在 Github 上获得) 的 [NYC-flights14](https://raw.githubusercontent.com/Rdatatable/data.table/master/vignettes/flights14.csv) 数据。它包含 [运输统计局](http://www.transtats.bts.gov/DL_SelectFields.asp?Table_ID=236) 2014年从纽约市机场起飞的所有航班的准点航班数据 (灵感来自 [nycflights13](https://github.com/hadley/nycflights13) 包)。 数据集只包含 2014年 1月至10月的航班记录。

我们能用 `data.table` 提供的又快又好地读取数据的函数 `fread` 去直接加载 `flights` 数据集，如下：

``` r
library(nycflights13)
flights <- as.data.table(flights)
flights
#         year month day dep_time sched_dep_time dep_delay arr_time
#      1: 2013     1   1      517            515         2      830
#      2: 2013     1   1      533            529         4      850
#      3: 2013     1   1      542            540         2      923
#      4: 2013     1   1      544            545        -1     1004
#      5: 2013     1   1      554            600        -6      812
#     ---                                                          
# 336772: 2013     9  30       NA           1455        NA       NA
# 336773: 2013     9  30       NA           2200        NA       NA
# 336774: 2013     9  30       NA           1210        NA       NA
# 336775: 2013     9  30       NA           1159        NA       NA
# 336776: 2013     9  30       NA            840        NA       NA
#         sched_arr_time arr_delay carrier flight tailnum origin dest
#      1:            819        11      UA   1545  N14228    EWR  IAH
#      2:            830        20      UA   1714  N24211    LGA  IAH
#      3:            850        33      AA   1141  N619AA    JFK  MIA
#      4:           1022       -18      B6    725  N804JB    JFK  BQN
#      5:            837       -25      DL    461  N668DN    LGA  ATL
#     ---                                                            
# 336772:           1634        NA      9E   3393    <NA>    JFK  DCA
# 336773:           2312        NA      9E   3525    <NA>    LGA  SYR
# 336774:           1330        NA      MQ   3461  N535MQ    LGA  BNA
# 336775:           1344        NA      MQ   3572  N511MQ    LGA  CLE
# 336776:           1020        NA      MQ   3531  N839MQ    LGA  RDU
#         air_time distance hour minute           time_hour
#      1:      227     1400    5     15 2013-01-01 05:00:00
#      2:      227     1416    5     29 2013-01-01 05:00:00
#      3:      160     1089    5     40 2013-01-01 05:00:00
#      4:      183     1576    5     45 2013-01-01 05:00:00
#      5:      116      762    6      0 2013-01-01 06:00:00
#     ---                                                  
# 336772:       NA      213   14     55 2013-09-30 14:00:00
# 336773:       NA      198   22      0 2013-09-30 22:00:00
# 336774:       NA      764   12     10 2013-09-30 12:00:00
# 336775:       NA      419   11     59 2013-09-30 11:00:00
# 336776:       NA      431    8     40 2013-09-30 08:00:00
dim(flights)
# [1] 336776     19
```

<div class="sidebar">

`fread` 可以接受直接传递的 `http` 和 `https` 网址，以及操作系统命令的输出，如 `sed` 和 `awk` 。 请看函数帮助文档 `?fread` 给出的具体的示例。

</div>

# 介绍

在这份文档中，我们将

1.  首先从基础的开始 — 什么是一个 `data.table`，它的一般形式，如何选择行子集，如何选择列和在列上计算；
2.  然后，我们看看数据的分组聚合。

# 1. 基本 Basics

## 1.1 什么是 `data.table`？

`data.table` 是一个 R 包，提供了一个加强版的 `data.frame` 数据框，`data.frame` 数据框是一种标准的数据结构用来在 Base R 中存储数据。 在上面的 [数据](#data) 一节中，我们已经使用 `fread()`函数创建了一个 `data.table`。我们也可以使用函数`data.table()`来创建`data.table`。这是一个例子：

``` r
DT = data.table(
  ID = c("b","b","b","a","a","c"),
  a = 1:6,
  b = 7:12,
  c = 13:18
)
DT
#    ID a  b  c
# 1:  b 1  7 13
# 2:  b 2  8 14
# 3:  b 3  9 15
# 4:  a 4 10 16
# 5:  a 5 11 17
# 6:  c 6 12 18
class(DT$ID)
# [1] "character"
```

你也可以用 `setDT()` 函数将存在的数据对象（`data.table` 和 `list` 类型）转化为 `data.table` 类型，而对于其他数据结构，我们可以用 `as.data.table()` 函数来转化。介绍这二者之间的差别已经超出了本文档的介绍范围，请看函数帮助文档 `?setDT` 和 `?as.data.table` 来获取更多详细内容。

### 注意

-   和 `data.frame` 不同，字符 `character` 类型的列默认不会转化为因子 `factors` 类型。

-   行数以 `:` 标记，为了在视觉上将行号与第一列分开。

-   当要打印的行数超过全局设置选项 `datatable.print.nrows` (default = 100)，就自动打印前5行和最后5行 (如 [Data](#data) 所示)。如果你有很多使用`data.frame`的经验，您可能会发现自己在等待较大的表格打印和页面输出，有时似乎是无休止的。 您可以这样查询默认号码：

    ``` r
    getOption("datatable.print.nrows")
    ```

-   `data.table` 从不会设置和使用行名。我们将在基于键和快速二进制搜索的子集的文档中看到原因。

## 1.2 一般形式 - `data.table` 是以一种什么样的方式加强的

相比于 `data.frame`，在 `data.table` 的框架下，你能做远远超出选择行子集和列子集的事情，比如 `[ ... ]` (注意：我们也可以在 `DT[...]` 里写 “查询 `DT`”, 类似 SQL). 要理解它，我们将必须先看一下 `data.table` 语法的一般形式， 如下所示：

``` r
DT[i, j, by]

##   R:                 i                 j        by
## SQL:  where | order by   select | update  group by
```

具有 SQL 背景的用户可能会立即与此语法相关。

### 理解的方式是:

`DT`， 子集/重排 `i`， 计算 `j`， 分组 `by`.

让我们先看看 `i` 和 `j` - 行子集和列操作

## 1.3 行子集 `i`

### 获得6月当月以肯尼迪国际机场为始发机场的所有航班

``` r
ans <- flights[origin == "JFK" & month == 6L]
head(ans)
#    year month day dep_time sched_dep_time dep_delay arr_time
# 1: 2013     6   1        2           2359         3      341
# 2: 2013     6   1      538            545        -7      925
# 3: 2013     6   1      539            540        -1      832
# 4: 2013     6   1      553            600        -7      700
# 5: 2013     6   1      554            600        -6      851
# 6: 2013     6   1      557            600        -3      934
#    sched_arr_time arr_delay carrier flight tailnum origin dest
# 1:            350        -9      B6    739  N618JB    JFK  PSE
# 2:            922         3      B6    725  N806JB    JFK  BQN
# 3:            840        -8      AA    701  N5EAAA    JFK  MIA
# 4:            711       -11      EV   5716  N835AS    JFK  IAD
# 5:            908       -17      UA   1159  N33132    JFK  LAX
# 6:            942        -8      B6    715  N766JB    JFK  SJU
#    air_time distance hour minute           time_hour
# 1:      200     1617   23     59 2013-06-01 23:00:00
# 2:      203     1576    5     45 2013-06-01 05:00:00
# 3:      140     1089    5     40 2013-06-01 05:00:00
# 4:       42      228    6      0 2013-06-01 06:00:00
# 5:      330     2475    6      0 2013-06-01 06:00:00
# 6:      198     1598    6      0 2013-06-01 06:00:00
```

#### 

-   在 `data.table` 里，列可以直接用变量名来引用，这个和在 SQL 或 Stata 里很像。因此，使用变量列的时候，我们直接使用 `origin` 和 `month` 就好。我们不必每次去添加前缀 `flights$`。不过，也可以使用 `flights$origin` 和 `flights$month` 。

-   行指标满足条件 `origin == "JFK" & month == 6L` 的计算，并且由于没有其他事情要做，因此来自`flights`的所有行（对应于那些行索引）的列都将作为 data.table 返回。

-   在条件 `i` 之后，添加一个逗号不是必须的。 `flights[origin == "JFK" & month == 6L, ]` 添加逗号也可以， 但是在 `data.frame` 里，逗号是必须的。

### 查看 `flights` 的前两行

``` r
ans <- flights[1:2]
ans
#    year month day dep_time sched_dep_time dep_delay arr_time
# 1: 2013     1   1      517            515         2      830
# 2: 2013     1   1      533            529         4      850
#    sched_arr_time arr_delay carrier flight tailnum origin dest
# 1:            819        11      UA   1545  N14228    EWR  IAH
# 2:            830        20      UA   1714  N24211    LGA  IAH
#    air_time distance hour minute           time_hour
# 1:      227     1400    5     15 2013-01-01 05:00:00
# 2:      227     1416    5     29 2013-01-01 05:00:00
```

#### 

-   在这种情况下，没有条件。行指标已经由 `i` 提供。因此，我们返回一个 `data.table`，并且将所有列以指定的行指标返回。

### `flights` 先按列 `origin` 以升序排列，然后按列 `dest` 以降序排列:

我们可以使用 R 函数 `order()` 来实现它

``` r
ans <- flights[order(origin, -dest)]
head(ans)
#    year month day dep_time sched_dep_time dep_delay arr_time
# 1: 2013     1   2      905            822        43     1313
# 2: 2013     1   3      848            850        -2     1149
# 3: 2013     1   4      901            850        11     1120
# 4: 2013     1   6      843            848        -5     1053
# 5: 2013     1   7      858            850         8     1105
# 6: 2013     1   8      847            850        -3     1116
#    sched_arr_time arr_delay carrier flight tailnum origin dest
# 1:           1045        NA      EV   4140  N15912    EWR  XNA
# 2:           1113        36      EV   4125  N21129    EWR  XNA
# 3:           1113         7      EV   4125  N16178    EWR  XNA
# 4:           1111       -18      EV   4625  N12172    EWR  XNA
# 5:           1113        -8      EV   4125  N13118    EWR  XNA
# 6:           1113         3      EV   4125  N14180    EWR  XNA
#    air_time distance hour minute           time_hour
# 1:       NA     1131    8     22 2013-01-02 08:00:00
# 2:      196     1131    8     50 2013-01-03 08:00:00
# 3:      168     1131    8     50 2013-01-04 08:00:00
# 4:      174     1131    8     48 2013-01-06 08:00:00
# 5:      163     1131    8     50 2013-01-07 08:00:00
# 6:      177     1131    8     50 2013-01-08 08:00:00
```

### 深度优化的排序 `order()`

-   我们能对一个字符型的列使用减号 “-” 去实现降序排列

-   此外，`data.table` 框架下的 `order(...)` 使用 `data.table` 内置的快速 radix 排序 `forder()`。这个排序算法如此快速有效，以至于 R 内置的 `base::order` 函数在 R 版本 3.3.0 以后默认采用，详见 `?sort` 和 [R 更新日志](https://cran.r-project.org/doc/manuals/r-release/NEWS.pdf).

我们会在 `data.table` 的高级文档中详细讨论`data.table` 的快速排序。

## 1.4 Select column(s) in `j`

### 选择 `arr_delay` 列，但是它作为一个向量返回

``` r
ans <- flights[, arr_delay]
head(ans)
# [1]  11  20  33 -18 -25  12
```

#### 

-   由于列可以被视为好像它们是data.table框架中的变量，因此我们直接引用我们想要子集的变量。 因为我们要*所有行*，所以我们只需跳过`i`。

-   它返回列 `arr_delay` 的所有行

### 选择 `arr_delay` 列， 但是作为 `data.table` 返回。

``` r
ans <- flights[, list(arr_delay)]
head(ans)
#    arr_delay
# 1:        11
# 2:        20
# 3:        33
# 4:       -18
# 5:       -25
# 6:        12
```

#### 

-   我们用 `list()` 包裹变量（列名）以确保返回一个 `data.table` 类型的数据对象。如果只有一个的列名，就不需要把它放在 `list()` 里，返回的就是一个向量，如 [previous example](#select-j-1d) 所示。

-   `data.table` 也允许将列名放在 `.()` 里而不是 `list()`里。 它相当于给 `list()` 取了一个别名，作用是一样的。你可以按照自己喜欢的方式任意选择，我们发现大多数用户似乎更加喜欢 `.()` 的方式，它显得更加简洁，此后，我们会继续使用 `.()` 。

`data.table`s (和 `data.frame`s) 内部使用的都是列表 `list`s as well, with the stipulation that each element has the same length and the `list` has a `class` attribute. Allowing `j` to return a `list` enables converting and returning `data.table` very efficiently.

#### 提示建议:

只要 `j-expression` 返回一个 `list`, 那么列表里每个元素都会被转化为最终返回结果 `data.table` 中 的一列。这使得 `j` 非常强大，因为我们很快就会看到这一点。理解这一点是非常重要的，特别是当你想做更加复杂的查询的时候！

### 同时选择 `arr_delay` 和 `dep_delay` 两列.

``` r
ans <- flights[, .(arr_delay, dep_delay)]
head(ans)
#    arr_delay dep_delay
# 1:        11         2
# 2:        20         4
# 3:        33         2
# 4:       -18        -1
# 5:       -25        -6
# 6:        12        -4

## 或者
# ans <- flights[, list(arr_delay, dep_delay)]
```

-   将两列放在 `.()` 或 `list()` 里。 就是那样！

### 同时选择 `arr_delay` 和 `dep_delay` 列，并且分别重命名为 `delay_arr` 和 `delay_dep`

既然 `.()` 只是 `list()` 的别名，我们能命名列，就像我们创建一个 `list` 一样

``` r
ans <- flights[, .(delay_arr = arr_delay, delay_dep = dep_delay)]
head(ans)
#    delay_arr delay_dep
# 1:        11         2
# 2:        20         4
# 3:        33         2
# 4:       -18        -1
# 5:       -25        -6
# 6:        12        -4
```

就是那样！

## 1.5 在 `j` 里计算

### 总延迟小于0的航班有多少?

``` r
ans <- flights[, sum( (arr_delay + dep_delay) < 0 )]
ans
# [1] NA
```

### 这里发生了什么？

-   `data.table` 的 `j` 不仅能处理选择的列，而且能处理表达式。比如，对列计算。列能直接被它的变量所引用，所以不应该感到惊讶。然后，我们调用函数在这些变量上去计算。那正是在这里发生的！

## 1.6 在 `i` 过滤和在 `j` 里计算

### 计算始发机场6月份航班为 JFK 平均的到达和离开延迟时间

``` r
ans <- flights[origin == "JFK" & month == 6L,
               .(m_arr = mean(arr_delay), m_dep = mean(dep_delay))]
ans
#    m_arr m_dep
# 1:    NA    NA
```

-   我们首先在 `i` 里筛选行，匹配那些起飞航班是 JFK 月份是 6 月的行。我们还不会筛选整个 `data.table` 里相应的行。

-   现在，我们看看 `j` ，发现它仅仅使用两列。 我们要做的是计算它们的平均值 `mean()`.因此，我们只是在筛选后的列和匹配后的行上计算平均值 `mean()`.

因为这三个主要的查询操作 (`i`, `j` 和 `by`) 都在 `[...]` 里， `data.table` 能看到三个操作，并且在计算之前同时优化查询，而不是分开计算。因此，我们能够防止整个子集操作（比如，在 `arr_delay` 和 `dep_delay` 里选择列），这都是出于速度和内存效率上的考虑。

### 2014 年 6 月 JFK 机场起飞的航班有多少

``` r
ans <- flights[origin == "JFK" & month == 6L, length(dest)]
ans
# [1] 9472
```

The function `length()` requires an input argument. We just needed to compute the number of rows in the subset. We could have used any other column as input argument to `length()` really. This approach is reminiscent of `SELECT COUNT(dest) FROM flights WHERE origin = 'JFK' AND month = 6` in SQL.

This type of operation occurs quite frequently, especially while grouping (as we will see in the next section), to the point where `data.table` provides a *special symbol* `.N` for it.

### 特殊的符号 `.N`

`.N` 是一个特殊的内建变量，用来存储当前组内的观测数。当与 `by` 一起使用的时候，在下一节中我们会看到它是特别有用的。不在分组的环境里，它仅是返回子集里行数。

所以，我们可以用 `.N` 完成简单的任务，比如：

``` r
ans <- flights[origin == "JFK" & month == 6L, .N]
ans
# [1] 9472
```

#### 

-   再一次，我们在 `i` 里筛选行指标，只要起飞 `origin` 的机场是 *“JFK”* 并且月份 `month` 是 *6*。

-   我们看到 `j` 仅仅使用 `.N` 没有其它列。因此，整个子集没有实现，我们仅仅返回子集的行数，就是行指标的长度。

-   注意：我们没有把 `.N` 放在 `list()` 或 `.()` 里。所以返回的是一个向量。

We could have accomplished the same operation by doing `nrow(flights[origin == "JFK" & month == 6L])`. However, it would have to subset the entire `data.table` first corresponding to the *row indices* in `i` *and then* return the rows using `nrow()`, which is unnecessary and inefficient. We will cover this and other optimisation aspects in detail under the *`data.table` design* vignette.

## 1.7 非常好！但是我们如何在 `j` 里用列名引用列呢？（像在数据框 `data.frame` 里那样）

如果你显式地写出列名，这与 `data.frame` 没有可见的差别 （自 1.9.8 版本以后）

### 以在 `data.frame` 的方式同时选择 `arr_delay` 和`dep_delay` 两列

``` r
ans <- flights[, c("arr_delay", "dep_delay")]
head(ans)
#    arr_delay dep_delay
# 1:        11         2
# 2:        20         4
# 3:        33         2
# 4:       -18        -1
# 5:       -25        -6
# 6:        12        -4
```

如果你已经在字符向量里存储了需要的列，这有两个选项：使用 `..` 前缀或使用 `with` 参数。

### 使用前缀在一个变量里选择列名 `..`

``` r
select_cols = c("arr_delay", "dep_delay")
flights[ , ..select_cols]
#         arr_delay dep_delay
#      1:        11         2
#      2:        20         4
#      3:        33         2
#      4:       -18        -1
#      5:       -25        -6
#     ---                    
# 336772:        NA        NA
# 336773:        NA        NA
# 336774:        NA        NA
# 336775:        NA        NA
# 336776:        NA        NA
```

For those familiar with the Unix terminal, the `..` prefix should be reminiscent of the “up-one-level” command, which is analogous to what’s happening here – the `..` signals to `data.table` to look for the `select_cols` variable “up-one-level”, i.e., in the global environment in this case.

### 使用 `with = FALSE` 在一个变量里选择列名

``` r
flights[ , select_cols, with = FALSE]
#         arr_delay dep_delay
#      1:        11         2
#      2:        20         4
#      3:        33         2
#      4:       -18        -1
#      5:       -25        -6
#     ---                    
# 336772:        NA        NA
# 336773:        NA        NA
# 336774:        NA        NA
# 336775:        NA        NA
# 336776:        NA        NA
```

The argument is named `with` after the R function `with()` because of similar functionality. Suppose you have a `data.frame` `DF` and you’d like to subset all rows where `x > 1`. In `base` R you can do the following:

``` r
DF = data.frame(x = c(1,1,1,2,2,3,3,3), y = 1:8)

## (1) normal way
DF[DF$x > 1, ] # data.frame needs that ',' as well
#   x y
# 4 2 4
# 5 2 5
# 6 3 6
# 7 3 7
# 8 3 8

## (2) using with
DF[with(DF, x > 1), ]
#   x y
# 4 2 4
# 5 2 5
# 6 3 6
# 7 3 7
# 8 3 8
```

-   Using `with()` in (2) allows using `DF`’s column `x` as if it were a variable.

    Hence the argument name `with` in `data.table`. Setting `with = FALSE` disables the ability to refer to columns as if they are variables, thereby restoring the “`data.frame` mode”.

-   We can also *deselect* columns using `-` or `!`. For example:

    ``` r
    ## not run

    # returns all columns except arr_delay and dep_delay
    ans <- flights[, !c("arr_delay", "dep_delay")]
    # or
    ans <- flights[, -c("arr_delay", "dep_delay")]
    ```

-   From `v1.9.5+`, we can also select by specifying start and end column names, e.g., `year:day` to select the first three columns.

    ``` r
    ## not run

    # returns year,month and day
    ans <- flights[, year:day]
    # returns day, month and year
    ans <- flights[, day:year]
    # returns all columns except year, month and day
    ans <- flights[, -(year:day)]
    ans <- flights[, !(year:day)]
    ```

    This is particularly handy while working interactively.

`with = TRUE` is the default in `data.table` because we can do much more by allowing `j` to handle expressions - especially when combined with `by`, as we’ll see in a moment.

# 2. 聚合

We’ve already seen `i` and `j` from `data.table`’s general form in the previous section. In this section, we’ll see how they can be combined together with `by` to perform operations *by group*. Let’s look at some examples.

## 2.1 分组 `by`

### How can we get the number of trips corresponding to each origin airport?

``` r
ans <- flights[, .(.N), by = .(origin)]
ans
#    origin      N
# 1:    EWR 120835
# 2:    LGA 104662
# 3:    JFK 111279

## or equivalently using a character vector in 'by'
# ans <- flights[, .(.N), by = "origin"]
```

#### 

-   We know `.N` [is a special variable](#special-N) that holds the number of rows in the current group. Grouping by `origin` obtains the number of rows, `.N`, for each group.

-   By doing `head(flights)` you can see that the origin airports occur in the order *“JFK”*, *“LGA”* and *“EWR”*. The original order of grouping variables is preserved in the result. *This is important to keep in mind!*

-   Since we did not provide a name for the column returned in `j`, it was named `N` automatically by recognising the special symbol `.N`.

-   `by` also accepts a character vector of column names. This is particularly useful for coding programmatically, e.g., designing a function with the grouping columns as a (`character` vector) function argument.

-   When there’s only one column or expression to refer to in `j` and `by`, we can drop the `.()` notation. This is purely for convenience. We could instead do:

    ``` r
    ans <- flights[, .N, by = origin]
    ans
    #    origin      N
    # 1:    EWR 120835
    # 2:    LGA 104662
    # 3:    JFK 111279
    ```

    We’ll use this convenient form wherever applicable hereafter.

### How can we calculate the number of trips for each origin airport for carrier code `"AA"`?

The unique carrier code `"AA"` corresponds to *American Airlines Inc.*

``` r
ans <- flights[carrier == "AA", .N, by = origin]
ans
#    origin     N
# 1:    JFK 13783
# 2:    LGA 15459
# 3:    EWR  3487
```

-   We first obtain the row indices for the expression `carrier == "AA"` from `i`.

-   Using those *row indices*, we obtain the number of rows while grouped by `origin`. Once again no columns are actually materialised here, because the `j-expression` does not require any columns to be actually subsetted and is therefore fast and memory efficient.

### How can we get the total number of trips for each `origin, dest` pair for carrier code `"AA"`?

``` r
ans <- flights[carrier == "AA", .N, by = .(origin, dest)]
head(ans)
#    origin dest    N
# 1:    JFK  MIA 2221
# 2:    LGA  ORD 5694
# 3:    LGA  DFW 4836
# 4:    EWR  MIA 1068
# 5:    LGA  MIA 3945
# 6:    JFK  SJU 1099

## or equivalently using a character vector in 'by'
# ans <- flights[carrier == "AA", .N, by = c("origin", "dest")]
```

#### 

-   `by` accepts multiple columns. We just provide all the columns by which to group by. Note the use of `.()` again in `by` – again, this is just shorthand for `list()`, and `list()` can be used here as well. Again, we’ll stick with `.()` in this vignette.

### How can we get the average arrival and departure delay for each `orig,dest` pair for each month for carrier code `"AA"`?

``` r
ans <- flights[carrier == "AA",
        .(mean(arr_delay), mean(dep_delay)),
        by = .(origin, dest, month)]
ans
#      origin dest month      V1     V2
#   1:    JFK  MIA     1  0.4789 12.237
#   2:    LGA  ORD     1      NA     NA
#   3:    LGA  DFW     1      NA     NA
#   4:    EWR  MIA     1  7.6559 15.495
#   5:    LGA  MIA     1      NA     NA
#  ---                                 
# 262:    JFK  IAH     9 -0.4000  9.867
# 263:    JFK  AUS     9      NA 18.900
# 264:    JFK  SAN     9  0.9667 12.600
# 265:    EWR  LAX     9      NA -2.533
# 266:    JFK  SEA     9 -6.6333  8.567
```

#### 

-   Since we did not provide column names for the expressions in `j`, they were automatically generated as `V1` and `V2`.

-   Once again, note that the input order of grouping columns is preserved in the result.

Now what if we would like to order the result by those grouping columns `origin`, `dest` and `month`?

## 2.2 Sorted `by`: `keyby`

`data.table` retaining the original order of groups is intentional and by design. There are cases when preserving the original order is essential. But at times we would like to automatically sort by the variables in our grouping.

### So how can we directly order by all the grouping variables?

``` r
ans <- flights[carrier == "AA",
        .(mean(arr_delay), mean(dep_delay)),
        keyby = .(origin, dest, month)]
ans
#      origin dest month     V1     V2
#   1:    EWR  DFW     1     NA     NA
#   2:    EWR  DFW     2     NA     NA
#   3:    EWR  DFW     3     NA     NA
#   4:    EWR  DFW     4     NA     NA
#   5:    EWR  DFW     5     NA     NA
#  ---                                
# 262:    LGA  STL     7     NA     NA
# 263:    LGA  STL     8     NA     NA
# 264:    LGA  STL     9     NA     NA
# 265:    LGA  STL    10  1.315  1.292
# 266:    LGA  STL    11 -2.228 -4.474
```

#### 

-   All we did was to change `by` to `keyby`. This automatically orders the result by the grouping variables in increasing order. In fact, due to the internal implementation of `by` first requiring a sort before recovering the original table’s order, `keyby` is typically faster than `by` because it doesn’t require this second step.

**Keys:** Actually `keyby` does a little more than *just ordering*. It also *sets a key* after ordering by setting an `attribute` called `sorted`.

We’ll learn more about `keys` in the *Keys and fast binary search based subset* vignette; for now, all you have to know is that you can use `keyby` to automatically order the result by the columns specified in `by`.

## 2.3 链式

Let’s reconsider the task of [getting the total number of trips for each `origin, dest` pair for carrier *“AA”*](#origin-dest-.N).

``` r
ans <- flights[carrier == "AA", .N, by = .(origin, dest)]
```

### How can we order `ans` using the columns `origin` in ascending order, and `dest` in descending order?

We can store the intermediate result in a variable, and then use `order(origin, -dest)` on that variable. It seems fairly straightforward.

``` r
ans <- ans[order(origin, -dest)]
head(ans)
#    origin dest    N
# 1:    EWR  MIA 1068
# 2:    EWR  LAX  365
# 3:    EWR  DFW 2054
# 4:    JFK  TPA  311
# 5:    JFK  STT  303
# 6:    JFK  SJU 1099
```

#### 

-   Recall that we can use `-` on a `character` column in `order()` within the frame of a `data.table`. This is possible to due `data.table`’s internal query optimisation.

-   Also recall that `order(...)` with the frame of a `data.table` is *automatically optimised* to use `data.table`’s internal fast radix order `forder()` for speed.

But this requires having to assign the intermediate result and then overwriting that result. We can do one better and avoid this intermediate assignment to a temporary variable altogether by *chaining* expressions.

``` r
ans <- flights[carrier == "AA", .N, by = .(origin, dest)][order(origin, -dest)]
head(ans, 10)
#     origin dest    N
#  1:    EWR  MIA 1068
#  2:    EWR  LAX  365
#  3:    EWR  DFW 2054
#  4:    JFK  TPA  311
#  5:    JFK  STT  303
#  6:    JFK  SJU 1099
#  7:    JFK  SFO 1422
#  8:    JFK  SEA  365
#  9:    JFK  SAN  365
# 10:    JFK  ORD  365
```

#### 

-   我们可以一个接一个地将表达式并肩连接，形成链式操作，如 `DT[ ... ][ ... ][ ... ]`.

-   或者你也可以以垂直地方式把它们链接起来：

    ``` r
    DT[ ...
       ][ ...
         ][ ...
           ]
    ```

## 2.4 `by` 里的表达式

### Can `by` accept *expressions* as well or does it just take columns?

Yes it does. As an example, if we would like to find out how many flights started late but arrived early (or on time), started and arrived late etc…

``` r
ans <- flights[, .N, .(dep_delay>0, arr_delay>0)]
ans
#    dep_delay arr_delay      N
# 1:      TRUE      TRUE  92303
# 2:     FALSE     FALSE 158900
# 3:     FALSE      TRUE  40701
# 4:      TRUE     FALSE  35442
# 5:     FALSE        NA    488
# 6:      TRUE        NA    687
# 7:        NA        NA   8255
```

#### 

-   The last row corresponds to `dep_delay > 0 = TRUE` and `arr_delay > 0 = FALSE`. We can see that 35442 flights started late but arrived early (or on time).

-   Note that we did not provide any names to `by-expression`. Therefore, names have been automatically assigned in the result. As with `j`, you can name these expressions as you would elements of any `list`, e.g. `DT[, .N, .(dep_delayed = dep_delay>0, arr_delayed = arr_delay>0)]`.

-   You can provide other columns along with expressions, for example: `DT[, .N, by = .(a, b>0)]`.

## 2.5 Multiple columns in `j` - `.SD`

### Do we have to compute `mean()` for each column individually?

It is of course not practical to have to type `mean(myCol)` for every column one by one. What if you had 100 columns to average `mean()`?

How can we do this efficiently, concisely? To get there, refresh on [this tip](#tip-1) - *“As long as the `j`-expression returns a `list`, each element of the `list` will be converted to a column in the resulting `data.table`”*. Suppose we can refer to the *data subset for each group* as a variable *while grouping*, then we can loop through all the columns of that variable using the already- or soon-to-be-familiar base function `lapply()`. No new names to learn specific to `data.table`.

### Special symbol `.SD`:

`data.table` provides a *special* symbol, called `.SD`. It stands for **S**ubset of **D**ata. It by itself is a `data.table` that holds the data for *the current group* defined using `by`.

Recall that a `data.table` is internally a `list` as well with all its columns of equal length.

Let’s use the [`data.table` `DT` from before](#what-is-datatable-1a) to get a glimpse of what `.SD` looks like.

``` r
DT
#    ID a  b  c
# 1:  b 1  7 13
# 2:  b 2  8 14
# 3:  b 3  9 15
# 4:  a 4 10 16
# 5:  a 5 11 17
# 6:  c 6 12 18

DT[, print(.SD), by = ID]
#    a b  c
# 1: 1 7 13
# 2: 2 8 14
# 3: 3 9 15
#    a  b  c
# 1: 4 10 16
# 2: 5 11 17
#    a  b  c
# 1: 6 12 18
# Empty data.table (0 rows and 1 cols): ID
```

#### 

-   `.SD` contains all the columns *except the grouping columns* by default.

-   It is also generated by preserving the original order - data corresponding to `ID = "b"`, then `ID = "a"`, and then `ID = "c"`.

To compute on (multiple) columns, we can then simply use the base R function `lapply()`.

``` r
DT[, lapply(.SD, mean), by = ID]
#    ID   a    b    c
# 1:  b 2.0  8.0 14.0
# 2:  a 4.5 10.5 16.5
# 3:  c 6.0 12.0 18.0
```

#### 

-   `.SD` holds the rows corresponding to columns `a`, `b` and `c` for that group. We compute the `mean()` on each of these columns using the already-familiar base function `lapply()`.

-   Each group returns a list of three elements containing the mean value which will become the columns of the resulting `data.table`.

-   Since `lapply()` returns a `list`, so there is no need to wrap it with an additional `.()` (if necessary, refer to [this tip](#tip-1)).

We are almost there. There is one little thing left to address. In our `flights` `data.table`, we only wanted to calculate the `mean()` of two columns `arr_delay` and `dep_delay`. But `.SD` would contain all the columns other than the grouping variables by default.

### How can we specify just the columns we would like to compute the `mean()` on?

### .SDcols

Using the argument `.SDcols`. It accepts either column names or column indices. For example, `.SDcols = c("arr_delay", "dep_delay")` ensures that `.SD` contains only these two columns for each group.

Similar to [part g)](#refer_j), you can also provide the columns to remove instead of columns to keep using `-` or `!` sign as well as select consecutive columns as `colA:colB` and deselect consecutive columns as `!(colA:colB)` or `-(colA:colB)`.

Now let us try to use `.SD` along with `.SDcols` to get the `mean()` of `arr_delay` and `dep_delay` columns grouped by `origin`, `dest` and `month`.

``` r
flights[carrier == "AA",                       ## Only on trips with carrier "AA"
        lapply(.SD, mean),                     ## compute the mean
        by = .(origin, dest, month),           ## for every 'origin,dest,month'
        .SDcols = c("arr_delay", "dep_delay")] ## for just those specified in .SDcols
#      origin dest month arr_delay dep_delay
#   1:    JFK  MIA     1    0.4789    12.237
#   2:    LGA  ORD     1        NA        NA
#   3:    LGA  DFW     1        NA        NA
#   4:    EWR  MIA     1    7.6559    15.495
#   5:    LGA  MIA     1        NA        NA
#  ---                                      
# 262:    JFK  IAH     9   -0.4000     9.867
# 263:    JFK  AUS     9        NA    18.900
# 264:    JFK  SAN     9    0.9667    12.600
# 265:    EWR  LAX     9        NA    -2.533
# 266:    JFK  SEA     9   -6.6333     8.567
```

## 2.6 Subset `.SD` for each group:

### How can we return the first two rows for each `month`?

``` r
ans <- flights[, head(.SD, 2), by = month]
head(ans)
#    month year day dep_time sched_dep_time dep_delay arr_time
# 1:     1 2013   1      517            515         2      830
# 2:     1 2013   1      533            529         4      850
# 3:    10 2013   1      447            500       -13      614
# 4:    10 2013   1      522            517         5      735
# 5:    11 2013   1        5           2359         6      352
# 6:    11 2013   1       35           2250       105      123
#    sched_arr_time arr_delay carrier flight tailnum origin dest
# 1:            819        11      UA   1545  N14228    EWR  IAH
# 2:            830        20      UA   1714  N24211    LGA  IAH
# 3:            648       -34      US   1877  N538UW    EWR  CLT
# 4:            757       -22      UA    252  N556UA    EWR  IAH
# 5:            345         7      B6    745  N568JB    JFK  PSE
# 6:           2356        87      B6   1816  N353JB    JFK  SYR
#    air_time distance hour minute           time_hour
# 1:      227     1400    5     15 2013-01-01 05:00:00
# 2:      227     1416    5     29 2013-01-01 05:00:00
# 3:       69      529    5      0 2013-10-01 05:00:00
# 4:      174     1400    5     17 2013-10-01 05:00:00
# 5:      205     1617   23     59 2013-11-01 23:00:00
# 6:       36      209   22     50 2013-11-01 22:00:00
```

-   `.SD` is a `data.table` that holds all the rows for *that group*. We simply subset the first two rows as we have seen [here](#subset-rows-integer) already.

-   For each group, `head(.SD, 2)` returns the first two rows as a `data.table`, which is also a `list`, so we do not have to wrap it with `.()`.

## 2.7 Why keep `j` so flexible?

So that we have a consistent syntax and keep using already existing (and familiar) base functions instead of learning new functions. To illustrate, let us use the `data.table` `DT` that we created at the very beginning under [What is a data.table?](#what-is-datatable-1a) section.

### How can we concatenate columns `a` and `b` for each group in `ID`?

``` r
DT[, .(val = c(a,b)), by = ID]
#     ID val
#  1:  b   1
#  2:  b   2
#  3:  b   3
#  4:  b   7
#  5:  b   8
#  6:  b   9
#  7:  a   4
#  8:  a   5
#  9:  a  10
# 10:  a  11
# 11:  c   6
# 12:  c  12
```

#### 

-   That’s it. There is no special syntax required. All we need to know is the base function `c()` which concatenates vectors and [the tip from before](#tip-1).

### What if we would like to have all the values of column `a` and `b` concatenated, but returned as a list column?

``` r
DT[, .(val = list(c(a,b))), by = ID]
#    ID         val
# 1:  b 1,2,3,7,8,9
# 2:  a  4, 5,10,11
# 3:  c        6,12
```

-   Here, we first concatenate the values with `c(a,b)` for each group, and wrap that with `list()`. So for each group, we return a list of all concatenated values.

-   Note those commas are for display only. A list column can contain any object in each cell, and in this example, each cell is itself a vector and some cells contain longer vectors than others.

Once you start internalising usage in `j`, you will realise how powerful the syntax can be. A very useful way to understand it is by playing around, with the help of `print()`.

For example:

``` r
## (1) look at the difference between
DT[, print(c(a,b)), by = ID]
# [1] 1 2 3 7 8 9
# [1]  4  5 10 11
# [1]  6 12
# Empty data.table (0 rows and 1 cols): ID

## (2) and
DT[, print(list(c(a,b))), by = ID]
# [[1]]
# [1] 1 2 3 7 8 9
# 
# [[1]]
# [1]  4  5 10 11
# 
# [[1]]
# [1]  6 12
# Empty data.table (0 rows and 1 cols): ID
```

In (1), for each group, a vector is returned, with length = 6,4,2 here. However (2) returns a list of length 1 for each group, with its first element holding vectors of length 6,4,2. Therefore (1) results in a length of `6+4+2 = 12`, whereas (2) returns `1+1+1=3`.

# 总结

`data.table` 语法的一般形式：

``` r
DT[i, j, by]
```

到目前为止，我们已经看到，

## 使用 `i`:

-   我们可以类似在 `data.frame` 里一样选择行 - 除了你不必重复使用 `DT$`，因为 `data.table` 里的列就是看到的变量。

-   我们可以对 `data.table` 排序 `order()`，内部使用了 `data.table` 实现的快速排序以提高性能。

我们通过 keying a `data.table` 能在 `i` 里做更多，这使得子集筛选操作和连接操作非常快。我们将分别在 *“Keys and fast binary search based subsets”* 和 *“Joins and rolling joins”* 两份文档里介绍这些。

## 使用 `j`:

1.  `data.table` 选择列的方式: `DT[, .(colA, colB)]`.

2.  `data.frame` 选择列的方式: `DT[, c("colA", "colB")]`.

3.  在列上计算: `DT[, .(sum(colA), mean(colB))]`.

4.  如果必要可以提供新的列名给计算结果: `DT[, .(sA =sum(colA), mB = mean(colB))]`.

5.  和 `i` 组合使用: `DT[colA > value, sum(colB)]`.

## 使用 `by`:

-   使用 `by`，我们能够按照指定的列或列名的字符向量甚至是表达式来分组。将 `by` 和 `i` 组合到一起， `j` 的灵活性构成一个非常强大的语法。

-   `by` 可以处理多个列和表达式。

-   我们可以使用 `keyby` 来分组，它对分组的结果自动排序.

-   我们能在 `j` 里使用 `.SD` 和 `.SDcols` 去操作多个列，同时使用一些已经熟悉的 base 函数。这是一些例子：

    1.  `DT[, lapply(.SD, fun), by = ..., .SDcols = ...]` - 将函数 `fun` 应用到在 `.SDcols` 指定的列上，同时根据 `by` 指定的列分组.

    2.  `DT[, head(.SD, 2), by = ...]` - 返回每个组的前两行。

    3.  `DT[col > val, head(.SD, 1), by = ...]` - 组合 `i` 和 `j` 与 `by` 一起使用。

<div class="rmdtip">

只要 `j` 返回一个 `list`， 那么列表里的每一个元素在返回的 `data.table` 里都会变成一个列。

在下一份文档中，我们将会介绍如何通过引用的方式添加/更新/删除列，如何用 `i` 和 `by` 组合他们。

</div>

# 环境信息（笔者加）

在 RStudio IDE 内编辑本文的 R Markdown 源文件，用 **blogdown** 构建网站，[Hugo](https://github.com/gohugoio/hugo) 渲染 knitr 之后的 Markdown 文件，得益于 **blogdown** 对 R Markdown 格式的支持，图、表和参考文献的交叉引用非常方便，省了不少文字编辑功夫。文中使用了多个 R 包，为方便复现本文内容，下面列出详细的环境信息：

``` r
xfun::session_info(packages = c(
  "knitr", "rmarkdown", "blogdown", "data.table"
))
# R version 4.1.2 (2021-11-01)
# Platform: x86_64-apple-darwin17.0 (64-bit)
# Running under: macOS Big Sur 10.16
# 
# Locale: en_US.UTF-8 / en_US.UTF-8 / en_US.UTF-8 / C / en_US.UTF-8 / en_US.UTF-8
# 
# Package version:
#   base64enc_0.1.3   blogdown_1.6      bookdown_0.24    
#   data.table_1.14.2 digest_0.6.28     evaluate_0.14    
#   fastmap_1.1.0     glue_1.5.0        graphics_4.1.2   
#   grDevices_4.1.2   highr_0.9         htmltools_0.5.2  
#   httpuv_1.6.3      jquerylib_0.1.4   jsonlite_1.7.2   
#   knitr_1.36        later_1.3.0       magrittr_2.0.1   
#   methods_4.1.2     mime_0.12         promises_1.2.0.1 
#   R6_2.5.1          Rcpp_1.0.7        rlang_0.4.12     
#   rmarkdown_2.11    servr_0.24        stats_4.1.2      
#   stringi_1.7.5     stringr_1.4.0     tinytex_0.35     
#   tools_4.1.2       utils_4.1.2       xfun_0.28        
#   yaml_2.2.1       
# 
# Pandoc version: 2.16.1
# 
# Hugo version: 0.89.2
```
