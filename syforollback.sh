#!/bin/bash

subcommand=$1
repository=$2

credentials=$(printf 'host=github.com\nprotocol=https\n' | git credential-`git config credential.helper` get)
username=$(printf "$credentials" | grep username | cut -b 10-)
password=$(printf "$credentials" | grep password | cut -b 10-)

get_deployments() {
    repository=$(echo $1 | jq --raw-input)
    cluster=$2
    if [ ! -z "$cluster" ]; then
        cluster=`echo $cluster | jq --raw-input`;
    fi
    query='
        query($cluster: [String!], $repository: String!) { 
        repository(owner: "navikt", name: $repository) { 
            deployments(environments: $cluster, last: 50) {
                nodes {
                    databaseId
                    payload
                    description
                    updatedAt
                    environment
                    ref {
                        name
                    }
                    commitOid
                    commit {
                        author {
                            name
                            date
                        }
                        message
                    }
                    latestStatus {
                        state
                    }
                }
            }
        }
    }'
    quoted_query=`echo "$query" | jq --raw-input --slurp`
    payload="{\"query\": $quoted_query, \"variables\": {\"cluster\": [$cluster], \"repository\": $repository}}"
    response=`curl --silent -u "$username:$password" -d "$payload" https://api.github.com/graphql`
    echo "$response" | jq '.data.repository.deployments.nodes'
}

cmd_list() {
    repository=$1
    cluster=$2
    deployments=$(get_deployments $repository $cluster)
    printf "ID\t\tDeployed at\t\tBranch\tStatus\t\tCommit\tCluster\n"
    echo "$deployments" | jq -r '.[] | select(.latestStatus.state == "INACTIVE" or .latestStatus.state == "SUCCESS") | "\(.databaseId)\t\(.updatedAt)\t\(.ref.name)\t\(.latestStatus.state)  \t\(.commitOid)\t\(.environment)\n\(.commit.message)\n======================"'
}

cmd_extract() {
    repository=$1
    id=$2
    deployments=$(get_deployments $repository)
    echo "$deployments" | jq ".[] | select(.databaseId == $id) | .payload | fromjson | fromjson | .kubernetes.resources | .[]"
}

case $subcommand in
    "list")
        cmd_list $2 $3
    ;;
    "extract")
        cmd_extract $2 $3
    ;;
esac
