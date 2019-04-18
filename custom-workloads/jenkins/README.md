
# Jenkins with JJB workloads
This repo contains `Dockerfile`, workload scripts and template to create and deploy Jenkins with JJB workload. 

## How to build docker image using Dockerfile
- Build image by executing below command from the directory with `Dockerfile`
    ```
    $ docker build -t <image-name>:<image-tag> .
    ```
- Save docker image on local disk
    ```
    $ docker save --output jenkins-jjb-workload.tar.gz <image-name>:<image-tag>
    ```
- Copy tar.gz file and load docker image on all the Openshift nodes
    ```
    $ docker load --input jenkins-jjb-workload.tar.gz
    ```

## How to deploy Jenkins pod and start workload
- Create jenkins template with parameters and deploy resources
    ```
    $ oc process -f templates/jenkins-jjb-template.yml JENKINS_SERVICE_NAME=<jenkins-service-name> JENKINS_PVC_NAME=<jenkins-pvc-name> STORAGE_CLASS_NAME=<storage-name> JENKINS_IMAGE=<image-name>:<image-tag> | oc create -f -
    ```

- Get port number from service name 
    ```
    $ oc get service <jenkins-service-name> --no-headers -o=custom-columns=:.spec.ports[0].nodePort
    ```

- Set executors count on jenkins to execute jobs parallely
    ```
    $ curl -k --data-urlencode "script=$(cat groovy/jenkins_set_no_of_executor.groovy)" -X POST "http://<master-host-name>:<port-number>/scriptText"
    ```

- Get jenkins pod name
    ```
    $ oc get pods --no-headers -o=custom-columns=:.metadata.name --selector deploymentconfig=<jenkins-service-name>
    ```

- Start executing worklod on pod
    ```
    $ oc exec -t <jenkins-pod-name> -- bash -c "sh ./start-jenkins-load.sh >> jenkins-workloads.log 2>&1 &"
    ```