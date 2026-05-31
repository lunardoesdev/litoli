buildah build \
  --layers \
  -f Containerfile \
  --output type=tar,dest=./sdk-rootfs.tar \
  . && \
zstd -v --rm sdk-rootfs.tar
