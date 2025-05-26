# Proyecto Redes - Configuración de DNS, Servidor Web y Proxy

Este proyecto configura un entorno con tres servicios principales utilizando Docker:
1.  **BIND9**: Servidor DNS para resolver nombres de dominio personalizados.
2.  **Apache**: Servidor web para alojar múltiples sitios virtuales.
3.  **Squid**: Proxy para filtrar el acceso a internet.

## Prerrequisitos

*   **Docker** instalado (Ver [guía de instalación de Docker](https://docs.docker.com/engine/install/))
*   **Docker Compose** instalado (Ver [guía de instalación de Docker Compose](https://docs.docker.com/compose/install/))
*   **Git** (para clonar el repositorio)
*   Un sistema operativo **Linux** para seguir los pasos de prueba.

## Configuración Inicial

1.  **Clonar el repositorio (si aún no lo has hecho):**
    ```bash
    git clone https://github.com/Alegria28/Proyecto-Redes.git
    cd Proyecto-Redes
    ```

## Ejecutar los Servicios

1.  **Levantar los contenedores:**
    Desde la raíz del proyecto (donde se encuentra el archivo `docker-compose.yml`), ejecuta:
    ```bash
    docker compose -f 'docker-compose.yml' up -d --build
    ```
    Esto construirá las imágenes (si es la primera vez o si hay cambios en los Dockerfiles) e iniciará los contenedores en segundo plano.
    
## Probar los Servicios

A continuación, se detallan los pasos para probar cada servicio.

### 1. Probar el Servicio DNS (BIND)

El servidor BIND está configurado para resolver los dominios `local.pagina1.com`, `local.pagina2.com`, y `local.pagina3.com`.

#### a. Configurar DNS en la Máquina Anfitriona

Necesitarás configurar manualmente el DNS en tu máquina anfitriona (host Linux) para que utilice el servidor DNS que se ejecuta en Docker (`127.0.0.1`).

**Ejemplo para Linux Mint (o distribuciones con NetworkManager similar):**

1.  Abre la configuración de Red.
2.  Selecciona tu conexión activa y accede a sus ajustes (normalmente un icono de engranaje).
3.  Ve a la pestaña `IPv4`.
4.  Desactiva el DNS automático.
5.  En el campo de Servidores DNS, añade `127.0.0.1`.
6.  Aplica los cambios.

<table>
  <tr>
    <td align="center"><img src="images/network.png" alt="Acceder a configuración de red" width="600"/></td>
    <td align="center"><img src="images/IPv4.png" alt="Configurar DNS en IPv4" width="550"/></td>
  </tr>
  <tr>
    <td align="center"><em>Paso 1 & 2: Acceder a la configuración de la conexión de red.</em></td>
    <td align="center"><em>Paso 3-5: Configurar el servidor DNS en la pestaña IPv4.</em></td>
  </tr>
</table>

7.  **Reinicia NetworkManager** para que los cambios surtan efecto:
    ```bash
    sudo systemctl restart NetworkManager
    ```

#### b. Verificar la Resolución DNS

Abre una terminal y usa el comando `dig` para consultar cada dominio. El servidor DNS a consultar es `127.0.0.1`.

*   Para `local.pagina1.com`:
    ```bash
    dig local.pagina1.com @127.0.0.1
    ```
*   Para `local.pagina2.com`:
    ```bash
    dig local.pagina2.com @127.0.0.1
    ```
*   Para `local.pagina3.com`:
    ```bash
    dig local.pagina3.com @127.0.0.1
    ```
    En la sección `ANSWER SECTION` de la salida, deberías ver que cada dominio resuelve a `127.0.0.1`.

### 2. Probar el Servicio Web (Apache)

Con la configuración DNS de tu host apuntando a `127.0.0.1` (del paso anterior):

#### a. Acceder a las Páginas Web

Abre tu navegador web y visita las siguientes URLs:
*   `http://local.pagina1.com` (Debería mostrar "Esta es la pagina 1")
*   `http://local.pagina2.com` (Debería mostrar "Esta es la pagina 2")
*   `http://local.pagina3.com` (Debería mostrar "Esta es la pagina 3")

### 3. Probar el Servicio Proxy (Squid)

El proxy Squid se ejecuta en `127.0.0.1` en el puerto `3128`.

#### a. Configurar el Proxy en tu Sistema o Navegador

*   **Opción 1: Navegador (Ejemplo Firefox):**
    1.  Ve a `Preferencias` -> `General`.
    2.  Desplázate hasta `Configuración de red` y haz clic en `Configuración...`.
    3.  Selecciona `Configuración manual del proxy`.
    4.  En `Proxy HTTP`, ingresa `127.0.0.1`.
    5.  En `Puerto` para HTTP Proxy, ingresa `3128`.
    6.  Opcionalmente, marca "Usar este proxy para todos los protocolos" o configura también el proxy HTTPS con los mismos valores.
    7.  Guarda los cambios.

*   **Opción 2: Sistema (Ejemplo Linux Mint):**
    1.  Ve a la configuración de `Red`.
    2.  Selecciona `Proxy de red`.
    3.  Elige el método `Manual`.
    4.  Configura `HTTP Proxy` y `HTTPS Proxy` con la dirección `127.0.0.1` y el puerto `3128`.
    5.  Aplica los cambios.

    ![Configuración de Proxy en Linux Mint](images/proxy.png)
    *<p align="center">Ejemplo de configuración del proxy a nivel de sistema en Linux Mint.</p>*

#### b. Probar el Filtrado

Con el proxy configurado:
*   **Sitio permitido:** Intenta acceder a un sitio web normal que no esté en la lista de prohibidos (ej. `http://example.com`). Debería cargar correctamente.
*   **Sitio prohibido (por dominio):** Intenta acceder a `http://www.facebook.com` o `http://www.youtube.com`. El acceso debería ser bloqueado por Squid.
*   **Palabra prohibida (en URL):** Intenta buscar "juegos" o "casino" en un motor de búsqueda, o intenta acceder a una URL que contenga estas palabras (ej. `http://example.com/pagina-de-juegos.html`). El acceso debería ser bloqueado por Squid.

## Detener los Servicios

Para detener y eliminar los contenedores definidos en `docker-compose.yml`:
```bash
docker compose down
```
Esto detendrá y eliminará los contenedores y redes pero no las imágenes de estas.

## Solución de Problemas

*   **Permisos de Docker:** Asegúrate de que tu usuario tiene permisos para ejecutar comandos de Docker. Generalmente, esto se logra añadiendo tu usuario al grupo `docker` (`sudo usermod -aG docker $USER` y luego reiniciando sesión o el sistema) o ejecutando los comandos de Docker con `sudo`.
*   **Puertos Ocupados:** Si los puertos `53` (DNS), `80` (HTTP) o `3128` (Proxy) ya están en uso en tu máquina anfitriona, `docker compose up` fallará. Deberás detener los servicios que estén usando esos puertos o modificar los mapeos de puertos en el archivo `docker-compose.yml` (ej. ` "8080:80"` para mapear el puerto 80 del contenedor al 8080 del host).
    *   Para identificar qué servicio está usando un puerto específico (reemplaza `<PUERTO>` con el número de puerto, ej. 53, 80):
        ```bash
        sudo netstat -tulnp | grep ':<PUERTO>'
        ```
    *   Una vez identificado el servicio, puedes intentar detenerlo. Por ejemplo, si `systemd-resolved` está usando el puerto 53:
        ```bash
        sudo systemctl stop systemd-resolved
        ```
    *   Si es otro servicio, usa su nombre correspondiente con `systemctl stop <nombre-del-servicio>`. Si no es un servicio gestionado por systemd, podrías necesitar usar `kill <PID>` (donde PID es el ID del proceso obtenido del comando `ss` o `netstat`).
    *   **Advertencia:** Detener servicios del sistema puede tener efectos inesperados. Asegúrate de saber qué servicio estás deteniendo. A menudo, `systemd-resolved` es el culpable del puerto 53 en sistemas de escritorio Linux. Para el puerto 80, podrían ser otros servidores web como Apache (`apache2`) o Nginx (`nginx`) instalados localmente.
