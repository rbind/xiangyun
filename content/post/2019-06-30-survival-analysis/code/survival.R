#
library(MASS)
b <- boxcox(WaitingTime ~ ., data = sub_dat)
i <- which(b$y == max(b$y))
b$x[i]

lm_fit <- lm(WaitingTime^0.14 ~ ., data = sub_dat)
step_lm_fit <- step(lm_fit)
summary(step_lm_fit)

