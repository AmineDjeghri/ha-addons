# Home Assistant Addon — AIOStreams
# BUILD_FROM is injected by the Supervisor from build.json.
ARG BUILD_FROM
FROM ${BUILD_FROM}

# The upstream runtime image is DISTROLESS (gcr.io/distroless/nodejs24-debian12):
# no bash, no curl, no jq, no apt/apk — so bashio is impossible and there is no
# shell entrypoint to hook. Node 24 IS present at /nodejs/bin/node, so instead of
# a run.sh we ship a tiny Node bootstrap that reads /data/options.json directly
# and translates the HA options into the environment variables AIOStreams expects
# before spawning the upstream server. The upstream image is pinned in build.json
# and tracked on the `nightly` channel by upstream-bump.yml; this Dockerfile adds
# no packages and leaves the upstream image otherwise byte-for-byte intact —
# including its HEALTHCHECK, which we deliberately do not override.
COPY bootstrap.js /bootstrap.js

ENTRYPOINT ["/nodejs/bin/node", "/bootstrap.js"]
