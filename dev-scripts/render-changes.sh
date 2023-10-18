#!/bin/bash

git diff --name-only >> diff
python build/tweak_render.py
python build/pimp_notebook.py


quarto render --to hugo
find . -name "index.md" | rename -f -d 's/^/_/'

quarto preview --port 5000 --host 0.0.0.0
