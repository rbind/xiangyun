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
description: "软件环境配置是个既麻烦又耗时的苦力活，笔者曾经在 Windows 上折腾多年，换过几次电脑，工作之后，转向 MacOS 系统，又开始折腾，人生苦短，现收集整理出来，以后遇到新的坑也会填上来，尽量节省一些不必要的重复折腾，以期利己利人。"
---


# 基础软件

- 命令行工具 [Xcode](https://developer.apple.com/download/all/)

- 软件包管理工具 [brew](https://mirrors.tuna.tsinghua.edu.cn/help/homebrew/)

# 文本编辑

通用代码文本集成开发编辑环境 IDE 

```bash
brew install --cask visual-studio-code 
brew install --cask atom
```

文本编辑和转化工具

```bash
brew install --cask lyx
brew install --cask typora
brew install --cask calibre
brew install pandoc hugo
```

运行 LyX 内置的 knitr 模版，需要一些 LaTeX 包

```r
tinytex::tlmgr_install(c('palatino', 'babel-english', 'mathpazo'))
```

安装中文字体

```bash
brew tap homebrew/cask-fonts
brew install --cask font-noto-sans-cjk-sc font-noto-serif-cjk-sc
brew install --cask font-alegreya-sans-sc font-alegreya-sc
```

安装英文字体

```bash
# 用于 RStudio IDE 内的代码编辑器
brew install --cask font-fira-code
# 等宽字体
brew install font-inconsolata
# dejavu/liberation/fira 等系列字体
brew install font-dejavu font-liberation
brew install font-fira-sans font-fira-mono font-fira-code 
brew install font-open-sans font-open-sans-condensed
# 思源英文字体
brew install --cask font-source-code-pro 
brew install --cask font-source-sans-pro 
brew install --cask font-source-serif-pro
# 用于终端显示
brew install --cask font-source-code-pro-for-powerline
# 漫画字体
brew install --cask font-xkcd
# 表情字体
brew install --cask font-noto-emoji font-noto-color-emoji 
# Windows 系统字体
brew install --cask font-arial font-andale-mono
```

# 图像视频

```bash
brew install ghostscript imagemagick optipng graphviz
brew install ffmpeg gifski
brew install --cask drawio inkscape gimp
brew install --cask zy-player
brew install --cask iina
```


# 常用软件


> 解压、下载软件

```bash
brew install --cask rar
brew install --cask free-download-manager
```

> 数据库管理

```bash
# 免费社区版本
brew install --cask dbeaver-community
```

> Python 和 Java 开发环境

```bash
brew install --cask pycharm-ce intellij-idea-ce
```

> 空间数据分析 QGIS 

```bash
brew install --cask qgis
```

> 统计软件

```bash
brew install jags
brew install --cask jasp
brew install --cask julia
```

> 办公软件

```bash
brew install --cask microsoft-office
brew install --cask zoom
brew install --cask tencent-meeting
brew install --cask google-chrome
brew install --cask notion
brew install --cask slack
brew install --cask adobe-acrobat-reader
brew install --cask adobe-creative-cloud
```


> Github 相关

```bash
# Github CLI 命令行工具
brew install tig tree
brew install gh gnupg
brew install --cask github dropbox
```

> 虚拟化相关

```bash
brew install --cask vmware-fusion
brew install --cask virtualbox
brew install --cask docker 
```


# R 和 RStudio 软件

```bash
brew install --cask r xquartz
brew install --cask rstudio
```

设置 R 软件的语言为英文[^r-app-en]，避免一些不必要的编码问题，中文翻译不是很好，此外，看英文最好！

```bash
defaults write org.R-project.R force.LANG en_US.UTF-8
```

[^r-app-en]: [Internationalization of the R.app](https://cran.r-project.org/bin/macosx/RMacOSX-FAQ.html#Internationalization-of-the-R_002eapp)


安装一些 R 包需要的系统依赖

```bash
brew install glpk
brew install clp
brew install udunits gdal
brew install v8
brew install apache-arrow
```

安装完 apache-arrow 后，固定下来

```bash
brew pin apache-arrow 
```

安装 orca 将 plotly 绘制的交互式动态图形转化为静态的 SVG/PDF 格式矢量图形

```bash
brew install --cask orca
```

安装 phantomjs 用于 **webshot** 包

```bash
brew install --cask phantomjs
```

`webshot::install_phantomjs()` 将动态图形截图放在书里


#  R 包与 Java 开发环境

```bash
# 推荐
brew install openjdk@11
```

配置 JDK

```bash
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

```
export SPARK_VERSION=3.1.1
export HADOOP_VERSION=3.2
export SPARK_HOME=/opt/spark/spark-3.1.1-bin-hadoop3.2
```

推荐从清华镜像站点下载 Spark 环境

```bash
sudo mkdir -p /opt/spark/
tar -xzf spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz -C /opt/spark/
sudo chown -R $(whoami):admin /opt/spark/
```


# R 包与 OpenMP

目前，发现 R 包 **data.table**、**RandomFields** 和 **RandomFieldsUtils** 需启用 OpenMP 从源码编译才能获得共享内存的多线程并行计算的能力。

从源码安装 [data.table](https://github.com/fxcoudert/gfortran-for-macOS/releases)

```bash
brew install pkg-config # 检查和发现 zlib
brew install libomp # OpenMP
```

参考 <https://mac.r-project.org/openmp/> 文档，在 `~/.R/Makevars` 添加两行即可。

    CPPFLAGS += -Xclang -fopenmp
    LDFLAGS += -lomp



# Rmpi 包和 open-mpi

先安装外部软件依赖

```bash
brew install open-mpi
```
```r
install.packages('Rmpi', type = 'source')
```
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
```

# stringi 包和 icu4c

安装 icu4c

```bash
brew install icu4c
```

配置环境变量

```bash
# brew 安装的 icu4c 优先
echo 'export PATH="/usr/local/opt/icu4c/bin:$PATH"' >> ~/.zshrc
echo 'export PATH="/usr/local/opt/icu4c/sbin:$PATH"' >> ~/.zshrc

# 用于 C++ 编译器找到 icu4c
echo 'export LDFLAGS="-L/usr/local/opt/icu4c/lib"' >> ~/.zshrc
echo 'export CPPFLAGS="-I/usr/local/opt/icu4c/include"' >> ~/.zshrc

# 用于 pkg-config 找到 icu4c 
echo 'export PKG_CONFIG_PATH="/usr/local/opt/icu4c/lib/pkgconfig"' >> ~/.zshrc
```

如果用 brew 安装了新版本的 gcc 编译器，在安装需要启用 gcc 编译链接的 R 包时，出现如下类似警告[^gfortran-warn]：

```
ld: warning: directory not found for option '-L/usr/local/lib/gcc/x86_64-apple-darwin13.0.0/4.8.2'
```

设置 gfortran 库路径，当前安装的 gcc-11

```
FLIBS = -L/usr/local/Cellar/gcc/11.2.0/lib/gcc/11 -lgfortran -lquadmath -lm
```

[^gfortran-warn]: [Mac OS X R error "ld: warning: directory not found for option"](https://stackoverflow.com/questions/35999874/mac-os-x-r-error-ld-warning-directory-not-found-for-option)


# 用 miniconda 配置 Python 虚拟环境

`~/.condarc` 指定虚拟环境所在目录

```yaml
envs_dirs:
  - /opt/miniconda-virtualenvs/
```

详见 miniconda [官方文档](https://docs.conda.io/en/latest/miniconda.html)

```bash
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


```bash
# 指定安装路径和 Python 版本
conda create -p /opt/miniconda-virtualenvs/r-reticulate python=3.7
# 移除虚拟环境
conda env remove -p /opt/miniconda-virtualenvs/r-reticulate
# 更新 miniconda
conda update conda
```


# 用 virtualenv 配置 Python 虚拟环境

安装 virtualenv

```bash
brew install virtualenv
```

用 virtualenv 创建虚拟环境，虚拟环境的存放路径是 `/opt/.virtualenvs/r-tensorflow`，所以名字就是 `r-tensorflow`

```bash
# 准备虚拟环境萼存放地址
sudo mkdir -p /opt/.virtualenvs/r-tensorflow
sudo chown -R $(whoami):staff /opt/.virtualenvs/r-tensorflow
# 方便后续复用
export RETICULATE_PYTHON_ENV=/opt/.virtualenvs/r-tensorflow
# 创建虚拟环境
virtualenv -p /usr/local/bin/python3 $RETICULATE_PYTHON_ENV
```

查看虚拟环境中 Python 版本

```bash
python -V
```

激活虚拟环境

```bash
source $RETICULATE_PYTHON_ENV/bin/activate
# 取消激活
deactivate
```

进入虚拟环境后，从 requirements.txt 安装 Python 模块

```bash
pip install -r requirements.txt
```

查看已经安装的 Python 模块

```bash
pip list --format=columns
```

在文件 `.Rprofile` 里设置环境变量 `RETICULATE_PYTHON` 和 `RETICULATE_PYTHON_ENV`，这样 **reticulate** 包就能发现和使用它了。

```bash
Sys.setenv(RETICULATE_PYTHON="/usr/local/bin/python3")
Sys.setenv(RETICULATE_PYTHON_ENV="/opt/.virtualenvs/r-tensorflow")
```

如果希望打开终端就进入虚拟环境，可以在 .zshrc 文件中添加两行

```bash
export RETICULATE_PYTHON_ENV=/opt/.virtualenvs/r-tensorflow
source $RETICULATE_PYTHON_ENV/bin/activate
```

> 注意
>
> 要使用从 brew 安装的 Python3 即 `/usr/local/bin/python3` 而不是 MacOS 系统自带的 Python3，即 `/usr/bin/python3`

在 RStudio IDE 里配置好 Python 及其虚拟环境，应该能看到

```r
Sys.getenv("RETICULATE_PYTHON")
```
```
[1] "/usr/local/bin/python3"
```

```r
reticulate::py_discover_config()
```
```
python:         /usr/local/bin/python3
libpython:      /usr/local/opt/python@3.9/Frameworks/Python.framework/Versions/3.9/lib/python3.9/config-3.9-darwin/libpython3.9.dylib
pythonhome:     /usr/local/Cellar/python@3.9/3.9.7/Frameworks/Python.framework/Versions/3.9
version:        3.9.7 (default, Sep  3 2021, 12:37:55)  [Clang 12.0.5 (clang-1205.0.22.9)]
numpy:          /usr/local/lib/python3.9/site-packages/numpy
numpy_version:  1.21.2

NOTE: Python version was forced by RETICULATE_PYTHON
```

# Gollum 知识管理


用 [Gollum](https://github.com/gollum/gollum) 创建 wiki 随时记下个人笔记，gollum 源自电影《指环王》里的角色咕噜。系统环境如下

```bash
gem env
```
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
```

将 `/Users/你的账户名/.local/share/gem/ruby/2.6.0/bin` 添加到 PATH 变量里，修改修改镜像源，加快下载速度

```bash
gem sources --add https://mirrors.tuna.tsinghua.edu.cn/rubygems/ --remove https://rubygems.org/
```

安装好 Xcode 库后，安装一些编译环境，比如 cmake，一些 [gollum](https://github.com/gollum/gollum) 依赖的库需要编译安装，这些库是用 cmake 创建的项目。更新自带的库

```bash
sudo gem update
```

然后安装 gollum

```bash
brew install cmake pkg-config
gem install --user-install gollum
```

注意⚠️，由于权限问题，不能安装到系统目录，实际上，也建议安装到非系统目录，即当前账户下的目录，截止 2021-03-06 安装的最新稳定版本 gollum 5.2.1。创建一个目录，并用 git 初始化， gollum 是用 git 来做版本管理的，所以要先初始化，然后使用 gollum 服务，启动 wiki

```bash
gollum /path/to/wiki
```

最后，预览 Wiki 网页，打开 <http://localhost:4567>，gollum 默认使用 4567 端口号，如果分支使用 main， 那么启动的时候要加参数 `--ref` 指定为 main

```bash
gollum --ref main --emoji --allow-uploads=dir /path/to/wiki
```

> 注意
>
> 先想好目录结构，不然会很乱，以后改起来就麻烦了！
