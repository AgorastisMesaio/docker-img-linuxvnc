# Linux Desktop VNC

![GitHub action workflow status](https://github.com/SW-Luis-Palacios/base-linuxvnc/actions/workflows/docker-publish.yml/badge.svg)

This repository contains a `Dockerfile` aimed to create a *base image* to provide a Linux Desktop with VNC Server.

Typical use cases:

- Setup a cloud desktop accessible through Guacamole
- Setup multiple remote desktop accessible through VNC clients.
- Demo and test VDI replacement use cases

## Consume in your `docker-compose.yml`

This is an example use case, where we have a guacamole service and want to access our VNC Server

```yaml
### Docker Compose example

volumes:
  # Guacamole
  gc_backend_drive:
    driver: local
  gc_backend_record:
    driver: local
  gc_postgres_data:
    driver: local
  gc_frontend_drive:
    driver: local
  gc_frontend_record:
    driver: local

networks:
  my_network:
    name: my_network
    driver: bridge

services:
  ct_linuxvnc:
    image: sw-luis-palacios/base-linuxvnc
    hostname: linuxvnc.company.com
    container_name: ct_linuxvnc
    ports:
      - "2222:22"
      - "9001:9001"
      - "5900:5900"
    volumes:
      - ./config:/config          # Optional
    networks:
      - my_network

  #
  # I've included Guacamole example below. It's not part of this repository,
  # and it's only for your information as an example.
  #
  gc_guacd:
    image: guacamole/guacd
    container_name: gc_guacd
    restart: always
    volumes:
      - gc_backend_drive:/drive
      - gc_backend_record:/var/lib/guacamole/recordings
    networks:
      - my_network

  gc_frontend:
    image: guacamole/guacamole
    hostname: guacamole.company.com
    container_name: gc_frontend
    restart: always
    environment:
      GUACD_HOSTNAME: gc_guacd
      POSTGRES_DATABASE: guacamole_db
      POSTGRES_HOSTNAME: gc_postgres
      POSTGRES_PASSWORD: 'ChooseYourOwnPasswordHere1234'
      POSTGRES_USER: guacamole_user
    links:
    - gc_guacd
    volumes:
      - gc_frontend_drive:/drive
      - gc_frontend_record:/var/lib/guacamole/recordings
    ports:
      - 8080:8080
    networks:
      - my_network
    depends_on:
    - gc_guacd
    - gc_postgres

  gc_postgres:
    image: postgres:15.2-alpine
    hostname: gc_postgres.company.com
    container_name: gc_postgres
    restart: always
    environment:
      - PGDATA=/var/lib/postgresql/data/guacamole
      - POSTGRES_DB=guacamole_db
      - POSTGRES_USER=guacamole_user
      - POSTGRES_PASSWORD='ChooseYourOwnPasswordHere1234'
    networks:
      - my_network
    volumes:
    - ./init:/docker-entrypoint-initdb.d:ro
    - sw_gc_postgres_data:/var/lib/postgresql/data
```

I've left ./config directory available to be able to share files with the container.

```zsh
.
├── config
│   ├── run.sh
```

- `run.sh` It's optional. I've included a sample script. If this script is present it'll be called/executed from within `entrypoint.sh`

Start your services

```sh
docker compose up --build -d
```

In the example above you would have the following ports available from this base image. Not that I'm not covering the guacamole ones

- `ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -p 2222 alpine@localhost`
- [http://localhost:9011](http://localhost:9001) - Exposed supervisord port
- [http://localhost:5900](http://localhost:5900) - Exposed VNC

Otherwise, connect to the container directly

```zsh
docker exec -it ct_linuxvnc /bin/bash
```

## For developers

If you copy or fork this project to create your own base image.

### Building the Image

To build the Docker image, run the following command in the directory containing the Dockerfile:

```sh
docker build -t your-image/base-linuxvnc .
or
docker compose up --build -d
```

### Troubleshoot

```sh
docker run --rm --name ct_linuxvnc --hostname linuxvnc --shm-size 1g -p 5900:5900 -p 2222:22 -p 9001:9001 sw-luis-palacios/base-linuxvnc
```
