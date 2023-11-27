from joblib import dump
import numpy as np
import pandas as pd

from sklearn.model_selection import GridSearchCV
from sklearn.ensemble import GradientBoostingRegressor
from sklearn.impute import SimpleImputer
from sklearn.preprocessing import StandardScaler, OneHotEncoder
from sklearn.pipeline import make_pipeline, Pipeline
from sklearn.compose import make_column_transformer
from sklearn.model_selection import train_test_split

from getdvf import pipeline_fetch_data


def pipeline_define(data):

    numeric_features = data.columns[~data.columns.isin(['month', 'Valeur_fonciere'])].tolist()
    categorical_features = ['month']

    reg = GradientBoostingRegressor(random_state=0)

    numeric_pipeline = make_pipeline(
      SimpleImputer(),
      StandardScaler()
    )
    transformer = make_column_transformer(
        (numeric_pipeline, numeric_features),
        (OneHotEncoder(sparse = False, handle_unknown = "ignore"), categorical_features))
    
    pipe = Pipeline(steps=[('preprocessor', transformer),
                          ('boosting', reg)])

    return pipe


def create_data_cv(data):

    pipe = pipeline_define(data)

    X_train, X_test, y_train, y_test = train_test_split(
            data.drop("Valeur_fonciere", axis = 1),
            data[["Valeur_fonciere"]].values.ravel(),
            test_size = 0.2, random_state = 123
        )

    X = pd.concat((X_train, X_test), axis=0)
    Y = np.concatenate([y_train,y_test])

    param_grid = {
        "boosting__n_estimators": np.linspace(5,25, 5).astype(int),
        "boosting__max_depth": [2,4]
    }
    grid_search = GridSearchCV(pipe, param_grid=param_grid)
    grid_search.fit(X, Y)

    return grid_search, X_train, y_train, X_test, y_test


def train_best_model_cv(data):

    grid_search, X_train, y_train, X_test, y_test = create_data_cv(data)

    pipe_optimal = grid_search.best_estimator_
    pipe_optimal.fit(X_train, y_train)

    return pipe_optimal

def dump_boosting_cv(data, filename='pipe.joblib'):
    pipe_optimal = train_best_model_cv(data)
    dump(pipe_optimal, filename)
    return pipe_optimal

if __name__ == "__main__":
    mutations_paris = pipeline_fetch_data()
    dump_boosting_cv(mutations_paris)
