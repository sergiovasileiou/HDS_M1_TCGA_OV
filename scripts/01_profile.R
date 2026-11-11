#01_profile.R
#Saves the summaries of the raw tables that the report uses.
#Saves: outputs/table_sizes.csv, outputs/missing_patient.csv and
#outputs/placeholders.csv

library(here)
library(dplyr)


#0. Loading the data ----

biotab <- readRDS(here("data", "raw", "biotab.rds"))

#Removing the first two rows from each table since these rows contain labels
#rather than actual data
tables <- biotab
for (i in seq_along(tables)) {
  tables[[i]] <- tables[[i]][-(1:2), ]
}

patient <- tables$clinical_patient_ov


#1. Size of each table ----

table_sizes <- data.frame(
  table = names(tables),
  rows = NA,
  columns = NA,
  patients = NA
)

for (i in seq_along(tables)) {
  table_sizes$rows[i] <- nrow(tables[[i]])
  table_sizes$columns[i] <- ncol(tables[[i]])
  table_sizes$patients[i] <- length(unique(tables[[i]]$bcr_patient_barcode))
}

print(table_sizes)
write.csv(table_sizes, here("outputs", "table_sizes.csv"), row.names = FALSE)


#2. Missing values in the key patient columns ----

key_columns <- c("vital_status", "death_days_to", "last_contact_days_to",
                 "tumor_status", "age_at_initial_pathologic_diagnosis",
                 "clinical_stage", "residual_disease_largest_nodule")

missing_patient <- data.frame(
  column = key_columns,
  not_available = NA,
  not_applicable = NA,
  unknown = NA,
  discrepancy = NA,
  not_evaluated = NA
)

for (i in seq_along(key_columns)) {
  values <- patient[[key_columns[i]]]
  missing_patient$not_available[i]  <- sum(values == "[Not Available]")
  missing_patient$not_applicable[i] <- sum(values == "[Not Applicable]")
  missing_patient$unknown[i]        <- sum(values == "[Unknown]")
  missing_patient$discrepancy[i]    <- sum(values == "[Discrepancy]")
  missing_patient$not_evaluated[i]  <- sum(values == "[Not Evaluated]")
}

missing_patient$total <- missing_patient$not_available +
  missing_patient$not_applicable + missing_patient$unknown +
  missing_patient$discrepancy + missing_patient$not_evaluated
missing_patient$percent <- round(100 * missing_patient$total / nrow(patient), 1)

print(missing_patient)
write.csv(missing_patient, here("outputs", "missing_patient.csv"), row.names = FALSE)


#3. Placeholder values used across all tables ----
#Checks the list of placeholders used in 02_clean.R is complete

all_bracketed <- c()
for (i in seq_along(tables)) {
  values <- unlist(tables[[i]])
  all_bracketed <- c(all_bracketed, values[grepl("^\\[", values)])
}

placeholders <- as.data.frame(table(all_bracketed))
names(placeholders) <- c("value", "count")

print(placeholders)
write.csv(placeholders, here("outputs", "placeholders.csv"), row.names = FALSE)