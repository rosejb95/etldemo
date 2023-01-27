#!/bin/bash
[ "$#" -eq 1 ] || { echo >&2 "1 argument required, $# provided"; exit 1; }


# Write template to tmp file to pass to k8s cluster.
tmp_file=$(mktemp)
j2 -f yaml test.j2 $1 >$tmp_file || { echo "job template application failed"; exit 1; }

job_name=$(kubectl apply -f $tmp_file -o name)

# wait for completion as background process - capture PID
kubectl wait --for=condition=complete $job_name &
completion_pid=$!

# wait for failure as background process - capture PID
kubectl wait --for=condition=failed $job_name && exit 1 &
failure_pid=$! 

# capture exit code of the first subprocess to exit
wait -n $completion_pid $failure_pid

# store exit code in variable
exit_code=$?

if (( $exit_code == 0 )); then
  echo "Job completed"
else
  echo "Job failed with exit code ${exit_code}, exiting..."
fi

exit $exit_code