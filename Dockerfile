# docker build --rm -t chiaki:latest . && docker run -it --name chiaki chiaki:latest
FROM alpine:edge # https://hub.docker.com/_/alpine
ENTRYPOINT ["bash"]
WORKDIR /chiaki
RUN \
  set -ex && \
  apk add --update --no-cache \
    cmake ninja protoc py3-protobuf py3-setuptools \
    opus-dev qt5-qtbase-dev qt5-qtsvg-dev qt5-qtmultimedia-dev \
    ffmpeg-dev sdl2-dev docker fuse argp-standalone \
    bash git
COPY . /chiaki
RUN \
  set -ex && \
  service docker start && \
  chmod +s /usr/bin/docker && \
  service fuse start && \
  cd /chiaki/ && \
  cmake -Bbuild -GNinja -DCHIAKI_ENABLE_CLI=ON -DCHIAKI_ENABLE_GUI=ON -DCHIAKI_CLI_ARGP_STANDALONE=ON && \
  ninja -C build && \
  build/test/chiaki-unit && \
  cd /chiaki/ && \
  scripts/run-docker-build-appimage.sh && \
  cp appimage/Chiaki.AppImage ../Chiaki.AppImage
