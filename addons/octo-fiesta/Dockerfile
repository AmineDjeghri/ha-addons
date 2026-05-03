ARG BUILD_FROM
FROM ${BUILD_FROM}

# Install bashio for reading HA addon options (upstream .NET image doesn't have it)
RUN if command -v apt-get >/dev/null 2>&1; then \
        apt-get update && apt-get install -y --no-install-recommends curl ca-certificates bash; \
    elif command -v apk >/dev/null 2>&1; then \
        apk add --no-cache curl ca-certificates bash; \
    fi \
    && mkdir -p /tmp/bashio \
    && curl -L -s https://github.com/hassio-addons/bashio/archive/v0.16.2.tar.gz | tar -xzf - --strip 1 -C /tmp/bashio \
    && mv /tmp/bashio/lib /usr/lib/bashio \
    && ln -s /usr/lib/bashio/bashio /usr/bin/bashio \
    && if command -v apt-get >/dev/null 2>&1; then \
        apt-get clean && rm -rf /var/lib/apt/lists/*; \
    fi \
    && rm -rf /tmp/*

COPY run.sh /
RUN chmod a+x /run.sh

ENTRYPOINT ["/run.sh"]
