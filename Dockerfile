# Docker file for the donation simulation project
# Alistair Clark, February, 2020

# use rocker/tidyverse as the base image
FROM rocker/tidyverse

# install R packages
RUN apt-get update -qq && apt-get -y --no-install-recommends install \ 
    && install2.r --error \
    MASS \
    docopt \
    scales

CMD ["/bin/bash"]˝