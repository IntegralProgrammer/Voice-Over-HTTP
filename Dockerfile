FROM debian:10

RUN apt-get update
RUN apt-get -y install \
	apache2 \
	apache2-utils \
	openssl \
	python

RUN a2enmod proxy
RUN a2enmod proxy_http
RUN a2enmod ssl
RUN a2enmod alias

COPY 000-default.conf /etc/apache2/sites-enabled/000-default.conf

RUN mkdir /relayserver
RUN mkdir /authconfig

COPY python_relay.py /relayserver

COPY webui.html /var/www
COPY a_or_b.html /var/www

COPY container_init.sh /
RUN chmod +x /container_init.sh

ENTRYPOINT /container_init.sh
