#!/bin/bash

git diff --name-only >> diff
python build/tweak_render.py
python build/pimp_notebook.py

quarto render --to hugo
find . -name "index.md" | rename -f -d 's/^/_/'

hugo server -p 5000 --bind 0.0.0.0
