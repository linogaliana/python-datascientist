#!/bin/bash

apt-get update && \
    apt install -y graphviz
    apt-get -y install wget && \
    apt-get install -y git && \
    apt-get install build-essential -y && \
    apt-get install libmagic-dev -y && \
    apt-get install libgdal-dev -y && \
    DEBIAN_FRONTEND=noninteractive apt install -y imagemagick && \
    rm -rf /var/lib/apt/lists/*
