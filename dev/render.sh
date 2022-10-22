#!/bin/bash

quarto render --to hugo
find . -name "index.md" | rename -f -d 's/^/_/'

hugo server -p 5000 --bind 0.0.0.0
