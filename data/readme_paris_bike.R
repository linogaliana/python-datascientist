download_dir <- "./data/velo"


df <- lapply(list.files(download_dir,
                        full.names = TRUE),
             function(nm){
               d <- data.table::fread(nm)
               d[,.SD,.SDcols = c("Identifiant du compteur",
                                  "Nom du compteur",
                                  "Identifiant du site de comptage",
                                  "Nom du site de comptage",
                                  "Comptage horaire",
                                  "Date et heure de comptage",
                                  "Date d'installation du site de comptage")]
             })

df <- data.table::rbindlist(df)

data.table::fwrite(df, compress = "gzip",
                   file = "./data/bike.csv")
