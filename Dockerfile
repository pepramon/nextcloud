# Utilizamos la imagen oficial nextcloud como base
FROM nextcloud:stable

# Copiar el script de inicio al contenedor
COPY script_inicio.sh /script_inicio.sh

# For inotify, y se actualizan los paquetes
RUN chmod +x /script_inicio.sh && \
    apt-get update && \
    apt-get -y upgrade && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* 

# Definir el script como entrypoint
ENTRYPOINT ["/script_inicio.sh"]
