
# MongoDb with YCSB workloads
This repo contains `Dockerfile`, workload scripts and template to create and deploy MongoDb with YCSB workload. 

## How to build docker image using Dockerfile
- Build image by executing below command from the directory with `Dockerfile`
    ```
    $ docker build -t <image-name>:<image-tag> .
    ```
- Save docker image on local disk
    ```
    $ docker save --output mongo-ycsb-workload.tar.gz <image-name>:<image-tag>
    ```
- Copy tar.gz file and load docker image on all the Openshift nodes
    ```
    $ docker load --input mongo-ycsb-workload.tar.gz
    ```

## How to deploy MongoDb pod and start workload
- Create mongo template with parameters and deploy resources
    ```
    $ oc process -f templates/mongo-ycsb-template.yml MONGO_SERVICE_NAME=<mongo-service-name> MONGO_PVC_NAME=<mongo-pvc-name> STORAGE_CLASS_NAME=<storage-name> MONGO_IMAGE=<image-name>:<image-tag> | oc create -f -
    ```

- Get port number from service name 
    ```
    $ oc get service <mongo-service-name> --no-headers -o=custom-columns=:.spec.ports[0].nodePort
    ```

- Get mongo pod name
    ```
    $ oc get pods --no-headers -o=custom-columns=:.metadata.name --selector deploymentconfig=<mongo-service-name>
    ```

- Start executing worklod on pod
    ```
    $ oc exec -t <mongo-pod-name> -- bash -c "sh ./start-ycsb-load.sh >> /data/db/ycsb-workloads.log 2>&1 &"
    ```