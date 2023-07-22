#!/bin/bash

SECTION=$1
CHAPTER=$2

#FILE="notebooks/course/manipulation/01_numpy.ipynb"

WORK_DIR="/home/onyxia/work"
CLONE_DIR="${WORK_DIR}/repo-git"
if [[ "$3" == "correction" ]];
then 
  COURSE_DIR="${CLONE_DIR}/corrections/course"
else
  COURSE_DIR="${CLONE_DIR}/notebooks/course"
fi

# Clone course repository
REPO_URL="https://github.com/linogaliana/python-datascientist-notebooks.git"
git clone --depth 1 $REPO_URL $CLONE_DIR

# Put relevant notebook in formation dir
cp "${COURSE_DIR}/${SECTION}/${CHAPTER}.ipynb" "${WORK_DIR}"

# Remove useless repositories
rm -rf $CLONE_DIR ${WORK_DIR}/lost+found

# Open the relevant notebook when starting Jupyter Lab
jupyter server --generate-config
echo "c.LabApp.default_url = '/lab/tree/work/${CHAPTER}.ipynb'" >> /home/onyxia/.jupyter/jupyter_server_config.py
