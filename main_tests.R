library(RSelenium)
library(XML)

source("AutoDemOn_functions.R")
rD <- rsDriver(
      port = 4477L,
      browser = c("firefox"),
      version = "latest",
    )
remDr <- rD$client

demonLogin(u = Sys.getenv("autod_u"), p = Sys.getenv("autod_p"))

switchOperatingGroup(sel = "Tay Ringing Group")


