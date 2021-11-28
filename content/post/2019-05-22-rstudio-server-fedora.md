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
  - R 语言
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


[^ip-port]: http://docs.rstudio.com/ide/server-pro/access-and-security.html#network-port-and-address
