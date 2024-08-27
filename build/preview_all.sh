#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Render the Quarto project with the French profile
echo "Rendering Quarto project with French profile..."
quarto render --profile fr

# Run the Python script to modify sidebars for English
echo "Modifying sidebars to English..."
#python build/sidebar.py --to english

# Render the Quarto project with the English profile
echo "Rendering Quarto project with English profile..."
quarto render --profile en

# Run the Python script to modify sidebars back to French
echo "Modifying sidebars back to French..."
#python build/sidebar.py --to french

echo "Build process completed successfully."
python -m http.server 5000 --bind 0.0.0.0

