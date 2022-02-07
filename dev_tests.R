library(RSelenium)
library(XML)
library(rvest)

source("AutoDemOn_functions.R")
rD <- rsDriver(
  port = 4479L,
  browser = c("firefox"),
  version = "latest",
)
remDr <- rD$client

demonLogin(u = Sys.getenv("autod_u"), p = Sys.getenv("autod_p"))

loginStatusCheck()

switchOperatingGroup("Mr J Minderman")

### Data entry in DEFAULT ALL FIELDS setup:
remDr$navigate("https://app.bto.org/demography/bto/main/data-entry/list-style/list-input.jsp")

ifield <- remDr$findElements("name", "record_type_pseudo")
ifield[[1]]$sendKeysToElement(list("F", key="enter"))


### Data to be input:
d <- read.xlsx("test_entry_data/test1.xlsx", detectDates = TRUE)
# Iterate through data:
i <- 1
di <- d[i,]

# Record type:
ifield <- remDr$findElements("name", "record_type_pseudo")
ifield[[1]]$sendKeysToElement(list("F", key="enter"))

# Ring No.
ifield <- remDr$findElements("name", "ring_no")
ifield[[1]]$sendKeysToElement(list(di[,"Metal.Ring"], key="enter"))
# Tab out
ifield[[1]]$sendKeysToElement(list("", key = "tab"))

# Visit date
ifield <- remDr$findElements("name", "visit_date")
ifield[[1]]$sendKeysToElement(list(format(di[,"Date"],"%d/%m/%Y"), key="tab"))

# Location ### THIS WORKS BUT DOES NOT LIST AVAILABLE LOCATIONS
ifield <- remDr$findElements("id", "s2id_autogen8_search")
ifield[[1]]$sendKeysToElement(list("ABERDE", key = "tab"))


