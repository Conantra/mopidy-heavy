# Mopidy (Docker Image)

> Based on [debian:bookworm] & [mopidy/*](https://github.com/mopidy), as well as the [Iris Mopidy Client](https://github.com/jaedb/Iris).
> 
  

## Features Include:

- Mopidy plugins
  - Mopidy-Bandcamp
  - Mopidy-Beets
  - Mopidy-InternetArchive
  - Mopidy-Iris
  - Mopidy-Jellyfin
  - Mopidy-Local
  - Mopidy-MPD
  - Mopidy-Podcast
  - Mopidy-Scrobbler
  - Mopidy-SomaFM
  - Mopidy-Subidy
  - Mopidy-Tidal
  - Mopidy-TuneIn
  - Mopidy-YTMusic
  - Mopidy-Plex
- [Iris Mopidy Client](https://github.com/jaedb/Iris)
    - Iris can function as snapclient stream & manage snapserver
- FIFO usage to stream the audio from mopidy to snapcast
- Based on  [debian:bookworm] 
    - Customly made an entrypoint what imitate user and group behave from linuxserver.io which allows use of UID and GID variable.


```yaml
version: "3"
services:
  mopidy:
    image: conantra/mopidy-heavy:v1.00
    hostname: mopidy
    environment:
      - PUID=1000 # user ID which the mopidy service will run as, needs permissions to access the music
      - PGID=1000 # group ID which the mopidy service will run as, needs permissions to access the music
      - TZ=Europe/Warsaw
      #
      # https://github.com/linuxserver/docker-mods/tree/universal-package-install
      #
      # Set alpine or pip package ENV vars for further mopidy extensions
      #
      - DOCKER_MODS=linuxserver/mods:universal-package-install
      - INSTALL_PIP_PACKAGES=Mopidy-Beets|Mopidy-dLeyna|Mopidy-InternetArchive|Mopidy-TuneIn|Mopidy-YTMusic
      # - INSTALL_PACKAGES=mopidy-podcast
    restart: "unless-stopped"
    ports:
      - 6600:6600 # Remote Control port for MPD
      - 6680:6680 # HTML API & Webinterface port for accessing mopidy
    ports:
     - 6600:6600 # Remote Control port for MPD
     - 6680:6680 # HTML API & Webinterface port for accessing mopidy
     - 5555:5555/udp # port for the optional snapcast FIFO output, needs to be conf>

    # devices:
    # - /dev/snd:/dev/snd # optional, needed if you want to play to host audio devices.
    volumes:
      - $MOPIROOM_FOLDER/config/:/config/
      # contains mopidy configured FIFO location,
      # check mopidy.conf <https://github.com/conantra/mopidy-heavy/blob/main/root/defaults/mopidy.conf>
      # will get used by snapcast and streamed to the network.
      #
      # ```conf
      # [audio]
      # output = (...) location=/data/audio/snapcast_fifo
      # ```
      #
      # mopidy--FIFO-in-FileSystem-->SnapServer--LAN-Stream-->SnapClient
      #
      - $MOPIROOM_FOLDER/data/:/data/
      - $MOPIROOM_FOLDER/:/music/:ro # READ-ONLY & optional  (needed if you want to play audio files from host)

