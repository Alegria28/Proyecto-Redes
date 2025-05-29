# La imagen se creara basándose en Ubuntu junto con la aplicación de Squid (en su ultima version en Docker Hub)
FROM ubuntu/squid:latest

# Para poder hacer pruebas de ping y curl en el contenedor, instalamos los paquetes, pero no sin antes actualizar el contenedor
RUN apt update && apt install && apt install -y iputils-ping curl

# Copiamos los archivos creados con la información sobre los sitios y palabras prohibidas ademas de la configuración que va a tener
# el proxy de squid en la imagen creada
COPY squid.conf /etc/squid/squid.conf
COPY palabrasProhibidas.txt /etc/squid/palabrasProhibidas.txt
COPY sitiosProhibidos.txt /etc/squid/sitiosProhibidos.txt

# Ejecutamos el siguiente comando dentro de nuestra imagen, en donde cambiamos los permisos:
# - Primer dígito permisos para el dueño del archivo
# - Segundo dígito permisos para el grupo al que pertenece el equipo
# - Tercer dígito permisos para todos los demás usuarios
# La suma de los valores representan permisos distintos:
# 4 permiso lectura
# 2 permiso escritura
# 1 permiso ejecución
# Como tenemos 6 (4 + 2) el dueño root puede leer y escribir mientras que el grupo y otros usuarios solo pueden leer
# ESto se hace para que el solamente el usuario para Squid solo pueda leer estos archivos 
RUN chmod 644 /etc/squid/palabrasProhibidas.txt /etc/squid/sitiosProhibidos.txt

# Squid estará "escuchando" desde este puerto (en el contenedor) el cual es que esta por defecto para Squid.
# Con escuchar nos referimos a esperar solicitudes para poder ser procesadas
EXPOSE 3128