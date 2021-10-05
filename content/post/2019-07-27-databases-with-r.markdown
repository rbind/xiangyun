---
title: 数据库与 R 语言
date: '2019-07-27'
author: 黄湘云
slug: databases-in-r
categories:
  - 统计软件
tags:
  - R Markdown
  - R 语言
  - ClickHouse
  - SQLite
draft: true
thumbnail: https://clickhouse.com/docs/en/images/column-oriented.gif
description: "目前，大大小小的公司都有数据库系统甚至是集群，做数据分析第一步就是连接上数据，故而，介绍 R 语言环境中如何连接远程数据库及其在 R Markdown 数据分析报告中的使用。数据库涉及常见的 RSQLite 和不常见的 ClickHouse，并且都考虑到生产环境中的实际情况。"
---


# SQLite {#SQLite}

以 memory 方式存储的数据集为例，简单介绍一些基本功能


```r
db <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
DBI::dbWriteTable(db, "mtcars", mtcars, overwrite = TRUE)
subjects <- 6
```

`max.print=10` 控制显示的行数，直接使用 SQL 语句查询，不可以缓存数据


```sql
SELECT * FROM mtcars where gear IN (3, 4) and cyl >= ?subjects
```


<div class="knitsql-table">


Table: Table 1: 表格标题

|  mpg| cyl|  disp|  hp| drat|    wt|  qsec| vs| am| gear| carb|
|----:|---:|-----:|---:|----:|-----:|-----:|--:|--:|----:|----:|
| 21.0|   6| 160.0| 110| 3.90| 2.620| 16.46|  0|  1|    4|    4|
| 21.0|   6| 160.0| 110| 3.90| 2.875| 17.02|  0|  1|    4|    4|
| 21.4|   6| 258.0| 110| 3.08| 3.215| 19.44|  1|  0|    3|    1|
| 18.7|   8| 360.0| 175| 3.15| 3.440| 17.02|  0|  0|    3|    2|
| 18.1|   6| 225.0| 105| 2.76| 3.460| 20.22|  1|  0|    3|    1|
| 14.3|   8| 360.0| 245| 3.21| 3.570| 15.84|  0|  0|    3|    4|
| 19.2|   6| 167.6| 123| 3.92| 3.440| 18.30|  1|  0|    4|    4|
| 17.8|   6| 167.6| 123| 3.92| 3.440| 18.90|  1|  0|    4|    4|
| 16.4|   8| 275.8| 180| 3.07| 4.070| 17.40|  0|  0|    3|    3|
| 17.3|   8| 275.8| 180| 3.07| 3.730| 17.60|  0|  0|    3|    3|

</div>

`output.var="mtcars34"` 将查询的结果保存到变量 `mtcars34`，此时不再输出打印到控制台，此外，还支持 SQL 语句中包含变量 subjects，将查询结果导出到 R 对象，这时可以缓存


```sql
SELECT * FROM mtcars where gear IN (3, 4) and cyl >= ?subjects
```

我们再来查看 `mtcars34` 变量的内容


```r
head(mtcars34)
```

```
##    mpg cyl disp  hp drat    wt  qsec vs am gear carb
## 1 21.0   6  160 110 3.90 2.620 16.46  0  1    4    4
## 2 21.0   6  160 110 3.90 2.875 17.02  0  1    4    4
## 3 21.4   6  258 110 3.08 3.215 19.44  1  0    3    1
## 4 18.7   8  360 175 3.15 3.440 17.02  0  0    3    2
## 5 18.1   6  225 105 2.76 3.460 20.22  1  0    3    1
## 6 14.3   8  360 245 3.21 3.570 15.84  0  0    3    4
```

最后关闭数据库连接的通道


```r
DBI::dbDisconnect(conn = db)
```

# ClickHouse {#ClickHouse}

安装 ClickHouse 要求系统环境： Linux, x86_64 with SSE 4.2.

```bash
sudo apt-get install dirmngr    # optional
# 导入 key
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv E0C56BD4    # optional
# 添加源
echo "deb http://repo.yandex.ru/clickhouse/deb/stable/ main/" | sudo tee /etc/apt/sources.list.d/clickhouse.list
sudo apt-get update
# 安装客户端
sudo apt-get install -y clickhouse-server clickhouse-client
# 启动服务
sudo service clickhouse-server start
# 进入客户端
clickhouse-client
```

[ClickHouse 中文用户手册](https://clickhouse.yandex/docs/zh/) 和 [高鹏](http://jackpgao.github.io/) 在北京 [ClickHouse 社区分享会](https://clickhouse.yandex/blog/en/clickhouse-community-meetup-in-beijing-on-january-27-2018) 上给的报告 [MySQL DBA 解锁数据分析的新姿势-ClickHouse](https://yandex.github.io/clickhouse-presentations/meetup12/power_your_data.pdf) 

开源社区对 ClickHouse 提供了很多语言的支持，比如 R 语言接口有 [RClickhouse](https://github.com/IMSMWU/RClickhouse) 和 [clickhouse-r](https://github.com/hannesmuehleisen/clickhouse-r)，其它接口请看 [官方文档链接](https://clickhouse.yandex/docs/zh/interfaces/third-party/client_libraries/)

由于 clickhouse-r 还在开发中，从未提交到 CRAN，提供的功能也相对有限，这里我们推荐使用 RClickhouse，首先安装 RClickhouse

```r
# 安装 CRAN 版本
install.packages("RClickhouse")
# 安装Github上的开发版
devtools::install_github("IMSMWU/RClickhouse")
```

建立数据库的连接，离不开 `dbConnect` 函数，它提供的 `config_paths` 参数用来指定配置文件 `RClickhouse.yaml` 的路径，在该文件中指定一系列的参数值 `host, port, db, user, password, compression`

```yaml
host: example-db.com
port: 1111
```

如果没有手动配置，会使用默认的参数配置 `host="localhost", port = 9000, db = "default", user = "default", password = "", compression = "lz4"`。现在，我们考虑更加实用的场景，服务器上安装了 Docker，ClickHouse 部署在Docker集群上，下面介绍如何从本机连接上集群。

## 远程连接

首先在某台机器上，拉取 ClickHouse 的 Docker 镜像

```bash
docker pull yandex/clickhouse-server
```

从 Yandex 官网打包的 [Dockerfile](https://hub.docker.com/r/yandex/clickhouse-server/dockerfile) 来看，其默认暴露了 9000、 8123 和 9009 三个端口，所以我在运行 ClickHouse 容器的时候，需要选择其中一个端口映射给主机端口，这里我选择 8282，值得注意的是，我主机的8787端口已经分配给了 RStudio，所以不要再把该主机端口映射给 9000

```bash
docker run --name ck -d -p 8282:9000 -e ROOT=TRUE \
   -e USER=xiangyun -e PASSWORD=cloud yandex/clickhouse-server
```

最后是建立连接，需要远端 Docker 容器内 Clickhouse 的 IP 地址，分配给它的主机端口，用来访问数据库，数据库的用户账户和具体的数据库名称，默认账户和密码以及数据库都是 default，下面展示连接远程 ClickHouse 数据库，连接远程数据库的方式，实现本地数据分析环境和数据库环境分离，分别管理和使用

```r
library(DBI)
library(RClickhouse)
con <- DBI::dbConnect(RClickhouse::clickhouse(),
  host = "192.168.99.100", port = 8282, db = "default",
  user = "default", password = "default", compression = "lz4"
)
```

## 本地连接

下面是连接本地 ClickHouse 数据库，数据库和数据分析环境都在本地，我们使用默认的9000端口和默认default数据库，而默认的账户名在安装 ClickHouse 时指定为 cloud，因此连接参数设置如下 

```r
library(DBI)
library(RClickhouse)
# con <- DBI::dbConnect(RClickhouse::clickhouse(), config_paths = "~/.R/RClickhouse.yaml")
con <- DBI::dbConnect(RClickhouse::clickhouse(),
  host = "localhost", port = 9000, db = "default",
  user = "default", password = "cloud", compression = "lz4"
)
```

RClickHouse 包提供部分 dplyr 式的数据操作，使用比较方便，这里便使用它了，往 ClickHouse 中写入数据

```r
DBI::dbWriteTable(con, "mtcars", mtcars, overwrite=TRUE)
```

查看数据库中的 mtcars 表 

```r
# 列出 ClickHouse 中存放的表
dbListTables(con)
# 列出表 mtcars 中的所有字段
dbListFields(con, "mtcars")
```

RClickHouse 包支持的聚合操作（其实是 dplyr）和 Base R 提供的聚合操作对比，测试一下正确与否

## 数据操作

净土风的操作

```r
library(tidyverse)
# 按变量 cyl 分组对 mpg 求和
tbl(con, "mtcars") %>% 
  group_by(cyl) %>% 
  summarise(smpg=sum(mpg, na.rm = TRUE)) # SQL 总是要移除缺失值
# 等价于
aggregate(mpg ~ cyl, data = mtcars, sum)

# 先筛选出 cyl = 8 并且 vs = 0 的数据，然后按 am 分组，最后对 qsec 求平均值
tbl(con, "mtcars") %>% 
  filter(cyl == 8, vs == 0) %>% 
  group_by(am) %>% 
  summarise(mean(qsec, na.rm = TRUE))
# 等价于
aggregate(qsec ~ am, data = mtcars, mean, subset = cyl == 8 & vs == 0)
```

> aggregate 聚合函数默认对缺失值的处理是忽略， sum 和 mean 函数的参数 `na.rm=TRUE` 实际由聚合函数 aggregate 的参数 `na.action` 传递，它的默认值是 `na.omit` ，就是将缺失值移除后返回。值得注意的是 `na.omit` 是一个缺失值处理的函数，所以如果对缺失值有特殊要求，比如插补，可以自己写函数传递给 `na.action` 参数

你当然可以继续使用 SQL 语句做查询，而不使用 dplyr 提供的现代化的管道操作语法

```r
# 传递 SQL 查询语句
DBI::dbGetQuery(con, 
"SELECT
    vs,
    COUNT(*) AS n_vc,
    AVG(qsec) AS avg_qsec
FROM mtcars
GROUP BY vs")
```

如果数据集比较小，可以将 ClickHouse 的整张表读进内存，但是对于大数据集，只有使用远程服务器才可以获得更好的性能

```r
# 读取数据库中的整张表
copy_mtcars <- dbReadTable(con, "mtcars")
tibble::glimpse(copy_mtcars)
```

还有 RClickhouse 使用 SQL 查询的时候，同样支持 ClickHouse 的内置函数，如 `multiIf`

```r
# 查看 ClickHouse 中所有的数据库名称
DBI::dbGetQuery(con, "SHOW DATABASES")
# 查看所有存储的表
DBI::dbGetQuery(con, "SHOW TABLES")
# 获取 ClickHouse 中 mtcars 表的变量名和类型描述
DBI::dbGetQuery(con, "DESCRIBE TABLE mtcars")
# Compact CASE - WHEN - THEN conditionals
DBI::dbGetQuery(con, "
SELECT multiIf(am=1, 'automatic', 'manual') AS transmission,
       multiIf(vs=1, 'straight', 'V-shaped') AS engine
FROM mtcars
")
```
```r
dbDisconnect(conn = con)
```

# DBI

[ClickHouse](https://clickhouse.yandex/) 独辟蹊径，基于 C++ 的实现，数据查询速度超级快，官网介绍碾压大量传统数据库。还有不少接口，其中还有 R 的 [clickhouse-r](https://github.com/hannesmuehleisen/clickhouse-r)。这是一个存放在 Github 上的包，随着 ClikHouse 在大厂的流行，此包也受到越来越多的关注
与数据仓库如何连接，如何查询数据，背后的接口 DBI 如何使用，实例化一个新的接口，如 clickhouse2r

```r
library(DBI)
con <- dbConnect(clickhouse::clickhouse(),
  host = ifelse(is_on_travis, Sys.getenv("DOCKER_HOST_IP"), "192.168.99.101"),
  port = 8787,
  db = "default",
  user = "default",
  password = "", # 默认账户的默认密码为空
  compression = "lz4"
)
```

安装 clickhouse 包

```r
devtools::install_github("hannesmuehleisen/clickhouse-r")
```

调用接口

```r
library(DBI)
con <- dbConnect(clickhouse::clickhouse(),
  host = "localhost",
  port = 8123L,
  user = "default",
  password = ""
)
dbWriteTable(con, "mtcars", mtcars)
dbListTables(con)
dbGetQuery(con, "SELECT COUNT(*) FROM mtcars")
d <- dbReadTable(con, "mtcars")
dbDisconnect(con)
```

发现它和 knitr 里的 SQL 钩子，都用 [DBI包](https://github.com/rstats-db/DBI)，这个连接方式就是没有任何软件和包依赖，配置也简单，功能也最少，基本只有传递 SQL 的作用。

# JDBC 驱动

学习博文 [利用 JDBC 驱动连接 R 和 Hive](https://www.bjt.name/2016/11/19/jdbc-hive-r.html) 和 [clickhouse-jdbc](https://github.com/yandex/clickhouse-jdbc) 试试 [RJDBC](https://github.com/s-u/RJDBC) 包远程连接 ClickHouse 仓库。

RJDBC 的强大之处就是只要数据库管理系统提供 JDBC 驱动就可以用它来连接。事实上，主流的数据库系统都同时支持 JDBC 和 ODBC 两种驱动方式。目前，ClickHouse 官方没有提供 ODBC 的 deb 包，需要从源码编译，这个有点坑，要自己从源码编译配置，另外，JDBC 驱动需要 Java 环境，而且效率应该没有 ODBC 高

# 运行环境 {#sessioninfo}


```r
xfun::session_info(c(
  "rmarkdown", "RSQLite", "odbc"
))
```

```
## R version 4.1.1 (2021-08-10)
## Platform: x86_64-apple-darwin17.0 (64-bit)
## Running under: macOS Big Sur 10.16
## 
## Locale: en_US.UTF-8 / en_US.UTF-8 / en_US.UTF-8 / C / en_US.UTF-8 / en_US.UTF-8
## 
## Package version:
##   base64enc_0.1.3 bit_4.0.4       bit64_4.0.5     blob_1.2.2     
##   cachem_1.0.6    DBI_1.1.1       digest_0.6.28   ellipsis_0.3.2 
##   evaluate_0.14   fastmap_1.1.0   glue_1.4.2      graphics_4.1.1 
##   grDevices_4.1.1 highr_0.9       hms_1.1.1       htmltools_0.5.2
##   jquerylib_0.1.4 jsonlite_1.7.2  knitr_1.36      lifecycle_1.0.1
##   magrittr_2.0.1  memoise_2.0.0   methods_4.1.1   odbc_1.3.2     
##   pkgconfig_2.0.3 plogr_0.2.0     Rcpp_1.0.7      rlang_0.4.11   
##   rmarkdown_2.11  RSQLite_2.2.8   stats_4.1.1     stringi_1.7.4  
##   stringr_1.4.0   tinytex_0.34    tools_4.1.1     utils_4.1.1    
##   vctrs_0.3.8     xfun_0.26       yaml_2.2.1     
## 
## Pandoc version: 2.14.2
```

Dockerfile 打包的环境见 <https://github.com/xiangyunhuang/db-in-rmd>，编译生成 HTML 文档的命令见 <https://xiangyunhuang.github.io/db-in-rmd/db-in-rmd.html>
