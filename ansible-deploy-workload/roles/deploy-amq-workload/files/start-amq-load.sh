#!/bin/bash

### This script is used for run workload on amq pod
### variables
nameSpace=$1
podName=$2
messageCount=$3
messageSize=$4
iterations=$5

outputFile=output-amq-$podName-messageCount-$messageCount-messageSize-$messageSize.$$

G='\033[1;32m'
N='\033[0m'

echo | tee -a $outputFile

i_index=1
while true;
do
    echo -e "${G}Running transactions on database${N}"
    echo "------ Running iteration $i_index ------" | tee -a $outputFile

    ### producing messages
    echo "****** Producing Messages ******" | tee -a $outputFile
    (time oc -n $nameSpace exec -i $podName -- bash -c "./broker/bin/artemis producer --message-count=$messageCount --message-size=$messageSize")  2>&1 |& tee -a $outputFile
    echo | tee -a $outputFile

    ### consuming messages
    echo "****** Consuming Messages ******" | tee -a $outputFile
    (time oc -n $nameSpace exec -i $podName -- bash -c "./broker/bin/artemis consumer --message-count=$messageCount")  2>&1 |& tee -a $outputFile
    echo | tee -a $outputFile
    i_index=`expr $i_index + 1`
done
