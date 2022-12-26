# Introduction 
This project contains a basic set of instratructure for remote development of ETL/ELT pipelines using Python and DBT.

The current primary use case is for small-medium sized datasets which can be reasonably processed on a single node.
As the relative cost of container startup is small compared to memory and compute intensive ETL jobs,
developement and deployemnts are performed using the same image to reduce the risk of breaking changes across environments.

# Local requirements for using the development environment
Develoeprs using the environment require the following tools-
* VSCode with the remote-development extension.
* Git
* Git-bash for Windows: https://gitforwindows.org/
* SSH
* kubectl: https://kubernetes.io/docs/reference/kubectl/
* helm: https://helm.sh/docs/intro/install/
