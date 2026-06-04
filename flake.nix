{
  description = "Litoli CMake/Nix cross-compilation example";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    rust-overlay.url = "github:oxalica/rust-overlay";
  };

  outputs = { self, nixpkgs, rust-overlay, ... }: let
    systems = [ "x86_64-linux" "aarch64-linux" ];
    forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f system);
    pkgsFor = system: overlays: import nixpkgs { inherit system overlays; };

    litoli-sdk = pkgs: pkgs.stdenv.mkDerivation {
      name = "litoli-sdk";
      src = pkgs.fetchurl {
        url = "https://github.com/lunardoesdev/litoli/releases/download/0.1.0/litoli-bookworm-x86_64-unknown-linux-gnu.tar.zst";
        hash = "sha256-FGo5zReqQ57bzI7462zODDR6mRW8xBP2c/9sGUd/FIA=";
      };
      nativeBuildInputs = [ pkgs.zstd ];
      dontUnpack = true;
      dontFixup = true;
      installPhase = ''
        mkdir -p $out
        tar --zstd -xf $src -C $out
      '';
    };
  in {
    packages = forAllSystems (system: let
      pkgs = pkgsFor system [];
    in {
      litoli-sdk = litoli-sdk pkgs;
    });

    devShells = forAllSystems (system: let
      overlays = [ (import rust-overlay) ];
      pkgs = pkgsFor system overlays;
      sdk = litoli-sdk pkgs;
      rust = pkgs.rust-bin.stable.latest.default.override {
        targets = [ "x86_64-unknown-linux-gnu" ];
      };
      clang' = pkgs.llvmPackages.clang-unwrapped;
      binutils' = pkgs.llvmPackages.bintools-unwrapped;
    in {
      default = pkgs.mkShell {
        LITOLI_SDK = "${sdk}";
        buildInputs = with pkgs; [
          cmake
          clang'
          llvm
          binutils'
          gnumake
          ninja
          autoconf
          automake
          libtool
          meson
          pkg-config
          zstd
          git
          xmake
          rust
        ];
        shellHook = ''
          export LITOLI_SDK="$LITOLI_SDK"
          export TARGET="x86_64-linux-gnu"
          export CC="${clang'}/bin/clang"
          export CXX="${clang'}/bin/clang++"
          export AS="$CC"
          export ASFLAGS="--target=$TARGET"
          export LD="$CC"
          export AR=${binutils'}/bin/llvm-ar
          export RANLIB=${binutils'}/bin/llvm-ranlib
          export NM=${binutils'}/bin/llvm-nm
          export STRIP=${binutils'}/bin/llvm-strip
          export INCLUDEDIRS="$LITOLI_SDK/usr/include"
          export LIBDIRS="$LITOLI_SDK/usr/lib/x86_64-linux-gnu"
          export CFLAGS="-I$INCLUDEDIRS --sysroot=$LITOLI_SDK --target=$TARGET"
          export CXXFLAGS="-I$INCLUDEDIRS --sysroot=$LITOLI_SDK --target=$TARGET"
          export LDFLAGS="-fuse-ld=lld -Wl,--allow-shlib-undefined -Wl,--dynamic-linker=/lib64/ld-linux-x86-64.so.2 -L$LIBDIRS --target=$TARGET"
          
          export PKG_CONFIG_SYSROOT_DIR="$LITOLI_SDK"
          export PKG_CONFIG_LIBDIR="$LITOLI_SDK/usr/lib/pkgconfig:$LITOLI_SDK/usr/share/pkgconfig:$LITOLI_SDK/usr/lib/x86_64-linux-gnu/pkgconfig"
          
          export CPM_SOURCE_CACHE="$HOME/.cache/CPM"
          
          export CMAKE_LIBRARY_PATH="$LIBDIRS"
          export CMAKE_INCLUDE_PATH="$INCLUDEDIRS"
          
          echo "Litoli dev shell — LITOLI_SDK=$LITOLI_SDK"
        '';
      };
    });
  };
}
