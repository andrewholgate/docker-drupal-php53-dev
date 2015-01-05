FROM drupal-ubuntu:latest
MAINTAINER Andrew Holgate <andrewholgate@yahoo.com>

RUN apt-get update
RUN apt-get -y upgrade

# Install useful OS tools
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install nano htop

# Turn on error reporting configurations.
RUN sed -ri 's/^display_errors\s*=\s*Off/display_errors = On/g' /etc/php5/apache2/php.ini
RUN sed -ri 's/^display_errors\s*=\s*Off/display_errors = On/g' /etc/php5/cli/php.ini
RUN sed -ri 's/^error_reporting\s*=.*$/error_reporting = E_ALL \& ~E_DEPRECATED \& ~E_NOTICE/g' /etc/php5/apache2/php.ini
RUN sed -ri 's/^error_reporting\s*=.*$/error_reporting = E_ALL \& ~E_DEPRECATED \& ~E_NOTICE/g' /etc/php5/cli/php.ini

# Install tools for documenting.
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install python-sphinx python-pip doxygen
RUN DEBIAN_FRONTEND=noninteractive pip install sphinx_rtd_theme breathe

# Install XDebug
RUN DEBIAN_FRONTEND=noninteractive pecl install xdebug xhprof
RUN echo 'zend_extension="/usr/lib/php5/20090626/xdebug.so"' >> /etc/php5/apache2/php.ini

# Install XHProf
RUN DEBIAN_FRONTEND=noninteractive pecl install -f xhprof
RUN echo 'extension=xhprof.so' >> /etc/php5/apache2/php.ini
RUN echo 'xhprof.output_dir="/tmp/xhprof"' >> /etc/php5/apache2/php.ini

# Install KCacheGrind
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install kcachegrind

# Clean-up installation.
RUN DEBIAN_FRONTEND=noninteractive apt-get autoclean

RUN /etc/init.d/apache2 restart

CMD ["/usr/local/bin/run"]
