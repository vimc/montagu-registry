#!/usr/bin/env bash
VAULT_ADDR=https://support.montagu.dide.ic.ac.uk:8200

REGISTRY_NAME=registry
REGISTRY_VOLUME_NAME=registry_data
RUNNING=$(docker inspect --format="{{.State.Running}}" $REGISTRY_NAME 2> \
                 /dev/null)
PATH_CRT=certs/domain.crt
PATH_KEY=certs/domain.key


if [[ "$RUNNING" == "true" ]]; then
    echo "Registry already running"
    exit 0
fi

docker volume inspect $REGISTRY_VOLUME_NAME 2> /dev/null > /dev/null
VOLUME_EXISTS=$?
if [ $VOLUME_EXISTS -eq 0 ]; then
    echo "Found docker volume"
else
    echo "The docker volume $REGISTRY_VOLUME_NAME must exist"
    exit 1
fi

if [ ! -f $PATH_KEY ]; then
    echo "Reading ssl key"
    vault auth -method-github
    vault read -field /secret/ssl/registry > $PATH_KEY
    chmod 600 $PATH_KEY
fi

echo "Starting docker registry"
docker run -d -p 5000:5000 --restart=always --name registry \
       -v `pwd`/certs:/certs \
       -v $REGISTRY_VOLUME_NAME:/var/lib/registry \
       -e REGISTRY_HTTP_TLS_CERTIFICATE=$PATH_CRT \
       -e REGISTRY_HTTP_TLS_KEY=$PATH_KEY \
       registry:2
exit $?
