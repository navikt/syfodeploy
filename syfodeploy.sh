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

if [ -z "$2" ]; then
    echo "Usage $0 <repository> <branch>"
    exit 1
fi

deploy_payload="{ \"branch\": \"$2\", \"parameters\": { \"deploy_branch\": true } }"

curl -u "$circle_token:" -H "Content-Type: application/json" -d "$deploy_payload" "$circle_host/api/v2/project/gh/navikt/$1/pipeline"

