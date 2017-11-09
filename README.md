# montagu-registry

## Requirements:

1. [vault](https://github.com/vimc/montagu-vault) must be running and unsealed.  This will run at https://support.montagu.dide.ic.ac.uk:8200 - we'll fetch the SSL certificate's key from here.
2. The `registry_data` volume must exist.  The [restore script](https://github.com/vimc/montagu-backup) will create this for you.  Alternatively if you are starting completely fresh (e.g., testing) then just run `docker volume create registry_data`

## Deployment:

./run.sh

## Did it work?

```
docker pull postgres
docker tag postgres docker.montagu.dide.ic.ac.uk:5000/postgres
docker push docker.montagu.dide.ic.ac.uk:5000/postgres
docker pull docker.montagu.dide.ic.ac.uk:5000/postgres
```
