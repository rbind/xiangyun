---
title: 在 Fedora Server 上从源码安装 RStudio Server
author: 黄湘云
date: '2019-05-22'
slug: rstudio-server-fedora
categories:
  - 统计软件
tags:
  - RStudio Server
  - Fedora
  - R
thumbnail: /img/rstudio.svg
description: "仅以此篇献给爱折腾的人。RStudio Server 不提供 Fedora Server 上的服务器版 rpm 包，遂从源码编译安装，折腾平台是 Fedora Server 30 虚拟机 VBox，这个过程同样适用于 Docker 因为我是从 Minimal 的 Fedora Server 30 开始的"
---


> 假定你已经安装好了 VirtualBox，并且在虚拟机中已经安装好了 Fedora Server，具备联网的条件。既然想尝试新的软件开发环境 Fedora Server，我假定你安装目前最新的 Fedora Server 30，本文以此为基础介绍。如何在虚拟机中联网安装 Fedora Server 以后介绍。

# 1. 系统依赖

在虚拟机 VirtualBox 中已经安装好了 Fedora Server 服务器版本，R 软件可以是从源码仓库中自己编译安装的，也可以从系统包管理器中安装，简单起见，我们从包管理器中安装，若想从源码安装可参考 [从源码安装最新的开发版 R](https://www.xiangyunhuang.com.cn/2019/05/r-devel-ubuntu/)

安装 R 和常用R包的系统依赖

```bash
sudo yum install -y R git R-littler R-littler-examples \
   libcurl-devel openssl-devel libssh2-devel \
   libgit2-devel libxml2-devel cairo-devel \
   NLopt-devel igraph-devel glpk-devel gmp-devel
```

其中，`R-littler` 和 `R-littler-examples` 是 Dirk Eddelbuettel 为 R 开发的命令行前端，方便从命令行中安装 R 包，只要建立快捷方式

```bash
sudo ln -s /usr/lib64/R/library/littler/examples/install.r /usr/bin/install.r 
sudo ln -s /usr/lib64/R/library/littler/examples/install2.r /usr/bin/install2.r
sudo ln -s /usr/lib64/R/library/littler/examples/installGithub.r /usr/bin/installGithub.r 
sudo ln -s /usr/lib64/R/library/littler/examples/testInstalled.r /usr/bin/testInstalled.r
```

为加快下载R包的速度，设置默认 CRAN 镜像站点，建议选择一个离自己最近的站点，参考 R 官网 <https://cran.r-project.org/> 左侧 Mirrors 栏镜像站点的完整列表

```bash
echo "options(repos = c(CRAN = 'https://mirrors.tuna.tsinghua.edu.cn/CRAN/'))" | sudo tee -a /usr/lib64/R/etc/Rprofile.site
sudo chmod a+r /usr/lib64/R/etc/Rprofile.site
```

创建 R 包存放目录，与 R 默认的目录 `/usr/lib64/R/library` 分离开来，用于存放第三方的 R 包

```bash
sudo mkdir -p /usr/local/lib/R/site-library
```

给当前用户在目录 `/usr/local/lib/R/site-library/` 上添加写权限

```bash
sudo chown -R root:$(whoami) /usr/local/lib/R/site-library
sudo chmod -R g+w /usr/local/lib/R/site-library
```

最后，来小试一把，在命令行中安装 R 包

```bash
install.r docopt
```

应该可以看到

```
试开URL’https://mirrors.tuna.tsinghua.edu.cn/CRAN/src/contrib/docopt_0.6.1.tar.gz'
Content type 'application/x-gzip' length 28467 bytes (27 KB)
==================================================
downloaded 27 KB

* installing *source* package ‘docopt’ ...
** 成功将‘docopt’程序包解包并MD5和检查
** R
** inst
** byte-compile and prepare package for lazy loading
** help
*** installing help indices
  converting help for package ‘docopt’
    finding HTML links ... 好了
    as.character-Pattern-method             html
    as.character-Tokens-method              html
    docopt-package                          html
    docopt                                  html
    sub-Tokens-method                       html
    subset-Tokens-method                    html
** building package indices
** testing if installed package can be loaded
* DONE (docopt)
```

# 2. 编译安装

现在可以克隆 RStudio 开发仓库

```bash
git clone --depth=1 --branch=master https://github.com/rstudio/rstudio.git
```

切换到 `rstudio/` 目录下

```bash
cd rstudio 
```

可以看到安装编译 RStudio Server 所需的依赖

```bash
cat ./dependencies/linux/install-dependencies-yum
```

之前安装 R 和常用依赖时已经安装了不少依赖，只需额外安装

```bash
sudo yum install -y wget \
  cmake rpmdevtools pam-devel \
  boost-devel pango-devel \
  ant xml-commons-apis \
  initscripts
```

其余的通过在线下载，尽量保证一个比较好的网络环境，避免下载失败

```bash
cat ./dependencies/common/install-common
```

创建 `build/` 目录供配置和编译 RStudio Server，也是为了和 RStudio Server 的源码目录分离，不要互相干扰，方便随时升级到最新的开发版 RStudio Server

```bash
mkdir build && cd build
```

创建配置文件，目标是 RStudio Server 服务器版本，而不是桌面版

```bash
cmake .. -DRSTUDIO_TARGET=Server -DCMAKE_BUILD_TYPE=Release
```

配置结果

```
-- The C compiler identification is GNU 9.1.1
-- The CXX compiler identification is GNU 9.1.1
-- Check for working C compiler: /usr/bin/cc
-- Check for working C compiler: /usr/bin/cc -- works
-- Detecting C compiler ABI info
-- Detecting C compiler ABI info - done
-- Detecting C compile features
-- Detecting C compile features - done
-- Check for working CXX compiler: /usr/bin/c++
-- Check for working CXX compiler: /usr/bin/c++ -- works
-- Detecting CXX compiler ABI info
-- Detecting CXX compiler ABI info - done
-- Detecting CXX compile features
-- Detecting CXX compile features - done
-- Performing Test COMPILER_SUPPORTS_CXX11
-- Performing Test COMPILER_SUPPORTS_CXX11 - Success
-- Boost version: 1.69.0
-- Using RStudio-provided Boost 1.69.0
-- Using Boost.Signals version 2
-- No Crashpad libraries found under /opt/rstudio-tools/crashpad/crashpad/out/Default/obj. Crashpad integration disabled.
-- Performing Test HAVE_SCANDIR_POSIX
-- Performing Test HAVE_SCANDIR_POSIX - Success
-- Looking for SA_NOCLDWAIT
-- Looking for SA_NOCLDWAIT - found
-- Looking for SO_PEERCRED
-- Looking for SO_PEERCRED - found
-- Looking for inotify_init1
-- Looking for inotify_init1 - found
-- Looking for getpeereid
-- Looking for getpeereid - not found
-- Looking for setresuid
-- Looking for setresuid - found
-- Performing Test PAM_MESSAGE_CONST
-- Performing Test PAM_MESSAGE_CONST - Success
-- Found PAM: /usr/lib64/libpam.so;/usr/lib64/libdl.so
-- Configured to build SERVER
-- Found LibR: /usr/lib64/R
-- Found R: /usr/lib64/R
-- Configuring done
-- Generating done
-- Build files have been written to: /home/xiangyun/rstudio/build
```

编译和安装所需时间比较长，需耐心等待大约1个小时

```bash
sudo make install
```

![build-rstudio-server](https://wp-contents.netlify.com/2018/12/build-rstudio-server.png)

添加建立系统账号 rstduio-server 

```bash
sudo useradd -r rstudio-server
```

RStudio Server 使用 PAM 给用户登陆授权

```bash
sudo cp /usr/local/lib/rstudio-server/extras/pam/rstudio /etc/pam.d/rstudio
```

设置开机启动，使用 init.d 注册 RStudio Server 服务为守护进程，将可执行文件 `rstudio-server` 、`rstudio-server.redhat.service` 和 `rstudio-server.service` 拷贝到目录 `/etc/init.d/` 下

```bash
sudo cp /usr/local/lib/rstudio-server/extras/init.d/redhat/rstudio-server \
  /usr/local/lib/rstudio-server/extras/systemd/rstudio-server.redhat.service \
  /usr/local/lib/rstudio-server/extras/systemd/rstudio-server.service /etc/init.d/
```

给这两个服务添加可执行的权限

```bash
sudo chmod +x /etc/init.d/rstudio-server.redhat.service \
  /etc/init.d/rstudio-server.service
```

将服务注册为合适的运行级别

```bash
sudo /sbin/chkconfig --add rstudio-server
```

给 rstudio-server 建立快捷方式

```bash
sudo ln -f -s /usr/local/lib/rstudio-server/bin/rstudio-server /usr/sbin/rstudio-server
```

启动 rstudio-server 服务，此时还不能从浏览器登陆 RStudio Server，需要防火墙分配访问端口

```bash
sudo rstudio-server start
```

创建RStudio Server 运行的日志文件存放目录（可选）

```bash
sudo mkdir -p /var/run/rstudio-server \
  /var/lock/rstudio-server \
  /var/log/rstudio-server \
  /var/lib/rstudio-server
```

接下来需要分配端口号和获取虚拟机的IP地址：默认情况下 RStudio Server 占用8787端口，可以通过防火墙开辟 8787端口给 rstudio-server ， `ip addr` 可以查询虚拟机 ip 地址，然后在浏览器中访问 `http://<ip>:8787`，再输入登陆虚拟机的用户名和密码登陆。其实也可以设置自定义的端口号[^ip-port]

```bash
sudo firewall-cmd --zone=public --add-port=8787/tcp --permanent
```

重启防火墙使得端口配置生效

```bash
sudo firewall-cmd --reload # 或者 sudo systemctl restart firewalld
```

在浏览器中登陆 RStudio Server，需要使用登陆虚拟机所需的用户名和密码，不支持 root 账户登陆

![login-rstudio-server](https://wp-contents.netlify.com/2018/12/login-rstudio-server.png)

登陆进去后，我们可以看到如下画面

![load-rstudio-server](https://wp-contents.netlify.com/2018/12/load-rstudio-server.png)

查看 RStudio Server 版本，最新开发版的版本号总是 99.9.9

![rstudio-server-fedora](https://wp-contents.netlify.com/2018/12/rstudio-server-fedora.png)

最后将 Pandoc 工具添加到系统路径，它包含在 RStudio Server 中，只需修改配置文件 `.bashrc` 

```bash
echo "PATH=/usr/local/lib/rstudio-server/bin/pandoc:$PATH; export PATH" | tee -a ~/.bashrc
```

重新加载 `.bashrc` 使得修改生效

```bash
source ~/.bashrc
```

截至写作时间，RStudio Server 捆绑的 Pandoc 版本是 2.3.1，

```bash
pandoc -v
```
```
pandoc 2.3.1
Compiled with pandoc-types 1.17.5.1, texmath 0.11.1, skylighting 0.7.2
Default user data directory: /home/xiangyun/.pandoc
Copyright (C) 2006-2018 John MacFarlane
Web:  http://pandoc.org
This is free software; see the source for copying conditions.
There is no warranty, not even for merchantability or fitness
for a particular purpose.
```

对于有些开发环境而言，可能版本落后，我们可以从 [Pandoc 官网](https://github.com/jgm/pandoc/releases/latest) 下载最新的文件替换，比如目前最新的版本是 `pandoc-2.9.2-linux.tar.gz`，下载之后将其解压替换 RStudio Server 自带的版本 。

> Pandoc 是一个万能文档转化器，以后有时间会继续介绍

# 3. 其它设置

## 3.1 安装 fish

```bash
# 提供 chsh 命令
sudo yum install -y util-linux-user 
# 安装 fish
sudo yum install -y fish
# 安装 oh-my-fish
curl -L https://get.oh-my.fish | fish
# 安装使用 robbyrussell 主题
omf install robbyrussell
# 设置 fish 为默认 shell
chsh -s /usr/bin/fish
```

## 3.2 安装软件

```bash
sudo dnf install -y \
  calibre inkscape optipng ImageMagick ghostscript texinfo \
  texlive-pdfcrop texlive-dvisvgm texlive-dvips \
  texlive-dvipng texlive-ctex texlive-fandol texlive-xetex \
  texlive-framed texlive-titling \
  tex-preview epstool texlive-alegreya texlive-sourcecodepro
```

## 3.3 删除内核

```bash
# 查看已安装的内核
rpm -qa | grep kernel
# 删除旧内核
sudo yum remove kernel-3.10.0-693.el7.x86_64
```

## 3.4 CentOS 平台上的软件

---

配置网络

```bash
sudo vi /etc/sysconfig/network-scripts/ifcfg-enp0s3
sudo vi /etc/sysconfig/network-scripts/ifcfg-enp0s8
```

自动获取IP，只需将 ONBOOT=no 改为 ONBOOT=yes，然后重启网络

```bash
sudo service network restart
```

然后更新 yum  

```bash
sudo yum update 
sudo yum groupinstall "Development Tools" 
```

---

安装 Git

```bash
sudo sh -c "$(curl -fsSL https://setup.ius.io/)"
sudo yum update && sudo yum install git2u
```

---

从这里安装 texlive https://github.com/FluidityProject/yum-centos7-texlive

```bash
sudo curl -fLo /etc/yum.repos.d/texlive.repo https://raw.githubusercontent.com/FluidityProject/yum-centos7-texlive/master/texlive-centos7.repo
```

安装中文宏包支持中文项目 https://github.com/XiangyunHuang/Graphics

```bash
sudo yum install -y levien-inconsolata-fonts texlive-inconsolata \
  texlive-fandol texlive-ctex texlive-xetex texlive-xetex-def \
  texlive-savesym texlive-xecjk texlive-euenc texlive-xltxtra \
  texlive-framed texlive-titling texlive-tocbibind texlive-mathspec
```

---

安装 GCC-7

```bash
sudo yum install centos-release-scl-rh
sudo yum install -y devtoolset-7-gcc devtoolset-7-gcc-c++
# 启用 GCC-7 
source /opt/rh/devtoolset-7/enable
```

---

安装 JAGS

```bash
sudo curl -fLo /etc/yum.repos.d/jags.repo http://download.opensuse.org/repositories/home:/cornell_vrdc/CentOS_7/home:cornell_vrdc.repo
sudo yum install jags4 jags4-devel
```

---

安装 quadprog

下载文件，下载至当前目录，文件名为 `quadprog_1.5-5.tar.gz`

```bash
curl -C - -O https://cran.r-project.org/src/contrib/quadprog_1.5-5.tar.gz
```

检查

```bash
R CMD check quadprog_1.5-5.tar.gz
```

安装 `gcc-gfortran` 建立软链接

```bash
sudo yum install gcc-gfortran
sudo ln -s /usr/lib/gcc/x86_64-redhat-linux/4.8.5/libgfortran.so /usr/lib64/gfortran/modules
sudo ln -s /usr/lib/gcc/x86_64-redhat-linux/4.8.5/libquadmath.so /usr/lib64/gfortran/modules
```

安装

```r
install.packages('quadprog')
```

## 3.5 工具箱列表

Linux 平台常用的工具

```{r,eval=FALSE}
# 加载 R 包 函数 stri_extract_all 抽取邮件地址
library(stringi)
# "openssl", "lua", "fontconfig", "bash", "zsh", "unzip", "sqlite"
# 工具集
softwares <- c(
  "sed", "gawk", "grep", "perl", "gnupg2", "vim", "zip",
  "curl", "make", "firewalld", "ghostscript", "imagemagick"
)
# 获取各软件描述信息
info <- lapply(paste("apt-cache show", softwares), system, intern = TRUE)
# 获取维护者字段
Original_Maintainer <- gsub("Original-Maintainer: ", "", sapply(info, function(slots) grep("^(Original-Maintainer)", slots, value = T)[1]), perl = TRUE)
# 抽取邮件地址
Email_Maintainer <- unlist(stri_extract_all(Original_Maintainer, regex = '<([^<>]*)>'))
# unname(Email_Maintainer)
tidy_maintainer <- function(x) {
		x <- gsub('\\[.*?\\]|\\(.*?\\)','',x)
		x <- gsub('<([^<>]*)>','',x)
		x <- gsub('\\\n','',x)
		x <- gsub("(\\\t)|(\\\')|(\\\')|(')",'',x)
		x <- gsub(' +$', '', x)  # 去掉末尾空格
		x <- gsub('  ','',x)  # 两空格转一个空格
}
# 去掉邮件地址
Original_Maintainer <- sapply(Original_Maintainer, tidy_maintainer)
# 创建 markdown 表格
knitr::kable(
  data.frame(
    Package = gsub("Package: ", "", sapply(info, function(slots) grep("^(Package)", slots, value = T)[1]), perl = TRUE),
    Homepage = gsub("Homepage: ", "", sapply(info, function(slots) grep("^(Homepage)", slots, value = T)[1]), perl = TRUE),
    Version = gsub("Version: ", "", sapply(info, function(slots) grep("^(Version)", slots, value = T)[1]), perl = TRUE)
  )
)
```

|Package     |Homepage                          |Version                      |
|:-----------|:---------------------------------|:----------------------------|
|sed         |https://www.gnu.org/software/sed/ |4.4-2                        |
|gawk        |http://www.gnu.org/software/gawk/ |1:4.1.4+dfsg-1build1         |
|grep        |http://www.gnu.org/software/grep/ |3.1-2                        |
|perl        |http://dev.perl.org/perl5/        |5.26.1-6ubuntu0.2            |
|gnupg2      |https://www.gnupg.org/            |2.2.4-1ubuntu1.1             |
|vim         |https://vim.sourceforge.io/       |2:8.0.1453-1ubuntu1          |
|zip         |http://www.info-zip.org/Zip.html  |3.0-11build1                 |
|curl        |http://curl.haxx.se               |7.58.0-2ubuntu3.5            |
|make        |http://www.gnu.org/software/make/ |4.1-9.1ubuntu1               |
|firewalld   |http://www.firewalld.org/         |0.4.4.6-1                    |
|ghostscript |https://www.ghostscript.com/      |9.26~dfsg+0-0ubuntu0.18.04.1 |
|imagemagick |http://www.imagemagick.org/       |8:6.9.7.4+dfsg-16ubuntu6.4   |

[make-pdf-manual]: https://www.gnu.org/software/make/manual/make.pdf
[sed-pdf-manual]: https://www.gnu.org/software/sed/manual/sed.pdf
[gawk-pdf-manual]: https://www.gnu.org/software/gawk/manual/gawk.pdf
[bash-pdf-manual]: https://www.gnu.org/software/bash/manual/bash.pdf

tee 将标准输入复制到每个指定文件，并显示到标准输出。<https://www.gnu.org/software/coreutils/tee>
iptables IP 信息包过滤系统 <https://www.netfilter.org/>

tree 文件系统树形浏览器

```bash
sudo yum install -y tree
```

```bash
tree ~/.fonts
```

输出结果可以被 Markdown 语法接受

```markdown
/home/xiangyun/.fonts/
└── winfonts
    ├── Arial_Bold_Italic.ttf
    ├── Arial_Bold.ttf
    ├── Arial_Italic.ttf
    ├── Arial.ttf
    ├── FangSong_GB2312.ttf
    ├── KaiTi_GB2312.ttf
    ├── SimHei.ttf
    ├── SimSun.ttc
    ├── Times_New_Roman_Bold_Italic.ttf
    ├── Times_New_Roman_Bold.ttf
    ├── Times_New_Roman_Italic.ttf
    └── Times_New_Roman.ttf
```
```
1 directory, 12 files
```

## tlmgr

下载解压 install-tl-unx.tar.gz

```bash
wget https://mirrors.tuna.tsinghua.edu.cn/CTAN/systems/texlive/tlnet/install-tl-unx.tar.gz
tar -xzf install-tl-unx.tar.gz
```

安装 

```bash
sudo ./install-tl-20181217/install-tl
```

注意选择最小安装，即只安装包管理器 tlmgr （大约6M）

```
======================> TeX Live installation procedure <=====================

======>   Letters/digits in <angle brackets> indicate   <=======
======>   menu items for actions or customizations      <=======

 Detected platform: GNU/Linux on x86_64

 <B> set binary platforms: 1 out of 17

 <S> set installation scheme: scheme-infraonly

 <C> set installation collections:
     0 collections out of 41, disk space required: 6 MB

 <D> set directories:
   TEXDIR (the main TeX directory):
     /usr/local/texlive/2018
   TEXMFLOCAL (directory for site-wide local files):
     /usr/local/texlive/texmf-local
   TEXMFSYSVAR (directory for variable and automatically generated data):
     /usr/local/texlive/2018/texmf-var
   TEXMFSYSCONFIG (directory for local config):
     /usr/local/texlive/2018/texmf-config
   TEXMFVAR (personal directory for variable and automatically generated data):
     ~/.texlive2018/texmf-var
   TEXMFCONFIG (personal directory for local config):
     ~/.texlive2018/texmf-config
   TEXMFHOME (directory for user-specific files):
     ~/texmf

 <O> options:
   [ ] use letter size instead of A4 by default
   [X] allow execution of restricted list of programs via \write18
   [X] create all format files
   [X] install macro/font doc tree
   [X] install macro/font source tree
   [ ] create symlinks to standard directories

 <V> set up for portable installation

Actions:
 <I> start installation to hard disk
 <P> save installation profile to 'texlive.profile' and exit
 <H> help
 <Q> quit

Enter command: I
Installing to: /usr/local/texlive/2018
Installing [1/7, time/total: ??:??/??:??]: hyphen-base [22k]
Installing [2/7, time/total: 00:00/00:00]: kpathsea [1149k]
Installing [3/7, time/total: 00:01/00:01]: kpathsea.x86_64-linux [47k]
Installing [4/7, time/total: 00:01/00:01]: tetex [583k]
Installing [5/7, time/total: 00:01/00:01]: tetex.x86_64-linux [1k]
Installing [6/7, time/total: 00:01/00:01]: texlive.infra [394k]
Installing [7/7, time/total: 00:02/00:02]: texlive.infra.x86_64-linux [146k]
Time used for installing the packages: 00:02
running mktexlsr /usr/local/texlive/2018/texmf-dist ...
mktexlsr: Updating /usr/local/texlive/2018/texmf-dist/ls-R...
mktexlsr: Done.
writing fmtutil.cnf to /usr/local/texlive/2018/texmf-dist/web2c/fmtutil.cnf
writing updmap.cfg to /usr/local/texlive/2018/texmf-dist/web2c/updmap.cfg
writing language.dat to /usr/local/texlive/2018/texmf-var/tex/generic/config/language.dat
writing language.def to /usr/local/texlive/2018/texmf-var/tex/generic/config/language.def
writing language.dat.lua to /usr/local/texlive/2018/texmf-var/tex/generic/config/language.dat.lua
running mktexlsr /usr/local/texlive/2018/texmf-var /usr/local/texlive/2018/texmf-config /usr/local/texlive/2018/texmf-dist ...
mktexlsr: Updating /usr/local/texlive/2018/texmf-config/ls-R...
mktexlsr: Updating /usr/local/texlive/2018/texmf-dist/ls-R...
mktexlsr: Updating /usr/local/texlive/2018/texmf-var/ls-R...
mktexlsr: Done.
running updmap-sys --nohash ...done
re-running mktexlsr /usr/local/texlive/2018/texmf-var /usr/local/texlive/2018/texmf-config ...
mktexlsr: Updating /usr/local/texlive/2018/texmf-config/ls-R...
mktexlsr: Updating /usr/local/texlive/2018/texmf-var/ls-R...
mktexlsr: Done.
pre-generating all format files, be patient...
running fmtutil-sys --no-error-if-no-engine=luajittex,mfluajit --no-strict --all ...done
running package-specific postactions
finished with package-specific postactions


Welcome to TeX Live!


See /usr/local/texlive/2018/index.html for links to documentation.
The TeX Live web site (http://tug.org/texlive/) contains any updates and
corrections. TeX Live is a joint project of the TeX user groups around the
world; please consider supporting it by joining the group best for you. The
list of groups is available on the web at http://tug.org/usergroups.html.


Add /usr/local/texlive/2018/texmf-dist/doc/man to MANPATH.
Add /usr/local/texlive/2018/texmf-dist/doc/info to INFOPATH.
Most importantly, add /usr/local/texlive/2018/bin/x86_64-linux
to your PATH for current and future sessions.
Logfile: /usr/local/texlive/2018/install-tl.log
```

在 `.zshrc` 或者 `.bashrc` 文件中添加路径

```
# TeXLive
PATH="/usr/local/texlive/2018/bin/x86_64-linux:$PATH"
export PATH

export MANPATH=${MANPATH}:/usr/local/texlive/2018/texmf-dist/doc/man
export INFOPATH=${INFOPATH}:/usr/local/texlive/2018/texmf-dist/doc/info
```

此时 tlmgr 可以在终端中工作了

```bash
tlmgr search --file --global upquote.sty
```
```
tlmgr: package repository http://mirrors.tuna.tsinghua.edu.cn/CTAN/systems/texlive/tlnet (verified)
upquote:
        texmf-dist/tex/latex/upquote/upquote.sty
```

[^ip-port]: http://docs.rstudio.com/ide/server-pro/access-and-security.html#network-port-and-address
