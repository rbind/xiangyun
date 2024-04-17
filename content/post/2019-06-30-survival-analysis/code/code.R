# 分析目的：患者在医生诊断后，需要等待多久时间来住院，
# 探索影响入院等待时间的因素，给出合理解释
# 用两种预测模型

# 随机森林、神经网络

# 读取数据
dat <- read.csv(file = "入院等待时间预测.csv", header = TRUE, check.names = FALSE)

# 门诊次：
# 住院次：
# 开住院条日期：
# 入院病情应该是有序的变量
options(tidyverse.quiet = TRUE)
library(tidyverse)


# 数据预处理
dat$性别 <- as.factor(dat$性别)
dat$入院疾病分类 <- as.factor(dat$入院疾病分类)
dat$入院目的 <- as.factor(dat$入院目的)
dat$住院类别 <- as.factor(dat$住院类别)
dat$入院病情 <- as.factor(dat$入院病情)
dat$Doctor <- as.factor(dat$Doctor)
# 数据变换和缺失值处理
dat$年龄 <- scale(dat$年龄) # (dat$年龄 - mean(dat$年龄))/sd(dat$年龄)
dat$门诊次 <- log(dat$门诊次)
dat$开住院条日期 <- ifelse(is.na(dat$开住院条日期), 0, dat$开住院条日期)
# transform(dat, 开住院条日期 = ifelse(is.na(开住院条日期), 0, 开住院条日期))
# 开住院条的日期缺失，极有可能就是没有办住院

# 数据汇总
summary(dat)

# aggregate(WaitingTime ~ 开住院条日期, data = dat, mean, na.rm = FALSE)

# 数据特点
# 根据开住院条的日期，划分数据集，将含有缺失的单独看作一类
dat[is.na(dat$开住院条日期), ] # 380 例
# 和整体的等待时间的分布形式比较一致，所以我们将其归为一类
boxplot(dat[is.na(dat$开住院条日期), "WaitingTime"])

# 等待时间具有长尾特点
hist(dat$WaitingTime)
boxplot(dat$WaitingTime)
# 异常数据怎么处理

# 取对数 分布正常了
boxplot(log(dat$WaitingTime))
# 注意处理特别的情况
# 等待时间为 0 是不是属于特别紧急的 根据入院病情来看，
# 有的属于紧急，有的不属于，不需要特别处理
# 对数高斯分布，允许随机变量取小于等于0的情况
dat[dat$WaitingTime == 0, ]
dat <- dat[complete.cases(dat) & dat$WaitingTime != 0, ]

# 等待时间0 入院病情 2 很相关 
subset(dat, WaitingTime == 0 & 入院病情 == 2)
subset(dat, WaitingTime == 0 & 入院病情 == 1)

# 数据要不要归一化，各个变量的尺度要不要统一一下，比如门诊次和年龄
# 去掉截距项
log.glm.fit <- glm(data = dat, formula = WaitingTime ~. - 1, 
                   family = gaussian(link = "log"))
log.glm.fit
summary(log.glm.fit)

fit <- lm(WaitingTime ~ . -1, data = dat)


# 逐步回归筛选变量 解释模型比较有帮助的，就是哪个因素比较重要
final.log.glm.fit<- step(log.glm.fit)

# COX-Box 变换

library(MASS)

# 生存分析
library(survival)



# 缺失数据怎么处理
unique(dat$开住院条日期)
# 包含缺失项的记录
dat[!complete.cases(dat), ]

# 描述统计 

library(ggplot2)
# 等待时间的分布 明显属于偏态
g1 <- ggplot(data = dat, aes(WaitingTime)) +
  geom_histogram()
g2 <- ggplot(data = dat, aes(y = WaitingTime)) +
  geom_boxplot()
# library(gridExtra)

library(cowplot)
plot_grid(g1, g2, labels = c('直方图', '箱线图'), label_size = 12)

grid.arrange(g1, g2, ncol = 2)


# 看一下分位点

range(dat$WaitingTime)
quantile(dat$WaitingTime)
summary(dat$WaitingTime)

nrow(subset(dat, WaitingTime > 23.80) )


# 不均衡，可能是普通门诊和专家门诊的区别
table(dat$Doctor)
# 和医生的关系
ggplot(data = dat, aes(x = Doctor, y = WaitingTime, color = Doctor)) + 
  geom_jitter()

# 和入院病情的关系：既然只有两例，大胆猜测就是紧急和不紧急两类
# 模型的意义应该是探索不紧急的情况下，等待多久时间来入院与什么因素有关
table(dat$入院病情) # 严重不均衡

ggplot(data = dat, aes(x = Doctor, y = WaitingTime, color = Doctor)) + 
  geom_jitter() +
  facet_grid(~入院病情)
  
# 建模

# 1.1 含有缺失项的记录直接去掉
# 1.2 含有等待时间特别长的记录视为异常值，直接去掉

# 1. 从收集的数据本身来看，等待时间服从什么分布
# 2. 从数据的产生过程来看，等待时间服从什么分布，时间 t >=0 
# 多长的时间视为病人不来了，数据本身应该是截断的，生存分析



对数正态分布


模拟对数正态分布

x = rlnorm(500,1,.6)
grid = seq(0,25,.1)
plot(grid,dlnorm(grid,1,.6),type="l",xlab="x",ylab="f(x)")
lines(density(x),col="red")
legend("topright",c("True Density","Estimate"),lty=1,col=1:2)



library(brms)

log_glm_brm_fit <- brm(
  data = sub_dat, formula = WaitingTime ~ . - 1,
  family = lognormal(link = "identity", link_sigma = "log")
)

Is log-linear regression a generalized linear model?
https://stats.stackexchange.com/questions/330412

How to specify a lognormal distribution in the glm family argument in R?
https://stats.stackexchange.com/questions/21447

What is the difference between a “link function” and a “canonical link function” for GLM
https://stats.stackexchange.com/questions/40876

Link function in a Gamma-distribution GLM
https://stats.stackexchange.com/questions/202570


