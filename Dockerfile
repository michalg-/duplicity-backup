FROM alpine:latest

RUN apk add --update py-pip
RUN apk add --no-cache duplicity gnupg dpkg curl

RUN python -m pip config --global set global.break-system-packages true
RUN pip install b2sdk

COPY backup.sh /usr/local/bin/backup.sh
RUN chmod +x /usr/local/bin/backup.sh

RUN crontab -l | { cat; echo "0 4 * * * sh /usr/local/bin/backup.sh > /proc/1/fd/1 2>/proc/1/fd/2"; } | crontab -
RUN crontab -l | { cat; echo "*/15 * * * * echo 'Sleeping' > /proc/1/fd/1 2>/proc/1/fd/2"; } | crontab -

ENTRYPOINT ["/usr/sbin/crond", "-f"]
