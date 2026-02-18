FROM alpine:latest

# ttyd version to download
ENV TTYD_VERSION=1.7.7

# NOTE: used by install_update_linux.sh to download binary
ENV DIR=/usr/bin/

# Install dependencies (bash needed for lazydocker install script)
RUN apk add --no-cache tini curl bash

# Download pre-built ttyd binary from GitHub releases
RUN curl -Lo /usr/bin/ttyd https://github.com/tsl0922/ttyd/releases/download/${TTYD_VERSION}/ttyd.x86_64 \
    && chmod +x /usr/bin/ttyd

# Download lazydocker binary
RUN curl "https://raw.githubusercontent.com/jesseduffield/lazydocker/master/scripts/install_update_linux.sh" | bash

EXPOSE 7681
WORKDIR /root

HEALTHCHECK --interval=2m --timeout=5s --start-period=10s --retries=3 \
  CMD curl --fail --head http://localhost:7681/ || exit 1

ENTRYPOINT ["/sbin/tini", "--"]
CMD ["ttyd", "--writable", "lazydocker"]
