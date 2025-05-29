#!/bin/bash
# A esto se le llama shebang (!#), el cual viene seguido de una ruta para el ejecutable. Esto es para especificar
# el interpretador con el cual nuestro Shell Script se correrá

# Mantener el comportamiento original de salir en caso de error
set -e

# Simple mensaje de inicio
echo "----- Empezando configuración de los iptables -----"

# En la PC anfitriona hay una cadena llamada DOCKER-USER la cual docker crea y utiliza para que los usuarios puedan añadir reglas personalizadas
# que afectan el trafico de los contenedores

echo "Estado de DOCKER-USER (host) ANTES de modificar (desde contenedor):"
/usr/sbin/iptables-nft -L DOCKER-USER -n -v

# ------ Limpiar cadena DOCKER-USER ------

# Limpiamos (-F) las reglas que tiene esta cadena, de esta manera aseguramos que se agreguen nuevas reglas 
echo "Limpiando cadena DOCKER-USER"
/usr/sbin/iptables-nft -F DOCKER-USER

# ------ Verificar regla DOCKER-USER en cadena FORWARD ------

# Verificamos (-C) si existe una regla en la cadena FORWARD que salte (-j) a DOCKER-USER
# Si no existe, insertamos (-I) la regla en la primera posición de FORWARD
# El '2>/dev/null' en -C suprime el mensaje de error si la regla no existe, permitiendo que '||' funcione
echo "Verificando y asegurando el salto de FORWARD a DOCKER-USER..."
if ! /usr/sbin/iptables-nft -C FORWARD -j DOCKER-USER 2>/dev/null; then
    /usr/sbin/iptables-nft -I FORWARD 1 -j DOCKER-USER
fi

echo "Agregando reglas a DOCKER-USER"

# ------ Permitimos el trafico establecido y relacionado en la cadena DOCKER-USER ------

# Agrega (-A) una regla a la cadena DOCKER-USER para permitir (-j ACCEPT) el tráfico de conexiones ya establecidas (ESTABLISHED)
# y el tráfico relacionado con conexiones existentes (RELATED), esto se logra utilizando el módulo conntrack (connection tracking)
# (-m conntrack) y especificando los estados (--ctstate)
# Esto es MUY IMPORTANTE ya que aseguramos que haya una conexión bidireccional entre los contenedores y una conexión existente
# con los puertos
/usr/sbin/iptables-nft -A DOCKER-USER -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# Es importante notar que la dirección de red de la universidad es: 172.16.152.0/21, por lo que podemos trabajar con direcciones IP
# en el rango 172.16.152.1-172.16.159.254
# La dirección de red se obtiene haciendo un AND con los bits de la mascara (/21) y los bits de una dirección IP de esa subred


# La dirección de red de tserverliv es: 192.168.0.0/24, por lo que podemos trabajar con direcciones IP en el rango 192.168.0.0-192.168.0.255

# ------ 1. Denegar acceso al puerto 80 a un equipo en especifico ------

# En este caso, agregamos una regla (-A) a nuestra cadena para esta IP en especifico bloqueando (-j DROP) el protocolo tcp en el puerto 80 (HTTP),
# agregando un comentario informativo sobre esta regla
/usr/sbin/iptables-nft -A DOCKER-USER -s 192.168.1.77 -p tcp --dport 80 -j DROP -m comment --comment "Regla 1"

# ------ 2. Denegar acceso al puerto 21 a un equipo en especifico ------

# Volvemos a hacer lo mismo para la misma IP, pero ahora estaremos bloqueando el puerto 21 (FTP)
/usr/sbin/iptables-nft -A DOCKER-USER -s 192.168.1.77 -p tcp --dport 21 -j DROP -m comment --comment "Regla 2"

echo "Estado de DOCKER-USER (host) DESPUÉS de modificar (desde contenedor):"
/usr/sbin/iptables-nft -L DOCKER-USER -n -v

echo "Configuración completada"