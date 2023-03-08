# Drupal Composer
This container starts with a Ubuntu Server image and layers on apache2, php7.2 and composer.  It then creates Drupal 10 website using Composer.

## Tags
`22.04` This is the only maintaned version. It stayes with the current LTS version of Ubuntu

## How to use this container

docker run -d -p 80:80 --name [AppName] kiendeleo/drupalcomposer:[Tag]

## Persistance Volumes
- Apache directives: apache:/etc/apache2/sites-enabled/
- PHP.ini: php:/etc/php/
- Site Files: drupal:/var/www/site/
- Run command for Persistance: docker run -d -v drupal:/var/www/site -v php:/etc/php/ -v apache:/etc/apache2/sites-enabled/ kiendeleo/drupalcomposer:latest

## Things still left to do:
- SSH (Self signed cert)

## Credits
Based on what i've learned from this:
- [SpiralOutDotEu/docker-apache-php-composer](https://github.com/SpiralOutDotEu/docker-apache-php-composer)
- [nimmis/apache-php5](https://hub.docker.com/r/nimmis/apache-php5/~/dockerfile/)
- [webdevops/php-boilerplate](https://hub.docker.com/r/webdevops/php-boilerplate/~/dockerfile/)
- [Dan Pupius@Medium:Apache and PHP on Docker](https://medium.com/dev-tricks/apache-and-php-on-docker-44faef716150#.5bz3h5mgy)
- [Yunes Rafie@sitepoint:Docker and Dockerfiles Made Easy!](http://www.sitepoint.com/docker-and-dockerfiles-made-easy/)
