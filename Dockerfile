FROM golang:1.24.9-alpine3.22 AS build

# The commit being built and its UTC commit time (2006-01-02T15:04:05Z),
# which MinIO turns into its version and release tag.
ARG COMMIT_ID
ARG COMMIT_TIME

WORKDIR /src
COPY go.mod go.sum ./
RUN go mod download
COPY . .

RUN test -n "$COMMIT_ID" && test -n "$COMMIT_TIME" && \
    tag="RELEASE.$(echo "$COMMIT_TIME" | tr ':' '-')" && \
    pkg=github.com/minio/minio/cmd && \
    CGO_ENABLED=0 go build -tags kqueue -trimpath -o /out/minio --ldflags "-s -w \
      -X $pkg.Version=$COMMIT_TIME \
      -X $pkg.CopyrightYear=${COMMIT_TIME%%-*} \
      -X $pkg.ReleaseTag=$tag \
      -X $pkg.CommitID=$COMMIT_ID \
      -X $pkg.ShortCommitID=$(echo "$COMMIT_ID" | cut -c1-12)" && \
    /out/minio --version

FROM alpine:3.22

RUN apk add --no-cache ca-certificates
COPY --from=build /out/minio /usr/bin/minio
COPY LICENSE /licenses/LICENSE

EXPOSE 9000 9001
VOLUME ["/data"]
HEALTHCHECK --interval=10s --timeout=3s --retries=6 \
  CMD wget -q -O /dev/null http://127.0.0.1:9000/minio/health/live || exit 1

ENTRYPOINT ["/usr/bin/minio"]
CMD ["server", "/data", "--console-address", ":9001"]
