#!/usr/bin/env bash

# Install recent go version
GO_VERSION="1.18.4"
wget https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz && \
    sudo rm -rf /usr/local/go && \
    sudo tar -C /usr/local -xzf go${GO_VERSION}.linux-amd64.tar.gz

PATH="/usr/local/go/bin:${PATH}"

# Install hugo
HUGO_VERSION="0.97.3" 
wget https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_extended_${HUGO_VERSION}_Linux-64bit.deb && \
    sudo apt install "./hugo_extended_${HUGO_VERSION}_Linux-64bit.deb" && \
    sudo rm -f hugo_extended_${HUGO_VERSION}_Linux-64bit.deb

QUARTO_VERSION="1.0.37"
wget "https://github.com/quarto-dev/quarto-cli/releases/download/v${QUARTO_VERSION}/quarto-${QUARTO_VERSION}-linux-amd64.deb" && \
    sudo apt install "./quarto-${QUARTO_VERSION}-linux-amd64.deb" && \
    sudo rm -f "./quarto-${QUARTO_VERSION}-linux-amd64.deb"


hugo server -p 5000 --bind 0.0.0.0
