FROM rocker/verse:4.3.3
RUN apt-get update && apt-get install -y  libcurl4-openssl-dev libicu-dev libssl-dev libxml2-dev make pandoc zlib1g-dev && rm -rf /var/lib/apt/lists/*
RUN mkdir -p /usr/local/lib/R/etc/ /usr/lib/R/etc/
RUN echo "options(repos = c(CRAN = 'https://cran.rstudio.com/'), download.file.method = 'libcurl', Ncpus = 4)" | tee /usr/local/lib/R/etc/Rprofile.site | tee /usr/lib/R/etc/Rprofile.site
RUN R -e 'install.packages("remotes")'
RUN Rscript -e 'remotes::install_version("cli",upgrade="never", version = "3.6.3")'
RUN Rscript -e 'remotes::install_version("R6",upgrade="never", version = "2.5.1")'
RUN Rscript -e 'remotes::install_version("curl",upgrade="never", version = "6.1.0")'
RUN Rscript -e 'remotes::install_version("bslib",upgrade="never", version = "0.8.0")'
RUN Rscript -e 'remotes::install_version("httr",upgrade="never", version = "1.4.7")'
RUN Rscript -e 'remotes::install_version("shiny",upgrade="never", version = "1.10.0")'
RUN Rscript -e 'remotes::install_version("config",upgrade="never", version = "0.3.2")'
RUN Rscript -e 'remotes::install_version("testthat",upgrade="never", version = "3.2.3")'
RUN Rscript -e 'remotes::install_version("spelling",upgrade="never", version = "2.3.1")'
RUN Rscript -e 'remotes::install_version("urltools",upgrade="never", version = "1.7.3")'
RUN Rscript -e 'remotes::install_version("rvest",upgrade="never", version = "1.0.4")'
RUN Rscript -e 'remotes::install_version("purrr",upgrade="never", version = "1.0.2")'
RUN Rscript -e 'remotes::install_version("golem",upgrade="never", version = "0.5.1")'
RUN mkdir /build_zone
ADD . /build_zone
WORKDIR /build_zone
RUN R -e 'remotes::install_local(upgrade="never")'
RUN rm -rf /build_zone
EXPOSE 3838
CMD  ["R", "-e", "options('shiny.port'=3838,shiny.host='0.0.0.0');library(css2r);css2r::run_app()"]
