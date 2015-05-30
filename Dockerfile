FROM drupal-php53:latest
MAINTAINER Andrew Holgate <andrewholgate@yahoo.com>

RUN apt-get update
RUN apt-get -y upgrade

# Install tools for documenting.
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install python-sphinx python-pip doxygen
RUN DEBIAN_FRONTEND=noninteractive pip install sphinx_rtd_theme breathe

# Install XHProf
RUN DEBIAN_FRONTEND=noninteractive pecl install -f xhprof
COPY xhprof.ini /etc/php5/apache2/conf.d/xhprof.ini
COPY xhprof.conf /etc/apache2/conf.d/xhprof.conf
RUN mkdir /tmp/xhprof
RUN chown www-data:www-data /tmp/xhprof

# Install XDebug 2.2.7, the latest version compatible with PHP 5.3.x
RUN wget http://xdebug.org/files/xdebug-2.2.7.tgz
RUN tar zxvf xdebug-2.2.7.tgz
RUN cd xdebug-2.2.7 && \
  phpize && \
  ./configure --enable-xdebug && \
  make && \
  make install
RUN rm -Rf xdebug-2.2.7.tgz xdebug-2.2.7
COPY xdebug.ini /etc/php5/apache2/conf.d/xdebug.ini
RUN mkdir /tmp/xdebug && chown www-data:www-data /tmp/xdebug
RUN mkdir /var/log/xdebug && chown www-data:www-data /var/log/xdebug

# Turn on PHP error reporting
RUN sed -ri 's/^display_errors\s*=\s*Off/display_errors = On/g' /etc/php5/apache2/php.ini
RUN sed -ri 's/^display_errors\s*=\s*Off/display_errors = On/g' /etc/php5/cli/php.ini
RUN sed -ri 's/^error_reporting\s*=.*$/error_reporting = E_ALL \& ~E_DEPRECATED \& ~E_NOTICE/g' /etc/php5/apache2/php.ini
RUN sed -ri 's/^error_reporting\s*=.*$/error_reporting = E_ALL \& ~E_DEPRECATED \& ~E_NOTICE/g' /etc/php5/cli/php.ini

# Symlink log files.
RUN ln -s /var/log/xdebug/xdebug.log /var/www/log/

# Grant ubuntu user access to sudo with no password.
RUN apt-get -y install sudo
RUN echo "ubuntu ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
RUN usermod -a -G sudo ubuntu

# Clean-up installation.
RUN DEBIAN_FRONTEND=noninteractive apt-get autoclean && apt-get autoremove

RUN /etc/init.d/apache2 restart

CMD ["/usr/local/bin/run"]
