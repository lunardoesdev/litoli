# litoli — Linux-To-Linux sysroot

Pre-built Linux cross-compilation sysroot with SDL2, SFML, GTK3, Qt6, OpenGL,
Vulkan, GLFW, audio libs (ALSA, PulseAudio, JACK, OpenAL), X11, and more.

## Requirements

- `zstd` — to decompress
- `clang` — compiler (covers any arch via `--target`)
- `buildah` — only if rebuilding

## Build

```sh
./build.sh              # produces sdk-rootfs.tar.zst
```

## Use

```sh
mkdir -p $HOME/litoli
tar --zstd -xf sdk-rootfs.tar.zst -C $HOME/litoli
```

### clang

```sh
clang --target=aarch64-linux-gnu --sysroot=$HOME/litoli -o hello hello.c   # cross
```

### CMake

```sh
cmake -B build -DCMAKE_SYSROOT=$HOME/litoli -DCMAKE_C_COMPILER=gcc -DCMAKE_CXX_COMPILER=g++
cmake --build build
```

Cross (switch compilers to needed ones):
```sh
cmake \
  -DCMAKE_SYSROOT=$HOME/litoli \
  -DCMAKE_C_COMPILER=gcc \
  -DCMAKE_CXX_COMPILER=g++ \
  -DCMAKE_C_COMPILER_TARGET=x86_64-linux-gnu \
  -DCMAKE_CXX_COMPILER_TARGET=x86_64-linux-gnu \
  -DCMAKE_C_COMPILER_WORKS=ON \
  -DCMAKE_CXX_COMPILER_WORKS=ON \
  ..
```

### CMake with clang (it doesn't work without --allow-shlib-undefined):
```sh
cmake -DCMAKE_SYSROOT=$HOME/litoli \
  -DCMAKE_C_COMPILER=clang \
  -DCMAKE_CXX_COMPILER=clang++ \
  -DCMAKE_C_FLAGS="-Wl,--allow-shlib-undefined" \
  -DCMAKE_EXE_LINKER_FLAGS="-Wl,--allow-shlib-undefined" \
  ..

```


```
cmake   -DCMAKE_SYSROOT="$LITOLI_SDK"   -DCMAKE_MODULE_PATH="$(find "$LITOLI_SDK/usr/share" -maxdepth 3 -type d -path '*/cmake-*/Modules')"   -DCMAKE_C_COMPILER=gcc   -DCMAKE_CXX_COMPILER=g++   -DCMAKE_C_COMPILER_TARGET=x86_64-linux-gnu   -DCMAKE_C_FLAGS="-Wl,--allow-shlib-undefined"   -DCMAKE_EXE_LINKER_FLAGS="-Wl,--allow-shlib-undefined"   -DCMAKE_C_COMPILER_WORKS=ON   -DCMAKE_CXX_COMPILER_WORKS=ON   -DCMAKE_FIND_ROOT_PATH="$LITOLI_SDK"    ..

```

### pkg-config

```sh
export PKG_CONFIG_SYSROOT_DIR=$HOME/litoli
export PKG_CONFIG_LIBDIR=$HOME/litoli/usr/lib/pkgconfig:$HOME/litoli/usr/share/pkgconfig
```
