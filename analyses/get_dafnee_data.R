
# get the refs from Cesab, NCEAS and sDiv already compiled for DAFNEE
utils::download.file("https://raw.githubusercontent.com/FRBCesab/dafnee/main/data/derived-data/all-publications.txt", 
                     "data/raw-data/dafnee_refs.txt", 
                     mode = "wb" )

jpw_scrap <- read.csv2("data/derived-data/jwpc_scraped_publis.csv")
