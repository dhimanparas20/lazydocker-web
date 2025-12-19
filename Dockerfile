FROM ubuntu:22.04

# NOTE: use `main` branch for latest
ENV TTYD_GIT_REF=main

# NOTE: use `master` branch for latest
ENV LAZYDOCKER_GIT_REF=master

# NOTE: used by install_update_linux.sh to download binary (otherwise defaults to $HOME/.local/bin)
ENV DIR=/usr/bin/


# install deps and build ttyd binary
RUN apt-get update && apt-get install -y autoconf automake curl cmake git libtool make \
    && git clone --single-branch --branch "$TTYD_GIT_REF" --depth=1 https://github.com/tsl0922/ttyd.git /ttyd \
    && cd /ttyd && env BUILD_TARGET=x86_64 ./scripts/cross-build.sh

# download lazydocker binary
RUN curl "https://raw.githubusercontent.com/jesseduffield/lazydocker/${LAZYDOCKER_GIT_REF}/scripts/install_update_linux.sh" | bash

# use alpine to thin down the container
FROM alpine
ENV DIR=${DIR:-/usr/bin/}
COPY --from=0 /ttyd/build/ttyd /usr/bin/ttyd
COPY --from=0 $DIR/lazydocker /usr/bin/lazydocker
RUN apk add --no-cache tini curl

EXPOSE 7681
WORKDIR /root

ENTRYPOINT ["/sbin/tini", "--"]
CMD ["ttyd", "--writable", "lazydocker"]
