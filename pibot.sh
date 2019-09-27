#Simple Bash script to pull PiHole API
#and post to Twitter.
#Requires Twurl installed and configured
#to a Twitter development account
#Schedule to run via Cron

#!/bin/bash

# Settings
PIHOLE_IP="192.168.0.8"  # PiHole IP

# Get data from Pi_Hole API
INPUT=$(curl -s "http://$PIHOLE_IP/admin/api.php")
DOMAINSBLOCKED=$(echo "$INPUT" | awk -v FS="(:|,)" '{print $2}')
DNSQUERIESTODAY=$(echo "$INPUT" | awk -v FS="(:|,)" '{print $4}')
ADSBLOCKEDTODAY=$(echo "$INPUT" | awk -v FS="(:|,)" '{print $6}')
ADSPERCENTTODAY=$(echo "$INPUT" | awk -v FS="(:|,)" '{print $8}')
UNIQUEDOMAINS=$(echo "$INPUT" | awk -v FS="(:|,)" '{print $10}')
QUERIESFORWARDED=$(echo "$INPUT" | awk -v FS="(:|,)" '{print $12}')

#Make data more readable
DOMAINSBLOCKED=$(printf "%'d" "$DOMAINSBLOCKED")
DNSQUERIESTODAY=$(printf "%'d" "$DNSQUERIESTODAY")
ADSBLOCKEDTODAY=$(printf "%'d" "$ADSBLOCKEDTODAY")
UNIQUEDOMAINS=$(printf "%'d" "$UNIQUEDOMAINS")
QUERIESFORWARDED=$(printf "%'d" "$QUERIESFORWARDED")
NEWLINE='\n'
STRUpload=("Today, I have blocked $ADSBLOCKEDTODAY advertisments (${ADSPERCENTTODAY%.*}%) and processed $DNSQUERIESTODAY DNS Queries #pihole")
#echo -e $STRUpload
twurl -q -d status="$STRUpload" /1.1/statuses/update.json
#EOF
