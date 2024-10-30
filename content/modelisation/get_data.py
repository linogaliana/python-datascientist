import urllib.request
import zipfile
from pathlib import Path
import numpy as np
import pandas as pd
import geopandas as gpd
from urllib.request import Request, urlopen

# Constants
DATA_DIR = Path("data")
COUNTY_ZIP_URL = (
    "https://www2.census.gov/geo/tiger/GENZ2019/shp/cb_2019_us_county_20m.zip"
)
ELECTION_RESULTS_URL = (
    "https://raw.githubusercontent.com/tonmcg/US_County_Level_Election_Results_08-20"
    "/master/2020_US_County_Level_Presidential_Results.csv"
)
POPULATION_DATA_URL = (
    "https://www.ers.usda.gov/webdocs/DataFiles/48747/PopulationEstimates.xls?v=290.4"
)
EDUCATION_DATA_URL = (
    "https://www.ers.usda.gov/webdocs/DataFiles/48747/Education.xls?v=290.4"
)
UNEMPLOYMENT_DATA_URL = (
    "https://www.ers.usda.gov/webdocs/DataFiles/48747/Unemployment.xls?v=290.4"
)
INCOME_DATA_URL = (
    "https://www.ers.usda.gov/webdocs/DataFiles/48747/PovertyEstimates.xls?v=290.4"
)
HISTORICAL_DATA_URL = (
    "https://dataverse.harvard.edu/api/access/datafile/3641280?gbrecs=false"
)


# Utility functions
def download_file(url, save_path):
    """Download file from a URL to a specified path."""
    with urllib.request.urlopen(url) as response:
        with open(save_path, "wb") as out_file:
            out_file.write(response.read())


def extract_zip(file_path, extract_to):
    """Extract a ZIP file to the specified directory."""
    with zipfile.ZipFile(file_path, "r") as zip_ref:
        zip_ref.extractall(extract_to)


# Data download functions
def download_shapefile():
    """Download and extract shapefile data for US counties."""
    DATA_DIR.mkdir(parents=True, exist_ok=True)
    shapefile_path = DATA_DIR / "shapefile.zip"
    download_file(COUNTY_ZIP_URL, shapefile_path)
    extract_zip(shapefile_path, DATA_DIR / "counties")


def load_shapefile():
    """Load the county shapefile and filter out non-contiguous US states."""
    shp = gpd.read_file(DATA_DIR / "counties/cb_2019_us_county_20m.shp")
    excluded_states = {"02", "69", "66", "78", "60", "72", "15"}
    return shp[~shp["STATEFP"].isin(excluded_states)]


def load_election_results():
    """Load the county-level election results for 2020."""
    return pd.read_csv(ELECTION_RESULTS_URL)


def load_additional_data():
    """Load additional demographic data: population, education, unemployment, and income."""
    population = pd.read_excel(POPULATION_DATA_URL, header=2).rename(
        columns={"FIPStxt": "FIPS"}
    )
    education = pd.read_excel(EDUCATION_DATA_URL, header=4).rename(
        columns={"FIPS Code": "FIPS", "Area name": "Area_Name"}
    )
    unemployment = pd.read_excel(UNEMPLOYMENT_DATA_URL, header=4).rename(
        columns={"fips_txt": "FIPS", "area_name": "Area_Name", "Stabr": "State"}
    )
    income = pd.read_excel(INCOME_DATA_URL, header=4).rename(
        columns={"FIPStxt": "FIPS", "Stabr": "State", "Area_name": "Area_Name"}
    )
    return [population, education, unemployment, income]


def merge_demographic_data(demographic_dfs):
    """Merge demographic data on 'FIPS' and 'State' fields."""
    return pd.concat(
        [df.set_index(["FIPS", "State"]) for df in demographic_dfs], axis=1
    ).reset_index()


def load_historical_data():
    """Load and clean historical election data."""
    req = Request(HISTORICAL_DATA_URL)
    req.add_header(
        "User-Agent",
        "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:77.0) Gecko/20100101 Firefox/77.0",
    )
    content = urlopen(req)
    df = pd.read_csv(content, sep="\t").dropna(subset=["FIPS"])
    df["FIPS"] = df["FIPS"].astype(int)
    df["share"] = df["candidatevotes"] / df["totalvotes"]
    df["party"] = df["party"].fillna("other")
    return df.pivot_table(
        index="FIPS", values=["candidatevotes", "share"], columns=["year", "party"]
    ).reset_index()


# Main function
def create_votes_dataframes():
    """Create the final DataFrame containing votes, demographic data, and historical trends."""
    download_shapefile()
    shp = load_shapefile()
    shp["FIPS"] = shp["GEOID"].astype(str).str.lstrip("0")

    df_election = load_election_results()
    demographic_dfs = load_additional_data()
    data_county = merge_demographic_data(demographic_dfs)

    df_election = df_election.merge(
        data_county, left_on="county_fips", right_on="FIPS", how="left"
    )
    df_election["county_fips"] = df_election["county_fips"].astype(str).str.lstrip("0")

    votes = shp.merge(df_election, left_on="FIPS", right_on="county_fips", how="left")

    df_historical_wide = load_historical_data()
    df_historical_wide.columns = [
        "_".join(map(str, col)).strip("_") for col in df_historical_wide.columns.values
    ]
    df_historical_wide["FIPS"] = df_historical_wide["FIPS"].astype(str).str.lstrip("0")

    votes = votes.merge(df_historical_wide, on="FIPS", how="left")
    votes["winner"] = np.where(
        votes["votes_gop"] > votes["votes_dem"], "republican", "democrat"
    )

    return votes
