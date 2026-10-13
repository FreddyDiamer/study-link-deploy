#!/bin/bash
set -euo pipefail

usage() {
    echo "Usage: deploy.sh <api|webapp> <commit-sha>" >&2
    exit 1
}

if [[ $# -ne 2 ]]; then
    usage
fi

case "$1" in
    "api")    ENV_TAG_NAME="API_IMAGE_TAG" ;;
    "webapp") ENV_TAG_NAME="WEBAPP_IMAGE_TAG" ;;
    *)        echo "Error: unknown service '$1'" >&2; usage ;;
esac

if [[ ! "$2" =~ ^[0-9a-f]{40}$ ]]; then
    echo "Error: invalid commit sha '$2' (expected 40 hex characters)" >&2
    usage
fi

ENV_TAG_VALUE="$2"

cd "$(dirname "$0")"

sed -i "s/^$ENV_TAG_NAME=.*/$ENV_TAG_NAME=$ENV_TAG_VALUE/" versions.env

docker compose --env-file .env --env-file versions.env up -d --wait

docker image prune -af