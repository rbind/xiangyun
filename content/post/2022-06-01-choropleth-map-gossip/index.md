---
title: 《地区分布图及其应用》的注记
author: 黄湘云
date: '2022-05-12'
slug: contributions-to-the-choropleth-map
categories:
  - 统计应用
tags:
  - 数据操作
  - 数据重整
  - 统计地图
  - tidyr
  - Base R
toc: true
draft: true
link-citations: true
bibliography: 
  - refer.bib
description: "本文是一篇关于《地区分布图及其应用》的注记"
---

## 关于地区分布图的绘制

``` r
data(USCancerRates, package = "latticeExtra")
```

``` r
# 宽格式转长格式
us_cancer_rates <- reshape(
  data = USCancerRates,
  # 需要转行的列
  varying = c(
    "LCL95.male", "rate.male", "UCL95.male",
    "LCL95.female", "rate.female", "UCL95.female"
  ),
  times = c("男性", "女性"), # 构成新列 sex 的列值
  v.names = c("LCL95", "rate", "UCL95"), # 列转行 列值构成的新列，指定名称
  timevar = "sex", # 列转行 列名构成的新列，指定名称
  idvar = c("state", "county"), # 可识别郡的 ID
  # 原数据有 3041 行，性别字段只有两个取值，转长格式后有 2*3041 行
  new.row.names = 1:(2 * 3041),
  direction = "long"
)
```

``` r
us_cancer_rates <- within(us_cancer_rates, {
  state <- tolower(state)
  county <- tolower(county)
  county <- gsub(pattern = "( county)|( parish)", replacement = "", x = county)
})
```

路易斯安那州下属各行政单元不叫某某郡县 County 而叫某某教区 Parish。
对比国内，基本上每年各级行政区域的名称都有少量更改，比如撤县划市，村镇街道合并等等，越靠近基层的行政单元更改的量越大，一则地理单元的名称、辖区本身适应经济发展需要经常改，二则不同的体系下甚至各有一套，
比如美国人口调查局一套，发布癌症死亡率数据的 NCI 一套，
R 包 **maps** 二次加工一套，**ggplot2** 包在 **maps** 包基础上再次加工，又是一套，
这种层层加工将地理单元的唯一编码 FIPS 丢掉了，导致数据上难以关联准确。

``` r
library(ggplot2)
# 获取州、郡级地图数据
us_state_map <- map_data(map = "state")
us_county_map <- map_data(map = "county")
```

``` r
# 合并观测数据和地图数据
us_cancer_rates2 <- merge(
  x = us_county_map,
  y = us_cancer_rates,
  by.x = c("region", "subregion"), # region 首字母小写的各州名称
  by.y = c("state", "county"),
  all.x = TRUE,
  sort = FALSE
)

# 排序
us_cancer_rates2 <- us_cancer_rates2[order(us_cancer_rates2$order), ]

# 癌症死亡率分级
us_cancer_rates2$rate_d <- cut(us_cancer_rates2$rate, breaks = 50 * 0:13)

# 去掉缺失 rate 的记录
us_cancer_rates2 <- subset(x = us_cancer_rates2, subset = !is.na(sex))
```

``` r
ggplot(data = us_cancer_rates2, aes(long, lat, group = subregion)) +
  geom_map(aes(map_id = region),
           map = us_county_map,
           fill = "grey80"
  ) +
  geom_polygon(aes(group = group, fill = rate_d), color = NA) +
  geom_map(aes(map_id = region),
           map = us_state_map,
           colour = "gray80", fill = NA, size = 0.15
  ) +
  coord_map("orthographic", orientation = c(39, -98, 0)) +
  scale_fill_viridis_d(option = "plasma", na.value = "grey80") +
  facet_wrap(~sex, ncol = 1, strip.position = "top") +
  labs(
    fill = "死亡率", title = "1999-2003 年美国各个郡的年平均癌症死亡率",
    caption = "数据源：美国国家癌症研究所"
  ) +
  theme_void(base_size = 13) +
  theme(plot.title = element_text(hjust = 0.5))
```

<div class="figure" style="text-align: center">

<img src="{{< blogdown/postref >}}index_files/figure-html/ggplot2-maps-1.png" alt="1999-2003 年美国各个郡的年平均癌症死亡率分布" width="768" />
<p class="caption">
图 1: 1999-2003 年美国各个郡的年平均癌症死亡率分布
</p>

</div>

## 关于美国各郡县癌症死亡率

结合美国疾控预防中心（Centers for Disease Control and Prevention，简称 CDC）发布的2021年统计报告([Jiaquan et al. 2021](#ref-Xu2021))，假定死亡人数服从泊松分布，暂不谈抽样误差，具体到某一个年度调查，每一个州每一个年龄段癌症死亡人数 `\(X\)` 服从泊松分布 `\(P(\lambda)\)`

$$
P(X=k) = \mathrm{e}^{ - \lambda} \frac{\lambda^k}{k!}
$$

已知泊松分布的期望 `\(E\)` 和方差 `\(D\)` 都是 `\(\lambda\)`，期望在这里的含义就是预期死亡人数。
该州的人口数以 `\(P\)` 表示，这是一个常数，而年龄调整的死亡率的标准差：

$$
\sqrt{\mathrm{Var}(\frac{X}{P})} = \sqrt{ \frac{1}{P^2}\mathrm{Var}(X)} = \sqrt{ \frac{D}{P^2}}
$$

考虑到有些地方死亡人数小于 100，因此死亡人数的分布需要用伽马分布的刻画。

## 关于美国人口结构

纵观过去，美国是没有老龄化现象的，惊不惊讶，意不意外！笔者初看有点意外，想了会儿又觉得是情理之中。有些基本问题无论从前还是未来，无论发达国家还是发展中国家，都要给出自己的解法。笔者不准备讨论与国家政策相关的敏感话题，仅推荐一本正儿八经的人物传记—现代统计学家《Neyman》([Reid 1982](#ref-Reid1982))，有相应中译版《耐曼》([Reid 1985](#ref-Yao1985))，里面给出了一些线索。

笔者英文水平有限，看的是中文版，推荐有条件的读者尝试看英文版，应该会舒服得多。《Neyman》书中多次提及另一本卡尔·皮尔逊（Karl Person）的著作《The Grammar of Science》([Person 1911](#ref-Person1911))，也有中译本《科学的规范》([Person 1998](#ref-Person1998))，值得一读。众所周知，耐曼在波兰和英国时期和爱根·皮尔逊（E. S. Person）在假设检验和置信区间理论方面有大量合作，一起奠定了统计学严格的数学基础。耐曼的早期工作从卡尔·皮尔逊时代开始，研究了大量实际问题，所以，了解一些生活中实在的具体问题，就不会被 N-P 引理折磨了。于我个人而言，毕业以后，第一阶段应用，从书中来到工作中去，第二阶段理论，从工作中来到书中去。我的第一阶段正在进行中，第二阶段不知道什么时候开始。

## 关于数据操作

大部分的数据可视化和统计建模函数要求「长格式」的数据，所以，从「宽格式」到「长格式」是更常见的变形操作。以上对数据集 USCancerRates 从「宽格式」到「长格式」的变形操作是非常典型的，读者可对照帮助文档 `?reshape()` 和如下两种方式理解其他传参方式对结果的影响，以加深对变形操作的理解。

``` r
# 方式二
reshape(
  data = USCancerRates,
  varying = list(
    LCL95 = c("LCL95.male", "LCL95.female"),
    rate = c("rate.male", "rate.female"),
    UCL95 = c("UCL95.male", "UCL95.female")
  ),
  times = c("男性", "女性"), # 可选，最好填
  v.names = c("LCL95", "rate", "UCL95"), # 可选，最好填
  timevar = "sex", # 可选，最好填
  idvar = c("state", "county"), # 必填
  new.row.names = 1:(2 * 3041), # 可选，最好填
  direction = "long"
)
# 方式三
reshape(
  data = USCancerRates,
  varying = list(
    LCL95 = c("LCL95.male", "LCL95.female"),
    rate = c("rate.male", "rate.female"),
    UCL95 = c("UCL95.male", "UCL95.female")
  ),
  # times = c("男性", "女性"),
  # v.names = c("LCL95", "rate", "UCL95"),
  timevar = "sex",
  idvar = c("state", "county"),
  new.row.names = 1:(2 * 3041),
  direction = "long"
)
```

关于数据操作，在不影响效率的情况下，笔者会优先选择 Base R 来做数据操作，若遇到小规模数据会考虑调用 **data.table** 来处理，若遇到大规模数据肯定是用 SQL 来处理，聚合完继续用 Base R 或 **data.table** 处理。工作几年下来，任凭窗外云卷云舒，在稳定和效率面前，我自岿然不动，看过不少净土代码，也写过一些，所知有限，不敢示人，常晓其大意，换之以 Base R。

处理数百 GB 乃至 TB 级的海量数据，聚合计算通常都是由写 SQL 完成的，不太可能直接用 R 语言或 Python 语言去处理，什么牛逼的工具包都不行！SQL 聚合计算后得到的数据集就 KB 或 MB级，大约几千，几万或几十万，即使遇到几百万条记录，也是用 SQL 再按需聚合。只在最后，为了可视化和分析建模，对 SQL 查询后的数据做各种适应性变换，这其中变形重塑的数据操作是最常见的，也是最复杂的数据操作，并且在SQL中实现复杂而在R中非常简单。用户唯一的痛点是非常难记住 reshape 的到底是谁，长变宽还是宽变长。R 语言社区陆续出现一些工具，从 `reshape()` 函数到 **reshape** 包([Wickham 2007](#ref-Wickham2007))，再到 **reshape2** 包，再到 **tidyr** 包([Wickham and Girlich 2022](#ref-Wickham2022))，一路折腾，还是应该回归到出发点来看待 `reshape()` 函数。

R 软件内置的函数 `reshape()` 有很丰富的解释。所谓的「宽格式」和「长格式」数据来源于纵向数据分析领域 longitudinal data analysis — 对同一对象的同一特征在不同时间点重复测量分析（假定对象没有随时间发生变化），也可以是对多个特征在不同时间点重复测量，这些特征就是所谓的时间变量（随时间变化的变量）timevar（time-varying variables），具体地，测量一个人的头发长度，有的特征随时间不会变化，比如性别、种族等，称之为时间常量（time-constant variables）。函数 `reshape()` 的参数就采用纵向数据分析的术语。R 是一个用于统计计算和绘图的编程语言和环境，主要由统计学家开发和维护，很多重要的函数要回归到统计上去理解，才会豁然开朗。

## 关于栅格绘图系统

``` r
library(lattice)
trellis.device(
  device = postscript, color = TRUE, file = "lattice.ps",
  paper = "letter", horizontal = TRUE, onefile = TRUE
)
show.settings()
dev.off()
```

设置全局主题风格为 ggplot2 风

``` r
trellis.par.set(ggplot2like())
```

**latticeExtra** 包内置经济学人杂志的主题

``` r
trellis.par.set(theEconomist.theme())
xyplot(window(sunspot.year, start = 1900),
  main = "Sunspot cycles", sub = "Number per year",
  par.settings = theEconomist.theme(box = "transparent"),
  lattice.options = theEconomist.opts()
)
```

## 关于空间坐标投影

**sf** 包内置的北卡州郡级地图数据集 `nc.gpkg` 坐标参考系为 [`EPSG:4267`](https://epsg.io/4267)，而通常使用的 **leaflet** 包([Cheng, Karambelkar, and Xie 2022](#ref-leaflet))和 **mapdeck** 包([Cooley 2020](#ref-mapdeck))需要地图数据集转化到 [`EPSG:4326`](https://epsg.io/4326)，其细微差别详见 Hiroaki Yutani 的博客 ([Yutani 2018](#ref-Yutani2018))。本文源文档提供图<a href="#fig:us-nc-income"><strong>??</strong></a>的 **leaflet** 绘图代码，此处不再介绍。若使用国内的 Web 地图服务，一般需要地图数据转化到[火星坐标系](https://en.wikipedia.org/wiki/Restrictions_on_geographic_data_in_China)，其间会存在一定的[漂移](https://gis.stackexchange.com/questions/234202)。

``` r
# 读取数据
nc_income_race_county <- readRDS(file = "data/nc_income_race_county.rds")
nc_income_race_tract <- readRDS(file = "data/nc_income_race_tract.rds")
# 计算家庭年收入和白人占比数据
nc_income_race_tract <- within(nc_income_race_tract, {
  pop <- B02001_001E
  pctWhite <- B02001_002E / B02001_001E
  medInc <- B19013_001E
})
# 将坐标参考系转化为 4326，准备以 leaflet 绘制地图
nc_income_race_tract <- st_transform(nc_income_race_tract, crs = 4326)
# 获取 NC 的几何中心，用于设置观察中心 setView
st_bbox(nc_income_race_tract)
# 加载 R 包
library(leaflet)
# 人口密度分段
bins <- c(0:10, 15, 20, 25) * 10000
# 构造调色板
pal <- colorBin("plasma", domain = nc_income_race_tract$medInc, bins = bins)
# 绘图渲染需要一点时间
leaflet(nc_income_race_tract) |>
  setView(lng = -79.86, lat = 35.17, zoom = 8) |>
  # 添加默认的 OpenStreetMap 瓦片服务
  addTiles() |>
  addPolygons(
    color = "white", # 边界线颜色
    opacity = 0.6,     # 颜色透明度
    weight = 0.2,      # 边界线宽度
    fillOpacity = 0.6,   # 填充色透明度
    fillColor = ~ pal(medInc)  # 填充色
  ) |>
  addLegend(
    pal = pal,
    values = ~medInc,
    opacity = 0.7,
    title = "家庭收入",
    position = "bottomright"
  )
# 可以继续补充悬浮提示 label 和 popup
# 还可以抽取各个地理单元的几何中心，以比例气泡图展示收入数据
st_centroid(st_geometry(nc_income_race_tract))
```

## 关于空间数据操作

在写作过程中查找了不少材料，发现一个事实，即使在空间统计领域，崇拜 **tidyverse** ([Wickham et al. 2019](#ref-Wickham2019))的人也对 Base R 充满敌视，措辞非常严厉。笔者曾请教 **tidycensus** 包作者[一些问题](https://github.com/walkerke/tidycensus/issues/439)，尽管问题本身和 Base R 没有太多关系，但人家会毫无理由地严厉地批评 `base::merge()` 而后推荐 `dplyr::left_join()`，读者遇到此类问题，请辩证地看待。据笔者深入了解，**sf** 及整个空间数据处理的基础框架都没有偏向 **tidyverse** 的意思，Edzer J. Pebesma 在 RStudio 2019 年会上的报告 — [Spatial data science in the Tidyverse](https://resources.rstudio.com/rstudio-conf-2019/spatial-data-science-in-the-tidyverse) — 被很多人当作 **sf** 生态偏向 **tidyverse** 的标志。**sf** 是中立的，最初支持 Base R 数据操作和统计作图，后来支持部分净土操作，实际上 **data.table** ([Dowle and Srinivasan 2021](#ref-Dowle2021))也将在[下个版本](https://github.com/Rdatatable/data.table/pull/5224)更好地支持 **sf** 的空间数据类型。此外，若将本文中的代码替换为[净土代码](https://yihui.org/cn/2019/07/tidy-noise/)，将引入很多的 R 包依赖，并在不久的将来有丧失可重复性的风险。

## 关于数据分析

最后，建议尽量寻求来源权威可靠的第一手材料，对手头现有的材料有追根溯源和交叉验证的热情。数据操作的过程应满足可重复性的基本要求，以便检查分析过程和结论。度量指标需要围绕专题分析的目标，并结合实际背景选择合适的维度拆解。借助统计工具分析隐藏数据中的深层规律，科学定量地刻画，并将规律用领域语言表达，最后，结合软件工具选用恰当的图形准确呈现，直观定性地表达降低沟通成本，快速形成决策建议，乃至落地推广。

## 关于空间统计

在写作过程中，陆续遇到一些虽未直接引用但有价值的材料：

-   芝加哥大学空间数据科学中心有一些培训材料，从入门开始讲解，比较系统全面细致，推荐读者看看([Anselin 2019](#ref-Anselin2019))。

-   Edzer Pebesma 在历年 useR! 大会上的材料，如[2016年](https://edzer.github.io/UseR2016/)、[2017年](https://edzer.github.io/UseR2017/)、[2019年](https://github.com/edzer/UseR2019)、[2020年](https://edzer.github.io/UseR2020/)、[2021年](https://edzer.github.io/UseR2021/)。

-   Edzer Pebesma 和 Roger Bivand 合著的书籍[《Spatial Data Science with applications in R》](https://www.r-spatial.org/book) 架起了理论到应用的桥梁，详细阐述了空间数据科学的基本概念和统计方法，R 语言在空间统计生态的过去、现在和未来。

## 关于地区分布图应用

-   **区域经济方面**，改革开放40多年，最显著的变化就是城市化，大量人口进城，以互联网技术为基础，围绕吃穿住行、教育发展和休闲娱乐，餐饮外卖行业，新零售行业，房地产行业，出行行业，教育培训行业，以及休闲娱乐行业，互联网横向在各行各业渗透，纵向从一二线城市到三四五线城市下沉。大数据、互联网、人工智能等新技术极大地推动智慧城市规划和建设。「以经济建设为中心，一百年不动摇」必将在下一个四十年为城市发展持续注入动力。这就是当今中国社会最大的因，因果推断技术本质是从因推断果，而不是相反。围绕此核心分析总体概况，从时间（趋势）、空间（地域）两个维度，拆解分析人群、行业变化，相信可以据此理解已经发生的、正在发生的和将要发生的一系列事情，而衡量中国城市化进程最直接的结果指标就是中国城镇化率。

## 关于时空统计应用

本文涉及的都属于区域数据（Lattice / Area data），另外还有 Point referenced data / Geostatistics data 和 Point process data 两类。

企业层面，根据2021年[中国地理信息产业发展报告](http://www.cagis.org.cn/Lists/content/id/3440.html)，截止2020年末，具有测绘资质的单位约**2.2**万家，甲级资质的企事业单位的空间数据价值非常巨大。国内以百度、高德、腾讯和华为为代表的地图服务供应商，在本地生活、智慧交通、智慧城市、无人车、无人机等领域提供高精电子导航等基础服务。

国家层面，电视剧《雍正王朝》里有一个镜头，胤禛办完江南筹款赈灾向康熙汇报民情，各省上报的土地逐年减少，税收也逐年减少，仅此一弊，国家不堪其忧。国家依靠层层上报的数据可能存在虚假成分，不利于国家及时掌握真实情况。2021年中华人民共和国自然资源部发布[2020年卫星遥感应用报告](http://gi.mnr.gov.cn/202108/P020210901375952588128.pdf)，目前数据规模达到 **1.6 PB**，相比于一些互联网公司每天产生的数据量，未来发展空间还十分巨大。2021年中华人民共和国自然资源部发布[第三次全国国土调查主要数据公报](http://www.mnr.gov.cn/dt/ywbb/202108/t20210826_2678340.html)，基于高分辨率的卫星遥感影像数据，广泛应用移动互联网、云计算、无人机等新技术，全面查清了全国国土利用状况。要提升整体的社会系统建设，科学技术就是一个抓手。比起历朝历代，通过现代化技术可以极大地降低调查成本，提高数据准确性和可靠性，以科学的方法推进国家治理体系和治理能力现代化。

# 参考文献

<div id="refs" class="references csl-bib-body hanging-indent">

<div id="ref-Anselin2019" class="csl-entry">

Anselin, Luc. 2019. “Introduction to Spatial Data Science.” <https://spatialanalysis.github.io/tutorials/>.

</div>

<div id="ref-leaflet" class="csl-entry">

Cheng, Joe, Bhaskar Karambelkar, and Yihui Xie. 2022. *Leaflet: Create Interactive Web Maps with the JavaScript Leaflet Library*. <https://rstudio.github.io/leaflet/>.

</div>

<div id="ref-mapdeck" class="csl-entry">

Cooley, David. 2020. *Mapdeck: Interactive Maps Using ’Mapbox GL JS’ and ’Deck.gl’*. <https://CRAN.R-project.org/package=mapdeck>.

</div>

<div id="ref-Dowle2021" class="csl-entry">

Dowle, Matt, and Arun Srinivasan. 2021. *<span class="nocase">data.table</span>: Extension of ‘Data.frame‘*. <https://CRAN.R-project.org/package=data.table>.

</div>

<div id="ref-Xu2021" class="csl-entry">

Jiaquan, Xu, Sherry L. Murphy, Kenneth D. Kochanek, and Elizabeth Arias. 2021. “Deaths: Final Data for 2019.” 8. Vol. 70. National Vital Statistics Reports. National Center for Health Statistics. <https://www.cdc.gov/nchs/data/nvsr/nvsr70/nvsr70-08-508.pdf>.

</div>

<div id="ref-Person1911" class="csl-entry">

Person, Karl. 1911. *The Grammar of Science*. 3rd ed. London: Adam; Charles Black.

</div>

<div id="ref-Person1998" class="csl-entry">

———. 1998. *科学的规范*. Translated by 李醒民. 北京: 华夏出版社.

</div>

<div id="ref-Reid1982" class="csl-entry">

Reid, Constance. 1982. *Neyman*. New York, NY: Springer-Verlag. <https://doi.org/10.1007/978-1-4612-5754-7>.

</div>

<div id="ref-Yao1985" class="csl-entry">

———. 1985. *耐曼*. Translated by 姚慕生, 陈克艰, and 王顺义等. 上海: 上海翻译出版公司.

</div>

<div id="ref-Wickham2007" class="csl-entry">

Wickham, Hadley. 2007. “Reshaping Data with the <span class="nocase">reshape</span> Package.” *Journal of Statistical Software* 21 (12). <https://www.jstatsoft.org/v21/i12/>.

</div>

<div id="ref-Wickham2019" class="csl-entry">

Wickham, Hadley, Mara Averick, Jennifer Bryan, Winston Chang, Lucy D’Agostino McGowan, Romain François, Garrett Grolemund, et al. 2019. “Welcome to the <span class="nocase">tidyverse</span>.” *Journal of Open Source Software* 4 (43): 1686. <https://doi.org/10.21105/joss.01686>.

</div>

<div id="ref-Wickham2022" class="csl-entry">

Wickham, Hadley, and Maximilian Girlich. 2022. *<span class="nocase">tidyr</span>: Tidy Messy Data*. <https://CRAN.R-project.org/package=tidyr>.

</div>

<div id="ref-Yutani2018" class="csl-entry">

Yutani, Hiroaki. 2018. “Plot <span class="nocase">geom_sf()</span> on OpenStreetMap Tiles.” <https://yutani.rbind.io/post/2018-06-09-plot-osm-tiles/>.

</div>

</div>
