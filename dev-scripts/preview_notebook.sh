#!/bin/bash

# Check if a filename is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <filename.qmd>"
    exit 1
fi

# Get the filename passed as an argument
filename="$1"

# Replace the .qmd extension with .ipynb
filename_replace="${filename%.qmd}.ipynb"
echo "$filename_replace"

# Run the first quarto render command
quarto render "$filename" --to ipynb --output "toto.ipynb"

# Run the second quarto render command with the replaced filename
quarto render "toto.ipynb" --execute

echo "Test of notebook generated by ${filename} has been successfull"
