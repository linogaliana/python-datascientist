#!/bin/bash
# Test automatique des notebooks

#args=("$@")

echo "Creating folder -------------"

rm -rf "./temp"
mkdir -p temp

echo "Running python snippets to clean markdown -----------"


python cleanmd.py


cd "./temp"

echo "Jupytext ------------------"


#correction=${args[0]}
#extension=${args[1]}
correction=false
extension="Rmd"
echo "Correction: $correction"
echo "extension: $extension"


if [ "$correction" = true ] ; then
  # CONVERT INTO NOTEBOOKS AND EXECUTE
  for i in $(find . -type f \( -iname "*.md" -o -iname "*.Rmd" \)); do
    echo "Executing $i"
    jupytext --to py --execute "$i"
  done
else
  # Ici :
  #   * $extension = "md"  -> enonces
  #   * $extension = "Rmd" -> corrections
  for i in $(find . -type f \( -iname "*.md" -o -iname "*.Rmd" \)); do
    echo "Converting $i"
    # jupytext --to py --execute "$i"
    jupytext --to ipynb "$i"
    #jupyter nbconvert --to notebook --execute --inplace ${i/$extension/ipynb}
  done
fi

for i in $(find . -type f \( -iname "*.md" -o -iname "*.Rmd" \)); do
  rm "$i"
done
