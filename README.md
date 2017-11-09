# montagu-registry

## Requirements:

1. [vault](https://github.com/vimc/montagu-vault) must be running and unsealed.  This will run at https://support.montagu.dide.ic.ac.uk:8200 - we'll fetch the SSL certificate's key from here.
2. The `registry_data` volume must exist.  The [restore script](https://github.com/vimc/montagu-backup) will create this for you.  Alternatively if you are starting completely fresh (e.g., testing) then just run `docker volume create registry_data`
3. A password is required to be stored in vault at `/secret/registry/vimc` (do this with `./generate_registry_password.sh`)

## Deployment:

From within this directory, run:

```
./run.sh
```

The script will pull the ssl certificate and password from the vault.  If you update either then relaunch the registry and the changes will take effect.

## Login

Login has no expiry, so just needs running once

```
docker login -u vimc docker.montagu.dide.ic.ac.uk:5000
```

With the password from

```
vault read -field=password /secret/registry/vimc
```

## Did it work?

```
docker pull postgres
docker tag postgres docker.montagu.dide.ic.ac.uk:5000/postgres
docker push docker.montagu.dide.ic.ac.uk:5000/postgres
docker pull docker.montagu.dide.ic.ac.uk:5000/postgres
```

## Requesting a new tls certificate

```
vault write secret/registry/challenge password=$(pwgen 20 1)
```

Then run

```
openssl genrsa -out data.key 2048
openssl req -new -sha256 -key data.key -out cert.csr
```

With answers:

* `Country Name`: GB
* `State or Province Name`: London
* `Locality Name`: London
* `Organization Name`: Imperial College, London
* `Organizational Unit Name`: Dept of Infectious Disease Epidemiology
* `Common Name`: docker.montagu.dide.ic.ac.uk
* `Email Address`: dide-it@imperial.ac.uk
* `Challenge Password`: `vault read -field=password secret/registry/challenge`
* `Optional company name`: (leave blank)

Then file a request with imperial ICT at https://imperial.service-now.com/requests.do

Previous requests were logged with

* SR0468436
* SR0513015 (VIMC-969)
