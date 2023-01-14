#!/bin/sh
set -eu

: "${TAR_TARGET}"
: "${TAR_ARGS:=-z}"

: "${B2_APP_ID}"
: "${B2_APP_KEY}"
: "${B2_ARGS:=}"
: "${B2_BUCKET_NAME}"
: "${B2_FILE_NAME}"

tmpfile=$(mktemp)

echo "[$(date '+%Y/%m/%d %H:%M:%S')] Taring..."
tar $TAR_ARGS -c -f "$tmpfile" $TAR_TARGET

# b2 authorize-account [-h]  [applicationKeyId] [applicationKey]
echo "[$(date '+%Y/%m/%d %H:%M:%S')] Logging in..."
b2 authorize-account \
  "$B2_APP_ID" \
  "$B2_APP_KEY"

# b2 upload-file [-h] [--noProgress] [--quiet] [--contentType CONTENTTYPE] [--minPartSize MINPARTSIZE] [--sha1 SHA1] [--threads THREADS]
# [--info INFO] [--destinationServerSideEncryption {SSE-B2,SSE-C}] [--destinationServerSideEncryptionAlgorithm {AES256}] [--legalHold {on,off}]
# [--fileRetentionMode {compliance,governance}] [--retainUntil TIMESTAMP] bucketName localFilePath b2FileName
echo "[$(date '+%Y/%m/%d %H:%M:%S')] Calculating checksum..."
sha1=$(sha1sum "$tmpfile" | awk '{print $1}')
echo "[$(date '+%Y/%m/%d %H:%M:%S')] Uploading..."
b2 upload-file $B2_ARGS \
  --noProgress \
  --sha1 "$sha1" \
  "$B2_BUCKET_NAME" \
  "$tmpfile" \
  "$B2_FILE_NAME"

# backup time tracking in logs
echo "[$(date '+%Y/%m/%d %H:%M:%S')] Done!"
