#!/usr/bin/env bash
set -euo pipefail

# Install the Quarto CLI (needed by the Quarto VS Code extension to render/preview
# .qmd files and notebooks, including callout formatting). Pinned to the same
# version used by CI (.github/workflows/prod.yml) for consistent rendering.
QUARTO_VERSION="1.8.26"
ARCH="$(dpkg --print-architecture)"
DEB_PATH="/tmp/quarto-${QUARTO_VERSION}.deb"

curl -fsSL -o "${DEB_PATH}" \
  "https://github.com/quarto-dev/quarto-cli/releases/download/v${QUARTO_VERSION}/quarto-${QUARTO_VERSION}-linux-${ARCH}.deb"
sudo dpkg -i "${DEB_PATH}"
rm -f "${DEB_PATH}"

quarto --version

echo ""
echo "Quarto CLI installed. Python packages are NOT pre-installed:"
echo "  pip install -e ."
echo "to install this course's dependencies from pyproject.toml."
