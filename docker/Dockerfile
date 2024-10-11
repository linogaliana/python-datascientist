FROM inseefrlab/onyxia-vscode-python:py3.12.6-2024.10.07

USER root

RUN apt-get -y update && \
    apt-get -y install wget && \
    apt-get install -y git && \
    apt-get install build-essential -y && \
    apt-get install libmagic-dev -y && \
    rm -rf /var/lib/apt/lists/*
 
RUN apt-get -y update && \
    DEBIAN_FRONTEND=noninteractive apt install -y imagemagick

RUN which python

COPY requirements.txt .
COPY requirements.sh .

# Install graphviz
RUN pip install -r requirements.txt && \
    chmod +x requirements.sh && \
    ./requirements.sh

RUN pip freeze 

RUN python -m spacy download en_core_web_sm


EXPOSE 5000
CMD ["pip", "freeze"]
