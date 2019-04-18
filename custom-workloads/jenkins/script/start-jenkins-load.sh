
TIMESTAMP="date +%Y-%m-%d-%H:%M:%S"

echo [`$TIMESTAMP`] "Generare projects.yaml file"
for job_id in `seq 1 $EXECUTORS`; do
  echo "      - '{name}-job':" >> jobs/projects.yaml 
  echo "          name: jenkins-workload-$job_id" >> jobs/projects.yaml 
done

echo "Create jenkins jobs"
/root/.local/bin/jenkins-jobs --flush-cache \
                                --conf jenkins_jobs.ini \
                                update --delete-old \
                                jobs/

url="http://127.0.0.1:8080/job"
while true; do
  echo [`$TIMESTAMP`] "Start job scheduling"

  for job_id in `seq 1 $EXECUTORS`; do
    job_name=jenkins-workload-$job_id-job
    echo [`$TIMESTAMP`] "Job Name: $job_name"

    result=$(curl -s -k $url/$job_name/lastBuild/api/json | jq '.result' --raw-output)
    if [ $? -eq 0 ]; then
      if [ "${result}" = "null" ]; then
        echo [`$TIMESTAMP`] "Job $job_name still in execution"
        continue
      fi
    fi

    echo [`$TIMESTAMP`] "Job $job_name completed, re-executing"
    curl -k --data-urlencode json='{"parameter": []}' -X POST $url/$job_name/build
  done

  sleep 10
done

