#
# The Application Core Container
#

# Pull base image
#FROM webdevops/php-nginx-dev:ubuntu-16.04
FROM webdevops/base:ubuntu-16.04

MAINTAINER Chibuzor Ogbu <chibuzorogbu@byteworksng.com>

COPY artifacts .
COPY conf/ /opt/docker


ENV PATH=/root/composer/vendor/bin:$PATH \
    COMPOSER_HOME=/root/composer \
    COMPOSER_ALLOW_SUPERUSER=1 \
    APPLICATION_PATH="/project" \
    APPLICATION_USER="www-data" \
    APPLICATION_GROUP="www-data" \
    DEBIAN_FRONTEND=noninteractive \
    XDEBUG_IDEKEY="PHPSTORM" \
    XDEBUG_SHOW_LOCAL_VARS=1 \
    XDEBUG_SCREAM=0 \
    XDEBUG_SHOW_ERROR_TRACE=1 \
    XDEBUG_REMOTE_PORT=9000 \
    XDEBUG_REMOTE_CONNECT_BACK=0 \
    XDEBUG_REMOTE_AUTOSTART=1 \
    XDEBUG_REMOTE_ENABLE=1 \
    XDEBUG_REMOTE_HOST=0.0.0.0

RUN echo 'nameserver 8.8.8.8' >> /etc/resolv.conf

RUN ls -al artifacts

RUN mkdir -p $APPLICATION_PATH/public \
    && chown -R $APPLICATION_USER:$APPLICATION_GROUP $APPLICATION_PATH \
    && curl -s https://packagecloud.io/install/repositories/phalcon/stable/script.deb.sh | bash \
    && apt-get install -y software-properties-common snmp snmp-mibs-downloader \
    && LANG=C.UTF-8 apt-add-repository -y ppa:ondrej/php \
    && echo "#!/bin/sh\nexit 0" > /usr/sbin/policy-rc.d \
    && apt-get update -y
RUN echo "deb http://nginx.org/packages/mainline/ubuntu/ xenial nginx" | tee -a /etc/apt/sources.list \
    && echo "deb-src http://nginx.org/packages/mainline/ubuntu/ xenial nginx" | tee -a /etc/apt/sources.list \
    && wget -qO - https://nginx.org/keys/nginx_signing.key | apt-key add - \
    && apt-get update -y \
    && apt-get install -y nginx

RUN apt-get update -y  \
	&& apt install -y -f nodejs npm \
	&& apt install -y git

RUN apt-get -o Dpkg::Options::="--force-confnew" install -y -f --no-install-recommends \
        php7.2 \
        php7.2-cli \
        php7.2-bcmath \
        php-apcu \
        pwgen \
        php7.2-bz2 \
        php7.2-dev \
        php7.2-dba \
        php7.2-gmp \
        php7.2-gd \
        php7.2-imap \
        php7.2-mysql \
        php7.2-json \
        php7.2-intl \
        php7.2-curl \
        php7.2-common \
        php7.2-ldap \
        php7.2-opcache \
        php7.2-mbstring \
        php7.2-mongodb \
        php7.2-msgpack \
        php-pear \
        php7.2-odbc \
        php7.2-pgsql \
        php7.2-pspell \
        php7.2-readline \
        php7.2-snmp \
        php7.2-soap \
        php7.2-xml \
        php7.2-xmlrpc \
        php7.2-xsl \
        php7.2-zip \
        php7.2-recode \
        php-ssh2 \
        php7.2-tidy \
        php7.2-fpm \
        php-yaml \
        lsb-release \
        libssh2-1-dev \
        libyaml-dev \
        libssl-dev


RUN wget https://phar.io/releases/phive.phar \
    && wget https://phar.io/releases/phive.phar.asc \
    && gpg --keyserver hkps.pool.sks-keyservers.net --recv-keys 0x9B2D5D79 \
    && gpg --verify phive.phar.asc phive.phar \
    && chmod +x phive.phar \
    && mv phive.phar /usr/bin/phive \
    && pecl channel-update pecl.php.net \
    && curl -sOL https://squizlabs.github.io/PHP_CodeSniffer/phpcs.phar \
    && chmod +x phpcs.phar \
    && mv phpcs.phar /usr/local/bin/phpcs \
    && curl -sOL https://squizlabs.github.io/PHP_CodeSniffer/phpcbf.phar \
    && chmod +x phpcbf.phar \
    && mv phpcbf.phar /usr/local/bin/phpcbf \
    && curl -sOL http://static.phpmd.org/php/latest/phpmd.phar \
    && chmod +x phpmd.phar \
    && mv phpmd.phar /usr/local/bin/phpmd \
    && curl -sOL http://www.phing.info/get/phing-latest.phar \
    && chmod +x phing-latest.phar \
    && mv phing-latest.phar /usr/local/bin/phing \
    && mkdir $COMPOSER_HOME \
    && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
    && chmod +x /usr/local/bin/composer
RUN pear config-set preferred_state beta \
	&& pecl install xdebug
RUN cp -R /artifacts/etc/php/7.2/mods-available /etc/php/7.2/mods-available \
    && cp -R /artifacts/usr/lib/php/`php-config --phpapi` /usr/lib/php/`php-config --phpapi` \
    && touch /var/run/php/php7.2-fpm.sock \
    && chown -R $APPLICATION_USER:$APPLICATION_GROUP /var/run/php \
    && FILES=/artifacts/etc/php/7.2/mods-available/* && for f in $FILES; \
            do \
                phpenmod -v 7.2 -s ALL `basename $f | cut -d '.' -f 1`; \
            done \
    && php -m

RUN TIMEZONE=`cat /etc/timezone`; sed -i "s|;date.timezone =.*|date.timezone = ${TIMEZONE}|" /etc/php/7.2/cli/php.ini \
    && TIMEZONE=`cat /etc/timezone`; sed -i "s|;date.timezone =.*|date.timezone = ${TIMEZONE}|" /etc/php/7.2/fpm/php.ini \
    && sed -i "s|memory_limit =.*|memory_limit = -1|" /etc/php/7.2/cli/php.ini \
    && sed -i 's|short_open_tag =.*|short_open_tag = On|' /etc/php/7.2/cli/php.ini \
    && sed -i 's|error_reporting =.*|error_reporting = -1|' /etc/php/7.2/cli/php.ini \
    && sed -i 's|display_errors =.*|display_errors = On|' /etc/php/7.2/cli/php.ini \
    && sed -i 's|display_startup_errors =.*|display_startup_errors = On|' /etc/php/7.2/cli/php.ini \
    && sed -i -re 's|^(;?)(session.save_path) =.*|\2 = "/tmp"|g' /etc/php/7.2/cli/php.ini \
    && sed -i -re 's|^(;?)(phar.readonly) =.*|\2 = off|g' /etc/php/7.2/cli/php.ini \
    && echo "apc.enable_cli = 1" >> /etc/php/7.2/mods-available/apcu.ini \
    && echo "zend_extension=xdebug.so" >> /etc/php/7.2/cli/php.ini

# add build script (also set timezone to AFRICA/LAGOS)

COPY conf/provision/bootstrap.d/*.sh /opt/docker/provision/bootstrap.d/
COPY conf/provision/entrypoint.d/*.sh /opt/docker/provision/entrypoint.d/
ADD conf/provision/bootstrap.d/.bashrc /opt/docker/provision/entrypoint.d/.bashrc
RUN chmod +x /opt/docker/provision/bootstrap.d/*.sh \
    && chmod +x /opt/docker/provision/entrypoint.d/*.sh

# copy files from repo
COPY conf/nginx/main/http.conf /etc/nginx/nginx.conf
RUN echo "daemon off;" >> /etc/nginx/nginx.conf \
	&& echo "user ${APPLICATION_USER} ${APPLICATION_GROUP};" >> /etc/nginx/nginx.conf \
	&& rm -f    /etc/nginx/conf.d/default.conf \
ADD app/index.php $APPLICATION_PATH/public/index.php

RUN apt-get autoremove -y \
    && apt-get autoclean -y \
    && apt-get clean -y \
    && rm -rf \
        /var/lib/apt/lists/* \
        /tmp/* \
        /var/tmp/* \
        /artifacts \
        /opt/docker/etc/php/fpm/pool.d/www.conf

# Define mountable directories.
VOLUME ["/etc/nginx/sites-enabled", "/etc/nginx/certs", "/etc/nginx/conf.d", "/var/log/nginx"]

COPY conf/nginx/conf.d/*.conf /etc/nginx/conf.d/
COPY conf/nginx/certs /etc/nginx/certs
COPY conf/nginx/sites-enabled/*.conf /etc/nginx/sites-enabled/

RUN /opt/docker/bin/bootstrap.sh
EXPOSE 80 443 9000

# Define default command
CMD /etc/init.d/php7.2-fpm restart && nginx
