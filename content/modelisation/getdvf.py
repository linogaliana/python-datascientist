import os
import requests
import duckdb

URL = "https://www.data.gouv.fr/fr/datasets/r/56bde1e9-e214-408b-888d-34c57ff005c4"
FILENAME_DVF_LOCAL = "dvf.parquet"


def download_file(url, file_name):
    """
    Download a file from a given URL and save it locally.

    Args:
        url (str): The URL of the file to be downloaded.
        file_name (str): The local file name to save the downloaded content.

    Returns:
        None
    """
    # Check if the file already exists
    if not os.path.exists(file_name):
        response = requests.get(url)

        if response.status_code == 200:
            with open(file_name, "wb") as f:
                f.write(response.content)
            print("Téléchargement réussi.")
        else:
            print(f"Échec du téléchargement. Code d'état : {response.status_code}")
    else:
        print(f"Le fichier '{file_name}' existe déjà. Aucun téléchargement nécessaire.")


def create_dataset_paris(duckdb_session, xvars):
    """
    Create a Paris dataset based on specified variables.

    Args:
        duckdb_session: The DuckDB session object.
        xvars (list): List of variable names to include in the dataset.

    Returns:
        pandas.DataFrame: The created Paris dataset.
    """
    xvars = ", ".join([f'"{s}"' for s in xvars])

    mutations = duckdb.sql(
        f"""
        SELECT
        date_part('month', "Date mutation") AS month,
        substring("Code postal", 1, 2) AS dep,
        {xvars},
        COLUMNS('Surface Carrez.*')
        FROM dvf
        """
    ).to_df()

    colonnes_surface = mutations.columns[
        mutations.columns.str.startswith("Surface Carrez")
    ]
    mutations.loc[:, colonnes_surface] = (
        mutations.loc[:, colonnes_surface]
        .replace({",": "."}, regex=True)
        .astype(float)
        .fillna(0)
    )
    mutations["surface"] = mutations.loc[:, colonnes_surface].sum(axis=1).astype(int)

    mutations_paris = mutations.drop(
        colonnes_surface.tolist()
        + ["Date mutation"],  # ajouter "confinement" si données 2020
        axis="columns",
    ).copy()

    mutations_paris = mutations_paris.loc[
        mutations_paris["Valeur fonciere"] < 5e6
    ]  # keep only values below 5 millions

    mutations_paris.columns = mutations_paris.columns.str.replace(" ", "_")
    mutations_paris = mutations_paris.dropna(subset=["dep", "Code_type_local", "month"])
    mutations_paris = mutations_paris.loc[mutations_paris["dep"] == "75"]
    mutations_paris = mutations_paris.loc[mutations_paris["Code_type_local"] == 2].drop(
        ["dep", "Code_type_local", "Nombre_de_lots"], axis="columns"
    )
    mutations_paris.loc[mutations_paris["surface"] > 0]

    return mutations_paris


def pipeline_fetch_data(url=URL, file_name=FILENAME_DVF_LOCAL):
    """
    Fetch data, create a DuckDB view, and save the processed data as a Parquet file.

    Args:
        url (str): The URL to download the initial data.
        file_name (str): The local file name to save the downloaded content.

    Returns:
        None
    """
    download_file(url, file_name)
    duckdb.sql(
        f'CREATE OR REPLACE VIEW dvf AS SELECT * FROM read_parquet("dvf.parquet")'
    )

    xvars = [
        "Date mutation",
        "Valeur fonciere",
        "Nombre de lots",
        "Code type local",
        "Nombre pieces principales",
    ]

    data = create_dataset_paris(duckdb, xvars)

    data.to_parquet("input.parquet")

    print(f"Data fetching done, {data.shape[0]} rows available")

    return data


if __name__ == "__main__":
    pipeline_fetch_data()
