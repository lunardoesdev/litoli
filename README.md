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
clang --sysroot=$HOME/litoli -o hello hello.c $(pkg-config --cflags --libs sdl2)
clang --target=aarch64-linux-gnu --sysroot=$HOME/litoli -o hello hello.c   # cross
```

### CMake

```sh
cmake -B build -DCMAKE_SYSROOT=$HOME/litoli -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++
cmake --build build
```

Cross:
```sh
cmake -B build \
  -DCMAKE_SYSROOT=$HOME/litoli \
  -DCMAKE_C_COMPILER=clang \
  -DCMAKE_CXX_COMPILER=clang++ \
  -DCMAKE_C_COMPILER_TARGET=aarch64-linux-gnu \
  -DCMAKE_CXX_COMPILER_TARGET=aarch64-linux-gnu
```

### Xmake + xrepo

```sh
xmake f -p linux -a x86_64 --sysroot=$HOME/litoli --toolchain=clang
xmake
```

In `xmake.lua`:
```lua
add_requires("fmt", "spdlog")
```

### Meson

you can put a crossfile anywhere in your $HOME for example, no need to put it inside
your project.
`cross/litoli.ini` (adjust the sysroot path):
```ini
[binaries]
c = 'clang'
cpp = 'clang++'

[built-in options]
c_args = ['--sysroot=/home/user/litoli']
c_link_args = ['--sysroot=/home/user/litoli']
cpp_args = ['--sysroot=/home/user/litoli']
cpp_link_args = ['--sysroot=/home/user/litoli']

[host_machine]
system = 'linux'
cpu_family = 'x86_64'
cpu = 'x86_64'
endian = 'little'
```

```sh
meson setup build --cross-file cross/litoli.ini
```

### pkg-config

```sh
export PKG_CONFIG_SYSROOT_DIR=$HOME/litoli
export PKG_CONFIG_LIBDIR=$HOME/litoli/usr/lib/pkgconfig:$HOME/litoli/usr/share/pkgconfig
```
