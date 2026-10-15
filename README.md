# realminio

An unofficial, source-built MinIO server image, maintained for HHHOJ.

MinIO stopped publishing community binaries and container images in 2025 and
archived the `minio/minio` repository in 2026. This repository keeps the full
upstream history and builds the server from its final `master` commit, which
includes the fixes merged after `RELEASE.2025-10-15T17-29-55Z`.

This is not a MinIO, Inc. product. The server is licensed under the GNU AGPL
v3 (see `LICENSE`); the upstream README is kept as `UPSTREAM-README.md`.

## Changes from upstream

- The upstream Dockerfiles, `docker-buildx.sh` and GitHub workflows are
  removed: they pulled images or used runners that no longer exist.
- `Dockerfile` builds the binary from source on Go 1.24 and ships it on Alpine.
- `.github/workflows/image.yml` publishes `ghcr.io/frevlm/realminio`.

## Images

Pushing a tag `r<N>` builds `linux/amd64` and `linux/arm64` images tagged
`r<N>` and `sha-<commit>`; the run summary prints the digest. Pin the digest:

```yaml
  uoj-s3:
    image: ghcr.io/frevlm/realminio@sha256:<digest>
    volumes:
      - ./uoj_data/s3:/data
    environment:
      - MINIO_ROOT_USER=...
      - MINIO_ROOT_PASSWORD=...
```

The image runs `minio server /data --console-address :9001`; the S3 API is on
port 9000.

## Building locally

```sh
./build-image.sh realminio:local
```
