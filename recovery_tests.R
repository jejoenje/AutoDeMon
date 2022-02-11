### Data entry tests
library(RSelenium)
library(XML)
library(rvest)

source("AutoDemOn_functions.R")
rD <- rsDriver(
  port = 4487L,
  browser = c("firefox"),
  version = "latest",
)
remDr <- rD$client

demonLogin(u = Sys.getenv("autod_u"), p = Sys.getenv("autod_p"))

loginStatusCheck()

switchOperatingGroup("Tay Ringing Group")

