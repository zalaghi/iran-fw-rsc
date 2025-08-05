#!/bin/bash

LICENSE_KEY="$MAXMIND_LICENSE_KEY"
COUNTRY_CODE="IR"
TMP_DIR="./tmp"
mkdir -p "$TMP_DIR"
cd "$TMP_DIR" || exit 1
rm -f *.zip *.csv iran_ips.rsc

curl -s -L -o db.zip "https://download.maxmind.com/app/geoip_download?edition_id=GeoLite2-Country-CSV&license_key=${LICENSE_KEY}&suffix=zip"
unzip -q db.zip

DIR=$(find . -type d -name "GeoLite2-Country-CSV*")
IPV4="$DIR/GeoLite2-Country-Blocks-IPv4.csv"
LOC="$DIR/GeoLite2-Country-Locations-en.csv"

IR_ID=$(awk -F, '$5 == "IR" {print $1}' "$LOC" | head -n1)
awk -F, -v id="$IR_ID" '$2 == id {print $1}' "$IPV4" > iran_cidrs.txt

echo "# MikroTik IRAN IP Address List" > iran_ips.rsc
while read -r cidr; do
  echo "/ip firewall address-list add list=IRAN address=$cidr" >> iran_ips.rsc
done < iran_cidrs.txt

mv iran_ips.rsc ../iran.rsc
cd ..
rm -rf tmp
