#!/bin/bash
set -e

echo "----- Empezando configuración de los iptables (simplificado) -----"

echo "Estado de DOCKER-USER (host) ANTES de modificar (desde contenedor):"
/usr/sbin/iptables-nft -L DOCKER-USER -n -v

echo "Limpiando DOCKER-USER..."
# Solo limpiamos la cadena, Docker deberia haberla creado.
/usr/sbin/iptables-nft -F DOCKER-USER

echo "Agregando reglas a DOCKER-USER..."
# Permitir tráfico establecido y relacionado
/usr/sbin/iptables-nft -A DOCKER-USER -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT -m comment --comment "Regla_Contenedor_RELATED_ESTABLISHED"

# Denegar acceso al puerto 80 para IP específica
/usr/sbin/iptables-nft -A DOCKER-USER -s 192.168.1.85 -p tcp --dport 80 -j DROP -m comment --comment "Regla_Contenedor_DROP_80_CELULAR"

echo "Estado de DOCKER-USER (host) DESPUÉS de modificar (desde contenedor):"
/usr/sbin/iptables-nft -L DOCKER-USER -n -v

echo "Script finalizado, manteniendo contenedor activo."
# Mantener el contenedor corriendo
tail -f /dev/null