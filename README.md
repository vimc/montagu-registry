# montagu-registry

## Requirements:

1. [vault](https://github.com/vimc/montagu-vault) must be running and unsealed.  This will run at https://support.montagu.dide.ic.ac.uk:8200 - we'll fetch the SSL certificate's key from here.
2. The `registry_data` volume must exist.  The [restore script](https://github.com/vimc/montagu-backup) will create this for you.  Alternatively if you are starting completely fresh (e.g., testing) then just run `docker volume create registry_data`
3. A password is required to be stored in vault at `/secret/registry/vimc` (do this with `./generate_registry_password.sh`)

## Deployment:

./run.sh

## Login

```
docker login -p $(vault read -field=password /secret/registry/vimc) \
    docker.montagu.dide.ic.ac.uk:5000
```

## Did it work?

```
docker pull postgres
docker tag postgres docker.montagu.dide.ic.ac.uk:5000/postgres
docker push docker.montagu.dide.ic.ac.uk:5000/postgres
docker pull docker.montagu.dide.ic.ac.uk:5000/postgres
```
