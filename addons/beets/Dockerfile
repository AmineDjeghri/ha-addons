# Home Assistant Addon — Beets
# The Supervisor injects BUILD_FROM from build.json at build time.
ARG BUILD_FROM
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
ENV BEETS_VERSION=2.13.1

# Install Beets pinned to the upstream release, with the plugins used here.
# Chroma (AcoustID fingerprinting) uses fpcalc from the chromaprint package.
RUN uv tool install --python 3.14 \
        "beets[fetchart,lastgenre,embedart,titlecase,chroma]==${BEETS_VERSION}" \
    && ln -s /root/.local/bin/beet /usr/local/bin/beet

COPY run.sh /run.sh
RUN chmod a+x /run.sh

ENTRYPOINT ["/run.sh"]
