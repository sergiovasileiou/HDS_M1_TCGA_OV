#02_clean.R
#Removes the label rows, turns placeholders into NA and combines the two
#new tumour event tables. The raw data are not changed.
#Saves: patient, followup, nte and drug tables in data/derived/

library(here)
library(dplyr)


#0. Loading the data ----

biotab <- readRDS(here("data", "raw", "biotab.rds"))

#The five placeholders found in 01_profile.R, used instead of leaving a value empty
placeholders <- c("[Not Available]", "[Not Applicable]", "[Unknown]",
                  "[Discrepancy]", "[Not Evaluated]")


#1. Cleaning every table in the same way ----

tables <- biotab

for (i in seq_along(tables)) {
  one_table <- tables[[i]]
  
  #Removing the two label rows
  one_table <- one_table[-(1:2), ]
  
  #Replacing placeholders with NA, one column at a time
  for (column in names(one_table)) {
    one_table[[column]][one_table[[column]] %in% placeholders] <- NA
  }
  
  tables[[i]] <- one_table
}


#2. Picking out the tables used in the project ----

patient  <- tables$clinical_patient_ov
followup <- tables$clinical_follow_up_v1.0_ov
drug     <- tables$clinical_drug_ov

#New tumour events are in two tables with different columns, so stack them
#with bind_rows() and record which table each row came from
nte <- bind_rows(followup_form = tables$clinical_follow_up_v1.0_nte_ov,
                 separate_form = tables$clinical_nte_ov,
                 .id = "source_table")


#3. Checks ----

#Rows kept in each table
print(nrow(patient))           #should be 587
print(nrow(followup))          #should be 670
print(table(nte$source_table)) #should be 513 and 8
print(nrow(drug))              #should be 2516

#Placeholders left in any table, should be 0
remaining <- 0
for (i in seq_along(tables)) {
  remaining <- remaining + sum(unlist(tables[[i]]) %in% placeholders)
}
print(remaining)


#4. Saving the cleaned tables ----

saveRDS(patient,  here("data", "derived", "patient.rds"))
saveRDS(followup, here("data", "derived", "followup.rds"))
saveRDS(nte,      here("data", "derived", "nte.rds"))
saveRDS(drug,     here("data", "derived", "drug.rds"))