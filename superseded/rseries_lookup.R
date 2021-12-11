## sudo docker run -d -p 4445:4444 -p 5901:5900 selenium/standalone-firefox-debug:2.53.0    
##

library(RSelenium)
library(stringr)
library(XML)

source("extractSeries.R")
source('AutoDemOn_functions.R')

rsers <- loadSeriesData("~/Dropbox/000_Ringing/Tay RG/ctl9093-190915.exp")

rsers_working <- rsers[rsers$init=="JM" & rsers$size=="B",]
rsers_working <- rsers_working[order(rsers_working$first, decreasing = T),]

remDr <- remoteDriver(port = 4445L)
remDr$open()

demonLogin()

tocheck <- buildSeries(rsers_working[i,"first"],rsers_working[i,"n"])

findWildCardBase <- function(x) {
  x_vars <- strsplit(tocheck[1],"")[[1]] == strsplit(tocheck[length(tocheck)],"")[[1]]
  last_fix <- which(x_vars==FALSE)[1]-1
  wildcard <- strsplit(x[1],"")[[1]][1:last_fix]
  return(paste(wildcard, collapse=""))
}

check_wildcard <- paste(findWildCardBase(tocheck),"%",sep="")

series_dat <- find_Ring(r = check_wildcard)

sum(tocheck %in% as.vector(series_dat$`Ring No`))


### Adding a series of rings to search box
tocheck1 <- tocheck[1]
tocheck2 <- tocheck[1:50]
for(i in 1:length(tocheck2)) {
  ring_search$sendKeysToElement(list(tocheck2[i], key = "tab"))
  Sys.sleep(0.1)
}

