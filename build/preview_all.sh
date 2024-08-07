#!/bin/bash

quarto render --profile fr --to html
quarto render --profile en --to html
cd _site/
python3 -m http.server -b 0.0.0.0 5000
