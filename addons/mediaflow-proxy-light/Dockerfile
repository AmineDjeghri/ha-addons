# Home Assistant Addon — MediaFlow Proxy Light
# The Supervisor injects BUILD_FROM (from build.json) and BUILD_ARCH at build time.
ARG BUILD_FROM
FROM ${BUILD_FROM}

# Single source of truth for the pinned upstream release — sed-updated by the
# bump-mediaflow-proxy-light job in .github/workflows/upstream-bump.yml.
ARG MEDIAFLOW_VERSION=1.1.2
# Injected by the HA builder (amd64, aarch64, ...); used to pick the release asset.
ARG BUILD_ARCH

# HA Debian base images already ship bashio, curl, jq and ca-certificates —
# no install step needed (octo-fiesta only installs bashio because its base is
# a foreign upstream .NET image that lacks it).
#
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
