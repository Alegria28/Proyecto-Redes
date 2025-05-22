FROM ubuntu:latest

RUN apt update && \
    apt install -y apache2 && \
    apt clean

RUN apt-get update && apt-get installa -y supervisor

COPY ./apache/apache2.conf /usr/local/apache2/conf/httpd.conf

COPY ./apache/sites-available/ /usr/local/apache2/conf/extra/

RUN sed -i '/LoadModule vhost_alias_module modules\/mod_vhost_alias.so/s/^#//g' /usr/local/apache2/conf/httpd.conf \
    && sed -i '/LoadModule rewrite_module modules\/mod_rewrite.so/s/^#//g' /usr/local/apache2/conf/httpd.conf \
    && sed -i '/Include conf\/extra\/httpd-vhosts.conf/s/^#//g' /usr/local/apache2/conf/httpd.conf

EXPOSE 80
EXPOSE 443

COPY ./htdocs/ /usr/local/apache2/htdocs/

CMD ["supervisor", "-n"] //GESTIONAR EL PROCESO DE SERVICIOS