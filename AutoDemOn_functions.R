ext_colourMarkString <- function(el) {
  
  cm_vec1 <- c("LB","RB","LA","RA")
  cm_vec2 <- rep("",4)
  cm_vec <- cbind(cm_vec1, cm_vec2)
  
  for(i in 1:4) {
    txt <- el[[i]]$getElementText()[[1]]
    if(txt!="") {
      cm_vec[i,2] <- tail(strsplit(txt, " ")[[1]],1)  
    } 
  }
  
  cm_non_blank <- which(cm_vec[,2]!="")
  
  if(length(cm_non_blank)>1) {
    cm <- paste(apply(cm_vec[cm_non_blank,],1,function(x) paste(x,collapse="")),collapse=";")
  } else {
    cm <- paste(as.matrix(cm_vec[cm_non_blank,]),collapse="")
  }
  
  return(cm)
  
}

demonLogin <- function(u=NULL, p=NULL) {
  
  if(is.null(u) | is.null(p)) {
    if(!(as.logical(sum(grepl("demons.txt", list.files("~/Documents/docs/")))))) {
      stop("Please provide username and password or provide password file.")
    }
    
  }
  
  remDr$navigate("https://app.bto.org/demography/bto/main/data-home.jsp")
  remDr$getTitle()
  
  uname <- remDr$findElement(using = "css selector", value = "#username")
  pword <- remDr$findElement(using = "css selector", value = "#password")
  uname$sendKeysToElement(list(u))
  pword$sendKeysToElement(list(p))
  loginB <- remDr$findElement(using = 'css selector', ".btn-block")
  loginB$clickElement()
  
  Sys.sleep(5)
  
  if(grepl("data-home", remDr$getCurrentUrl()[[1]])) {
    print("Login successful.")
  } else {
    print("Something went wrong, you are not logged in.")
  }
  
}

loginStatusCheck <- function(verbose = T) {
  
  if(grepl("login", remDr$getCurrentUrl()[[1]])) {
    if(verbose==TRUE) print("Logged out, logging you back in...")
    demonLogin()
  } else {
    if(verbose==TRUE) print("You are already logged in, moving on...")
  }
  
}

switchOperatingGroup <- function(sel) {
  remDr$navigate("https://app.bto.org/demography/bto/main/user-setup-options/operator/switch-operator.jsp")
  
  cur_opt <- remDr$findElements("id", "navString")
  cur_opt <- cur_opt[[1]]$getElementText()[[1]]
  cur_opt <- gsub("Operating as: ", "", cur_opt)
  cur_opt <- gsub(" Change","",cur_opt)
  
  if(cur_opt!=sel) {
    
    ### Find table with listed operating groups
    ptable <- remDr$findElements("id","permissionsTable")
    ptable_h <- ptable[[1]]$getElementAttribute("outerHTML")[[1]]
    ptable_t <- readHTMLTable(ptable_h, as.data.frame=TRUE)[[1]]
    
    ### Find corresponding buttons:
    opts <- remDr$findElements(using = "class", "btn")
    
    ### Find which button corresponds to the desired one:
    p_target <- which(ptable_t[,1]==sel)
    
    ### Click button:
    opts[[p_target]]$clickElement()
    
    Sys.sleep(1)
    
    confirm <- remDr$findElements(using = "class", "btn-success")
    confirm[[1]]$clickElement()
  }
  
}




find_Ring <- function(r, s=NULL, date_lookup=NULL, verbose = TRUE, pause = 1) {
  
  loginStatusCheck()
  
  remDr$navigate("https://app.bto.org/demography/bto/main/search-ringing/search-ringing.jsp")
  if(verbose==TRUE) print("Waiting for record search page to load...")
  Sys.sleep(pause*5)
  if(verbose==TRUE) print("Moving on...")
  
  ### Make sure we tick "Accepted"
  ###
  ### NOTE THIS NEEDS UPDATING SO IT AUTOMATICALLY CHECKS WHICH BOXES ARE NOT ALREADY TICKED:
  
  if(verbose==TRUE) print("Setting search filters...")
  recordFilters <- remDr$findElements("css selector", "#recordFilters")
  Sys.sleep(pause)
  recordFilters <- strsplit(recordFilters[[1]]$getElementText()[[1]],"\n")[[1]]
  Sys.sleep(pause)
  selectB <- remDr$findElements(using = "class", 'btn-group')
  acc_filter <- which(recordFilters == "Accepted")
  ### Select "accepted" button using index found above:
  selectB[[acc_filter]]$clickElement()
  if(verbose==TRUE) print("Done setting search filters...")
  
  if(verbose==TRUE) print("Setting species/date filters...")
  
  if(!is.null(s)) {
    sp_search <- remDr$findElement(using = "css selector", value = "#s2id_autogen18")
    sp_search$sendKeysToElement(list(s, key="enter"))
  }
  
  if(!is.null(date_lookup)) {
    # Make sure date is formatted correctly:
    date_lookup <- as.vector(format(as.Date(date_lookup,"%d-%b-%Y"),"%d/%m/%Y"))
    
    dateSelectors <- remDr$findElements("css selector", "#dateFilters > div > div > input")
    # Start date
    dateSelectors[[1]]$sendKeysToElement(list(date_lookup, key="enter"))
    dateSelectors[[2]]$sendKeysToElement(list(date_lookup, key="enter"))
  }
    
  ring_search <- remDr$findElement(using = "css selector", value = "#s2id_autogen2")
  ring_search$sendKeysToElement(list(r, key = "enter"))
  
  search_button <-remDr$findElement(using = "css selector", value = ".searchBtn")
  search_button$clickElement()
  
  if(verbose==TRUE) print("Waiting for selected data to load...")
  
  res <- NULL
  while(is.null(res)) {
    suppressMessages({
      try({res <- remDr$findElement("id","resultTable_length")}, silent = TRUE)  
    })
    Sys.sleep(1)
  }
  
  #Sys.sleep(pause*5)
  
  if(verbose==TRUE) print("Moving on... extracting data...")
  
  dat <- remDr$findElements("class", "dataTables_scroll")
  dat_html <-dat[[1]]$getElementAttribute("outerHTML")[[1]]
  dat_tab <- readHTMLTable(dat_html, as.data.frame=TRUE)
  dat_tab <- dat_tab[[2]]
  
  if(nrow(dat_tab)>1) {
    print("There is more than 1 record for this date/species combination...!")
    
    fulltab <- remDr$findElements(using = "xpath", '//*[contains(text(),"Raw fullscreen table")]')
    fulltab[[1]]$clickElement()
    fulltab <- remDr$findElements(using = "xpath", '//*[contains(text(),"All data")]')
    fulltab[[3]]$clickElement()
    
    remDr$switchToWindow(remDr$getWindowHandles()[[2]])
    
    dat_tab <- readHTMLTable(htmlParse(remDr$getPageSource()[[1]]))[[1]]
    Sys.sleep(pause*7)
    if(verbose==TRUE) print("Done.")
    remDr$closeWindow()
    remDr$switchToWindow(remDr$getWindowHandles()[[1]])
    
    return(dat_tab)
    
  } else {
    if(verbose==TRUE) print("Done.")
    
    return(dat_tab)  
  }

}

findSpeciesCode <- function(s) {
  sp_dat <- read.csv("bto_species_data.csv",header=T)
  sp_dat$en <- as.vector(sp_dat$en)
  sp_dat$en <- tolower(sp_dat$en)
  sp_dat$species <- tolower(sp_dat$species)
  sp_dat$five_code <- as.vector(sp_dat$five_code)
  
  sn <- substr(s, regexpr("\\(",s)[1]+1, regexpr("\\)",s)[1]-1)
  sn <- tolower(sn)
  
  s <- tolower(s)
  s <- substr(s, 1, regexpr("\\(",s)[1]-2)
  
  sp_short <- sp_dat[grep(sn, sp_dat$species),"five_code"]
  
  return(sp_short)
  
}

summariseReports <- function(date_filter, verbose = T, pause=0.5) {
  
  loginStatusCheck()
  
  remDr$navigate("https://app.bto.org/demography/bto/main/ringing-reports/recoveryReports.jsp")
  Sys.sleep(pause*10)
  if(verbose==TRUE) print("Waiting for reports to load...")
  
  ### Setting date range selection:
  filters <- remDr$findElements(using = "class", value="tableFilterBox")
  filter_date <- filters[[2]]
  filter_date$sendKeysToElement(list(date_filter))
  
  ### Set display list to 100 
  ### Get number of records to show and set to 100 (element 4)
  no_show <- remDr$findElements("css", "#reportTable_length option")[[4]]
  no_show$clickElement()
  
  ### Get number of records shown and total
  displayed <- remDr$findElements("class", "dataTables_info")
  
  displayed <- displayed[[1]]$getElementText()[[1]]
  displayed <- as.numeric(str_extract_all(displayed, "[0-9]+")[[1]][1:3])
  #displayed
  max_recs <- displayed[2]
  
  if(verbose==TRUE) {
    if(displayed[2]==displayed[3]) {
      print(paste("Showing all records for selection: ",max_recs))
    } else {
      print("Warning: There are more than 100 reports for the current selection - this is not currently supported. Only the first 100 will be processed.")
    }
  }
  alldat <- as.data.frame(NULL)
  
  for(i in 1:max_recs) {
    
    print(paste("Processing record", i, "out of", max_recs,"..."))
    
    recs <- remDr$findElements(using = "tag name", value="tr")  
    Sys.sleep(pause)
    rec <- recs[[i+2]]                            ### Need to start with 3rd rec in list (first two are header and blank)
    base_dat <- rec$getElementText()[[1]]
    Sys.sleep(pause)
    base_dat <- strsplit(base_dat, " ")[[1]]
    type <- base_dat[1]
    ring <- base_dat[4]
    
    rec$clickElement()
    remDr$switchToWindow(remDr$getWindowHandles()[[2]])
    if(verbose==TRUE) print("Waiting for record detail...")
    Sys.sleep(pause*3)
    
    if(verbose==TRUE) print("Start extracting data...")
    
    ageSexSection <- remDr$findElements(using = "class", value = "ageSexSection")
    Sys.sleep(pause)
    ageSexSection <- ageSexSection[[1]]$getElementText()[[1]]
    age <- paste(strsplit(ageSexSection," ")[[1]][1:2], collapse=" ")
    sex <- paste(strsplit(ageSexSection," ")[[1]][3:4], collapse=" ")
    agesex <- paste(age, sex, sep=", ")
    
    summarySection <- remDr$findElements(using = "class", value = "quickSummarySection")[[1]]$getElementText()
    Sys.sleep(pause)
    summarySection <- summarySection[[1]]
    
    sp <- gsub(".*Species: (.+) Scheme.*", "\\1", summarySection)
    
    fdate <- remDr$findElements(using = "xpath", '//*[contains(text(),"Finding date")]')
    Sys.sleep(pause)
    fdate <- fdate[[1]]$getElementText()[[1]]
    fdate <- strsplit(fdate," ")[[1]][3]
    
    rdate <- remDr$findElements(using = "xpath", '//*[contains(text(),"Ringing date")]')
    Sys.sleep(pause)
    rdate <- rdate[[1]]$getElementText()[[1]]
    rdate <- strsplit(rdate," ")[[1]][3]
    
    rplace <- remDr$findElements("class", "regPlaceCodeSection")
    Sys.sleep(pause)
    rplace <- rplace[[1]]$getElementText()[[1]]
    rplace <- strsplit(rplace, ": ")[[1]]
    rplace <- tail(rplace,1)
    
    fplace <- remDr$findElements("class", "spanRow")
    Sys.sleep(pause)
    fplace_with_name <- unlist(lapply(fplace, function(x) grepl("Site name: ",x$getElementText()) ))
    fplace_with_name <- which(fplace_with_name)
    fplace <- fplace[[fplace_with_name[2]]]$getElementText()[[1]]
    fplace <- strsplit(fplace, ": ")[[1]]
    fplace <- tail(fplace,1)
    
    cmarks <- remDr$findElements("class", "colourMarks")
    cm <- ext_colourMarkString(cmarks)
    
    # recdat <- list(type = type, sp = sp, ring = ring, cm = cm, rdate = rdate, 
    #                rplace = rplace, agesex=agesex, fdate = fdate, fplace = fplace)
    
    recdat <- data.frame(type,sp,ring,cm,rdate,rplace,agesex,fdate,fplace)
    
    alldat <- rbind(alldat, recdat)
    
    if(verbose==TRUE) print("Done extracting data...")
    
    remDr$closeWindow()
    remDr$switchToWindow(remDr$getWindowHandles()[[1]])
    
    if(verbose==TRUE) print("Waiting a minute for the next record...")
    
  }  # End of for loop for records
  
  return(alldat)
  
}
