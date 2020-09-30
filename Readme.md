# Drupal Composer
This container starts with a Ubuntu Server image and layers on apache2, php7.2 and composer.  It then creates Drupal 8 website using Composer.

## Tags
`18.04` This version runs on Ubuntu 18.04 and installs Drupal 8

`20.04` This version runs on Ubuntu 20.04 and installs Drupal 9

`latest` This is the latest version, shoul should not use the latest tag as it may break your server when a new LTS release of Ubuntu comes out

## How to use this container

docker run -d -p 80:80 --name [AppName] kiendeleo/drupalcomposer:[Tag]

## Persistance Volumes
- Apache directives: apache:/etc/apache2/sites-enabled/
- PHP.ini: php:/etc/php/7.2/apache2/
- Site Files: d8:/var/www/site/
- Run command for Persistance: docker run -d -v d8:/var/www/site -v php:/etc/php/7.2/apache2/ -v apache:/etc/apache2/sites-enabled/ kiendeleo/drupalcomposer:latest

## Things still left to do:
- SSH (Self signed cert)
- check for created site before running composer command

## Credits
Based on what i've learned from this:
- [SpiralOutDotEu/docker-apache-php-composer](https://github.com/SpiralOutDotEu/docker-apache-php-composer)
- [nimmis/apache-php5](https://hub.docker.com/r/nimmis/apache-php5/~/dockerfile/)
- [webdevops/php-boilerplate](https://hub.docker.com/r/webdevops/php-boilerplate/~/dockerfile/)
- [Dan Pupius@Medium:Apache and PHP on Docker](https://medium.com/dev-tricks/apache-and-php-on-docker-44faef716150#.5bz3h5mgy)
- [Yunes Rafie@sitepoint:Docker and Dockerfiles Made Easy!](http://www.sitepoint.com/docker-and-dockerfiles-made-easy/)
