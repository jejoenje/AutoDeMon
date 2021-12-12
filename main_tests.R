library(RSelenium)
library(XML)

source("AutoDemOn_functions.R")
rD <- rsDriver(
      port = 4480L,
      browser = c("firefox"),
      version = "latest",
    )
remDr <- rD$client

demonLogin(u = Sys.getenv("autod_u"), p = Sys.getenv("autod_p"))

switchOperatingGroup(sel = "Tay Ringing Group")

z <- find_Ring("GR50844")


### Testing extracting from Ringing Recoveries:

sel <- "GR50844"
  
remDr$navigate("https://app.bto.org/demography/bto/main/ringing-reports/recoveryReports.jsp")

rtab <- remDr$findElements("id", "reportTable")

rtab_names <- names(html_table(read_html(rtab[[1]]$getElementAttribute("outerHTML")[[1]]))[[1]])

ftab <- remDr$findElements("class", "tableFilterBox")

ftab[[which(rtab_names=="Ring No")]]$sendKeysToElement(list(sel,key = "enter"))

### Set display list to 100 
### Get number of records to show and set to 100 (element 4)
no_show <- remDr$findElements("css", "#reportTable_length option")[[4]]
no_show$clickElement()

rtab[[1]]$clickElement()

### Need to switch tab now
switchTo <- remDr$getWindowHandles()[[2]]

remDr$switchToWindow(switchTo)

sum_dat <- as.data.frame(html_table(read_html(sum_section[[1]]$getElementAttribute("outerHTML")[[1]])))
ring <- sum_dat[1,6]

ageSexSection <- remDr$findElements(using = "class", value = "ageSexSection")
ageSexSection <- ageSexSection[[1]]$getElementText()[[1]]
age <- paste(strsplit(ageSexSection," ")[[1]][1:2], collapse=" ")
sex <- paste(strsplit(ageSexSection," ")[[1]][3:4], collapse=" ")
agesex <- paste(age, sex, sep=", ")

summarySection <- remDr$findElements(using = "class", value = "quickSummarySection")[[1]]$getElementText()
summarySection <- summarySection[[1]]

sp <- gsub(".*Species: (.+) Scheme.*", "\\1", summarySection)

fdate <- remDr$findElements(using = "xpath", '//*[contains(text(),"Finding date")]')
fdate <- fdate[[1]]$getElementText()[[1]]
fdate <- strsplit(fdate," ")[[1]][3]

rdate <- remDr$findElements(using = "xpath", '//*[contains(text(),"Ringing date")]')
rdate <- rdate[[1]]$getElementText()[[1]]
rdate <- strsplit(rdate," ")[[1]][3]

rplace <- remDr$findElements("class", "regPlaceCodeSection")
rplace <- rplace[[1]]$getElementText()[[1]]
rplace <- strsplit(rplace, ": ")[[1]]
rplace <- tail(rplace,1)

fplace <- remDr$findElements("class", "spanRow")
fplace_with_name <- unlist(lapply(fplace, function(x) grepl("Site name: ",x$getElementText()) ))
fplace_with_name <- which(fplace_with_name)
fplace <- fplace[[fplace_with_name[2]]]$getElementText()[[1]]
fplace <- strsplit(fplace, ": ")[[1]]
fplace <- tail(fplace,1)

cmarks <- remDr$findElements("class", "colourMarks")
cm <- ext_colourMarkString(cmarks)

recdat <- data.frame(sp,ring,cm,rdate,rplace,agesex,fdate,fplace)

