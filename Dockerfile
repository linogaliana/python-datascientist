ARG BASE_IMAGE=rocker/verse:4.0.2

# Use a multi-stage build to install packages
# First stage: install packages
FROM $BASE_IMAGE AS install_packages

RUN apt-get update
RUN apt-get install -y wget && rm -rf /var/lib/apt/lists/*


RUN wget \
    https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh \
    && mkdir /root/.conda \
    && bash Miniconda3-latest-Linux-x86_64.sh -b -p /opt/conda \
    && rm -f Miniconda3-latest-Linux-x86_64.sh \
    && useradd -s /bin/bash miniconda
    
RUN chown -R miniconda:miniconda /opt/conda \
    && chmod -R go-w /opt/conda
    
# RUN chown -R miniconda:miniconda /opt/conda \
#     && chmod -R go-w /opt/conda
    
RUN ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh
    
ENV PATH /opt/conda/bin:$PATH
RUN conda --version


# Create the environment:
COPY environment_test.yml .
# RUN conda env create -f environment.yml -n test-environment
RUN conda env create -f environment_test.yml -n test-environment


# R packages 
RUN Rscript -e "install.packages(c('knitr','rmarkdown','blogdown'))"
RUN Rscript -e 'install.packages("reticulate")'

# WRITE RETICULATE_PYTHON VARIABLE IN .Renviron
RUN echo "RETICULATE_PYTHON = '/opt/conda/bin'" >> /usr/local/lib/R/etc/Renviron

RUN echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc && \
    echo "conda activate base" >> ~/.bashrc



# Second stage: use the installed packages directories
FROM $BASE_IMAGE
# COPY --from=install_packages /opt/texlive /opt/texlive
# COPY --from=install_packages /usr/local/texlive /usr/local/texlive
COPY --from=install_packages /usr/local/lib/R/site-library /usr/local/lib/R/site-library

