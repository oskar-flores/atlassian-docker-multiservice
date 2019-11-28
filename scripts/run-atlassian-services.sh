#!/usr/bin/env bash
#-e  Exit immediately if a command exits with a non-zero status.
set -e

function usage
{
    local scriptName=$(basename "$0")
    echo "usage: ${scriptName} x.y.z ENV=VALUE ENV2=VALUE"
    echo "   ";
    echo " Set configuration parameters one after another to personalize the docker container";
    echo " example ${scriptName} 6.1.0 DEBUG_PORT=5006 will set the Confluence version to 6.1.0 opening the 5006 port for debugging";
    echo " If no parameters are set , .env file parameters will be set ";
    echo "   ";
    echo "  -h | --help                   : This message";
}


function parse_args
{
    # positional args
    args=()
    
    # named args
    while [ "$1" != "" ]; do
        case "$1" in
            -c | --confluence-version ) CONFLUENCE_RUN_VERSION="$2"; shift;;
            -j | --jira-version ) JIRA_RUN_VERSION="$2";             shift;;
            -s | --services ) RUN_SERVICES="$2";                     shift;;
            -h | --help )    usage;                                 exit;; # quit and show usage
            * )              args+=("$1")                                # if no match, add it to the positional args
        esac
        shift # move to next kv pair
    done
    echo "Runing Services ${RUN_SERVICES}"
    echo "Runing with Confluence version ${CONFLUENCE_RUN_VERSION}"
    echo "Runing with jira version ${JIRA_RUN_VERSION}"
    # restore positional args
    set -- "${args[@]}"   
}

parse_args "$@"
# Set current folder to parent
cd "$(dirname "$0")"/..

#load default env varibles
set -o allexport
[[ -f .env ]] && source .env
set +o allexport

if [[ ! -z "${CONFLUENCE_RUN_VERSION}" ]]
then
    export "CONFLUENCE_VERSION=${CONFLUENCE_RUN_VERSION}"
fi

if [[ ! -z "${JIRA_RUN_VERSION}" ]]
then
    export "JIRA_VERSION=${JIRA_RUN_VERSION}"
fi

if [[ ! -z "${RUN_SERVICES}" ]]
then
    export "SERVICES=${RUN_SERVICES}"
fi


for env_variable in ${args}
do
    echo ${env_variable}
    export ${env_variable}
    echo "set environment variable -> ${env_variable}"
done

if [[ ! -z "${SERVICES}" ]]
then
    IFS=',' read -r -a SERVICES_LIST <<< ${SERVICES}
    export $SERVICES_LIST
fi

echo "Starting ${SERVICES_LIST[@]} $CONFLUENCE_VERSION"
echo "---------------------------------"

docker-compose up -d ${DATABASE} ldap "${SERVICES_LIST[@]}"
