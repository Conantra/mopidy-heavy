#!/usr/bin/env bash
set -e

echo "**** Container start ****"

PUID=${PUID:-1000}
PGID=${PGID:-1000}

echo "**** UID: $PUID | GID: $PGID ****"

# Tworzenie grupy
if ! getent group abc >/dev/null; then
    groupadd -g "$PGID" abc
fi

# Tworzenie usera
if ! id -u abc >/dev/null 2>&1; then
    useradd -u "$PUID" -g "$PGID" -d /config -s /bin/bash abc
fi

# Uprawnienia
chown -R "$PUID:$PGID" /config /data

export PYTHONPATH="/usr/lib/python3/dist-packages:$PYTHONPATH"

# Kopia domyślnej konfiguracji Mopidy jeśli nie istnieje
if [ ! -f /config/mopidy.conf ]; then
    cp /defaults/mopidy.conf /config/
    chown abc:abc /config/mopidy.conf
fi

echo "**** Starting Mopidy ****"

exec gosu "$PUID:$PGID" "$@"
