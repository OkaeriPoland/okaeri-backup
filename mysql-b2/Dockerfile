FROM alpine:3

RUN apk add --no-cache mysql-client

RUN wget https://github.com/Backblaze/B2_Command_Line_Tool/releases/download/v3.4.0/b2-linux -O /usr/local/bin/b2
RUN chmod +x /usr/local/bin/b2

COPY backup.sh /usr/local/bin/backup
RUN chmod +x /usr/local/bin/backup

COPY restore.sh /usr/local/bin/restore
RUN chmod +x /usr/local/bin/restore

CMD ["backup"]
