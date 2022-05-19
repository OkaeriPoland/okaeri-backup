#!/bin/sh
set -eu

: "${POSTGRES_ARGS:=}"
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
    "/tmp/postgres.dump"
  ;;
"by-id")
  b2 download-file-by-id $B2_ARGS \
    --noProgress \
    "$B2_FILE_ID" \
    "/tmp/postgres.dump"
  ;;
*)
  echo "Unknown B2_RESTORE_METHOD: $B2_RESTORE_METHOD"
  exit 1
  ;;
esac

# https://www.postgresql.org/docs/current/libpq-envars.html
psql --set ON_ERROR_STOP=on $POSTGRES_ARGS <"/tmp/postgres.dump"
