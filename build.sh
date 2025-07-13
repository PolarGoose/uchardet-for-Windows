#!/usr/bin/env bash
# Run this script from 'ucrt64.exe' MSYS2 shell

set -o xtrace -o errexit -o nounset -o pipefail

readonly currentScriptDir=`dirname "$(realpath -s "${BASH_SOURCE[0]}")"`
readonly buildDir="${currentScriptDir}/build"

# Install prerequisites (the prerequisites are installed by Github Actions)
# pacman --sync --sysupgrade --refresh --noconfirm
# pacman --sync --needed --noconfirm mingw-w64-ucrt-x86_64-toolchain base-devel cmake git zip msys2-runtime-devel

# Create build directory
rm -rf "${buildDir}"
mkdir "${buildDir}"

# Clone uchardet repository
git clone --depth 1 --branch v0.0.8 https://gitlab.freedesktop.org/uchardet/uchardet.git "${buildDir}/uchardet"

# Patch CMakeLists.txt becuase version 3.1 is not supported
sed -i "s/cmake_minimum_required(VERSION 3\.1)/cmake_minimum_required(VERSION 3.10)/" "${buildDir}/uchardet/CMakeLists.txt"

# Build uchardet.exe
cmake -S "${buildDir}/uchardet" \
      -B "${buildDir}/out" \
      -D CMAKE_BUILD_TYPE=Release \
      -D BUILD_SHARED_LIBS=OFF \
      -D BUILD_STATIC=ON \
      -D CMAKE_EXE_LINKER_FLAGS="-static -static-libgcc -static-libstdc++"
cmake --build "${buildDir}/out" --target uchardet -- -j $(nproc)

zip --junk-paths -9 "${buildDir}/uchardet.zip" "${buildDir}/out/src/tools/uchardet.exe"
