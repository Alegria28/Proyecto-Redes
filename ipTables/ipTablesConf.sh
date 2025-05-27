#!/bin/bash
# A esto se le llama shebang (!#), el cual viene seguido de una ruta para el ejecutable. Esto es para especificar 
# el interpretador con el cual nuestro Shell Script se correrá

# Simple mensaje de inicio
echo "----- Empezando configuración de los iptables -----"

# En la PC anfitriona hay una cadena llamada DOCKER-USER la cual docker crea y utiliza para que los usuarios puedan añadir reglas personalizadas
# que afectan el trafico de los contenedores 

# ------ Limpiar y borrar cadena ------

# Con -F borramos todas las reglas en esta cadena dentro de esta cadena
iptables -F DOCKER-USER 
# Intentamos borrar esta cadena (después de haberla vaciado), aunque se espera que no lo haga ya que esta esta siendo usada por otra (FORWARD),
# por lo que redirigimos el error a null
iptables -X DOCKER-USER 2>/dev/null

# ------ Crear cadena ------

# Creamos nuevamente esta cadena usando -N, redirigiendo cualquier salida de error estándar (stderr) a null (archivo especial que descarta toda la información que se le escribe), 
# para que de esta manera el error se "oculte" o se "suprima". El error esperado aquí es que indique que esta cadena ya existe
iptables -N DOCKER-USER 2>/dev/null

# ------ Verificar regla DOCKER-USER en cadena FORWARD ------

# - Verificamos (-C) si existe una regla en la cadena FORWARD que salte (-j) a DOCKER-USER para procesamiento según las reglas de esta cadena, 
# redirigiendo la  salida de error estándar (stderr) al archivo especial null si es que no se encontró la regla especificada
# - El operador or (||) en shell funciona asi: Si el comando de la derecha termina con éxito, sin que haya salido ningún error, 
#  entonces no se va a ejecutar el comando de la derecha, y si el comando de la derecha falla, entonces si se va a ejecutar 
# - Si no existe, insertamos (-I) la regla DOCKER-USER en la cadena FORWARD para que el trafico pase por DOCKER-USER, asegurando
# que las reglas declaradas en DOCKER-USER sean procesadas
iptables -C FORWARD -j DOCKER-USER || iptables -I FORWARD -j DOCKER-USER

# ------ Permitimos el trafico establecido y relacionado en la cadena DOCKER-USER ------

# Agrega (-A) una regla a la cadena DOCKER-USER para permitir (-j ACCEPT) el tráfico de conexiones ya establecidas (ESTABLISHED)
# y el tráfico relacionado con conexiones existentes (RELATED), esto se logra utilizando el módulo conntrack (connection tracking) 
# (-m conntrack) y especificando los estados (--ctstate)
# Esto es MUY IMPORTANTE ya que aseguramos que haya una conexión bidireccional entre los contenedores y una conexión existente 
# con los puertos
iptables -A DOCKER-USER -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# Es importante notar que la dirección de red de la universidad es: 172.16.152.0/21, por lo que podemos trabajar con direcciones IP
# en el rango 172.16.152.1-172.16.159.254
# La dirección de red se obtiene haciendo un AND con los bits de la mascara (/21) y los bits de una dirección IP de esa subred

# ------ 1. Denegar acceso al puerto 80 a un equipo en especifico ------

# En este caso, agregamos una regla (-A) a nuestra cadena para esta IP en especifico (172.16.152.69) 
# bloqueando (-j DROP) el protocolo tcp en el puerto 80
iptables -A DOCKER-USER -s 172.16.152.69 -p tcp --dport 80 -j DROP