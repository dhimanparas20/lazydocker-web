FROM alpine:latest

# Populated automatically by `docker buildx build`. We also fall back to `uname -m`
# when building without buildx on a single machine.
ARG TARGETARCH
ARG TARGETVARIANT

# ttyd version to download
ENV TTYD_VERSION=1.7.7

# NOTE: used by install_update_linux.sh to download binary
ENV DIR=/usr/bin/

# Install dependencies (bash needed for lazydocker install script)
RUN apk add --no-cache tini curl bash ca-certificates

# Download pre-built ttyd binary from GitHub releases (match CPU arch: Pi is ARM).
RUN set -eux; \
    arch="${TARGETARCH:-}"; variant="${TARGETVARIANT:-}"; \
    if [ -z "$arch" ]; then \
      m="$(uname -m)"; \
      case "$m" in \
        x86_64) arch="amd64" ;; \
        aarch64) arch="arm64" ;; \
        armv7*|armv7l) arch="arm"; variant="v7" ;; \
        armv6*|armv6l) arch="arm"; variant="v6" ;; \
        *) echo "Unsupported uname -m: $m" >&2; exit 1 ;; \
      esac; \
    fi; \
    case "${arch}${variant:+/$variant}" in \
      amd64) ttyd_asset="ttyd.x86_64" ;; \
      arm64) ttyd_asset="ttyd.aarch64" ;; \
      arm/v7) ttyd_asset="ttyd.armhf" ;; \
      arm/v6) ttyd_asset="ttyd.arm" ;; \
      *) echo "Unsupported TARGETARCH/TARGETVARIANT: ${arch}/${variant}" >&2; exit 1 ;; \
    esac; \
    curl -fsSL -o /usr/bin/ttyd "https://github.com/tsl0922/ttyd/releases/download/${TTYD_VERSION}/${ttyd_asset}"; \
    chmod +x /usr/bin/ttyd

# Download lazydocker binary
RUN curl "https://raw.githubusercontent.com/jesseduffield/lazydocker/master/scripts/install_update_linux.sh" | bash

EXPOSE 7681
WORKDIR /root

# Ship a default LazyDocker config in the image. Users can still override at runtime with a bind mount:
# `-v ./config.yml:/root/.config/lazydocker/config.yml`
RUN mkdir -p /root/.config/lazydocker
COPY config.yml /root/.config/lazydocker/config.yml

HEALTHCHECK --interval=2m --timeout=5s --start-period=10s --retries=3 \
  CMD curl --fail --head http://localhost:7681/ || exit 1

ENTRYPOINT ["/sbin/tini", "--"]
CMD ["ttyd", "--writable", "lazydocker"]
