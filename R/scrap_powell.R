# scraping - Powell center
# https://www.usgs.gov/centers/john-wesley-powell-center-for-analysis-and-synthesis/science/ecosystems



eco <- "https://www.usgs.gov/centers/john-wesley-powell-center-for-analysis-and-synthesis/science/ecosystems"

# on stocke ttes les infos de la mage url, en créant une session, donc pon peut 
# récup des infos de cette page

p <- "?node_science_type=All&node_group_topics=All&node_release_date=&search_api_fulltext=&node_states_1=&node_science_status=All&sort_bef_combine=node_release_date_DESC&sort_by=node_release_date&sort_order=DESC&page="

# on colle l'url principale à celle du p
pp <- paste0(eco, p)

# on loop sur l'ensemble des titres de projets (groupes), pour choper
# leurs urls dans lesquelles on ira ensuite chercher les publis.

projects_url <- NULL

for (i in 0:4){
  page <- rvest::session(paste0(pp, i))
  
  projects <- page %>% 
    rvest::html_elements(css = ".views-row") %>%
    rvest::html_elements(css = "h4") %>%
    rvest::html_elements(css = "a") %>%
    rvest::html_attr(name = "href")
  projects_url <- c(projects_url, projects)
}


pub_list <- NULL
for (i in 23:length(projects_url)){
  # ca c'est la fin de l'url qu'il faut coller à l'url globale de la page
  bb <- projects_url[i]
  
  page <- paste0("https://www.usgs.gov", bb)
  
  miaou <- rvest::session(paste0(page, "#overview")) %>%
    rvest::html_elements("p") %>%
    rvest::html_text()
  
  publi <- grep("^Publication(s)?:", miaou)
  
  if (length(publi) > 0) {
    publi <- publi[1]
    pi <- grep("^(\\\n)?Principal Investigator", miaou)
    pos <- publi:(pi[1]-1)
    publi <- gsub("^Publication(s)?:", "", miaou[pos])
    pub_list <- c(pub_list, publi)
    
  }
}


pub_list <- data.frame(pub_list)
write.csv2(pub_list, "data/derived-data/jwpc_scraped_publis.csv", 
           row.names = FALSE)









