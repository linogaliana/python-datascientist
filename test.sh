#!/bin/bash
# Test automatique des notebooks

args=("$@")

rm -rf "./temp"

python cleanmd.py


cd "./temp"


test=${args[0]}
extension=${args[1]}
echo "Test: $test"
echo "extension: $extension"


if [ "$test" = true ] ; then
  # CONVERT INTO NOTEBOOKS AND EXECUTE
  for i in $(find . -type f \( -iname "*.md" -o -iname "*.Rmd" \)); do
    echo "Executing $i"
    jupytext --to py --execute "$i"
  done
else
  # Ici :
  #   * $extension = "md"  -> enonces
  #   * $extension = "Rmd" -> corrections
  for i in $(find . -type f -iname "*.$extension"); do
    echo "Converting $i"
    # jupytext --to py --execute "$i"
    jupytext --to ipynb "$i"
  done
fi

for i in $(find . -type f \( -iname "*.md" -o -iname "*.Rmd" \)); do
  rm "$i"
done
