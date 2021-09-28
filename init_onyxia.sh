#!/bin/bash

git clone https://github.com/linogaliana/python-datascientist.git ~/python-datascientist
cp -r ~/python-datascientist/notebooks/course/* /home/jovyan/work/
chown -R jovyan:users /home/jovyan/work/
