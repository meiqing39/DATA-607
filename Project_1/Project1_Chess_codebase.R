
                   library(tidyverse)
                   
                   raw_data <- read.csv("https://raw.githubusercontent.com/meiqing39/DATA-607/refs/heads/main/Project_1/tournamentinfo.txt")
                   
                   head(raw_data)
        
            
                   #remove first 2 rows of non data
                   
                   new_df <- raw_data |> 
                     filter(!row_number()%in% c(1:2)) |> 
                     rename(raw_text = 1) |> 
                     filter(!str_detect(raw_text, "^-+$"))  #remove rows with 1+ dashes 
                   
                   head(new_df)
                   

                   # Data Tidying 
                   
                   #Split into 2 tables: odd vs even rows ( Name & Matches vs Staes & Rating)\
                   
                   r1_data <- new_df |> 
                     filter(row_number()%% 2==1) #odd
                   
                   
                   r2_data <-new_df |> 
                     filter(row_number()%% 2==0) #even
                   
                   head(r1_data, 4)
                   
                   head(r2_data, 4)
                   

                   

                   #create columns with |
                   
                   sep1_data <- r1_data |> 
                     separate_wider_delim(cols = raw_text, 
                                          delim = "|", 
                                          names = c("Player_Num", "Player_Name", "Total_Points", "R1", "R2", "R3", "R4", "R5", "R6", "R7", NA)) 
                   #naming after each pipe separation, last column was empty space so named "NA" to fill in
                   
                   sep2_data <- r2_data |> 
                     separate_wider_delim( cols = raw_text, 
                                           delim = "|", names = c("Player_State", "Rating_Info", NA, NA, NA, NA, NA, NA, NA, NA, NA)) 
                   # fill in empty columns with NA to run this function

                   # CLEAN AND EXTRACT TARGET DATA
                   
                   clean_sep1 <- sep1_data |>  
                     mutate( Player_Num = as.numeric(str_trim(Player_Num)), # Trim space and gather numbers in Odd rows table
                             Player_Name = str_trim(Player_Name), 
                             Total_Points = as.numeric(str_trim(Total_Points)))
                   
                   clean_sep2 <- sep2_data |> 
                     mutate(
                       Player_State = str_trim(Player_State),
                       Pre_Rating = str_extract(Rating_Info, "R:\\s*\\d+") |> 
                         str_remove("R:\\s*") |> 
                         as.numeric()
                     )
                   
                   # Combine the 2 table back together
                   
                   combined_data <- bind_cols(clean_sep1, clean_sep2)
                   
                   combined_data
                   
                   # Calculate average opponent rating for each player
                   
                   
                   ratings_lookup <- combined_data |>
                     select(Player_Num, Pre_Rating) # reference table creation with IDs and Ratings select(Player_Num, Pre_Rating)
                   
                   ratings_lookup
                   
                   # Calculate opponent pre rating averages in tables 
                   
                   opponent_averages <- combined_data |> 
                     select(Player_Num, R1, R2, R3, R4, R5, R6, R7) |> 
                     pivot_longer(cols = R1:R7, names_to = "Round", values_to = "Match_Result")|> 
                     mutate(Opponent_Num = as.numeric(str_extract(Match_Result, "\\d+"))) |> 
                     filter(!is.na(Opponent_Num)) |> 
                     left_join(ratings_lookup, by = c("Opponent_Num" = "Player_Num")) |> 
                     group_by(Player_Num) |> 
                     summarize(Avg_Opp_Pre_Rating = round(mean(Pre_Rating, na.rm = TRUE))) 
                   
                   opponent_averages
                   

                   
                   


                     # **Finalize and Export to CSV**
                     
                   # Join averages column to main table and select the 5 columns
                   
                   final_project_data <- combined_data |> 
                     left_join(opponent_averages, by = "Player_Num") |> 
                     select( Player_Name, Player_State, Total_Points, Pre_Rating, Avg_Opp_Pre_Rating)
                   
                   # Preview final result
                   
                   head(final_project_data)
                   
                   # Export data set to a CSV file
                   
                   write.csv(final_project_data, "project1_chess_results.csv", row.names = FALSE)

                  

