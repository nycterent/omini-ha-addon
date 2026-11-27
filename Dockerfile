ARG BUILD_FROM
FROM ${BUILD_FROM}

# Go toolchain for the build stage (cross-arch: build on native arch, target
# is set by BUILDARCH/BUILDPLATFORM supplied by the Supervisor builder).
FROM golang:1.27 AS build
ARG TARGETOS TARGETARCH VERSION=dev
WORKDIR /src
COPY go.mod go.sum ./
RUN go mod download
COPY . .
# Build the web UI first (it is embedded into the Go binary)
RUN apt-get update && apt-get install -y --no-install-recommends nodejs npm \
    && cd web && npm ci --no-audit --no-fund && npm run build && cd .. \
    && cp -r web/dist ./web/dist
RUN go run ./internal/appicons/gen -bundle \
 && go run ./internal/geoip/gen \
 && CGO_ENABLED=0 GOOS=$TARGETOS GOARCH=$TARGETARCH \
    go build -trimpath -ldflags "-s -w -X main.version=${VERSION}" -o /out/omini ./cmd/omini

FROM ${BUILD_FROM}
RUN apk add --no-cache python3 py3-pip tzdata \
 && pip3 install --no-cache-dir uv \
 || (apk add --no-cache uv) \
 || true
COPY --from=build /out/omini /usr/local/bin/omini
ENV OMINI_DATA_DIR=/data/omini \
    OMINI_ADDR=:8080 \
    UV_PYTHON_DOWNLOADS=never
# run.sh is supplied by the add-on framework and calls this binary.
