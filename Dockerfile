ARG UBUNTU_VERSION=24.04
FROM ubuntu:${UBUNTU_VERSION}

LABEL org.opencontainers.image.title="Drupal Composer Apache" \
      org.opencontainers.image.description="Ubuntu 24.04, PHP 8.3, Drupal 10 recommended-project" \
      org.opencontainers.image.source="https://github.com/Kiendeleo/docker-apache-php-composer-drupal8" \
      org.opencontainers.image.authors="Kiendeleo <kiendeleo.com>"

ARG PHP_VERSION=8.3
# php2shell (CVE-2026-109618, CVE-2026-109619) is fixed in USN-8948-1.
# Ubuntu keeps the upstream number at 8.3.6 and puts the fix in the package revision.
ARG PHP_MIN_PACKAGE=8.3.6-0ubuntu0.24.04.13
ARG DRUPAL_VERSION=10.6.20

ENV DEBIAN_FRONTEND=noninteractive \
    PHP_VERSION=${PHP_VERSION} \
    DRUPAL_VERSION=${DRUPAL_VERSION} \
    APACHE_RUN_USER=www-data \
    APACHE_RUN_GROUP=www-data \
    APACHE_LOG_DIR=/var/log/apache2 \
    APACHE_LOCK_DIR=/var/lock/apache2 \
    APACHE_PID_FILE=/var/run/apache2.pid \
    COMPOSER_ALLOW_SUPERUSER=0 \
    COMPOSER_HOME=/var/www/.composer

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer
COPY check-php2shell.sh /usr/local/bin/check-php2shell.sh

RUN apt-get update \
 && apt-get upgrade -y --no-install-recommends \
 && apt-get install -y --no-install-recommends \
      apache2 \
      ca-certificates \
      curl \
      libapache2-mod-php${PHP_VERSION} \
      php${PHP_VERSION} \
      php${PHP_VERSION}-cli \
      php${PHP_VERSION}-common \
      php${PHP_VERSION}-mysql \
      php${PHP_VERSION}-curl \
      php${PHP_VERSION}-gd \
      php${PHP_VERSION}-bcmath \
      php${PHP_VERSION}-opcache \
      php${PHP_VERSION}-xml \
      php${PHP_VERSION}-mbstring \
      php${PHP_VERSION}-zip \
      php${PHP_VERSION}-intl \
      php${PHP_VERSION}-apcu \
      php${PHP_VERSION}-soap \
      unzip \
 && a2enmod php${PHP_VERSION} rewrite headers \
 && PHP_VERSION="${PHP_VERSION}" PHP_MIN_PACKAGE="${PHP_MIN_PACKAGE}" sh /usr/local/bin/check-php2shell.sh \
 && rm -rf /var/lib/apt/lists/*

RUN printf '%s\n' \
      'short_open_tag = Off' \
      'display_errors = Off' \
      'display_startup_errors = Off' \
      'log_errors = On' \
      'error_reporting = E_ALL' \
      'expose_php = Off' \
      'allow_url_fopen = On' \
      'memory_limit = 256M' \
      'max_execution_time = 120' \
      'upload_max_filesize = 32M' \
      'post_max_size = 32M' \
      'zend.assertions = -1' \
    > /etc/php/${PHP_VERSION}/apache2/conf.d/99-drupal.ini \
 && cp /etc/php/${PHP_VERSION}/apache2/conf.d/99-drupal.ini /etc/php/${PHP_VERSION}/cli/conf.d/99-drupal.ini

COPY apache-config.conf /etc/apache2/sites-enabled/000-default.conf

RUN mkdir -p /var/www/site/public /var/www/.composer /var/www/.cache \
 && chown -R www-data:www-data /var/www/site /var/www/.composer /var/www/.cache \
 && su -s /bin/bash www-data -c "composer create-project drupal/recommended-project:${DRUPAL_VERSION} /var/www/site/public --no-interaction --no-progress" \
 && su -s /bin/bash www-data -c "composer require drush/drush --working-dir=/var/www/site/public --no-interaction --no-progress" \
 && mkdir -p /var/www/site/public/web/sites/default/files \
 && chown -R root:www-data /var/www/site/public \
 && find /var/www/site/public -type d -exec chmod 0750 {} \; \
 && find /var/www/site/public -type f -exec chmod 0640 {} \; \
 && chown -R www-data:www-data /var/www/site/public/web/sites/default \
 && chmod 0770 /var/www/site/public/web/sites/default /var/www/site/public/web/sites/default/files \
 && if [ -d /var/www/site/public/vendor/bin ]; then chmod 0750 /var/www/site/public/vendor/bin/*; fi

# mod_php writes PHP errors to Apache's main ErrorLog, not the vhost one.
# The vhost ErrorLog can be stderr and these messages still land in
# /var/log/apache2/error.log until the main log is stderr too.
# Drupal's .htaccess sets zend.assertions per request. PHP rejects that
# when the ini value is -1 and would log a warning on every hit.
RUN sed -i 's#^ErrorLog .*#ErrorLog /proc/self/fd/2#' /etc/apache2/apache2.conf \
 && printf '%s\n' 'ServerName localhost' > /etc/apache2/conf-available/fqdn.conf \
 && a2enconf fqdn \
 && if grep -q 'php_value zend.assertions' /var/www/site/public/web/.htaccess; then \
      sed -i '/php_value zend.assertions/d' /var/www/site/public/web/.htaccess; \
    fi \
 && printf 'ok\n' > /var/www/site/public/web/healthz.txt \
 && chmod 0644 /var/www/site/public/web/healthz.txt

WORKDIR /var/www/site/public

EXPOSE 80

COPY docker-healthcheck.sh /usr/local/bin/docker-healthcheck.sh
RUN chmod 755 /usr/local/bin/docker-healthcheck.sh

HEALTHCHECK --interval=30s --timeout=5s --start-period=30s --retries=3 \
  CMD ["/usr/local/bin/docker-healthcheck.sh"]

CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]
