#' Scrap SESYNC Publications

url <- "https://www.sesync.org/research/search-results?types%5Bpublication%5D=publication&page="


## Retrieve publications URLs ----

children <- NULL

for (page in 0:91) {

  cat("Scraping page", page, "\r")
  
  urls <- rvest::session(paste0(url, page)) |> 
    rvest::html_elements(css = "h3.node-title") |> 
    rvest::html_elements(css = "a") |> 
    rvest::html_attr(name = "href")
  
  urls <- paste0("https://www.sesync.org", urls)
  
  children <- c(children, urls)
}


## Extract publications infos ----

papers <- data.frame()

for (i in 1:length(children)) {
  
  cat("Scraping page", i, "\r")
  
  content <- rvest::session(children[i])
  
  
  p_type <- content |> 
    rvest::html_elements(css = ".field-node--field-publication-type") |> 
    rvest::html_elements(css = ".field-item") |> 
    rvest::html_text()
  
  p_type <- tolower(p_type)
  p_type <- trimws(p_type)
  
  if (p_type == "journal article") {
  
    p_title <- content |> 
      rvest::html_elements(css = "h1") |> 
      rvest::html_text()
    
    p_title <- gsub("\\\n", "", p_title)
    
    p_authors <- content |> 
      rvest::html_elements(css = ".field-node--field-authors") |> 
      rvest::html_elements(css = ".view-mode-line") |> 
      rvest::html_text()
    
    p_authors <- gsub("\\\n", "", p_authors)
    p_authors <- trimws(p_authors)
    p_authors <- paste0(p_authors, collapse = " ; ")
    
    p_date <- content |> 
      rvest::html_elements(css = ".field-node--field-date") |> 
      rvest::html_elements(css = ".field-item") |> 
      rvest::html_text()
    
    p_date <- p_date[1]
    p_date <- stringr::str_extract(p_date, "[0-9]{4}")
  
    p_journal <- content |> 
      rvest::html_elements(css = ".field-node--field-publication") |> 
      rvest::html_elements(css = ".field-item") |> 
      rvest::html_text()
    
    p_journal <- p_journal[1]
    p_journal <- gsub("\\\n", "", p_journal)
    
    p_abstract <- content |> 
      rvest::html_elements(css = ".field-node--body") |> 
      rvest::html_elements(css = ".field-item") |> 
      rvest::html_text()
    
    p_doi <- content |> 
      rvest::html_elements(css = ".field-node--field-doi") |> 
      rvest::html_elements(css = ".field-item") |> 
      rvest::html_text()
    
    p_doi <- trimws(p_doi)
    
    if (length(p_doi) == 0) p_doi <- NA
    
    dat <- data.frame("type"     = p_type,
                      "title"    = p_title,
                      "year"     = p_date,
                      "authors"  = p_authors,
                      "journal"  = p_journal,
                      "abstract" = p_abstract,
                      "doi"      = p_doi)
    
    papers <- rbind(papers, dat)
  }
}


## Export table ----

save(papers, file = here::here("github/projects/kgb/data", "raw-data", "sesync_papers.RData"))
