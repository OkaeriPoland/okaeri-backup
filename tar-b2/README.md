# Okaeri Backup | Tar (B2)

Backup/~~restore~~ files into/~~from~~ B2 bucket. Uses tar with gzip compression by default.

## Backup

### Command line

```console
docker run --rm --net=host \
    -e TAR_TARGET=/home \
    -e B2_APP_ID=xyz \
    -e B2_APP_KEY=xyz \
    -e B2_BUCKET_NAME=mybucket \
    -e B2_FILE_NAME=mydata.tar.gz \
    okaeri/backup-mysql-b2
```

#### Nomad (periodic job, host mount)

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

  constraint {
    attribute = "${attr.unique.hostname}"
    value     = "mytargethost"
  }

  group "backup" {
    count = 1

    task "backup" {
      driver = "docker"

      env {
        TAR_TARGET     = "/data"

        B2_APP_ID      = "xyz"
        B2_APP_KEY     = "xyz"
        B2_BUCKET_NAME = "mybucket"
        B2_FILE_NAME   = "myservice-backup-daily.tar.gz"
      }

      config {
        image       = "okaeri/backup-tar-b2:latest"
        volumes     = [
          # mount /home from host as /data in container (read-only)
          "/home:/data:ro"
        ]
      }

      resources {
        cpu    = 500
        memory = 256
      }
    }
  }
}
```
