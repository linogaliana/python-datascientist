#!/bin/bash
# Test automatique des notebooks

set test extension

rm -rf "./temp"

python cleanmd.py


cd "./temp"


if [ "$test" = true ] ; then
  # CONVERT INTO NOTEBOOKS AND EXECUTE
  for i in $(ls **/*.md **/*.Rmd | grep -v 'index.md$'); do
    jupytext --to py --execute "$i"
  done
else
  # Ici :
  #   * $extension = "md"  -> enonces
  #   * $extension = "Rmd" -> corrections
  for i in $(find . -type f -iname "*.$extension"); do
    # jupytext --to py --execute "$i"
    jupytext --to ipynb "$i"
    rm "$i"
  done
fi


