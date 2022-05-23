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

刘志进实验室有很多免费音乐，支持外链，可以插入博客 <https://music.liuzhijin.cn/>

# 常用软件


``` bash
# 办公软件
brew install --cask notion jasp
brew install --cask adobe-creative-cloud


# 视频编辑器 https://www.openshot.org/zh-hans/
# [openshot-video-editor](https://github.com/OpenShot/openshot-qt)
brew install --cask openshot-video-editor

# https://github.com/mltframework/shotcut
brew install --cask shotcut

# https://github.com/blender/blender
# https://www.blender.org/
brew install --cask blender
# https://www.blackmagicdesign.com/products/davinciresolve/

# Github CLI 命令行工具
brew install tig tree
brew install gh gnupg

# LaTeX 代码块样式
# https://www.ctan.org/pkg/codebox

# 矢量图形编程语言 [asymptote](https://asymptote.sourceforge.io/)
# https://asymptote.sourceforge.io/asymptote.pdf
# https://ctan.org/pkg/asymptote
brew install asymptote

# UML 统一建模语言 [plantuml](https://plantuml.com/)
brew install plantuml

brew install --cask visual-paradigm-ce

# Data science platform
brew install --cask rapidminer-studio data-science-studio
# orange 数据挖掘 https://orangedatamining.com/
# 每一个操作都是一个组件，将组件连接起来就是工作流，可视化数据编程
# 是开源的 https://github.com/biolab/orange3
brew install --cask orange

# Data visualization software 或 BI 工具 如 Qlik
brew install --cask tableau 
```

# 绘图软件 

## gnuplot

[gnuplot](http://www.gnuplot.info/) 是开源的绘图软件，不像 gimp，它是命令行驱动。

```bash
brew install gnuplot
```

将下面的命令放入文件 `~/.gnuplot` 自定义字体

```
set term qt font "Noto Sans"
```

查看本机安装的字体

```bash
fc-list : family | sort
```


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

