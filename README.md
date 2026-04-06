# OpenCvSharp Builder

Custom fork of [shimat/opencvsharp](https://github.com/shimat/opencvsharp) for building optimized `libOpenCvSharpExtern` native libraries for ThatCharacter.

## Why Custom Builds?

Official OpenCvSharp runtime packages for Linux and macOS are outdated or missing:

- **Linux**: `OpenCvSharp4.runtime.linux-x64` exists but includes unnecessary dependencies (FFmpeg, Tesseract, GTK3)
- **macOS x64**: `OpenCvSharp4.runtime.osx.10.15-x64` stuck at 4.6.0 (2023), incompatible with OpenCvSharp 4.11.0 C# wrapper
- **macOS ARM64**: `OpenCvSharp4.runtime.osx_arm64` stuck at 4.8.1-rc (2023), incompatible with 4.11.0

Windows uses the official `OpenCvSharp4.runtime.win` package (up-to-date, 4.11.0).

## Changes in This Fork

### Size Optimization (76MB → ~13MB)

**`cmake/opencv_build_options.cmake`**
 
- Disabled all OpenCV modules except `core` and `imgproc` (the only modules PaddleOCR uses)
- Disabled IPP (Intel Performance Primitives)
- Disabled FFmpeg, Tesseract, and codec libraries not needed by ThatCharacter

**`src/OpenCvSharpExtern/CMakeLists.txt`**
 
- Explicit list of 4 source files instead of `file(GLOB *.cpp)`: `core.cpp`, `imgproc.cpp`, `std_string.cpp`, `std_vector.cpp`
- Narrowed `find_package` to only `core` and `imgproc` components
- Added compile definitions: `NO_HIGHGUI`, `NO_VIDEO`, `NO_STITCHING`, `NO_ML`, `NO_CONTRIB`

### CMake Fix for Arch Linux

**`src/OpenCvSharpExtern/CMakeLists.txt`**
- Changed `find_package(OpenCV REQUIRED)` to explicit component list
- Required on systems where `find_package(OpenCV)` doesn't auto-enumerate components

## Building Native Libraries

**Note:** Before building, ensure the `opencv` and `opencv_contrib` submodules are initialized:
```bash
git submodule update --init --recursive
```

---

### Linux x64 (Docker)

Builds inside Ubuntu 22.04 (glibc 2.35) for portability. Covers: Ubuntu 22/24, Debian 12, Fedora 37+, Arch, Mint 21.

**Prerequisites:** Docker with BuildKit support

**Step 1: Build Docker image**
 
```bash
DOCKER_BUILDKIT=1 docker build \
  --target opencvsharp-builder \
  -f docker/ubuntu24-dotnet10-opencv4.13.0/Dockerfile \
  -t opencvsharp-builder \
  .
```

Takes ~20 minutes on first run (compiles OpenCV from source). Subsequent runs are faster due to cache.

**Step 2: Extract the built library**

```bash
docker run --rm \
  -v ../native/linux-x64:/out \
  opencvsharp-builder \
  sh -c "cp /artifacts/libOpenCvSharpExtern.so /out/ && strip --strip-all /out/libOpenCvSharpExtern.so"
```

**Step 3: Verify no missing dependencies**
 
```bash
ldd ../native/linux-x64/libOpenCvSharpExtern.so | grep "not found"
```

Should print nothing. If any libraries are listed, they need to be statically linked in `cmake/opencv_build_options.cmake`.

---

### macOS x64 (Intel Mac)

**Prerequisites:**
```bash
brew install cmake protobuf
```

Note: Protobuf is a build-time dependency only (CMake requires it for package discovery). It won't be linked into the final dylib.

**Step 1: Build OpenCV statically**
```bash
# Use the optimized build options from this repo
cmake -C cmake/opencv_build_options.cmake \
  -S opencv -B opencv/build \
  -D CMAKE_BUILD_TYPE=Release \
  -D BUILD_SHARED_LIBS=OFF \
  -D CMAKE_INSTALL_PREFIX=$PWD/opencv_artifacts \
  -D OPENCV_EXTRA_MODULES_PATH=$PWD/opencv_contrib/modules

cmake --build opencv/build -j$(sysctl -n hw.ncpu)
cmake --install opencv/build
```

Takes ~20 minutes on first run.

**Step 2: Build libOpenCvSharpExtern**
```bash
mkdir -p src/OpenCvSharpExtern/build
cd src/OpenCvSharpExtern/build

cmake .. \
  -D CMAKE_BUILD_TYPE=Release \
  -D CMAKE_MACOSX_RPATH=ON \
  -D CMAKE_PREFIX_PATH=$PWD/../../../opencv_artifacts

make -j$(sysctl -n hw.ncpu)

# Fix install name for runtime resolution
install_name_tool -id @rpath/libOpenCvSharpExtern.dylib libOpenCvSharpExtern.dylib

# Strip debug symbols
strip -x libOpenCvSharpExtern.dylib

# Copy to project
cp libOpenCvSharpExtern.dylib ../../../native/osx-x64/
```

**Step 3: Verify it's self-contained**
```bash
otool -L ../../../native/osx-x64/libOpenCvSharpExtern.dylib
```

Should **only** reference system libraries: `libstdc++`, `libc++`, `libSystem`, `/usr/lib/libc++abi.dylib`. No OpenCV dylibs should appear - they're statically linked inside.

---

### macOS ARM64 (Apple Silicon)

**Prerequisites:**
```bash
brew install cmake protobuf
```

Note: Protobuf is a build-time dependency only (CMake requires it for package discovery). It won't be linked into the final dylib.

**Step 1: Build OpenCV statically**
```bash
# Use the optimized build options from this repo
cmake -C cmake/opencv_build_options.cmake \
  -S opencv -B opencv/build \
  -D CMAKE_BUILD_TYPE=Release \
  -D BUILD_SHARED_LIBS=OFF \
  -D CMAKE_INSTALL_PREFIX=$PWD/opencv_artifacts \
  -D OPENCV_EXTRA_MODULES_PATH=$PWD/opencv_contrib/modules

cmake --build opencv/build -j$(sysctl -n hw.ncpu)
cmake --install opencv/build
```

Takes ~20 minutes on first run.

**Step 2: Build libOpenCvSharpExtern**
```bash
mkdir -p src/OpenCvSharpExtern/build
cd src/OpenCvSharpExtern/build

cmake .. \
  -D CMAKE_BUILD_TYPE=Release \
  -D CMAKE_MACOSX_RPATH=ON \
  -D CMAKE_PREFIX_PATH=$PWD/../../../opencv_artifacts

make -j$(sysctl -n hw.ncpu)

# Fix install name for runtime resolution
install_name_tool -id @rpath/libOpenCvSharpExtern.dylib libOpenCvSharpExtern.dylib

# Strip debug symbols
strip -x libOpenCvSharpExtern.dylib

# Copy to project
cp libOpenCvSharpExtern.dylib ../../../native/osx-arm64/
```

**Step 3: Verify it's self-contained**
```bash
otool -L ../../../native/osx-arm64/libOpenCvSharpExtern.dylib
```

Should **only** reference system libraries: `libstdc++`, `libc++`, `libSystem`, `/usr/lib/libc++abi.dylib`. No OpenCV dylibs should appear - they're statically linked inside.

## Notes

- Native libraries are **pre-built and committed** to `/native/` in the main project
- Only rebuild when OpenCV version changes or modules need to be added/removed (~few times per year)
- **All platforms use static linking** - no external OpenCV installation required on user machines
- Linux: Docker build ensures compatibility across distributions (glibc 2.35+ baseline)
- macOS: Statically links OpenCV, only depends on system libraries (libc++, libSystem)
