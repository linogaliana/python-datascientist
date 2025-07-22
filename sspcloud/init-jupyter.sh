#!/bin/bash

SECTION=$1
CHAPTER=$2

#FILE="notebooks/course/manipulation/01_numpy.ipynb"

WORK_DIR="/home/onyxia/work"
if [[ "$3" == "correction" ]];
then 
  PATH_WITHIN="notebooks"
  COURSE_DIR="${CLONE_DIR}/corrections"
else
  PATH_WITHIN="corrections"
  COURSE_DIR="${CLONE_DIR}/notebooks"
fi

BASE_URL="https://raw.githubusercontent.com/linogaliana/python-datascientist-notebooks/main"
NOTEBOOK_PATH="${PATH_WITHIN}/${SECTION}/${CHAPTER}.ipynb"
DOWNLOAD_URL="${BASE_URL}/${NOTEBOOK_PATH}"

# Download the notebook directly using curl
echo $DOWNLOAD_URL
curl -L $DOWNLOAD_URL -o "${WORK_DIR}/${CHAPTER}.ipynb"

# Open the relevant notebook when starting Jupyter Lab
echo "c.LabApp.default_url = '/lab/tree/${CHAPTER}.ipynb'" >> /home/onyxia/.jupyter/jupyter_server_config.py

pip install jupyterlab-quarto