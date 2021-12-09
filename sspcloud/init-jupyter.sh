#!/bin/sh

SECTION=$1
CHAPTER=$2

WORK_DIR=/home/jovyan/work
CLONE_DIR=${WORK_DIR}/repo-git
COURSE_DIR=${CLONE_DIR}/notebooks/course
FORMATION_DIR=${WORK_DIR}/formation

# Clone course repository
REPO_URL=https://github.com/linogaliana/python-datascientist.git
git clone --depth 1 $REPO_URL $CLONE_DIR

# Put relevant notebook in formation dir
mkdir $FORMATION_DIR
cp ${COURSE_DIR}/${SECTION}/${CHAPTER}.ipynb ${FORMATION_DIR}/

# Give write permissions
chown -R jovyan:users $FORMATION_DIR

# Remove course Git repository
rm -r $CLONE_DIR

# Open the relevant notebook when starting Jupyter Lab
echo "c.LabApp.default_url = '/lab/tree/formation/${CHAPTER}.ipynb'" >> /home/jovyan/.jupyter/jupyter_server_config.py
