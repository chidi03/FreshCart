#!/bin/bash

set -euo pipefail

echo 'Acquire::ForceIPv4 "true";' >/etc/apt/apt.conf.d/99force-ipv4

apt-get update
apt-get install -y ca-certificates curl docker.io python3

systemctl enable docker
systemctl start docker

docker network create freshcart-network || true

docker run -d \
	--name postgres \
	--restart unless-stopped \
	--network freshcart-network \
	-e POSTGRES_USER=freshcart \
	-e POSTGRES_PASSWORD=freshcart \
	-e POSTGRES_DB=freshcart \
	postgres:16-alpine

for attempt in $(seq 1 30); do
	if docker exec postgres pg_isready -U freshcart -d freshcart; then
		break
	fi

	if [ "$attempt" -eq 30 ]; then
		echo "PostgreSQL did not become ready"
		exit 1
	fi

	sleep 2
done

REGISTRY_HOST=$(printf '%s' "${container_image}" | cut -d/ -f1)

if [[ "$REGISTRY_HOST" == *.pkg.dev ]]; then
	TOKEN_RESPONSE=$(curl -fsS \
		-H "Metadata-Flavor: Google" \
		"http://metadata.google.internal/computeMetadata/v1/instance/service-accounts/default/token")

	ACCESS_TOKEN=$(printf '%s' "$TOKEN_RESPONSE" |
		python3 -c 'import json, sys; print(json.load(sys.stdin)["access_token"])')

	printf '%s' "$ACCESS_TOKEN" |
		docker login \
			--username oauth2accesstoken \
			--password-stdin \
			"https://$REGISTRY_HOST"

	unset TOKEN_RESPONSE ACCESS_TOKEN
fi

docker pull "${container_image}"

docker rm -f checkout-api || true

docker run -d \
	--name checkout-api \
	--restart unless-stopped \
	--network freshcart-network \
	-e DATABASE_URL=postgres://freshcart:freshcart@postgres:5432/freshcart \
	-e PORT="${backend_port}" \
	-p "80:${backend_port}" \
	"${container_image}"
