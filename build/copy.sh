wget -O sirene2024.parquet https://www.data.gouv.fr/fr/datasets/r/c67d4fb4-dc56-491f-83e4-cde858f6cdf5
mc cp sirene2024.parquet s3/lgaliana/data/python-ENSAE/sirene2024.parquet
mc anonymous set download s3/lgaliana/data/python-ENSAE

wget -O dvf.parquet https://www.data.gouv.fr/fr/datasets/r/56bde1e9-e214-408b-888d-34c57ff005c4
mc cp dvf.parquet s3/lgaliana/data/python-ENSAE/dvf.parquet
