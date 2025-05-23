#REVISAR ESTE APUNTE PARA HACER EL DOCKERFILE
# https://www.youtube.com/watch?v=q_MCqyukJ34&t=667s
#https://gestal.es/downloads/ies/DelegacionDeZonaDockerBind9.pdf
FROM ubuntu:latest

# Actualizamos el sistema
RUN apt update && apt install -y bind9 dnsutils && apt clean && rm -rf /var/lib/apt/lists/*

# Copiamos el archivo de configuración de BIND9
COPY config/named.conf /etc/bind/named.conf
COPY config/named.conf.options /etc/bind/named.conf.options
COPY config/named.conf.local /etc/bind/named.conf.local
COPY config/db.local.pagina1.com /etc/bind/db.local.pagina1.com
COPY config/db.local.pagina2.com /etc/bind/db.local.pagina2.com
COPY config/db.local.pagina3.com /etc/bind/db.local.pagina3.com


RUN chown -R bind:bind /etc/bind/ 
# Cambiamos los permisos de los archivos de configuración de BIND9 
# para que el usuario 'bind' tenga acceso a ellos.
# Esto es importante para la seguridad y el funcionamiento correcto del servicio.
RUN chmod -R 755 /etc/bind/

# Crea el directorio de caché de Bind9 y asigna los permisos correctos.
# Esto es esencial para que Bind9 pueda almacenar su caché de resolución.
RUN mkdir -p /var/cache/bind
RUN chown bind:bind /var/cache/bind
RUN chmod 775 /var/cache/bind # Permisos de escritura para el dueño (bind) y el grupo

# Exponemos el puerto 53 para el servicio DNS
EXPOSE 53/udp
EXPOSE 53/tcp

# Comando para iniciar el servicio BIND9
CMD ["/usr/sbin/named", "-g", "-c", "/etc/bind/named.conf"]



