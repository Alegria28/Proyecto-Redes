#cspell: ignore noninteractive, dnsutils, recursivamente, checkconf, checkzone

# La imagen se creara basándose en Ubuntu (en su ultima version en Docker Hub)
FROM ubuntu:latest

# Establecer la variable de entorno DEBIAN_FRONTEND a 'noninteractive'
# Esto evita que aparezcan diálogos interactivos durante la instalación de paquetes
ENV DEBIAN_FRONTEND=noninteractive

# Corremos el siguiente comando (en el contenedor) donde:
# - Actualizamos el sistema
# - Instalamos bind y dnsutils
# - Para liberar espacio, limpiamos los paquetes (.deb) descargados que ya no son usados, esto
# para lograr que la imagen creada sea mas ligera
# -y responde "si" automáticamente durante la instalación
RUN apt update && apt install -y bind9 dnsutils && apt clean

# En el directorio de trabajo de BIND copiamos los archivos de configuración de hemos creado
COPY config/named/named.conf /etc/bind/named.conf
COPY config/named/viewsConf.txt /etc/bind/viewsConf.txt
COPY config/named/optionsACL_Conf.txt /etc/bind/optionsACL_Conf.txt

# Nuevamente en el directorio de trabajo de BIND, copiamos la configuración de las zonas
COPY config/zonas/db.local.pagina1.com /etc/bind/db.local.pagina1.com
COPY config/zonas/db.local.pagina2.com /etc/bind/db.local.pagina2.com
COPY config/zonas/db.local.pagina3.com /etc/bind/db.local.pagina3.com
COPY config/zonas/db.local.pagina1.com.host /etc/bind/db.local.pagina1.com.host
COPY config/zonas/db.local.pagina2.com.host /etc/bind/db.local.pagina2.com.host
COPY config/zonas/db.local.pagina3.com.host /etc/bind/db.local.pagina3.com.host

# Creamos un directorio de cache para bind
# -p sirve para crear directorios padres (en este caso var o cache) si estos
# no existen
RUN mkdir -p /var/cache/bind

# Corremos el siguiente comando (en el contenedor) donde:
# - Creamos el directorio de runtime para BIND que es utilizado por el demonio named para almacenar archivos de runtime
# - Cambiamos el propietario y el grupo del directorio /run/named (y su contenido, recursivamente con -R) al usuario 'bind' y grupo 'bind'.
# - Establecemos los permisos del directorio /run/named (ver proxySquid/Dockerfile para mas información)
RUN mkdir -p /run/named && chown -R bind:bind /run/named && chmod -R 775 /run/named

# Corremos el siguiente comando (en el contenedor) donde:
# - Cambiamos el dueño de los directorios al usuario "bind" y grupo "bind" recursivamente (-R) para todos los contenidos 
RUN chown -R bind:bind /etc/bind /var/cache/bind

# Corremos el siguiente comando (en el contenedor) donde:
# - Establecemos los permisos del directorio /run/named (ver proxySquid/Dockerfile para mas información)
RUN chmod -R 775 /run/named

# Corremos el siguiente comando (en el contenedor) donde:
# - Buscamos todos los archivos que estén en el directorio /etc/bind (-type -f nos ayuda a hacer eso)
# - Por cada archivo encontrado (-exec) cambiamos los permisos (ver proxySquid/Dockerfile para mas información), {} se remplaza por el nombre 
# del archivo encontrado y \; indica el final del comando a ejecutar
RUN find /etc/bind -type f -exec chmod 644 {} \;

# Corremos el siguiente comando (en el contenedor) donde:
# - Establecemos los permisos del directorio /var/cache/bind (ver proxySquid/Dockerfile para mas información)
RUN chmod -R 775 /var/cache/bind

# Verificamos la sintaxis de los archivos de configuración utilizando named-checkconf, de haberlos entonces se parara la construcción de la imagen
RUN named-checkconf /etc/bind/named.conf

# Verificamos la sintaxis de los archivos de configuración de nuestras zonas, de haberlos entonces se parara la construcción de la imagen,
# siguiendo un formato <nombre_zona> <archivo_zona_contenedor>
RUN named-checkzone local.pagina1.com /etc/bind/db.local.pagina1.com
RUN named-checkzone local.pagina2.com /etc/bind/db.local.pagina2.com
RUN named-checkzone local.pagina3.com /etc/bind/db.local.pagina3.com
RUN named-checkzone local.pagina1.com /etc/bind/db.local.pagina1.com.host
RUN named-checkzone local.pagina2.com /etc/bind/db.local.pagina2.com.host
RUN named-checkzone local.pagina3.com /etc/bind/db.local.pagina3.com.host

# Exponemos el puerto 53 es el por defecto para servicios DNS (tcp y udp son protocolos)
EXPOSE 53/udp
EXPOSE 53/tcp

# Especificamos (antes del CMD) que el usuario con el que se ejecutara es bind
USER bind

# A diferencia de RUN (que se ejecuta al construir la imagen), CMD se ejecuta cuando se crea el contenedor,
# en este caso, para iniciar el servidor BIND
# CMD usa la forma "exec", donde el primer argumento es el ejecutable y los siguientes son los parámetros
# Usamos la opción -g para que "named" se ejecute en primer plano (foreground), lo cual es necesario para que el contenedor
# no se detenga al pensar que el proceso principal ha terminado
# Además, especificamos el archivo de configuración principal con -c /etc/bind/named.conf
CMD ["/usr/sbin/named", "-g", "-c", "/etc/bind/named.conf"]