#!/usr/bin/env bash

set -x

REGISTRY_PORT=5001
REGISTRY_CONTAINER=registry2
REGISTRY_VOLUME_NAME=registry_data2
REGISTRY_DOMAIN=docker.support.montagu.dide.ic.ac.uk

## These should not be changed
VAULT_ADDR=https://support.montagu.dide.ic.ac.uk:8200
PATH_CRT=certs/domain.crt
PATH_KEY=certs/domain.key
PATH_AUTH=auth/htpasswd

RUNNING=$(docker inspect --format="{{.State.Running}}" $REGISTRY_CONTAINER 2> \
                 /dev/null)

REGISTRY_USER=vimc

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

set -e

export VAULT_ADDR='https://support.montagu.dide.ic.ac.uk:8200'
if [ -z $VAULT_AUTH_GITHUB_TOKEN ]; then
    echo -n "Paste your github token: "
    read -s VAULT_AUTH_GITHUB_TOKEN
fi
export VAULT_AUTH_GITHUB_TOKEN

if [ ! -f $PATH_CRT ]; then
    cat certs/${REGISTRY_DOMAIN}.crt \
        certs/QuoVadisOVIntermediateCertificate.crt > \
        ${PATH_CRT}
fi

if [ ! -f $PATH_KEY ]; then
    echo "Reading ssl key"
    vault auth -method=github
    vault read -field=key /secret/ssl/registry > $PATH_KEY
    chmod 600 $PATH_KEY
fi

if [ ! -f $PATH_AUTH ]; then
    echo "Setting up password for registry user ${REGISTRY_USER}"
    REGISTRY_PASSWORD=$(vault read -field=password /secret/registry/${REGISTRY_USER})
    mkdir -p auth
    docker run --rm --entrypoint htpasswd registry:2 \
           -Bbn $REGISTRY_USER $REGISTRY_PASSWORD > $PATH_AUTH
fi

echo "Starting docker registry"
docker run \
       --name $REGISTRY_CONTAINER \
       -d --restart=always \
       -p ${REGISTRY_PORT}:5000 \
       -v $REGISTRY_VOLUME_NAME:/var/lib/registry \
       -v `pwd`/certs:/certs \
       -e REGISTRY_HTTP_TLS_CERTIFICATE=/$PATH_CRT \
       -e REGISTRY_HTTP_TLS_KEY=/$PATH_KEY \
       -v `pwd`/auth:/auth \
       -e REGISTRY_AUTH=htpasswd \
       -e REGISTRY_AUTH_HTPASSWD_REALM="Registry Realm" \
       -e REGISTRY_AUTH_HTPASSWD_PATH=/$PATH_AUTH \
       registry:2
exit $?
