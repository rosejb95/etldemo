#!/bin/bash

# TODO: Make options required.
while getopts :n:b:c: flag;
do
    case "${flag}" in
        n) POD_NAME="$OPTARG";;
        b) BRANCH_NAME="$OPTARG";;
        c) GIT_CREDS="$OPTARG";;
        *) echo "Invalid option -$OPTARG" >&2
        exit 1
        ;;
    esac
done

#  Script is located in the helm chart directory.
HELM_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# Also using POD_NAME for the value of the helm deployment.
helm install $POD_NAME "$HELM_DIR" --set podName=$POD_NAME,branch=$BRANCH_NAME,gitCreds=${GIT_CREDS} --wait

kubectl port-forward $POD_NAME 22:22