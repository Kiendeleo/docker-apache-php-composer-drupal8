FROM ubuntu:22.04

MAINTAINER Kiendeleo <kiendeleo.com>

# disable interactive functions. 
ENV DEBIAN_FRONTEND noninteractive

# Install apache, php and supplimentary programs. also remove the list from the apt-get update at the end ;-)
RUN apt-get update && \
	apt-get install -y apache2 \
	libapache2-mod-php8.1 \
	php8.1-mysql \
	php8.1-gd \
	php8.1-bcmath \
	php8.1-soap \
	php-pear \
	php-apcu \
	php8.1-fpm \
	php8.1-curl \
	curl lynx-common lynx \
	php8.1-mbstring \
	php8.1-zip \
	php8.1-uploadprogress \
	unzip \
	git \
	nano \
	wget \
	&& rm -rf /var/lib/apt/lists/* \
	&& apt-get clean -y 
# Install composer for PHP dependencies
RUN cd /tmp && curl -sS https://getcomposer.org/installer | php && mv composer.phar /usr/local/bin/composer

# Add the temp folder for composers's cache
RUN mkdir /var/www/.composer/

# Enable apache mods.
RUN a2enmod php8.1
RUN a2enmod rewrite

# Update the PHP.ini file, enable <? ?> tags and quieten logging.
RUN sed -i "s/short_open_tag = Off/short_open_tag = On/" /etc/php/8.1/apache2/php.ini
RUN sed -i "s/error_reporting = .*$/error_reporting = E_ERROR | E_WARNING | E_PARSE/" /etc/php/8.1/apache2/php.ini

# Manually set up the apache environment variables
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_LOCK_DIR /var/lock/apache2
ENV APACHE_PID_FILE /var/run/apache2.pid

# Make working directories.
RUN mkdir /var/www/site
RUN mkdir /var/www/site/public

# Create Drupal 8 site using Composer
RUN composer create-project drupal/recommended-project /var/www/site/public
RUN cd /var/www/site/public && composer require drush/drush
RUN cd /var/www/site/public && composer install --prefer-dist

# Adjust File Permissions 
RUN chown -R www-data:www-data /var/www/site/public/
RUN chown -R www-data:www-data /var/www/.composer/
RUN cd /var/www/site/public && find . -type d -exec chmod u=rwx,g=rx,o= '{}' \;
RUN cd /var/www/site/public && find . -type f -exec chmod u=rw,g=r,o= '{}' \;
RUN chmod +x /var/www/site/public/vendor/drush/drush/drush
RUN chmod +x /var/www/site/public/vendor/bin/drush

# Update the default apache site with the config we created.
ADD apache-config.conf /etc/apache2/sites-enabled/000-default.conf

# By default, simply start apache.
CMD /usr/sbin/apache2ctl -D FOREGROUND

#Add Open SSL
RUN apt-get -y install openssl

#Change permisions of Composer Cache
RUN mkdir /var/www/.cache/
RUN chown -R www-data:www-data /var/www/.cache/

# expose container at port 80
EXPOSE 80
