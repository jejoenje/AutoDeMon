library(RSelenium)
library(XML)
library(rvest)

source("src/utils.R")

### Docker running
remDr <- remoteDriver(port = 4445L)
remDr$open(silent = TRUE)

### Standalone running (no Docker)
# rD <- rsDriver(browser ="firefox",
#                port = 4556L,
#                verbose = FALSE,
#                chromever = NULL)
# remDr <- rD$client

demon_login(u = Sys.getenv("autod_u"), p = Sys.getenv("autod_p"))

switch_op_group(sel = "Tay Ringing Group")

z <- find_ring("GR50165", verbose = TRUE)

### Testing extracting from Ringing Recoveries:

x <- find_sightings(ring = "GR50165")


sum_section <- remDr$findElements("class", "quickSummarySection")
sum_section_h <- sum_section[[1]]$getElementAttribute("outerHTML")[[1]]
sum_dat <- sum_section_h %>%
  read_html() %>%
  html_table() %>%
  as.data.frame()
ring <- sum_dat[1, 6]


# as_section <- remDr$findElements(
#   using = "class",
#   value = "ageSexSection")
# as_section <- as_section[[1]]$getElementText()[[1]]
# age <- paste(strsplit(as_section, " ")[[1]][1:2], collapse = " ")
# sex <- paste(strsplit(as_section, " ")[[1]][3:4], collapse = " ")
# agesex <- paste(age, sex, sep = ", ")

# s_section <- remDr$findElements("class", "quickSummarySection")
# s_section <- s_section[[1]]$getElementText()
# s_section <- s_section[[1]]
# sp <- gsub(".*Species: (.+) Scheme.*", "\\1", s_section)

# fdate <- remDr$findElements(using = "xpath",
#   '//*[contains(text(),"Finding date")]')
# fdate <- fdate[[1]]$getElementText()[[1]]
# fdate <- strsplit(fdate, " ")[[1]][3]

# rdate <- remDr$findElements("xpath",
#   '//*[contains(text(),"Ringing date")]')
# rdate <- rdate[[1]]$getElementText()[[1]]
# rdate <- strsplit(rdate, " ")[[1]][3]

# rplace <- remDr$findElements("class", "regPlaceCodeSection")
# rplace <- rplace[[1]]$getElementText()[[1]]
# rplace <- strsplit(rplace, ": ")[[1]]
# rplace <- tail(rplace, 1)

# fplace <- remDr$findElements("class", "spanRow")
# fplace_with_name <- unlist(
#   lapply(fplace,
#     function(x) grepl("Site name: ", x$getElementText())))
# fplace_with_name <- which(fplace_with_name)
# fplace <- fplace[[fplace_with_name[2]]]$getElementText()[[1]]
# fplace <- strsplit(fplace, ": ")[[1]]
# fplace <- tail(fplace, 1)

# cmarks <- remDr$findElements("class", "colourMarks")
# cm <- ext_colourMarkString(cmarks)

# recdat <- data.frame(sp, ring, cm, rdate, rplace, agesex, fdate, fplace)
