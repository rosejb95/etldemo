config_temp_file=$(mktemp)
manifest_temp_file=$(mktemp)
script_dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

echo "
podName: $1
branch: $2
">$config_temp_file

# Generate completed manifest.
j2 --format=yaml "$script_dir/bdb_box_template.j2" $config_temp_file >$manifest_temp_file

# Start the box -- TODO: check failure behavior.
kubectl apply -f $manifest_temp_file
kubectl wait -f $manifest_temp_file --for=condition=ready

#Start port-forwarding in background.
kubectl port-forward pod/$1 22:22 &

#Setup user details.
ssh-copy-id -i ~/.ssh/id_rsa.pub dev@localhost
ssh dev@localhost "git config --global user.name $(git config --get user.name)"
ssh dev@localhost "git config --global user.email $(git config --get user.email)"

# Resume port-forwarding
fg