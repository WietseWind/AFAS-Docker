FROM ubuntu:14.04

MAINTAINER Wietse Wind <w.wind@ipublications.net>

ENV DEBIAN_FRONTEND noninteractive
ENV PHPREPO http://ppa.launchpad.net/ondrej/php/ubuntu/pool/main/p/php7.0

# PHP Packages from:
#   https://launchpad.net/~ondrej/+archive/ubuntu/php-7.0/+packages?field.name_filter=php7.0&field.status_filter=published&field.series_filter=trusty
# DEB Listing:
#   http://ppa.launchpad.net/ondrej/php/ubuntu/pool/main/p/php7.0/

RUN echo "debconf debconf/frontend select Noninteractive" | debconf-set-selections

RUN sed -i "s/http:\/\/archive.ubuntu.com/http:\/\/nl3.archive.ubuntu.com/g" /etc/apt/sources.list && \
    apt-get -y --force-yes update

ENV LANGUAGE C.UTF-8
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8

# Configure timezone and locale
RUN export LANGUAGE=C.UTF-8; export LANG=C.UTF-8; export LC_ALL=C.UTF-8; locale-gen C.UTF-8; DEBIAN_FRONTEND=noninteractive dpkg-reconfigure locales; echo "Europe/Amsterdam" > /etc/timezone; dpkg-reconfigure -f noninteractive tzdata

# Install main packages
RUN apt-get -y --force-yes install nano libreoffice-writer pdftk imagemagick abiword expect ssmtp mutt supervisor htop wget curl git lynx locales python-software-properties software-properties-common && \
    add-apt-repository ppa:ondrej/php -y && \
    apt-get -y --force-yes update && \
    apt-get -y --force-yes upgrade && \
    apt-get -y --force-yes install libcurl4-openssl-dev pkg-config libenchant1c2a libgmp10 libmcrypt4 libqdbm14 libxslt1.1 libaspell15 libhunspell-1.3-0 enchant aspell-en aspell dictionaries-common php-common libgd3 libxpm4 libfontconfig1 libfreetype6 libjpeg8 libtiff5 libvpx1 libjpeg-turbo8 libjbig0 fontconfig-config fonts-dejavu-core ttf-bitstream-vera fonts-freefont-ttf gsfonts-x11 gsfonts xfonts-utils libfontenc1 libxfont1 x11-common xfonts-encodings apache2 apache2-bin apache2-data ssl-cert

RUN mkdir -p /var/www/nodum_projects/default && \
    chown -R www-data:root /var/www/nodum_projects && \
    chmod -R 740 /var/www/nodum_projects

# Install PHP7.0
RUN cd /tmp && mkdir php && cd php && \
    apt-get -y --force-yes -f install php7.0-dev php7.0-opcache php7.0-curl php7.0-gd php7.0-common php7.0-ldap php7.0-sqlite3 php7.0-json php7.0 libapache2-mod-php7.0 php7.0-cli && \
    chmod -R 777 /var/lib/php/sessions/ && \
    apt-get -y --force-yes purge && apt-get -y --force-yes clean && apt-get -y --force-yes autoclean && apt-get -y --force-yes autoremove && \
    rm -rf /var/lib/apt/lists/* /tmp/*

# Install MongoDB Driver
RUN cd /tmp && wget http://pear.php.net/go-pear.phar && \
    echo '#!/usr/bin/expect' > /tmp/install-pear.sh && \
    echo 'spawn php /tmp/go-pear.phar' >> /tmp/install-pear.sh && \
    echo 'send "\r"' >> /tmp/install-pear.sh && \
    echo 'expect eof' >> /tmp/install-pear.sh && \
    chmod +x /tmp/install-pear.sh && \
    /tmp/install-pear.sh && \
    rm /tmp/install-pear.sh && \
    rm /tmp/go-pear.phar && \
    php /usr/share/php/pearcmd.php channel-update pecl.php.net && \
    php /usr/share/php/peclcmd.php install mongodb && \
    echo "extension=mongodb.so" > /etc/php/7.0/apache2/conf.d/20-mongo.ini

# Apache config
RUN a2enmod headers rewrite && \
    rm -r /var/www/html && \
    echo '<FilesMatch "\.(txt|md|ini|sql|log|md)$">' >> /etc/apache2/mods-available/php7.0.conf && \
    echo '  Deny from all' >> /etc/apache2/mods-available/php7.0.conf && \
    echo '</FilesMatch>' >> /etc/apache2/mods-available/php7.0.conf && \
    echo '<DirectoryMatch "^\.|\/\.">' >> /etc/apache2/mods-available/php7.0.conf && \
    echo '  Order allow,deny' >> /etc/apache2/mods-available/php7.0.conf && \
    echo '  Deny from all' >> /etc/apache2/mods-available/php7.0.conf && \
    echo '</DirectoryMatch>' >> /etc/apache2/mods-available/php7.0.conf && \
    echo 'opcache.revalidate_freq=100' >> /etc/php/7.0/mods-available/opcache.ini && \
    echo 'opcache.memory_consumption=32' >> /etc/php/7.0/mods-available/opcache.ini && \
    echo 'opcache.max_accelerated_files=130987' >> /etc/php/7.0/mods-available/opcache.ini && \
    echo 'interned_strings_buffer=4' >> /etc/php/7.0/mods-available/opcache.ini && \
    echo 'opcache.enable=1' >> /etc/php/7.0/mods-available/opcache.ini && \
    sed -i "s/^ServerTokens.\+/ServerTokens Prod/g" /etc/apache2/conf-enabled/security.conf && \
    sed -i "s/^ServerSignature.\+/ServerSignature Off/g" /etc/apache2/conf-enabled/security.conf

# PHP Config
RUN sed -i "s/session\.cache_expire.*/session.cache_expire = 18000000/g" /etc/php/7.0/apache2/php.ini && \
    sed -i "s/.*date\.timezone.*=.*/date.timezone = Europe\/Amsterdam/g" /etc/php/7.0/apache2/php.ini && \
    sed -i "s/^expose_php.\+/expose_php = Off/g" /etc/php/7.0/apache2/php.ini && \
    sed -i "s/^max_execution_time.\+/max_execution_time = 600/g" /etc/php/7.0/apache2/php.ini && \
    sed -i "s/^upload_max_filesize.\+/upload_max_filesize = 512M/g" /etc/php/7.0/apache2/php.ini && \
    sed -i "s/^memory_limit.\+/memory_limit = 512M/g" /etc/php/7.0/apache2/php.ini && \
    sed -i "s/^short_open_tag.\+/short_open_tag = On/g" /etc/php/7.0/apache2/php.ini && \
    sed -i "s/^display_errors.\+/display_errors = Off/g" /etc/php/7.0/apache2/php.ini && \
    sed -i "s/^;opcache.enable=.\+/opcache.enable=1/g" /etc/php/7.0/apache2/php.ini

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY mpm_prefork.conf /etc/apache2/mods-available/mpm_prefork.conf
COPY site-enabled.conf /etc/apache2/sites-available/000-default.conf
COPY index.php /var/www/nodum_projects/default/index.php

WORKDIR /var/www/nodum_projects/default

EXPOSE 80

CMD ["/usr/bin/supervisord"]
