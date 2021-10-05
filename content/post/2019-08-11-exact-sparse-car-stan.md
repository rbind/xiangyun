---
title: 稀疏条件自回归模型的精确推断及其在苏格兰唇癌数据分析中的应用
author: 黄湘云
date: '2019-08-11'
slug: exact-sparse-car-stan
categories:
  - 统计模型
tags:
  - 条件自回归模型
  - 苏格兰唇癌数据
  - 空间随机效应的稀疏表示
description: "本文详细描述稀疏条件自回归模型的精确推断及其 Stan 实现，是稀疏条件自回归模型的近似推断的姊妹篇。稀疏表示可以获得数量级的效率优势，对于大型空间数据集有更好的扩展性"
---

> 本文翻译自 Max Joseph 的 [Exact sparse CAR models in Stan](https://mc-stan.org/users/documentation/case-studies/mbjoseph-CARStan.html) 相关代码和数据见 <https://github.com/mbjoseph/CARstan>，本文代码已做了大量现代化改进，以期在未来5年内不会变动。

本文详细描述稀疏条件自回归模型的精确推断及其 Stan 实现，是稀疏条件自回归模型的近似推断的姊妹篇。稀疏表示似乎可以获得数量级的效率优势，对于大型空间数据集有更好的扩展性

## 1. 空间随机效应的先验表示

在区域型的空间数据集上，条件自回归模型常作为空间随机效应的先验分布。假设我们在 `$n$` 个区域型的位置上有随机量 `$\phi = (\phi_1, \phi_2, ..., \phi_n)'$`。 CAR 模型的全条件分布常表示为如下的形式

`$$
\phi_i \mid \phi_j, j \neq i \sim N(\alpha \sum_{j = 1}^n b_{ij} \phi_j, \tau_i^{-1})
$$`

其中，`$\tau_i$` 是随空间位置变化的精度参数，`$b_{ii} = 0$`。根据 Brook 引理，`$\phi$` 的联合分布为

`$$
\phi \sim N(0, [D_\tau (I - \alpha B)]^{-1}).
$$`

符号作如下约定

- `$D_\tau = \tau D$`
- `$D = diag(m_i)$`: 是一个 `$n \times n$` 的对角矩阵，`$m_i$` 表示位置 `$i$` 处的近邻个数
- `$I$`: 是 `$n \times n$` 的单位矩阵
- `$\alpha$`: 是空间相关性的参数，特别地，`$\alpha = 0$` 表示与空间无关, `$\alpha = 1$` 相应于 IAR (intrisnic conditional autoregressive) 模型
- `$B = D^{-1} W$`: 尺度变换后的邻接矩阵
- `$W$`: 邻接矩阵，对角线元素 `$w_{ii} = 0$`，如果 `$i$` 是 `$j$` 的近邻, `$w_{ij} = 1$`，否则 `$w_{ij} = 0$`

则 CAR 先验可以简化为

`$$
\phi \sim N(0, [\tau (D - \alpha W)]^{-1}).
$$`

`$\alpha$` 参数决定 `$\phi$` 的联合分布的性质，只要 `$| \alpha | < 1$` (Gelfand \& Vounatsou 2003)。 然而，`$\alpha$` 常常会取到 1 变成 IAR 模型，这会产生一个奇异的精度矩阵和不合适的先验分布。 

## 2. 泊松分布

假定我们已经收集了 `$n$` 个位置处的计数数据 `$y_1, y_2, ..., y_n$`，假定相近的位置有相似的计数，并服从泊松分布

`$$
y_i \sim \text{Poisson}(\text{exp}(X_{i} \beta + \phi_i + \log(\text{offset}_i)))
$$`

其中，`$X_i$` 是设计向量，表示来自设计矩阵的第 `$i$` 行，`$\beta$` 是系数向量，`$\phi_i$` 是空间相关的随机效应，`$\log(\text{offset}_i)$` 是空间单元的期望值，如物理过程的区域，疾病应用中的人群大小等。

如果我们指定合适的 CAR 先验 `$\phi$`，然后获得 `$\phi \sim \text{N}(0, [\tau (D - \alpha W)]^{-1})$` 其中 `$\tau (D - \alpha W)$` 是精度矩阵 `$\Sigma^{-1}$`。完整的贝叶斯表示还包含其余参数 `$\alpha$`, `$\tau$` 和 `$\beta$` 的先验，使得后验分布为

`$$
p(\phi, \beta, \alpha, \tau \mid y) \propto p(y \mid \beta, \phi) p(\phi \mid \alpha, \tau) p(\alpha) p(\tau) p(\beta)
$$`



## 3. 案例：苏格兰唇癌数据

为了介绍这个方法，我们使用苏格兰唇癌数据。数据集记录了苏格兰56个空间单元的唇癌病例，病例数的期望值用作 offset （与空间区域无关的未知常数项，可看作是模型截距），与空间区域有关的协变量表示从事农业、渔业和林业的人群比例，模型结构等同于一个上面描述的泊松模型。

我们首先加载必要的 R 包

```{r make-scotland-map}
library(sf)
options(
  ggplot2.continuous.colour = "viridis",
  ggplot2.continuous.fill = "viridis"
)
library(ggplot2)
library(rstan)
```

Stan 编译设置

```r
rstan_options(auto_write = TRUE)
# 与 tfprobability 比较 https://github.com/tensorflow/probability
options(mc.cores = 1) # 设置为 1 单进程是降低内存的考量 https://discourse.mc-stan.org/t/9633
# Stan 的内存花销 n_iterations * n_stored_values * 8 bytes of memory
Sys.setenv(LOCAL_CPPFLAGS = '-march=native') # Windows 下需要
```

读取空间数据集

```r
# 设置坐标参考系
proj4str <- "+init=epsg:27700 +proj=tmerc 
  +lat_0=49 +lon_0=-2 +k=0.9996012717 +x_0=400000 +y_0=-100000
  +datum=OSGB36 +units=m +no_defs +ellps=airy
  +towgs84=446.448,-125.157,542.060,0.1502,0.2470,0.8421,-20.4894"
# 读取苏格兰边界数据
scotlips <- sf::st_read('data/scotland.shp', crs = proj4str)
png(filename = "scotlips.png", width = 10*80, height = 10*80, res = 150, type = "cairo")
ggplot() +
  geom_sf(data = scotlips, aes(fill = Observed))
dev.off()
```

![苏格兰地区](https://wp-contents.netlify.com/2019/08/scotlips.png)

指定 MCMC 迭代次数和链条数

```{r load-lip-cancer-data}
# 加载数据集
source('data/scotland_lip_cancer.RData')
# MCMC 参数设置
niter <- 1E4   # 设置迭代次数 10000 次
nchains <- 4  # 设置马氏链的数目
```

为了拟合整个模型，首先加载苏格兰唇癌数据集，然后使用 `model.matrix` 生成设计矩阵，将连续型协变量 `x` 中心化，以此来减弱截距和斜率之间的相关性。

```{r make-adjacency-matrix}
W <- A # 邻接矩阵 adjacency matrix
scaled_x <- c(scale(x))
X <- model.matrix(~scaled_x)
  
full_d <- list(n = nrow(X),         # number of observations 观测样本量
               p = ncol(X),         # number of coefficients 系数个数
               X = X,               # design matrix 设计矩阵
               y = O,               # observed number of cases
               log_offset = log(E), # log(expected) num. cases
               W = W)               # adjacency matrix 邻接矩阵
```

### 3.1 借助 `multi_normal_prec` 函数实现 CAR 模型

参数 `$\beta$` 和 `$\tau$` 的先验分别为正态和伽马分布，参数 `$\alpha$` 服从均匀先验 `$\text{Uniform}(0, 1)$`，参数 `$\phi$` 的先验由函数 `multi_normal_prec` 确定，传进 `$\tau (D - \alpha W)$` 作为精度矩阵

```{r print-stan-prec-model}
cat(readLines('stan/car_prec.stan'), sep = '\n')
```
```
data {
  int<lower = 1> n;
  int<lower = 1> p;
  matrix[n, p] X;
  int<lower = 0> y[n];
  vector[n] log_offset;
  matrix<lower = 0, upper = 1>[n, n] W;
}
transformed data{
  vector[n] zeros;
  matrix<lower = 0>[n, n] D;
  {
    vector[n] W_rowsums;
    for (i in 1:n) {
      W_rowsums[i] = sum(W[i, ]);
    }
    D = diag_matrix(W_rowsums);
  }
  zeros = rep_vector(0, n);
}
parameters {
  vector[p] beta;
  vector[n] phi;
  real<lower = 0> tau;
  real<lower = 0, upper = 1> alpha;
}
model {
  phi ~ multi_normal_prec(zeros, tau * (D - alpha * W));
  beta ~ normal(0, 1);
  tau ~ gamma(2, 2);
  y ~ poisson_log(X * beta + phi + log_offset);
}
```

用 rstan 包拟合模型

```{r fit-prec-model}
full_fit <- stan('stan/car_prec.stan', data = full_d, 
                 iter = niter, chains = nchains, verbose = FALSE)
print(full_fit, pars = c('beta', 'tau', 'alpha', 'lp__'))
```
```
Inference for Stan model: car_prec.
4 chains, each with iter=10000; warmup=5000; thin=1;
post-warmup draws per chain=5000, total post-warmup draws=20000.

          mean se_mean   sd   2.5%    25%    50%    75%  97.5% n_eff Rhat
beta[1]   0.00    0.01 0.29  -0.60  -0.16   0.00   0.16   0.57   576 1.01
beta[2]   0.27    0.00 0.09   0.08   0.21   0.27   0.34   0.45  4596 1.00
tau       1.63    0.01 0.49   0.86   1.28   1.57   1.92   2.78  6343 1.00
alpha     0.93    0.00 0.06   0.76   0.91   0.95   0.97   0.99  4157 1.00
lp__    820.67    0.10 6.71 806.51 816.36 821.02 825.34 832.76  4780 1.00

Samples were drawn using NUTS(diag_e) at Tue Aug 13 02:35:40 2019.
For each parameter, n_eff is a crude measure of effective sample size,
and Rhat is the potential scale reduction factor on split chains (at
convergence, Rhat=1).
```

可视化结果

```r
png(filename = "scotlips-mcmc-traceplot-01.png", width = 20*80, height = 16*80, res = 150, type = "cairo")
to_plot <- c('beta', 'tau', 'alpha', 'phi[1]', 'phi[2]', 'phi[3]', 'lp__')
traceplot(full_fit, pars = to_plot)
dev.off()
```

![scotlips-mcmc-traceplot-01](https://wp-contents.netlify.com/2019/08/scotlips-mcmc-traceplot-01.png)

### 3.2 一种更有效的稀疏表示

尽管我们可以借助 Stan 里的 `multi_normal_prec` 函数指定 `$\phi$` 的多元正态先验 ，如上所做，但在这个例子里，直接手动指定对数概率密度函数 `$p(\phi \mid \tau, \alpha)$`，我们将提高计算的效率，`$\phi$` 的对数概率密度函数是

`$$
\log(p(\phi \mid \tau, \alpha))
= - \frac{n}{2} \log(2 \pi) + \frac{1}{2} \log(\text{det}( \Sigma^{-1})) - \frac{1}{2} \phi^T \Sigma^{-1} \phi
$$`

在 Stan 里，我们只需把对数后验加到可加常数上，所以我们可以把第一项丢掉，然后，用 `$\tau (D - \alpha W)$` 替换 `$\Sigma^{-1}$`

`$$
\begin{align}
\frac{1}{2} \log(\text{det}(\tau (D - \alpha W))) - \frac{1}{2} \phi^T \Sigma^{-1} \phi
&= \frac{1}{2} \log(\tau ^ n \text{det}(D - \alpha W)) - \frac{1}{2} \phi^T \Sigma^{-1} \phi \\
&= \frac{n}{2} \log(\tau) + \frac{1}{2} \log(\text{det}(D - \alpha W)) - \frac{1}{2} \phi^T \Sigma^{-1} \phi
\end{align}
$$`

这有两种提高计算效率的方式

1. `$\Sigma^{-1}$` 的稀疏表示加快 `$\phi^T \Sigma^{-1} \phi$` 的计算，这个工作在之前由 Kyle foreman 做了

1. 更加高效地计算行列式 Jin, Carlin, and Banerjee (2005) 证明了

`$$
\text{det}(D - \alpha W) \propto \prod_{i = 1}^n (1 - \alpha \lambda_i)
$$`

其中 `$\lambda_1, ..., \lambda_n$` 是矩阵 `$D^{-\frac{1}{2}} W D^{-\frac{1}{2}}$` 的特征值，可以提前计算，并作为数据传入，因为只需要一个可加常数的对数后验，基于这个结果，它正比于某个可乘的常数 `$c$`

`$$
\begin{align}
\frac{n}{2} \log(\tau) + \frac{1}{2} \log(c \prod_{i = 1}^n (1 - \alpha \lambda_i)) - \frac{1}{2} \phi^T \Sigma^{-1} \phi 
= \frac{n}{2} \log(\tau) + \frac{1}{2} \log(c) +  \frac{1}{2} \log(\prod_{i = 1}^n (1 - \alpha \lambda_i)) - \frac{1}{2} \phi^T \Sigma^{-1} \phi
\end{align}
$$`

再一次扔掉一些可加的常数

`$$
\begin{align}
\frac{n}{2} \log(\tau) + \frac{1}{2} \log(\prod_{i = 1}^n (1 - \alpha \lambda_i)) - \frac{1}{2} \phi^T \Sigma^{-1} \phi 
= \frac{n}{2} \log(\tau) + \frac{1}{2} \sum_{i = 1}^n \log(1 - \alpha \lambda_i) - \frac{1}{2} \phi^T \Sigma^{-1} \phi
\end{align}
$$`



### 3.3 稀疏 CAR 模型的 Stan 实现

在 Stan 模型数据转换部分 `transformed data` 中，我们计算 `$D^{-\frac{1}{2}} W D^{-\frac{1}{2}}$` 的特征值 `$\lambda_1, ..., \lambda_n$`，生成 W 的稀疏表示 `W_sparse`，假定它是对称的，使得相邻的关系可以表示为矩阵的两列，每一行表示两个站点的相邻关系。

实现稀疏表示的 Stan 语句块不构造精度矩阵，不用任何 `multi_normal*` 相关的函数，而是使用我们自定义的 `sparse_car_lpdf()` 函数，然后在模型块中使用它。

```{r print-sparse-model}
cat(readLines('stan/car_sparse.stan'), sep = '\n')
```
```
functions {
  /**
  * Return the log probability of a proper conditional autoregressive (CAR) prior 
  * with a sparse representation for the adjacency matrix
  *
  * @param phi Vector containing the parameters with a CAR prior
  * @param tau Precision parameter for the CAR prior (real)
  * @param alpha Dependence (usually spatial) parameter for the CAR prior (real)
  * @param W_sparse Sparse representation of adjacency matrix (int array)
  * @param n Length of phi (int)
  * @param W_n Number of adjacent pairs (int)
  * @param D_sparse Number of neighbors for each location (vector)
  * @param lambda Eigenvalues of D^{-1/2}*W*D^{-1/2} (vector)
  *
  * @return Log probability density of CAR prior up to additive constant
  */
  real sparse_car_lpdf(vector phi, real tau, real alpha, 
    int[,] W_sparse, vector D_sparse, vector lambda, int n, int W_n) {
      row_vector[n] phit_D; // phi' * D
      row_vector[n] phit_W; // phi' * W
      vector[n] ldet_terms;
    
      phit_D = (phi .* D_sparse)';
      phit_W = rep_row_vector(0, n);
      for (i in 1:W_n) {
        phit_W[W_sparse[i, 1]] = phit_W[W_sparse[i, 1]] + phi[W_sparse[i, 2]];
        phit_W[W_sparse[i, 2]] = phit_W[W_sparse[i, 2]] + phi[W_sparse[i, 1]];
      }
    
      for (i in 1:n) ldet_terms[i] = log1m(alpha * lambda[i]);
      return 0.5 * (n * log(tau)
                    + sum(ldet_terms)
                    - tau * (phit_D * phi - alpha * (phit_W * phi)));
  }
}
data {
  int<lower = 1> n;
  int<lower = 1> p;
  matrix[n, p] X;
  int<lower = 0> y[n];
  vector[n] log_offset;
  matrix<lower = 0, upper = 1>[n, n] W; // adjacency matrix
  int W_n;                // number of adjacent region pairs
}
transformed data {
  int W_sparse[W_n, 2];   // adjacency pairs
  vector[n] D_sparse;     // diagonal of D (number of neigbors for each site)
  vector[n] lambda;       // eigenvalues of invsqrtD * W * invsqrtD
  
  { // generate sparse representation for W
  int counter;
  counter = 1;
  // loop over upper triangular part of W to identify neighbor pairs
    for (i in 1:(n - 1)) {
      for (j in (i + 1):n) {
        if (W[i, j] == 1) {
          W_sparse[counter, 1] = i;
          W_sparse[counter, 2] = j;
          counter = counter + 1;
        }
      }
    }
  }
  for (i in 1:n) D_sparse[i] = sum(W[i]);
  {
    vector[n] invsqrtD;  
    for (i in 1:n) {
      invsqrtD[i] = 1 / sqrt(D_sparse[i]);
    }
    lambda = eigenvalues_sym(quad_form(W, diag_matrix(invsqrtD)));
  }
}
parameters {
  vector[p] beta;
  vector[n] phi;
  real<lower = 0> tau;
  real<lower = 0, upper = 1> alpha;
}
model {
  phi ~ sparse_car(tau, alpha, W_sparse, D_sparse, lambda, n, W_n);
  beta ~ normal(0, 1);
  tau ~ gamma(2, 2);
  y ~ poisson_log(X * beta + phi + log_offset);
}
```

拟合模型

```{r fit-sparse-model}
sp_d <- list(n = nrow(X),         # number of observations
             p = ncol(X),         # number of coefficients
             X = X,               # design matrix
             y = O,               # observed number of cases
             log_offset = log(E), # log(expected) num. cases
             W_n = sum(W) / 2,    # number of neighbor pairs
             W = W)               # adjacency matrix

sp_fit <- stan('stan/car_sparse.stan', data = sp_d, 
               iter = niter, chains = nchains, verbose = FALSE)
```

查看各个参数估计的结果

```r
print(sp_fit, pars = c('beta', 'tau', 'alpha', 'lp__'))
```
```
Inference for Stan model: car_sparse.
4 chains, each with iter=10000; warmup=5000; thin=1;
post-warmup draws per chain=5000, total post-warmup draws=20000.

          mean se_mean   sd   2.5%    25%    50%    75%  97.5% n_eff Rhat
beta[1]   0.00    0.01 0.30  -0.58  -0.16   0.00   0.15   0.61   557 1.01
beta[2]   0.27    0.00 0.09   0.09   0.21   0.27   0.33   0.45  5303 1.00
tau       1.64    0.01 0.50   0.85   1.28   1.58   1.93   2.81  5668 1.00
alpha     0.93    0.00 0.06   0.77   0.91   0.95   0.97   1.00  4465 1.00
lp__    782.84    0.10 6.69 768.70 778.52 783.20 787.53 795.05  4947 1.00

Samples were drawn using NUTS(diag_e) at Tue Aug 13 02:39:18 2019.
For each parameter, n_eff is a crude measure of effective sample size,
and Rhat is the potential scale reduction factor on split chains (at
convergence, Rhat=1).
```

迭代链条的平稳性，迭代轨迹图

```r
traceplot(sp_fit, pars = to_plot)
```

![scotlips-mcmc-traceplot-02](https://wp-contents.netlify.com/2019/08/scotlips-mcmc-traceplot-02.png)


### 3.4 比较 MCMC 采样效率 
 
主要感兴趣的是每单位时间的有效样本量，稀疏性可以大大减少运行时间
 
```{r make-mcmc-efficiency-table}
library(dplyr)
library(ggmcmc)
library(knitr)
efficiency <- data.frame(model = c('full', 'sparse'), 
             n_eff = c(summary(full_fit)$summary['lp__', 'n_eff'], 
                       summary(sp_fit)$summary['lp__', 'n_eff']), 
             elapsed_time = c(get_elapsed_time(full_fit) %>% sum(), 
                              get_elapsed_time(sp_fit) %>% sum())) %>%
  mutate(n_eff_per_sec = n_eff / elapsed_time)
names(efficiency) <- c('Model', 'Number of effective samples', 'Elapsed time (sec)', 
                       'Effective samples / sec)')
kable(efficiency)
```

|Model  | Number of effective samples| Elapsed time (sec)| Effective samples / sec)|
|:------|---------------------------:|------------------:|------------------------:|
|full   |                    4780.412|           260.9445|                 18.31965|
|sparse |                    4947.075|            22.9909|                215.17533|


### 3.5 后验分布的比较

通过比较两种方法的参数估计结果，来确保我们使用不同的方法获得相同的结果。在这个案例中，为了更好地估计每个边际后验分布的尾部，相比于通常的情况，这里使用了更多的 MCMC 迭代，每条链迭代有10000次，这样，我们就可以比较两种方法 95% 的置信区间

```{r compare-parameter-estimates}
post_full <- ggs(full_fit)
post_full$model <- 'full'
post_sp <- ggs(sp_fit)
post_sp$model <- 'sparse'
post <- full_join(post_full, post_sp)

psumm <- post %>%
  group_by(model, Parameter) %>%
  summarize(median = median(value), 
            lo = quantile(value, .025), 
            hi = quantile(value, .975)) %>%
  mutate(paramXmod = paste(Parameter, model, sep = '_'))
# 空间随机效应的比较
# compare estimated spatial random effects
psumm %>%
  filter(grepl('phi', Parameter)) %>%
  ggplot(aes(x = median, y = paramXmod, color = model)) + 
  geom_point() + 
  geom_segment(aes(x = lo, xend = hi, yend = paramXmod)) + 
  labs(x = 'Estimate', title = 'Comparison on random effect estimates')
```

![稀疏表示和精度矩阵表示的空间随机效应的估计结果比较](https://wp-contents.netlify.com/2019/08/compare-parameter-estimates.png)

```{r}
# 比较模型各个参数
# compare remaining estimates
psumm %>%
  filter(!grepl('phi', Parameter)) %>%
  ggplot(aes(x = median, y = paramXmod, color = model)) + 
  geom_point() + 
  geom_segment(aes(x = lo, xend = hi, yend = paramXmod)) + 
  labs(x = 'Estimate', title = expression(paste('Comparison of parameter estimates excluding'), phi))
```

![其余参数估计的结果比较](https://wp-contents.netlify.com/2019/08/compare-remaining-estimates.png)

这两种方法给出了相同的结果，由于 MCMC 固有的采样误差，结果或多或少存在些微小差别！

## 3.6 附录：稀疏 IAR 表示

尽管 `$\alpha = 1$` 导出的 `$\phi$` 的 IAR 先验是不合适的，但它很受欢迎 (Besag, York, and Mollie, 1991)。在实践中，拟合模型的同时加上和为0的约束，`$\sum_{i \in \text{connected coponent}} \phi_i = 0$`。这可以用来解释总体均值和逐个成分的均值。将 `$\alpha$` 取值为 1，我们可以得到

`$$
\begin{align}
\log(p(\phi \mid \tau)) 
&= - \frac{n}{2} \log(2 \pi) + \frac{1}{2} \log(\text{det}^*(\tau (D - W))) - \frac{1}{2} \phi^T \tau (D - W) \phi \\
&= - \frac{n}{2} \log(2 \pi) + \frac{1}{2} \log(\tau^{n-k} \text{det}^*(D - W)) - \frac{1}{2} \phi^T \tau (D - W) \phi \\
&= - \frac{n}{2} \log(2 \pi) + \frac{1}{2} \log(\tau^{n-k}) + \frac{1}{2} \log(\text{det}^*(D - W)) - \frac{1}{2} \phi^T \tau (D - W) \phi
\end{align}
$$`

这里 `$\text{det}^*(A)$` 是方阵 `$A$` 的广义行列式， `$A$` 定义为它的非零特征值的乘积， `$k$` 是图里面相关联的成分的数量。就苏格兰唇癌数据集来说，这只有一个连接成分，因此 `$k=1$`。由定义可知，我们需要使用广义行列式的原因是 intrinsic 模型中的精度矩阵是奇异的，因为高斯分布的支撑是低于 `$n$` 维的子空间。对于经典的 ICAR(1) 模型，我们知道零特征值的方向是关于图里每个连接成分的常数向量，因此 `$k$` 是连接成分的个数。扔掉可加的常数项，变为

`$$
\frac{1}{2} \log(\tau^{n-k}) - \frac{1}{2} \phi^T \tau (D - W) \phi
$$`

相应的 Stan 代码变为

```{r print-iar-model, comment='', echo = FALSE}
cat(readLines('stan/iar_sparse.stan'), sep = '\n')
```
```
functions {
  /**
  * Return the log probability of a proper intrinsic autoregressive (IAR) prior 
  * with a sparse representation for the adjacency matrix
  *
  * @param phi Vector containing the parameters with a IAR prior
  * @param tau Precision parameter for the IAR prior (real)
  * @param W_sparse Sparse representation of adjacency matrix (int array)
  * @param n Length of phi (int)
  * @param W_n Number of adjacent pairs (int)
  * @param D_sparse Number of neighbors for each location (vector)
  * @param lambda Eigenvalues of D^{-1/2}*W*D^{-1/2} (vector)
  *
  * @return Log probability density of IAR prior up to additive constant
  */
  real sparse_iar_lpdf(vector phi, real tau,
    int[,] W_sparse, vector D_sparse, vector lambda, int n, int W_n) {
      row_vector[n] phit_D; // phi' * D
      row_vector[n] phit_W; // phi' * W
      vector[n] ldet_terms;
    
      phit_D = (phi .* D_sparse)';
      phit_W = rep_row_vector(0, n);
      for (i in 1:W_n) {
        phit_W[W_sparse[i, 1]] = phit_W[W_sparse[i, 1]] + phi[W_sparse[i, 2]];
        phit_W[W_sparse[i, 2]] = phit_W[W_sparse[i, 2]] + phi[W_sparse[i, 1]];
      }
    
      return 0.5 * ((n-1) * log(tau)
                    - tau * (phit_D * phi - (phit_W * phi)));
  }
}
data {
  int<lower = 1> n;
  int<lower = 1> p;
  matrix[n, p] X;
  int<lower = 0> y[n];
  vector[n] log_offset;
  matrix<lower = 0, upper = 1>[n, n] W; // adjacency matrix
  int W_n;                // number of adjacent region pairs
}
transformed data {
  int W_sparse[W_n, 2];   // adjacency pairs
  vector[n] D_sparse;     // diagonal of D (number of neigbors for each site)
  vector[n] lambda;       // eigenvalues of invsqrtD * W * invsqrtD
  
  { // generate sparse representation for W
  int counter;
  counter = 1;
  // loop over upper triangular part of W to identify neighbor pairs
    for (i in 1:(n - 1)) {
      for (j in (i + 1):n) {
        if (W[i, j] == 1) {
          W_sparse[counter, 1] = i;
          W_sparse[counter, 2] = j;
          counter = counter + 1;
        }
      }
    }
  }
  for (i in 1:n) D_sparse[i] = sum(W[i]);
  {
    vector[n] invsqrtD;  
    for (i in 1:n) {
      invsqrtD[i] = 1 / sqrt(D_sparse[i]);
    }
    lambda = eigenvalues_sym(quad_form(W, diag_matrix(invsqrtD)));
  }
}
parameters {
  vector[p] beta;
  vector[n] phi_unscaled;
  real<lower = 0> tau;
}
transformed parameters {
  vector[n] phi; // brute force centering
  phi = phi_unscaled - mean(phi_unscaled);
}
model {
  phi_unscaled ~ sparse_iar(tau, W_sparse, D_sparse, lambda, n, W_n);
  beta ~ normal(0, 1);
  tau ~ gamma(2, 2);
  y ~ poisson_log(X * beta + phi + log_offset);
}
```


## 参考文献

1. Besag, Julian, Jeremy York, and Annie Mollié. 1991. Bayesian image restoration, with two applications in spatial statistics. Annals of the institute of statistical mathematics. 43(1):1-20.

1. Gelfand, Alan E., and Penelope Vounatsou. 2003. Proper multivariate conditional autoregressive models for spatial data analysis. Biostatistics. 4(1):11-15.

1. Jin, Xiaoping, Bradley P. Carlin, and Sudipto Banerjee. 2005. Generalized hierarchical multivariate CAR models for areal data. Biometrics. 61(4):950-961. <https://doi.org/10.1111/j.1541-0420.2005.00359.x>

## 强调两个技巧

CAR 模型常用于区域空间数据的分析中，作为空间随机效应的先验分布。以往，用于 CAR 模型的 MCMC 算法基于空间随机效应的全条件分布，实现高效的吉布斯采样。但是，这些条件分布不能在Stan中表示出来，联合密度需要指定。

当空间随机效应用多元正态先验表示时，CAR 模型可以在 Stan 模型中实现，多元正态分布由均值向量和精度矩阵参数化。这是一种实现方式，但是运算起来很慢，而且很难扩展到大型数据集上。

极大地加快计算速度的方式有以下两点：

1. 稀疏矩阵乘法，来自 Kyle Foreman 见 [Stan 用户邮件列表](https://groups.google.com/d/topic/stan-users/M7T7EIlyhoo/discussion)

1. 来自Jin, Carlin, and Banerjee (2005) 矩阵行列式技巧

苏格兰唇癌数据，稀疏 CAR 模型借助 Stan 内置的 NUTS 采样器实现，每秒可以获得 120 个有效样本，而精度矩阵的实现方式每秒只能获取7个有效样本。更多关于稀疏 CAR 模型的精确方法，见上述译文，见原文 <https://github.com/mbjoseph/CARstan>

> Stan 也往往充满各种技巧，不得要领往往陷入计算效率低的窘境。虽然 NUTS 可以处理参数存在的相关性问题，但不等于解决，所以如果能尽可能地用技巧降低相关性可以极大地提高参数后验分布的抽样效率

## 运行环境

> **注意**
> 
> 不知什么原因，总是不能将两个 Stan 模型在一个 R 会话框中运行，运行完一个 Stan 模型后，运行另一个就会导致 R 控制台崩溃退出，所以我打包了一个容器。在容器中运行完两个模型，将R工作空间保存下来，经测试，再在 Windows 下打开，可以完成后续分析，这是 `*.RData` 文件的胜利！有 38.8M ！

Stan 编译环境的设置如下

```r
writeLines(readLines("~/.R/Makevars"))
```
```
CXXFLAGS += -Wno-ignored-attributes
CXX14 = g++
CXX14FLAGS = -fPIC -flto=2 -mtune=native -march=native
CXX14FLAGS += -Wno-unused-variable -Wno-unused-function -Wno-unused-local-typede
fs
CXX14FLAGS += -Wno-ignored-attributes -Wno-deprecated-declarations -Wno-attribut
es -O3
```

R 控制台的运行环境如下

```r
sessionInfo()
```
```
R version 3.6.1 (2019-07-05)
Platform: x86_64-pc-linux-gnu (64-bit)
Running under: Ubuntu 16.04.6 LTS

Matrix products: default
BLAS:   /opt/R/R-3.6.1/lib/R/lib/libRblas.so
LAPACK: /opt/R/R-3.6.1/lib/R/lib/libRlapack.so

locale:
 [1] LC_CTYPE=en_US.UTF-8       LC_NUMERIC=C
 [3] LC_TIME=en_US.UTF-8        LC_COLLATE=en_US.UTF-8
 [5] LC_MONETARY=en_US.UTF-8    LC_MESSAGES=en_US.UTF-8
 [7] LC_PAPER=en_US.UTF-8       LC_NAME=C
 [9] LC_ADDRESS=C               LC_TELEPHONE=C
[11] LC_MEASUREMENT=en_US.UTF-8 LC_IDENTIFICATION=C

attached base packages:
[1] stats     graphics  grDevices utils     datasets  methods   base

other attached packages:
[1] rstan_2.19.2          StanHeaders_2.18.1-10 ggplot2_3.2.0

loaded via a namespace (and not attached):
 [1] Rcpp_1.0.2         magrittr_1.5       tidyselect_0.2.5   munsell_0.5.0
 [5] colorspace_1.4-1   R6_2.4.0           rlang_0.4.0        dplyr_0.8.3
 [9] tools_3.6.1        parallel_3.6.1     pkgbuild_1.0.4     grid_3.6.1
[13] gtable_0.3.0       loo_2.1.0          cli_1.1.0          withr_2.1.2
[17] matrixStats_0.54.0 lazyeval_0.2.2     assertthat_0.2.1   tibble_2.1.3
[21] crayon_1.3.4       processx_3.4.1     gridExtra_2.3      purrr_0.3.2
[25] callr_3.3.1        codetools_0.2-16   ps_1.3.0           inline_0.3.15
[29] glue_1.3.1         compiler_3.6.1     pillar_1.4.2       prettyunits_1.0.2
[33] scales_1.0.0       stats4_3.6.1       pkgconfig_2.0.2
```
