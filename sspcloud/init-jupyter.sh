#!/bin/bash

echo $1

ABSPATH=$1
RELPATH="${ABSPATH/notebooks\/course\//""}"
echo $RELPATH
IFS=/ read -r SECTION CHAPTER <<< $RELPATH

echo $SECTION
echo $CHAPTER

WORK_DIR=/home/onyxia/work
CLONE_DIR=${WORK_DIR}/repo-git
COURSE_DIR=${CLONE_DIR}/notebooks/course
FORMATION_DIR=${WORK_DIR}/formation

# Clone course repository
rm -rf $CLONE_DIR
REPO_URL=https://github.com/linogaliana/python-datascientist.git
git clone --depth 1 $REPO_URL $CLONE_DIR

# Put relevant notebook in formation dir
rm -rf $FORMATION_DIR
mkdir $FORMATION_DIR
cp ${COURSE_DIR}/${SECTION}/${CHAPTER} ${FORMATION_DIR}/

# Give write permissions
chown -R onyxia:users $FORMATION_DIR

# Remove course Git repository
rm -r $CLONE_DIR

# Open the relevant notebook when starting Jupyter Lab
jupyter server --generate-config
echo "c.LabApp.default_url = '/lab/tree/formation/${CHAPTER}'" >> /home/onyxia/.jupyter/jupyter_server_config.py
