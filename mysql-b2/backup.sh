#!/bin/sh
set -eu

: "${MYSQL_HOST}"
: "${MYSQL_PORT:=3306}"
: "${MYSQL_DATABASE}"
: "${MYSQL_USER}"
: "${MYSQL_PASSWORD}"
: "${MYSQLDUMP_ARGS:=--events --routines --triggers --hex-blob --single-transaction --complete-insert}"

: "${B2_APP_ID}"
: "${B2_APP_KEY}"
: "${B2_ARGS:=}"
: "${B2_BUCKET_NAME}"
: "${B2_FILE_NAME}"

# https://dev.mysql.com/doc/refman/8.0/en/mysqldump.html
# https://www.gnu.org/software/gzip/manual/gzip.html
echo "[$(date '+%Y/%m/%d %H:%M:%S')] Dumping..."
mysqldump "-h$MYSQL_HOST" "--port=$MYSQL_PORT" "-u$MYSQL_USER" "-p$MYSQL_PASSWORD" $MYSQL_DATABASE $MYSQLDUMP_ARGS | gzip >"/tmp/mysql.dump"

# b2 authorize-account [-h]  [applicationKeyId] [applicationKey]
echo "[$(date '+%Y/%m/%d %H:%M:%S')] Logging in..."
b2 authorize-account \
  "$B2_APP_ID" \
  "$B2_APP_KEY"

# b2 upload-file [-h] [--noProgress] [--quiet] [--contentType CONTENTTYPE] [--minPartSize MINPARTSIZE] [--sha1 SHA1] [--threads THREADS]
# [--info INFO] [--destinationServerSideEncryption {SSE-B2,SSE-C}] [--destinationServerSideEncryptionAlgorithm {AES256}] [--legalHold {on,off}]
# [--fileRetentionMode {compliance,governance}] [--retainUntil TIMESTAMP] bucketName localFilePath b2FileName
echo "[$(date '+%Y/%m/%d %H:%M:%S')] Calculating checksum..."
sha1=$(sha1sum "/tmp/mysql.dump" | awk '{print $1}')
echo "[$(date '+%Y/%m/%d %H:%M:%S')] Uploading..."
b2 upload-file $B2_ARGS \
  --noProgress \
  --sha1 "$sha1" \
  "$B2_BUCKET_NAME" \
  "/tmp/mysql.dump" \
  "$B2_FILE_NAME"

# backup time tracking in logs
echo "[$(date '+%Y/%m/%d %H:%M:%S')] Done!"
