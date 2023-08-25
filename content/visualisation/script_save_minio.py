import shutil
import requests
import zipfile
import os
import glob
import pandas as pd

import pyarrow as pa
import pyarrow.parquet as pq
from pyarrow import fs


def import_by_decade(decennie = 1970):

    url = f"https://www.insee.fr/fr/statistiques/fichier/4769950/deces-{decennie}-{decennie+9}-csv.zip"

    req = requests.get(url)

    with open(f"deces_{decennie}.zip",'wb') as f:
        f.write(req.content)

    with zipfile.ZipFile(f"deces_{decennie}.zip", 'r') as zip_ref:
        zip_ref.extractall(f"deces_{decennie}")

    csv_files = glob.glob(os.path.join(f"deces_{decennie}", "*.csv"))

    df = [pd.read_csv(f, sep = ";", encoding="utf-8").assign(annee = f) for f in csv_files]
    df = pd.concat(df)
    df[['nom','prenom']] = df['nomprenom'].str.split("*", expand=True)
    df['prenom'] = df['prenom'].str.replace("/","")
    df['annee'] = df['annee'].str.rsplit("/").str[-1].str.replace("(Deces_|.csv|deces-)","").astype(int)

    shutil.rmtree(f"deces_{decennie}")    
    os.remove(f"deces_{decennie}.zip")

    return df


dfs = [import_by_decade(d) for d in [1970, 1980, 1990, 2000, 2010]]
deces = pd.concat(dfs)


# NAISSANCES -----------------

year = 2021
url_naissance = f"https://www.insee.fr/fr/statistiques/fichier/2540004/nat{year}_csv.zip"

req = requests.get(url_naissance)

with open(f"naissance_{year}.zip",'wb') as f:
    f.write(req.content)

with zipfile.ZipFile(f"naissance_{year}.zip", 'r') as zip_ref:
    zip_ref.extractall(f"naissance_{year}")

naissance = pd.read_csv(f"naissance_{year}/nat{year}.csv", sep = ";")
naissance = naissance.dropna(subset = ['preusuel'] )


# RESTRUCTURE --------------

jean_naiss = naissance.loc[naissance['preusuel'] == "JEAN"].loc[:, ['annais', 'nombre']]
jean_naiss = jean_naiss.rename({"annais": "annee"}, axis = "columns")
jean_naiss = jean_naiss.groupby('annee').sum().reset_index()
jean_deces = deces.loc[deces["prenom"] == "JEAN"]
jean_deces = jean_deces.groupby('annee').size().reset_index()
jean_deces.columns = ['annee', "nombre"]
jean_naiss.columns = ['annee', "nombre"]
df = pd.concat(
    [
        jean_deces.assign(source = "deces"),
        jean_naiss.assign(source = "naissance")
    ])
df = df.loc[df['annee'] != "XXXX"]
df['annee']=df['annee'].astype(int)
df = df.loc[df['annee'] > 1971]


# SAVE IN MINIO --------------

s3 = fs.S3FileSystem(endpoint_override="http://"+"minio.lab.sspcloud.fr")

bucket = "lgaliana"
table = pa.Table.from_pandas(df, preserve_index=False)
pq.write_table(table, f'{bucket}/diffusion/prenoms.parquet', filesystem=s3)

