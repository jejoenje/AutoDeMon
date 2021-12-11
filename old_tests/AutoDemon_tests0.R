library(RSelenium)
remDr <- remoteDriver(
  remoteServerAddr = "localhost",
  port = 4445L,
  browserName = "firefox"
)

remDr$open()

remDr$getStatus()

remDr$navigate("http://www.google.com/ncr")
remDr$getCurrentUrl()
remDr$navigate("http://www.bbc.co.uk")
remDr$getCurrentUrl()
remDr$goBack()
remDr$getCurrentUrl()
remDr$goForward()
remDr$getCurrentUrl()
remDr$refresh()

remDr$navigate("http://www.google.com/ncr")
webElem <- remDr$findElement(using = "name", value = "q")
webElem$getElementAttribute("name")

webElem$getElementAttribute("class")
webElem$getElementAttribute("id")

remDr$navigate("https://app.bto.org/demography/bto/public/login.jsp")

######

remDr$getStatus()
XML::htmlParse(remDr$getPageSource()[[1]])

remDr$navigate("https://app.bto.org/demography/bto/main/ringing-reports/recoveryReports.jsp")

XML::htmlParse(remDr$getPageSource()[[1]])

mainC <- remDr$findElement(using = "id", value = "reportTable")

dat <- readHTMLTable(XML::htmlParse(remDr$getPageSource()[[1]]))[[1]]
dat

### Filter by date (year/month):
remDr$refresh()
remDr$getCurrentUrl()
mainC <- remDr$findElement(using = "id", value = "reportTable")
filters <- remDr$findElements(using = "class", "tableFilterBox")
filter_date <- filters[[2]] # Note need more generic way to find names for filters
filter_date$sendKeysToElement(list("2019-03"))
dat <- readHTMLTable(XML::htmlParse(remDr$getPageSource()[[1]]))[[1]]
dat

### Need to wait a few seconds between refreshes.
### Also, is there a "cleaner" way to filter w/o refreshing??

remDr$refresh()
mainC <- remDr$findElement(using = "id", value = "reportTable")
filters <- remDr$findElements(using = "class", "tableFilterBox")
filter_date <- filters[[2]] # Note need more generic way to find names for filters
filter_date$sendKeysToElement(list("2019-02"))
dat <- readHTMLTable(XML::htmlParse(remDr$getPageSource()[[1]]))[[1]]
dat

recs <- remDr$findElement(using = "css selector", value = "tr")
recs_lines <- unlist(lapply(recs, function(x){x$getElementText()}))


webElems <- remDr$findElements(using = 'css selector', "tr")
resHeaders <- unlist(lapply(webElems, function(x){x$getElementText()}))
webElem <- webElems[[which(resHeaders == "Finding 2019-05-23 10:27:01 Z553743 Pied/White Wagtail Baron sur Odon")]]
webElem <- webElems[[3]]
webElem$clickElement()
remDr$getCurrentUrl()

#script <- 'var report = tab.row(this).data(); window.open("/demography/bto/main/ringing-reports/report.jsp?headless=true&id=" + report.ENC_FINAL_REC_REP_ID);'
script <- ''



odds_elems <- remDr$findElements(using = "class", "odd")
odds <- unlist(lapply(odds_elems, function(x) {x$getElementText()}))
evns_elems <- remDr$findElements(using = "class", "even")
evns <- unlist(lapply(evns_elems, function(x) {x$getElementText()}))
all <- c(odds,evns)

odds_elems[[1]]$clickElement
XML::htmlParse(remDr$getPageSource()[[1]])
remDr$getCurrentUrl()

remDr$navigate("https://app.bto.org/demography/bto/main/ringing-reports/report.jsp?headless=true&id=5716049")
