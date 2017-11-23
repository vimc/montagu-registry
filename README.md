# montagu-registry

## Login

Login has no expiry, so just needs running once

```
docker login -u vimc docker.montagu.dide.ic.ac.uk:5000
```

With the password from

```
vault read -field=password /secret/registry/vimc
```

which can be done all in one with

```
vault read -field=password /secret/registry/vimc | \
    docker login -u vimc --password-stdin docker.montagu.dide.ic.ac.uk:5000
```

### Deployment and maintenance

## Requirements:

1. [vault](https://github.com/vimc/montagu-vault) must be running and unsealed.  This will run at https://support.montagu.dide.ic.ac.uk:8200 - we'll fetch the SSL certificate's key from here.
2. The `registry_data` volume must exist.  The [restore script](https://github.com/vimc/montagu-backup) will create this for you.  Alternatively if you are starting completely fresh (e.g., testing) then just run `docker volume create registry_data`
3. A password is required to be stored in vault at `/secret/registry/vimc` (do this with `./generate_registry_password.sh`)
4. Some Python packages; install with `pip3 install --user -r requirements.txt`

## Deployment:

From within this directory, run:

```
./montagu-registry start
```

The script will pull the ssl certificate and password from the vault.  If you update either then relaunch the registry and the changes will take effect.

## Garbage collection:

This will take down the registry while it runs, then restore the registry

```
./montagu-registry gc
```

## Stopping the registry:

```
./montagu-registry stop
```

## Cleanup

```
./montagu-registry cleanup
```

Note that cleanup does not automatically do garbage collection (because cleanup does not require taking the registry offline but garbage collection does).  According to some reports the registry will automatically garbage collect (e.g., overnight) but I'm not sure this will definitely happen.

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

They'll email back a zip file with files

* `QuoVadisOVIntermediateCertificate.crt`
* `QuoVadisOVRootCertificate.crt`
* `docker.montagu.dide.ic.ac.uk.crt`

along with the csr as provided.  Copy these into the `cert/` directory, overwriting as needed.

Write the key into the vault

```
vault write /secret/ssl/registry key=@data.key
```

Redeploy the vaule

Previous requests were logged with

* SR0468436
* SR0513015 (VIMC-969)
