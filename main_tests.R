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




