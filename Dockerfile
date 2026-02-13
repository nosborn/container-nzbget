FROM debian:13.3-slim

ARG VERSION

RUN export DEBIAN_FRONTEND=noninteractive \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        jq \
        python3 \
        unzip \
    && rm -rf \
        /var/lib/apt/lists/* \
    && mkdir /app /config \
    && chown 1000:1000 /app

USER 1000:1000

RUN cd /app \
    && curl -fLsS \
        --output /tmp/nzbget-bin.run \
        --url "https://github.com/nzbgetcom/nzbget/releases/download/v${VERSION:?}/nzbget-${VERSION:?}-bin-linux.run" \
    && sh /tmp/nzbget-bin.run --destdir "${PWD}" --unpack \
    && rm /tmp/nzbget-bin.run \
    && for f in 7za nzbget unrar unrar7; do \
         mv "${f}-x86_64" "${f}"; \
       done \
    && rm -f \
        7za-* \
        cacert.pem \
        install-update.sh \
        nzbget-* \
        pubkey.pem \
        unrar-* \
        unrar7-* \
    && mkdir scripts \
    && extensions="$(curl -fsS https://raw.githubusercontent.com/nzbgetcom/nzbget-extensions/refs/heads/main/extensions.json)" \
    && for name in FakeDetector RemoveSamples; do \
         url="$(echo "${extensions}" | jq --arg name "${name}" -r '.[]|select(.name==$name)|.url')"; \
         curl -fLOsS "${url}"; \
         unzip "$(basename "${url}")" -d scripts; \
         rm "$(basename "${url}")"; \
       done \
    && curl -fLOsS \
        --output-dir scripts \
        --url https://raw.githubusercontent.com/l3uddz/nzbgetScripts/d9d852b4c889dd3636e6434d82445d5fedcbef0a/HashRenamer.py \
    && chmod +x scripts/HashRenamer.py

EXPOSE 6789
VOLUME /downloads
VOLUME /library

ENTRYPOINT ["/app/nzbget", "--configfile=/app/nzbget.conf", "--option=OutputMode=log", "--option=WriteLog=none", "--server"]
