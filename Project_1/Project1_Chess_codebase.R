---
  title: "Project 1"
author: "Mei Qi Ng"
date: "`r Sys.Date()`"
output: html_document
---
  
  ```{r setup, include=FALSE}
knitr::opts_chunk$set(echo = TRUE)
```

## [**Approach**]{.underline}

In this project, we are given a text file with chess tournament results where information has some structure. The goal is to create an R markdown file that generates a .CSV file (that could be for example imported into a SQL database) with the following information for all players:
  
  ### *Player’s Name, Player’s State, Total Number of Points, Player’s Pre-Rating, and Average Pre Chess Rating of Opponents*
  
  Starting this there was the challenge of trying to tidy this data set as there are many pipelines and spaces that are in the way as well as trying to extract information to creating columns with the correct names and their corresponding data. Using strings and regular expression often was necessary for me to properly organize the data.

```{r echo=FALSE, out.width="40%", fig.align="center"}
knitr::include_graphics("https://images.pexels.com/photos/277092/pexels-photo-277092.jpeg")

```

(1) Data Loading: The tournament text file will be posted on Github, which allows me to load the data frame.

(2) Data Tidying: Removing headers, separating into smaller tables, cleaning tables, extracting data, combining, and creating new tables for calculation.

(3) Average Opponent Calculation and Hand-calculation: Calculating at least 2 cases averages and comparing that to the averages from "Average Pre Chess Rating of Opponents"

(4) Create CSV: With this newly cleaned up version of this table, a csv file will be created and used to analyze the tournament information.

Challenges: Based on looking at raw tournament txt file, I see that there are some rows of lines and other cells that will need to be cleared up , columns that are not needed for calculation, renaming columns for clarity, rearranging, and changing of characters to integers for easier workaround for this data frame. Create the new table used for average calculation was also difficult so I used Gemini Pro to suggest functions that can be used to create the new columns need for calculation.

# Source:

(1) Gemini Pro - to troubleshoot regular expressions for extracting the opponents ratings.

-   *AI citation -(Google DeepMind. (2026). Gemini Pro [Large language model]. <https://gemini.google.com>. Accessed February 19, 2026*
                     
                     (2) [Posit Stringr/Regrex cheatsheet](https://posit.co/wp-content/uploads/2022/10/strings-1.pdf)
                   
                   (3) R for Data Science 2e : Chapters from Week 3
                   
                   ```{r}
                   # Load data
                   
                   library(tidyverse)
                   
                   raw_data <- read.csv("https://raw.githubusercontent.com/meiqing39/DATA-607/refs/heads/main/Project_1/tournamentinfo.txt")
                   
                   head(raw_data)
                   ```
                   
                   ```{r}
                   #remove first 2 rows of non data
                   
                   new_df <- raw_data |> 
                     filter(!row_number()%in% c(1:2)) |> 
                     rename(raw_text = 1) |> 
                     filter(!str_detect(raw_text, "^-+$"))  #remove rows with 1+ dashes 
                   
                   head(new_df)
                   
                   ```
                   
                   ```{r}
                   # Data Tidying 
                   
                   #Split into 2 tables: odd vs even rows ( Name & Matches vs Staes & Rating)\
                   
                   r1_data <- new_df |> 
                     filter(row_number()%% 2==1) #odd
                   
                   
                   r2_data <-new_df |> 
                     filter(row_number()%% 2==0) #even
                   
                   head(r1_data, 4)
                   
                   head(r2_data, 4)
                   
                   ```
                   
                   ```{r}
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
                   ```
                   
                   ```{r}
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
                   
                   ```
                   
                   # **Hand Calculation**
                   
                   [1] Player who played all games: Player 3 ADITYA BAJAJ
                   
                   ```         
                   Average Opponent's Pre Rating = (1641+955+1745+1563+1712+1666+1663)/7 = 1563.5 = 1534
    
```

| Player Number each played round | Pre Ratings |
|---------------------------------|-------------|
| 8                               | 1641        |
| 61                              | 955         |
| 25                              | 1745        |
| 21                              | 1563        |
| 11                              | 1712        |
| 13                              | 1666        |
| 12                              | 1663        |

[2] Player who played less than all games: Player 53 JOSE C YBARRA

```         
Average Opponent's Pre Rating = (1745+1199+1092)/3 = 1345.33 = 1345
                   ```
                   
                   | Player number of each played rounds | Pre ratings |
                     |-------------------------------------|-------------|
                     | 25                                  | 1745        |
                     | 44                                  | 1199        |
                     | 57                                  | 1092        |
                     
                     # **Finalize and Export to CSV**
                     
                     ```{r}
                   # Join averages column to main table and select the 5 columns
                   
                   final_project_data <- combined_data |> 
                     left_join(opponent_averages, by = "Player_Num") |> 
                     select( Player_Name, Player_State, Total_Points, Pre_Rating, Avg_Opp_Pre_Rating)
                   
                   # Preview final result
                   
                   head(final_project_data)
                   
                   # Export data set to a CSV file
                   
                   write.csv(final_project_data, "project1_chess_results.csv", row.names = FALSE)
                   ```
                   
                   # **Conclusion**
                   
                   I transformed chess tournament chess result from a text file into a formatted CSV file suitable for SQL relational database usage. The challenge of this data set was the many multi-row layout. Chess players would have a distinct row, however the many white spaces, delimiters, and dashed lines took many trial and errors. By using R codes such as regular expressions (stringr) for pattern extraction, tidyr functions (separate_wider_delim) and pivot_longer, I was able to clean, separate and restructure the table into an organized format.
                   
                   After, I calculated the average pre-rating of opponents using smaller tables/combine tables which shows the relational data based connection in SQL. Extracting opponent's ID in match history then joining them with isolated pre rating numbers and sorting out the un-played games and byes, helped in creating the final metrics. These programmed results are then verified against manual hand calculated result to check for accuracy.

In conclusion, this project demonstrated the value of R data cleaning. To manually edit the text file would have taken more time and keen eye which leaves room for mistakes. Developing this R script provides a automated and reproducible file that can quickly process same formatted future tournament information and can be used in SQL for a analysis ready table.
