#!/bin/bash

readonly NAMESPACE=${1}
readonly JJB_POD=${2}
readonly JENKINS_URL=${3}

readonly TEST_BUILD_NUMBER=${4}

readonly TOTAL_BUILD_NUMBER=29

outputFile=output-jenkins-pod-$JJB_POD-buildCount-$TEST_BUILD_NUMBER-totalBuildCount-$TOTAL_BUILD_NUMBER.$$

G='\033[1;32m'
N='\033[0m'

sleep 10
echo -e "\n****** Wait for 10 sec ******" | tee -a $outputFile

function trigger()
{
  local url
  url=$1
  local job_name
  job_name=$2
  curl -s -k --user admin:password -X POST "https://${url}/job/${job_name}/build" --data-urlencode json='{"parameter": []}'
}

function check_build() {
  local interval
  interval=$1
  local timeout
  timeout=$2
  local start_time
  start_time=$(date +%s)
  local result
  local all_success
  local j
  j=0
  while (( ($(date +%s) - ${start_time}) < ${timeout} ));
  do
    all_success=1
    for i in $(seq ${j} ${TEST_BUILD_NUMBER})
      do
        j=${i}
        ### it is not that straightforward to parse json without jq here
        result=$(curl -s -k --user admin:password https://${JENKINS_URL}/job/test-${i}_job/1/api/json | jq '.result' --raw-output)

        echo "${NAMESPACE}: job ${i}: ${result}" | tee -a $outputFile
        if [[ "${result}" != "SUCCESS" ]]; then
          all_success=0
          if [[ "${result}" = "FAILURE" ]] || [[ "${result}" = "UNSTABLE" ]] || [[ "${result}" = "ABORTED" ]]; then
            NON_SUCCESS_JOB_NUMBER=$((NON_SUCCESS_JOB_NUMBER+1))
            continue
          elif [[ "${result}" != "null" ]]; then
            echo "unknown build results: ${NAMESPACE}: job ${i}: ${result}" | tee -a $outputFile
          fi
          break
        fi
    done
    if (( ${j} == ${TEST_BUILD_NUMBER} )) && ([[ "${result}" = "FAILURE" ]] || [[ "${result}" = "UNSTABLE" ]] || [[ "${result}" = "ABORTED" ]]);
    then
      MY_TIME=$(($(date +%s) - ${start_time}))
      echo "the last job ${j} is FAILURE or UNSTABLE, exiting ..." | tee -a $outputFile
      break
    fi

    if (( ${all_success} == 1 ));
    then
      MY_TIME=$(($(date +%s) - ${start_time}))
      break
    fi

    sleep ${interval}
    echo -e "\n****** Wait for ${interval} sec ******" | tee -a $outputFile
  done
}

readonly TIMEOUT=1800
i_index=1
while true;
do
  echo -e "\n------ Running iteration $i_index ------" | tee -a $outputFile

  ### delete jobs
  echo -e "\n${G}Deleting Jobs from Jenkins${N}"
  echo -e "\n****** Deleting existing Jenkins Jobs ******" >> $outputFile
  (time for j in $(seq 0 ${TOTAL_BUILD_NUMBER}); do oc exec -n ${NAMESPACE} "${JJB_POD}" -- jenkins-jobs delete test-${j}_job; done) 2>&1 |& tee -a $outputFile

  sleep 10
  echo -e "\n****** Wait for 10 sec ******" | tee -a $outputFile

  ### create jobs
  echo -e "\n${G}Creating Jobs from Jenkins${N}"
  echo -e "\n****** Creating new Jenkins Jobs ******" >> $outputFile
  (time oc exec -n ${NAMESPACE} "${JJB_POD}" -- jenkins-jobs --flush-cache  update --delete-old /data) 2>&1 |& tee -a $outputFile

  ### trigger jobs
  echo -e "\n${G}Triggering Jobs on Jenkins${N}"
  echo -e "\n****** Triggering new Jenkins Jobs ******" >> $outputFile
  (time for j in $(seq 0 ${TEST_BUILD_NUMBER}); do trigger "${JENKINS_URL}" "test-${j}_job"; done) 2>&1 |& tee -a $outputFile

  sleep 10
  echo -e "\n****** Wait for 10 sec ******" | tee -a $outputFile

  ### check jobs
  MY_TIME=-1
  NON_SUCCESS_JOB_NUMBER=0
  echo -e "\n${G}Checking for build status${N}"
  echo -e "\n****** Checking Jenkins Jobs build status ******" >> $outputFile
  check_build 10 ${TIMEOUT}

  msg="${NAMESPACE} and iteration ${i_index}: All builds finished in ${MY_TIME} seconds and NON_SUCCESS_JOB_NUMBER is ${NON_SUCCESS_JOB_NUMBER}"
  if (( ${MY_TIME} == -1 )); then
    msg="not finished in ${TIMEOUT} seconds for ${NAMESPACE} and iteration ${i_index}"
  fi
  echo "${msg}" |& tee -a $outputFile

  i_index=`expr $i_index + 1`
done