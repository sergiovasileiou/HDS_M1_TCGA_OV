# Data sources

## Download
- The data were downloaded on 11th November 2026 using scripts/00_data_download.R
- Software used was R 4.6.1 and TCGAbiolinks 2.40.0 (the full list is in
  data/manifests/session_info.txt)
- Checksums are saved in data/manifests/download_record.csv and the GDC file list in
  data/manifests/gdc_files.csv
- GitHub repository: https://github.com/sergiovasileiou/HDS_M1_TCGA_OV (private)

## Time period
- GDC data release: 46.0 (10 August 2026), current on the download date
- Patients were diagnosed between 1992 and 2013. 486 of 587 (82.8%) were diagnosed between 2000 and
  2009, with the median year being 2004. There were no missing years.
- Patient forms were completed between 19th Feb 2009 and 1st Oct 2014
- Follow-up forms were completed between 19th Feb 2009 and 31st Jul 2015, so no follow-ups
  after mid-2015 are included
- All form completion dates could be read as dates (quality check)
- How data were collected (prospective or retrospective) is recorded for only 17 of
  587 patients (11 retrospective, 6 prospective), missing for 570 (97.1%)
- The CDR was published in 2018, the cBioPortal study goes with a 2011 paper

## Sources

| Source | What it is | Link |
|---|---|---|
| GDC, project TCGA-OV | Raw BCR Biotab clinical tables | [GDC Data Portal](https://portal.gdc.cancer.gov) |
| TCGA-CDR, Supplementary Table S1 | Curated OS and PFI (Liu et al. 2018) | [GDC file](https://api.gdc.cancer.gov/data/1b5f413e-a8d1-4d10-92eb-7c4ae739ed81), [PanCanAtlas page](https://gdc.cancer.gov/about-data/publications/pancanatlas) |
| cBioPortal, study ov_tcga_pub | Published platinum status, 345 patients | [Study page](https://www.cbioportal.org/study/summary?id=ov_tcga_pub) |
| TCGAbiolinks | R package used to download | [Bioconductor](https://bioconductor.org/packages/TCGAbiolinks) |
| GDC publication policy | Terms for using open GDC data | [GDC page](https://gdc.cancer.gov/content/are-there-restrictions-use-gdc-data-publications) |

Paper describing the CDR: Liu J et al. Cell 2018;173(2):400-416.e11. https://doi.org/10.1016/j.cell.2018.02.052

## Raw tables (after removing the two label rows)

| Table | One row is | Rows | Columns | Patients | Used |
|---|---|---|---|---|---|
| clinical_patient_ov | A patient | 587 | 57 | 587 | Yes |
| clinical_follow_up_v1.0_ov | A follow-up form | 670 | 19 | 580 | Yes |
| clinical_follow_up_v1.0_nte_ov | A new tumour event reported at follow-up | 513 | 11 | 367 | Yes |
| clinical_nte_ov | A new tumour event on a separate form | 8 | 10 | 4 | Yes |
| clinical_drug_ov | A drug given | 2,516 | 28 | 530 | Yes |
| clinical_radiation_ov | A course of radiotherapy | 36 | 18 | 34 | No |
| clinical_omf_v4.0_ov | Another cancer in the same patient | 3 | 30 | 3 | No |

## How the tables connect
Every table carries both patient identifiers: bcr_patient_uuid and bcr_patient_barcode.
The tables can be joined on either, but the barcode will be used, as it is the
identifier shared with the CDR and cBioPortal and is written the same way in every
table. All days are counted from diagnosis.

## First observations

### Structure
- Each table has two label rows under the header, the first repeats the column names and
  the second holds CDE_ID codes
- Every column is stored as text, including ages and day counts
- All days are counted from diagnosis, as days_to_initial_pathologic_diagnosis is 0 for
  all 587 patients
- Column naming differs between tables, for example days_to_radiation_therapy_start
  against pharmaceutical_tx_started_days_to
- Formats vary within columns, with dates written without leading zeros (2009-3-26) and
  cycle counts written as both 06 and 4

### Missing values
- Missing values are written as text, such as [Not Available], [Not Applicable] and [Unknown]
- Residual disease is recorded in two fields. residual_disease_largest_nodule is missing
  for 67 patients and residual_tumor (R0 to RX) for 529

### Patients
- There are 587 patients, with one row each and no duplicate barcodes
- 302 patients were recorded as dead, 282 as alive and 3 were not available
- Most patients were stage IIIC (413) or IV (89). Stage I had 17 patients, stage II 30,
  IIIA and IIIB 33, and 5 were not available
- For residual disease (largest nodule), 120 patients had none, 256 had 1-10 mm,
  38 had 11-20 mm and 106 had over 20 mm, with 67 not available
- Race and ethnicity are recorded, so the make-up of the cohort can be described

### Follow-up and new tumour events
- 496 patients had one follow-up form, 80 had two and 4 had three or four, while 7 had none
- Vital status differs between the tables. 344 patients were marked dead in at least one
  follow-up form (346 rows, as 2 patients had two), compared with 302 in the patient
  table. 297 patients were dead in both, 47 were dead in follow-up only and 5 in the
  patient table only, so 349 patients were recorded as dead somewhere. All 47 were
  marked "Alive" in the patient table, so the two tables contradict each other for
  these patients
- New tumour events are split across two tables (513 and 8 rows). The follow-up version
  has one extra column, bcr_followup_barcode, so the tables were combined with bind_rows().
  Across both, there were 297 recurrences, 64 locoregional, 42 metastatic, 42 progression,
  4 both locoregional and distant, and 72 unknown
- TCGA-59-A5PD has two new tumour event records on day 145 (one Recurrence, one
  [Unknown]), which may be the same event recorded twice

### Drugs
- There are 2,516 drug records for 530 patients, while 57 patients had no drug record
- By therapy type, there were 2,382 chemotherapy, 60 targeted, 51 hormone and
  17 immunotherapy records, with 6 not available
- Drug names are free text with variant spellings, such as Taxol, Paclitaxel and
  Paciltaxel, Gemcitabine, Gemzar and Gemcitibine, and Carboplatin and Carbo
- Some entries name two drugs in one field (Taxol/Carboplatin, Topotecan/Carboplatin,
  Cisplatin/Gemzar), and each combined entry appears only once
- Some entries come from blinded trials, so the drug actually given is unknown
  (Bevacizamab/Placebo, Ovarex/placebo, spellings as recorded)
- A therapy_regimen column records why each drug was given (ADJUVANT, RECURRENCE)
- The drug names have not yet been grouped

### Other tables
- There were 36 radiotherapy records for 34 patients. This table is not used
- 3 patients had a second cancer diagnosed at the same time. This table is not used

## Other sources

### TCGA-CDR (Liu et al. 2018)
- The CDR holds 11,160 patients across all TCGA cancers, 587 of them ovarian, all of
  which matched Biotab (from the first look on 11th Nov, to be confirmed by the
  validation script)
- It has eight sheets, with the patient data on the sheet "TCGA-CDR"
- There is one row per patient, and it joins to Biotab on the patient barcode
- The outcome columns, as defined by Liu et al. 2018, are:
  - OS and OS.time, overall survival from diagnosis to death from any cause. Patients
    still alive are censored at their last contact
  - PFI and PFI.time, the progression-free interval from diagnosis to the first new
    tumour event (progression, locoregional recurrence, distant metastasis, new
    primary tumour) or death with tumour. Patients alive without an event, or who
    died without tumour, are censored
  - OS and PFI are the event indicators, while OS.time and PFI.time are the days
- The Redaction column flags cases removed from TCGA, for example when consent was withdrawn
- It is used only as a reference to check the rebuilt OS and PFI. The outcome values have
  not yet been inspected
- It was curated from the same TCGA clinical records, so it is not fully independent

### cBioPortal ov_tcga_pub (TCGA 2011)
- It holds 345 patients, 197 sensitive, 90 resistant and 58 too early (recorded as
  "Tooearly")
- There were no duplicate patient IDs, and all 345 were found in the Biotab patient table
- It is used only as a reference to check the derived platinum status
- It comes from an earlier data freeze with its own definition, and covers 345 of the
  587 patients