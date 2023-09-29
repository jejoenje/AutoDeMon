library(RSelenium)
library(XML)
library(rvest)

source("src/utils.R")
rD <- rsDriver(
  browser = "firefox",
  port = 4555L,
  verbose = FALSE,
  chromever = NULL
)
remDr <- rD$client

demon_login(u = Sys.getenv("autod_u"), p = Sys.getenv("autod_p"))

switch_op_group(sel = "Tay Ringing Group")

z <- find_ring("GC86435", verbose = TRUE)

### Testing extracting from Ringing Recoveries:

# sel <- "GC86435"

# remDr$navigate(
#   "https://app.bto.org/demography/bto/main/ringing-reports/recoveryReports.jsp")

# rtab <- remDr$findElements("id", "reportTable")
# rtab_h <- rtab[[1]]$getElementAttribute("outerHTML")
# rtab_names <- rtab_h[[1]] %>%
#   read_html() %>%
#   html_table() %>%
#   as.data.frame() %>%
#   names()
# ring_filter <- which(rtab_names == "Ring.No")
# ftab <- remDr$findElements("class", "tableFilterBox")
# ftab[[ring_filter]]$sendKeysToElement(list(sel, key = "enter"))

# ### Get number of records to show and set to 100 (element 4)
# no_show <- remDr$findElements("css", "#reportTable_length option")[[4]]
# no_show$clickElement()

# ### Click first element in sightings list:
# rtab <- remDr$findElements("id", "reportTable")
# rtab[[1]]$clickElement()

# ### Need to switch tab now
# switch_to <- remDr$getWindowHandles()[[2]]
# remDr$switchToWindow(switch_to)

# sum_section <- remDr$findElements("class", "quickSummarySection")
# sum_section_h <- sum_section[[1]]$getElementAttribute("outerHTML")[[1]]
# sum_dat <- sum_section_h %>%
#   read_html() %>%
#   html_table() %>%
#   as.data.frame()
# ring <- sum_dat[1, 6]

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
