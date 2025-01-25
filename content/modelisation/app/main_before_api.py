import joblib
import pandas as pd

model = joblib.load("pipe.joblib")

X_fictif = pd.DataFrame(
    {
        "month": [3, 12],
        "Nombre_de_lots": [1, 2],
        "Code_type_local": [2, 1],
        "Nombre_pieces_principales": [3.0, 6.0],
        "surface": [75.0, 180.0],
    }
)

print(model.predict(X_fictif))
