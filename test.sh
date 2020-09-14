#!/bin/bash
# Test automatique des notebooks



cd "./content"

# CONVERT INTO NOTEBOOKS AND EXECUTE
for i in $(ls **/*.md **/*.Rmd | grep -v 'index.md$'); do
  jupytext --to ipynb -execute "$i"
done