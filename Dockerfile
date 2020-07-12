# get shiny serves plus tidyverse packages image
FROM rocker/shiny-verse:3.6.3

# system libraries of general use
RUN apt-get update && apt-get install -y \
    sudo \
    pandoc \
    pandoc-citeproc \
    libcurl4-gnutls-dev \
    libcairo2-dev \
    libxt-dev \
    libssl-dev \
    libssh2-1-dev  \
    libnss3 \
    libnss3-dev
  

# install R packages required 
# (change it dependeing on the packages you need)
RUN R -e "install.packages('remotes', repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('vctrs', repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('fable', repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('shiny', repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('shinydashboard', repos='http://cran.rstudio.com/')"
#RUN R -e "devtools::install_github('andrewsali/shinycssloaders')"
RUN R -e "install.packages('lubridate', repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('magrittr', repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('glue', repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('DT', repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('odbc', repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('DBI', repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('ggthemes', repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('plotly', repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('wesanderson', repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('digest', repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('truncnorm', repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('data.table', repos='http://cran.rstudio.com/')"


# setup nginx
RUN apt-get update && \
apt-get install -y nginx apache2-utils && \
htpasswd -bc /etc/nginx/.htpasswd uid pwd
RUN openssl req -batch -x509 -nodes -days 365 -newkey rsa:2048 \
       -keyout /etc/ssl/private/server.key \
       -out /etc/ssl/private/server.crt

ADD ./nginx.conf /etc/nginx/nginx.conf
ADD ./shiny.conf /etc/nginx/sites-available/shiny.conf
RUN ln -s /etc/nginx/sites-available/shiny.conf /etc/nginx/sites-enabled/shiny.conf

RUN apt-get update && apt-get install -y \
     unixodbc-bin \
     odbc-postgresql

# copy the app to the image

COPY sapp/ui.R /srv/shiny-server/
COPY sapp/server.R /srv/shiny-server/
COPY shiny-server.conf /srv/shiny-server/

# select port
EXPOSE 80 443

# allow permission
RUN sudo chown -R shiny:shiny /srv/shiny-server

# run app
CMD service nginx start && /usr/bin/shiny-server.sh
