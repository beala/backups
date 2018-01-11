#!/bin/bash

# Description: A backup script that uses `duplicity` for all the heavy lifting.
# Each time the script is run, either an incremental or full backup is created,
# encrypted, signed, and uploaded to S3. Additionally, backups older than a
# specified age are deleted from S3. These parameters are configurable below.
# This script is meant to be run as a periodic cronjob.

# Uncomment to debug
# set -x

# Credentials file. Exports the following secrets:
#   GPG_KEY_ID: ID of gpg key to use for encryption and signing
#   PASSPHRASE: Passphrase for gpg key
#   AWS_ACCESS_KEY_ID: Amazon credentials.
#   AWS_SECRET_ACCESS_KEY: Amazon credentials.
# Note: Make sure this file is only readable by the backup user!
SECRETS_FILE="/home/alex/.duplicity-secrets"

if [ ! -f "$SECRETS_FILE" ]; then
    echo "Cannot find secrets file at: $SECRETS_FILE"
    exit 1
fi

# The number of full backups to keep.
KEEP_COUNT=2
# How often to create a full backup. For example, setting this to
# "1M" creates a full backup if the most recent full backup is older
# than 1 month. Otherwise, the backup is an incremental backup.
LENGTH_BETWEEN_FULL=1M

# S3 locations to back up to.
S3_BUCKET="s3+http://beala-backups"
S3_HOME_BUCKET="$S3_BUCKET/desktop-home-alex"
S3_ARCHIVE_BUCKET="$S3_BUCKET/desktop-archive"

LOGFILE="/home/alex/.duplicity.log"

# Uncomment second line to do a dry run
DRY_RUN=""
# DRY_RUN="--dry-run"

source "$SECRETS_FILE"

backup () {
    # This function kicks off the backup process. There is one
    # duplicity command per backed up location. To start, edit
    # the source and destination (the last two parameters) to point
    # to your source and destination.
    duplicity --full-if-older-than $LENGTH_BETWEEN_FULL $DRY_RUN \
	      --exclude-filelist /home/alex/.exclude-backup \
	      --s3-use-multiprocessing \
	      --s3-use-ia \
	      --s3-use-new-style \
	      --log-file "$LOGFILE" \
	      --encrypt-sign-key "$GPG_KEY_ID" \
	      /home/alex \
	      "$S3_HOME_BUCKET" || exit 1

    duplicity --full-if-older-than $LENGTH_BETWEEN_FULL $DRY_RUN \
	      --exclude '/archive/lost+found' \
	      --s3-use-multiprocessing \
	      --s3-use-ia \
	      --s3-use-new-style \
	      --log-file "$LOGFILE" \
	      --encrypt-sign-key "$GPG_KEY_ID" \
	      /archive \
	      "$S3_ARCHIVE_BUCKET" || exit 1
}

clean () {
    # This deletes backups older than a given age. There is
    # one duplicity command per backed up location. To start,
    # edit the backup location (the last param) to point to
    # your backup location.
    duplicity remove-all-but-n-full $KEEP_COUNT $DRY_RUN \
	      --s3-use-new-style \
	      --log-file "$LOGFILE" \
	      --encrypt-sign-key "$GPG_KEY_ID" \
	      "$S3_HOME_BUCKET" || exit 1

    duplicity remove-all-but-n-full $KEEP_COUNT $DRY_RUN \
	      --s3-use-new-style \
	      --log-file "$LOGFILE" \
	      --encrypt-sign-key "$GPG_KEY_ID" \
	      "$S3_ARCHIVE_BUCKET" || exit 1
}

# Commence the backup process!!!
backup
clean

# Unset the secrets exported by the credentials file.
# Not sure if this is necessary, but seems like good
# hygiene.
unset PASSPHRASE
unset AWS_ACCESS_KEY_ID
unset AWS_SECRET_ACCESS_KEY
unset GPG_KEY_ID
