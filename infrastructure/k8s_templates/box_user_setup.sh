#Setup user details.
ssh-copy-id -i ~/.ssh/id_rsa.pub dev@localhost
ssh dev@localhost "git config --global user.name $(git config --get user.name)"
ssh dev@localhost "git config --global user.email $(git config --get user.email)"
ssh dev@localhost "az login --use-device-code"
ssh dev@localhost "az aks get-credentials --admin --name benton-k8-cluster --resource-group etl"
