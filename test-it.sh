#!/usr/bin/env bash
set -x
set -e

dest=$(pwd)/permanent
[ -d "$dest" ] || mkdir "$dest"
data=$dest/data
[ -d "$data" ] || mkdir "$data"

[ -e Dockerfile ] || ln -s docker/all-in-one/Dockerfile.debian Dockerfile
docker build -t mcondarelli/zt1-ui:0.1 -t mcondarelli/zt1-ui:latest  .
docker run -d --rm --name zt1 \
  --mount "type=bind,src=$dest,dst=/var/lib/zerotier-one" \
  --mount "type=bind,src=$data,dst=/app/backend/data" \
  --net=host --device=/dev/net/tun \
  --cap-add=NET_ADMIN --cap-add=SYS_ADMIN \
  -p 4000:4000 \
  -e ZU_DEFAULT_USERNAME=admin \
  -e ZU_DEFAULT_PASSWORD=zero-ui \
  -e ZU_CONTROLLER_ENDPOINT=http://localhost:9993/\
  mcondarelli/zt1-ui
authtoken=$(docker exec -ti zt1 cat /var/lib/zerotier-one/authtoken.secret)

#docker exec -it zt1 curl -H "X-ZT1-Auth:$authtoken" http://127.0.0.1:9993/status
#docker exec -it zt1 curl -H "X-ZT1-Auth:$authtoken" http://127.0.0.1:9993/controller

#docker stop zt1
