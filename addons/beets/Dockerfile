# Home Assistant Addon — Beets
# BUILD_FROM comes from build.json when the Supervisor passes it; since Supervisor 2026.04 it is no
# longer passed by default, so the argument carries a default (a multi-arch equivalent of the build.json images).
ARG BUILD_FROM=ghcr.io/home-assistant/base:latest
FROM ${BUILD_FROM}

ENV PYTHONUNBUFFERED=1

# Runtime deps: bashio (bash/curl/jq), chromaprint (fpcalc binary for the
# chroma plugin), ffmpeg (audioread decoding), inotify-tools (library watcher),
# and uv (beets installer).
RUN apk add --no-cache \
        bash \
        curl \
        jq \
        ca-certificates \
        chromaprint \
        ffmpeg \
        inotify-tools \
    && curl -LsSf https://astral.sh/uv/install.sh \
        | env UV_INSTALL_DIR="/usr/local/bin" sh \
    && rm -rf /tmp/*

# Single source of truth for the pinned Beets release — updated by the
# bump-beets job in .github/workflows/upstream-bump.yml.
ENV BEETS_VERSION=2.14.1

# Install Beets pinned to the upstream release, with the plugins used here.
# Chroma (AcoustID fingerprinting) uses fpcalc from the chromaprint package.
# The HA base image ships a pip.conf pointing at wheels.home-assistant.io,
# which only carries older versions of some deps (e.g. mediafile <= 0.13.0).
# The CLI flags force PyPI as the default index and pick the best version
# across any leftover indexes. build-base is a temporary fallback in case a
# dependency has no musllinux wheel and needs compiling.
RUN apk add --no-cache --virtual .beets-build build-base \
    && uv tool install --python 3.14 \
           --default-index https://pypi.org/simple \
           --index-strategy unsafe-best-match \
           "beets[fetchart,embedart,titlecase,chroma]==${BEETS_VERSION}" \
    && apk del .beets-build \
    && ln -s /root/.local/bin/beet /usr/local/bin/beet

COPY run.sh /run.sh
RUN chmod a+x /run.sh

ENTRYPOINT ["/run.sh"]
