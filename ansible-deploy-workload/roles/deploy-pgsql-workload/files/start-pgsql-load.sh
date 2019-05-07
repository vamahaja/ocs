#!/bin/bash

### This script is used for run load on pgsql pod
### variables
nameSpace=$1
podName=$2
scaling=$3
clients=$4
threads=$5
transactions=$6

outputFile=output-pgsql-$podName-scaling-$scaling-clients-$clients-threads-$threads-transactions-$transactions.$$

G='\033[1;32m'
N='\033[0m'

### delete database
echo -e "\n${G}Deleting existing database${N}"
echo -e "\n****** Deleting existing database ******" >> $outputFile
(time oc -n $nameSpace exec -i $podName -- bash -c "dropdb sampledb") 2>&1 |& tee -a $outputFile

### create database
echo -e "\n${G}Creating new database${N}"
echo -e "\n****** Creating new database ******" >> $outputFile
(time oc -n $nameSpace exec -i $podName -- bash -c "createdb sampledb") 2>&1 |& tee -a $outputFile

### scale up database
echo -e "\n${G}Scaling up database $scaling times${N}"
echo -e "\n****** Scaling up database $scaling times ******" >> $outputFile
(time oc -n $nameSpace exec -i $podName -- bash -c "pgbench -i -s $scaling sampledb")  2>&1 |& tee -a $outputFile
echo | tee -a $outputFile

i_index=1
while true;
do
    ### run load
    echo -e "\n${G}Running transactions on database${N}"
    echo "------ Running iteration $i_index ------" | tee -a $outputFile
    (time oc -n $nameSpace exec -i $podName -- bash -c "pgbench -c $clients -j $threads -t $transactions sampledb")  2>&1 |& tee -a $outputFile
    echo | tee -a $outputFile
    i_index=`expr $i_index + 1`
done