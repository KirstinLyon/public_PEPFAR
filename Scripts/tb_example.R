library(tidyverse)
library(janitor)


#TODO:  testing 
# TODO testing

# 1. LOAD FUNCTIONS AND GLOBAL VARIABLES


COUNTRY <- "MOZ"
DATA <- "Data/unzipped/Enhanced_Geographical_Analysis.txt"
INDICATORS <- c("TB_STAT","TB_STAT_POS","TB_ART")
INDICATORS_ALL <- c("TB_STAT","TB_PREV","TB_STAT_POS", "TX_TB", "TX_CURR", "TX_NEW", "TB_ART")
FISCAL_YEAR <- c("2019", "2020", "2021", "2022", "2023", "2024")
FISCAL_YEAR_REMOVE <- c("2016", "2017", "2018", "2019")

source("Scripts/utilities.R")


#2. READ DATA
#has both province and district as well age and sex.  missing fine level age groups - do we need that?
tb_data <- read_tsv(DATA)

tb_data_moz <- tb_data |> 
    filter(ISO3 == COUNTRY,
           Indicator %in% INDICATORS) |> 
    write_csv("Dataout/TB_moz.csv")


#show all column names
print(colnames(tb_data))

# keep columns that containt FISCAL_YEAR        
tb_data_all <- tb_data |> 
    filter(Indicator %in% INDICATORS,
           ISO3 %in% COUNTRY) |>
    select(!matches(FISCAL_YEAR_REMOVE)) |> 
    select(-c("Operating Unit", "Sub-National Unit 3","Sub-National Unit 3 UID", "Modality")) |> 
    group_by(Country, ISO3, Indicator, Description, `Numerator/Denominator`, 
             `Sub-National Unit 1`, `Sub-National Unit 1 UID`, 
             `Sub-National Unit 2`, `Sub-National Unit 2 UID`) |>
    summarise_all(sum) |>
    write_csv("Dataout/TB_all.csv")

print(colnames(tb_data_all))

#3. PREPARE DATA

tb_df <- tb_data |> 
    filter(ISO3 == COUNTRY,
           Indicator %in% INDICATORS) |> 
    prep_data() |> 
    mutate(indicator = case_when(indicator %in% c("TB_STAT", "TB_PREV", "TX_TB", "TB_ART") ~ 
                                       paste(indicator, numerator_denominator , sep = "_"),
                                   .default = indicator) 
    ) |> 
    select(country, snu, snuuid, psnu, psnuuid, fiscal_year, period, 
           period_type, indicator, value) |> 
    filter(fiscal_year %in% FISCAL_YEAR) |> 
    group_by(country, snu, snuuid, psnu, psnuuid, fiscal_year, period, period_type, indicator) |>
    summarise(value = sum(value) , 
                          .groups = "drop")

tb_df_results <- tb_df |> 
    filter(period_type == "Result") 


tb_df_results_total <- tb_df_results |> 
    group_by(country, snu, snuuid, psnu, psnuuid, fiscal_year, period_type, indicator) |>
    summarise(value = sum(value), .groups = "drop") 


tb_df_targets <- tb_df |> 
    filter(period_type == "Target") |> 
    select(-period) |> 
    bind_rows(tb_df_results_total) |> 
    pivot_wider(names_from = period_type, values_from = value) 
         

