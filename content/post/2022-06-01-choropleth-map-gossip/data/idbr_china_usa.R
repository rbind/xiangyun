library(idbr)

# the US Census Bureau International Data Base API
idb_api_key("YOUR_DATA_API_KEY")

countrycode::countryname("China", destination = "iso2c")

dat <- get_idb(c("US", "China"), year = 1960:2030, sex = c("male", "female"))
saveRDS(object = dat, file = "idbr_china_usa.rds")

dat <- readRDS(file = "idbr_china_usa.rds")
