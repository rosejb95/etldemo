#!/bin/bash
script_dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )


for c in {a..z}
do
  tmp_config_file=$(mktemp)

  echo "Running job $1"

  echo "
  job_name: \"test-job-$c\"
  branch_name: \"main\"
  job_command: \"echo $c,$(date +%F_%T),$(date +%s) >> '/mnt/etlshare/repeat_job_test.txt'\"
  " >$tmp_config_file

  (source "$script_dir/run_manifest_as_job.sh" "$tmp_config_file") &
done
