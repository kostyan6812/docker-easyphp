FROM php:apache

RUN a2enmod rewrite expires headers substitute remoteip

# install the PHP extensions we need
RUN apt-get update \
	&& apt-get upgrade -y \
	&& apt-get install -y libpng12-dev libjpeg-dev zlib1g-dev libcurl4-gnutls-dev libldb-dev libldap-2.4-2 libldap2-dev libmcrypt-dev libfreetype6-dev less sudo\
	&& rm -rf /var/lib/apt/lists/* \
	&& ln -s /usr/lib/x86_64-linux-gnu/libldap.so /usr/lib/libldap.so \
	&& ln -s /usr/lib/x86_64-linux-gnu/liblber.so /usr/lib/liblber.so \
	&& docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr --with-freetype-dir=/usr \
	&& docker-php-ext-install gd mysqli opcache zip bcmath pdo pdo_mysql curl mbstring ldap mcrypt
# set recommended PHP.ini settings
# see https://secure.php.net/manual/en/opcache.installation.php
RUN { \
		echo 'opcache.memory_consumption=128'; \
		echo 'opcache.interned_strings_buffer=8'; \
		echo 'opcache.max_accelerated_files=4000'; \
		echo 'opcache.revalidate_freq=2'; \
		echo 'opcache.fast_shutdown=1'; \
		echo 'opcache.enable_cli=1'; \
	} > /usr/local/etc/php/conf.d/opcache-recommended.ini
	
RUN { \
		echo 'file_uploads=On'; \
		echo 'upload_max_filesize=256M'; \
		echo 'post_max_size=256M'; \
		echo 'max_execution_time=1200'; \
	} > /usr/local/etc/php/conf.d/php-recommended.ini

VOLUME /var/www/html

COPY docker-entrypoint.sh /usr/local/bin/
RUN ln -s /usr/local/bin/docker-entrypoint.sh /entrypoint.sh \
	&& chmod +x /usr/local/bin/docker-entrypoint.sh

# ENTRYPOINT resets CMD
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["apache2-foreground"]
