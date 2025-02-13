#!/bin/bash

# Install VSCode personal parameters ---------

curl -sSL https://raw.githubusercontent.com/linogaliana/init-scripts/refs/heads/main/install-copilot.sh | bash

# Install dependencies -----------

git clone https://github.com/linogaliana/python-datascientist.git --single-branch --depth 1
cd python-datascientist
#pip install uv
#uv pip install -r requirements.txt --system
pip install -r requirements.txt

# Formatters and precommit

pre-commit install
pre-commit run --all-files

# Run nbstripout installation command in the terminal
echo "Running nbstripout --install..."
nbstripout --install
