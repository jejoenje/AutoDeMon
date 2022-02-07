### Data entry tests
library(RSelenium)
library(XML)
library(rvest)

source("AutoDemOn_functions.R")
rD <- rsDriver(
  port = 4484L,
  browser = c("firefox"),
  version = "latest",
)
remDr <- rD$client

demonLogin(u = Sys.getenv("autod_u"), p = Sys.getenv("autod_p"))

loginStatusCheck()

switchOperatingGroup("Mr J Minderman")

### HERGU raw data
d <- read.xlsx("../NESgulls/data/base/NESgulls.xlsx", sheet = "HERRING GULLS", detectDates = TRUE)
d$Type <- factor(d$Type)

### Sightings or Recoveries only:
dd <- d[d$Type == "Sighting" | d$Type == "Recovery",]
### Select unsubmitted data
dd <- dd[is.na(dd$SUBM),]
### drop levels
dd <- droplevels(dd)
levels(dd$Type)
### Pick values with site code:
dd <- dd[!is.na(dd$SiteCode),]

### Pick the most recent 10:
dd <- head(dd[order(dd$Date, decreasing = T),],10)

### Data entry in DEFAULT ALL FIELDS setup:
remDr$navigate("https://app.bto.org/demography/bto/main/data-entry/list-style/list-input.jsp")

### Switch to all fields input:
ifield <- remDr$findElements("id", "settingsButton")
ifield[[1]]$clickElement()
ifield <- remDr$findElements("name", "field-setup-list")
#ifield[[1]]$sendKeysToElement(list("All base Capture Fields Setup for Export"))
ifield[[1]]$sendKeysToElement(list("CRING RESIGHTINGS GULLS"))
#ifield <- remDr$findElements("id", "settingsButton")
ifield <- remDr$findElements("id", "settingsButton")
ifield[[1]]$clickElement()

###### ITERATE DATA ENTRY:
i <- 3

dd_i <- dd[i,]

# Record type:
ifield <- remDr$findElements("name", "record_type_pseudo")
ifield[[1]]$sendKeysToElement(list("F", key="enter"))

# Ring No:
ifield <- remDr$findElements("name", "ring_no")
ifield[[1]]$sendKeysToElement(list(dd_i[,"Metal.Ring"], key="tab"))
# Visit date:
ifield <- remDr$findElements("name", "visit_date")
ifield[[1]]$sendKeysToElement(list(format(dd_i[,"Date"],"%d/%m/%y"), key="enter"))
ifield[[1]]$click()

# ifield <- remDr$findElements("class name", "chosenFieldSetup")
# ifield[[11]]$clickElement()

# Location:
### Tab to it
#ifield <- remDr$findElements("name", "capture_time")
#ifield[[1]]$sendKeysToElement(list("", key="tab"))
#ifield <- remDr$findElements("id", "s2id_autogen7")

ifield <- remDr$findElements("class name", "select2-arrow")
ifield[[3]]$clickElement()
ifield <- remDr$findElements("id", "s2id_autogen8_search")
ifield[[1]]$sendKeysToElement(list(dd[i,"SiteCode"], key = "enter"))

# Finding circumstances
ifield <- remDr$findElement("name", "finding_circumstances")
ifield$clickElement()
ifield <- remDr$findElement(using = 'xpath', value = "//*[@value='81']")
ifield$clickElement()

### Left Leg Below
ifield <- remDr$findElements("name", "left_leg_below")
ifield[[1]]$sendKeysToElement(list(paste0("YN(",dd[i,"Code"],")"), key = "tab"))
### Right Leg Below
ifield <- remDr$findElements("name", "right_leg_below")
ifield[[1]]$sendKeysToElement(list("M", key = "tab"))

### Finder name
ifield <- remDr$findElements("name", "finder_name")
ifield[[1]]$sendKeysToElement(list(dd[i,"Observer/Notes"], key = "tab"))

