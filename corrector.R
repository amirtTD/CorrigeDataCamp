# 0. Load necessary libraries
# tidyverse includes dplyr, stringr, and ggplot2
library(tidyverse)
library(readxl)
library(openxlsx)

# 1. Decompress the delivery file
# Replace 'deliveries.zip' with the actual name of your zip file
unzip("data/2025-26 Tractament de les dades Gr.A-T (36423)-Tarea Intermediate R(Datacamp)-3281647 (1).zip", exdir = "decompressed_deliveries")

# 2. Use a regular expression to find all files
all_files <- list.files("decompressed_deliveries", recursive = TRUE, full.names = TRUE)

# Regex to find score files (puntos.txt)
# This looks for files containing "puntos" and ending in .txt
score_regex <- ".*puntos.*\\.txt$"
score_files <- all_files[grepl(score_regex, all_files, ignore.case = TRUE)]

# Regex to find course vouchers (PDF or Images)
voucher_regex <- ".*(voucher|certificat|receipt|comprobante).*\\.(pdf|jpg|png|jpeg)$"
voucher_files <- all_files[grepl(voucher_regex, all_files, ignore.case = TRUE)]

# 3. Extract information and organize it into a data frame
evalua_list <- list()

for (path in score_files) {
  # Extract the name of the file used (NameFile)
  file_name <- basename(path)
  
  # Extract user's last name from the file path (strsplit)
  # Standard structure: "decompressed_deliveries/Surname Name_ID_.../puntos.txt"
  path_components <- unlist(strsplit(path, "/"))
  student_folder <- path_components[2] 
  last_name <- unlist(strsplit(student_folder, " "))[1]
  
  # Import the puntos.txt file and extract the score (readLines)
  # We use regex to extract only the digits from the first line
  file_content <- readLines(path, warn = FALSE)[1]
  extracted_points <- as.numeric(gsub("[^0-9]", "", file_content))
  
  # Store in a temporary data frame
  evalua_list[[path]] <- data.frame(
    surnames = last_name,
    points = extracted_points,
    NameFile = file_name,
    Points = as.character(file_content),
    stringsAsFactors = FALSE
  )
}

# Combine the list into a single data frame (evalua_df)
evalua_df <- do.call(rbind, evalua_list)

# Arrange the data frame in ascending order according to the last name
evalua_df <- evalua_df %>% arrange(surnames)

# 4. Save the first required Excel file
write.xlsx(evalua_df, "NotasRIntermedio.xlsx")

# 5. Load enrolled students information
# Ensure the filename matches your actual Excel file
enrolled_students <- read_excel("data/AlumnosTD25_26.xlsx")

# 6. Combine information (Join)
# We associate the official student list with the delivery analysis
# Assuming 'Apellido(s)' is the column name in your official Excel file
final_report <- enrolled_students %>%
  left_join(evalua_df, by = c("Apellido(s)" = "surnames"))

# 7. Save the final combined data frame
write.xlsx(final_report, "AlumnosNotas.xlsx")

# 8. Integrity check / Summary
cat("Automation complete.\n")
cat("Number of variants for point files found:", length(unique(evalua_df$NameFile)), "\n")
