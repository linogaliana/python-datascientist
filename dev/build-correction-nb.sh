#!/bin/bash

git diff --name-only >> diff
python build/tweak_render.py
python build/pimp_notebook.py
python build/tweak_headers_quarto.py

quarto render content --to ipynb --execute
mkdir -p corrections
python build/move_files.py corrections
