library(RSelenium)
source("AutoDemOn_functions.R")
remDr<- rsDriver(
      port = 4455L,
      browser = c("firefox"),
      version = "latest",
    )
remDr$open()
demonLogin(u = Sys.getenv("autod_u"), p = Sys.getenv("autod_p"))

