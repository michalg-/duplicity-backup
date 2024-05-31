#!/bin/sh

#B2_ACCOUNT_ID=$B2_ACCOUNT_ID
#B2_APPLICATION_KEY=$B2_APPLICATION_KEY
#PASSPHRASE=$PASSPHRASE
#B2_BUCKET_NAME=your-bucket-name
#SRC=/source
#HA_TOKEN=token
#HA_URL=http://192.168.68.116:8123

B2_BUCKET_URL=b2://$B2_ACCOUNT_ID:$B2_APPLICATION_KEY@$B2_BUCKET_NAME

duplicity backup "$SRC" "$B2_BUCKET_URL" --allow-source-mismatch
duplicity remove-older-than 14D --force "$B2_BUCKET_URL/backup"

date=$(date +"%Y-%m-%dT%H:%M:%S%:z")

curl \
  -H "Authorization: Bearer $HA_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"state\": \"$date\", \"entity_id\": \"sensor.last_backup\", \"attributes\": { \"friendly_name\": \"Last Backup Time\" }}" \
  $HA_URL/api/states/sensor.last_backup
