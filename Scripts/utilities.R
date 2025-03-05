#pivots data - any column name include targets or results should  be longer
#find columns containing target or result
prep_data <- function(data){
    temp <- data |> 
        pivot_longer(cols = matches("Targets$|Results$"), names_to = "period", values_to = "Value") |> 
        separate(period, into = c("fiscal_year", "period_type", "quarter", "misc"), sep = " ", fill = "right") |> 
        mutate(period_type = case_when(period_type == "Targets" ~ "Target", 
                                       period_type == "Quarter" ~ "Result", 
                                       .default = "misc"),
               period = case_when(period_type == "Result"~ paste0(fiscal_year," Q", quarter),
                                  .default = NA_character_)
        ) |> 
        clean_names() |> 
        select(-c(quarter, misc)) |> 
        rename(
                "snu" = "sub_national_unit_1",
                "psnu" = "sub_national_unit_2",
                "snuuid" = "sub_national_unit_1_uid",
                "psnuuid" = "sub_national_unit_2_uid",
                "ou" = "operating_unit"
               )
    
    return(temp)
}