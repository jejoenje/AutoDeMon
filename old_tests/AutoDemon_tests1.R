library(RSelenium)
library(stringr)

remDr <- remoteDriver(port = 4445L)
remDr$open()

remDr$navigate("https://app.bto.org/demography/bto/public/login.jsp")
remDr$getTitle()

uname <- remDr$findElement(using = "css selector", value = "#username")
pword <- remDr$findElement(using = "css selector", value = "#password")

######

loginB <- remDr$findElement(using = 'css selector', ".btn-block")
loginB$clickElement()

Sys.sleep(5)

remDr$navigate("https://app.bto.org/demography/bto/main/ringing-reports/recoveryReports.jsp")

Sys.sleep(5)




### List report filters:
filters <- remDr$findElements(using = "class", value="tableFilterBox")
filter_date <- filters[[2]]
filter_date$sendKeysToElement(list("2019-02"))
# filter_date$clearElement()
#filter_date$sendKeysToElement(list("",key="enter"))


### Try to recover number of reports for present selection:
dataTables_info <- remDr$findElements(using = "class", value="dataTables_info")
dataTables_info <- dataTables_info[[1]]$getElementText()[[1]]

### Try to display 100 records
remDr$findElements(using = "class", value="form-control input-sm")

remDr$findElements(using = "class",


### List recovery reports:
recs <- remDr$findElements(using = "tag name", value="tr")
### First one:
rec <- recs[[3]]
rec$clickElement()

remDr$getWindowHandles()
remDr$switchToWindow("{1808178f-a083-4c25-99b4-acb2a95d4877}")
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
