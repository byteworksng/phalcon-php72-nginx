#
# The Application Core Container
#

# Pull base image
FROM webdevops/php-nginx-dev:ubuntu-16.04

# Pull php 7.2
#FROM webdevops/php-nginx-dev:7.2

MAINTAINER Chibuzor Ogbu <chibuzorogbu@byteworksng.com>

COPY artifacts .

ENV PATH=/root/composer/vendor/bin:$PATH \
    COMPOSER_HOME=/root/composer \
    COMPOSER_ALLOW_SUPERUSER=1 \
    COMPOSER_HOME=/root/composer \
    APPLICATION_PATH="/project" \
    DEBIAN_FRONTEND=noninteractive

RUN ls -al artifacts

RUN mkdir -p $APPLICATION_PATH/public \
    && chown -R $APPLICATION_USER:$APPLICATION_GROUP $APPLICATION_PATH \
    && curl -s https://packagecloud.io/install/repositories/phalcon/stable/script.deb.sh | bash \
    && apt-get install -y software-properties-common snmp snmp-mibs-downloader \
    && LANG=C.UTF-8 apt-add-repository -y ppa:ondrej/php \
    && echo "#!/bin/sh\nexit 0" > /usr/sbin/policy-rc.d \
    && apt-get update -y

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

RUN cp -R /artifacts/etc/php/7.2/mods-available /etc/php/7.2/mods-available \
    && cp -R /artifacts/usr/lib/php/`php-config --phpapi` /usr/lib/php/`php-config --phpapi` \
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
    && echo "apc.enable_cli = 1" >> /etc/php/7.2/mods-available/apcu.ini

RUN apt-get autoremove -y \
    && apt-get autoclean -y \
    && apt-get clean -y \
    && rm -rf \
        /var/lib/apt/lists/* \
        /tmp/* \
        /var/tmp/* \
        /artifacts \
        /opt/docker/etc/php/fpm/pool.d/www.conf


EXPOSE 80 443 9000