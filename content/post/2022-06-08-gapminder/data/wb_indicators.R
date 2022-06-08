library(wbstats)
# 指标
fresh_indicators <- wb_indicators()
# 保存
saveRDS(fresh_indicators, file = "data/wb_indicators.rds")

fresh_indicators <- readRDS(file = "data/wb_indicators.rds")

# 指标描述中包含人口的指标
dat = subset(x = fresh_indicators, subset =  grepl(pattern = "Population", x = indicator) & grepl(pattern = "total", x = indicator))

# 只有 1960 年至今的数据
world_pop <- wbstats::wb(
  indicator = c(
    "SP.DYN.LE00.IN", # 预期寿命
    "NY.GDP.PCAP.CD", # 人均 GDP
    "SP.POP.TOTL" # 人口总数
  ),
  country = "countries_only", 
  startdate = 1960, enddate = 2021
)

# 保存
saveRDS(world_pop, file = "wb_world_pop.rds")

wb_indicators <- readRDS(file = "data/wb_indicators.rds")

# 注意：indicators 表示指标 index 表示指数 coefficient 表示系数
# Gini 系数
# The Gini coefficient is most common measure of inequality. 
# It is based on the Lorenz curve, a cumulative frequency curve 
# that compares the distribution of a specific variable (in this case, income) with 
# the uniform distribution that represents equality. 
# The Gini coefficient is bounded by 0 (indicating perfect equality of income) and 1, 
# which means complete inequality. This calculation includes observations of 0 income.
# Gini 指数
# Gini index measures the extent to which the distribution of income 
# (or, in some cases, consumption expenditure) among individuals 
# or households within an economy deviates from a perfectly equal distribution. 
# A Lorenz curve plots the cumulative percentages of total income received against 
# the cumulative number of recipients, starting with the poorest individual or household. 
# The Gini index measures the area between the Lorenz curve and 
# a hypothetical line of absolute equality, expressed as 
# a percentage of the maximum area under the line. 
# Thus a Gini index of 0 represents perfect equality, 
# while an index of 100 implies perfect inequality.
# 泰尔指数
# The Theil index is part of a larger family of measures referred to as the General Entropy class. 
# Compared to the Gini index, it has the advantage of being additive across different subgroups or regions in the country. 
# However, it does not have a straightforward representation and lacks the appealing interpretation of the Gini coefficient.

# FP.CPI.TOTL 消费价格指数 Consumer price index (2010 = 100)
# Consumer price index reflects changes in the cost to 
# the average consumer of acquiring a basket of goods 
# and services that may be fixed or changed at specified intervals, such as yearly. 
# The Laspeyres formula is generally used. Data are period averages.

# FP.CPI.TOTL.ZG 通货膨胀率 Inflation, consumer prices (annual %)
# Inflation as measured by the consumer price index reflects the annual percentage change 
# in the cost to the average consumer of acquiring a basket of goods and services 
# that may be fixed or changed at specified intervals, such as yearly. 
# The Laspeyres formula is generally used.


# SL.UEM.TOTL  失业人数 Number of people unemployed
# Unemployed is a person in the labour force, who at the reference period, 
# did not have a job but was actively looking for one.
# 9.0.Unemp.All # 失业率 Unemployed (%)
# Share of the labor force (ages 18-65) that is unemployed

# GDP per capita is the sum of gross value added 
# by all resident producers in the economy 
# plus any product taxes (less subsidies) not included in the valuation of output, 
# divided by mid-year population. 
# Growth is calculated from constant price GDP data in local currency. 
# Sustained economic growth increases average incomes 
# and is strongly linked to poverty reduction. 
# GDP per capita provides a basic measure of the value of output per person, 
# which is an indirect indicator of per capita income. 
# Growth in GDP and GDP per capita are considered broad measures of economic growth.

world_indicator <- wbstats::wb_data(
  indicator = c(
    "3.0.Gini", # Gini 系数
    "3.1.Gini", # Gini, Rural 农村
    "3.2.Gini", # Gini, Urban 城市
    
    "3.0.TheilInd1", # 泰尔指数 Theil Index, GE(1)
    "3.1.TheilInd1", # 泰尔指数 Theil Index, GE(1), Rural
    "3.2.TheilInd1", # 泰尔指数 Theil Index, GE(1), Urban
    
    "SL.UEM.TOTL",    # 失业人数
    "9.0.Unemp.All",  # 失业率 Unemployed (%)
    "FP.CPI.TOTL",    # 消费价格指数
    "FP.CPI.TOTL.ZG", # 通货膨胀率
    "SI.POV.GINI",    # Gini 指数
    
    "SP.DYN.LE00.IN", # 预期寿命
    "NY.GDP.PCAP.CD", # 人均 GDP
    "SP.POP.TOTL"     # 人口总数
  ),
  country = "countries_only", 
  start_date = 1960, end_date = 2021
)

saveRDS(world_indicator, file = "world_indicator.rds")

library(ggplot2)


