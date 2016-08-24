FROM nodum/php:latest

MAINTAINER Wietse Wind <w.wind@ipublications.net>

ENV DEBIAN_FRONTEND noninteractive
ENV LANGUAGE C.UTF-8
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8

RUN echo "debconf debconf/frontend select Noninteractive" | debconf-set-selections
RUN export LANGUAGE=C.UTF-8; export LANG=C.UTF-8; export LC_ALL=C.UTF-8; locale-gen C.UTF-8; DEBIAN_FRONTEND=noninteractive dpkg-reconfigure locales; echo "Europe/Amsterdam" > /etc/timezone; dpkg-reconfigure -f noninteractive tzdata

RUN apt-get -y --force-yes update && apt-get -y --force-yes upgrade
RUN git clone -b master https://github.com/WietseWind/AFAS-Docker.git /var/www/nodum_projects/default/

WORKDIR /var/www/nodum_projects/default

EXPOSE 80

CMD ["/usr/bin/supervisord"]