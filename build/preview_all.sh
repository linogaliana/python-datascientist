#!/bin/bash

echo "build/preview_all.sh only previews chapter list in _quarto.yml in French"

./requirements.sh
uv sync
uv run quarto preview --port 5000 --host 0.0.0.0