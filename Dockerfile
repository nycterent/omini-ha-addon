# Build args come from the Supervisor. Base images come from Docker Hub
# (ghcr.io is 403-blocked on this network). The omini source is cloned from
# upstream at a pinned tag — the add-on repo contains packaging only.
FROM golang:1.27-alpine AS build
ARG TARGETOS TARGETARCH
ARG OMINI_REF=v1.11.1
ENV GOTOOLCHAIN=auto
RUN apk add --no-cache nodejs npm git
WORKDIR /src
RUN git clone --depth 1 --branch ${OMINI_REF} https://github.com/riccardoalv/omini.git .
RUN cd web && npm ci --no-audit --no-fund && npm run build
RUN go run ./internal/appicons/gen -bundle \
 && go run ./internal/geoip/gen \
 && CGO_ENABLED=0 GOOS=$TARGETOS GOARCH=$TARGETARCH \
    go build -trimpath -ldflags "-s -w -X main.version=${OMINI_REF}" -o /out/omini ./cmd/omini

FROM alpine:3.21
RUN apk add --no-cache bash curl jq python3 py3-tzdata tzdata uv
COPY --from=build /out/omini /usr/local/bin/omini
COPY run.sh /
RUN chmod +x /run.sh
ENV OMINI_DATA_DIR=/data/omini \
    OMINI_ADDR=:8080 \
    UV_PYTHON_DOWNLOADS=never
CMD ["/bin/bash", "/run.sh"]
