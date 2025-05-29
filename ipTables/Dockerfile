# La imagen se creara basándose en Ubuntu (en su ultima version en Docker Hub)
FROM ubuntu:latest

# Ejecutamos el siguiente comando (en el contenedor) donde:
# - Instalamos el paquete de ubuntu para trabajar con iptables
RUN apt update && apt install -y iptables

# Para poder hacer pruebas de ping y curl en el contenedor, instalamos los paquetes
RUN apt install -y iputils-ping curl

# Copiamos nuestro script shell al contenedor
COPY ipTablesConf.sh /ipTablesConf.sh

# Cambiamos los permisos de este archivo (permisos de ejecución)
RUN chmod +x /ipTablesConf.sh

# Solo para mantener el contenedor arriba
# CMD ["tail", "-f", "/dev/null"] 