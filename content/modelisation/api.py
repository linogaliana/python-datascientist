"""A simple API to expose our trained RandomForest model for Tutanic survival."""
from fastapi import FastAPI
from joblib import load

import pandas as pd

model = load('pipe.joblib')

app = FastAPI(
    title="Quel est le prix de ce logement ?",
    description=
    "Application du boosting sur les données DVF 🏡 <br>Une version par API pour faciliter la réutilisation du modèle 🚀" +\
        "<br><br><img src=\"https://upload.wikimedia.org/wikipedia/fr/thumb/9/90/Tour_Montparnasse_Mars_2021.jpeg/1200px-Tour_Montparnasse_Mars_2021.jpeg\" width=\"200\">"
    )


@app.get("/", tags=["Welcome"])
def show_welcome_page():
    """
    Show welcome page with model name and version.
    """

    return {
        "Message": "API de prédiction des prix de l'immobilier",
        "Model_name": 'DVF ML',
        "Model_version": "0.1",
    }


@app.get("/predict", tags=["Predict"])
async def predict(
    month: int = 3,
    nombre_lots: int = 1,
    code_type_local: int = 2,
    nombre_pieces_principales: int = 3,
    surface: float = 75
) -> float:
    """
    """

    df = pd.DataFrame(
        {
            "month": [month],
            "Nombre_de_lots": [nombre_lots],
            "Code_type_local": [code_type_local],
            "Nombre_pieces_principales": [nombre_pieces_principales],
            "surface": [surface]
        }
    )

    prediction = model.predict(df)

    return prediction


