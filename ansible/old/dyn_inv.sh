#! /bin/bash

usage() { echo "Usage of $0: [--list <path_to_inventory.json>] [--host <string>]" 1>&2; exit 1; }

TEMP=`getopt -o l::h: --long list::,host: -- "$@"`
eval set -- "$TEMP"

while true ; do
    case "$1" in
        -l|--list)
            case "$2" in
                "") INV_PATH=./inventory.json && /bin/cat $INV_PATH || usage ; shift 2 ;;
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
