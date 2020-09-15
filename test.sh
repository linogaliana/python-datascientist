#!/bin/bash
# Test automatique des notebooks

python "import cleanmd ; cleanmd.cleanblog()"

cd "./temp"

# CONVERT INTO NOTEBOOKS AND EXECUTE
for i in $(ls **/*.md **/*.Rmd | grep -v 'index.md$'); do
  jupytext --to ipynb --execute "$i"
done