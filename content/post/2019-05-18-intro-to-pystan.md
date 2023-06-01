---
title: PyStan 使用入门
author: 黄湘云
date: '2019-05-18'
slug: intro-to-pystan
categories:
  - 统计软件
tags:
  - 贝叶斯计算
  - 分层正态模型
  - Python 语言
math: true
description: "以数据集 8schools 为例介绍分层正态模型及 PyStan 模块的使用，Stan 团队除了不断加强 rstan 及其生态的开发，也着手打造 Stan 的 Python 接口 pystan，但是目前支持力度相对较小，实现的功能远不及 rstan 丰富，易用性也不如 rstan。"
---


# PyStan 使用 {#Intro-PyStan}

查看 pystan 模块包含的方法

```python
import pystan
dir(pystan)
```
```
['StanModel', '__builtins__', '__cached__', '__doc__', '__file__', '__loader__', '__name__', '__package__', '__path__', '__spec__', '__version__', '_api', '_chains', '_compat', '_misc', 'api', 'chains', 'check_hmc_diagnostics', 'constants', 'diagnostics', 'external', 'logger', 'logging', 'lookup', 'misc', 'model', 'plots', 'read_rdump', 'stan', 'stan_rdump', 'stanc', 'stansummary']
```

pystan 对象的绘图方法

```python
dir(pystan.plots)
```
```
['__builtins__', '__cached__', '__doc__', '__file__', '__loader__', '__name__', '__package__', '__spec__', 'logger', 'logging', 'np', 'traceplot']
```

以八校学生考试数据为例，分层正态模型的 Stan 实现

```python
import pystan
import numpy as np
import matplotlib.pyplot as plt
eight_schools_code = """
  // saved as 8schools.stan
  data {
    int<lower=0> J;         // number of schools 
    real y[J];              // estimated treatment effects
    real<lower=0> sigma[J]; // standard error of effect estimates 
  }
  parameters {
    real mu;                // population treatment effect
    real<lower=0> tau;      // standard deviation in treatment effects
    vector[J] eta;          // unscaled deviation from mu by school
  }
  transformed parameters {
    vector[J] theta = mu + tau * eta;        // school treatment effects
  }
  model {
    target += normal_lpdf(eta | 0, 1);       // prior log-density
    target += normal_lpdf(y | theta, sigma); // log-likelihood
  }
"""
```

观测数据是一个字典类型

```python
eight_schools_dat = {'J': 8,
  'y': [28,  8, -3,  7, -1,  1, 18, 12],
  'sigma': [15, 10, 16, 11,  9, 11, 10, 18]}
```

调用 pystan 模块的 StanModel 方法编译模型

```python
sm = pystan.StanModel(model_code = eight_schools_code, verbose = False, model_name = "eight_schools")
```
```
# INFO:pystan:COMPILING THE C++ CODE FOR MODEL eight_schools_25f8cf92efcd66bc8843b4755e935536 NOW.
```

在编译好的模型中代入数据，开始参数的贝叶斯后验分布抽样

```python
eight_schools_fit = sm.sampling(data = eight_schools_dat, iter = 1000, chains = 4)
```
```
Gradient evaluation took 1.6e-05 seconds
1000 transitions using 10 leapfrog steps per transition would take 0.16 seconds.
Adjust your expectations accordingly!


Iteration:   1 / 1000 [  0%]  (Warmup)

Gradient evaluation took 1.5e-05 seconds
1000 transitions using 10 leapfrog steps per transition would take 0.15 seconds.
Adjust your expectations accordingly!


Iteration:   1 / 1000 [  0%]  (Warmup)
Iteration: 100 / 1000 [ 10%]  (Warmup)
Iteration: 100 / 1000 [ 10%]  (Warmup)
Iteration: 200 / 1000 [ 20%]  (Warmup)
Iteration: 200 / 1000 [ 20%]  (Warmup)
Iteration: 300 / 1000 [ 30%]  (Warmup)
Iteration: 300 / 1000 [ 30%]  (Warmup)
Iteration: 400 / 1000 [ 40%]  (Warmup)
Iteration: 400 / 1000 [ 40%]  (Warmup)
Iteration: 500 / 1000 [ 50%]  (Warmup)
Iteration: 501 / 1000 [ 50%]  (Sampling)
Iteration: 500 / 1000 [ 50%]  (Warmup)
Iteration: 501 / 1000 [ 50%]  (Sampling)
Iteration: 600 / 1000 [ 60%]  (Sampling)
Iteration: 600 / 1000 [ 60%]  (Sampling)
Iteration: 700 / 1000 [ 70%]  (Sampling)
Iteration: 700 / 1000 [ 70%]  (Sampling)
Iteration: 800 / 1000 [ 80%]  (Sampling)
Iteration: 800 / 1000 [ 80%]  (Sampling)
Iteration: 900 / 1000 [ 90%]  (Sampling)
Iteration: 900 / 1000 [ 90%]  (Sampling)
Iteration: 1000 / 1000 [100%]  (Sampling)

 Elapsed Time: 0.02124 seconds (Warm-up)
               0.016997 seconds (Sampling)
               0.038237 seconds (Total)


Gradient evaluation took 5e-06 seconds
1000 transitions using 10 leapfrog steps per transition would take 0.05 seconds.
Adjust your expectations accordingly!


Iteration:   1 / 1000 [  0%]  (Warmup)
Iteration: 1000 / 1000 [100%]  (Sampling)

 Elapsed Time: 0.02153 seconds (Warm-up)
               0.01847 seconds (Sampling)
               0.04 seconds (Total)


Gradient evaluation took 5e-06 seconds
1000 transitions using 10 leapfrog steps per transition would take 0.05 seconds.
Adjust your expectations accordingly!


Iteration:   1 / 1000 [  0%]  (Warmup)
Iteration: 100 / 1000 [ 10%]  (Warmup)
Iteration: 100 / 1000 [ 10%]  (Warmup)
Iteration: 200 / 1000 [ 20%]  (Warmup)
Iteration: 300 / 1000 [ 30%]  (Warmup)
Iteration: 200 / 1000 [ 20%]  (Warmup)
Iteration: 400 / 1000 [ 40%]  (Warmup)
Iteration: 300 / 1000 [ 30%]  (Warmup)
Iteration: 400 / 1000 [ 40%]  (Warmup)
Iteration: 500 / 1000 [ 50%]  (Warmup)
Iteration: 501 / 1000 [ 50%]  (Sampling)
Iteration: 600 / 1000 [ 60%]  (Sampling)
Iteration: 500 / 1000 [ 50%]  (Warmup)
Iteration: 501 / 1000 [ 50%]  (Sampling)
Iteration: 700 / 1000 [ 70%]  (Sampling)
Iteration: 600 / 1000 [ 60%]  (Sampling)
Iteration: 800 / 1000 [ 80%]  (Sampling)
Iteration: 700 / 1000 [ 70%]  (Sampling)
Iteration: 900 / 1000 [ 90%]  (Sampling)
Iteration: 800 / 1000 [ 80%]  (Sampling)
Iteration: 1000 / 1000 [100%]  (Sampling)

 Elapsed Time: 0.020184 seconds (Warm-up)
               0.016591 seconds (Sampling)
               0.036775 seconds (Total)

Iteration: 900 / 1000 [ 90%]  (Sampling)
Iteration: 1000 / 1000 [100%]  (Sampling)

 Elapsed Time: 0.019572 seconds (Warm-up)
               0.016049 seconds (Sampling)
               0.035621 seconds (Total)
```

抽样结束后，输出模型参数的贝叶斯估计结果

```{python,eval=FALSE}
print(eight_schools_fit)
```
```
Inference for Stan model: eight_schools_25f8cf92efcd66bc8843b4755e935536.
4 chains, each with iter=1000; warmup=500; thin=1;
post-warmup draws per chain=500, total post-warmup draws=2000.

           mean se_mean     sd   2.5%    25%    50%    75%  97.5%  n_eff   Rhat
mu          7.9    0.15   5.05  -1.98   4.67   7.85  11.11   18.4   1082    1.0
tau        6.67    0.21   5.63   0.26    2.5   5.36   9.37   20.6    749    1.0
eta[1]     0.39    0.02   0.98  -1.56  -0.23   0.42   1.03   2.28   2078    1.0
eta[2]  -7.9e-3    0.02   0.85  -1.64  -0.56  -0.01   0.53   1.69   1899    1.0
eta[3]    -0.22    0.02    0.9  -1.94  -0.85   -0.2    0.4   1.55   2017    1.0
eta[4]    -0.02    0.02   0.84  -1.73  -0.57-8.1e-3   0.53   1.64   2173    1.0
eta[5]    -0.34    0.02   0.89  -2.03  -0.96  -0.35   0.22   1.43   2122    1.0
eta[6]    -0.22    0.02   0.87   -1.9   -0.8  -0.22   0.34   1.59   2284    1.0
eta[7]     0.34    0.02   0.91  -1.48  -0.23   0.37   0.93   2.11   1900    1.0
eta[8]      0.1    0.02    0.9  -1.62  -0.49   0.09   0.68   1.93   1979    1.0
theta[1]  11.55    0.21   8.54  -2.15   6.11  10.19  15.37  32.89   1651    1.0
theta[2]   7.76    0.15   6.51  -4.98   3.92   7.65  11.55  21.21   1775    1.0
theta[3]   5.98    0.19   7.77 -12.53   1.86   6.61  10.57   19.9   1720    1.0
theta[4]   7.51    0.14   6.62  -5.93   3.59   7.54  11.35   21.2   2201    1.0
theta[5]   5.19    0.16   6.47   -9.0   1.39   5.68   9.45  17.01   1580    1.0
theta[6]   5.99    0.16   6.99  -8.66   1.97   6.48  10.38  19.16   2012    1.0
theta[7]   10.7    0.16   7.03   -1.8   6.05   9.92  14.68  26.16   1932    1.0
theta[8]   8.69    0.19   7.72  -6.51   4.19   8.56  12.68  25.43   1593    1.0
lp__     -39.51    0.11   2.68 -45.44 -41.13 -39.22 -37.64 -34.82    545    1.0

Samples were drawn using NUTS at Tue Apr 30 13:02:09 2019.
For each parameter, n_eff is a crude measure of effective sample size,
and Rhat is the potential scale reduction factor on split chains (at
convergence, Rhat=1).
```

查看参数 `$\eta$` 的后验均值

```python
eta = eight_schools_fit.extract(permuted=True)['eta']
np.mean(eta, axis=0)
```
```python
array([ 0.38997753, -0.00788471, -0.21640479, -0.01691977, -0.34157079,
       -0.21834438,  0.34371805,  0.09724732])
```

pystan 对象的绘图方法只实现了 traceplot 图，就是参数迭代的轨迹图， traceplot 默认画出所有参数的轨迹图

```python
eight_schools_fit.plot()
plt.tight_layout()
plt.show()
# 保存为 PDF 格式图像
plt.savefig('eight-schools.pdf', transparent=True)
# 均值
eight_schools_fit.plot(pars=["mu"]) # 默认尺寸 640x480
# 或者 eight_schools_fit.traceplot(pars=["mu"])
# 保存为 PNG 格式 分辨率 dpi 300
plt.savefig("eight-schools-mu.png", transparent=True, dpi=300, pad_inches = 0)
```

![eight-schools-mu](https://wp-contents.netlify.com/2019/05/eight-schools-mu.png)

```python
# plt.figure(figsize=(20,10)) # 新建空白的画布 2000x1000
# plt.subplots(1,2,figsize=(10, 10)) # 设置子图尺寸
# 其它图形控制
fig = plt.gcf()
fig.set_size_inches(10, 5)
# 防止坐标轴标签遮挡 https://matplotlib.org/users/tight_layout_guide.html
plt.tight_layout() 
# 保存 transparent=True 透明背景
plt.savefig('eight-schools-mu.pdf', transparent=True) 

# bbox_inches = 'tight' 可以去掉多余的边空
plt.savefig('eight-schools-mu.pdf', transparent=True, bbox_inches = 'tight')
# 方差
eight_schools_fit.plot(pars=["tau"])
plt.savefig('eight-schools-tau.pdf', transparent=True)

eight_schools_fit.plot(pars=["eta"])
plt.savefig('eight-schools-eta.pdf', transparent=True)

eight_schools_fit.plot(pars=["theta"])
plt.savefig('eight-schools-theta.pdf', transparent=True)
```


# 软件信息 {#Software-Information}

运行环境是操作系统 Fedora 30 (Thirty) 

```
Python 3.7.1 (default, Dec 14 2018, 19:28:38)
[GCC 7.3.0] :: Anaconda, Inc. on linux
```

pystan 模块的版本 2.18.0.0，其它 Python 模块信息

```bash
pip list --format=columns
```

```markdown
Package         Version
--------------- --------
certifi         2019.3.9
cycler          0.10.0
Cython          0.29.7
kiwisolver      1.1.0
logger          1.4
matplotlib      3.0.3
mkl-fft         1.0.12
mkl-random      1.0.2
numpy           1.16.3
pandas          0.24.2
pip             19.1.1
pyparsing       2.4.0
pystan          2.18.0.0
python-dateutil 2.8.0
pytz            2019.1
setuptools      41.0.1
six             1.12.0
tornado         6.0.2
wheel           0.33.4
wincertstore    0.2
```

> 最近 TUNA 把 Anaconda 源移除了，不得不重新配置新的镜像源

```bash
conda config --remove channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/free/
conda create --name r-stan python=3.6
conda install Cython numpy matplotlib pandas pystan scipy
```

# 参考文献

- [PyStan’s API documentation](https://mc-stan.org/users/interfaces/pystan)
- [Introduction to Bayesian Regression Analysis with PyStan](https://github.com/woosubs/Intro_BayesReg)
- [PyStan: The Python Interface to Stan](https://pystan.readthedocs.io)
