# 从维基百科获取2020年美国各州人口、面积和人口密度
library(xml2) # read_html
library(magrittr)
library(rvest) # html_table/html_element
# 抓取维基百科页面数据
us_states <- read_html("https://en.wikipedia.org/wiki/List_of_states_and_territories_of_the_United_States_by_population_density")
# 提取表格数据
us_states_df <- us_states %>%
  html_element("table") %>%
  html_table(header = T)

# 提取 4 个列
us_states_df <- us_states_df[-c(1, nrow(us_states_df)), c(1, 5, 7, 10)]
# 重命名
colnames(us_states_df) <- c("state_or_territory", "population_density", "population", "land_area")

us_states_df$population_density <- as.numeric(us_states_df$population_density)

us_states_df$population <- gsub(pattern = ",", replacement = "", x = us_states_df$population)
us_states_df$population <- as.numeric(us_states_df$population)

us_states_df$land_area <- gsub(pattern = ",", replacement = "", x = us_states_df$land_area)
us_states_df$land_area <- as.numeric(us_states_df$land_area)

us_states_df$state_or_territory <- tolower(us_states_df$state_or_territory)

saveRDS(object = us_states_df, file = "~/Desktop/us_states.RDS")

library(ggplot2)
# 地图数据，仅包含美国大陆，不包含阿拉斯加、夏威夷和波多黎各领地
state_map <- map_data("state")
# 人口密度的数据和地图数据合并
state_map_pop <- merge(state_map, us_states_df, by.x = "region", by.y = "state_or_territory")
state_map_pop <- state_map_pop[order(state_map_pop$order), ]

# 绘图
ggplot(data = state_map_pop, aes(x = long, y = lat, group = group)) +
  geom_polygon(aes(group = group, fill = population_density)) +
  scale_fill_gradientn(
    trans = "log10", colors = hcl.colors(10),
    guide = guide_colourbar(
      barwidth = 25, barheight = 0.4,
      title.position = "top" # 图例标题位于图例上方
    )
  ) +
  coord_map(projection = "polyconic") +
  theme_void() +
  theme(legend.position = "bottom", plot.title = element_text(hjust = 0.5)) +
  labs(
    title = "Map of states shaded by population density (2020)",
    caption = "Data Source: U.S. Census Bureau",
    fill = "Population density (km^2)"
  )

