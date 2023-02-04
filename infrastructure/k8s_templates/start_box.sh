config_temp_file=$(mktemp)
manifest_temp_file=$(mktemp)
script_dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

echo "
podName: $1
branch: $2
">$config_temp_file

# Generate completed manifest.
j2 --format=yaml "$script_dir/bdb_box_template.yml" $config_temp_file >$manifest_temp_file

# Start the box -- TODO: check failure behavior.
kubectl apply -f $manifest_temp_file
kubectl wait -f $manifest_temp_file --for=condition=ready --timeout=300s

#Start port-forwarding in background.
kubectl port-forward pod/$1 22:22