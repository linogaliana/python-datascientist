df = data.table::data.table(doremifasol::filosofi_com_2016)
data.table::fwrite(df, file = "./data/filosofi_2016.csv")