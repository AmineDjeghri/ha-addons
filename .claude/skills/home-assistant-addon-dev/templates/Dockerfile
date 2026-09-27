ARG BUILD_FROM
FROM ${BUILD_FROM}

# Install Python and build dependencies
RUN if command -v apt-get >/dev/null 2>&1; then \
        apt-get update && apt-get install -y --no-install-recommends python3 python3-pip python3-venv curl ca-certificates bash jq; \
    elif command -v apk >/dev/null 2>&1; then \
        apk add --no-cache python3 py3-pip curl ca-certificates bash jq; \
    fi \
    && mkdir -p /tmp/bashio \
    && curl -L -s https://github.com/hassio-addons/bashio/archive/v0.16.2.tar.gz | tar -xzf - --strip 1 -C /tmp/bashio \
    && mv /tmp/bashio/lib /usr/lib/bashio \
    && ln -s /usr/lib/bashio/bashio /usr/bin/bashio \
    && if command -v apt-get >/dev/null 2>&1; then \
        apt-get clean && rm -rf /var/lib/apt/lists/*; \
    fi \
    && rm -rf /tmp/*

WORKDIR /app
COPY src /app/src
COPY requirements.txt /app/requirements.txt
RUN pip3 install --no-cache-dir -r requirements.txt

COPY run.sh /
RUN chmod a+x /run.sh

ENTRYPOINT ["/run.sh"]
