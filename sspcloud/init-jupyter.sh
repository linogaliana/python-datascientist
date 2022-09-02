#!/bin/bash

SECTION=$1
CHAPTER=$2

WORK_DIR="/home/onyxia/work"
CLONE_DIR="${WORK_DIR}/repo-git"
COURSE_DIR="${CLONE_DIR}/notebooks/course"

# Clone course repository
rm -rf $CLONE_DIR
REPO_URL="https://github.com/linogaliana/python-datascientist.git"
git clone --depth 1 $REPO_URL $CLONE_DIR

# Put relevant notebook in formation dir
mkdir $FORMATION_DIR
cp "${COURSE_DIR}/${SECTION}/${CHAPTER}.ipynb" "${WORK_DIR}"

# Give write permissions
chown -R onyxia:users $FORMATION_DIR

# Remove useless repositories
rm -r $CLONE_DIR ${WORK_DIR}/lost+found

# Open the relevant notebook when starting Jupyter Lab
jupyter server --generate-config
echo "c.LabApp.default_url = '/lab/tree/${CHAPTER}.ipynb'" >> /home/onyxia/.jupyter/jupyter_server_config.py
