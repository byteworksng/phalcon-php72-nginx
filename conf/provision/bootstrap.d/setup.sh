#!/usr/bin/env bash
APPLICATION_USER=${APPLICATION_USER:-}
APPLICATION_GROUP=${APPLICATION_GROUP:-}
PROVISION_CONTEXT=${PROVISION_CONTEXT:-}
XDEBUG_IDEKEY=${XDEBUG_IDEKEY:-}
XDEBUG_SHOW_LOCAL_VARS=${XDEBUG_SHOW_LOCAL_VARS:-}
XDEBUG_SCREAM=${XDEBUG_SCREAM:-}
XDEBUG_SHOW_ERROR_TRACE=${XDEBUG_SHOW_ERROR_TRACE:-}
XDEBUG_REMOTE_PORT=${XDEBUG_REMOTE_PORT:-}
XDEBUG_REMOTE_CONNECT_BACK=${XDEBUG_REMOTE_CONNECT_BACK}
XDEBUG_REMOTE_AUTOSTART=${XDEBUG_REMOTE_AUTOSTART}
XDEBUG_REMOTE_ENABLE=${XDEBUG_REMOTE_ENABLE}
# set timezone machine to Africa/Lagos
# cp /usr/share/zoneinfo/Africa/Lagos /etc/localtime

# set UTF-8 environment
echo 'LC_ALL=en_US.UTF-8' >> /etc/environment
echo 'LANG=en_US.UTF-8' >> /etc/environment
echo 'LC_CTYPE=en_US.UTF-8' >> /etc/environment

# enable xdebug

echo "xdebug.remote_enable=${XDEBUG_REMOTE_ENABLE}" >> /etc/php/7.2/mods-available/xdebug.ini
echo "xdebug.remote_host=${XDEBUG_REMOTE_HOST}" >> /etc/php/7.2/mods-available/xdebug.ini
echo "xdebug.remote_autostart=${XDEBUG_REMOTE_AUTOSTART}" >> /etc/php/7.2/mods-available/xdebug.ini
echo "xdebug.remote_connect_back=${XDEBUG_REMOTE_CONNECT_BACK}" >> /etc/php/7.2/mods-available/xdebug.ini
echo "xdebug.show_error_trace=${XDEBUG_SHOW_ERROR_TRACE}" >> /etc/php/7.2/mods-available/xdebug.ini
echo "xdebug.remote_port=${XDEBUG_REMOTE_PORT}" >> /etc/php/7.2/mods-available/xdebug.ini
echo "xdebug.scream=${XDEBUG_SCREAM}" >> /etc/php/7.2/mods-available/xdebug.ini
echo "xdebug.show_local_vars=${XDEBUG_SHOW_LOCAL_VARS}" >> /etc/php/7.2/mods-available/xdebug.ini
echo "xdebug.idekey=${XDEBUG_IDEKEY}" >> /etc/php/7.2/mods-available/xdebug.ini


# setup php7.2-fpm to not run as daemon (allow my_init to control)
#sed -i "s/;daemonize\s*=\s*yes/daemonize = no/g" /etc/php/7.2/fpm/php-fpm.conf
sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php/7.2/fpm/php.ini

# create run directories
mkdir -p /var/run/php

if [ x"$APPLICATION_USER" != x ]; then
	owner="$APPLICATION_USER"
	if [ x"$APPLICATION_GROUP" != x ]; then
		owner="${owner}:$APPLICATION_GROUP"
	fi

	chown -R ${owner} /var/run/php

fi

