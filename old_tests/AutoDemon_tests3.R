## sudo docker run -d -p 4445:4444 -p 5901:5900 selenium/standalone-firefox-debug:2.53.0    
##

library(RSelenium)
library(stringr)
library(XML)

remDr <- remoteDriver(port = 4445L)
remDr$open()

source('AutoDemOn_functions.R')

loginStatusCheck()

remDr$navigate("https://app.bto.org/demography/bto/main/ringing-reports/recoveryReports.jsp")

remDr$navigate("https://app.bto.org/demography/bto/main/data-entry/list-style/list-input.jsp?%40=448")

### Find input setup name:
input_field_name = remDr$findElement(using = "id", "currentFieldSetup")
input_field_name$getElementText()[[1]]

### Click input settings button:
settings_button = remDr$findElement(using = "id", "settingsButton")
settings_button$clickElement()

### Access "settings" popover:
settings_popover = remDr$findElements(using = "id", "settingsPopover")

### Select "record type" == "F"
record_type_F = remDr$findElement(using = "xpath", "//*[contains(text(),'Field observation')]")
record_type_F$clickElement()

### Select "record type" == "N"
# record_type_N = remDr$findElement(using = "xpath", "//*[contains(text(),'New bird - Standard capture and release')]")
# record_type_N$clickElement()

### Select ring no. box:
#ring_no = remDr$findElement(using = "xpath", "/html/body/div[1]/div/div/div[3]/div[1]/div/div[4]/div/div[4]/div[2]/div[1]/form/table/tbody/tr[2]/td[4]/input")
ring_no = remDr$findElement(using = "css", "input[name='ring_no']")

# Enter ring number:
#ring_no$sendKeysToElement(list("GR90725"))
ring_no$sendKeysToElement(list("GR90725", key = "tab"))

### Select Scheme box to see if completed ok:
scheme = remDr$findElement(using = "css", "select[name='scheme']")
scheme$getElementAttribute("value")[[1]]

### Get and check species:
species = remDr$findElement(using = "css", "input[name='species_name']")
species$getElementAttribute("value")[[1]]

### Age:
age = remDr$findElement(using = "css", "select[name='age']")
age$getElementAttribute("value")[[1]]

### 
vdate = remDr$findElement(using = "css", "input[name='visit_date']")
vdate$getElementAttribute("value")[[1]]
vdate$sendKeysToElement(list("11/07/2020", key = "tab"))

loc = remDr$findElements(using = "xpath", "//*[contains(text(),'Field observation')]")


new_loc = remDr$findElements(using = "id", "select2-drop")

new_loc$clickElement()




new_loc = remDr$findElement(using = "xpath", "//*[contains(text(),'Add New Location')]")

new_dropdown = remDr$findElements(using = "xpath", "//*[@id='select2-drop-mask']")
new_dropdown$highlightElement()

new_loc$clickElement()

//*[@id="select2-result-label-3226"]


new_loc = remDr$findElement(using = "xpath", "//*[@id='select2-result-label-546']")

new_loc$highlightElement()

new_loc$clickElement()



reportdat$sp <- as.vector(reportdat$sp)
reportdat$ring <- as.vector(reportdat$ring)
reportdat$rdate <- as.vector(reportdat$rdate)
reportdat$fdate <- as.vector(reportdat$fdate)


reportdat_find <- reportdat[reportdat$type=="Finding",]
reportdat_ring <- reportdat[reportdat$type=="Ringing",]

reportdat_find$proc <- NA
for(i in 1:nrow(reportdat_find)) {
  dat_i <- find_Ring(r = reportdat_find[i,"ring"],
                     s = reportdat_find[i,"sp"],
                     date_lookup = reportdat_find[i,"fdate"]
                     )
  reportdat_find$proc[i] <- as.vector(dat_i$`Processor Initials`)
}

reportdat_ring$proc <- NA
for(i in 1:nrow(reportdat_ring)) {
  dat_i <- find_Ring(r = reportdat_ring[i,"ring"],
                     s = reportdat_ring[i,"sp"],
                     date_lookup = reportdat_ring[i,"rdate"]
  )
  reportdat_ring$proc[i] <- as.vector(dat_i$`Processor Initials`)
}

reportdat <- rbind(reportdat_find,reportdat_ring)

save(reportdat, file = "test_reportdat.Rdata")








### List recovery reports:
recs <- remDr$findElements(using = "tag name", value="tr")

for(i in 3:length(recs)) {
  
  ## repeat number shown etc
  recs <- remDr$findElements(using = "tag name", value="tr")
  rec <- recs[[i]]
  Sys.sleep(1)
  
  #rec$clickElement()
  #Sys.sleep(1)
  
  base_dat <- rec$getElementText()[[1]]
  Sys.sleep(1)
  base_dat <- strsplit(base_dat, " ")[[1]]
  type <- base_dat[1]
  ring <- base_dat[4]
  
  rec$clickElement()
  #remDr$getWindowHandles()
  remDr$switchToWindow(remDr$getWindowHandles()[[2]])
  Sys.sleep(1)
  
  ageSexSection <- remDr$findElements(using = "class", value = "ageSexSection")
  Sys.sleep(1)
  ageSexSection <- ageSexSection[[1]]$getElementText()[[1]]
  age <- paste(strsplit(ageSexSection," ")[[1]][1:2], collapse=" ")
  sex <- paste(strsplit(ageSexSection," ")[[1]][3:4], collapse=" ")
  agesex <- paste(age, sex, sep=", ")
  
  summarySection <- remDr$findElements(using = "class", value = "quickSummarySection")[[1]]$getElementText()
  Sys.sleep(1)
  summarySection <- summarySection[[1]]
  
  sp <- gsub(".*Species: (.+) Scheme.*", "\\1", summarySection)

  fdate <- remDr$findElements(using = "xpath", '//*[contains(text(),"Finding date")]')
  Sys.sleep(1)
  fdate <- fdate[[1]]$getElementText()[[1]]
  fdate <- strsplit(fdate," ")[[1]][3]
  
  rdate <- remDr$findElements(using = "xpath", '//*[contains(text(),"Ringing date")]')
  Sys.sleep(1)
  rdate <- rdate[[1]]$getElementText()[[1]]
  rdate <- strsplit(rdate," ")[[1]][3]
  
  rplace <- remDr$findElements("class", "regPlaceCodeSection")
  Sys.sleep(1)
  rplace <- rplace[[1]]$getElementText()[[1]]
  rplace <- strsplit(rplace, ": ")[[1]]
  rplace <- tail(rplace,1)
  
  fplace <- remDr$findElements("class", "spanRow")
  Sys.sleep(1)
  fplace_with_name <- unlist(lapply(fplace, function(x) grepl("Site name: ",x$getElementText()) ))
  fplace_with_name <- which(fplace_with_name)
  fplace <- fplace[[fplace_with_name[2]]]$getElementText()[[1]]
  fplace <- strsplit(fplace, ": ")[[1]]
  fplace <- tail(fplace,1)
  
  cmarks <- remDr$findElements("class", "colourMarks")
  cm <- ext_colourMarkString(cmarks)
  
  recdat <- list(type = type, sp = sp, ring = ring, cm = cm, rdate = rdate, 
                 rplace = rplace, agesex=agesex, fdate = fdate, fplace = fplace)
  
  Sys.sleep(1)

  remDr$closeWindow()
  remDr$switchToWindow(remDr$getWindowHandles()[[1]])
}



logoutB <- remDr$findElements(using = "xpath", '//*[contains(text(),"Logout")]')
logoutB[[1]]$clickElement()

### First one:
rec <- recs[[3]]
rec$clickElement()

remDr$getWindowHandles()
remDr$switchToWindow(remDr$getWindowHandles()[[2]])
remDr$getTitle()
remDr$getCurrentUrl()

remDr$closeWindow()
remDr$getWindowHandles()[[1]]
remDr$switchToWindow(remDr$getWindowHandles()[[1]])
remDr$getCurrentUrl()




filters <- remDr$findElements(using = "class", value="tableFilterBox")
filter_date <- filters[[2]]
filter_date$sendKeysToElement(list("2018-12"), key="enter")

recs <- remDr$findElements(using = "tag name", value="tr")
rec <- recs[[3]]
rec$clickElement()
remDr$switchToWindow(remDr$getWindowHandles()[[2]])
remDr$getCurrentUrl()

htmlParse(remDr$getPageSource()[[1]])

ageSexSection <- remDr$findElements(using = "class", value = "ageSexSection")
ageSexSection <- ageSexSection[[1]]$getElementText()[[1]]

summarySection <- remDr$findElements(using = "class", value = "quickSummarySection")[[1]]$getElementText()
summarySection <- summarySection[[1]]

sp <- str_match(summarySection, "Species: (.*?) Scheme:")[,2]
ring <- str_match(summarySection, "Ring no: (.*)")[,2]

fdate <- remDr$findElements(using = "class", value = "spanRow")
fdate <- fdate[[9]]$getElementText()[[1]]
fdate <- str_match(fdate, "Finding date: (.*)")[,2]

### THIS IS FAR MORE EFFECTIVE:

fdate <- remDr$findElements(using = "xpath", '//*[contains(text(),"Finding date")]')
fdate[[1]]$getElementText()[[1]]


# Record data as XML:
xmlParse(remDr$getPageSource()[[1]])
# Convert XML rec data to list:
xml_rec_data <- xmlToList(xmlParse(remDr$getPageSource()[[1]]))
json_rec_data <- toJSON(xml_rec_data)



### Look up ring number in ringing database:
remDr$closeWindow()
remDr$switchToWindow(remDr$getWindowHandles()[[1]])
remDr$navigate("https://app.bto.org/demography/bto/main/search_new/records.jsp")
Sys.sleep(5)
remDr$getCurrentUrl()

# ### Select the button groups:
# selectB <- remDr$findElements(using = "class", 'btn-group')
# ### Apparently number 8 is the "Accepted" toggle - NOTE NEED A BETTER WAY OF FINDING THIS IN PAGE
# selectB[[8]]$clickElement()

### Try to find by "Accepted":
#recordFilters <- remDr$findElements("css selector", "#recordFilters > div")
recordFilters <- remDr$findElements("css selector", "#recordFilters")
recordFilters <- strsplit(recordFilters[[1]]$getElementText()[[1]],"\n")[[1]]
selectB <- remDr$findElements(using = "class", 'btn-group')
acc_filter <- which(recordFilters == "Accepted")
### Select "accepted" button using index found above:
selectB[[acc_filter]]$clickElement()

sp_search <- remDr$findElement(using = "css selector", value = "#s2id_autogen18")
sp_search$sendKeysToElement(list("BLHGU", key="enter"))   ###OOPS

dateSelectors <- remDr$findElements("css selector", "#dateFilters > div > div > input")
# Start date
dateSelectors[[1]]$sendKeysToElement(list("01/02/2019", key="enter"))
# End date
dateSelectors[[2]]$sendKeysToElement(list("20/06/2019", key="enter"))

ring_search <- remDr$findElement(using = "css selector", value = "#s2id_autogen2")
ring_search$sendKeysToElement(list("EX57490", key = "enter"))

# .. and search:

search_button <-remDr$findElement(using = "css selector", value = ".searchBtn")
search_button$clickElement()
