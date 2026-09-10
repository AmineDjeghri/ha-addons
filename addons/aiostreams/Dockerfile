ARG BUILD_FROM
FROM ${BUILD_FROM}

# Upstream's runtime image is distroless (no shell), so there is no run.sh/bashio:
# this Node bootstrap maps /data/options.json onto AIOStreams' env vars and spawns
# the server. The upstream image stays byte-for-byte intact, HEALTHCHECK included.
COPY bootstrap.js /bootstrap.js

ENTRYPOINT ["/nodejs/bin/node", "/bootstrap.js"]
