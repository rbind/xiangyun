library(wbstats)
# 指标
wb_indicators <- wb_indicators()
# 保存
saveRDS(wb_indicators, file = "data/wb_indicators.rds")
# 读取数据
wb_indicators <- readRDS(file = "data/wb_indicators.rds")
