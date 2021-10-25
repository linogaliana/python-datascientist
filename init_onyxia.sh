#!/bin/bash

# Store git credentials when prompted (for jupyterlab-git extension)
git config --global credential.helper store

# Clone course repository
git clone https://github.com/linogaliana/python-datascientist.git ~/python-datascientist
cp -r ~/python-datascientist/notebooks/course/* /home/jovyan/work/
chown -R jovyan:users /home/jovyan/work/
