ssh-copy-id -i ~/.ssh/id_rsa.pub dev@localhost
ssh dev@localhost "git config --global user.name $(git config --get user.name)"
ssh dev@localhost "git config --global user.email $(git config --get user.email)"
ssh dev@localhost 'cd ~/repo && git config --global --add safe.directory ~/repo && git remote set-url origin git@github.com:rosejb95/etldemo.git'
