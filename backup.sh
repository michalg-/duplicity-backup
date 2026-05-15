#!/bin/sh

#B2_ACCOUNT_ID=$B2_ACCOUNT_ID
#B2_APPLICATION_KEY=$B2_APPLICATION_KEY
#PASSPHRASE=$PASSPHRASE
#B2_BUCKET_NAME=your-bucket-name
#SRC=/source
#HA_TOKEN=token
#HA_URL=http://192.168.68.116:8123

B2_BUCKET_URL=b2://$B2_ACCOUNT_ID:$B2_APPLICATION_KEY@$B2_BUCKET_NAME

# Whitespace/newline-separated list of patterns to exclude from backup.
# Override via the BACKUP_EXCLUDES env var (compose `|` block scalar works well).
DEFAULT_EXCLUDES="
**/.*
/source/stacks/jellyfin/config/data/metadata
/source/stacks/adwireguard/adguard/opt-adguard-work/data/querylog.json*
"
EXCLUDES="${BACKUP_EXCLUDES:-$DEFAULT_EXCLUDES}"

set -f
EXCLUDE_FLAGS=""
for pattern in $EXCLUDES; do
  EXCLUDE_FLAGS="$EXCLUDE_FLAGS --exclude $pattern"
done
set +f

duplicity --full-if-older-than 7D $EXCLUDE_FLAGS "$SRC" "$B2_BUCKET_URL" --allow-source-mismatch
duplicity backup $EXCLUDE_FLAGS "$SRC" "$B2_BUCKET_URL" --allow-source-mismatch
duplicity remove-older-than 8D --force "$B2_BUCKET_URL"

date=$(date +"%Y-%m-%dT%H:%M:%S%:%z")

curl \
  -H "Authorization: Bearer $HA_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"state\": \"$date\", \"attributes\": {\"friendly_name\": \"Last Backup Timestamp\", \"device_class\": \"timestamp\"}}" \
  $HA_URL/api/states/sensor.backup_sensor
