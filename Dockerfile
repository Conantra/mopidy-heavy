FROM debian:bookworm-slim

ARG BUILD_DATE
ARG VERSION
ARG MOPIDY_RELEASE=3.4.2

LABEL build_version="version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="conantra"

ENV DEBIAN_FRONTEND=noninteractive
ENV PATH="/lsiopy/bin:$PATH"

# -------------------------------------------------------
# System packages
# -------------------------------------------------------
RUN set -ex \
 && apt update \
 && apt install -y --no-install-recommends \
    python3.11 \
    python3.11-venv \
    python3.11-dev \
    python3-pip \
    python3-gi \
    python3-cairo \
    gir1.2-glib-2.0 \
    gir1.2-gstreamer-1.0 \
    gir1.2-gst-plugins-base-1.0 \
    build-essential \
    pkg-config \
    cmake \
    gobject-introspection \
    libgirepository1.0-dev \
#    libgirepository-2.0-dev \
    libcairo2-dev \
    libdbus-1-dev \
    libglib2.0-dev \
    libxml2 \
    libxml2-dev \
    libffi-dev \
    gstreamer1.0-tools \
    gstreamer1.0-plugins-base \
    gstreamer1.0-plugins-good \
    gstreamer1.0-plugins-bad \
    gstreamer1.0-plugins-ugly \
    gstreamer1.0-libav \
    gstreamer1.0-vaapi \
    vainfo \
    mesa-va-drivers \
    alsa-utils \
    gosu \
    ca-certificates \
    nano \
    mc \
 && apt clean \
 && rm -rf /var/lib/apt/lists/*

# -------------------------------------------------------
# Python venv
# -------------------------------------------------------
RUN set -ex \
 && python3.11 -m venv /lsiopy \
 && /lsiopy/bin/pip install --no-cache-dir --upgrade pip wheel \
 && /lsiopy/bin/pip install --no-cache-dir setuptools==80.9.0

# -------------------------------------------------------
# Mopidy + extensions
# -------------------------------------------------------
RUN set -ex \
 && /lsiopy/bin/pip install --no-cache-dir \
    Mopidy==${MOPIDY_RELEASE} \
    Mopidy-Bandcamp \
    Mopidy-Beets \
    Mopidy-InternetArchive \
    Mopidy-Iris \
    Mopidy-Jellyfin \
    Mopidy-Local \
    Mopidy-MPD \
    Mopidy-Podcast \
    Mopidy-Scrobbler \
    Mopidy-SomaFM \
    Mopidy-Subidy \
    Mopidy-Tidal \
    Mopidy-TuneIn \
    Mopidy-YTMusic \
    Mopidy-Plex \
    plexapi \
    pykka \
    requests \
    tornado

# 🔒 Fix setuptools (pkg_resources)
RUN /lsiopy/bin/pip install --no-cache-dir --force-reinstall setuptools==80.9.0

# -------------------------------------------------------
# Katalogi aplikacji
# -------------------------------------------------------
RUN mkdir -p /config /music /data

# -------------------------------------------------------
# Entry point
# -------------------------------------------------------
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# copy defaults & s6-overlay stuff
COPY root/ /

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]

CMD ["/lsiopy/bin/mopidy", "--config", "/config/mopidy.conf"]

# -------------------------------------------------------
# Ports / volumes
# -------------------------------------------------------
EXPOSE 6680 6600 5555/udp

VOLUME /config /music /data