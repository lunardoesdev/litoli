buildah build \
  --layers \
  -f Containerfile \
  --output type=tar,dest=/dev/stdout \
  . | zstd -10 -v -o sdk-rootfs.tar.zst