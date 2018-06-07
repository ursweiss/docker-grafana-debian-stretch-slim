# Grafana Docker image for Raspberry Pi

## Pull image from Docker Hub
You can get the image from Docker Hub too, which will safe you a lot of time:
```sh
docker pull ursweiss/grafana-debian-stretch-slim-arm32v7
```

## Build
On a Raspberry Pi 3, it will take around 75 minutes to build this image.

## Run
Three volumes are used to store persistent data:
* Database & Plugins (grafana-storage)
* Configuration (grafana-etc)
* Logs (grafana-log)

```sh
docker volume create grafana-storage
docker volume create grafana-etc
docker volume create grafana-log
```

Run the container:
```sh
docker run \
  -d \
  -it \
  -p 3000:3000 \
  --name=grafana \
  --mount type=volume,src=grafana-storage,dst=/var/lib/grafana,volume-driver=local \
  --mount type=volume,src=grafana-etc,dst=/etc/grafana,volume-driver=local,readonly \
  --mount type=volume,src=grafana-log,dst=/var/log/grafana,volume-driver=local \
  ursweiss/grafana-debian-stretch-slim-arm32v7
```
