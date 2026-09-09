# Home Assistant Addon — MediaFlow Proxy Light
# The Supervisor injects BUILD_FROM (from build.json) and BUILD_ARCH at build time.
ARG BUILD_FROM
FROM ${BUILD_FROM}

# Single source of truth for the pinned upstream release — sed-updated by the
# bump-mediaflow-proxy-light job in .github/workflows/upstream-bump.yml.
ARG MEDIAFLOW_VERSION=1.1.2
# Injected by the HA builder (amd64, aarch64, ...); used to pick the release asset.
ARG BUILD_ARCH

# Install bashio for reading HA addon options. The Debian base already ships bash,
# but curl/ca-certificates/jq are needed by bashio and the addon bootstrap.
RUN apt-get update \
    && apt-get install -y --no-install-recommends curl ca-certificates bash jq \
    && mkdir -p /tmp/bashio \
    && curl -L -s https://github.com/hassio-addons/bashio/archive/v0.16.2.tar.gz | tar -xzf - --strip 1 -C /tmp/bashio \
    && mv /tmp/bashio/lib /usr/lib/bashio \
    && ln -s /usr/lib/bashio/bashio /usr/bin/bashio \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/*

# The upstream Docker image is distroless (no shell), so it cannot be the addon
# base — instead we fetch the prebuilt release binary onto HA's Debian base. It is
# a glibc-dynamic build, so Alpine/musl bases will not run it. This is a GitHub
# release asset download, so the pinned MEDIAFLOW_VERSION keeps builds reproducible.
RUN case "${BUILD_ARCH}" in \
        amd64) MFP_ARCH="x86_64" ;; \
        aarch64) MFP_ARCH="aarch64" ;; \
        *) echo "Unsupported architecture: ${BUILD_ARCH}"; exit 1 ;; \
    esac \
    && curl -fSL --retry 3 -o /usr/local/bin/mediaflow-proxy-light \
        "https://github.com/mhdzumair/MediaFlow-Proxy-Light/releases/download/${MEDIAFLOW_VERSION}/mediaflow-proxy-light-linux-${MFP_ARCH}" \
    && chmod +x /usr/local/bin/mediaflow-proxy-light

COPY run.sh /
RUN chmod a+x /run.sh

ENTRYPOINT ["/run.sh"]
