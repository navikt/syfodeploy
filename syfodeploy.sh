#!/bin/bash

config_path=$HOME/.circleci

if [ ! -d "$config_path" ]; then
    mkdir -p "$config_path"
fi

config_file=$config_path/cli.yml

if [ ! -f "$config_file" ]; then
    echo "Configuration file not found, generating a new one"
    echo "To generate a new API token visit: https://circleci.com/account/api"
    printf "Please enter circleci token: "
    read -s circle_token
    echo
    cat << EOF > $config_file
host: https://circleci.com
endpoint: graphql-unstable
token: $circle_token
EOF
fi

circle_token=$(cat $config_file | grep "token:" | cut -b 8-)
circle_host=$(cat $config_file | grep "host:" | cut -b 7-)

project=$1
branch=$2

if [ "$project" == "git-context" ]; then
    base_ref=$(basename `git config --get remote.origin.url`)
    project="${base_ref%.*}"
    branch=$(git rev-parse --abbrev-ref HEAD)
fi

if [ -z "$branch" ]; then
    echo "Deploy a specific branch for a repository: $0 <repository> <branch>"
    echo "Deploy using the current git context: $0 git-context"
    exit 1
fi

deploy_payload="{ \"branch\": \"$branch\", \"parameters\": { \"deploy_branch\": true } }"

curl -u "$circle_token:" -H "Content-Type: application/json" -d "$deploy_payload" "$circle_host/api/v2/project/gh/navikt/$project/pipeline"

