
MONGO_URL=mongodb://${MONGO_INITDB_ROOT_USERNAME}:${MONGO_INITDB_ROOT_PASSWORD}@127.0.0.1:27017/${MONGODB_DATABASE}?authSource=admin

for load in $(echo ${YCSB_WORKLOADS} | sed -e s/,/" "/g); do 
    mongo $MONGO_URL --eval 'db.usertable.remove({})'; 

    /ycsb/bin/ycsb load mongodb -s -threads ${YCSB_THREADCOUNT} \
        -P "/ycsb/workloads/${load}" \
        -p mongodb.url=$MONGO_URL \
        -p recordcount=${YCSB_RECORDCOUNT} \
        -p operationcount=${YCSB_OPERATIONCOUNT};

    /ycsb/bin/ycsb run mongodb -s -threads ${YCSB_THREADCOUNT} \
        -P "/ycsb/workloads/${load}" \
        -p mongodb.url=$MONGO_URL \
        -p recordcount=${YCSB_RECORDCOUNT} \
        -p operationcount=${YCSB_OPERATIONCOUNT}; 
done;

