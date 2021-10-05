---
title: CmdStan 使用入门
author: 黄湘云
date: '2019-05-02'
slug: intro-to-cmdstan
categories:
  - 统计软件
tags:
  - Stan
  - MCMC
thumbnail: /img/cmdstan.svg
draft: true
description: "基于Docker的完全可重复的配置过程，意义在于省去 Stan 在Windows下配置的麻烦，以 CmdStan 为例介绍贝叶斯计算框架 Stan 的安装和使用。Stan 问世的时间比 TensorFlow Probability 早很多年，这么些年了，影响力远不如 TensorFlow Probability，笔者在多个场合提及 Stan 都没有人听说过。"
---


> **注意**
> 
> 珍爱生命，远离 Windows ！！！


## 软件环境 

> 下面给出复现的详细信息，写这么多就是希望5年后不做任何改动完美复现本文结果，这也将作为其他Stan相关文章的复现基础！！

- Git Bash 2.22.0
- Docker 18.03.0-ce
- CmdStan 2.20.0

下面是复现文章内容的步骤，如何下载安装 [Git](https://git-scm.com/) 和 [Docker](https://www.docker.com/) 请见各自官网

### 1. 在开始菜单找到 Git Bash，打开后输入如下命令下载 CmdStan

```bash
cmdstan_version=2.20.0 && \
url_prefix="https://github.com/stan-dev/cmdstan/releases/download" && \
curl -fLo ~/Desktop/cmdstan-${cmdstan_version}.tar.gz \
  ${url_prefix}/v${cmdstan_version}/cmdstan-${cmdstan_version}.tar.gz && \
tar -xzf ~/Desktop/cmdstan-${cmdstan_version}.tar.gz && \
cd ~/Desktop/cmdstan-${cmdstan_version}
```

### 2. 在容器中编译 CmdStan

下载镜像，启动并进入容器，此处将 CmdStan 解压后的目录挂载到容器的根目录下

```bash
docker pull debian:buster
winpty docker run --rm -it --name=cmdstan -v "/${PWD}://root" debian:buster bash
```

配置就近的清华镜像源，下载编译依赖，如 GCC 等编译工具

```bash
apt-get update && \
apt-get install -y apt-transport-https ca-certificates && \
mv /etc/apt/sources.list /etc/apt/sources.list.bak && \
echo "
# 默认注释了源码镜像以提高 apt update 速度，如有需要可自行取消注释
deb https://mirrors.tuna.tsinghua.edu.cn/debian/ buster main contrib non-free
# deb-src https://mirrors.tuna.tsinghua.edu.cn/debian/ buster main contrib non-free
deb https://mirrors.tuna.tsinghua.edu.cn/debian/ buster-updates main contrib non-free
# deb-src https://mirrors.tuna.tsinghua.edu.cn/debian/ buster-updates main contrib non-free
deb https://mirrors.tuna.tsinghua.edu.cn/debian/ buster-backports main contrib non-free
# deb-src https://mirrors.tuna.tsinghua.edu.cn/debian/ buster-backports main contrib non-free
deb https://mirrors.tuna.tsinghua.edu.cn/debian-security buster/updates main contrib non-free
# deb-src https://mirrors.tuna.tsinghua.edu.cn/debian-security buster/updates main contrib non-free
" >> /etc/apt/sources.list && \
apt-get update && \
apt-get install -y make gcc g++ gfortran && \
cd /root && make build
```

最后显示

```
--- CmdStan v2.20.0 built ---
```

中间没有任何警告和错误，表示编译成功！！在 CmdStan 主目录下，生成两个可执行文件 

- `stanc` Stan 编译器，将 Stan 代码翻译成 C++ 代码
- `stansummary` 后验分析器，分析 Stan 程序运行的结果（保存在逗号分隔的 csv 文件中），报告每个参数的均值、标准差、分位数、`$\hat{R}$` 以及其它信息，详见下文的例子。

下一次进入容器，只需

```bash
winpty docker exec -it cmdstan bash
```

### 3. 打包 CmdStan 环境

既然， CmdStan 环境配置好了，我们打包一下方便以后使用，或者分享给其他人使用

```bash
docker commit -a "Xiangyun Huang <xiangyunfaith@outlook.com>" \
  -m "Docker Image for CmdStan" f8bb7e701514 xiangyunhuang/cmdstan
```

其中，`f8bb7e701514` 是容器 ID， `xiangyunhuang/cmdstan` 是镜像标签，其中 xiangyunhuang 是我的 [Docker Hub](https://hub.docker.com/) 登陆名，cmdstan 是仓库名，TAG 默认是 latest，你当然可以自定义一个

最后，登陆并将镜像推送到 Docker Hub，这样以后重现本文结果，只需将镜像拉下来

```bash
echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin
docker push xiangyunhuang/cmdstan
```

### 4. 测试配置环境

伯努利分布模型： Y 服从 0-1 分布，观测数据共10个，现在需要估计其参数 `$\theta$`

|  0  |   1   |
| :-: | :---: |
| `$1-\theta$` | `$\theta$` |

```
├── bernoulli  编译后生成的可执行文件
├── bernoulli.d
├── bernoulli.data.json 数据文件 JSON 格式
├── bernoulli.data.R 数据文件 R 代码
├── bernoulli.hpp   编译后生成的头文件
└── bernoulli.stan  模型文件
```

JSON 格式数据文件

```bash
cat examples/bernoulli/bernoulli.data.json
```
```
{
    "N" : 10,
    "y" : [0,1,0,0,0,0,0,0,0,1]
}
```

R代码格式数据文件

```bash
cat bernoulli.data.R
```
```r
N <- 10
y <- c(0,1,0,0,0,0,0,0,0,1)
```

Stan 代码文件

```bash
cat examples/bernoulli/bernoulli.stan
```
```
// 定义数据
data {
  int<lower=0> N;
  int<lower=0,upper=1> y[N];
}
// 定义参数
parameters {
  real<lower=0,upper=1> theta;
}
// 定义模型结构
model {
  theta ~ beta(1,1);
  for (n in 1:N)
    y[n] ~ bernoulli(theta);
}
// 向量化模型块
model {
  theta ~ beta(1,1);  // uniform prior on interval 0,1
  y ~ bernoulli(theta);
}
```

编译 CmdStan 自带的推断伯努利分布的参数的例子，首先将 `bernoulli.stan` 文件翻译成 C++ 文件，然后编译成可执行文件 `bernoulli`

```bash
make examples/bernoulli/bernoulli
```
```
--- Translating Stan model to C++ code ---
bin/stanc  --o=examples/bernoulli/bernoulli.hpp examples/bernoulli/bernoulli.sta
n
Model name=bernoulli_model
Input file=examples/bernoulli/bernoulli.stan
Output file=examples/bernoulli/bernoulli.hpp

--- Compiling, linking C++ code ---
g++ -std=c++1y -pthread -Wno-sign-compare     -O3 -I src -I stan/src -I stan/lib
/stan_math/ -I stan/lib/stan_math/lib/eigen_3.3.3 -I stan/lib/stan_math/lib/boos
t_1.69.0 -I stan/lib/stan_math/lib/sundials_4.1.0/include    -DBOOST_RESULT_OF_U
SE_TR1 -DBOOST_NO_DECLTYPE -DBOOST_DISABLE_ASSERTS -DBOOST_PHOENIX_NO_VARIADIC_E
XPRESSION     -c  -x c++ -o examples/bernoulli/bernoulli.o examples/bernoulli/be
rnoulli.hpp
g++ -std=c++1y -pthread -Wno-sign-compare     -O3 -I src -I stan/src -I stan/lib
/stan_math/ -I stan/lib/stan_math/lib/eigen_3.3.3 -I stan/lib/stan_math/lib/boos
t_1.69.0 -I stan/lib/stan_math/lib/sundials_4.1.0/include    -DBOOST_RESULT_OF_U
SE_TR1 -DBOOST_NO_DECLTYPE -DBOOST_DISABLE_ASSERTS -DBOOST_PHOENIX_NO_VARIADIC_E
XPRESSION                   src/cmdstan/main.o stan/lib/stan_math/lib/sundials_4
.1.0/lib/libsundials_nvecserial.a stan/lib/stan_math/lib/sundials_4.1.0/lib/libs
undials_cvodes.a stan/lib/stan_math/lib/sundials_4.1.0/lib/libsundials_idas.a  e
xamples/bernoulli/bernoulli.o -o examples/bernoulli/bernoulli
```

编译过程中间文件 bernoulli.d 的内容

```bash
head -n 10 bernoulli.d
```
```
examples/bernoulli/bernoulli.o examples/bernoulli/bernoulli: \
 examples/bernoulli/bernoulli.hpp examples/bernoulli/bernoulli.hpp \
 stan/src/stan/model/model_header.hpp stan/lib/stan_math/stan/math.hpp \
 stan/lib/stan_math/stan/math/rev/mat.hpp \
 stan/lib/stan_math/stan/math/rev/core.hpp \
 stan/lib/stan_math/stan/math/rev/core/autodiffstackstorage.hpp \
 stan/lib/stan_math/stan/math/memory/stack_alloc.hpp \
 stan/lib/stan_math/stan/math/prim/scal/meta/likely.hpp \
 stan/lib/stan_math/stan/math/rev/core/build_vari_array.hpp \
 stan/lib/stan_math/stan/math/prim/mat/fun/Eigen.hpp \
...
```

给定数据文件，调用编译好的可执行文件 `bernoulli`，开始采样过程，采样完成后，采样结果会自动存放在当前目录下的 `output.csv` 文件中 

```bash
examples/bernoulli/bernoulli sample data file=examples/bernoulli/bernoulli.data.R
```
```
method = sample (Default)
  sample
    num_samples = 1000 (Default)
    num_warmup = 1000 (Default)
    save_warmup = 0 (Default)
    thin = 1 (Default)
    adapt
      engaged = 1 (Default)
      gamma = 0.050000000000000003 (Default)
      delta = 0.80000000000000004 (Default)
      kappa = 0.75 (Default)
      t0 = 10 (Default)
      init_buffer = 75 (Default)
      term_buffer = 50 (Default)
      window = 25 (Default)
    algorithm = hmc (Default)
      hmc
        engine = nuts (Default)
          nuts
            max_depth = 10 (Default)
        metric = diag_e (Default)
        metric_file =  (Default)
        stepsize = 1 (Default)
        stepsize_jitter = 0 (Default)
id = 0 (Default)
data
  file = examples/bernoulli/bernoulli.data.R
init = 2 (Default)
random
  seed = 1136067858
output
  file = output.csv (Default)
  diagnostic_file =  (Default)
  refresh = 100 (Default)

Gradient evaluation took 0.000104 seconds
1000 transitions using 10 leapfrog steps per transition would take 1.04 seconds.
Adjust your expectations accordingly!

Iteration:    1 / 2000 [  0%]  (Warmup)
Iteration:  100 / 2000 [  5%]  (Warmup)
Iteration:  200 / 2000 [ 10%]  (Warmup)
Iteration:  300 / 2000 [ 15%]  (Warmup)
Iteration:  400 / 2000 [ 20%]  (Warmup)
Iteration:  500 / 2000 [ 25%]  (Warmup)
Iteration:  600 / 2000 [ 30%]  (Warmup)
Iteration:  700 / 2000 [ 35%]  (Warmup)
Iteration:  800 / 2000 [ 40%]  (Warmup)
Iteration:  900 / 2000 [ 45%]  (Warmup)
Iteration: 1000 / 2000 [ 50%]  (Warmup)
Iteration: 1001 / 2000 [ 50%]  (Sampling)
Iteration: 1100 / 2000 [ 55%]  (Sampling)
Iteration: 1200 / 2000 [ 60%]  (Sampling)
Iteration: 1300 / 2000 [ 65%]  (Sampling)
Iteration: 1400 / 2000 [ 70%]  (Sampling)
Iteration: 1500 / 2000 [ 75%]  (Sampling)
Iteration: 1600 / 2000 [ 80%]  (Sampling)
Iteration: 1700 / 2000 [ 85%]  (Sampling)
Iteration: 1800 / 2000 [ 90%]  (Sampling)
Iteration: 1900 / 2000 [ 95%]  (Sampling)
Iteration: 2000 / 2000 [100%]  (Sampling)

 Elapsed Time: 0.009716 seconds (Warm-up)
               0.059077 seconds (Sampling)
               0.068793 seconds (Total)
```

查看伯努利分布参数的估计结果

```bash
bin/stansummary output.csv
```
```
Inference for Stan model: bernoulli_model
1 chains: each with iter=(1000); warmup=(0); thin=(1); 1000 iterations saved.

Warmup took (0.0097) seconds, 0.0097 seconds total
Sampling took (0.059) seconds, 0.059 seconds total

                Mean     MCSE   StdDev     5%   50%   95%  N_Eff  N_Eff/s    R_hat
lp__            -7.3  4.0e-02  7.8e-01   -9.1  -7.0  -6.8    372     6305  1.0e+00
accept_stat__   0.92  4.1e-03  1.3e-01   0.62  0.97   1.0    996    16856  1.0e+00
stepsize__      0.87  2.8e-15  2.8e-15   0.87  0.87  0.87    1.0       17  1.0e+00
treedepth__      1.4  1.6e-02  4.9e-01    1.0   1.0   2.0    916    15507  1.0e+00
n_leapfrog__     2.5  4.4e-02  1.3e+00    1.0   3.0   3.0    847    14341  1.0e+00
divergent__     0.00  0.0e+00  0.0e+00   0.00  0.00  0.00    500     8464     -nan
energy__         7.8  5.2e-02  1.1e+00    6.8   7.5   9.9    426     7203  1.0e+00
theta           0.25  7.7e-03  1.2e-01  0.075  0.24  0.47    261     4414  1.0e+00

Samples were drawn using hmc with nuts.
For each parameter, N_Eff is a crude measure of effective sample size,
and R_hat is the potential scale reduction factor on split chains (at
convergence, R_hat=1).
```

采样器         |    参数        |     描述
:------------- | :------------- | :-------------
NUTS     |  `accept_stat__`  |Metropolis acceptance probability averaged over samples in the slice
NUTS     |  `stepsize__`     |Integrator step size
NUTS     |  `treedepth__`    |Tree depth
NUTS     |  `n_leapfrog__`   |Number of leapfrog calculations
NUTS     |  `divergent__`    |1 if trajectory diverged
NUTS     |  `energy__`       |Hamiltonian value


采样器         |    参数        |     描述
:------------- | :------------- | :-------------
HMC      |  `accept_stat__` | Metropolis acceptance probability
HMC      |  `stepsize__`     |Integrator step size
HMC      |  `int_time_`      |Total integration time
NUTS     |  `energy__`       |Hamiltonian value

从后验分布中抽样，调用 Stan 优化器迭代求解后验模 posterior modes 即模型参数的贝叶斯估计值，使用方式和前面一致

```bash
examples/bernoulli/bernoulli optimize data file=examples/bernoulli/bernoulli.data.R
```
```
method = optimize
  optimize
    algorithm = lbfgs (Default)
      lbfgs
        init_alpha = 0.001 (Default)
        tol_obj = 9.9999999999999998e-13 (Default)
        tol_rel_obj = 10000 (Default)
        tol_grad = 1e-08 (Default)
        tol_rel_grad = 10000000 (Default)
        tol_param = 1e-08 (Default)
        history_size = 5 (Default)
    iter = 2000 (Default)
    save_iterations = 0 (Default)
id = 0 (Default)
data
  file = examples/bernoulli/bernoulli.data.R
init = 2 (Default)
random
  seed = 1154395342
output
  file = output.csv (Default)
  diagnostic_file =  (Default)
  refresh = 100 (Default)

Initial log joint probability = -7.36952
    Iter      log prob        ||dx||      ||grad||       alpha      alpha0  # evals  Notes
       5      -5.00402     0.0021254    4.2608e-05           1           1        8
Optimization terminated normally:
  Convergence detected: relative gradient magnitude is below tolerance
```

CmdStan 还包含自动微分变分推断优化 Automatic Differentiation Variational Inference 简称 ADVI

```bash
examples/bernoulli/bernoulli variational data file=examples/bernoulli/bernoulli.data.R
```
```
method = variational
  variational
    algorithm = meanfield (Default)
      meanfield
    iter = 10000 (Default)
    grad_samples = 1 (Default)
    elbo_samples = 100 (Default)
    eta = 1 (Default)
    adapt
      engaged = 1 (Default)
      iter = 50 (Default)
    tol_rel_obj = 0.01 (Default)
    eval_elbo = 100 (Default)
    output_samples = 1000 (Default)
id = 0 (Default)
data
  file = examples/bernoulli/bernoulli.data.R
init = 2 (Default)
random
  seed = 1154685110
output
  file = output.csv (Default)
  diagnostic_file =  (Default)
  refresh = 100 (Default)

------------------------------------------------------------
EXPERIMENTAL ALGORITHM:
  This procedure has not been thoroughly tested and may be unstable
  or buggy. The interface is subject to change.
------------------------------------------------------------

实验性的算法，还没有全面测试，可能有八哥！

Gradient evaluation took 7.7e-05 seconds
1000 transitions using 10 leapfrog steps per transition would take 0.77 seconds.
Adjust your expectations accordingly!

Begin eta adaptation.
Iteration:   1 / 250 [  0%]  (Adaptation)
Iteration:  50 / 250 [ 20%]  (Adaptation)
Iteration: 100 / 250 [ 40%]  (Adaptation)
Iteration: 150 / 250 [ 60%]  (Adaptation)
Iteration: 200 / 250 [ 80%]  (Adaptation)
Success! Found best value [eta = 1] earlier than expected.

Begin stochastic gradient ascent.
  iter             ELBO   delta_ELBO_mean   delta_ELBO_med   notes
   100           -6.129             1.000            1.000
   200           -6.267             0.511            1.000
   300           -6.275             0.341            0.022
   400           -6.231             0.258            0.022
   500           -6.145             0.209            0.014
   600           -6.229             0.176            0.014
   700           -6.210             0.152            0.014
   800           -6.253             0.133            0.014
   900           -6.263             0.119            0.007   MEDIAN ELBO CONVERGED

Drawing a sample of size 1000 from the approximate posterior...
COMPLETED.
```

变分方法估计参数的结果

```
Inference for Stan model: bernoulli_model
1 chains: each with iter=(1001); warmup=(0); thin=(0); 1001 iterations saved.

Warmup took (0.00) seconds, 0.00 seconds total
Sampling took (0.00) seconds, 0.00 seconds total

           Mean     MCSE  StdDev     5%    50%       95%  N_Eff  N_Eff/s    R_hat
lp__       0.00  0.0e+00    0.00   0.00   0.00   0.0e+00    500      inf     -nan
log_p__    -7.3  2.9e-02    0.82   -8.9   -7.0  -6.8e+00    818      inf  1.0e+00
log_g__   -0.51  2.4e-02    0.70   -1.9  -0.23  -2.1e-03    886      inf  1.0e+00
theta      0.24  4.1e-03    0.13  0.077   0.22   4.8e-01    942      inf  1.0e+00

Samples were drawn using meanfield with .
For each parameter, N_Eff is a crude measure of effective sample size,
and R_hat is the potential scale reduction factor on split chains (at
convergence, R_hat=1).
```

## 命令行参数

```
examples/bernoulli/bernoulli method=sample help
```
```
sample
  Bayesian inference with Markov Chain Monte Carlo
  Valid subarguments: num_samples, num_warmup, save_warmup, thin, adapt, algorithm

Usage: examples/bernoulli/bernoulli <arg1> <subarg1_1> ... <subarg1_m> ... <arg_n> <subarg_n_1> ... <
subarg_n_m>

Begin by selecting amongst the following inference methods and diagnostics,
  sample      Bayesian inference with Markov Chain Monte Carlo
  optimize    Point estimation
  variational  Variational inference
  diagnose    Model diagnostics
  generate_quantities  Generate quantities of interest

Or see help information with
  help        Prints help
  help-all    Prints entire argument tree

Additional configuration available by specifying
  id          Unique process identifier
  data        Input data options
  init        Initialization method: "x" initializes randomly between [-x, x], "0" initializes to 0,
anything else identifies a file of values
  random      Random number configuration
  output      File output options

See examples/bernoulli/bernoulli <arg1> [ help | help-all ] for details on individual arguments.
```

进一步地，如何配置随机数种子

```
examples/bernoulli/bernoulli method=sample random help
```
```
random
  Random number configuration
  Valid subarguments: seed
```

所以重现上述变分推断的结果只需抽样的时候设置随机数种子

```
examples/bernoulli/bernoulli variational random seed=1154685110 data file=examples/bernoulli/bernoulli.data.R
```


## 结果解释

从频率派的观点来看，在这个例子中，关于 `$\theta$` 的极大似然估计就是矩估计，即 0.2。可从对数似然函数简单推导

`$$
\begin{align}
\log Lik 
&=\log\big[ (1-\theta)^{1-x_1}\theta^{x_1}\cdots(1-\theta)^{1-x_n}\theta^{x_n}\big] \\
&=\log\big[ (1-\theta)^{ n - \sum_{i = 1}^{n}x_{i}}\theta^{\sum_{i=1}^{n}x_{i}}\big] \\
&= k \log(1-\theta) + (n - k) \log(\theta), \quad \theta \in (0,1)
\end{align}
$$`

其中 `$k$` 是取 0 的个数，则 `$n-k$` 是取 1 的个数，上述对数似然函数关于 `$\theta$` 求导，获得极值点 

`$$
\hat{\theta}_{\mathrm{mle}} = \frac{n-k}{n} = \frac{\sum_{i=1}^{n}x_{i}}{n} = \bar{x}
$$`

有的时候，似然函数不那么简单，不可以写出极大似然估计的解析表达式，所以更一般的方法是数值计算。即将参数 `$\theta$` 的估计问题转化为求一维非线性目标函数的极大值问题，可如下写个小程序优化目标函数

```r
loglik <- function(theta) {
  8*log(1-theta) + 2*log(theta)
}

optimize(loglik, lower = 0, upper = 1, maximum = TRUE)
```
```
$maximum
[1] 0.2

$objective
[1] -5.004
```

## 多线程支持

以上介绍的都是基于 CmdStan 的默认配置，下面介绍的部分是一些自定义操作，主要是如何启用多核编译和并行采样

```bash
touch make/local && echo "CXXFLAGS += -DSTAN_THREADS" >> make/local
make build
```

多线程用于支持 Stan 内置的高阶函数，如 `map_rect` 函数，运行时设置环境变量 `STAN_NUM_THREADS` 指定最多可用的线程数，而 `-1` 表示能用多少用多少，如果没有设置，就默认单线程。

### 1. 固定数据集

```r
set.seed(2018)
n <- 12
x <- rnorm(n)  
beta_0 <- 0.5
beta_1 <- 0.3
log.p <- beta_0 + beta_1 * x 
y <- rbinom(n, 1 , prob = exp(beta_0 + beta_1 * x)/(1 + exp(beta_0 + beta_1 * x)))
```

将获得的数据与Stan程序保存在同一目录下，文件 `LogisticRegression.data.R` 内容如下

```r
N <- 12
x <- c(-0.42298398, -1.54987816, -0.06442932,  0.27088135,  1.73528367, -0.26471121,
        2.09947070,  0.86335122, -0.61058715,  0.63705561, -0.64303470, -1.03002873)
y <- c(0, 0, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0)
```

文件 `LogisticRegression.stan` 内容如下

```
functions {
  vector lr(vector beta, vector theta, real[] x, int[] y) {
    real lp = bernoulli_logit_lpmf(y | beta[1] + to_vector(x) * beta[2]);
    return [lp]';
  }
}
data {
  int y[12];
  real x[12];
}
transformed data {
  // K = 3 shards
  int ys[3, 4] = { y[1:4], y[5:8], y[9:12] };
  real xs[3, 4] = { x[1:4], x[5:8], x[9:12] };
  vector[0] theta[3];
}
parameters {
  vector[2] beta;
}
model {
  beta ~ std_normal();
  target += sum(map_rect(lr, beta, theta, xs, ys));
}
```

### 2. 编译 Stan 程序

```bash
make examples/LogisticRegression/LogisticRegression
```
```
--- Translating Stan model to C++ code ---
bin/stanc  --o=examples/LogisticRegression/LogisticRegression.hpp examples/Logis
ticRegression/LogisticRegression.stan
Model name=LogisticRegression_model
Input file=examples/LogisticRegression/LogisticRegression.stan
Output file=examples/LogisticRegression/LogisticRegression.hpp

--- Compiling, linking C++ code ---
g++ -DSTAN_THREADS -std=c++1y -pthread -Wno-sign-compare     -O3 -I src -I stan/
src -I stan/lib/stan_math/ -I stan/lib/stan_math/lib/eigen_3.3.3 -I stan/lib/sta
n_math/lib/boost_1.69.0 -I stan/lib/stan_math/lib/sundials_4.1.0/include    -DBO
OST_RESULT_OF_USE_TR1 -DBOOST_NO_DECLTYPE -DBOOST_DISABLE_ASSERTS -DBOOST_PHOENI
X_NO_VARIADIC_EXPRESSION     -c  -x c++ -o examples/LogisticRegression/LogisticR
egression.o examples/LogisticRegression/LogisticRegression.hpp
g++ -DSTAN_THREADS -std=c++1y -pthread -Wno-sign-compare     -O3 -I src -I stan/
src -I stan/lib/stan_math/ -I stan/lib/stan_math/lib/eigen_3.3.3 -I stan/lib/sta
n_math/lib/boost_1.69.0 -I stan/lib/stan_math/lib/sundials_4.1.0/include    -DBO
OST_RESULT_OF_USE_TR1 -DBOOST_NO_DECLTYPE -DBOOST_DISABLE_ASSERTS -DBOOST_PHOENI
X_NO_VARIADIC_EXPRESSION                   src/cmdstan/main.o stan/lib/stan_math
/lib/sundials_4.1.0/lib/libsundials_nvecserial.a stan/lib/stan_math/lib/sundials
_4.1.0/lib/libsundials_cvodes.a stan/lib/stan_math/lib/sundials_4.1.0/lib/libsun
dials_idas.a  examples/LogisticRegression/LogisticRegression.o -o examples/Logis
ticRegression/LogisticRegression
```

### 3. 固定抽样的随机数种子

```bash
examples/LogisticRegression/LogisticRegression \
  sample random seed=1506552817 \
  data file=examples/LogisticRegression/LogisticRegression.data.R
```
```
method = sample (Default)
  sample
    num_samples = 1000 (Default)
    num_warmup = 1000 (Default)
    save_warmup = 0 (Default)
    thin = 1 (Default)
    adapt
      engaged = 1 (Default)
      gamma = 0.050000000000000003 (Default)
      delta = 0.80000000000000004 (Default)
      kappa = 0.75 (Default)
      t0 = 10 (Default)
      init_buffer = 75 (Default)
      term_buffer = 50 (Default)
      window = 25 (Default)
    algorithm = hmc (Default)
      hmc
        engine = nuts (Default)
          nuts
            max_depth = 10 (Default)
        metric = diag_e (Default)
        metric_file =  (Default)
        stepsize = 1 (Default)
        stepsize_jitter = 0 (Default)
id = 0 (Default)
data
  file = examples/LogisticRegression/LogisticRegression.data.R
init = 2 (Default)
random
  seed = 1506552817
output
  file = output.csv (Default)
  diagnostic_file =  (Default)
  refresh = 100 (Default)


Gradient evaluation took 0.000233 seconds
1000 transitions using 10 leapfrog steps per transition would take 2.33 seconds.
Adjust your expectations accordingly!


Iteration:    1 / 2000 [  0%]  (Warmup)
Iteration:  100 / 2000 [  5%]  (Warmup)
Iteration:  200 / 2000 [ 10%]  (Warmup)
Iteration:  300 / 2000 [ 15%]  (Warmup)
Iteration:  400 / 2000 [ 20%]  (Warmup)
Iteration:  500 / 2000 [ 25%]  (Warmup)
Iteration:  600 / 2000 [ 30%]  (Warmup)
Iteration:  700 / 2000 [ 35%]  (Warmup)
Iteration:  800 / 2000 [ 40%]  (Warmup)
Iteration:  900 / 2000 [ 45%]  (Warmup)
Iteration: 1000 / 2000 [ 50%]  (Warmup)
Iteration: 1001 / 2000 [ 50%]  (Sampling)
Iteration: 1100 / 2000 [ 55%]  (Sampling)
Iteration: 1200 / 2000 [ 60%]  (Sampling)
Iteration: 1300 / 2000 [ 65%]  (Sampling)
Iteration: 1400 / 2000 [ 70%]  (Sampling)
Iteration: 1500 / 2000 [ 75%]  (Sampling)
Iteration: 1600 / 2000 [ 80%]  (Sampling)
Iteration: 1700 / 2000 [ 85%]  (Sampling)
Iteration: 1800 / 2000 [ 90%]  (Sampling)
Iteration: 1900 / 2000 [ 95%]  (Sampling)
Iteration: 2000 / 2000 [100%]  (Sampling)

 Elapsed Time: 0.036979 seconds (Warm-up)
               0.07441 seconds (Sampling)
               0.111389 seconds (Total)
```

### 4. 输出结果，检验结果

```bash
bin/stansummary output.csv
```
```
Inference for Stan model: LogisticRegression_model
1 chains: each with iter=(1000); warmup=(0); thin=(1); 1000 iterations saved.

Warmup took (0.037) seconds, 0.037 seconds total
Sampling took (0.074) seconds, 0.074 seconds total

                Mean     MCSE   StdDev     5%   50%   95%  N_Eff  N_Eff/s    R_hat
lp__            -8.6  4.6e-02  9.8e-01    -10  -8.3  -7.6    451     6059  1.0e+00
accept_stat__   0.92  3.0e-03  1.0e-01   0.69  0.96   1.0   1209    16253  1.0e+00
stepsize__      0.84  4.5e-15  4.6e-15   0.84  0.84  0.84    1.0       13  1.0e+00
treedepth__      1.9  1.7e-02  5.3e-01    1.0   2.0   3.0    919    12352  1.0e+00
n_leapfrog__     4.1  1.1e-01  3.2e+00    1.0   3.0    11    907    12190  1.0e+00
divergent__     0.00  0.0e+00  0.0e+00   0.00  0.00  0.00    500     6720     -nan
energy__         9.5  6.7e-02  1.4e+00    7.9   9.2    12    419     5628  1.0e+00
beta[1]         0.27  1.9e-02  5.5e-01  -0.61  0.25   1.2    854    11472  1.0e+00
beta[2]         0.68  2.1e-02  5.5e-01  -0.15  0.65   1.6    663     8910  1.0e+00

Samples were drawn using hmc with nuts.
For each parameter, N_Eff is a crude measure of effective sample size,
and R_hat is the potential scale reduction factor on split chains (at
convergence, R_hat=1).
```

`$\hat{R}=1$`，序列的混合的好，平稳性也检验过，这个结果和真实值还是一致的，精度比起 <https://www.xiangyunhuang.com.cn/post/2019/06/19/logistic-distribution/> 差点，当然可以增加采样的间隔和迭代次数来提高精度。值得注意的是，对于这种简单模型，使用贝叶斯 MCMC 算法是不推荐的！

```bash
examples/LogisticRegression/LogisticRegression \
  sample num_samples=5000000 num_warmup=2500000 thin=5 \
  random seed=1506552817 \
  data file=examples/LogisticRegression/LogisticRegression.data.R
```

```
Iteration: 7498800 / 7500000 [ 99%]  (Sampling)
Iteration: 7498900 / 7500000 [ 99%]  (Sampling)
Iteration: 7499000 / 7500000 [ 99%]  (Sampling)
Iteration: 7499100 / 7500000 [ 99%]  (Sampling)
Iteration: 7499200 / 7500000 [ 99%]  (Sampling)
Iteration: 7499300 / 7500000 [ 99%]  (Sampling)
Iteration: 7499400 / 7500000 [ 99%]  (Sampling)
Iteration: 7499500 / 7500000 [ 99%]  (Sampling)
Iteration: 7499600 / 7500000 [ 99%]  (Sampling)
Iteration: 7499700 / 7500000 [ 99%]  (Sampling)
Iteration: 7499800 / 7500000 [ 99%]  (Sampling)
Iteration: 7499900 / 7500000 [ 99%]  (Sampling)
Iteration: 7500000 / 7500000 [100%]  (Sampling)

 Elapsed Time: 67.8867 seconds (Warm-up)
               193.23 seconds (Sampling)
               261.117 seconds (Total)
```
```
Inference for Stan model: LogisticRegression_model
1 chains: each with iter=(1000000); warmup=(0); thin=(5); 1000000 iterations saved.

Warmup took (68) seconds, 1.1 minutes total
Sampling took (193) seconds, 3.2 minutes total

                Mean     MCSE   StdDev     5%   50%   95%    N_Eff  N_Eff/s    R_hat
lp__            -8.6  1.1e-03  1.0e+00    -11  -8.3  -7.6  9.8e+05  5.1e+03  1.0e+00
accept_stat__   0.89  1.4e-04  1.4e-01   0.59  0.94   1.0  9.9e+05  5.1e+03  1.0e+00
stepsize__      0.95  1.5e-12  1.5e-12   0.95  0.95  0.95  1.0e+00  5.2e-03  1.0e+00
treedepth__      1.8  4.3e-04  4.3e-01    1.0   2.0   2.0  1.0e+06  5.2e+03  1.0e+00
n_leapfrog__     3.0  1.2e-03  1.2e+00    1.0   3.0   7.0  1.0e+06  5.2e+03  1.0e+00
divergent__     0.00  0.0e+00  0.0e+00   0.00  0.00  0.00  5.0e+05  2.6e+03     -nan
energy__         9.6  1.5e-03  1.4e+00    7.9   9.2    12  9.8e+05  5.1e+03  1.0e+00
beta[1]         0.27  5.4e-04  5.4e-01  -0.61  0.26   1.2  1.0e+06  5.2e+03  1.0e+00
beta[2]         0.68  5.7e-04  5.7e-01  -0.21  0.66   1.6  1.0e+06  5.2e+03  1.0e+00

Samples were drawn using hmc with nuts.
For each parameter, N_Eff is a crude measure of effective sample size,
and R_hat is the potential scale reduction factor on split chains (at
convergence, R_hat=1).
```

2018年7月14日，CmdStan 在版本 2.18.0 中开始提供 MPI 支持，使得 Stan 可以跑在大规模计算集群上，当然，启用 MPI 也可以在本地运行。2019年3月21日，CmdStan 在版本 2.19.0 中开始提供 GPU 支持，GPU 支持矩阵阶数大于1250才会启用 GPU 计算。

---

补充 Docker 版本的详细信息

```bash
docker version
```
```
Client:
 Version:       18.03.0-ce
 API version:   1.37
 Go version:    go1.9.4
 Git commit:    0520e24302
 Built: Fri Mar 23 08:31:36 2018
 OS/Arch:       windows/amd64
 Experimental:  false
 Orchestrator:  swarm

Server: Docker Engine - Community
 Engine:
  Version:      18.09.7
  API version:  1.39 (minimum version 1.12)
  Go version:   go1.10.8
  Git commit:   2d0083d
  Built:        Thu Jun 27 18:01:17 2019
  OS/Arch:      linux/amd64
  Experimental: false
```

补充系统硬件信息，Stan 的 GPU 和 MPI 功能介绍还未展开，笔者 Windows 8.1 的 主机不适合折腾，硬件配置也低了点！

```bash
 ./clinfo -l
```
```
Platform #0: Intel(R) OpenCL
 +-- Device #0: Intel(R) HD Graphics 4600
 `-- Device #1: Intel(R) Core(TM) i7-4710MQ CPU @ 2.50GHz
Platform #1: NVIDIA CUDA
 `-- Device #0: GeForce GTX 850M
```

---

有待继续补充的地方，期待后续博文吧！

- HMC/NUTS 采样算法如何调参？见 <https://mc-stan.org/docs/2_19/reference-manual/algorithms.html#algorithms>

- CmdStan 和 [TensorFlow Probability](https://github.com/tensorflow/probability) 的性能比较，比如 [分层线性模型的 Stan vs TFP](https://github.com/tensorflow/probability/blob/master/tensorflow_probability/examples/jupyter_notebooks/HLM_TFP_R_Stan.ipynb) `lme4::lmer` (R 语言) `rstanarm::stan_lmer` (Stan 语言)，可以进一步考虑广义分层线性模型。广义线性模型对比，见 Jeff Pollock 的[新博文](https://jeffpollock9.github.io/maximum-likelihood-estimation-with-tensorflow-probability-and-stan-take-2/) 和 [旧博文](https://jeffpollock9.github.io/maximum-likelihood-estimation-with-tensorflow-probability-and-pystan/)

## 参考文献

1. Stan 用户指导 <https://mc-stan.org/docs/2_19/stan-users-guide/index.html>

1. Stan 语言参考手册 <https://mc-stan.org/docs/2_19/reference-manual/index.html>

1. Stan 函数参考手册 <https://mc-stan.org/docs/2_19/functions-reference/index.html>

1. [Getting Started with CmdStan](https://github.com/stan-dev/cmdstan/wiki/Getting-Started-with-CmdStan)

1. CmdStan 指导手册 <https://github.com/stan-dev/cmdstan/releases/download/v2.20.0/cmdstan-guide-2.20.0.pdf>
