library(RSelenium)
library(XML)
library(rvest)

source("src/utils.R")

### Docker running
remDr <- remoteDriver(port = 4445L)
remDr$open(silent = TRUE)

### Standalone running (no Docker)
# rD <- rsDriver(browser ="firefox",
#                port = 4556L,
#                verbose = FALSE,
#                chromever = NULL)
# remDr <- rD$client

demon_login(u = Sys.getenv("autod_u"), p = Sys.getenv("autod_p"))

switch_op_group(sel = "Tay Ringing Group")

#r <- "GR50165"
#r <- "GR24996"
#r <- "GR24997"
#r <- "GR24999"
#r <- "GR24971" ### works?
#r <- "GR24954" ### doesn't?
#r <- "GR24957"
#r <- "GR24959"
#r <- "GC86401"
r <- "GR88061"
r2 <- "GR57316"

z <- records(r, verbose = FALSE, date_lookup = "12/08/2015")
y <- records(r2, verbose = FALSE, op_group = "Grampian Ringing Group", date_lookup = "05/06/2013")

### Testing extracting from Ringing Recoveries:

x <- recoveries(ring = r, verbose = TRUE)
