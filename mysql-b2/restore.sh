#!/bin/sh
set -eu

: "${MYSQL_HOST}"
: "${MYSQL_PORT:=3306}"
: "${MYSQL_DATABASE}"
: "${MYSQL_USER}"
: "${MYSQL_PASSWORD}"
: "${MYSQL_ARGS:=}"

: "${B2_APP_ID}"
: "${B2_APP_KEY}"
: "${B2_ARGS:=}"
#: "${B2_BUCKET_NAME}"
#: "${B2_FILE_NAME}"
#: "${B2_FILE_ID}"
: "${B2_RESTORE_METHOD:=by-name}"

# b2 authorize-account [-h]  [applicationKeyId] [applicationKey]
b2 authorize-account \
  "$B2_APP_ID" \
  "$B2_APP_KEY"

# b2 download-file-by-id [-h] [--noProgress] [--sourceServerSideEncryption {SSE-C}] [--sourceServerSideEncryptionAlgorithm {AES256}] fileId localFileName
# b2 download-file-by-name [-h] [--noProgress] [--sourceServerSideEncryption {SSE-C}] [--sourceServerSideEncryptionAlgorithm {AES256}] bucketName b2FileName localFileName
case "$B2_RESTORE_METHOD" in
"by-name")
  b2 download-file-by-name $B2_ARGS \
    --noProgress \
    "$B2_BUCKET_NAME" \
    "$B2_FILE_NAME" \
    "/tmp/mysql.dump"
  ;;
"by-id")
  b2 download-file-by-id $B2_ARGS \
    --noProgress \
    "$B2_FILE_ID" \
    "/tmp/mysql.dump"
  ;;
*)
  echo "Unknown B2_RESTORE_METHOD: $B2_RESTORE_METHOD"
  exit 1
  ;;
esac

# https://www.gnu.org/software/gzip/manual/gzip.html
gzip -d <"/tmp/mysql.dump" | mysql "-h$MYSQL_HOST" "--port=$MYSQL_PORT" "-u$MYSQL_USER" "-p$MYSQL_PASSWORD" $MYSQL_DATABASE $MYSQL_ARGS
