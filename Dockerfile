FROM ubuntu:xenial

ENV TERM linux

# Install sudo, create script directory
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections \
    && echo '### Update apt-get ###' \
    && apt-get -y update \
    && echo '### Upgrade apt-get' \
    && apt-get -y upgrade \
    && echo '### Install sudo' \
    && apt-get -y install sudo \
    && echo '### Install wget' \
    && sudo apt-get -y install wget \
    && echo '### Install nginx' \
    && sudo apt-get -y install nginx \
    && echo '### Install Pipe Viewer' \
    && sudo apt-get -y install pv \
    && echo '### Install SSH' \
    && sudo apt-get -y install ssh \
    && echo '### Install SSH Pass' \
    && sudo apt-get -y install sshpass \
    && echo '### Install SSHFS' \
    && sudo apt-get -y install sshfs \
    && echo '### Install Oracle JAVA 8' \
    && sudo apt-get -y install software-properties-common \
    && sudo apt-get install -y python-software-properties debconf-utils \
    && sudo add-apt-repository -y ppa:webupd8team/java \
    && sudo apt-get update \
    && echo "oracle-java8-installer shared/accepted-oracle-license-v1-1 select true" | sudo debconf-set-selections \
    && sudo apt-get install -y oracle-java8-installer \
    && echo '### Create folders' \
    && mkdir /scripts

# change working directory for getting jira install data
WORKDIR /tmp

# download JIRA install archive
RUN wget --no-check-certificate --progress=bar --show-progress https://downloads.atlassian.com/software/jira/downloads/atlassian-jira-software-7.6.2.tar.gz

# change back workdir to root
WORKDIR /

# copy scripts into container
COPY scripts/install-jira /scripts/
COPY scripts/env-script-replacement /scripts/
COPY scripts/env-xml-replacement /scripts/

# Copy configs to tmp folder (will get copied in install script)
COPY config/server.xml /tmp/
COPY config/dbconfig.xml /tmp/

# Copy jira service script and nginx config
COPY scripts/jira /etc/init.d/
COPY config/jira.conf /etc/nginx/conf.d/

# make scripts executable and start nginx
RUN chmod a+x /scripts/install-jira \
    && chmod a+x /scripts/env-xml-replacement \
    && chmod a+x /scripts/env-script-replacement \
    && chmod \+x /etc/init.d/jira \
    && update-rc.d jira defaults

# Expose port 80 to access jira locally
EXPOSE 80

ENTRYPOINT ./scripts/env-script-replacement \
           && ./scripts/env-xml-replacement \
           && ./scripts/install-jira \
           && /bin/bash

CMD /bin/bash
