#cspell: ignore ensite

# La imagen se creara basándose en Ubuntu (en su ultima version en Docker Hub)
FROM ubuntu:latest

# Corremos el siguiente comando (en el contenedor) donde:
# - Actualizamos el sistema
# - Instalamos apache (el paquete se llama apache2)
# - Para liberar espacio, limpiamos los paquetes (.deb) descargados que ya no son usados, esto
# para lograr que la imagen creada sea mas ligera
# -y responde "si" automáticamente durante la instalación
RUN apt update && apt install -y apache2 && apt clean 

# En el directorio que contiene los sitios disponibles para apache, copiamos la configuración de nuestras paginas
COPY /conf /etc/apache2/sites-available

# Copiamos los archivos .html en el directorio var/www/html, el cual se crea al descargar apache2 (ver https://shorturl.at/m2CSU)
COPY /html /var/www/html

# Habilitamos los sitos virtuales (a2ensite hace eso)
RUN a2ensite pagina1.conf
RUN a2ensite pagina2.conf
RUN a2ensite pagina3.conf

# Exponemos el puerto 80, que es el puerto por defecto para HTTP
EXPOSE 80

# A diferencia de RUN (que se ejecuta cuando se construye la imagen), CMD se ejecuta cuando se crea
# el contenedor, en este caso, para iniciar apache
# CDM usa la forma "exec", en donde el primer argumento es el ejecutable y los siguientes 2 son los parámetros,
# usamos la opción -D para "define a name for use in <IfDefine name> directives" (según -h del ejecutable) y 
# mandamos como segundo parámetro "FOREGROUND" para que apache se ejecute en primer plano (esto para que el contenedor
# no se detenga al pensar que el proceso ha terminado)
CMD ["apache2ctl", "-D", "FOREGROUND"]  