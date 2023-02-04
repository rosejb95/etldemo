#!/bin/bash
# Arg is the config file name.
[ "$#" -eq 1 ] || { echo >&2 "1 argument for the name of the file to execute required, $# provided"; exit 1; }

script_dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# Write template to tmp file to pass to k8s cluster.
tmp_file=$(mktemp)

j2 -f yaml "$script_dir/bdb_job_template.yml" "$1" >$tmp_file || { echo "job template application failed"; exit 1; }

job_name=$(kubectl apply -f $tmp_file -o name)

# wait for completion as background process - capture PID
kubectl wait --for=condition=complete $job_name && echo "Job complete" && exit 0 &

# wait for failure as background process
kubectl wait --for=condition=failed $job_name && echo "Job Failed" && exit 1 &