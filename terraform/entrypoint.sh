#! /bin/sh

cd /var/init

# wait until iamlive cert is mounted
until [ -f /tmp/examplefile.txt ]; do
	sleep 5
done

# Update certificates to include cert from iamlive (mounted via docker-compose)
update-ca-certificates

cd /var/app && /bin/sh
