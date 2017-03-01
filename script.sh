#!/bin/bash

cd /lxc-host/

# Used to encrypt backups
export PASSPHRASE="xxxxxxx"

# Backblaze B2 configuration variables
B2_BUCKET="xxxxxxx"
B2_ACCOUNT="xxxxxxx"
B2_KEY="xxxxxxx"

# Check if Duplicity is installed
if ! [ $(which duplicity 2>/dev/null) ]; then
  echo "Duplicity is not installed. Can't continue."
  exit 1;
fi

for dir in */
do
  dir=$(basename "$dir")

  echo "Starting backup for $dir ..."
  duplicity --exclude-filelist /root/exclude-backup.txt $dir b2://${B2_ACCOUNT}:${B2_KEY}@${B2_BUCKET}/$dir/ --full-if-older-than 30D --numeric-owner

  echo "Deleting old backups on B2 (>30 days old)..."
  duplicity remove-older-than 1M b2://${B2_ACCOUNT}:${B2_KEY}@${B2_BUCKET}/$dir/
done

unset PASSPHRASE
