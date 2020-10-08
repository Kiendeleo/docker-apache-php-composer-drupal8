FROM ubuntu:20.04

MAINTAINER Kiendeleo <kiendeleo.com>

# disable interactive functions. 
ENV DEBIAN_FRONTEND noninteractive

# Install apache, php and supplimentary programs. also remove the list from the apt-get update at the end ;-)
RUN apt-get update && \
	apt-get install -y apache2 \
	libapache2-mod-php7.4 \
	php7.4-mysql \
	php7.4-gd \
	php7.4-bcmath \
	php7.4-soap \
	php-pear \
	php-apcu \
	php7.4-json \
	php7.4-curl \
	curl lynx-common lynx \
	php7.4-mbstring \
	php7.4-zip \
	php7.4-uploadprogress \
	unzip \
	&& rm -rf /var/lib/apt/lists/* \
	&& apt-get clean -y 
# Install composer for PHP dependencies
RUN cd /tmp && curl -sS https://getcomposer.org/installer | php && mv composer.phar /usr/local/bin/composer

# Add the temp folder for composers's cache
RUN mkdir /var/www/.composer/

# Enable apache mods.
RUN a2enmod php7.4
RUN a2enmod rewrite

# Update the PHP.ini file, enable <? ?> tags and quieten logging.
RUN sed -i "s/short_open_tag = Off/short_open_tag = On/" /etc/php/7.4/apache2/php.ini
RUN sed -i "s/error_reporting = .*$/error_reporting = E_ERROR | E_WARNING | E_PARSE/" /etc/php/7.4/apache2/php.ini

# Manually set up the apache environment variables
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_LOCK_DIR /var/lock/apache2
ENV APACHE_PID_FILE /var/run/apache2.pid

EXPOSE 80

# Make working directories.
RUN mkdir /var/www/site
RUN mkdir /var/www/site/public

# Create Drupal 8 site using Composer
RUN composer create-project drupal/recommended-project /var/www/site/public
RUN cd /var/www/site/public && composer require drush/drush

# Adjust File Permissions 
RUN chown -R www-data:www-data /var/www/site/public/
RUN chown -R www-data:www-data /var/www/.composer/

# Update the default apache site with the config we created.
ADD apache-config.conf /etc/apache2/sites-enabled/000-default.conf

# By default, simply start apache.
CMD /usr/sbin/apache2ctl -D FOREGROUND

# expose container at port 80
EXPOSE 80
