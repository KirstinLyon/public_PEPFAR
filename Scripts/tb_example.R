library(tidyverse)
library(janitor)


#TODO:  for results: you don't need modality for TB.  exclude it and group.  
# TODO for targets, you need to get the total results to compare and don't need modality

# 1. LOAD FUNCTIONS AND GLOBAL VARIABLES


COUNTRY <- "MOZ"
DATA <- "Data/unzipped/Enhanced_Geographical_Analysis.txt"
INDICATORS <- c("TB_STAT","TB_STAT_POS","TB_ART")
INDICATORS_ALL <- c("TB_STAT","TB_PREV","TB_STAT_POS", "TX_TB", "TX_CURR", "TX_NEW", "TB_ART")
FISCAL_YEAR <- c("2019", "2020", "2021", "2022", "2023", "2024")

source("Scripts/utilities.R")


#2. READ DATA
#has both province and district as well age and sex.  missing fine level age groups - do we need that?
tb_data <- read_tsv(DATA)
    

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
    filter(fiscal_year %in% FISCAL_YEAR) 


tb_df_results <- tb_df |> 
    filter(period_type == "Result") 


tb_df_targets <- tb_df |> 
    group_by(country, snu, snuuid, psnu, psnuuid, fiscal_year, period_type, indicator)

