# 加载数据
rongelap <- readRDS(file = "data/rongelap.rds")
rongelap_coastline <- readRDS(file = "data/rongelap_coastline.rds")

library(cmdstanr)
set_cmdstan_path(path = "/opt/cmdstan/cmdstan-2.32.2/")

###########################################################
## 克里金插值预测 SLMM 
###########################################################
nchains <- 4 # 4 条迭代链
set.seed(20232023)
# 给每条链设置不同的参数初始值
inits_data <- lapply(1:nchains, function(i) {
  list(
    alpha = rnorm(1),
    sigma = runif(1),
    phi = runif(1)
  )
})

# 准备数据
rongelap_krige_d <- list(
  N = nrow(rongelap), # 观测记录的条数
  D = 2, # 2 维坐标
  X = rongelap[, c("cX", "cY")] / 6000, # N x 2 坐标矩阵
  y = log(rongelap$counts / rongelap$time) # N 向量
)

# 编译模型
mod_rongelap_krige <- cmdstan_model(
  stan_file = "code/rongelap_gaussian.stan",
  compile = TRUE, cpp_options = list(stan_threads = TRUE)
)

# 编译模型
mod_rongelap_krige <- cmdstan_model(
  stan_file = "code/rongelap_gaussian_pred.stan",
  compile = TRUE, cpp_options = list(stan_threads = TRUE)
)

# 拟合模型
fit_rongelap_krige <- mod_rongelap_krige$sample(
  data = rongelap_krige_d, # 观测数据
  init = inits_data, # 迭代初值
  iter_warmup = 1000, # 每条链预处理迭代次数
  iter_sampling = 2000, # 每条链总迭代次数
  chains = nchains, # 马尔科夫链的数目
  parallel_chains = 4, # 指定 CPU 核心数，可以给每条链分配一个
  threads_per_chain = 1, # 每条链设置一个线程
  show_messages = FALSE, # 不显示迭代的中间过程
  refresh = 0, # 不显示采样的进度
  seed = 20232023 # 设置随机数种子，不要使用 set.seed() 函数
)

# 跑模型的时间花费 146.4s 
# 诊断
fit_rongelap_krige$diagnostic_summary()

# 输出结果
# 保留 6 位有效数字
fit_rongelap_krige$summary(variables = c("lp__", "alpha", "sigma", "phi"),
                           .num_args = list(sigfig = 6, notation = "dec"))

# 某个位置的预测值的后验分布
fit_rongelap_krige$draws(variables = "ypred[1]")
# 1 号和 10 号位置的预测值
mcmc_dens(fit_rongelap_krige$draws(variables = c("ypred[1]", "ypred[10]")),
          facet_args = list(
            labeller = ggplot2::label_parsed,
            strip.position = "top", ncol = 1
          )
) + theme_bw(base_size = 12)

# log_lik_multi 与 log_lik 的关系 
# log_lik_multi -90.0 不等于 sum(log_lik) -128.9 原因是每个位置之间的关系不是独立的
fit_rongelap_krige$summary(variables = c("log_lik_multi"))
fit_rongelap_krige$summary(variables = c("log_lik"))
# ypred 和 yhat 的关系
fit_rongelap_krige$summary(variables = c("ypred"))
fit_rongelap_krige$summary(variables = c("yhat"))

library(ggplot2)
library(bayesplot)
# 参数的迭代轨迹
mcmc_trace(fit_rongelap_krige$draws(c("sigma", "phi")),
           facet_args = list(
             labeller = ggplot2::label_parsed,
             strip.position = "top", ncol = 1
           )
) + theme_bw(base_size = 12)

# 参数的后验分布
mcmc_dens(fit_rongelap_krige$draws(c("sigma", "phi")),
          facet_args = list(
            labeller = ggplot2::label_parsed,
            strip.position = "top", ncol = 1
          )
) + theme_bw(base_size = 12)




library(sf)
library(abind)
library(stars)

rongelap_sf <- st_as_sf(rongelap, coords = c("cX", "cY"), dim = "XY")
rongelap_coastline_sf <- st_as_sf(rongelap_coastline, coords = c("cX", "cY"), dim = "XY")
rongelap_coastline_sfp <- st_cast(st_combine(st_geometry(rongelap_coastline_sf)), "POLYGON")

rongelap_coastline_buffer <- st_buffer(rongelap_coastline_sfp, dist = 50)
# 构造带边界约束的网格
rongelap_coastline_grid <- st_make_grid(rongelap_coastline_buffer, n = c(150, 75))
# 将 sfc 类型转化为 sf 类型
rongelap_coastline_grid <- st_as_sf(rongelap_coastline_grid)
rongelap_coastline_buffer <- st_as_sf(rongelap_coastline_buffer)
rongelap_grid <- rongelap_coastline_grid[rongelap_coastline_buffer, op = st_intersects]
# 计算网格中心点坐标
rongelap_grid_centroid <- st_centroid(rongelap_grid)

# 1612 个点
rongelap_grid_df <- as.data.frame(st_coordinates(rongelap_grid_centroid))
colnames(rongelap_grid_df) <- c("cX", "cY")


# 截距
beta <- 1.75176
# 范围参数
phi <- 0.0322392*6000
# 方差
sigma_sq <- 0.665897^2
# 自协方差函数
cov_fun <- function(h) sigma_sq * exp(-h / phi)
# 观测距离矩阵
m_obs <- cov_fun(st_distance(x = rongelap_sf))
# 预测距离矩阵
m_pred <- cov_fun(st_distance(x = rongelap_sf, y = rongelap_grid_centroid))
# 简单克里金插值 Simple Kriging
mean_sk <- beta + t(m_pred) %*% solve(m_obs, log(rongelap_sf$counts / rongelap_sf$time) - beta)
# 辐射强度预测值
rongelap_grid_df$pred_sk <- exp(mean_sk)
# 辐射强度预测方差
rongelap_grid_df$var_sk <- sigma_sq - diag(t(m_pred) %*% solve(m_obs, m_pred))

rongelap_grid_sf <- st_as_sf(rongelap_grid_df, coords = c("cX", "cY"), dim = "XY")


ggplot(data = rongelap_grid_sf) +
  geom_sf(aes(color = pred_sk), size = 0.5) +
  scale_color_viridis_c(option = "C") +
  theme_bw() +
  labs(x = "横坐标（米）", y = "纵坐标（米）", color = "预测值")

ggplot(data = rongelap_grid_sf) +
  geom_sf(aes(color = var_sk), size = 0.5) +
  scale_color_viridis_c(option = "C") +
  theme_bw() +
  labs(x = "横坐标（米）", y = "纵坐标（米）", color = "预测方差")


###########################################################
## 泊松 SGLMM 
###########################################################

# 准备数据
rongelap_poisson_d <- list(
  N = nrow(rongelap), # 观测记录的条数
  D = 2, # 2 维坐标
  X = rongelap[, c("cX", "cY")] / 6000, # N x 2 矩阵
  y = rongelap$counts, # 响应变量
  offsets = rongelap$time # 漂移项
)

set.seed(20232023)

inits_data <- lapply(1:nchains, function(i) {
  list(
    alpha = rnorm(1),
    sigma = runif(1),
    phi = runif(1),
    f = rnorm(157)
  )
})

# 编译模型
mod_rongelap_poisson <- cmdstan_model(
  stan_file = "code/rongelap_poisson.stan",
  compile = TRUE, cpp_options = list(stan_threads = TRUE)
)

# 拟合模型
fit_rongelap_poisson <- mod_rongelap_poisson$sample(
  data = rongelap_poisson_d, # 观测数据
  init = inits_data,    # 迭代初值
  iter_warmup = 1000,    # 每条链预处理迭代次数
  iter_sampling = 2000, # 每条链总迭代次数
  chains = nchains,     # 马尔科夫链的数目
  parallel_chains = 4,  # 指定 CPU 核心数，可以给每条链分配一个
  threads_per_chain = 1, # 每条链设置一个线程
  show_messages = FALSE, # 不显示迭代的中间过程
  refresh = 0,    # 不显示采样的进度
  seed = 20232023 # 设置随机数种子，不要使用 set.seed() 函数
)
# 跑模型的时间花费 216.9s 

fit_rongelap_poisson$diagnostic_summary()
# 参数的估计结果
fit_rongelap_poisson$summary(variables = c("lp__", "alpha", "sigma", "phi"))

# 参数的迭代轨迹
mcmc_trace(fit_rongelap_poisson$draws(c("sigma", "phi")),
           facet_args = list(
             labeller = ggplot2::label_parsed,
             strip.position = "top", ncol = 1
           )
) + theme_bw(base_size = 12)

# 参数的后验分布
mcmc_dens(fit_rongelap_poisson$draws(c("sigma", "phi")),
          facet_args = list(
            labeller = ggplot2::label_parsed,
            strip.position = "top", ncol = 1
          )
) + theme_bw(base_size = 12)

#
# 对数似然 log_lik
# 观测位置的预测值
# 未观测位置的预测值

# https://rpubs.com/NickClark47/stan_geostatistical
# multi_normal_cholesky
# https://mc-stan.org/docs/functions-reference/multi-normal-cholesky-fun.html
# poisson_log_lpmf
# https://mc-stan.org/docs/functions-reference/poisson-distribution-log-parameterization.html

# 未观测的位置 1020 个
dim(rongelap_grid_newdata)

ggplot(data = rongelap_grid_newdata, aes(x = cX,y=cY)) +
  geom_point()

# 含有多个参数，给定数据下的参数的后验分布的对数具有非常复杂的形式，计算 lp__
alpha = 1.77
sigma = 0.649
phi = 0.0285
Sigma <- sigma^2 * exp( as.matrix(dist(rongelap_krige_d$X)) / phi )

y <- rongelap_krige_d$y
