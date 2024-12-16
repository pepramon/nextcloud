#!/bin/bash

# Función para manejar una salida limpia del script
salida_limpia() {
    echo "Iniciando proceso de apagado..."
    
    # Detener cron
    if [ -n "$CRON_PID" ]; then
        kill -SIGTERM "$CRON_PID" 2>/dev/null
        wait "$CRON_PID" 2>/dev/null
    fi
    
    # Detener el proceso de Nextcloud
    if kill -0 "$NC_PID" 2>/dev/null; then
        echo "Deteniendo NextCloud..."
        kill -SIGTERM "$NC_PID"
        wait "$NC_PID"
    fi
    
    echo "Apagado completo."
    exit
}

# Configurar manejo de señales para salida ordenada
# TERM, INT: Señales para detener el script de forma controlada (por ejemplo, Docker o Ctrl+C)
# QUIT: Señal adicional de interrupción, útil en algunos sistemas
# EXIT: Ejecuta la función `salida_limpia` para garantizar que los procesos se detengan correctamente
trap "salida_limpia" EXIT SIGINT SIGTERM

# Si se suministra un UID, se hace que apache de Nextcloud se ejecute con ese usuario
if [ -n "$UID" ]; then
    usermod -u "$UID" www-data
fi

# Si se suministra un GID, se hace que apache de Nextcloud se ejecute con ese grupo
if [ -n "$GID" ]; then
    groupmod -g "$GID" www-data
fi

# Se asegura que el directorio DATA de nextcloud es accesible en RW por apache
if [ -n "$NEXTCLOUD_DATA_DIR" ]; then
    chown -R www-data:www-data "$NEXTCLOUD_DATA_DIR"
fi

# Se lanza nginx con sus parámetros y se guarda el PID
echo "Iniciando NextCloud..."
/entrypoint.sh "$@" &
NC_PID=$!

# Se configura una espera para ejecutar el cron
# Define un valor por defecto si no está definido TIEMPO_ESPERA de 5 minutos
TIEMPO_ESPERA=${TIEMPO_ESPERA:-300}
if [ -n "$TIEMPO_ESPERA" ]; then
    while true; do
        echo "Ejecutando Cron y esperando $TIEMPO_ESPERA"
        su -s /bin/bash -c "php -f /var/www/html/cron.php" www-data
        sleep "$TIEMPO_ESPERA"
    done &
    CRON_PID=$!
fi

# Esperar a que los procesos terminen
wait "$NC_PID"
EXIT_CODE=$?

if [ -n "$CRON_PID" ]; then
    wait "$CRON_PID"
fi

# Informar sobre la salida del script
echo "Saliendo con código ${EXIT_CODE}"
exit ${EXIT_CODE}

