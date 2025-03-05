library(tidyverse)
library(janitor)


COUNTRY <- "MOZ"

#1. LOAD DATA ---------------------------

source("Scripts/utilities.R")




#has both province and district as well age and sex.  missing fine level age groups - do we need that?  Doesn't include all indicators
clinical_cascade_coarse_age_sex_data <- read_tsv("Data/unzipped/Clinical_Cascade_Results_by_Coarse_Age_and_Sex.txt") |> filter(ISO3 == COUNTRY)

site_performance_data <- read_tsv("Data/unzipped/Site_Performance_2021+.txt") 


clinical_cascade_coarse_age <- clinical_cascade_coarse_age_sex_data |> 
    prep_data()

#modality here but no age and sex
enhanced_geographical_data <- read_tsv("Data/unzipped/Enhanced_Geographical_Analysis.txt")|> filter(ISO3 == COUNTRY)


#ends with _target or _result

data <- clinical_cascade_fine_age_sex_data |> 
    pivot_longer(cols = matches("Targets$|Results$"), names_to = "period", values_to = "Value") |> 
    separate(period, into = c("fiscal_year", "period_type", "quarter", "misc"), sep = " ", fill = "right") |> 
    mutate(period_type = case_when(period_type == "Targets" ~ "Target", 
                                period_type == "Quarter" ~ "Result", 
                                .default = "misc"),
           period = case_when(period_type == "Result"~ paste0(fiscal_year," Q", quarter),
                             .default = NA_character_)
           ) |> 
    select(-c(quarter, misc))




#No ------------------------------------------------
vmmc_data <- read_tsv("Data/unzipped/Voluntary_Male_Medical_Circumcisions_Results_by_Operating_Unit.txt") #not right now
#no - doesn't have numberator/denominator
country_results_modality_coarse_age_sex_data <- read_tsv("Data/unzipped/Country_Level_Results_by_Modality_Coarse_Age_and_Sex.txt") |> filter(ISO3 == COUNTRY)
clinical_cascade_data <- read_tsv("Data/unzipped/Clinical_Cascade_Quarterly_Results.txt") |> filter(ISO3 == COUNTRY)
geographical_analysis_ou_data <- read_tsv("Data/unzipped/Geographical_Analysis_Operating_Unit.txt")|> filter(ISO3 == COUNTRY) # too high level
# NO
geographical_analysis_snu_data <- read_tsv("Data/unzipped/Geographical_Analysis_Sub_National_Unit.txt") |> filter(ISO3 == COUNTRY) #no - missing N/D
#modality here but no age and sex
enhanced_geographical_data <- read_tsv("Data/unzipped/Enhanced_Geographical_Analysis.txt")|> filter(ISO3 == COUNTRY)
#district doesn't exist
clinical_cascade_fine_age_sex_data <- read_tsv("Data/unzipped/Clinical_Cascade_Results_by_Fine_Age_and_Sex.txt") |> filter(ISO3 == COUNTRY)

#district doesn't exist
rm(geographical_analysis_snu_data)
