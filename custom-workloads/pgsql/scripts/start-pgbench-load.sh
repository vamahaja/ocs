
while true; do 
    createdb ${PGBENCH_DATABASE}
    
    pgbench -i -s ${PGBENCH_SCALINGCOUNT} ${PGBENCH_DATABASE}
    
    pgbench ${PGBENCH_DATABASE} \
        -c ${PGBENCH_CLIENTGCOUNT} \
        -j ${PGBENCH_THREADCOUNT} \
        -t ${PGBENCH_TRANSACTIONSCOUNT}

    dropdb ${PGBENCH_DATABASE}
done
