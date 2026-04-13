library(tidyverse)
library(readxl)
library(openxlsx)

# Dezarhivăm livrările într-un folder temporar
unzip("data/entregas.zip", exdir = "entregas_temp")

# Listăm TOATE fișierele din folder (inclusiv sub-foldere)
toate_fisierele <- list.files("entregas_temp", recursive = TRUE, full.names = TRUE)

# Căutăm fișierele care conțin "puntos" (Regex)
fisiere_scor <- toate_fisierele[grepl("puntos.*\\.txt$", toate_fisierele, ignore.case = TRUE)]

evalua_list <- list()

for (cale in fisiere_scor) {
  # 1. Extragem numele fișierului (NameFile)
  nume_fisier <- basename(cale)
  
  # 2. Extragem numele de familie din calea folderului (strsplit)
  # Structura tipică: "entregas_temp/Nume Prenume_ID_.../puntos.txt"
  bucati_cale <- unlist(strsplit(cale, "/"))
  folder_student <- bucati_cale[2] # Ajustează indexul în funcție de structura ta
  nume_familie <- unlist(strsplit(folder_student, " "))[1]
  
  # 3. Citim conținutul (readLines) și extragem scorul numeric
  continut <- readLines(cale, warn = FALSE)[1]
  scor_numeric <- as.numeric(gsub("[^0-9]", "", continut)) 
  
  # Stocăm datele
  evalua_list[[cale]] <- data.frame(
    surnames = nume_familie,
    points = scor_numeric,
    NameFile = nume_fisier,
    Points = as.character(continut),
    stringsAsFactors = FALSE
  )
}

evalua_df <- do.call(rbind, evalua_list) %>% arrange(surnames)