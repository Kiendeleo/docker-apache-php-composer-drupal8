# docker-apache-php-composer-drupal8
How to use this container

docker run -d -p 80:80 -n AppName kiendeleo / drupalcomposer:latest

# Persistance Volumes
Apache directives apache:/etc/apache2/sites-enabled/
PHP.ini: php:/etc/php/7.2/apache2/
Site Files: d8:/var/www/site

# Things still left to do:
- SSH (Self signed cert)
- check for created site before running composer command

# Credits
Based on what i've learned from this:
- [SpiralOutDotEu/docker-apache-php-composer](https://github.com/SpiralOutDotEu/docker-apache-php-composer)
- [nimmis/apache-php5](https://hub.docker.com/r/nimmis/apache-php5/~/dockerfile/)
- [webdevops/php-boilerplate](https://hub.docker.com/r/webdevops/php-boilerplate/~/dockerfile/)
- [Dan Pupius@Medium:Apache and PHP on Docker](https://medium.com/dev-tricks/apache-and-php-on-docker-44faef716150#.5bz3h5mgy)
- [Yunes Rafie@sitepoint:Docker and Dockerfiles Made Easy!](http://www.sitepoint.com/docker-and-dockerfiles-made-easy/)
