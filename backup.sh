#!/bin/sh

#B2_ACCOUNT_ID=$B2_ACCOUNT_ID
#B2_APPLICATION_KEY=$B2_APPLICATION_KEY
#PASSPHRASE=$PASSPHRASE
#B2_BUCKET_NAME=your-bucket-name
#SRC=/source
#HA_TOKEN=token
#HA_URL=http://192.168.68.116:8123

B2_BUCKET_URL=b2://$B2_ACCOUNT_ID:$B2_APPLICATION_KEY@$B2_BUCKET_NAME

# Whitespace/newline-separated lists of patterns to include/exclude from backup.
# Override via BACKUP_INCLUDES/BACKUP_EXCLUDES env vars (compose `|` block scalar works well).
DEFAULT_INCLUDES="
**/.storage
**/.storage/**
"
DEFAULT_EXCLUDES="
**/.*
/source/stacks/jellyfin/config/data/metadata
/source/stacks/adwireguard/adguard/opt-adguard-work/data/querylog.json*
"
INCLUDES="${BACKUP_INCLUDES:-$DEFAULT_INCLUDES}"
EXCLUDES="${BACKUP_EXCLUDES:-$DEFAULT_EXCLUDES}"

set -f
SELECTION_FLAGS=""
for pattern in $INCLUDES; do
  SELECTION_FLAGS="$SELECTION_FLAGS --include $pattern"
done
for pattern in $EXCLUDES; do
  SELECTION_FLAGS="$SELECTION_FLAGS --exclude $pattern"
done
set +f

duplicity --full-if-older-than 7D $SELECTION_FLAGS "$SRC" "$B2_BUCKET_URL" --allow-source-mismatch
duplicity backup $SELECTION_FLAGS "$SRC" "$B2_BUCKET_URL" --allow-source-mismatch
duplicity remove-older-than 8D --force "$B2_BUCKET_URL"

date=$(date +"%Y-%m-%dT%H:%M:%S%:%z")

curl \
  -H "Authorization: Bearer $HA_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"state\": \"$date\", \"attributes\": {\"friendly_name\": \"Last Backup Timestamp\", \"device_class\": \"timestamp\"}}" \
  $HA_URL/api/states/sensor.backup_sensor
