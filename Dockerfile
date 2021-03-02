ARG BASE_IMAGE=rocker/geospatial:4.0.2
# Use a multi-stage build to install packages
# First stage: install packages
FROM $BASE_IMAGE AS install_packages

RUN apt-get update
RUN apt-get install -y wget && rm -rf /var/lib/apt/lists/*


RUN wget \
    https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh \
    && mkdir /root/.conda \
    && bash Miniconda3-latest-Linux-x86_64.sh -b \
    && rm -f Miniconda3-latest-Linux-x86_64.sh 

ENV PATH="/root/miniconda3/bin:${PATH}"
RUN conda --version

# Create the environment:
COPY environment.yml .
RUN conda env create -f environment.yml -n test-environment





# R packages 
RUN Rscript -e "install.packages('knitr','rmarkdown','blogdown','reticulate')"

# Second stage: use the installed packages directories
FROM $BASE_IMAGE
# COPY --from=install_packages /opt/texlive /opt/texlive
# COPY --from=install_packages /usr/local/texlive /usr/local/texlive
COPY --from=install_packages /usr/local/lib/R/site-library /usr/local/lib/R/site-library


RUN Rscript -e "print(reticulate::miniconda_path())"

