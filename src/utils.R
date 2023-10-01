library(openxlsx)
library(stringr)

extract_colour_mark <- function(el) {
  cm_vec1 <- c("LB", "RB", "LA", "RA")
  cm_vec2 <- rep("", 4)
  cm_vec <- cbind(cm_vec1, cm_vec2)
  for (i in 1:4) {
    txt <- el[[i]]$getElementText()[[1]]
    if (txt != "") {
      cm_vec[i, 2] <- tail(strsplit(txt, " ")[[1]], 1)
    }
  }
  cm_non_blank <- which(cm_vec[, 2] != "")

  if (length(cm_non_blank) > 1)  {
    cm <- paste(apply(cm_vec[cm_non_blank, ], 1, 
                      function(x) paste(x, collapse = "")),
                collapse = ";")
  } else {
    cm <- paste(as.matrix(cm_vec[cm_non_blank, ]), collapse = "")
  }
  return(cm)
}

demon_login <- function(u = NULL, p = NULL) {
  if(is.null(u) | is.null(p)) {
    if (!(as.logical(sum(grepl("demons.txt",
                        list.files("~/Documents/docs/")))))) {
      stop("Please provide username and password or provide password file.")
    }
  }
  remDr$navigate("https://app.bto.org/demography/bto/main/data-home.jsp")
  remDr$getTitle()
  uname <- remDr$findElement(using = "css selector", value = "#username")
  pword <- remDr$findElement(using = "css selector", value = "#password")
  uname$sendKeysToElement(list(u))
  pword$sendKeysToElement(list(p))
  loginB <- remDr$findElement(using = "css selector", ".btn-block")
  loginB$clickElement()
  Sys.sleep(5)
  if (grepl("data-home", remDr$getCurrentUrl()[[1]])) {
    print("Login successful.")
  } else {
    print("Something went wrong, you are not logged in.")
  }
}

login_status_check <- function(verbose = FALSE) {
  if (grepl("login", remDr$getCurrentUrl()[[1]])) {
    if (verbose == TRUE) print("Logged out, logging you back in...")
    demon_login()
  } else {
    if (verbose == TRUE) print("You are already logged in, moving on...")
  }
  
}

switch_op_group <- function(sel) {
  remDr$navigate("https://app.bto.org/demography/bto/main/user-setup-options/operator/switch-operator.jsp") # nolint

  cur_opt <- remDr$findElements("id", "navString")
  cur_opt <- cur_opt[[1]]$getElementText()[[1]]
  cur_opt <- gsub("Operating as: ", "", cur_opt)
  cur_opt <- gsub(" Change", "", cur_opt)

  if (cur_opt != sel) {

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

waiter <- function(driver, elementtype, elementname, pause=1, return_data = TRUE) {
  res <- list()
  while (length(res) == 0) {
    suppressMessages({
      try({res <- driver$findElements(elementtype, elementname)},
                                    silent = TRUE)
      Sys.sleep(pause)
    })
    
  }
  Sys.sleep(0.5)
  if (return_data == TRUE) return(res)
}

find_ring <- function(r, s = NULL, date_lookup = NULL,
                      verbose = TRUE, pause = 1) {

  login_status_check(verbose = verbose)

  remDr$navigate("https://app.bto.org/demography/bto/main/search-ringing/search-ringing.jsp") # nolint

  ### Add 'waiting' while search page loads. Checked via availability of tick boxes # nolint
  if (verbose == TRUE) print("Waiting for record search page to load...")
  recordFilters <- NULL
  while(length(recordFilters) == 0) {
      try({recordFilters <-
        remDr$findElements("css selector", "#recordFilters")
      }, silent = TRUE)
    Sys.sleep(pause / 2)
  }

  ### Tick 'accepted' filter.
  if (verbose == TRUE) print("Setting 'Accepted' filter")
  recordFilters2 <- NULL
  while(length(recordFilters2) == 0) {
    try({
      recordFilters2 <- strsplit(recordFilters[[1]]$getElementText()[[1]],
                                 "\n")[[1]]
    }, silent = TRUE)
    Sys.sleep(pause / 2)
  }

  selectB <- remDr$findElements(using = "class", 'btn-group')
  acc_filter <- which(recordFilters2 == "Accepted") - 1
  ### Select "accepted" button using index found above:
  selectB[[acc_filter]]$clickElement()
  if (verbose == TRUE) print("Done setting search filters...")
  if (verbose == TRUE) print("Setting species/date filters...")

  if (!is.null(s)) {
    sp_search <- remDr$findElement(using = "css selector",
                                   value = "#s2id_autogen18")
    sp_search$sendKeysToElement(list(s, key = "enter"))
  }

  if (!is.null(date_lookup)) {
    # Make sure date is formatted correctly:
    date_lookup <- as.vector(format(as.Date(date_lookup,
                                            "%d-%b-%Y"),
                                            "%d/%m/%Y")
                            )

    dateSelectors <- remDr$findElements("css selector",
                                        "#dateFilters > div > div > input")
    # Start date
    dateSelectors[[1]]$sendKeysToElement(list(date_lookup, key = "enter"))
    dateSelectors[[2]]$sendKeysToElement(list(date_lookup, key = "enter"))
  }

  ring_search <- remDr$findElement(using = "css selector",
                                   value = "#s2id_autogen2")
  ring_search$sendKeysToElement(list(r, key = "enter"))

  search_button <- remDr$findElement(using = "css selector",
                                    value = ".searchBtn")
  search_button$clickElement()

  if (verbose == TRUE) print("Waiting for selected data to load...")

  dat <- list()
  while (length(dat) == 0) {
    suppressMessages({
      try({dat <- remDr$findElements("class", "dataTables_scroll")},
                                    silent = TRUE)
    })
    Sys.sleep(1)
  }
  if (verbose == TRUE) print("Moving on... extracting data...")

  dat <- remDr$findElements("class", "dataTables_scroll")
  dat_html <- dat[[1]]$getElementAttribute("outerHTML")[[1]]
  dat_tab <- readHTMLTable(dat_html, as.data.frame = TRUE)
  dat_tab <- dat_tab[[2]]

  if (nrow(dat_tab) > 1) {
    #print("There is more than 1 record for this date/species combination...!")

    fulltab <- remDr$findElements(using = "xpath",
                  '//*[contains(text(),"Raw fullscreen table")]')
    fulltab[[1]]$clickElement()
    fulltab <- remDr$findElements(using = "xpath",
                  '//*[contains(text(),"All data")]')
    fulltab[[3]]$clickElement()

    remDr$switchToWindow(remDr$getWindowHandles()[[2]])

    dat_tab <- readHTMLTable(htmlParse(remDr$getPageSource()[[1]]))[[1]]
    Sys.sleep(pause*7)
    if (verbose == TRUE) print("Done.")
    remDr$closeWindow()
    remDr$switchToWindow(remDr$getWindowHandles()[[1]])

    return(dat_tab)

  } else {
    if (verbose == TRUE) print("Done.")

    return(dat_tab)
  }

}

find_species_code <- function(s) {
  sp_dat <- read.csv("bto_species_data.csv", header = TRUE)
  sp_dat$en <- as.vector(sp_dat$en)
  sp_dat$en <- tolower(sp_dat$en)
  sp_dat$species <- tolower(sp_dat$species)
  sp_dat$five_code <- as.vector(sp_dat$five_code)
  sn <- substr(s, regexpr("\\(", s)[1] + 1, regexpr("\\)", s)[1] - 1)
  sn <- tolower(sn)
  s <- tolower(s)
  s <- substr(s, 1, regexpr("\\(", s)[1] - 2)
  sp_short <- sp_dat[grep(sn, sp_dat$species), "five_code"]
  return(sp_short)
}

summariseReports <- function(date_filter, verbose = T, pause=0.5) {
  
  login_status_check()
  
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
  
  recs <- remDr$findElements("class name", "sorting_1")
  
  ### Keep base window ref
  base_window <- remDr$getWindowHandles()
  
  for(i in 1:max_recs) {
    
    print(paste("Processing record", i, "out of", max_recs,"..."))
    
    #recs <- remDr$findElements(using = "tag name", value="tr")  
    #Sys.sleep(pause)
    #rec <- recs[[i+2]]                            ### Need to start with 3rd rec in list (first two are header and blank)
    
    ### Click report list
    recs[[i]]$clickElement()
    
    ### Switch to report window:
    remDr$switchToWindow(remDr$getWindowHandles()[[2]])
    
    # 
    # base_dat <- recs[[i]]$getElementText()[[1]]
    # 
    # Sys.sleep(pause)
    # base_dat <- strsplit(base_dat, " ")[[1]]
    # type <- base_dat[1]
    # ring <- base_dat[4]
    # 
    # rec$clickElement()
    # remDr$switchToWindow(remDr$getWindowHandles()[[2]])
    # if(verbose==TRUE) print("Waiting for record detail...")
    # Sys.sleep(pause*3)

    if(verbose==TRUE) print("Start extracting data...")
    
    quickSummarySection <- remDr$findElement(using = "class name", value = "quickSummarySection")
    
    
    
    
    
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
    cm <- extract_colour_mark(cmarks)
    
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

extract_entry_counts <- function(s) {
  s <- s[[1]]$getElementText()[[1]]
  s <- gsub(",","",s)
  s <- strsplit(s, " ")[[1]]
  suppressWarnings({
    s <- as.numeric(s)
  })
  n <- s[!is.na(s)]

  out <- list(i = n[1], n = n[2], N = n[3])
  if(length(n)>3) {
    out$K <- n[4]
  }

  return(out)
}

recoveries <- function(ring, verbose = FALSE) {

  login_status_check(verbose = verbose)

  remDr$navigate(
  "https://app.bto.org/demography/bto/main/ringing-reports/recoveryReports.jsp")

  rtab <- waiter(driver = remDr, elementtype = "id", "reportTable",
                 return_data = TRUE, pause = 2)

  # Find "Ring no." filter box index:
  rtab_h <- rtab[[1]]$getElementAttribute("outerHTML")
  rtab_names <- rtab_h[[1]] %>%
    read_html() %>%
    html_table() %>%
    as.data.frame() %>%
    names()
  ring_filter <- which(rtab_names == "Ring.No")

  # Set "Ring no." filter box:
  # Hard sleep steps necessary to avoid breakage, apparently...
  Sys.sleep(0.5)
  ftab <- remDr$findElements("class", "tableFilterBox")
  Sys.sleep(0.5)
  ftab[[ring_filter]]$clickElement()
  ftab[[ring_filter]]$clearElement()
  ftab[[ring_filter]]$sendKeysToElement(list(ring))

  # Find no. recs displayed
  displayed <- remDr$findElements("class", "dataTables_info")
  displayed <- extract_entry_counts(displayed)

  # Extract only if recs do not exceed 100 (ie filter likely incorrectly applied, also would need pageing)
  if((displayed$N > 99)) {
    if(verbose == TRUE) print("Warning: There are more than 100 reports for the current selection - this is not currently supported.") # nolint
    return(NULL)
  } else {
    # Extract if more than zero records displayed
    if (displayed$N > 0) {
      # Re-load displayed sightings table
      recs <- remDr$findElements("class name", "sorting_1")
      # Iterate through sightings list:
      sight_dat <- as.data.frame(NULL)
      for (i in 1:displayed$N) {
        if (verbose == TRUE) {
          sprintf("Processing sighting %s of %s", i, displayed$N)
        }
        recs[[i]]$clickElement()
        waiter(remDr, "id", "content", return_data = FALSE, pause = 0.5)
        # Need to switch tab now
        main_tab <- remDr$getWindowHandles()[[1]]
        switch_to <- remDr$getWindowHandles()[[2]]
        remDr$switchToWindow(switch_to)
        # Parse data and add to output
        dat_i <- parse_report()
        sight_dat <- rbind(sight_dat, dat_i)
        # Close and back to Main
        remDr$closeWindow()
        remDr$switchToWindow(main_tab)
      }
      return(sight_dat)

    } else {
      if(verbose == TRUE) print("No sighting records found for given ring!")
      return(NULL)
    }
  }

}

### Parsing BTO recovery summary report.
### Works either on downloaded report (pageurl) or passing in web driver obj pointing at open report (driver)
parse_report <- function(pageurl = NULL) {

  if (!is.null(pageurl)) {
    dat <- read_html(pageurl)
  } else {
    dat <- read_html(remDr$getPageSource()[[1]])
  }

  quickSummarySection <- html_nodes(dat, "div.quickSummarySection table")
  quickSummarySection <- as.data.frame(html_table(quickSummarySection))
  RING <- quickSummarySection[1, 6]
  SP <- quickSummarySection[1, 2]

  ringingDateSection <- html_nodes(dat, "div.ringingDateSection span")
  ringingDateSection <- html_text(ringingDateSection)
  RDATE <- strsplit(ringingDateSection, ":\\ ")[[1]][2]
  RDATE <- strsplit(RDATE, "\\ ")[[1]][1]

  regPlaceCodeSection <- html_nodes(dat, "div.regPlaceCodeSection span")
  place_text <- html_text(regPlaceCodeSection)
  place <- paste(place_text[(grep("Place code",
                 place_text) + 1):length(place_text)],
                 collapse = ", ")
  RPLACE <- gsub("Site name: ", "", place)

  findingDat <- html_nodes(dat, "div.spanRow")
  fDateLoc <- grep("Finding date", html_text(findingDat))
  fdate <- html_text(findingDat[fDateLoc])
  fdate <- gsub("\r\n", "", fdate)
  fdate <- gsub("Finding date: ", "", fdate)
  fdate <- gsub("\\  ", "", fdate)
  FDATE <- strsplit(fdate, " ")[[1]][1]

  fPlaceLoc <- grep("Place code", html_text(findingDat))
  fplace <- html_text(findingDat[fPlaceLoc[2]])
  fplace <- sub(".*Site name: ", "", fplace)
  fplace <- gsub("\r\n", "", fplace)
  FPLACE <- gsub("  ", "", fplace)

  fcondition <- html_nodes(dat, "div.findingBirdCondition")
  fcondition <- html_text(fcondition)
  fcondition <- strsplit(fcondition, "\\s{2,}")[[1]][3]
  fcondition <- gsub("\n", "", fcondition)
  FCONDITION <- gsub("\\  ", "", fcondition)

  OUT <-
    data.frame(RING = RING,
               SP = SP,
               RDATE = RDATE,
               RPLACE = RPLACE,
               FDATE = FDATE,
               FPLACE = FPLACE,
               FCONDITION = FCONDITION)

  return(OUT)
}
