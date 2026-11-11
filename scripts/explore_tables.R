#explore_tables.R
#A quick look at the raw tables before doing any analysis.

library(here)
library(dplyr)
library(readxl)


#0. Loading the data ----

biotab <- readRDS(here("data", "raw", "biotab.rds"))

#Removing the first two rows from each table since these rows contain labels
#rather than actual data
tables <- biotab
for (i in seq_along(tables)) {
  tables[[i]] <- tables[[i]][-(1:2), ]
  }

#1. Checking the size of each table ----

table_summary <- data.frame(
  table = names(tables),
  rows = NA,
  columns = NA,
  patients = NA
)

for (i in seq_along(tables)) {
  table_summary$rows[i] <- nrow(tables[[i]])
  table_summary$columns[i] <- ncol(tables[[i]])
  table_summary$patients[i] <- length(
    unique(tables[[i]]$bcr_patient_barcode)
  )
}
print(table_summary)


#2. Looking at the columns in each table ----

for (i in seq_along(tables)) {
  cat("\nTable:", names(tables)[i], "\n")
  str(tables[[i]])
}


#3. Looking at some important variables ----

#Selecting the tables we need
patient <- tables$clinical_patient_ov
followup <- tables$clinical_follow_up_v1.0_ov
drug <- tables$clinical_drug_ov

#Combining the two tables containing new tumour events
#Using bind_rows() because the two tables have different columns
nte <- bind_rows(
  tables$clinical_follow_up_v1.0_nte_ov,
  tables$clinical_nte_ov
)


##3.1 Patient information ----

print(table(patient$vital_status, useNA = "ifany"))
print(table(patient$clinical_stage, useNA = "ifany"))
print(table(patient$residual_disease_largest_nodule, useNA = "ifany"))
print(table(patient$residual_tumor, useNA = "ifany"))

#All days are counted from diagnosis, so this should be 0 for every patient
print(table(patient$days_to_initial_pathologic_diagnosis, useNA = "ifany"))


##3.2 Time period ----

#Year of diagnosis
print(table(patient$initial_pathologic_dx_year, useNA = "ifany"))

#Patient form completion dates
patient_dates <- as.Date(patient$form_completion_date)
print(range(patient_dates, na.rm = TRUE))
print(sum(is.na(patient_dates)))     # dates that could not be read, should be 0

#Follow-up form completion dates
followup_dates <- as.Date(followup$form_completion_date)
print(range(followup_dates, na.rm = TRUE))
print(sum(is.na(followup_dates)))    # dates that could not be read, should be 0

#Whether the data were collected prospectively or retrospectively
print(table(patient$prospective_collection, useNA = "ifany"))
print(table(patient$retrospective_collection, useNA = "ifany"))


##3.3 Follow-up information ----

#Counting how many follow-up records each patient has
followup_per_patient <- table(
  followup$bcr_patient_barcode,
  useNA = "ifany"
)

#Counting how many patients have each number of follow-up records
print(table(followup_per_patient))

#Follow-up rows recording a death, and how many patients they belong to
print(sum(followup$vital_status == "Dead"))
dead_patients <- unique(followup$bcr_patient_barcode[followup$vital_status == "Dead"])
print(length(dead_patients))

#Comparing deaths in the follow-up and patient tables
patient_dead <- patient$bcr_patient_barcode[patient$vital_status == "Dead"]
print(sum(!dead_patients %in% patient_dead))   # dead in follow-up, not dead in patient table
print(sum(!patient_dead %in% dead_patients))   # dead in patient table, no death in follow-up

#Vital status in the patient table for those dead in follow-up only
dead_followup_only <- dead_patients[!dead_patients %in% patient_dead]
print(table(patient$vital_status[patient$bcr_patient_barcode %in% dead_followup_only]))


##3.4 New tumour events ----

print(table(nte$new_neoplasm_event_type, useNA = "ifany"))


##3.5 Drug information ----

#Top 20 most frequently recorded drug names
drug_names <- sort(
  table(drug$pharmaceutical_therapy_drug_name, useNA = "ifany"),
  decreasing = TRUE
)
print(head(drug_names, 20))

#Counting the different types of pharmaceutical therapy
print(table(drug$pharmaceutical_therapy_type, useNA = "ifany"))

#Drug names containing a slash (more than one drug in one entry)
combined_drugs <- drug$pharmaceutical_therapy_drug_name[
  grepl("/", drug$pharmaceutical_therapy_drug_name)
]
print(table(combined_drugs))


#4. Initial inspection of the external sources ----

##4.1 TCGA-CDR ----

#Sheet names and column names only
#n_max = 0 reads the header row only, so no outcome values are loaded yet
print(excel_sheets(here("data", "raw", "TCGA-CDR.xlsx")))
cdr_columns <- read_excel(here("data", "raw", "TCGA-CDR.xlsx"),
                          sheet = "TCGA-CDR", n_max = 0)
print(names(cdr_columns))


##4.2 cBioPortal ----

cbio <- read.csv(here("data", "raw", "cbioportal_platinum.csv"))
print(dim(cbio))
print(table(cbio$value, useNA = "ifany"))

#Checking for duplicate patients
print(sum(duplicated(cbio$patientId)))

#Checking how many cBioPortal patients are in the patient table
cbio_patients <- unique(cbio$patientId)
print(sum(cbio_patients %in% patient$bcr_patient_barcode))