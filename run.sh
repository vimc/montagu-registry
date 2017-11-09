#!/usr/bin/env bash

REGISTRY_PORT=5000
REGISTRY_CONTAINER=registry
REGISTRY_VOLUME_NAME=registry_data
REGISTRY_DOMAIN=docker.support.montagu.dide.ic.ac.uk

## These should not be changed
VAULT_ADDR=https://support.montagu.dide.ic.ac.uk:8200
PATH_CRT=certs/domain.crt
PATH_KEY=certs/domain.key

RUNNING=$(docker inspect --format="{{.State.Running}}" $REGISTRY_CONTAINER 2> \
                 /dev/null)

if [[ "$RUNNING" == "true" ]]; then
    echo "Registry already running"
    exit 0
fi

cat certs/${REGISTRY_DOMAIN}.crt \
    certs/QuoVadisOVIntermediateCertificate.crt > \
    ${PATH_CRT}

if [ ! -f $PATH_KEY ]; then
    echo "Reading ssl key"
    vault auth -method=github
    vault read -field=key /secret/ssl/registry > $PATH_KEY
    chmod 600 $PATH_KEY
fi

docker volume inspect $REGISTRY_VOLUME_NAME 2> /dev/null > /dev/null
VOLUME_EXISTS=$?
if [ $VOLUME_EXISTS -eq 0 ]; then
    echo "Found docker volume"
else
    echo "The docker volume $REGISTRY_VOLUME_NAME must exist"
    exit 1
fi

echo "Starting docker registry"
docker run \
       --name $REGISTRY_CONTAINER \
       -d --restart=always \
       -p ${REGISTRY_PORT}:5000 \
       -v `pwd`/certs:/certs \
       -v $REGISTRY_VOLUME_NAME:/var/lib/registry \
       -e REGISTRY_HTTP_TLS_CERTIFICATE=/$PATH_CRT \
       -e REGISTRY_HTTP_TLS_KEY=/$PATH_KEY \
       registry:2
exit $?
