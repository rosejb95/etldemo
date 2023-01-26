ssh-copy-id -i ~/.ssh/id_rsa.pub dev@localhost
ssh dev@localhost "git config --global user.name $(git config --get user.name)"
ssh dev@localhost "git config --global user.email $(git config --get user.email)"