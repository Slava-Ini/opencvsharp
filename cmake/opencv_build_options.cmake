# CMake initial cache for OpenCV full build.
# Used via: cmake -C cmake/opencv_build_options.cmake -S opencv ...
# Platform-specific settings (CMAKE_INSTALL_PREFIX, OPENCV_EXTRA_MODULES_PATH,
# CMAKE_PREFIX_PATH, generator) are passed directly by each build script/workflow.

set(CMAKE_BUILD_TYPE       Release CACHE STRING "" FORCE)
set(BUILD_SHARED_LIBS      OFF     CACHE BOOL   "" FORCE)
set(ENABLE_CXX11           ON      CACHE BOOL   "" FORCE)
set(OPENCV_ENABLE_NONFREE  ON      CACHE BOOL   "" FORCE)

# Disable build outputs we don't need
set(BUILD_EXAMPLES  OFF CACHE BOOL "" FORCE)
set(BUILD_DOCS      OFF CACHE BOOL "" FORCE)
set(BUILD_PERF_TESTS OFF CACHE BOOL "" FORCE)
set(BUILD_TESTS     OFF CACHE BOOL "" FORCE)
set(BUILD_JAVA      OFF CACHE BOOL "" FORCE)

# Only build the two OpenCV modules the bridge actually uses:
#   core    — Mat type and basic operations
#   imgproc — CvtColor, Resize, CopyMakeBorder, FindContours, MinAreaRect, etc.
# PaddleOCR's preprocessing uses only these two. Everything else is dead weight.
set(BUILD_opencv_apps                      OFF CACHE BOOL "" FORCE)
set(BUILD_opencv_java_bindings_generator   OFF CACHE BOOL "" FORCE)
set(BUILD_opencv_python_bindings_generator OFF CACHE BOOL "" FORCE)
set(BUILD_opencv_python_tests              OFF CACHE BOOL "" FORCE)
set(BUILD_opencv_ts                        OFF CACHE BOOL "" FORCE)
set(BUILD_opencv_js                        OFF CACHE BOOL "" FORCE)
set(BUILD_opencv_js_bindings_generator     OFF CACHE BOOL "" FORCE)
# Core modules not needed
set(BUILD_opencv_calib3d                   OFF CACHE BOOL "" FORCE)
set(BUILD_opencv_dnn                       OFF CACHE BOOL "" FORCE)
set(BUILD_opencv_features2d                OFF CACHE BOOL "" FORCE)
set(BUILD_opencv_flann                     OFF CACHE BOOL "" FORCE)
set(BUILD_opencv_gapi                      OFF CACHE BOOL "" FORCE)
set(BUILD_opencv_highgui                   OFF CACHE BOOL "" FORCE)
set(BUILD_opencv_imgcodecs                 OFF CACHE BOOL "" FORCE)
set(BUILD_opencv_ml                        OFF CACHE BOOL "" FORCE)
set(BUILD_opencv_objdetect                 OFF CACHE BOOL "" FORCE)
set(BUILD_opencv_photo                     OFF CACHE BOOL "" FORCE)
set(BUILD_opencv_stitching                 OFF CACHE BOOL "" FORCE)
set(BUILD_opencv_video                     OFF CACHE BOOL "" FORCE)
set(BUILD_opencv_videoio                   OFF CACHE BOOL "" FORCE)
# Contrib modules not needed
set(BUILD_opencv_aruco                     OFF CACHE BOOL "" FORCE)
set(BUILD_opencv_bgsegm                    OFF CACHE BOOL "" FORCE)
set(BUILD_opencv_bioinspired               OFF CACHE BOOL "" FORCE)
set(BUILD_opencv_ccalib                    OFF CACHE BOOL "" FORCE)
set(BUILD_opencv_datasets                  OFF CACHE BOOL "" FORCE)
set(BUILD_opencv_dnn_objdetect             OFF CACHE BOOL "" FORCE)
set(BUILD_opencv_dnn_superres              OFF CACHE BOOL "" FORCE)
set(BUILD_opencv_dpm                       OFF CACHE BOOL "" FORCE)
set(BUILD_opencv_face                      OFF CACHE BOOL "" FORCE)
set(BUILD_opencv_fuzzy                     OFF CACHE BOOL "" FORCE)
set(BUILD_opencv_img_hash                  OFF CACHE BOOL "" FORCE)
set(BUILD_opencv_intensity_transform       OFF CACHE BOOL "" FORCE)
set(BUILD_opencv_line_descriptor           OFF CACHE BOOL "" FORCE)
set(BUILD_opencv_mcc                       OFF CACHE BOOL "" FORCE)
set(BUILD_opencv_objc_bindings_generator   OFF CACHE BOOL "" FORCE)
set(BUILD_opencv_optflow                   OFF CACHE BOOL "" FORCE)
set(BUILD_opencv_quality                   OFF CACHE BOOL "" FORCE)
set(BUILD_opencv_rapid                     OFF CACHE BOOL "" FORCE)
set(BUILD_opencv_reg                       OFF CACHE BOOL "" FORCE)
set(BUILD_opencv_shape                     OFF CACHE BOOL "" FORCE)
set(BUILD_opencv_stereo                    OFF CACHE BOOL "" FORCE)
set(BUILD_opencv_structured_light          OFF CACHE BOOL "" FORCE)
set(BUILD_opencv_superres                  OFF CACHE BOOL "" FORCE)
set(BUILD_opencv_surface_matching          OFF CACHE BOOL "" FORCE)
set(BUILD_opencv_text                      OFF CACHE BOOL "" FORCE)
set(BUILD_opencv_tracking                  OFF CACHE BOOL "" FORCE)
set(BUILD_opencv_videostab                 OFF CACHE BOOL "" FORCE)
set(BUILD_opencv_wechat_qrcode             OFF CACHE BOOL "" FORCE)
set(BUILD_opencv_xfeatures2d               OFF CACHE BOOL "" FORCE)
set(BUILD_opencv_ximgproc                  OFF CACHE BOOL "" FORCE)
set(BUILD_opencv_xobjdetect                OFF CACHE BOOL "" FORCE)
set(BUILD_opencv_xphoto                    OFF CACHE BOOL "" FORCE)

# Disable IPP (Intel Performance Primitives) — statically embeds a large precompiled
# x86 SIMD library. Responsible for ~11k of 24k exported symbols and a large share
# of binary size. Plain OpenCV SSE/AVX code is fast enough for screen-capture preprocessing.
set(WITH_IPP OFF CACHE BOOL "" FORCE)

# Tesseract disabled — app uses PaddleOCR, not Tesseract.
set(WITH_TESSERACT OFF CACHE BOOL "" FORCE)

# FFmpeg disabled — app captures screen frames via ThatCapture, not video files.
set(WITH_FFMPEG OFF CACHE BOOL "" FORCE)

# Disable all 3rdparty libs that are only used by the modules we disabled above.
# When a module is disabled but its WITH_xxx flag stays ON, OpenCV still configures
# the 3rdparty cmake target and exports it in OpenCVModules.cmake — but never builds
# the actual .a file. The bridge's find_package then fails with "file does not exist".
# Setting WITH_xxx OFF prevents the target from being configured at all.

# imgcodecs deps (imgcodecs disabled)
set(WITH_WEBP     OFF CACHE BOOL "" FORCE)
set(WITH_PNG      OFF CACHE BOOL "" FORCE)
set(WITH_TIFF     OFF CACHE BOOL "" FORCE)
set(WITH_JPEG     OFF CACHE BOOL "" FORCE)
set(WITH_OPENEXR  OFF CACHE BOOL "" FORCE)
set(WITH_JASPER   OFF CACHE BOOL "" FORCE)
set(WITH_OPENJPEG OFF CACHE BOOL "" FORCE)

# dnn deps (dnn disabled)
set(WITH_PROTOBUF OFF CACHE BOOL "" FORCE)
set(WITH_VULKAN   OFF CACHE BOOL "" FORCE)
set(WITH_OPENVINO OFF CACHE BOOL "" FORCE)

# objdetect dep — quirc is the QR code decoder inside objdetect (objdetect disabled)
set(WITH_QUIRC    OFF CACHE BOOL "" FORCE)

# Eigen — used as an optional accelerator for calib3d/features2d (both disabled)
set(WITH_EIGEN    OFF CACHE BOOL "" FORCE)

# Disable unused 3rd-party integrations
set(WITH_GSTREAMER OFF CACHE BOOL "" FORCE)
set(WITH_ADE       OFF CACHE BOOL "" FORCE)

# On Windows, disable bundled 3rd-party lib builds so OpenCV uses the vcpkg-provided
# versions instead. This ensures OpenCVModules.cmake references paths in
# vcpkg_installed/ (which exist) rather than uninstalled paths in opencv_artifacts/.
# These packages are guaranteed to be present via vcpkg.json dependencies.
if(WIN32)
  set(BUILD_ZLIB  OFF CACHE BOOL "" FORCE)
  set(BUILD_TIFF  OFF CACHE BOOL "" FORCE)
  set(BUILD_JPEG  OFF CACHE BOOL "" FORCE)
  set(BUILD_PNG   OFF CACHE BOOL "" FORCE)
  set(BUILD_WEBP  OFF CACHE BOOL "" FORCE)

  # Enable security hardening flags (/GS, /sdl, /guard:cf, /DYNAMICBASE, etc.)
  # to satisfy security audit requirements (issue #1841).
  # Note: opencv_videoio_ffmpeg*.dll is a pre-built binary downloaded from
  # https://github.com/opencv/opencv_3rdparty and is not affected by this flag.
  # Its security hardening status depends entirely on the OpenCV project's build pipeline.
  set(ENABLE_BUILD_HARDENING ON CACHE BOOL "" FORCE)
endif()

