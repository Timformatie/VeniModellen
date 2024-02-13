FROM rocker/shiny-verse:4.3.1

# set environment variables
ENV SHINY_LOG_STDERR=1

# install system dependencies
RUN apt-get update -y && apt-get install -y \
  git \
  make \
  pandoc \
  libssl-dev \
  libcurl4-openssl-dev \
  libicu-dev \
  zlib1g-dev \
  libglpk-dev

WORKDIR /srv/shiny-server/

# install r packages
ENV RENV_VERSION 0.17.0
ENV RENV_CONFIG_REPOS_OVERRIDE=https://packagemanager.rstudio.com/cran/latest
RUN R -e "install.packages('remotes', repos = c(RSPM = 'https://packagemanager.rstudio.com/cran/latest'))"
RUN R -e "install.packages('attachment', repos = c(RSPM = 'https://packagemanager.rstudio.com/cran/latest'))"
RUN R -e "remotes::install_github('rstudio/renv@${RENV_VERSION}')"

COPY renv.lock renv.lock
RUN R -e "renv::restore()"

RUN chown shiny:shiny /srv/shiny-server && \
  chown shiny:shiny /var/log/shiny-server && \
  chown -R shiny:shiny /usr/local/lib/R

COPY . /srv/shiny-server
COPY inst/shiny-server.conf  /etc/shiny-server/shiny-server.conf

# expose port
EXPOSE 8080

# set user
USER shiny

# install dashboard
RUN R -e "attachment::install_from_description()"

CMD ["/usr/bin/shiny-server"]
