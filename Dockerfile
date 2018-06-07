FROM arm32v7/golang:stretch as builder

# Grafana version to compile
# GitHub: https://github.com/grafana/grafana/
ARG GRAFANA_VERSION=5.1.3

# Node version to install (LTS version recommended)
# GitHub: https://github.com/nodesource/distributions
ARG NODE_REPO=node_8.x
ARG NODE_DISTRO=stretch

ENV GOPATH=/go
WORKDIR /go/src/github.com/grafana/grafana

RUN apt-get update && apt-get upgrade -y \
    && apt-get install -y \
        apt-transport-https \
    && curl -s https://deb.nodesource.com/gpgkey/nodesource.gpg.key | apt-key add - \
    && echo "deb https://deb.nodesource.com/${NODE_REPO} ${NODE_DISTRO} main" > /etc/apt/sources.list.d/nodesource.list \
    && apt-get update && apt-get upgrade -y \
    && apt-get install -y \
        build-essential \
        ca-certificates \
        curl \
        nodejs \
        phantomjs \
    && rm -rf /var/lib/apt/lists/* \
    && git clone --progress --verbose -b "v${GRAFANA_VERSION}" --single-branch https://github.com/grafana/grafana.git . \
    && echo "Build grafana-server ..." \
    && go build -v -o bin/grafana-server ./pkg/cmd/grafana-server \
    && echo "Build Grafana frontend ..." \
    && npm install -g yarn \
    && export QT_QPA_PLATFORM=offscreen \
    && yarn install --pure-lockfile \
    && npm run build


FROM arm32v7/debian:stretch-slim

LABEL maintainer="Urs Weiss <docker-images@whity.ch>"

RUN apt-get update && apt-get upgrade -y

COPY --from=builder /go/src/github.com/grafana/grafana/bin/grafana-server   /usr/sbin/grafana-server
COPY --from=builder /go/src/github.com/grafana/grafana/conf/defaults.ini    /usr/share/grafana/conf/defaults.ini
COPY --from=builder /go/src/github.com/grafana/grafana/conf/sample.ini      /etc/grafana/grafana.ini
COPY --from=builder /go/src/github.com/grafana/grafana/public               /usr/share/grafana/public
COPY --from=builder /go/src/github.com/grafana/grafana/scripts              /usr/share/grafana/scripts
COPY --from=builder /go/src/github.com/grafana/grafana/vendor               /usr/share/grafana/vendor

EXPOSE      3000
VOLUME      [ "/var/lib/grafana", "/var/log/grafana", "/etc/grafana" ]
ENTRYPOINT  [ "/usr/sbin/grafana-server" ]
CMD         [ "--homepath=/usr/share/grafana", \
              "--config=/etc/grafana/grafana.ini", \
              "cfg:default.log.mode=console", \
              "cfg:default.paths.data=/var/lib/grafana", \
              "cfg:default.paths.logs=/var/log/grafana", \
              "cfg:default.paths.plugins=/var/lib/grafana/plugins" ]
