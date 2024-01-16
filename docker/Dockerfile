FROM inseefrlab/onyxia-jupyter-python:py3.10.13

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
RUN python -m gensim.downloader --download glove-wiki-gigaword-200

EXPOSE 5000
CMD ["pip", "freeze"]
