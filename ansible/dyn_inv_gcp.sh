#! /bin/bash

usage() { echo "Usage of $0: [--list <path_to_inventory.json>] [--host <string>]" 1>&2; exit 1; }

TEMP=`getopt -o l::h: --long list::,host: -- "$@"`
eval set -- "$TEMP"

while true ; do
    case "$1" in
        -l|--list)
            case "$2" in
                "") gcloud --format="value(name,networkInterfaces[0].accessConfigs[0].natIP)" compute instances list \
                    | awk 'BEGIN{print "{\"_meta\": {\n\"hostvars\": {"} {print "\""$1"\": {\"ansible_host\":\""$2"\"},"} END{print "}},"}' \
                    && \
                    gcloud --format="value(name,tags.items[0])" compute instances list \
                    | awk '{print "\""$2"\": {\"hosts\": [\""$1"\"] },"}  END{print "}"}' || usage ; shift 2 ;;
                *) PATH=$2 && /bin/cat $PATH || usage ; shift 2 ;;
            esac ;;
        -h|--host)
            case "$2" in
                *) echo '{}' || usage ; shift 2 ;;
            esac ;;
        --) shift ; break ;;
        *) usage ; exit 1 ;;
    esac
done
