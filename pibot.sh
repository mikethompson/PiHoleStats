#!/bin/bash
#Simple Bash script to pull PiHole API
#and post to Twitter.
#Requires Twurl installed and configured
#to a Twitter development account
#Schedule to run via Cron
#Michael Thompson 2019
#mikethompson@gmx.co.uk (GPG Key-ID: 062C03D9)

# Settings
PIHOLE_IP="192.168.0.8"  # Your PiHole IP
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/games:/usr/games
MONTH_INFO=1 #Set this to 0 to disable weekly information
dnsdata='/home/pi/Script/piholestats/data_dns_today.txt'
adsdata='/home/pi/Script/piholestats/data_adsblocked_today.txt'

# Get data from Pi_Hole API
INPUT=$(curl -s "http://$PIHOLE_IP/admin/api.php")
DOMAINSBLOCKED=$(echo "$INPUT" | awk -v FS="(:|,)" '{print $2}')
DNSQUERIESTODAY=$(echo "$INPUT" | awk -v FS="(:|,)" '{print $4}')
ADSBLOCKEDTODAY=$(echo "$INPUT" | awk -v FS="(:|,)" '{print $6}')
ADSPERCENTTODAY=$(echo "$INPUT" | awk -v FS="(:|,)" '{print $8}')
UNIQUEDOMAINS=$(echo "$INPUT" | awk -v FS="(:|,)" '{print $10}')
QUERIESFORWARDED=$(echo "$INPUT" | awk -v FS="(:|,)" '{print $12}')
echo $DNSQUERIESTODAY >> $dnsdata
echo $ADSBLOCKEDTODAY >> $adsdata

#Make data more readable
#DOMAINSBLOCKED=$(printf "%'d" "$DOMAINSBLOCKED")
DNSQUERIESTODAY=$(printf "%'d" "$DNSQUERIESTODAY")
ADSBLOCKEDTODAY=$(printf "%'d" "$ADSBLOCKEDTODAY")
#UNIQUEDOMAINS=$(printf "%'d" "$UNIQUEDOMAINS")
#QUERIESFORWARDED=$(printf "%'d" "$QUERIESFORWARDED")
#NEWLINE='\n'
STRUpload="Today, I have blocked $ADSBLOCKEDTODAY advertisments and processed $DNSQUERIESTODAY DNS Queries #pihole"
echo -e $STRUpload
twurl -d status="$STRUpload" /1.1/statuses/update.json

if [ $MONTH_INFO = 1 ]; then

current_date=$(date +'%d')

#find last month day
if [[ $(date -d "+1 day" +%m) != $(date +%m) ]]
then
    echo -e "Today is the last day of the month"

if [ -f "$dnsdata" ]; then
echo -e "DNS Count Files Exists"
 while read p;
do
totalDNS=$(( $totalDNS + $p ))
done < $dnsdata
fi

if [ -f "$adsdata" ]; then
    echo -e "ADS Count File Exists"
 while read p; 
do
totalADS=$(( $totalADS + $p ))
done < $adsdata
fi

totalDNS=$(printf "%'d" "$totalDNS")
totalADS=$(printf "%'d" "$totalADS")

echo -e "DNS Queries for the Month is $totalDNS"
echo -e "Ads Blocked this Month is  $totalADS"

twurl -d  status="This month, I have blocked $totalADS Advertisements and processed $totalDNS DNS Queries" /1.1/statuses/update.json
echo -e "This month, I have blocked $totalADS Advertisements and processed $totalDNS DNS Queries"
rm $adsdata
rm $dnsdata 
fi
  
else
echo -e "Don't Run Monthly"
fi





#EOF
