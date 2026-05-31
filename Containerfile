from debian:bookworm-slim as builder

env DEBIAN_FRONTEND=noninteractive

run --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt/lists,sharing=locked \
    apt-get update && apt-get install -y \
  build-essential \
  cmake \
  pkg-config \
  make \
  git \
  wget \
  curl \
  ca-certificates \
  \
  libsdl2-dev \
  libsdl2-image-dev \
  libsdl2-mixer-dev \
  libsdl2-ttf-dev \
  \
  libsfml-dev \
  \
  libgl1-mesa-dev \
  libglu1-mesa-dev \
  libegl1-mesa-dev \
  libgles2-mesa-dev \
  libvulkan-dev \
  libglfw3-dev \
  libglew-dev \
  libglm-dev \
  \
  libgtk-3-dev \
  libgtkmm-3.0-dev \
  qt6-base-dev \
  qt6-tools-dev \
  qt6-wayland-dev \
  \
  libasound2-dev \
  libpulse-dev \
  libjack-jackd2-dev \
  libopenal-dev \
  portaudio19-dev \
  \
  libfreetype6-dev \
  libx11-dev \
  libxrandr-dev \
  libxcursor-dev \
  libxi-dev \
  libxinerama-dev \
  && \
  apt-get clean

env DEBIAN_FRONTEND=

from scratch as final
COPY --from=builder /usr/include /usr/include
COPY --from=builder /usr/lib /usr/lib
COPY --from=builder /usr/lib64 /usr/lib64
COPY --from=builder /usr/share /usr/share
COPY --from=builder /usr/local/include /usr/local/include
COPY --from=builder /usr/local/lib /usr/local/lib
COPY --from=builder /usr/lib/*/qt6 /usr/lib/
COPY --from=builder /lib /lib