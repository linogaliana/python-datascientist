#!/bin/bash

quarto render --profile fr
quarto render --profile en
cd _site/
python3 -m http.server -b 0.0.0.0 5000
