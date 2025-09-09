# 获取京东、美团、拼多多股价数据，并可视化
library(quantmod)
quantmod::getSymbols(
  Symbols = c(
    "JD", # 京东
    "PDD", # 拼多多
    "BABA", # 阿里
    "DDL",  # 叮咚买菜
    "BILI", # B 站
    "AMZN", # 亚马逊
    "0700.HK", # 腾讯
    "9618.HK", # 京东
    "3690.HK", # 美团
    "9988.HK", # 阿里
    "1024.HK" # 快手
  ),
  auto.assign = TRUE, src = "yahoo"
)
save.image(file = "tech_stocks.RData")

# 美团季度财报

# 从财务报告来看，三者是层层下钻的关系，宏观、中观、微观
# 不仅是分析美团的财务，更重要的是理解分析方法

# 回答两个问题（整体概况）：第一规模有多大，第二挣不挣钱
# 分业务统计（分部拆解）：盈利或亏损来自什么业务
# 业务盈利或亏损的原因（归因分析）：业务策略、竞争对手、盈利模式等

# 净利润（亏损）: 非国际财务报告准则计量-经调整利润（亏损）净额
# 收入、毛利、经营利润、净利润的单位：人民币千元

# 如何从财报中抽取数据
mt = pdftools::pdf_data(pdf = "~/Downloads/美团财报/2019Q4.pdf")
mt[[1]]$text

tech_fin_report <- readxl::read_xlsx(path = "data/tech_fin_report.xlsx")

library(ggplot2)
showtext::showtext_auto()

# 转长格式
m = tidyr::pivot_wider(data = tech_fin_report, id_cols = c("公司", "年份", "日期"),
                       names_from =  "指标", values_from = "数值")

# 美团净利润的季度趋势变化像跑过山车一样
m |>
  dplyr::mutate(
    日期 = as.Date(日期),
    年份 = as.character(年份)
  ) |>
  ggplot(aes(x = `日期`, y = `净利润` / 100000)) +
  geom_col(aes(fill = `年份`), just = 1.5, data = ~ subset(.x, subset = `公司` == "美团")) +
  scale_x_date(date_breaks = "1 year", labels = function(x) zoo::format.yearqtr(x, "%yQ%q")) +
  scale_y_continuous(n.breaks = 10, labels = scales::label_number(suffix = "亿")) +
  guides(fill = guide_legend(reverse = TRUE)) +
  theme_bw() +
  labs(x = "季度", y = "净利润")

