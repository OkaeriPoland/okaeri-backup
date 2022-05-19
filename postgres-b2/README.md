# Okaeri Backup | PostgreSQL (B2)

Backup/restore PostgreSQL database into/from B2 bucket.

## Backup

### Command line

```console
docker run --rm --net=host \
    -e PGHOST=localhost \
    -e PGPORT=5432 \
    -e PGDATABASE=mydatabase \
    -e PGUSER=myuser \
    -e PGPASSWORD=1234 \
    -e B2_APP_ID=xyz \
    -e B2_APP_KEY=xyz \
    -e B2_BUCKET_NAME=mybucket \
    -e B2_FILE_NAME=mydatabase.dump \
    okaeri/backup-postgres-b2
```

#### Nomad (periodic job)

```hcl
job "myservice-backup-daily" {
  region      = "eu-central"
  datacenters = ["dc1"]
  type        = "batch"

  periodic {
    cron             = "30 5 * * *"
    time_zone        = "Europe/Warsaw"
    prohibit_overlap = true
  }

  group "backup" {
    count = 1

    task "backup" {
      driver = "docker"

      env {
        PGHOST     = "myservice-postgres.service.consul"
        PGPORT     = "5432"
        PGDATABASE = "mydatabase"
        PGUSER     = "myuser"
        PGPASSWORD = "1234"

        B2_APP_ID      = "xyz"
        B2_APP_KEY     = "xyz"
        B2_BUCKET_NAME = "mybucket"
        B2_FILE_NAME   = "myservice-backup-daily.dump"
      }

      config {
        image       = "okaeri/backup-postgres-b2:latest"
      }

      resources {
        cpu    = 500
        memory = 256
      }
    }
  }
}
```

## Restore

### By file name

```console
docker run --rm --net=host \
    -e PGHOST=localhost \
    -e PGPORT=5432 \
    -e PGDATABASE=mydatabase \
    -e PGUSER=myuser \
    -e PGPASSWORD=1234 \
    -e B2_APP_ID=xyz \
    -e B2_APP_KEY=xyz \
    -e B2_BUCKET_NAME=mybucket \
    -e B2_FILE_NAME=mydatabase.dump \
    -e B2_RESTORE_METHOD=by-name \
    okaeri/backup-postgres-b2 restore
```

### By file ID

```console
docker run --rm --net=host \
    -e PGHOST=localhost \
    -e PGPORT=5432 \
    -e PGDATABASE=mydatabase \
    -e PGUSER=myuser \
    -e PGPASSWORD=1234 \
    -e B2_APP_ID=xyz \
    -e B2_APP_KEY=xyz \
    -e B2_FILE_ID=xyz \
    -e B2_RESTORE_METHOD=by-id \
    okaeri/backup-postgres-b2 restore
```
