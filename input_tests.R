### Data entry tests
library(RSelenium)
library(XML)
library(rvest)

source("AutoDemOn_functions.R")
rD <- rsDriver(
  port = 4486L,
  browser = c("firefox"),
  version = "latest",
)
remDr <- rD$client

demonLogin(u = Sys.getenv("autod_u"), p = Sys.getenv("autod_p"))

loginStatusCheck()

switchOperatingGroup("Mr J Minderman")

### Raw data locations 
dat_file_folder <- "../NESgulls/data/base/"
dat_file_name <- "NESgulls.xlsx"
dat_file <- paste0(dat_file_folder, dat_file_name)
### BACKUP DATA FILE
file.copy(dat_file, paste0(dat_file_folder, gsub("\\.", "_backup.", dat_file_name)), overwrite = TRUE)

### Load data (ALL - need to do this to reconstruct):
sheet_names <- getSheetNames(dat_file)
sheet_no <- length(sheet_names)
DAT <- list()
for(i in 1:sheet_no) {
  DAT[[i]] <- readWorkbook(dat_file, sheet = sheet_names[i], detectDates = TRUE)
}
names(DAT) <- sheet_names

### Set up output data for saving:
OUT <- createWorkbook()
for(i in 1:sheet_no) {
  addWorksheet(OUT, sheetName = sheet_names[i])
  writeData(OUT, sheet = sheet_names[i], DAT[[i]] )
}

### Select section of data - e.g. HERRING GULLS
sel_sheet <- "HERRING GULLS"
d <- DAT[[sel_sheet]]

### Process input data
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
i <- 4

dd_i <- dd[i,]

# Record type:
ifield <- remDr$findElements("name", "record_type_pseudo")
ifield[[1]]$sendKeysToElement(list("F", key="enter"))

# Ring No:
ifield <- remDr$findElements("name", "ring_no")
ifield[[1]]$sendKeysToElement(list(dd_i[,"Metal.Ring"], key="tab"))
Sys.sleep(0.5)
# Visit date:
ifield <- remDr$findElements("name", "visit_date")
ifield[[1]]$clearElement()
ifield[[1]]$sendKeysToElement(list(format(dd_i[,"Date"],"%d/%m/%Y"), key="tab"))
ifield[[1]]$click()
Sys.sleep(0.5)

# ifield <- remDr$findElements("class name", "chosenFieldSetup")
# ifield[[11]]$clickElement()

# Location:
### Tab to it
#ifield <- remDr$findElements("name", "capture_time")
#ifield[[1]]$sendKeysToElement(list("", key="tab"))
#ifield <- remDr$findElements("id", "s2id_autogen7")

ifield <- remDr$findElements("class name", "select2-arrow")
ifield[[3]]$clickElement()
Sys.sleep(0.5)
ifield <- remDr$findElements("id", "s2id_autogen8_search")   #### THIS LOCATOR DOES NOT WORK ON SECOND GOES ETC
ifield[[1]]$sendKeysToElement(list(dd[i,"SiteCode"], key = "enter"))
Sys.sleep(0.5)

# Finding circumstances
ifield <- remDr$findElement("name", "finding_circumstances")
ifield$clickElement()
Sys.sleep(0.5)
ifield <- remDr$findElement(using = 'xpath', value = "//*[@value='81']")
ifield$clickElement()
Sys.sleep(0.5)

### Left Leg Below
ifield <- remDr$findElements("name", "left_leg_below")
ifield[[1]]$sendKeysToElement(list(paste0("YN(",dd[i,"Code"],")"), key = "tab"))
Sys.sleep(0.5)
### Right Leg Below
ifield <- remDr$findElements("name", "right_leg_below")
ifield[[1]]$sendKeysToElement(list("M", key = "tab"))
Sys.sleep(0.5)

### Finder name
ifield <- remDr$findElements("name", "finder_name")
ifield[[1]]$sendKeysToElement(list(dd[i,"Observer/Notes"], key = "tab"))
Sys.sleep(0.5)

### NEEDS TO BE DONE AFTER ITERATION LOOP

### "Tick off" value in raw input data:
d[which(d[,"idx"]==dd_i[,"idx"]),"SUBM"] <- "autodemon"
d$Date <- as.character(format(d$Date, "%d/%m/%Y"))
### Save to output
writeData(OUT, sheet = sel_sheet, d )
saveWorkbook(OUT, file = paste0(dat_file_folder,"NESgulls_autodemon.xlsx"), overwrite = TRUE)
