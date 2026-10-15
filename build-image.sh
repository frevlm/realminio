#!/bin/sh
# Build the image from the checked-out commit: ./build-image.sh [image-name]
set -eu

image=${1:-realminio:local}
commit_id=$(git rev-parse HEAD)
commit_time=$(TZ=UTC git log -1 --date=format-local:%Y-%m-%dT%H:%M:%SZ --format=%cd)

docker build \
  --build-arg COMMIT_ID="$commit_id" \
  --build-arg COMMIT_TIME="$commit_time" \
  -t "$image" .
