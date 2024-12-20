# Nginx con vigilancia de carpetas

Esta imagen de Docker es una mejora del la imagen oficial de NextCloud para que tenga un pseudo cron incorporado y seleccionar el usuario con el que se ejecuta

## Como usar

### A través de Docker Compose

```yml
version: "3"

services :
  nginx:
    image: pepramon/nextcloud
    volumes:
      # Configuración típica de NextCloud
      - ./store:/var/www/html
    environment:
      # Hacer que corra con UID 1000, GID 1000
      - UID=1000
      - GID=1000
      # Que ejecute cron cada 5 minutos
      - TIEMPO_ESPERA=300
```

### Mediante Docker run

Igual que en Docker Compose pero con un comando

```bash
docker run -d -v ./store:/var/www/html  -e UID=1000 -e GID=1000 -e TIEMPO_ESPERA=300 pepramon/nextcloud
```

## Soporte y colaboración

Aunque el punto de desarrollo de este proyecto está en un servidor de Gitea propio, se actualiza automáticamente el servidor de Github, y por tanto, cualquier comentario será bienvenido.

[https://github.com/pepramon/nextcloud](https://github.com/pepramon/nextcloud).

## Actualización de la imagen en DockerHub

Como se ha comentado anteriormente, el proyecto está alojado en un servidor de Gitea propio, una de las razones para ello es poder mantener actualiza la imagen de DockerHub de manera automática.

La imagen [https://hub.docker.com/r/pepramon/nextcloud](https://hub.docker.com/r/pepramon/nextcloud) se actualiza automáticamente en los siguiente supuestos:

* La imagen base de NextCloud ha cambiado
* Hay actualizaciones de Debian en el contenedor
* Se ha modificado el Dockerfile o el script `script_inicio.sh` de la raíz del repositorio

Para saber si la imagen base de NextCloud ha cambiado respecto a la construida, se almacena una etiqueta en el interior de la imagen generada que tiene el SHA de la imagen base (revisar `.gitea/workflows/` para ver como se hace).

La construcción se hace mediante Podman con el contenedor personalizado alojado en [https://github.com/pepramon/gitea-runner](https://github.com/pepramon/gitea-runner)