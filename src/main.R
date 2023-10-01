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
r <- "GC86401"

z <- records(r, verbose = FALSE)

### Testing extracting from Ringing Recoveries:

x <- recoveries(ring = r, verbose = TRUE)
