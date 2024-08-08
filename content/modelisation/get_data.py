import urllib
import urllib.request
import os
import zipfile
from urllib.request import Request, urlopen
from pathlib import Path
import numpy as np
import pandas as pd
import geopandas as gpd


def download_url(url, save_path):
    with urllib.request.urlopen(url) as dl_file:
        with open(save_path, "wb") as out_file:
            out_file.write(dl_file.read())


def create_votes_dataframes():

    Path("data").mkdir(parents=True, exist_ok=True)

    download_url(
        "https://www2.census.gov/geo/tiger/GENZ2019/shp/cb_2019_us_county_20m.zip",
        "data/shapefile",
    )
    with zipfile.ZipFile("data/shapefile", "r") as zip_ref:
        zip_ref.extractall("data/counties")

    shp = gpd.read_file("data/counties/cb_2019_us_county_20m.shp")
    shp = shp[~shp["STATEFP"].isin(["02", "69", "66", "78", "60", "72", "15"])]
    shp

    df_election = pd.read_csv(
        "https://raw.githubusercontent.com/tonmcg/US_County_Level_Election_Results_08-20/master/2020_US_County_Level_Presidential_Results.csv"
    )
    df_election.head(2)
    population = pd.read_excel(
        "https://www.ers.usda.gov/webdocs/DataFiles/48747/PopulationEstimates.xls?v=290.4",
        header=2,
    ).rename(columns={"FIPStxt": "FIPS"})
    education = pd.read_excel(
        "https://www.ers.usda.gov/webdocs/DataFiles/48747/Education.xls?v=290.4",
        header=4,
    ).rename(columns={"FIPS Code": "FIPS", "Area name": "Area_Name"})
    unemployment = pd.read_excel(
        "https://www.ers.usda.gov/webdocs/DataFiles/48747/Unemployment.xls?v=290.4",
        header=4,
    ).rename(columns={"fips_txt": "FIPS", "area_name": "Area_Name", "Stabr": "State"})
    income = pd.read_excel(
        "https://www.ers.usda.gov/webdocs/DataFiles/48747/PovertyEstimates.xls?v=290.4",
        header=4,
    ).rename(columns={"FIPStxt": "FIPS", "Stabr": "State", "Area_name": "Area_Name"})

    dfs = [
        df.set_index(["FIPS", "State"])
        for df in [population, education, unemployment, income]
    ]
    data_county = pd.concat(dfs, axis=1)
    df_election = df_election.merge(
        data_county.reset_index(), left_on="county_fips", right_on="FIPS"
    )
    df_election["county_fips"] = df_election["county_fips"].astype(str).str.lstrip("0")
    shp["FIPS"] = shp["GEOID"].astype(str).str.lstrip("0")
    votes = shp.merge(df_election, left_on="FIPS", right_on="county_fips")

    req = Request(
        "https://dataverse.harvard.edu/api/access/datafile/3641280?gbrecs=false"
    )
    req.add_header(
        "User-Agent",
        "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:77.0) Gecko/20100101 Firefox/77.0",
    )
    content = urlopen(req)
    df_historical = pd.read_csv(content, sep="\t")
    # df_historical = pd.read_csv('https://dataverse.harvard.edu/api/access/datafile/3641280?gbrecs=false', sep = "\t")

    df_historical = df_historical.dropna(subset=["FIPS"])
    df_historical["FIPS"] = df_historical["FIPS"].astype(int)
    df_historical["share"] = (
        df_historical["candidatevotes"] / df_historical["totalvotes"]
    )
    df_historical = df_historical[["year", "FIPS", "party", "candidatevotes", "share"]]
    df_historical["party"] = df_historical["party"].fillna("other")

    df_historical_wide = df_historical.pivot_table(
        index="FIPS", values=["candidatevotes", "share"], columns=["year", "party"]
    )
    df_historical_wide.columns = [
        "_".join(map(str, s)) for s in df_historical_wide.columns.values
    ]
    df_historical_wide = df_historical_wide.reset_index()
    df_historical_wide["FIPS"] = df_historical_wide["FIPS"].astype(str).str.lstrip("0")
    votes["FIPS"] = votes["GEOID"].astype(str).str.lstrip("0")
    votes = votes.merge(df_historical_wide, on="FIPS")
    votes["winner"] = np.where(
        votes["votes_gop"] > votes["votes_dem"], "republican", "democrats"
    )

    return votes
