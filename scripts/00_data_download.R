# 00_data_download.R
# Downloads the raw data from its public sources and records what arrived.
# Raw files go to data/raw/, which Git ignores.

library(TCGAbiolinks)
library(here)

# 1. TCGA clinical tables (BCR Biotab) from the GDC
query <- GDCquery(project = "TCGA-OV",
                  data.category = "Clinical",
                  data.type = "Clinical Supplement",
                  data.format = "BCR Biotab")
gdc_files <- getResults(query)
GDCdownload(query, directory = here("data", "raw", "gdc"))
biotab <- GDCprepare(query, directory = here("data", "raw", "gdc"))
saveRDS(biotab, here("data", "raw", "biotab.rds"))

# 2. TCGA-CDR table (Liu et al. 2018), using its GDC file ID
download.file("https://api.gdc.cancer.gov/data/1b5f413e-a8d1-4d10-92eb-7c4ae739ed81",
              destfile = here("data", "raw", "TCGA-CDR.xlsx"), mode = "wb")

# 3. Published platinum status from cBioPortal
cbio_url <- paste0("https://www.cbioportal.org/api/studies/ov_tcga_pub/clinical-data",
                   "?clinicalDataType=PATIENT&attributeId=PLATINUM_STATUS")
cbio <- jsonlite::fromJSON(cbio_url)
write.csv(cbio[, c("patientId", "value")],
          here("data", "raw", "cbioportal_platinum.csv"), row.names = FALSE)

# 4. Record what was downloaded
write.csv(gdc_files[, c("file_name", "md5sum")],
          here("data", "manifests", "gdc_files.csv"), row.names = FALSE)
files <- here("data", "raw", c("biotab.rds", "TCGA-CDR.xlsx", "cbioportal_platinum.csv"))
record <- data.frame(file = basename(files),
                     md5 = tools::md5sum(files),
                     downloaded = Sys.Date())
write.csv(record, here("data", "manifests", "download_record.csv"), row.names = FALSE)
writeLines(names(biotab), here("data", "manifests", "biotab_tables.txt"))
writeLines(capture.output(sessionInfo()), here("data", "manifests", "session_info.txt"))