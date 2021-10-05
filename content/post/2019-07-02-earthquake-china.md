---
title: 地震数据可视化
author: 黄湘云
date: '2019-07-02'
slug: earthquake-visualization
categories:
  - 统计图形
tags:
  - ggplot2
  - 数据可视化
draft: true
thumbnail: https://wp-contents.netlify.com/2019/07/earthquake-china-jitter.png
description: "quake6 数据集记录了 1973年至 2010 年全球六级以上地震强度的变化，从中国地震台网 <http://www.ceic.ac.cn> 下载了2012年4月26日至2019年6月30日的地震数据"
---

# 1973年至2010年全球地震强度变化

quake6 数据集记录了 1973年至 2010 年全球六级以上地震强度的变化

```r
library(MSG)
data(quake6)
head(quake6)
```
```
  Cat year month day     time    lat   long dep magnitude
1 PDE 1973     1   1 114237.5 -35.51 -16.21  33       6.0
2 PDE 1973     1   5 135429.1 -39.00 175.23 150       6.2
3 PDE 1973     1   6 155241.9 -14.66 166.38  36       6.1
4 PDE 1973     1  10 113227.4 -11.10 162.28  32       6.0
5 PDE 1973     1  15  90258.3  27.08 140.10 477       6.0
6 PDE 1973     1  18  92814.1  -6.87 149.99  43       6.8
```

一共 4999 条记录，9个字段

```r
dim(quake6)
```
```
[1] 4999    9
```

分组统计每年地震次数

```r
table(quake6$year)
```
```
1973 1974 1975 1976 1977 1978 1979 1980 1981 1982 1983 1984 1985 1986 1987 
 106  113  120  127  102  109  113  117  102   94  137   97  124   92  117 
1988 1989 1990 1991 1992 1993 1994 1995 1996 1997 1998 1999 2000 2001 2002 
  99   84  127  124  179  149  159  203  164  136  121  134  161  137  140 
2003 2004 2005 2006 2007 2008 2009 2010 
 155  157  151  153  196  180  153   67 
```

散点图每个年份一条线，添加抖动

```r
library(ggplot2)
png(filename = "earthquake-world-jitter.png", width = 20*80, height = 20*80, res = 150, type = "cairo")
ggplot(quake6, aes(x = as.factor(year), y = magnitude, colour = as.factor(year))) + 
  ggbeeswarm::geom_quasirandom(groupOnX = TRUE) +
  coord_flip() + 
  geom_jitter() +
  theme_minimal() + 
  theme(legend.position = "none") +
  labs(y = "magnitude", x = "year")
dev.off()
# 密度岭线图
ggplot(quake6, aes(x = magnitude, y = as.factor(year), fill = as.factor(year))) +
  ggridges::geom_density_ridges() + 
  theme_minimal() + 
  theme(legend.position = "none") +
  labs(x = "magnitude", y = "year")
# 岭线图
ggplot(quake6, aes(x = magnitude, y = as.factor(year), height = ..density..)) +
  ggridges::geom_ridgeline(stat = "density") +
  theme_minimal() + 
  theme(legend.position = "none") +
  labs(x = "magnitude", y = "year")
```

![1973 年至 2010 年世界6级以上地震情况](https://wp-contents.netlify.com/2019/07/earthquake-world-jitter.png)

地震的总体情况

```r
boxplot(quake6$magnitude, xlab = "", ylab = "magnitude")
```

![1973 年至 2010 年世界6级以上地震情况](https://wp-contents.netlify.com/2019/07/earthquake-world-boxplot.png)

取一部分年份展示地震数据集，这时类别比较少，点也比较少

```r
sub_quake6 <- subset(quake6, year >= 2005 & year <= 2010)
ggplot(sub_quake6, aes(x = as.factor(year), y = magnitude, colour = as.factor(year))) + 
  ggbeeswarm::geom_quasirandom(groupOnX = TRUE) +
  coord_flip() + 
  theme_minimal() + 
  theme(legend.position = "none") +
  labs(y = "magnitude", x = "year")
```

![2005 年至 2010 年世界6级以上地震情况](https://wp-contents.netlify.com/2019/07/earthquake-world-subset.png)

类别少，点多，我们继续尝试箱线图和小提琴图

```r
p1 <- ggplot(sub_quake6, aes(x = as.factor(year), y = magnitude, colour = as.factor(year))) + 
  geom_boxplot() +
  theme_minimal() + 
  theme(legend.position = "none") +
  labs(y = "magnitude", x = "year")
p2 <- ggplot(sub_quake6, aes(x = as.factor(year), y = magnitude, colour = as.factor(year))) + 
  geom_violin() +
  theme_minimal() + 
  theme(legend.position = "none") +
  labs(y = "magnitude", x = "year")  
library(gridExtra)
grid.arrange(p1, p2)
```

![2005 年至 2010 年世界6级以上地震情况](https://wp-contents.netlify.com/2019/07/earthquake-world-subset-boxplot-violin.png)

```r
library(MSG)
data(quake6)
library(ggplot2)
library(ggthemes)
library(data.table)

week.abb <- c('Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun')
month.abb <- c("Jan", "Feb", "Mar", "Apr", "May", "Jun", 
               "Jul", "Aug", "Sep", "Oct", "Nov", "Dec")

quake6 <- transform(quake6, date = paste(year, month, day, sep = "-"))
quake6$week <- week(quake6$date)
quake6$weekdays <- factor(wday(quake6$date), labels = week.abb)

pdf(file = "mag.pdf", width = 16, height = 8)
ggplot(quake6, aes(x = week, y = weekdays, fill = magnitude)) +
    scale_fill_viridis_c(name="magnitude", option = "C", limits = range(quake6$magnitude)) +
    geom_tile(color = "white", size = 0.4) +
    facet_wrap("year", ncol = 5) +
    scale_x_continuous(expand = c(0, 0), breaks = seq(1, 52, length = 12), labels = month.abb)+
    theme_tufte()
dev.off()
```

## 中国近年来的地震情况

从中国地震台网 <http://www.ceic.ac.cn> 下载2012年4月26日至2019年6月30日的地震数据，由于得到的是一个奇葩的 xls 文件，我们只好带着错误打开，并从剪切板读取数据

```r
eq <- readClipboard()
head(eq)
```
```
[1] "发震时刻\t震级(M)\t纬度(°)\t经度(°)\t深度(千米)\t参考位置"   
[2] "2019-06-30 21:44:44\t3\t27.56\t112.1\t6\t湖南娄底市双峰县"   
[3] "2019-06-30 21:32:29\t3.1\t28.44\t104.81\t8\t四川宜宾市长宁县"
[4] "2019-06-30 12:14:25\t3\t28.43\t104.77\t9\t四川宜宾市珙县"    
[5] "2019-06-30 03:44:11\t4.8\t22.43\t122.31\t30\t台湾台东县海域" 
[6] "2019-06-30 03:09:29\t3.1\t31\t98.96\t7\t四川甘孜州白玉县"    
```

为了方便重现本文内容，我对原始数据清理了一番，清理后的数据集存放在 <https://wp-contents.netlify.com/data/earthquake20190630.csv>

```r
eq2 <- Reduce('rbind', strsplit(eq[-1], split = "\t"))
colnames(eq2) <- unlist(strsplit(eq[1], split = "\t"))
rownames(eq2) <- NULL
eq2 <- as.data.frame(eq2)
eq2[,2] <- as.numeric(eq2[,2])
eq2[,3] <- as.numeric(eq2[,3])
eq2[,4] <- as.numeric(eq2[,4])
eq2[,5] <- as.numeric(eq2[,5])
write.csv(eq2, file = "earthquake20190630.csv", row.names = FALSE)
```

以后只需将数据集下载下来，直接读取

```r
eq <- read.csv(file = "earthquake20190630.csv", check.names = FALSE)
# 或者直接从线上读取
eq <- read.csv(file = "https://wp-contents.netlify.com/data/earthquake20190630.csv", check.names = FALSE)
```

从字符串日期中提取年、月、日，大鹏提供了更简单优雅的日期提取方式，见 <https://d.cosx.org/d/420854>

```r
extract_date <- function(x) {
  m <- regexec("((?<year>(\\d{4}))-(?<month>(\\d{1,2}))-(?<day>(\\d{1,2})))", x, perl = TRUE)
  parts <- do.call(rbind,
                   lapply(regmatches(x, m), `[`, c(2L, 4L, 6L, 8L)))
  colnames(parts) <- c("date", "year", "month", "day")
  parts
}

equake <- cbind(eq, extract_date(eq[, 1]))
head(equake)
```
```
             发震时刻 震级(M) 纬度(°) 经度(°) 深度(千米)         参考位置
1 2019-06-30 21:44:44     3.0   27.56  112.10          6 湖南娄底市双峰县
2 2019-06-30 21:32:29     3.1   28.44  104.81          8 四川宜宾市长宁县
3 2019-06-30 12:14:25     3.0   28.43  104.77          9   四川宜宾市珙县
4 2019-06-30 03:44:11     4.8   22.43  122.31         30   台湾台东县海域
5 2019-06-30 03:09:29     3.1   31.00   98.96          7 四川甘孜州白玉县
6 2019-06-30 03:07:58     3.1   31.02   98.96          8 四川甘孜州白玉县
        date year month day
1 2019-06-30 2019    06  30
2 2019-06-30 2019    06  30
3 2019-06-30 2019    06  30
4 2019-06-30 2019    06  30
5 2019-06-30 2019    06  30
6 2019-06-30 2019    06  30
```

统计截止目前2019年6月30日为止，各年地震次数

```r
table(equake$year)
```
```
2012 2013 2014 2015 2016 2017 2018 2019 
 511 1071  961  943  902  810  910  610 
```

2012年04月26日至2019年06月30日世界各地地震情况

```r
colnames(equake) <- c("time", "magnitude", "lat", "long", "depth", "location", "date", "year", "month", "day")
ggplot(equake, aes(x = as.factor(year), y = magnitude, colour = as.factor(year))) + 
  ggbeeswarm::geom_quasirandom(groupOnX = TRUE) +
  coord_flip() + 
  geom_jitter() +
  theme_minimal(base_size = 25) + 
  theme(legend.position = "none") +
  labs(y = "magnitude", x = "year")
```

![2012年04月26日至2019年06月30日世界各地地震情况](https://wp-contents.netlify.com/2019/07/earthquake-china-jitter.png)


```r
png(filename = "earthquake-china-ridge.png", width = 10*80, height = 10*80, res = 150, type = "cairo")
ggplot(equake, aes(y = as.factor(year), x = magnitude, fill = as.factor(year))) +
  ggridges::geom_density_ridges() + 
  theme_minimal() + 
  theme(legend.position = "none") +
  labs(x = "magnitude", y = "year")
dev.off()
```

![2012年04月26日至2019年06月30日世界各地地震情况](https://wp-contents.netlify.com/2019/07/earthquake-china-ridge.png)


## 地图

```r
library(ggplot2)
# 数据来源 http://news.ceic.ac.cn
# 数据采集时间段 2012.04.26 - 2019.6.30
worldquake <- read.csv(
  file = "https://wp-contents.netlify.com/data/earthquake20190630.csv",
  check.names = FALSE
)
head(worldquake)
```
```
             发震时刻 震级(M) 纬度(°) 经度(°) 深度(千米)         参考位置
1 2019-06-30 21:44:44     3.0   27.56  112.10          6 湖南娄底市双峰县
2 2019-06-30 21:32:29     3.1   28.44  104.81          8 四川宜宾市长宁县
3 2019-06-30 12:14:25     3.0   28.43  104.77          9   四川宜宾市珙县
4 2019-06-30 03:44:11     4.8   22.43  122.31         30   台湾台东县海域
5 2019-06-30 03:09:29     3.1   31.00   98.96          7 四川甘孜州白玉县
6 2019-06-30 03:07:58     3.1   31.02   98.96          8 四川甘孜州白玉县
```

从发震时刻添加两列，年份和月份

```r
worldquake <- transform(worldquake,
  check.names = FALSE,
  `年份` = format(as.Date(`发震时刻`), "%Y"),
  `月份` = format(as.Date(`发震时刻`), "%m")
)
head(worldquake)
```
```
             发震时刻 震级(M) 纬度(°) 经度(°) 深度(千米)         参考位置 年份 月份
1 2019-06-30 21:44:44     3.0   27.56  112.10          6 湖南娄底市双峰县 2019   06
2 2019-06-30 21:32:29     3.1   28.44  104.81          8 四川宜宾市长宁县 2019   06
3 2019-06-30 12:14:25     3.0   28.43  104.77          9   四川宜宾市珙县 2019   06
4 2019-06-30 03:44:11     4.8   22.43  122.31         30   台湾台东县海域 2019   06
5 2019-06-30 03:09:29     3.1   31.00   98.96          7 四川甘孜州白玉县 2019   06
6 2019-06-30 03:07:58     3.1   31.02   98.96          8 四川甘孜州白玉县 2019   06
```

分组统计每年地震次数

```r
table(worldquake$年份)
```
```
2012 2013 2014 2015 2016 2017 2018 2019 
 710 1071  961  943  902  810  910  610 
```

每年地震震级的分布

```r
# 添加中文支持
library(extrafont)
loadfonts()
png(filename = "earthquake-china-ridge-zh.png", width = 10*80, height = 10*80, 
    family = "SimHei", res = 150, type = "cairo")
ggplot(worldquake) +
  ggridges::geom_density_ridges(aes(x = `震级(M)`, y = 年份, fill = 年份)) +
  scale_fill_viridis_d(guide = FALSE) +
  labs(title = "2012年至2019年全球地震震级分布情况")
dev.off()
```

![2012年04月26日至2019年06月30日世界各地地震情况](https://wp-contents.netlify.com/2019/07/earthquake-china-ridge-zh.png)

下面考虑有完整年限的地震数据，即 2013年01月01日至2018年12月31日，并且考虑震级大于等于4.5级的地震，根据地震台网的信息，4.5级以上的地震才会对人和周围环境造成破环

```r
library(magrittr)
subset(worldquake, subset = `震级(M)` >= 4.5 & 年份 >= 2013 & 年份 <= 2018) %>%
  ggplot() +
  ggridges::geom_density_ridges(aes(x = `震级(M)`, y = 年份, fill = 年份)) +
  scale_fill_viridis_d(guide = FALSE) +
  labs(title = "2013年至2018年全球地震4.5级以上震级分布情况")
```

![2013年01月01日至2018年12月31日世界各地地震情况](https://wp-contents.netlify.com/2019/07/earthquake-china-ridge-subset.png)

测量仪器位于中国，地震分布的位置主要集中在中国

```r
par(mar=c(4,4,0.5,0.5))
plot(data = worldquake, `纬度(°)` ~ `经度(°)`)
```

![世界各地地震情况](https://wp-contents.netlify.com/2019/07/earthquake-china.png)

为了美观，我们使用 ggplot2 来画这个图，从这个图中，我们发现距离中国比较远的地方只能测量到较大的地震活动

```r
ggplot(data = worldquake, mapping = aes(x = `经度(°)`, y = `纬度(°)`, color = `震级(M)`)) +
  geom_point(size = .1) +
  scale_color_viridis_c() +
  theme_minimal(base_family = "SimHei", base_size = 8) +
  labs(
    title = "2012年4月26日至2019年7月1日的地震发生的位置分布",
    caption = "数据来源于国家地震台网"
  )
```

![世界各地地震情况](https://wp-contents.netlify.com/2019/07/earthquake.png)

世界各地地震次数分布

```r
ggplot(data = worldquake, mapping = aes(x = `经度(°)`, y = `纬度(°)`)) +
  geom_hex() +
  scale_fill_viridis_c() +
  theme_minimal() +
  labs(caption = "2012年4月26日至2019年7月1日的地震发生的位置分布")
```

![世界各地地震情况](https://wp-contents.netlify.com/2019/07/earthquake-hex.png)

