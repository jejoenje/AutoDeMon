## sudo docker run -d -p 4445:4444 -p 5901:5900 selenium/standalone-firefox-debug:2.53.0    
##

library(RSelenium)
library(stringr)
library(XML)

remDr <- remoteDriver(port = 4445L)
remDr$open()

source('AutoDemOn_functions.R')

remDr$navigate("https://app.bto.org/demography/bto/public/login.jsp")

loginStatusCheck()

remDr$navigate("https://app.bto.org/demography/bto/main/locations/locations.jsp?%40=447")

listButton = remDr$findElements(using = "xpath", "//*[contains(text(),'List View')]")
listButton[[1]]$clickElement()

#locationsButton = remDr$findElements(using = "xpath", "//*[contains(text(),'Locations')]")
locationsButton = remDr$findElements(using = "xpath", "/html/body/div[1]/div/div/div[3]/div[1]/div[3]/div[2]/div[1]/div[2]/div[3]/div/button[1]")
locationsButton[[1]]$clickElement()

### Extract locations table:
loctable = remDr$findElements(using = "xpath", '//*[@id="locationsTable"]')
loctable = loctable[[1]]$getElementAttribute("outerHTML")[[1]]
locTable = readHTMLTable(loctable)[[1]]


