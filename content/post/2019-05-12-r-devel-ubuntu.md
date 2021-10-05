---
title: 从源码安装最新的开发版R
author: 黄湘云
date: '2019-05-12'
slug: r-devel-ubuntu
categories:
  - 统计软件
tags:
  - R
  - RStudio Server
  - Ubuntu
thumbnail: https://cloud.r-project.org/Rlogo.svg
---

# 1. R

> 本文介绍在 Ubuntu Server 16.04.X/18.04.X 服务器系统上从源码安装最新的 R 软件[^ubuntu-r-installation]，前提是服务器能联网，此安装指导大部分也同样适用于 CentOS 和 Fedora。

不知什么原因，自从 Ubuntu 16.04 开始，开机要启动 XX 在线服务，浪费2-3分钟时间， [经查](https://askubuntu.com/questions/972215/a-start-job-is-running-for-wait-for-network-to-be-configured-ubuntu-server-17-1)，为解决开机启动慢，需要

```bash
sudo systemctl disable systemd-networkd-wait-online.service
sudo systemctl mask systemd-networkd-wait-online.service
```

在 Ubuntu 16.04 上，我们推荐需要安装最新的 Git 和 libgit2-dev 库，所以添加两个源

```bash
sudo add-apt-repository -y ppa:jeroen/libgit2
sudo add-apt-repository -y ppa:git-core/ppa
```

装完之后想移除源，也很简单

```bash
sudo add-apt-repository --remove ppa:jeroen/libgit2
```

下面为编译 R 源码准备，由于系统包管理器中自带的 R 版本比较低，需要添加官方放出的源，根据官网的指示，必须导入 GnuPG 密钥才能启用和更新源

```bash
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv E084DAB9
sudo apt-add-repository -y "deb https://mirrors.tuna.tsinghua.edu.cn/CRAN/bin/linux/ubuntu bionic-cran35/"
```

从源码安装 R 需要很多的系统依赖，所以需要启用 Ubuntu 源码仓，默认是不启用的

```bash
sudo sed -i -- 's/#deb-src/deb-src/g' /etc/apt/sources.list && sudo sed -i -- 's/# deb-src/deb-src/g' /etc/apt/sources.list
```

接下来，将 r-base-dev 所需的依赖全部装上，有了 `build-dep` 就不用一个一个去找了

```bash
# Ubuntu
sudo apt-get update && sudo apt-get build-dep r-base-dev
# Fedora 
sudo dnf update && sudo dnf builddep R-devel
# CentOS
sudo yum update && sudo yum install -y yum-utils && sudo yum-builddep R-devel
```

我们还推荐安装一些其它的系统依赖，供常用的 R 包安装使用，常用的 R 包有 xml2、ssl、git2r、curl、openssl、magick、nloptr、igraph、RcppGSL。另外为了下载R软件的源码，我们还需要安装 subversion，因为目前 R 的开发放在 SVN 上，这和 Python 不同，后者早就托管到 Github 上了。 最后两个依赖是和 LaTeX 相关的，我主要是为了编译 PDF 版的电子书，所以依赖它们，如果你不需要，可以不安装。 [ghostscript](https://www.ghostscript.com/)、 [imagemagick](https://imagemagick.org/index.php)、 [optipng](http://optipng.sourceforge.net/) 分别是处理字体，转化图片格式和优化图片的三把利剑。至于 jags 完全是个人需求，做贝叶斯推断的客官肯定已经听说过它的大名，即 Just Another Gibbs Sampler，简称 [JAGS](http://mcmc-jags.sourceforge.net/)，以后我们还会继续介绍

```bash
sudo apt-get install -y libxml2-dev libssl-dev libgit2-dev \
  libnlopt-dev libxmu-dev libglpk-dev libgsl-dev \
  ghostscript imagemagick optipng subversion jags \
  libcurl4-openssl-dev libmagick++-dev \
  texlive-xetex texlive-lang-chinese
```

在编译之前，先准备一些环境变量，方便切换目录

```bash
echo "export RTOP=~/svn/R" | tee -a ~/.bashrc
echo "export REPOS=https://svn.r-project.org/R" | tee -a ~/.bashrc
source ~/.bashrc
```

终于可以下载 R 源码的开发分支了！

```bash
echo $RTOP && mkdir -p $RTOP && cd $RTOP
svn co $REPOS/trunk r-devel/source
```

第一次下次，如果网速不好，中间可能会断掉，如果 svn 同步失败，需要先清理再同步，不要担心之前下载的源码丢失，这是断点续传的

```bash
svn cleanup r-devel/source
svn co $REPOS/trunk r-devel/source
```

因为使用的是开发版，它的源码几乎每天都在更新。通常有重大功能更新和错误修正的时候，我们建议更新一下源码，重新编译安装。此时更新源码非常简单，只需

```bash
cd $RTOP && svn up r-devel/source
```

更新过程如

```
正在升级 'r-devel/source':
U    r-devel/source/doc/NEWS.Rd
U    r-devel/source/src/library/stats/R/approx.R
U    r-devel/source/src/library/tools/R/utils.R
U    r-devel/source/src/library/stats/R/aov.R
U    r-devel/source/src/library/stats/R/family.R
U    r-devel/source/src/library/base/R/source.R
U    r-devel/source/src/library/utils/R/RSiteSearch.R
U    r-devel/source/src/library/grDevices/R/device.R
U    r-devel/source/src/library/stats/R/models.R
U    r-devel/source/src/library/stats/man/approxfun.Rd
U    r-devel/source/src/library/methods/R/RMethodUtils.R
U    r-devel/source/tests/Examples/stats-Ex.Rout.save
U    r-devel/source/src/library/stats/man/ecdf.Rd
U    r-devel/source/src/library/tcltk/R/Tk.R
U    r-devel/source/src/library/utils/R/help.start.R
U    r-devel/source/src/library/utils/R/glob2rx.R
U    r-devel/source/src/library/utils/R/packages2.R
U    r-devel/source/src/library/utils/R/news.R
U    r-devel/source/src/library/utils/R/sysdata.R
U    r-devel/source/src/library/stats/src/approx.c
U    r-devel/source/src/library/parallel/src/fork.c
U    r-devel/source/src/library/stats/src/init.c
U    r-devel/source/src/library/utils/R/sessionInfo.R
U    r-devel/source/src/library/stats/src/statsR.h
U    r-devel/source/src/library/utils/R/zip.R
U    r-devel/source/src/library/tools/R/install.R
U    r-devel/source/configure
U    r-devel/source/configure.ac
U    r-devel/source/src/library/tools/R/CRANtools.R
U    r-devel/source/src/library/tools/R/QC.R
U    r-devel/source/src/library/tools/R/Rd.R
U    r-devel/source/src/library/tools/R/Rd2HTML.R
U    r-devel/source/src/library/tools/R/Rd2latex.R
U    r-devel/source/src/library/tools/R/Rd2pdf.R
U    r-devel/source/src/library/tools/R/Rd2txt.R
U    r-devel/source/src/library/tools/R/RdConv2.R
U    r-devel/source/src/library/tools/R/RdHelpers.R
U    r-devel/source/src/library/tools/R/admin.R
U    r-devel/source/src/library/tools/R/check.R
U    r-devel/source/src/library/tools/R/dynamicHelp.R
U    r-devel/source/src/library/tools/R/news.R
U    r-devel/source/src/library/tools/R/urltools.R
U    r-devel/source/src/library/base/R/library.R
U    r-devel/source/src/library/base/R/utils.R
U    r-devel/source/src/library/methods/R/MethodsList.R
U    r-devel/source/src/library/methods/R/promptClass.R
U    r-devel/source/src/library/utils/R/citation.R
U    r-devel/source/src/library/utils/R/mirrorAdmin.R
U    r-devel/source/src/library/utils/R/prompt.R
U    r-devel/source/src/library/utils/R/write.table.R
U    r-devel/source/tests/reg-tests-1d.R
更新到版本 76484。
```

现在源码已经就绪了，除了下载R的核心源码外，R Core Team 推荐级别的 R 包也是值得安装的，因为它们被大量的第三方R包所依赖。这些源码包也是由核心开发团队所维护的，源码包和 R 源码放在同一个仓库里，是单独打包，可以直接下载

```bash
cd $RTOP/r-devel/source/tools && ./rsync-recommended
```

终于到了编译安装 R 开发版的时候了！客官，莫急！还有开始前的最后一步，**配置** 编译选项。先创建并切到独立于源码的build目录，防止污染本地源码目录，方便下次更新源码和重新编译

```bash
mkdir $RTOP/r-devel/build && cd $RTOP/r-devel/build
../source/configure --enable-R-shlib --enable-memory-profiling
```

配置成功的标志是没有警告和错误，并且需要的功能也都启用了

```
R is now configured for x86_64-pc-linux-gnu

  Source directory:            ../source
  Installation directory:      /usr/local

  C compiler:                  gcc  -g -O2
  Fortran fixed-form compiler: gfortran -fno-optimize-sibling-calls -g -O2

  Default C++ compiler:        g++ -std=gnu++11  -g -O2
  C++98 compiler:              g++ -std=gnu++98  -g -O2
  C++11 compiler:              g++ -std=gnu++11  -g -O2
  C++14 compiler:              g++ -std=gnu++14  -g -O2
  C++17 compiler:              g++ -std=gnu++17  -g -O2
  Fortran free-form compiler:  gfortran -fno-optimize-sibling-calls -g -O2
  Obj-C compiler:              gcc -g -O2 -fobjc-exceptions

  Interfaces supported:        X11, tcltk
  External libraries:          readline, curl
  Additional capabilities:     PNG, JPEG, TIFF, NLS, cairo, ICU
  Options enabled:             shared R library, shared BLAS, R profiling, memory profiling

  Capabilities skipped:
  Options not enabled:

  Recommended packages:        yes
```

配置后，开始编译源码，编译生成的就是可执行文件

```bash
make
```

编译成功最后一般会显示

```
configuring Java ...
Java interpreter : /usr/bin/java
Java version     : 1.8.0_212
Java home path   : /usr/lib/jvm/java-1.8.0-openjdk-1.8.0.212.b04-0.fc30.x86_64/jre
Java compiler    : /usr/bin/javac
Java headers gen.: /usr/bin/javah
Java archive tool: /usr/bin/jar

trying to compile and link a JNI program
detected JNI cpp flags    : -I$(JAVA_HOME)/../include -I$(JAVA_HOME)/../include/linux
detected JNI linker flags : -L$(JAVA_HOME)/lib/amd64/server -ljvm
make[2]: 进入目录“/tmp/Rjavareconf.pQpjMV”
gcc -I"/home/xiangyun/svn/R/r-devel/build/include" -DNDEBUG -I/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.212.b04-0.fc30.x86_64/jre/../include -I/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.212.b04-0.fc30.x86_64/jre/../include/linux  -I/usr/local/include  -fpic  -g -O2  -c conftest.c -o conftest.o
gcc -shared -L/home/xiangyun/svn/R/r-devel/build/lib -L/usr/local/lib64 -o conftest.so conftest.o -L/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.212.b04-0.fc30.x86_64/jre/lib/amd64/server -ljvm -L/home/xiangyun/svn/R/r-devel/build/lib -lR
make[2]: 离开目录“/tmp/Rjavareconf.pQpjMV”

JAVA_HOME        : /usr/lib/jvm/java-1.8.0-openjdk-1.8.0.212.b04-0.fc30.x86_64/jre
Java library path: $(JAVA_HOME)/lib/amd64/server
JNI cpp flags    : -I$(JAVA_HOME)/../include -I$(JAVA_HOME)/../include/linux
JNI linker flags : -L$(JAVA_HOME)/lib/amd64/server -ljvm
Updating Java configuration in /home/xiangyun/svn/R/r-devel/build
Done.

make[1]: 离开目录“/home/xiangyun/svn/R/r-devel/build”
```

现在进入 R 只需

```bash
./bin/R
```

然后，你会看到

```
R Under development (unstable) (2019-05-10 r76484) -- "Unsuffered Consequences"
Copyright (C) 2019 The R Foundation for Statistical Computing
Platform: x86_64-pc-linux-gnu (64-bit)

R是自由软件，不带任何担保。
在某些条件下你可以将其自由散布。
用'license()'或'licence()'来看散布的详细条件。

R是个合作计划，有许多人为之做出了贡献.
用'contributors()'来看合作者的详细情况
用'citation()'会告诉你如何在出版物中正确地引用R或R程序包。

用'demo()'来看一些示范程序，用'help()'来阅读在线帮助文件，或
用'help.start()'通过HTML浏览器来看帮助文件。
用'q()'退出R.
```

检查、安装和制作手册是可选的

```bash
make check && make pdf && make info
```

为了能够比较方便地在终端中唤醒 R，而不是每次都先切到 build 目录，`cd $RTOP/r-devel/build`，我们建立快捷方式

```bash
cd /usr/local/bin
sudo ln -s $RTOP/r-devel/build/bin/R R-devel
sudo ln -s $RTOP/r-devel/build/bin/Rscript Rscript-devel
```

这样，在终端中键入 `R-devel` 后回车，即可进入 R 环境，为了不和稳定发布的R版本冲突，我们用 R-devel 表示开发版的 R，方便系统以后安装多个R版本进行测试开发。为了后续可以比较快速地下载 R 包，我们继续设置就近的 CRAN 镜像站点，如国内的清华加速站点

```bash
echo "options(repos = c(CRAN = 'https://mirrors.tuna.tsinghua.edu.cn/CRAN/'))" | tee -a $RTOP/r-devel/build/etc/Rprofile.site
chmod a+r $RTOP/r-devel/build/etc/Rprofile.site
```

最后我们配置编译器选项，如 GCC/G++，这个是可选的，只有当你安装与 RcppEigen 和 rstan 相关的 R 包的时候，需要配置 `CXXFLAGS`、`CXX14` 和 `CXX14FLAGS`，比如 `G++-7`。有时，为了安装某些R包，如 Rmpi 还会要求配置开发库 openmpi-dev 的路径，这里就不一一细说了。

```bash
mkdir -p ~/.R/
# RcppEigen
echo "CXXFLAGS += -Wno-ignored-attributes" >> ~/.R/Makevars
# rstanarm
echo "CXX14 = g++-7" >> ~/.R/Makevars
echo "CXX14FLAGS = -fPIC -flto=2 -mtune=native -march=native" >> ~/.R/Makevars
echo "CXX14FLAGS += -Wno-unused-variable -Wno-unused-function -Wno-unused-local-typedefs" >> ~/.R/Makevars  
echo "CXX14FLAGS += -Wno-ignored-attributes -Wno-deprecated-declarations -Wno-attributes -O3" >> ~/.R/Makevars
```

# 2. RStudio

> 在 Fedora Server 上安装 RStudio Server 会比较费劲，因为 RStudio 官网不提供 RPM 安装包，也需要从源码编译安装，所以之后会单独开贴讲述，见 [在 Fedora Server 上从源码安装 RStudio Server](https://www.xiangyunhuang.com.cn/2019/05/rstudio-server-fedora/)

下载安装 RStudio Server，截至写作时间 RStudio Server 最新的稳定版是 **1.2.1335**，这里先安装 gdebi-core 是为了自动解决安装包的系统依赖问题，因为这里的安装包是系统包管理器外的第三方 deb 包

```bash
sudo apt-get install -y gdebi-core
wget https://download2.rstudio.org/server/bionic/amd64/rstudio-server-1.2.1335-amd64.deb
sudo gdebi rstudio-server-1.2.1335-amd64.deb
```

有时我们也需要从终端中用 bookdown 编译书籍，bookdown 除了依赖 rmarkdown 和 knitr 包，在转化为 HTML 和 LaTeX 等格式文档的时候，还需要 Pandoc，而 RStudio 本身自带一份，所以只需要添加其路径到环境变量 PATH 中即可，当然也可从 Pandoc 官方仓库中下载最新版本 <https://github.com/jgm/pandoc/releases/latest>

```bash
# 将 Pandoc 路径添加到系统环境变量中
echo "PATH=/usr/lib/rstudio-server/bin/pandoc:$PATH; export PATH" | tee -a ~/.bashrc
source ~/.bashrc
```

为了能够从浏览器登陆R开发环境，需要打开指定端口 8181 给 RStudio Server 访问[^ip-port]，并且把 R 的安装路径告诉给 RStudio Server， 让其启动的时候能够找到 R 软件环境

```bash
# 给 RStudio 分配访问端口
echo "www-port=8181" | sudo tee -a  /etc/rstudio/rserver.conf
# 将 R 软件路径告诉 RStudio Server
echo "rsession-which-r=/usr/local/bin/R-devel" | sudo tee -a /etc/rstudio/rserver.conf
```

分配端口号给 RStudio Server，就是让主机能够通过该端口号访问虚拟机中的 RStudio Server 服务，那么防火墙不要拦截该端口

```bash
# 安装 firewalld 防火墙管理工具
sudo apt-get install -y firewalld
# 打开8181端口
sudo firewall-cmd --zone=public --add-port=8181/tcp --permanent
# 重启防火墙使配置生效
sudo firewall-cmd --reload
```

最后重启 RStudio Server 服务，即可从浏览器中登陆

```bash
sudo rstudio-server restart
```

![login-rstudio-server](https://wp-contents.netlify.com/2019/05/login-rstudio-server.png)

---

在 MacOS 上配置 R 环境 <https://github.com/jacobxk/setup_macOS_for_R>

[^ubuntu-r-installation]: https://cran.r-project.org/bin/linux/ubuntu/README.html
[^ip-port]: https://docs.rstudio.com/ide/server-pro/access-and-security.html#network-port-and-address
