# Build args come from the Supervisor (BUILD_ARCH etc.). We build on stock
# Alpine images from Docker Hub because ghcr.io anonymous pulls are 403-blocked
# on this network; the HA add-on base image is therefore not used.
FROM golang:1.25-alpine AS build
ARG TARGETOS TARGETARCH VERSION=dev
RUN apk add --no-cache nodejs npm git
WORKDIR /src
COPY go.mod go.sum ./
RUN go mod download
COPY . .
# Build the web UI first (it is embedded into the Go binary)
RUN cd web && npm ci --no-audit --no-fund && npm run build && cd .. \
    && cp -r web/dist ./web/dist
RUN go run ./internal/appicons/gen -bundle \
 && go run ./internal/geoip/gen \
 && CGO_ENABLED=0 GOOS=$TARGETOS GOARCH=$TARGETARCH \
    go build -trimpath -ldflags "-s -w -X main.version=${VERSION}" -o /out/omini ./cmd/omini

FROM alpine:3.21
ARG BUILD_ARCH
ADD https://github.com/hassio-addons/bashio/archive/refs/heads/main.tar.gz /tmp/bashio.tar.gz
RUN apk add --no-cache bash curl jq python3 py3-tzdata tzdata uv \
 && mkdir -p /usr/lib/bashio \
 && tar -xzf /tmp/bashio.tar.gz --strip 1 -C /tmp \
 && mv /tmp/lib /usr/lib/bashio/lib \
 && mv /tmp/bashio /usr/lib/bashio/bashio \
 && ln -sf /usr/lib/bashio/bashio /usr/local/bin/bashio \
 && rm /tmp/bashio.tar.gz
COPY --from=build /out/omini /usr/local/bin/omini
COPY run.sh /
RUN chmod +x /run.sh
ENV OMINI_DATA_DIR=/data/omini \
    OMINI_ADDR=:8080 \
    UV_PYTHON_DOWNLOADS=never
CMD ["bashio", "/run.sh"]
