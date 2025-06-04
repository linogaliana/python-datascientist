#!/bin/bash

sudo apt-get update && \
    sudo apt install -y graphviz
    sudo apt-get -y install wget && \
    sudo apt-get install -y git && \
    sudo apt-get install build-essential -y && \
    sudo apt-get install libmagic-dev -y && \
    sudo DEBIAN_FRONTEND=noninteractive apt install -y imagemagick && \
    rm -rf /var/lib/apt/lists/*
