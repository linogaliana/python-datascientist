ARG BASE_IMAGE=rocker/geospatial:4.0.2
ENV PATH="/root/miniconda3/bin:${PATH}"
ARG PATH="/root/miniconda3/bin:${PATH}"

# Use a multi-stage build to install packages
# First stage: install packages
FROM $BASE_IMAGE AS install_packages
# LaTeX packages 
# COPY ./_latex_requirements.txt /tmp/build_image/
# RUN tlmgr update --self
# RUN tlmgr install `cat /tmp/build_image/_latex_requirements.txt | tr '\r\n' ' '`

# R packages 
COPY ./DESCRIPTION /tmp/build_image/
RUN Rscript -e "install.packages('knitr','rmarkdown','blogdown','reticulate')"
RUN Rscript -e "remotes::install_deps('/tmp/build_image', dependencies = TRUE, upgrade = FALSE)"

# Second stage: use the installed packages directories
FROM $BASE_IMAGE
# COPY --from=install_packages /opt/texlive /opt/texlive
# COPY --from=install_packages /usr/local/texlive /usr/local/texlive
COPY --from=install_packages /usr/local/lib/R/site-library /usr/local/lib/R/site-library

RUN apt-get update
RUN apt-get install -y wget && rm -rf /var/lib/apt/lists/*

# Create the environment:
COPY environment.yml .
RUN conda env create -f environment.yml -n test-environment

RUN wget \
    https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh \
    && mkdir /root/.conda \
    && bash Miniconda3-latest-Linux-x86_64.sh -b \
    && rm -f Miniconda3-latest-Linux-x86_64.sh 
RUN conda --version



