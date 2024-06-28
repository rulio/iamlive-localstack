#! /bin/sh

cd /var/init

# wait until iamlive cert is mounted
until [ -f /usr/local/share/ca-certificates/ca.pem ]; do
	sleep 5
done

# Update certificates to include cert from iamlive (mounted via docker-compose)
update-ca-certificates

cd /var/app && /bin/sh
