#!/bin/bash

# env
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source "$DIR/.env"

echo "---------------------------------"
date +%d-%m-%y/%H:%M:%S

# get current IP
echo "Fetching current IP..."
IP=$(curl https://api.ipify.org/)
echo "IP is currently: $IP"
if [[ ! $IP =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
  exit 1
fi

for NAME
do
	echo "Processing $NAME"
	echo "Fetching current record..."
	JSON=$($AWS_CLI route53 list-resource-record-sets --hosted-zone-id $ZONE_ID)
	echo $JSON | jq '.ResourceRecordSets[] | select (.Name == "'"$NAME"'") | select (.Type == "'"$TYPE"'") | .ResourceRecords[0].Value' > /tmp/current_route53_value

	echo "Route53 IP IS `cat /tmp/current_route53_value`"
	if grep -Fq "$IP" /tmp/current_route53_value 
	then
	   echo "IP Has Not Changed"
	   continue
	fi

	echo "Updating ip..." 
	cat > /tmp/route53_changes.json << EOF
	    {
	      "Comment":"Updated From DDNS Shell Script",
	      "Changes":[
		{
		  "Action":"UPSERT",
		  "ResourceRecordSet":{
		    "ResourceRecords":[
		      {
			"Value":"$IP"
		      }
		    ],
		    "Name":"$NAME",
		    "Type":"$TYPE",
		    "TTL":$TTL
		  }
		}
	      ]
	    }
EOF

	#update records
	$AWS_CLI route53 change-resource-record-sets --hosted-zone-id $ZONE_ID --change-batch file:///tmp/route53_changes.json 
done
echo "---------------------------------"
