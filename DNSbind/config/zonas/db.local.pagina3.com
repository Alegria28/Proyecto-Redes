; Ver https://shorturl.at/54DFa para ver que son las DNS zones y https://shorturl.at/rCxsK para la configuración del "zone file"
; Configuramos zona para "local.pagina3.com"

; Configuramos el "time-to-live (TTL)", el cual especifica cuanto tiempo (s) un RR (resource records) va a estar en 
; cache antes de que este sea descartado. Un RR es una entrada a nuestro DNS el cual puede o no tener información
$TTL    604800

; Especificamos registros para los nombres del propietario (el nombre del dominio donde los RR se encuentran)

; Según la documentación: "The @ (at-sign) When used in the label (or name) field, the asperand or at-sign (@) symbol represents the current origin." Es decir,
; que nos referimos a la misma zona. "IN" significa Internet, por lo que declaramos estos registros son parte de la clase Internet

; Este registro SOA (start of authority) es fundamental, ya que es donde se declaran las características de esta zona (dominio), 
; ver https://shorturl.at/BcOgk para obtener mas información sobre los campos de esta configuración
@       IN      SOA     ns1.local.pagina3.com. admin.local.pagina3.com. ( ; Campos MNAME (master name server) y RNAME (responsible name)
                      3           ; Serial
                 604800           ; Refresh
                  86400           ; Retry
                2419200           ; Expire
                 604800           ; Minimum
                )         

; Tipo de registro NS (name server) que especifica el nombre autoritativo para esta zona
@       IN      NS      ns1.local.pagina3.com.   
; Tipo de registro address el cual se encarga de mapear un nombre de host a una dirección IPv4 del contenedor de Apache (para local.pagina3.com)
@       IN      A       192.168.0.3               
; Tipo de registro address el cual se encarga de mapear un nombre de host a una dirección IPv4 del contenedor Bind9 (para ns1.local.pagina3.com)
ns1     IN      A       192.168.0.2
