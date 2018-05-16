#! /bin/bash
#Basic Ansible dynamic inventory script for GCP
#Script requires gcloud auth plugin and default project be configured 

usage() { echo "Usage of $0: [--list <path_to_inventory.json>] [--host <string>]" 1>&2; exit 1; }

instaces_to_ansible_json ()
{
    gcloud compute instances list --format="value(name,networkInterfaces[0].accessConfigs[0].natIP)" \
    | awk 'BEGIN{print "{\"_meta\": {\n\"hostvars\": {"} {print "\""$1"\": {\"ansible_host\":\""$2"\"},"} END{print "}},"}' \
    
    for tag in $(gcloud compute instances list --format='value(tags.items[0])')
    do
        filter="tags.items=${tag}"
        gcloud compute instances list --format="value(name,tags.items[0])" --filter=$filter \
        | awk '{print "\""$2"\": {\"hosts\": [\""$1"\"] },"}'
    done

    echo "}"
}

TEMP=`getopt -o l::h: --long list::,host: -- "$@"`
eval set -- "$TEMP"

while true ; do
    case "$1" in
        -l|--list)
            case "$2" in
                "") instaces_to_ansible_json || usage ; shift 2 ;;
                *) INV_PATH=$2 && /bin/cat $INV_PATH || usage ; shift 2 ;;
            esac ;;
        -h|--host)
            case "$2" in
                *) echo '{}' || usage ; shift 2 ;;
            esac ;;
        --) shift ; break ;;
        *) usage ; exit 1 ;;
    esac
done
