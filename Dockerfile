FROM debian:13.1-slim

ARG DEBIAN_FRONTEND=noninteractive
ARG VERSION

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        python3 \
    && rm -rf \
        /var/lib/apt/lists/* \
    && mkdir /app /config \
    && chown 1000:1000 /app

USER 1000:1000

RUN curl -fLsS -o /tmp/nzbget-bin.run "https://github.com/nzbgetcom/nzbget/releases/download/v${VERSION:?}/nzbget-${VERSION:?}-bin-linux.run" \
    && sh /tmp/nzbget-bin.run --destdir /app \
    && rm -f \
        /app/cacert.pem \
        /app/install-update.sh \
        /app/installer.cfg \
        /app/nzbget-bin.run \
        /app/nzbget.conf \
        /app/pubkey.pem \
    && mkdir /app/scripts \
    && curl -fLsS -o /app/scripts/HashRenamer.py \
        https://raw.githubusercontent.com/l3uddz/nzbgetScripts/d9d852b4c889dd3636e6434d82445d5fedcbef0a/HashRenamer.py \
    && chmod +x /app/scripts/HashRenamer.py

EXPOSE 6789

ENTRYPOINT ["/app/nzbget", "--server", "--configfile=/config/nzbget.conf", "--option=OutputMode=log", "--option=WriteLog=none"]
