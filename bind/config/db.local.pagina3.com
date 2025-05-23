; local.pagina3.com

$TTL    604800
@       IN      SOA     ns1.local.pagina3.com. admin.local.pagina3.com. (
                      3           ; Serial (incrementa con cada cambio)
                 604800           ; Refresh
                  86400           ; Retry
                2419200           ; Expire
                 604800 )         ; Negative Cache TTL
;
@       IN      NS      ns1.local.pagina3.com.   ; Servidor de nombres para esta zona
ns1     IN      A       172.18.0.2               ; IP de tu contenedor Bind9 (ej. la IP estática que le diste en docker-compose.yml)
@       IN      A       172.18.0.3               ; IP de tu contenedor Apache (ej. otra IP estática en la misma red Docker)
www     IN      A       172.18.0.6               ; Si quieres www.local.pagina3.com

admin   IN      A       1.1.1.1
app1    IN      A       2.2.2.2
api     IN      A       3.3.3.3  