#! /bin/bash
if [ "$1" = "--list" ] ; then
gcloud --format="value(name,networkInterfaces[0].accessConfigs[0].natIP)" compute instances list \
| awk 'BEGIN{print "{\"_meta\": {\n\"hostvars\": {"} {print "\""$1"\": {\"ansible_host\":\""$2"\"},"} END{print "}},"}' \
&& \
gcloud --format="value(name,tags.items[0])" compute instances list \
| awk '{print "\""$2"\": {\"hosts\": [\""$1"\"] },"}  END{print "}"}'
fi
