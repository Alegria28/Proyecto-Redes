# Proyecto Redes - Configuración de DNS, Servidor Web y Proxy

Este proyecto configura un entorno con tres servicios principales utilizando Docker:
1. **BIND9**: Servidor DNS para resolver nombres de dominio personalizados.
2. **Apache**: Servidor web para alojar múltiples sitios virtuales.
3. **Squid**: Proxy para filtrar el acceso a internet.

## Prerrequisitos

1. **Docker** y **Docker Compose** instalados ([Guía de instalación](https://docs.docker.com/get-docker/)).
2. **Git** para clonar el repositorio.
3. Sistema operativo **Linux**.

## Configuración Inicial

1. Clona el repositorio:
    ```bash
    git clone https://github.com/Alegria28/Proyecto-Redes.git
    cd Proyecto-Redes
    ```

2. Levanta los servicios:
    ```bash
    docker compose up -d --build
    ```

## Probar los Servicios

### 1. DNS (BIND9)

#### Configurar DNS en el Host
1. Cambia el servidor DNS de tu máquina a `127.0.0.1` (consulta la configuración de red de tu sistema operativo).
2. Reinicia el servicio de red:
    ```bash
    sudo systemctl restart NetworkManager
    ```

#### Verificar Resolución DNS
Usa `dig` para probar los dominios configurados:
```bash
dig local.pagina1.com @127.0.0.1
dig local.pagina2.com @127.0.0.1
dig local.pagina3.com @127.0.0.1
```
Deberías ver que cada dominio resuelve a `127.0.0.1`.

### 2. Servidor Web (Apache)

Con el DNS configurado, abre un navegador y visita:
- `http://local.pagina1.com` (Página 1)
- `http://local.pagina2.com` (Página 2)
- `http://local.pagina3.com` (Página 3)

### 3. Proxy (Squid)

#### Configurar Proxy
Configura tu navegador o sistema para usar `127.0.0.1:3128` como proxy HTTP y HTTPS.

#### Probar Filtrado
- **Permitido**: Accede a `http://example.com`.
- **Bloqueado**: Intenta acceder a `http://www.facebook.com` o URLs con palabras como "juegos".

### 4. Probar las Reglas de Firewall (iptables)

El script `ipTables/ipTablesConf.sh` se ejecuta automáticamente al levantar los servicios con `docker compose up` gracias al servicio `iptables-config` definido en `docker-compose.yml`. Este script modifica las reglas de `iptables` en la máquina anfitriona (host) para controlar el tráfico hacia y desde los contenedores.

**Notas Generales para las Pruebas:**
*   Necesitarás la dirección IP de tu máquina anfitriona (la que ejecuta Docker). En las pruebas, esta se referirá como `<docker_host_ip>`. 
    *   Para obtener la IP de tu máquina anfitriona, puedes usar el comando:
        ```bash
        ip addr show
        ```
        Busca la dirección IP asociada a la interfaz de red que estás utilizando (por ejemplo, `eth0` o `wlan0`).
*   Las IPs como `192.168.1.77` son ejemplos y deben ser reemplazadas por las IPs reales de las máquinas en tu red local. Para identificar la IP de una máquina en tu red:
    *   En Linux o macOS, usa:
        ```bash
        ifconfig
        ```
        o
        ```bash
        ip addr show
        ```
    *   En Windows, usa:
        ```cmd
        ipconfig
        ```
*   Algunas pruebas requieren acceso a otras máquinas en tu red local con direcciones IP específicas o la capacidad de cambiar la IP/MAC de tu máquina de prueba.
*   Para reglas que bloquean el tráfico saliente de contenedores (ej., a través de `enp4s0`), la interfaz de red `enp4s0` es un ejemplo y podría ser diferente en tu máquina anfitriona (ej., `eth0`, `wlan0`).

#### a. Regla 1: Denegar acceso al puerto 80 (HTTP) desde `192.168.1.77`
*   **Desde una máquina con IP `192.168.1.77` (o la IP correspondiente en tu red):**
    Intenta acceder al servidor web:
    ```bash
    curl http://<docker_host_ip>
    ```
    *   **Resultado Esperado:** La conexión debería fallar (timeout o rechazo).
*   **Desde una máquina con IP diferente (ej. `192.168.1.78`):**
    Intenta acceder al servidor web:
    ```bash
    curl http://<docker_host_ip>
    ```
    *   **Resultado Esperado:** Deberías recibir el contenido de `local.pagina1.com` (o la página por defecto del servidor Apache).

#### b. Regla 2: Denegar acceso al puerto 21 (FTP) desde `192.168.1.77`
*   **Servicio involucrado:** El contenedor `servidorFTP` está ejecutando un servidor FTP en el puerto 21.
*   **Desde una máquina con IP `192.168.1.77` (o la IP correspondiente en tu red):**
    Intenta conectar al puerto FTP:
    ```bash
    telnet <docker_host_ip> 21
    ```
    *   **Resultado Esperado:** La conexión debería fallar.
*   **Desde una máquina con IP diferente:**
    Intenta conectar al puerto FTP:
    ```bash
    telnet <docker_host_ip> 21
    ```
    *   **Resultado Esperado:** Deberías ver el banner del servidor FTP o un intento de conexión exitoso.

#### c. Regla 3: Denegar tráfico de salida para el rango de IPs de contenedor `192.168.0.70-192.168.0.160`
*   **Contenedor involucrado:** El contenedor `notraficosalida` tiene la IP `192.168.0.77`, que está dentro del rango bloqueado.
*   **Pasos:**
    1.  Accede a la shell del contenedor:
        ```bash
        docker exec -it notraficosalida /bin/bash
        ```
    2.  Dentro del contenedor, intenta acceder a un sitio externo:
        ```bash
        curl http://example.com
        ```
        o
        ```bash
        ping 8.8.8.8
        ```
        *   **Resultado Esperado:** La conexión debería fallar (timeout, "no route to host", etc.).

#### d. Regla 5: Denegar acceso al puerto 25 (SMTP) desde la MAC `40:1a:58:d5:45:7a`
*   **Servicio involucrado:** El contenedor `servidorSMTP` está ejecutando un servidor SMTP en el puerto 25.
*   **Desde una máquina con la MAC `40:1a:58:d5:45:7a`:**
    Intenta conectar al puerto 25:
    ```bash
    telnet <docker_host_ip> 25
    ```
    *   **Resultado Esperado:** La conexión debería fallar.
*   **Desde una máquina con una MAC diferente:**
    Intenta conectar al puerto 25:
    ```bash
    telnet <docker_host_ip> 25
    ```
    *   **Resultado Esperado:** Deberías ver el banner del servidor SMTP o un intento de conexión exitoso.

#### e. Regla 6: Limitar número de conexiones simultáneas a 20
*   **Prueba:** Intenta establecer más de 20 conexiones TCP nuevas simultáneamente al servidor Apache (puerto 80). Puedes usar un script simple o herramientas como `ab` (Apache Benchmark).
    Ejemplo con `curl` en un bucle (ejecutar desde otra máquina o el host):
    ```bash
    for i in $(seq 1 30); do (curl -s -o /dev/null -m 2 http://<docker_host_ip>/ && echo "Conexión $i: Éxito") || echo "Conexión $i: Fallo" & done; wait
    ```
*   **Resultado Esperado:** Las primeras ~20 conexiones podrían tener éxito. Las conexiones subsiguientes deberían ser rechazadas (la regla usa `REJECT --reject-with tcp-reset`, por lo que el cliente debería recibir un reset de TCP).

#### f. Regla 7: Denegar acceso de salida al puerto 443 (HTTPS) para el contenedor con IP `192.168.0.165`
*   **Contenedor involucrado:** El contenedor `bloqueopuertohttps` tiene la IP `192.168.0.165`, que está bloqueada para el puerto 443.
*   **Pasos:**
    1.  Accede a la shell del contenedor:
        ```bash
        docker exec -it bloqueopuertohttps /bin/bash
        ```
    2.  Dentro del contenedor, intenta acceder a un sitio HTTPS externo:
        ```bash
        curl https://example.com
        ```
        *   **Resultado Esperado:** La conexión debería fallar.

#### g. Regla 8: Permitir acceso al puerto 2222 (SSH) solo desde `192.168.1.200`
*   **Servicio involucrado:** El contenedor `servidorSSH` está ejecutando un servidor SSH en el puerto 2222.
*   **Desde una máquina con IP `192.168.1.200`:**
    Intenta conectar por SSH:
    ```bash
    ssh testuser@<docker_host_ip> -p 2222
    ```
    *   **Resultado Esperado:** Deberías ver el prompt de SSH o establecer una conexión (después de ingresar la contraseña si es necesaria).
*   **Desde una máquina con IP diferente:**
    Intenta conectar por SSH:
    ```bash
    ssh testuser@<docker_host_ip> -p 2222
    ```
    *   **Resultado Esperado:** La conexión debería fallar (timeout o rechazo por `iptables` antes de llegar al prompt de SSH).

#### h. Regla 9: Denegar acceso al puerto 23 (Telnet)
*   **Desde cualquier máquina:**
    Intenta conectar al puerto Telnet:
    ```bash
    telnet <docker_host_ip> 23
    ```
*   **Resultado Esperado:** La conexión debería fallar. Esto bloquea el acceso a cualquier servicio que pudiera estar mapeado al puerto 23 del host.

#### i. Regla 10: Denegar acceso al puerto 110 (POP3)
*   **Desde cualquier máquina:**
    Intenta conectar al puerto POP3:
    ```bash
    telnet <docker_host_ip> 110
    ```
*   **Resultado Esperado:** La conexión debería fallar. Esto bloquea el acceso a cualquier servicio que pudiera estar mapeado al puerto 110 del host.

#### j. Regla 11: Denegar acceso al puerto 143 (IMAP)
*   **Desde cualquier máquina:**
    Intenta conectar al puerto IMAP:
    ```bash
    telnet <docker_host_ip> 143
    ```
*   **Resultado Esperado:** La conexión debería fallar. Esto bloquea el acceso a cualquier servicio que pudiera estar mapeado al puerto 143 del host.

## Detener y Limpiar el Entorno

1. Detén los servicios:
    ```bash
    docker compose down
    ```

2. Limpia el entorno:
    ```bash
    ./limpiar.sh
    ```
    Si no tienes permisos de ejecución:
    ```bash
    chmod +x limpiar.sh
    ```

## Solución de Problemas

- **Permisos de Docker**: Asegúrate de que tu usuario pertenece al grupo `docker`:
    ```bash
    sudo usermod -aG docker $USER
    ```
- **Puertos Ocupados**: Identifica y libera los puertos necesarios:
    ```bash
    sudo netstat -tulnp | grep ':<PUERTO>'
    ```
    Detén el servicio que ocupa el puerto:
    ```bash
    sudo systemctl stop <nombre_servicio>
    ```
