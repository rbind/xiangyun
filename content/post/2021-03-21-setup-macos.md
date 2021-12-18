---
title: 设置 MacOS 电脑
author: 黄湘云
date: '2021-03-21'
slug: setup-macos
toc: true
categories:
  - 统计软件
tags:
  - 技术笔记
description: "软件环境配置是个既麻烦又耗时的苦力活，笔者曾经在 Windows 上折腾多年，换过几次电脑，工作之后，转向 MacOS 系统，又开始折腾，人生苦短，现收集整理出来，以后遇到新的坑也会填上来，尽量节省一些不必要的重复折腾。一些历史的折腾也搬上来了，生命不息，重装不止！"
---


# 高频设置

-   命令行工具 [Xcode](https://developer.apple.com/download/all/) 等，在线安装迷你版命令行工具。

    ```bash
    xcode-select --install
    ```

-   软件包管理工具 [brew](https://mirrors.tuna.tsinghua.edu.cn/help/homebrew/)

-   [Mac 截图去阴影等常用设置](https://macos-defaults.com/)

-   [自定义终端的命令行提示符](https://stackoverflow.com/questions/37286971/)

-   解决 [raw.githubusercontent.com port 443: Connection refused](https://blog.csdn.net/Rainbow1995/article/details/111475551)
    在网站 <https://ipaddress.com/> 输入 `raw.githubusercontent.com` 拿到 IP 地址，添加到 hosts 文件。
    
    ```bash
    sudo vi /etc/hosts
    ```
    ```
    185.199.108.133   raw.githubusercontent.com
    185.199.109.133   raw.githubusercontent.com
    185.199.110.133   raw.githubusercontent.com
    185.199.111.133   raw.githubusercontent.com
    ```

-   配置 MacOS 终端：MacOS 自带 [zsh](https://github.com/zsh-users/zsh)，只需安装 [Oh My Zsh](https://github.com/ohmyzsh/ohmyzsh) 配置工具、[nerd-font](https://github.com/ryanoasis/nerd-fonts) 图标字体和 [powerlevel10k](https://github.com/romkatv/powerlevel10k) 主题。

    ```bash
    # 安装 fira-code 字体及其配套的图标字体
    brew install --cask font-fira-code font-fira-code-nerd-font
    ```

# 文本编辑

## 编辑工具

通用代码文本集成开发编辑环境 IDE

```bash
brew install --cask visual-studio-code atom 
```

文字编辑和文档转化工具

```bash
brew install pandoc hugo
brew install --cask mark-text
brew install --cask calibre lyx
```

运行 LyX 内置的 knitr 模版，需要一些 LaTeX 包

``` r
tinytex::tlmgr_install(c('palatino', 'babel-english', 'mathpazo'))
```

## 中文字体

``` bash
brew tap homebrew/cask-fonts
brew install --cask font-noto-sans-cjk-sc font-noto-serif-cjk-sc
brew install --cask font-alegreya-sans-sc font-alegreya-sc
```

## 字体使用

LaTeX 宏包 **xecjk** 支持中文，不必使用 **ctex** 宏包，MacOS 系统上，在 LaTeX 文档里使用 Windows 系统上的黑体、宋体、仿宋、楷体四款中文字体。

``` tex
\setCJKmainfont[ItalicFont={KaiTi_GB2312}, BoldFont={SimHei}]{SimSun}
\setCJKsansfont{SimHei}
\setCJKmonofont{FangSong_GB2312}

\setCJKfamilyfont{heiti}{SimHei}             
\newcommand{\heiti}{\CJKfamily{heiti}}

\setCJKfamilyfont{kaishu}{KaiTi_GB2312}             
\newcommand{\kaishu}{\CJKfamily{kaishu}}

\setCJKfamilyfont{songti}{SimSun}             
\newcommand{\songti}{\CJKfamily{songti}}

\setCJKfamilyfont{fangsong}{FangSong_GB2312}             
\newcommand{\fangsong}{\CJKfamily{fangsong}}
```

## 英文字体

``` bash
# 用于 RStudio IDE 内的代码编辑器
brew install --cask font-fira-code
# 等宽字体
brew install font-inconsolata
# dejavu/liberation/fira 等系列字体
brew install font-dejavu font-liberation
brew install font-fira-sans font-fira-mono font-fira-code 
brew install font-open-sans font-open-sans-condensed
# 思源英文字体
brew install --cask font-source-code-pro font-source-sans-pro  font-source-serif-pro
# 用于终端显示
brew install --cask font-source-code-pro-for-powerline
# 漫画字体
brew install --cask font-xkcd
# 表情字体
brew install --cask font-noto-emoji font-noto-color-emoji 
# Windows 系统字体
brew install --cask font-arial font-andale-mono
```


刘志进实验室有很多免费音乐，支持外链，可以插入博客 <https://music.liuzhijin.cn/>

# 常用软件


``` bash
# 图像处理
brew install ghostscript imagemagick optipng graphviz
brew install ffmpeg gifski
brew install --cask drawio inkscape gimp

# 视频播放
brew install --cask zy-player
brew install --cask iina

# 解压、下载软件
brew install --cask rar free-download-manager

# 数据库管理
brew install --cask dbeaver-community

# 统计软件
brew install jags
brew install --cask jasp qgis
brew install --cask julia

# Python 和 Java 开发环境
brew install --cask pycharm-ce intellij-idea-ce

# 办公软件
brew install --cask tencent-meeting zoom
brew install --cask google-chrome
brew install --cask adobe-acrobat-reader
brew install --cask notion
brew install --cask microsoft-office
brew install --cask adobe-creative-cloud

# Github CLI 命令行工具
brew install tig tree
brew install gh gnupg
```


# R 和 RStudio 软件

``` bash
brew install --cask r xquartz
brew install --cask rstudio
```

设置 R 软件的语言为英文[^1]，避免一些不必要的编码问题，中文翻译不是很好，此外，看英文最好！

[^1]: [Internationalization of the R.app](https://cran.r-project.org/bin/macosx/RMacOSX-FAQ.html#Internationalization-of-the-R_002eapp)

``` bash
defaults write org.R-project.R force.LANG en_US.UTF-8
```

安装一些 R 包需要的系统依赖

``` bash
brew install glpk
brew install clp
brew install udunits gdal
brew install v8
```

安装完 apache-arrow 后，固定下来

``` bash
brew install apache-arrow
brew pin apache-arrow 
```

## R 包与 Orca

安装 orca 将 plotly 绘制的交互式动态图形转化为静态的 SVG/PDF 格式矢量图形

``` bash
brew install --cask orca
```

## R 包与 PhantomJS

安装 phantomjs 用于 **webshot** 包

``` bash
brew install --cask phantomjs
```

`webshot::install_phantomjs()` 将交互式图形截图放在 bookdown 书里

## R 包与 Java JDK

[JDK](https://github.com/openjdk/jdk)

``` bash
# 推荐 Java JDK 11 (or later)
brew install openjdk@11
```

配置 JDK

``` bash
# 默认的全局设置
sudo ln -sfn /usr/local/opt/openjdk@11/libexec/openjdk.jdk /Library/Java/JavaVirtualMachines/openjdk-11.jdk
# 环境变量
echo 'export PATH="/usr/local/opt/openjdk@11/bin:$PATH"' >> ~/.zshrc
# C++
export CPPFLAGS="-I/usr/local/opt/openjdk@11/include"

# 配置 R 环境
sudo R CMD javareconf

# 安装 rJava 包
Rscript -e 'install.packages(c("rJava", "sparklyr"))'
```

在 .zshrc 添加环境变量

    export SPARK_VERSION=3.1.1
    export HADOOP_VERSION=3.2
    export SPARK_HOME=/opt/spark/spark-3.1.1-bin-hadoop3.2

推荐从[Apache Spark](https://spark.apache.org)下载 Spark 环境

``` bash
sudo mkdir -p /opt/spark/
sudo chown -R $(whoami):admin /opt/spark/
tar -xzf spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz -C /opt/spark/
```

Spark 环境自带了 R 接口 **SparkR** 包，可这样加载：

```r
library(SparkR, lib.loc = "/opt/spark/spark-3.1.1-bin-hadoop3.2/R/lib/")
```

## R 包与 OpenMP

目前，发现 R 包 **data.table**、**RandomFields** 和 **RandomFieldsUtils** 需启用 OpenMP 从源码编译才能获得共享内存的多线程并行计算的能力。

从源码安装 [data.table](https://github.com/fxcoudert/gfortran-for-macOS/releases)

``` bash
brew install pkg-config # 检查和发现 zlib
brew install libomp # OpenMP
```

参考 <https://mac.r-project.org/openmp/> 文档，在 `~/.R/Makevars` 添加两行即可。

    CPPFLAGS += -Xclang -fopenmp
    LDFLAGS += -lomp

## Rmpi 包和 open-mpi

先安装外部软件依赖

``` bash
brew install open-mpi
```

``` r
install.packages('Rmpi', type = 'source')
```

    * installing *source* package ‘Rmpi’ ...
    ** package ‘Rmpi’ successfully unpacked and MD5 sums checked
    ** using staged installation
    checking for gcc... clang -mmacosx-version-min=11.3
    checking whether the C compiler works... yes
    checking for C compiler default output file name... a.out
    checking for suffix of executables... 
    checking whether we are cross compiling... no
    checking for suffix of object files... o
    checking whether we are using the GNU C compiler... yes
    checking whether clang -mmacosx-version-min=11.3 accepts -g... yes
    checking for clang -mmacosx-version-min=11.3 option to accept ISO C89... none needed
    checking for pkg-config... /usr/local/bin/pkg-config
    checking if pkg-config knows about OpenMPI... yes
    checking for orted... yes
    configure: creating ./config.status
    config.status: creating src/Makevars
    ** libs
    clang -mmacosx-version-min=11.3 -I"/Library/Frameworks/R.framework/Resources/include" -DNDEBUG -DPACKAGE_NAME=\"\" -DPACKAGE_TARNAME=\"\" -DPACKAGE_VERSION=\"\" -DPACKAGE_STRING=\"\" -DPACKAGE_BUGREPORT=\"\" -DPACKAGE_URL=\"\" -I/usr/local/Cellar/open-mpi/4.1.1_2/include -DMPI2 -DOPENMPI  -I/usr/local/include   -fPIC  -Wall -g -O2  -c Rmpi.c -o Rmpi.o
    clang -mmacosx-version-min=11.3 -I"/Library/Frameworks/R.framework/Resources/include" -DNDEBUG -DPACKAGE_NAME=\"\" -DPACKAGE_TARNAME=\"\" -DPACKAGE_VERSION=\"\" -DPACKAGE_STRING=\"\" -DPACKAGE_BUGREPORT=\"\" -DPACKAGE_URL=\"\" -I/usr/local/Cellar/open-mpi/4.1.1_2/include -DMPI2 -DOPENMPI  -I/usr/local/include   -fPIC  -Wall -g -O2  -c conversion.c -o conversion.o
    clang -mmacosx-version-min=11.3 -I"/Library/Frameworks/R.framework/Resources/include" -DNDEBUG -DPACKAGE_NAME=\"\" -DPACKAGE_TARNAME=\"\" -DPACKAGE_VERSION=\"\" -DPACKAGE_STRING=\"\" -DPACKAGE_BUGREPORT=\"\" -DPACKAGE_URL=\"\" -I/usr/local/Cellar/open-mpi/4.1.1_2/include -DMPI2 -DOPENMPI  -I/usr/local/include   -fPIC  -Wall -g -O2  -c internal.c -o internal.o
    clang -mmacosx-version-min=11.3 -dynamiclib -Wl,-headerpad_max_install_names -undefined dynamic_lookup -single_module -multiply_defined suppress -L/Library/Frameworks/R.framework/Resources/lib -L/usr/local/lib -o Rmpi.so Rmpi.o conversion.o internal.o -L/usr/local/Cellar/open-mpi/4.1.1_2/lib -L/usr/local/opt/libevent/lib -lmpi -F/Library/Frameworks/R.framework/.. -framework R -Wl,-framework -Wl,CoreFoundation
    installing to /Library/Frameworks/R.framework/Versions/4.1/Resources/library/00LOCK-Rmpi/00new/Rmpi/libs
    ** R
    ** demo
    ** inst
    ** byte-compile and prepare package for lazy loading
    ** help
    *** installing help indices
    ** building package indices
    ** testing if installed package can be loaded from temporary location
    ** checking absolute paths in shared objects and dynamic libraries
    ** testing if installed package can be loaded from final location
    ** testing if installed package keeps a record of temporary installation path
    * DONE (Rmpi)

## stringi 包和 icu4c

安装 icu4c

``` bash
brew install icu4c
```

配置环境变量

``` bash
# brew 安装的 icu4c 优先
echo 'export PATH="/usr/local/opt/icu4c/bin:$PATH"' >> ~/.zshrc
echo 'export PATH="/usr/local/opt/icu4c/sbin:$PATH"' >> ~/.zshrc

# 用于 C++ 编译器找到 icu4c
echo 'export LDFLAGS="-L/usr/local/opt/icu4c/lib"' >> ~/.zshrc
echo 'export CPPFLAGS="-I/usr/local/opt/icu4c/include"' >> ~/.zshrc

# 用于 pkg-config 找到 icu4c 
echo 'export PKG_CONFIG_PATH="/usr/local/opt/icu4c/lib/pkgconfig"' >> ~/.zshrc
```

如果用 brew 安装了新版本的 gcc 编译器，在安装需要启用 gcc 编译链接的 R 包时，出现如下类似警告[^2]：

[^2]: [Mac OS X R error "ld: warning: directory not found for option"](https://stackoverflow.com/questions/35999874/mac-os-x-r-error-ld-warning-directory-not-found-for-option)

    ld: warning: directory not found for option '-L/usr/local/lib/gcc/x86_64-apple-darwin13.0.0/4.8.2'

设置 gfortran 库路径，当前安装的 gcc-11

    FLIBS = -L/usr/local/Cellar/gcc/11.2.0/lib/gcc/11 -lgfortran -lquadmath -lm

# Python 虚拟环境

##  用 miniconda 配置

`~/.condarc` 指定虚拟环境所在目录

``` yaml
envs_dirs:
  - /opt/miniconda-virtualenvs/
```

详见 miniconda [官方文档](https://docs.conda.io/en/latest/miniconda.html)

``` bash
# 安装 miniconda
brew install --cask miniconda
# 初始化，将配置写入当前 Shell 环境，比如 .zshrc
conda init "$(basename "${SHELL}")"   

# 创建环境
conda create -n r-reticulate python=3.8
# 激活环境
conda activate r-reticulate
# 安装模块
conda install --yes --file requirements.txt

# 更新升级 conda
conda update -n base -c defaults conda

# 退出虚拟环境
conda deactivate
```

``` bash
# 指定安装路径和 Python 版本
conda create -p /opt/miniconda-virtualenvs/r-reticulate python=3.7
# 移除虚拟环境
conda env remove -p /opt/miniconda-virtualenvs/r-reticulate
# 更新 miniconda
conda update conda
```

## 用 virtualenv 配置

安装 virtualenv

``` bash
brew install virtualenv
```

用 virtualenv 创建虚拟环境，虚拟环境的存放路径是 `/opt/.virtualenvs/r-tensorflow`，所以名字就是 `r-tensorflow`

``` bash
# 准备虚拟环境萼存放地址
sudo mkdir -p /opt/.virtualenvs/r-tensorflow
sudo chown -R $(whoami):staff /opt/.virtualenvs/r-tensorflow
# 方便后续复用
export RETICULATE_PYTHON_ENV=/opt/.virtualenvs/r-tensorflow
# 创建虚拟环境
virtualenv -p /usr/local/bin/python3 $RETICULATE_PYTHON_ENV
```

查看虚拟环境中 Python 版本

``` bash
python -V
```

激活虚拟环境

``` bash
source $RETICULATE_PYTHON_ENV/bin/activate
# 取消激活
deactivate
```

进入虚拟环境后，从 requirements.txt 安装 Python 模块

``` bash
pip install -r requirements.txt
```

查看已经安装的 Python 模块

``` bash
pip list --format=columns
```

在文件 `.Rprofile` 里设置环境变量 `RETICULATE_PYTHON` 和 `RETICULATE_PYTHON_ENV`，这样 **reticulate** 包就能发现和使用它了。

``` bash
Sys.setenv(RETICULATE_PYTHON="/usr/local/bin/python3")
Sys.setenv(RETICULATE_PYTHON_ENV="/opt/.virtualenvs/r-tensorflow")
```

如果希望打开终端就进入虚拟环境，可以在 .zshrc 文件中添加两行

``` bash
export RETICULATE_PYTHON_ENV=/opt/.virtualenvs/r-tensorflow
source $RETICULATE_PYTHON_ENV/bin/activate
```

> 注意
>
> 要使用从 brew 安装的 Python3 即 `/usr/local/bin/python3` 而不是 MacOS 系统自带的 Python3，即 `/usr/bin/python3`

在 RStudio IDE 里配置好 Python 及其虚拟环境，应该能看到

``` r
Sys.getenv("RETICULATE_PYTHON")
```

    [1] "/usr/local/bin/python3"

``` r
reticulate::py_discover_config()
```

    python:         /usr/local/bin/python3
    libpython:      /usr/local/opt/python@3.9/Frameworks/Python.framework/Versions/3.9/lib/python3.9/config-3.9-darwin/libpython3.9.dylib
    pythonhome:     /usr/local/Cellar/python@3.9/3.9.7/Frameworks/Python.framework/Versions/3.9
    version:        3.9.7 (default, Sep  3 2021, 12:37:55)  [Clang 12.0.5 (clang-1205.0.22.9)]
    numpy:          /usr/local/lib/python3.9/site-packages/numpy
    numpy_version:  1.21.2

    NOTE: Python version was forced by RETICULATE_PYTHON

# Gollum 知识管理

用 [Gollum](https://github.com/gollum/gollum) 创建 wiki 随时记下个人笔记，gollum 源自电影《指环王》里的角色咕噜。系统环境如下

``` bash
gem env
```

    RubyGems Environment:
      - RUBYGEMS VERSION: 3.0.3
      - RUBY VERSION: 2.6.3 (2019-04-16 patchlevel 62) [universal.x86_64-darwin20]
      - INSTALLATION DIRECTORY: /Library/Ruby/Gems/2.6.0
      - USER INSTALLATION DIRECTORY: /Users/你的账户名/.gem/ruby/2.6.0
      - RUBY EXECUTABLE: /System/Library/Frameworks/Ruby.framework/Versions/2.6/usr/bin/ruby
      - GIT EXECUTABLE: /usr/bin/git
      - EXECUTABLE DIRECTORY: /usr/local/bin
      - SPEC CACHE DIRECTORY: /Users/你的账户名/.gem/specs
      - SYSTEM CONFIGURATION DIRECTORY: /Library/Ruby/Site
      - RUBYGEMS PLATFORMS:
        - ruby
        - universal-darwin-20
      - GEM PATHS:
         - /Library/Ruby/Gems/2.6.0
         - /Users/你的账户名/.gem/ruby/2.6.0
         - /System/Library/Frameworks/Ruby.framework/Versions/2.6/usr/lib/ruby/gems/2.6.0
      - GEM CONFIGURATION:
         - :update_sources => true
         - :verbose => true
         - :backtrace => false
         - :bulk_threshold => 1000
         - :sources => ["https://mirrors.tuna.tsinghua.edu.cn/rubygems/"]
         - :concurrent_downloads => 8
      - REMOTE SOURCES:
         - https://mirrors.tuna.tsinghua.edu.cn/rubygems/
      - SHELL PATH:
         - /Users/你的账户名/.gem/ruby/2.6.0/bin

将 `/Users/你的账户名/.local/share/gem/ruby/2.6.0/bin` 添加到 PATH 变量里，修改修改镜像源，加快下载速度

``` bash
gem sources --add https://mirrors.tuna.tsinghua.edu.cn/rubygems/ --remove https://rubygems.org/
```

安装好 Xcode 库后，安装一些编译环境，比如 cmake，一些 [gollum](https://github.com/gollum/gollum) 依赖的库需要编译安装，这些库是用 cmake 创建的项目。更新自带的库

``` bash
sudo gem update
```

然后安装 gollum

``` bash
brew install cmake pkg-config
gem install --user-install gollum
```

注意:warning:，由于权限问题，不能安装到系统目录，实际上，也建议安装到非系统目录，即当前账户下的目录，截止 2021-03-06 安装的最新稳定版本 gollum 5.2.1。创建一个目录，并用 git 初始化， gollum 是用 git 来做版本管理的，所以要先初始化，然后使用 gollum 服务，启动 wiki

``` bash
gollum /path/to/wiki
```

最后，预览 Wiki 网页，打开 <http://localhost:4567>，gollum 默认使用 4567 端口号，如果分支使用 main， 那么启动的时候要加参数 `--ref` 指定为 main

``` bash
gollum --ref main --emoji --allow-uploads=dir /path/to/wiki
```

> 注意
>
> 先想好目录结构，不然会很乱，以后改起来就麻烦了！



# 其它折腾

虚拟机内使用 CentOS 8.x 和 Fedora 29+ 系统时遇到的一些问题。

## CentOS 8.x & Fedora 29+

### 修改网络配置

```bash
# CentOS 8.x
sudo vi /etc/sysconfig/network-scripts/ifcfg-enp0s8
```
```
TYPE=Ethernet
PROXY_METHOD=none
BROWSER_ONLY=no
BOOTPROTO=dhcp
DEFROUTE=yes
IPV4_FAILURE_FATAL=no
IPV6INIT=yes
IPV6_AUTOCONF=yes
IPV6_DEFROUTE=yes
IPV6_FAILURE_FATAL=no
IPV6_ADDR_GEN_MODE=stable-privacy
NAME=enp0s8
UUID=b1914547-de69-4974-93f3-9b8bef8dabc0
DEVICE=enp0s8
ONBOOT=yes
```

将 `ONBOOT=no` 设置为 `ONBOOT=yes`，然后重启网络

```bash
sudo systemctl restart NetworkManager.service
# 或者
sudo systemctl stop NetworkManager.service
sudo systemctl start NetworkManager.service
# 或者
sudo nmcli networking off
sudo nmcli networking on
```

### 本地化设置

命令行内输入 `locale` 看到如下输出时，意味着系统语言环境没有设置

```
locale: Cannot set LC_CTYPE to default locale: No such file or directory
locale: Cannot set LC_MESSAGES to default locale: No such file or directory
locale: Cannot set LC_ALL to default locale: No such file or directory
LANG=zh_CN.UTF-8
LC_CTYPE="zh_CN.UTF-8"
LC_NUMERIC="zh_CN.UTF-8"
LC_TIME="zh_CN.UTF-8"
LC_COLLATE="zh_CN.UTF-8"
LC_MONETARY="zh_CN.UTF-8"
LC_MESSAGES="zh_CN.UTF-8"
LC_PAPER="zh_CN.UTF-8"
LC_NAME="zh_CN.UTF-8"
LC_ADDRESS="zh_CN.UTF-8"
LC_TELEPHONE="zh_CN.UTF-8"
LC_MEASUREMENT="zh_CN.UTF-8"
LC_IDENTIFICATION="zh_CN.UTF-8"
LC_ALL=
```

是中文环境，就安装中文语言包，如果是英文环境就安装英文语言包

```bash
sudo dnf install -y glibc-langpack-zh
```

> 编码、语言环境设置 <https://docs.fedoraproject.org/en-US/fedora/rawhide/system-administrators-guide/basic-system-configuration/System_Locale_and_Keyboard_Configuration/>


### 配置组账户权限

```bash
# 创建组 staff
groupadd staff

# 创建 docker 用户，并把它加入到 staff 组中
useradd -g staff -d /home/docker docker

# 给 staff 组管理员 root 权限
useradd -s /bin/bash -g staff -G root docker
usermod -G root docker
```


### 配置镜像源

Fedora 系统

```bash
# 加快下载速度
sudo sed -e 's!^metalink=!#metalink=!g' \
    -e 's!^#baseurl=!baseurl=!g' \
    -e 's!//download\.fedoraproject\.org/pub!//mirrors.tuna.tsinghua.edu.cn!g' \
    -e 's!http://mirrors\.tuna!https://mirrors.tuna!g' \
    -i /etc/yum.repos.d/epel.repo /etc/yum.repos.d/epel-testing.repo /etc/yum.repos.d/epel-modular.repo \
    /etc/yum.repos.d/epel-playground.repo

# 指定安装源
sudo sed -e 's|^metalink=|#metalink=|g' \
   -e 's|^#baseurl=http://download.fedoraproject.org/pub/fedora/linux|baseurl=https://mirrors.ustc.edu.cn/fedora|g' \
   -i /etc/yum.repos.d/fedora.repo \
   /etc/yum.repos.d/fedora-modular.repo \
   /etc/yum.repos.d/fedora-updates.repo \
   /etc/yum.repos.d/fedora-updates-modular.repo
```

### 安装软件包

```bash
# texinfo-tex openblas-devel pandoc
sudo dnf config-manager --set-enabled PowerTools 
# R-devel
sudo dnf -y install epel-release 
sudo dnf update
```


### 安装 MariaDB

```bash
# 从系统仓库安装开源版 
sudo dnf install -y mariadb mariadb-devel mariadb-connector-odbc unixODBC-devel mariadb-server

# 启动 mysql 服务
sudo systemctl start mariadb.service
# 设置开机启动
sudo systemctl enable mariadb.service

# 先设置密码，然后登陆
sudo '/usr/bin/mysqladmin' -u root password 'cloud'
mysql -u root -h 127.0.0.1 -p 
mysql -u root -p ‘cloud’
```


### 主宿机文件传输

```bash
# 测试链接
ssh xiangyun@192.168.56.5 -p 22
# 主机文件 pandoc-2.10.1-linux-amd64.tar.gz 放入虚拟机
scp -P 22 rstudio-server-rhel-1.3.1073-x86_64.rpm xiangyun@192.168.58.5:/home/xiangyun/
```

输入密码后即可传输，速度飞快

```
rstudio-server-rhel-1.3.1073-x86_64.rpm       100%   45MB  74.5MB/s   00:00
```



### 系统默认软件

尚未安装其它任何软件的情况下，系统自带的软件包，每一个都是生产力工具，每一个都值得写一篇长文介绍如何使用，留着以后折腾吧！

| 工具               | 概况                                                         | 版本     | 官网                                              |
| ------------------ | ------------------------------------------------------------ | -------- | ------------------------------------------------- |
| vi/vim/vim-minimal | 文本编辑器 A minimal version of the VIM editor               | 8.0.1763 | https://www.vim.org/                              |
| bash               | The GNU Bourne Again shell                                   | 4.4.19   | https://www.gnu.org/software/bash                 |
| gawk               | The GNU version of the AWK text processing utility           | 4.2.1    | https://www.gnu.org/software/gawk/                |
| grep               | Pattern matching utilities                                   | 3.1      | https://www.gnu.org/software/grep/                |
| sed                | A GNU stream text editor                                     | 4.5      | http://sed.sourceforge.net/                       |
| dnf                | 软件包管理器 Package manager                                 | 4.2.7    | https://github.com/rpm-software-management/dnf    |
| openssh            | An open source implementation of SSH protocol version 2      | 8.0p1    | http://www.openssh.com/portable.html              |
| openssl            | Utilities from the general purpose cryptography library with TLS implementation | 1.1.1c   | https://www.openssl.org/                          |
| curl               | A utility for getting files from remote servers (FTP, HTTP, and others) | 7.61.1   | https://curl.haxx.se/                             |
| iptables           | Tools for managing Linux kernel packet filtering capabilities | 1.8.2    | https://www.netfilter.org/                        |
| firewalld          | A firewall daemon with D-Bus interface providing a dynamic firewall | 0.7.0    | https://www.firewalld.org                         |
| NetworkManager     | Network connection manager and user applications             | 1.20.0   | http://www.gnome.org/projects/NetworkManager/     |
| rsyslog            | Enhanced system logging and kernel message trapping daemon   | 8.37.0   | https://www.rsyslog.com/                          |
| dbus               | D-BUS message bus                                            | 1.12.8   | http://www.freedesktop.org/Software/dbus/         |
| systemd            | System and Service Manager                                   | 239      | https://www.freedesktop.org/wiki/Software/systemd |
| gnupg2             | Utility for secure communication and data storage            | 2.2.9    | https://www.gnupg.org/                            |
| gzip               | The GNU data compression program                             | 1.9      | https://www.gzip.org/                             |
| xz                 | LZMA compression utilities                                   | 5.2.4    | https://tukaani.org/xz/                           |
| crontab            | 定时任务 Root crontab files used to schedule the execution of programs | 1.11     | https://fedorahosted.org/crontabs                 |

### tree 树形浏览器

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

### 安装 fish/zsh

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

### 安装软件

```bash
sudo dnf install -y \
  calibre inkscape optipng ImageMagick ghostscript texinfo \
  texlive-pdfcrop texlive-dvisvgm texlive-dvips \
  texlive-dvipng texlive-ctex texlive-fandol texlive-xetex \
  texlive-framed texlive-titling \
  tex-preview epstool texlive-alegreya texlive-sourcecodepro
```

### 删除内核

```bash
# 查看已安装的内核
rpm -qa | grep kernel
# 删除旧内核
sudo yum remove kernel-3.10.0-693.el7.x86_64
```

### Linux 工具箱


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



### 安装 tlmgr

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

## RStudio Server 相关

### 安装 RStudio Server 

```bash
curl -fLo rstudio-server-rhel-1.3.1073-x86_64.rpm https://download2.rstudio.org/server/centos8/x86_64/rstudio-server-rhel-1.3.1073-x86_64.rpm

gpg --keyserver keys.gnupg.net --recv-keys 3F32EE77E331692F
gpg --export --armor 3F32EE77E331692F > rstudio-signing.key 
sudo rpm --import rstudio-signing.key  
rpm -K rstudio-server-rhel-1.3.1073-x86_64.rpm

sudo dnf install -y rstudio-server-rhel-1.3.1073-x86_64.rpm
```

输出如下表示验证成功

```
rstudio-server-rhel-1.3.1073-x86_64.rpm: digests signatures 确定
```

### 更新 Pandoc 版本

替换掉 RStudio Server 自带的低版本，RStudio 1.3 自带 Pandoc 2.7.3

```bash
tar -xzf pandoc-2.10.1-linux-amd64.tar.gz 
sudo cp pandoc-2.10.1/bin/* /usr/lib/rstudio-server/bin/pandoc/
echo "PATH=/usr/local/lib/rstudio-server/bin/pandoc:$PATH; export PATH" | tee -a ~/.bashrc
```


## 配置 R 环境


```bash
# 查看 R-devel 依赖
sudo dnf builddep R-devel
# 安装 R 及其依赖
dnf install -y R git R-littler R-littler-examples \
   openssl-devel libssh2-devel libgit2-devel \
   libxml2-devel libcurl-devel
# 快捷方式
ln -s /usr/lib64/R/library/littler/examples/install.r /usr/bin/install.r 
ln -s /usr/lib64/R/library/littler/examples/install2.r /usr/bin/install2.r
ln -s /usr/lib64/R/library/littler/examples/installGithub.r /usr/bin/installGithub.r 
ln -s /usr/lib64/R/library/littler/examples/testInstalled.r /usr/bin/testInstalled.r

# 配置 R 英文环境
echo "LANG=en_US.UTF-8" >> /usr/lib64/R/etc/Renviron.site
# 配置系统英文环境
echo "export LC_ALL=en_US.UTF-8"  >> /etc/profile
echo "export LANG=en_US.UTF-8"  >> /etc/profile

# R 配置文件
sudo touch /usr/lib64/R/etc/Rprofile.site
sudo mkdir -p /usr/lib64/R/site-library
sudo chown -R $(whoami):$(whoami) /usr/lib64/R/library /usr/share/doc /usr/lib64/R/site-library /usr/lib64/R/etc/Rprofile.site

# https://github.com/r-lib/devtools/issues/2084
echo ".libPaths(c('/usr/lib64/R/site-library','/usr/lib64/R/library'))" | tee -a  /usr/lib64/R/etc/Rprofile.site

Rscript -e 'x <- file.path(R.home("doc"), "html"); if (!file.exists(x)) {dir.create(x, recursive=TRUE); file.copy(system.file("html/R.css", package="stats"), x)}'
# CRAN 镜像地址
echo "options(repos = c(CRAN = 'https://mirrors.tuna.tsinghua.edu.cn/CRAN'), download.file.method = 'libcurl')" | tee -a  /usr/lib64/R/etc/Rprofile.site
```


### 编辑安全策略


在 CentOS 8.x 上安装 RStudio Server 时，遇到如下错误，需要编辑策略 Security-Enhanced Linux （访问控制安全策略机制）

```
 ERROR system error 13 (Permission denied); OCCURRED AT: rstudio::core::Error 
 
 rstudio::core::system::launchChildProcess(std::__cxx11::string, std::__cxx11::string, rstudio::core::system::ProcessConfig, rstudio::core::system::ProcessConfigFilter, PidType*)
 
 /var/lib/jenkins/workspace/IDE/open-source-pipeline/v1.2-patch/src/cpp/core/system/PosixSystem.cpp:2152; 
 
 LOGGED FROM: rstudio::core::Error rstudio::core::system::launchChildProcess(std::__cxx11::string, std::__cxx11::string, rstudio::core::system::ProcessConfigFilter, PidType*) 
 
 /var/lib/jenkins/workspace/IDE/open-source-pipeline/v1.2-patch/src/cpp/core/system/PosixSystem.cpp:2153
```

运行命令 `sestatus` 查看情况，修改策略配置文件

```bash
sudo vi /etc/sysconfig/selinux
```

将 `SELinux=enforcing` 改为 `SELinux=disabled`，改完之后，重启，运行命令 `sestatus`，看是否生效

> 详见解决办法 <https://community.rstudio.com/t/rserver-1692-error-system-error-13-permission-denied/46972/10>


### 配置防火墙

开辟网络访问端口，比如 8282，准备分配给 RStudio Server

```bash
sudo firewall-cmd --zone=public --add-port=8282/tcp --permanent
sudo firewall-cmd --reload
```

### 修改默认配置 

```bash
sudo chown -R $(whoami):$(whoami) /etc/rstudio/rserver.conf /etc/rstudio/rsession.conf
# 默认的 R 路径 /usr/bin/R
echo "rsession-which-r=/usr/bin/R" >> /etc/rstudio/rserver.conf 
echo "www-port=8282" >> /etc/rstudio/rserver.conf 
echo "r-cran-repos=https://mirrors.tuna.tsinghua.edu.cn/CRAN/" >> /etc/rstudio/rsession.conf

# 重启 rstudio-server 服务
sudo rstudio-server restart
```

然后就可以访问 <http://192.168.58.5:8282>

## 系统安装

安装 Fedora 29, CentOS 7, OpenSUSE 15, Ubuntu 18.04


### 安装 Fedora 29

开机进入安装界面后，首先选择安装过程中使用的语言，这里选择英语

![choose-english](https://wp-contents.netlify.com/2019/01/Fedora/01.png)

启用网络连接

![](https://wp-contents.netlify.com/2019/01/Fedora/02.png)

最小安装

![](https://wp-contents.netlify.com/2019/01/Fedora/03.png)

完成各项配置

![](https://wp-contents.netlify.com/2019/01/Fedora/04.png)

等待安装直到完成

![](https://wp-contents.netlify.com/2019/01/Fedora/05.png)


当我们往 Linux 系统输入第一个含有管理员权限的命令后，会提示如下一段话

```
[xiangyun@localhost ~]$ sudo dnf update

我们信任您已经从系统管理员那里了解了日常注意事项。
总结起来无外乎这三点：

    #1) 尊重别人的隐私。
    #2) 输入前要先考虑(后果和风险)。
    #3) 权力越大，责任越大。

[sudo] xiangyun 的密码：
```

### 安装 CentOS 7

> 安装 CentOS 8 minimal 版本

下载<https://mirrors.tuna.tsinghua.edu.cn/centos/8/isos/x86_64/CentOS-8-x86_64-1905-boot.iso>

填写在线安装的网络地址 repo
<https://mirrors.ustc.edu.cn/centos/8/BaseOS/x86_64/os/>

CentOS 8源帮助 <https://mirrors.ustc.edu.cn/help/centos.html>

```bash
sudo mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup
touch CentOS-Base.repo
vi CentOS-Base.repo
sudo cp CentOS-Base.repo /etc/yum.repos.d/
sudo yum makecache
```

配置网络后，重启网络

```bash
sudo nmcli c reload
```

开机进入安装界面后，首先选择安装过程中使用的语言，这里选择英语

![choose-english](https://wp-contents.netlify.com/2018/12/installation-centos/01-choose-english.png)

可以看到还有警告提示，需要配置网络连接、远程镜像位置、系统安装位置

![](https://wp-contents.netlify.com/2018/12/installation-centos/02-settings.png)

默认情况下 enpOs3 没有启用

![](https://wp-contents.netlify.com/2018/12/installation-centos/02-network-01.png)

我们把它开启

![](https://wp-contents.netlify.com/2018/12/installation-centos/02-network-02.png)

类似地，把 enpOs8 也开启

![](https://wp-contents.netlify.com/2018/12/installation-centos/02-network-03.png)

此时远程镜像位置还没有配置，选择就近的系统安装源，如清华

![](https://wp-contents.netlify.com/2018/12/installation-centos/03-installation-source.png)

选择最小安装

![](https://wp-contents.netlify.com/2018/12/installation-centos/04-minimal-install.png)

选择安装位置

![](https://wp-contents.netlify.com/2018/12/installation-centos/05-installation-destination.png)

完成各项安装配置

![](https://wp-contents.netlify.com/2018/12/installation-centos/06-settings-down.png)

需要创建用户

![](https://wp-contents.netlify.com/2018/12/installation-centos/07-start-installation.png)

设置用户登陆密码

![](https://wp-contents.netlify.com/2018/12/installation-centos/08-root.png)

将该用户设置为管理员权限

![](https://wp-contents.netlify.com/2018/12/installation-centos/09-user-create.png)

完成用户创建

![](https://wp-contents.netlify.com/2018/12/installation-centos/10-accounts-down.png)

等待安装，直到完成

![](https://wp-contents.netlify.com/2018/12/installation-centos/11-installation-finish-reboot.png)

重启，选择第一项进入系统

![](https://wp-contents.netlify.com/2018/12/installation-centos/12-start-os.png)

获取 IP 地址

![](https://wp-contents.netlify.com/2018/12/installation-centos/13-configure-network.png)

`ONBOOT=no` 设置为 `ONBOOT=yes`

![](https://wp-contents.netlify.com/2018/12/installation-centos/14-onboot-yes.png)

将获得的 IP 输入 PUTTY

![](https://wp-contents.netlify.com/2018/12/installation-centos/15-PuTTY.png)

第一次连接虚拟机中的操作系统， PUTTY 会有安全提示，选择是，登陆进去

![](https://wp-contents.netlify.com/2018/12/installation-centos/16-PuTTY-Security.png)

### 安装 OpenSUSE

开机进入安装界面后，选择时区

![openSUSE-timezone](https://wp-contents.netlify.com/2019/03/openSUSE_timezone.png)

选择安装服务器版本

![openSUSE-server](https://wp-contents.netlify.com/2019/03/openSUSE_server.png)

即将安装的软件

![openSUSE-software](https://wp-contents.netlify.com/2019/03/openSUSE_software.png)

创建管理员用户账户

![openSUSE-user](https://wp-contents.netlify.com/2019/03/openSUSE_user.png)

### 安装 Ubuntu

开机进入安装界面后，首先选择安装过程中使用的语言，这里选择英语

![choose-english](https://wp-contents.netlify.com/2019/01/Bionic/01.png)

选择键盘布局

![](https://wp-contents.netlify.com/2019/01/Bionic/02.png)

安装 Ubuntu

![](https://wp-contents.netlify.com/2019/01/Bionic/03.png)

配置网络连接

![](https://wp-contents.netlify.com/2019/01/Bionic/04.png)

是否配置代理，选择否

![](https://wp-contents.netlify.com/2019/01/Bionic/05.png)

配置远程镜像位置

![](https://wp-contents.netlify.com/2019/01/Bionic/06.png)

文件系统设置

![](https://wp-contents.netlify.com/2019/01/Bionic/07.png)

VBox 指定的磁盘

![](https://wp-contents.netlify.com/2019/01/Bionic/08.png)

确认磁盘的设置

![](https://wp-contents.netlify.com/2019/01/Bionic/09.png)

再次确认磁盘的设置，一旦确认就会开始格式化磁盘，不可逆转

![](https://wp-contents.netlify.com/2019/01/Bionic/10.png)

用户管理员账户配置

![](https://wp-contents.netlify.com/2019/01/Bionic/11.png)

导入 SSH key

![](https://wp-contents.netlify.com/2019/01/Bionic/12.png)

服务器配置

![](https://wp-contents.netlify.com/2019/01/Bionic/13.png)

等待安装系统

![](https://wp-contents.netlify.com/2019/01/Bionic/14.png)

系统安装完成

![](https://wp-contents.netlify.com/2019/01/Bionic/15.png)
