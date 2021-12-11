fulltab <- remDr$findElements(using = "xpath", '//*[contains(text(),"Raw fullscreen table")]')
fulltab[[1]]$clickElement()
fulltab <- remDr$findElements(using = "xpath", '//*[contains(text(),"All data")]')
fulltab[[3]]$clickElement()

test <- readHTMLTable(htmlParse(remDr$getPageSource()[[1]]))

remDr$switchToWindow(remDr$getWindowHandles()[[2]])

test <- readHTMLTable(htmlParse(remDr$getPageSource()[[1]]))[[1]]

demonLogin()

