FROM ubuntu:18.04

MAINTAINER Wietse Wind <w.wind@ipublications.net>

ENV DEBIAN_FRONTEND noninteractive
ENV PHPREPO http://ppa.launchpad.net/ondrej/php/ubuntu/pool/main/p/php7.0
ENV PHPBUILD 7.0.33-10+ubuntu18.04.1+deb.sury.org+1


RUN echo "debconf debconf/frontend select Noninteractive" | debconf-set-selections
RUN sed -i "s/http:\/\/archive.ubuntu.com\//http:\/\/mirror.transip.net\/ubuntu\//g" /etc/apt/sources.list && \
    apt-get -y  update

ENV LANGUAGE C.UTF-8
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8

# Configure timezone and locale
# Install main packages
RUN apt-get -y  install locales tzdata nano libssl-dev supervisor htop wget curl git lynx locales software-properties-common && \
    apt-get -y  update && \
    apt-get -y  upgrade && \
    apt-get -y  install apache2 apache2-bin apache2-data ssl-cert

RUN export LANGUAGE=C.UTF-8; export LANG=C.UTF-8; export LC_ALL=C.UTF-8; locale-gen C.UTF-8; DEBIAN_FRONTEND=noninteractive dpkg-reconfigure locales; echo "Europe/Amsterdam" > /etc/timezone; dpkg-reconfigure -f noninteractive tzdata

RUN mkdir -p /var/www/nodum_projects/default && \
    chown -R www-data:root /var/www/nodum_projects && \
    chmod -R 740 /var/www/nodum_projects

# Apache config
RUN a2enmod headers rewrite remoteip && \
    echo '<FilesMatch "\.(txt|md|ini|sql|log|md)$">' >> /etc/apache2/conf-enabled/security.conf && \
    echo '  Deny from all' >> /etc/apache2/conf-enabled/security.conf && \
    echo '</FilesMatch>' >> /etc/apache2/conf-enabled/security.conf && \
    echo '<DirectoryMatch "^\.|\/\.">' >> /etc/apache2/conf-enabled/security.conf && \
    echo '  Order allow,deny' >> /etc/apache2/conf-enabled/security.conf && \
    echo '  Deny from all' >> /etc/apache2/conf-enabled/security.conf && \
    echo '</DirectoryMatch>' >> /etc/apache2/conf-enabled/security.conf && \
    sed -i "s/^ServerTokens.\+/ServerTokens Prod/g" /etc/apache2/conf-enabled/security.conf && \
    sed -i "s/^ServerSignature.\+/ServerSignature Off/g" /etc/apache2/conf-enabled/security.conf && \
    sed -i 's/^LogFormat "%h /LogFormat "%a /g' /etc/apache2/apache2.conf && \
    sed -i "s/Use mod_remoteip instead\(.\+\)/Use mod_remoteip instead\1\nRemoteIPHeader X-Forwarded-For/g" /etc/apache2/apache2.conf

RUN echo "[supervisord]" > /etc/supervisor/conf.d/supervisord.conf && \
    echo "nodaemon=true" >> /etc/supervisor/conf.d/supervisord.conf && \
    echo "" >> /etc/supervisor/conf.d/supervisord.conf && \
    echo "[program:httpd]" >> /etc/supervisor/conf.d/supervisord.conf && \
    echo 'command=/bin/bash -c "rm -rf /run/apache2/* && /usr/sbin/apachectl -D FOREGROUND"' >> /etc/supervisor/conf.d/supervisord.conf

RUN echo "<IfModule mpm_prefork_module>" > /etc/apache2/mods-available/mpm_prefork.conf && \
    echo "StartServers             1" >> /etc/apache2/mods-available/mpm_prefork.conf && \
    echo "MinSpareServers          1" >> /etc/apache2/mods-available/mpm_prefork.conf && \
    echo "MaxSpareServers          2" >> /etc/apache2/mods-available/mpm_prefork.conf && \
    echo "MaxRequestWorkers        6" >> /etc/apache2/mods-available/mpm_prefork.conf && \
    echo "MaxConnectionsPerChild   75" >> /etc/apache2/mods-available/mpm_prefork.conf && \
    echo "</IfModule>" >> /etc/apache2/mods-available/mpm_prefork.conf

RUN echo '<VirtualHost *:80>' > /etc/apache2/sites-available/000-default.conf && \
    echo '    ServerName nodum' >> /etc/apache2/sites-available/000-default.conf && \
    echo '    <Directory /var/www/nodum_projects/default>' >> /etc/apache2/sites-available/000-default.conf && \
    echo '        AllowOverride All' >> /etc/apache2/sites-available/000-default.conf && \
    echo '        Options -Indexes' >> /etc/apache2/sites-available/000-default.conf && \
    echo '    </Directory>' >> /etc/apache2/sites-available/000-default.conf && \
    echo '    ServerAdmin webmaster@server.nodum.io' >> /etc/apache2/sites-available/000-default.conf && \
    echo '    DocumentRoot /var/www/nodum_projects/default' >> /etc/apache2/sites-available/000-default.conf && \
    echo '    ErrorLog ${APACHE_LOG_DIR}/error.log' >> /etc/apache2/sites-available/000-default.conf && \
    echo '    CustomLog ${APACHE_LOG_DIR}/access.log combined' >> /etc/apache2/sites-available/000-default.conf && \
    echo '</VirtualHost>' >> /etc/apache2/sites-available/000-default.conf

# Install main packages
RUN LC_ALL=C.UTF-8 add-apt-repository ppa:ondrej/php -y && \
    apt-get -y  install expect build-essential libcurl4-openssl-dev pkg-config libmcrypt4 && \
    apt-get -y  update && \
    apt-get -y  install php-common libssl1.1 libgd3 libxslt1.1

# Install PHP7.0
RUN cd /tmp && mkdir php && cd php && \
    apt-get -y  install libsigsegv2 m4 autotools-dev libltdl-dev build-essential autoconf automake shtool libtool && \
    wget $PHPREPO/php7.0-common_${PHPBUILD}_amd64.deb && \
    wget $PHPREPO/php7.0-json_${PHPBUILD}_amd64.deb && \
    wget $PHPREPO/php7.0-gd_${PHPBUILD}_amd64.deb && \
    wget $PHPREPO/php7.0-curl_${PHPBUILD}_amd64.deb && \
    wget $PHPREPO/php7.0-mysql_${PHPBUILD}_amd64.deb && \
    wget $PHPREPO/php7.0-ldap_${PHPBUILD}_amd64.deb && \
    wget $PHPREPO/php7.0-opcache_${PHPBUILD}_amd64.deb && \
    wget $PHPREPO/php7.0-sqlite3_${PHPBUILD}_amd64.deb && \
    wget $PHPREPO/php7.0-readline_${PHPBUILD}_amd64.deb && \
    wget $PHPREPO/php7.0-cli_${PHPBUILD}_amd64.deb && \
    wget $PHPREPO/libapache2-mod-php7.0_${PHPBUILD}_amd64.deb && \
    wget $PHPREPO/php7.0-dev_${PHPBUILD}_amd64.deb && \
    wget $PHPREPO/php7.0-xml_${PHPBUILD}_amd64.deb && \
    wget $PHPREPO/php7.0_${PHPBUILD}_all.deb && \
    wget http://ppa.launchpad.net/ondrej/php/ubuntu/pool/main/p/pcre3/libpcre3_8.43-1+ubuntu18.04.1+deb.sury.org+1_amd64.deb && \
    wget http://ppa.launchpad.net/ondrej/php/ubuntu/pool/main/p/pcre3/libpcrecpp0v5_8.43-1+ubuntu18.04.1+deb.sury.org+1_amd64.deb && \
    wget http://ppa.launchpad.net/ondrej/php/ubuntu/pool/main/p/pcre3/libpcre3-dev_8.43-1+ubuntu18.04.1+deb.sury.org+1_amd64.deb && \
    wget http://ppa.launchpad.net/ondrej/php/ubuntu/pool/main/p/pcre3/libpcre16-3_8.43-1+ubuntu18.04.1+deb.sury.org+1_amd64.deb && \
    wget http://ppa.launchpad.net/ondrej/php/ubuntu/pool/main/p/pcre3/libpcre32-3_8.43-1+ubuntu18.04.1+deb.sury.org+1_amd64.deb	 && \
    dpkg -i libpcre16-3_8.43-1+ubuntu18.04.1+deb.sury.org+1_amd64.deb && \
    dpkg -i libpcre32-3_8.43-1+ubuntu18.04.1+deb.sury.org+1_amd64.deb	 && \
    dpkg -i libpcre3_8.43-1+ubuntu18.04.1+deb.sury.org+1_amd64.deb && \
    dpkg -i libpcrecpp0v5_8.43-1+ubuntu18.04.1+deb.sury.org+1_amd64.deb && \
    dpkg -i libpcre3-dev_8.43-1+ubuntu18.04.1+deb.sury.org+1_amd64.deb && \
    dpkg -i php7.0-common_${PHPBUILD}_amd64.deb && \
    dpkg -i php7.0-json_${PHPBUILD}_amd64.deb && \
    dpkg -i php7.0-gd_${PHPBUILD}_amd64.deb && \
    dpkg -i php7.0-curl_${PHPBUILD}_amd64.deb && \
    dpkg -i php7.0-mysql_${PHPBUILD}_amd64.deb && \
    dpkg -i php7.0-ldap_${PHPBUILD}_amd64.deb && \
    dpkg -i php7.0-opcache_${PHPBUILD}_amd64.deb && \
    dpkg -i php7.0-sqlite3_${PHPBUILD}_amd64.deb && \
    dpkg -i php7.0-readline_${PHPBUILD}_amd64.deb && \
    dpkg -i php7.0-cli_${PHPBUILD}_amd64.deb && \
    dpkg -i libapache2-mod-php7.0_${PHPBUILD}_amd64.deb && \
    dpkg -i php7.0-dev_${PHPBUILD}_amd64.deb && \
    dpkg -i php7.0-xml_${PHPBUILD}_amd64.deb && \
    dpkg -i php7.0_${PHPBUILD}_all.deb && \
    apt-get -y  install php7.0-dev=${PHPBUILD} php7.0-mysql=${PHPBUILD} php7.0-opcache=${PHPBUILD} php7.0-curl=${PHPBUILD} php7.0-gd=${PHPBUILD} php7.0-common=${PHPBUILD} php7.0-ldap=${PHPBUILD} php7.0-sqlite3=${PHPBUILD} php7.0-json=${PHPBUILD} php7.0=${PHPBUILD} libapache2-mod-php7.0=${PHPBUILD} php7.0-cli=${PHPBUILD} php7.0-xml=${PHPBUILD} php-xml && \
    rm *.deb && \
    chmod -R 777 /var/lib/php/sessions/ && \
    apt-get -y  purge && apt-get -y  clean && apt-get -y  autoclean && apt-get -y  autoremove && \
    rm -rf /var/lib/apt/lists/* /tmp/*

# Install MongoDB Driver
RUN cd /tmp && wget http://pear.php.net/go-pear.phar && \
    echo '#!/usr/bin/expect' > /tmp/install-pear.sh && \
    echo 'spawn php /tmp/go-pear.phar' >> /tmp/install-pear.sh && \
    echo 'send "\r"' >> /tmp/install-pear.sh && \
    echo 'send "\r"' >> /tmp/install-pear.sh && \
    echo 'send "\r"' >> /tmp/install-pear.sh && \
    echo 'expect eof' >> /tmp/install-pear.sh && \
    chmod +x /tmp/install-pear.sh && \
    /tmp/install-pear.sh && \
    rm /tmp/install-pear.sh && \
    rm /tmp/go-pear.phar && \
    php /usr/share/pear/pearcmd.php channel-update pecl.php.net && \
    php /usr/share/pear/peclcmd.php install mongodb && \
    echo "extension=mongodb.so" > /etc/php/7.0/apache2/conf.d/20-mongo.ini

RUN echo 'opcache.revalidate_freq=100' >> /etc/php/7.0/mods-available/opcache.ini && \
    echo 'opcache.memory_consumption=32' >> /etc/php/7.0/mods-available/opcache.ini && \
    echo 'opcache.max_accelerated_files=130987' >> /etc/php/7.0/mods-available/opcache.ini && \
    echo 'interned_strings_buffer=4' >> /etc/php/7.0/mods-available/opcache.ini && \
    echo 'opcache.enable=1' >> /etc/php/7.0/mods-available/opcache.ini

# PHP Config
RUN sed -i "s/session\.cache_expire.*/session.cache_expire = 18000000/g" /etc/php/7.0/apache2/php.ini && \
    sed -i "s/.*date\.timezone.*=.*/date.timezone = Europe\/Amsterdam/g" /etc/php/7.0/apache2/php.ini && \
    sed -i "s/^expose_php.\+/expose_php = Off/g" /etc/php/7.0/apache2/php.ini && \
    sed -i "s/^max_execution_time.\+/max_execution_time = 600/g" /etc/php/7.0/apache2/php.ini && \
    sed -i "s/.*upload_max_filesize.\+/upload_max_filesize = 0/g" /etc/php/7.0/apache2/php.ini && \
    sed -i "s/.*max_file_uploads.\+/max_file_uploads = 1000/g" /etc/php/7.0/apache2/php.ini && \
    sed -i "s/.*post_max_size.\+/post_max_size = 40M/g" /etc/php/7.0/apache2/php.ini && \
    sed -i "s/^memory_limit.\+/memory_limit = 0/g" /etc/php/7.0/apache2/php.ini && \
    sed -i "s/^short_open_tag.\+/short_open_tag = On/g" /etc/php/7.0/apache2/php.ini && \
    sed -i "s/^display_errors.\+/display_errors = Off/g" /etc/php/7.0/apache2/php.ini && \
    sed -i "s/^;opcache.enable=.\+/opcache.enable=1/g" /etc/php/7.0/apache2/php.ini

ADD src /var/www/nodum_projects/default

RUN chmod 777 /var/www/nodum_projects/default/server/php/files && \
    chown www-data:www-data /var/www/nodum_projects/default/server/php/files

RUN apt-get -y  update && apt-get -y  install php7.1

WORKDIR /var/www/nodum_projects/default

EXPOSE 80

CMD ["/usr/bin/supervisord"]
