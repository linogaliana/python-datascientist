#!/bin/bash

# Install recent go version
GO_VERSION="1.19.2"
wget https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz -O go.tar.gz && \
    sudo rm -rf /usr/local/go && \
    sudo tar -C /usr/local -xzf go.tar.gz && \
    sudo rm go.tar.gz
echo "PATH=$PATH:/usr/local/go/bin" >> $HOME/.profile

# Install hugo
HUGO_VERSION="0.104.3" 
wget https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_${HUGO_VERSION}_linux-amd64.deb -O hugo.deb && \
    sudo dpkg -i hugo.deb && \
    sudo rm hugo.deb

QUARTO_VERSION="1.1.251"
wget "https://github.com/quarto-dev/quarto-cli/releases/download/v${QUARTO_VERSION}/quarto-${QUARTO_VERSION}-linux-amd64.deb" -O quarto.deb && \
    sudo dpkg -i quarto.deb && \
    sudo rm quarto.deb

# source $HOME/.profile
