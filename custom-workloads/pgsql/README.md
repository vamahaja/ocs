
# PostgreSQL with PGBench workloads
This repo contains `Dockerfile`, workload scripts and template to create and deploy PostgreSQL and start PGBench workloads. 

## How to build docker image using Dockerfile
- Build image by executing below command from the directory with `Dockerfile`
    ```
    $ docker build -t <image-name>:<image-tag> .
    ```
- Save docker image on local disk
    ```
    $ docker save --output postgresql-pgbench-workload.tar.gz <image-name>:<image-tag>
    ```
- Copy tar.gz file and load docker image on all the Openshift nodes
    ```
    $ docker load --input postgresql-pgbench-workload.tar.gz
    ```

## How to deploy PostgreSQL pod and start workload
- Create postgresql template with parameters and deploy resources
    ```
    $ oc process -f templates/postgresql-pgbench-template.yml POSTGRESQL_SERVICE_NAME=<postgresql-service-name> POSTGRESQL_PVC_NAME=<postgresql-pvc-name> STORAGE_CLASS_NAME=<storage-name> POSTGRESQL_IMAGE=<image-name>:<image-tag> | oc create -f -
    ```

- Get postgresql pod name
    ```
    $ oc get pods --no-headers -o=custom-columns=:.metadata.name --selector deploymentconfig=<postgresql-service-name>
    ```

- Start executing worklod on pod
    ```
    $ oc exec -t <postgresql-pod-name> -- bash -c "sh ./start-pgbench-load.sh >> /var/lib/pgsql/data/pgbench-workloads.log 2>&1 &"
    ```