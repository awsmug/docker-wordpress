#!/bin/sh

if [ -z "$WP_VERSION" ]; then
    WP_VERSION=latest
fi

if [ -z "$WP_LOCALE" ]; then
    WP_LOCALE=en_US
fi

if [ -z "$WP_URL" ]; then
    WP_URL=localhost
fi

if [ -z "$WP_PATH" ]; then
    WP_PATH=/var/www/html
fi

if [ -z "$WP_TITLE" ]; then
    WP_TITLE=WordPress
fi

if [ -z "$WP_USER" ]; then
    WP_USER=admin
fi

if [ -z "$WP_PASS" ]; then
    WP_PASS=password
fi

if [ -z "$WP_EMAIL" ]; then
    WP_EMAIL=admin@localhost.dev
fi

if [ -z "$MYSQL_HOST" ]; then
    MYSQL_HOST=localhost
fi

if [ -z "$MYSQL_USER" ]; then
    MYSQL_USER=root
fi

if [ -z "$MYSQL_PASS" ]; then
    MYSQL_PASS=root
fi

if [ ! -f "${WP_PATH}/wp-config.php" ] || [ ${WP_INSTALL} == "new" ]; then
    mkdir -p ${WP_PATH}

    if [ -f "${WP_PATH}/wp-config.php" ]; then
        rm -rf ${WP_PATH}/*
        wp core download --path=${WP_PATH}  --version=${WP_VERSION} --locale=${WP_LOCALE}
        wp config create --path=${WP_PATH} --dbname=${MYSQL_DB} --dbuser=${MYSQL_USER} --dbpass=${MYSQL_PASS} --dbhost=${MYSQL_HOST}
        wp db drop --yes --path=${WP_PATH}
    else
        wp core download --path=${WP_PATH} --version=${WP_VERSION} --locale=${WP_LOCALE}
        wp config create --path=${WP_PATH} --dbname=${MYSQL_DB} --dbuser=${MYSQL_USER} --dbpass=${MYSQL_PASS} --dbhost=${MYSQL_HOST}
    fi

    sed -i -e "s~\$table_prefix = 'wp_';~\$table_prefix = 'wp_';\ndefine( 'WP_DEBUG', true );\ndefine( 'WP_DEBUG_LOG', true );~g" ${WP_PATH}/wp-config.php
    sleep 10

    wp db create --path=${WP_PATH}
    wp core install --path=${WP_PATH} --url=${WP_URL} --title="${WP_TITLE}" --admin_user=${WP_USER} --admin_password=${WP_PASS} --admin_email=${WP_EMAIL}

    if [ ! -z "$WP_PLUGINS" ]; then
        IFS=' ' read -ra plugins <<< "${WP_PLUGINS}"
        for plugin in "${plugins[@]}"; do
            echo "Installung Plugin ${plugin}...";
            wp plugin install ${plugin} --path=${WP_PATH} --activate
        done
    fi

    if [ ! -z "$WP_THEMES" ]; then
        IFS=' ' read -ra themes <<< "${WP_THEMES}"
        for themes in "${theme[@]}"; do
            echo "Installing Plugin ${theme}...";
            wp theme install ${theme} --path=${WP_PATH}
        done
    fi

    if [ ! -z "$WP_ACTIVE_THEME" ]; then
        wp theme activate ${WP_ACTIVE_THEME} --path=${WP_PATH}
    fi

    echo "<?php phpinfo();" >> ${WP_PATH}/phpinfo.php
fi

tail -f /dev/null