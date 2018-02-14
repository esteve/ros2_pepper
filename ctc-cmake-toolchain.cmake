## Based on Aldebaran's CTC toolchain
## Copyright (C) 2011-2014 Aldebaran

# CMake toolchain file to cross compile on ARM

##
# Utility macros
#espace space (this allow ctc path with space)
macro(set_escaped name)
  string(REPLACE " " "\\ " ${name} ${ARGN})
endmacro()
#double!
macro(set_escaped2 name)
  string(REPLACE " " "\\\\ " ${name} ${ARGN})
endmacro()

set(TARGET_ARCH "i686")
set(TARGET_TUPLE "${TARGET_ARCH}-aldebaran-linux-gnu")

set(ALDE_CTC_CROSS $ENV{ALDE_CTC_CROSS})


if(" " STREQUAL "${ALDE_CTC_CROSS} ")
  message(FATAL_ERROR "Please define the ALDE_CTC_CROSS variable to the path of Aldebaran's Crosscompiler toolchain")
endif()

set(INSTALL_ROOT $ENV{INSTALL_ROOT})
if(" " STREQUAL "${INSTALL_ROOT} ")
    set(INSTALL_ROOT ".ros-root")
endif()

set(ALDE_CTC_SYSROOT "${ALDE_CTC_CROSS}/${TARGET_TUPLE}/sysroot")

set(ROS2_PEPPER $ENV{ROS2_PEPPER})

if(" " STREQUAL "${ROS2_PEPPER} ")
  set(ROS2_PEPPER ${CMAKE_CURRENT_LIST_DIR})
endif()

set(Eigen3_DIR ${ROS2_PEPPER}/cmake CACHE INTERNAL "" FORCE)

##
# Define the target...
# But first, force cross-compilation, even if we are compiling
# from linux-x86 to linux-x86 ...

# NOTE(esteve): disabled in favor of CMAKE_C_COMPILER and CMAKE_CXX_COMPILER, see below
# include(CMakeForceCompiler)

set(CMAKE_CROSSCOMPILING   ON)
# Then, define the target system
set(CMAKE_SYSTEM_NAME      "Linux")
set(CMAKE_SYSTEM_PROCESSOR "${TARGET_ARCH}")
set(CMAKE_EXECUTABLE_FORMAT "ELF")

##
# Probe the build/host system...
set(_BUILD_EXT "")
# sanity checks/host detection
if(WIN32)
  if(MSVC)
    # Visual studio
    message(FATAL_ERROR "Host not suppported")
  else()
    # mingw32
    set(_BUILD_EXT ".exe")
  endif()
else()
  if(APPLE)
    # Mac OS X (assume 64bit architecture)
    set(_BUILD_EXT "")
  else()
    # Linux
    set(_BUILD_EXT "")
  endif()
endif()

set(I_AM_A_ROBOT ON CACHE BOOL "this is always defined when we target a robot (valid values: ATOM)" FORCE)

# add the sysroot location to the CMAKE_PREFIX_PATH to correctly find
# libraries and headers coming with the cross-compiler
if(NOT DEFINED CMAKE_PREFIX_PATH)
  set(CMAKE_PREFIX_PATH)
endif()
list(APPEND CMAKE_PREFIX_PATH ${ALDE_CTC_SYSROOT})

# root of the cross compiled filesystem
# should be set but we do find_path in each module outside this folder !!!!
if(NOT CMAKE_FIND_ROOT_PATH)
 set(CMAKE_FIND_ROOT_PATH)
endif()
list(INSERT CMAKE_FIND_ROOT_PATH 0  "${ALDE_CTC_SYSROOT}")

# search for programs in the build host directories
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM BOTH)
# for libraries and headers in the target directories
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
# NOTE(esteve): added this to ensure more isolation from host system
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)

set(CMAKE_FIND_ROOT_PATH ${CMAKE_FIND_ROOT_PATH} CACHE INTERNAL "" FORCE)

# NOTE(esteve): replaced this with CMAKE_C_COMPILER AND CMAKE_CXX_COMPILER so that we can
# use CMAKE_C_STANDARD and CMAKE_CXX_STANDARD on our projects
# CMAKE_FORCE_C_COMPILER(  "${ALDE_CTC_CROSS}/bin/${TARGET_TUPLE}-gcc${_BUILD_EXT}" GNU)
# CMAKE_FORCE_CXX_COMPILER("${ALDE_CTC_CROSS}/bin/${TARGET_TUPLE}-g++${_BUILD_EXT}" GNU)
set(CMAKE_C_COMPILER "${ALDE_CTC_CROSS}/bin/${TARGET_TUPLE}-gcc${_BUILD_EXT}")
set(CMAKE_CXX_COMPILER "${ALDE_CTC_CROSS}/bin/${TARGET_TUPLE}-g++${_BUILD_EXT}")

set(CMAKE_LINKER  "${ALDE_CTC_CROSS}/bin/${TARGET_TUPLE}-ld${_BUILD_EXT}"      CACHE FILEPATH "" FORCE)
set(CMAKE_AR      "${ALDE_CTC_CROSS}/bin/${TARGET_TUPLE}-ar${_BUILD_EXT}"      CACHE FILEPATH "" FORCE)
set(CMAKE_RANLIB  "${ALDE_CTC_CROSS}/bin/${TARGET_TUPLE}-ranlib${_BUILD_EXT}"  CACHE FILEPATH "" FORCE)
set(CMAKE_NM      "${ALDE_CTC_CROSS}/bin/${TARGET_TUPLE}-nm${_BUILD_EXT}"      CACHE FILEPATH "" FORCE)
set(CMAKE_OBJCOPY "${ALDE_CTC_CROSS}/bin/${TARGET_TUPLE}-objcopy${_BUILD_EXT}" CACHE FILEPATH "" FORCE)
set(CMAKE_OBJDUMP "${ALDE_CTC_CROSS}/bin/${TARGET_TUPLE}-objdump${_BUILD_EXT}" CACHE FILEPATH "" FORCE)
set(CMAKE_STRIP   "${ALDE_CTC_CROSS}/bin/${TARGET_TUPLE}-strip${_BUILD_EXT}"   CACHE FILEPATH "" FORCE)

# If ccache is found, just use it:)
find_program(CCACHE "ccache")
if (CCACHE)
  message( STATUS "Using ccache")
endif(CCACHE)

if (CCACHE AND NOT FORCE_NO_CCACHE)
  set(CMAKE_C_COMPILER                 "${CCACHE}" CACHE FILEPATH "" FORCE)
  set(CMAKE_CXX_COMPILER               "${CCACHE}" CACHE FILEPATH "" FORCE)
  set_escaped2(CMAKE_C_COMPILER_ARG1   "${ALDE_CTC_CROSS}/bin/${TARGET_TUPLE}-gcc${_BUILD_EXT}")
  set_escaped2(CMAKE_CXX_COMPILER_ARG1 "${ALDE_CTC_CROSS}/bin/${TARGET_TUPLE}-g++${_BUILD_EXT}")
else(CCACHE AND NOT FORCE_NO_CCACHE)
  set_escaped(CMAKE_C_COMPILER         "${ALDE_CTC_CROSS}/bin/${TARGET_TUPLE}-gcc${_BUILD_EXT}")
  set_escaped(CMAKE_CXX_COMPILER       "${ALDE_CTC_CROSS}/bin/${TARGET_TUPLE}-g++${_BUILD_EXT}")
endif(CCACHE AND NOT FORCE_NO_CCACHE)

##
# Small hacks for qt: do not use the qmake from the system,
# force path to moc and rcc
set(QT_USE_QMAKE FALSE CACHE INTERNAL "" FORCE)

if(NOT TARGET Qt5::moc)
  add_executable(Qt5::moc IMPORTED)
  set_target_properties(Qt5::moc PROPERTIES
    IMPORTED_LOCATION "${ALDE_CTC_CROSS}/bin/moc${_BUILD_EXT}")
endif()
if(NOT TARGET Qt5::rcc)
  add_executable(Qt5::rcc IMPORTED)
  set_target_properties(Qt5::rcc PROPERTIES
    IMPORTED_LOCATION "${ALDE_CTC_CROSS}/bin/rcc${_BUILD_EXT}")
endif()

##
# Set pkg-config for cross-compilation
#set(PKG_CONFIG_EXECUTABLE  "${ALDE_CTC_CROSS}/bin/pkg-config" CACHE INTERNAL "" FORCE)
set(PKG_CONFIG_EXECUTABLE  "/usr/bin/pkg-config" CACHE INTERNAL "" FORCE)

##
# Set target flags
set_escaped(ALDE_CTC_CROSS   ${ALDE_CTC_CROSS})
set_escaped(ALDE_CTC_SYSROOT ${ALDE_CTC_SYSROOT})

set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -DI_AM_A_ROBOT")

set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} --sysroot ${ALDE_CTC_SYSROOT}/")
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -pipe -fomit-frame-pointer")

if(WITH_BREAKPAD)
  set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -g -ggdb -gdwarf-2")
endif()

if("${TARGET_ARCH}" STREQUAL "i686")
  set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -m32 -march=i686")
  set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -mssse3 -mfpmath=sse")
  set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -finline-functions-called-once -finline-small-functions")
  set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -falign-functions -falign-labels -falign-loops -falign-jumps")
  set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -freorder-blocks -freorder-blocks-and-partition -freorder-functions")
  set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -faggressive-loop-optimizations -ftree-vectorize -fpredictive-commoning")
elseif("${TARGET_ARCH}" STREQUAL "arm")
  set(CMAKE_C_FLAGS="${CMAKE_C_FLAGS} -O2")
  set(CMAKE_C_FLAGS="${CMAKE_C_FLAGS} -mabi=aapcs-linux -marm -march=armv7-a -mcpu=cortex-a9")
  set(CMAKE_C_FLAGS="${CMAKE_C_FLAGS} --param l1-cache-line-size=64 --param l1-cache-size=16 --param l2-cache-size=2048")
  set(CMAKE_C_FLAGS="${CMAKE_C_FLAGS} -mfpu=neon-vfpv4 -mfloat-abi=hard")
  set(CMAKE_C_FLAGS="${CMAKE_C_FLAGS} -mbranch-likely")
  set(CMAKE_C_FLAGS="${CMAKE_C_FLAGS} -falign-functions -falign-labels -falign-loops -falign-jumps")
  set(CMAKE_C_FLAGS="${CMAKE_C_FLAGS} -freorder-blocks -freorder-blocks-and-partition -freorder-functions")
  set(CMAKE_C_FLAGS="${CMAKE_C_FLAGS} -finline-functions-called-once -finline-small-functions")
  set(CMAKE_C_FLAGS="${CMAKE_C_FLAGS} -faggressive-loop-optimizations -ftree-vectorize -fpredictive-commoning")
endif()

set(_library_dirs
  "\
  -L${ALDE_CTC_CROSS}/boost/lib \
  -L${ALDE_CTC_CROSS}/bzip2/lib \
  -L${ALDE_CTC_CROSS}/icu/lib \
  -L${ALDE_CTC_CROSS}/jpeg/lib \
  -L${ALDE_CTC_CROSS}/png/lib \
  -L${ALDE_CTC_CROSS}/tiff/lib \
  -L${ALDE_CTC_CROSS}/zlib/lib \
  -L${ALDE_CTC_CROSS}/xz_utils/lib \
  "
)

set(CMAKE_C_FLAGS   "${CMAKE_C_FLAGS} ${_library_dirs}" CACHE INTERNAL "")
set(CMAKE_CXX_FLAGS "${CMAKE_C_FLAGS} -std=gnu++11 ${_library_dirs}" CACHE INTERNAL "")

##
# Make sure we don't have to relink binaries when we cross-compile
set(CMAKE_BUILD_WITH_INSTALL_RPATH ON)

set(Boost_NO_SYSTEM_PATHS ON CACHE INTERNAL "" FORCE)
# set(Boost_ADDITIONAL_VERSIONS "1.59" CACHE INTERNAL "" FORCE)
# set(Boost_USE_MULTITHREADED ON CACHE INTERNAL "" FORCE)
# set(Boost_LIBRARY_DIR_RELEASE "${ALDE_CTC_CROSS}/boost/lib" CACHE INTERNAL "" FORCE)

set(Boost_INCLUDE_DIR "${ALDE_CTC_CROSS}/boost/include" CACHE INTERNAL "" FORCE)
set(Boost_PYTHON_FOUND 1 CACHE INTERNAL "" FORCE)
set(Boost_PYTHON_LIBRARY "${ALDE_CTC_CROSS}/boost/lib/libboost_python-2.7.so" CACHE INTERNAL "" FORCE)

set(Boost_DEBUG 1 CACHE INTERNAL "" FORCE)
set(Boost_DETAILED_FAILURE_MSG 1 CACHE INTERNAL "" FORCE)

# NOTE(esteve): manually specify paths to libraries so that find_package() finds them
set(TinyXML_LIBRARY "${ALDE_CTC_CROSS}/tinyxml/lib/libtinyxml.so" CACHE INTERNAL "" FORCE)
set(TinyXML_INCLUDE_DIR "${ALDE_CTC_CROSS}/tinyxml/include" CACHE INTERNAL "" FORCE)

set(lz4_INCLUDE_DIRS "${ALDE_CTC_CROSS}/lz4/include" CACHE INTERNAL "" FORCE)
set(lz4_LIBRARIES "${ALDE_CTC_CROSS}/lz4/lib/liblz4.so" CACHE INTERNAL "" FORCE)

set(BZIP2_INCLUDE_DIR "${ALDE_CTC_CROSS}/bzip2/include" CACHE INTERNAL "" FORCE)
set(BZIP2_LIBRARIES "${ALDE_CTC_CROSS}/bzip2/lib/libbz2.so" CACHE INTERNAL "" FORCE)

set(JPEG_LIBRARY "${ALDE_CTC_CROSS}/jpeg/lib/libjpeg.so" CACHE INTERNAL "" FORCE)
set(JPEG_INCLUDE_DIR "${ALDE_CTC_CROSS}/jpeg/include" CACHE INTERNAL "" FORCE)

set(ZLIB_LIBRARY "${ALDE_CTC_CROSS}/zlib/lib/libz.so" CACHE INTERNAL "" FORCE)
set(ZLIB_INCLUDE_DIR "${ALDE_CTC_CROSS}/zlib/include" CACHE INTERNAL "" FORCE)

set(TIFF_LIBRARY "${ALDE_CTC_CROSS}/tiff/lib/libtiff.so" CACHE INTERNAL "" FORCE)
set(TIFF_INCLUDE_DIR "${ALDE_CTC_CROSS}/tiff/include" CACHE INTERNAL "" FORCE)

set(PNG_LIBRARY "${ALDE_CTC_CROSS}/png/lib/libpng.so" CACHE INTERNAL "" FORCE)
set(PNG_PNG_INCLUDE_DIR "${ALDE_CTC_CROSS}/png/include" CACHE INTERNAL "" FORCE)

set(EIGEN_INCLUDE_DIR "${ALDE_CTC_CROSS}/eigen3/include/eigen3" CACHE INTERNAL "" FORCE)

set(FLANN_LIBRARY "/home/nao/${INSTALL_ROOT}/ros1_dependencies/lib/libflann.so" CACHE INTERNAL "" FORCE)
set(FLANN_INCLUDE_DIR "/home/nao/${INSTALL_ROOT}/ros1_dependencies/include" CACHE INTERNAL "" FORCE)

set(QHULL_LIBRARY "/home/nao/${INSTALL_ROOT}/ros1_dependencies/lib/liblibqhull.so" CACHE INTERNAL "" FORCE)
set(QHULL_INCLUDE_DIR "/home/nao/${INSTALL_ROOT}/ros1_dependencies/include" CACHE INTERNAL "" FORCE)

link_directories(${ALDE_CTC_CROSS}/boost/lib)
link_directories(${ALDE_CTC_CROSS}/bzip2/lib)
link_directories(${ALDE_CTC_CROSS}/ffmpeg/lib)
link_directories(${ALDE_CTC_CROSS}/icu/lib)
link_directories(${ALDE_CTC_CROSS}/jpeg/lib)
link_directories(${ALDE_CTC_CROSS}/libtheora/lib)
link_directories(${ALDE_CTC_CROSS}/ogg/lib)
link_directories(${ALDE_CTC_CROSS}/opencore-amr/lib)
link_directories(${ALDE_CTC_CROSS}/openssl/lib)
link_directories(${ALDE_CTC_CROSS}/opus/lib)
link_directories(${ALDE_CTC_CROSS}/png/lib)
link_directories(${ALDE_CTC_CROSS}/speex/lib)
link_directories(${ALDE_CTC_CROSS}/tbb/lib)
link_directories(${ALDE_CTC_CROSS}/tiff/lib)
link_directories(${ALDE_CTC_CROSS}/v4l/lib)
link_directories(${ALDE_CTC_CROSS}/vo-aacenc/lib)
link_directories(${ALDE_CTC_CROSS}/vo-amrwbenc/lib)
link_directories(${ALDE_CTC_CROSS}/vorbis/lib)
link_directories(${ALDE_CTC_CROSS}/xz_utils/lib)
link_directories(${ALDE_CTC_CROSS}/zlib/lib)

set(_link_flags "")

# NOTE(esteve): Workarounds for missing symbols in the CTC libraries (e.g. ICU in Boost.Regex)
if(
  PROJECT_NAME STREQUAL "rosout" OR
  PROJECT_NAME STREQUAL "topic_tools" OR
  PROJECT_NAME STREQUAL "rosbag" OR
  PROJECT_NAME STREQUAL "rosconsole_bridge" OR
  PROJECT_NAME STREQUAL "image_transport" OR
  PROJECT_NAME STREQUAL "diagnostic_updater" OR
  PROJECT_NAME STREQUAL "tf2_ros" OR
  PROJECT_NAME STREQUAL "tf" OR
  PROJECT_NAME STREQUAL "kdl_parser" OR
  PROJECT_NAME STREQUAL "robot_state_publisher" OR
  PROJECT_NAME STREQUAL "nodelet")
  set(_link_flags
    "\
    -licudata \
    -licui18n \
    -licuuc \
    "
  )
elseif(
  PROJECT_NAME STREQUAL "naoqi_driver" OR
  PROJECT_NAME STREQUAL "image_proc"
)
  set(_link_flags
    "\
    -lbz2 \
    -licudata \
    -licui18n \
    -licuuc \
    -ljpeg \
    -llzma \
    -lpng16 \
    -ltiff \
    -lz \
    "
  )
elseif(PROJECT_NAME STREQUAL "urdfdom")
  set(_link_flags
    "\
    -lboost_timer \
    "
  )
elseif(
  PROJECT_NAME STREQUAL "rospack"
)
  set(_link_flags
    "\
    -ldl \
    -lutil \
    "
  )
elseif(
  PROJECT_NAME STREQUAL "OpenCV"
)
  set(_link_flags
    "\
    -ljpeg \
    -llzma \
    -lpng16 \
    -ltiff \
    -lz \
    "
  )
  elseif(
       PROJECT_NAME STREQUAL "PCL"
  )
    set(_link_flags
      "\
      -lbz2 \
      -lz \
      "
    )
endif()

set(EIGEN3_INCLUDE_DIR ${ALDE_CTC_CROSS}/eigen3/include/eigen3/ CACHE INTERNAL "" FORCE)
set(EIGEN3_FOUND TRUE CACHE INTERNAL "" FORCE)

set(CMAKE_EXE_LINKER_FLAGS "-Wl,--as-needed,--sysroot,${ALDE_CTC_SYSROOT}/ ${_link_flags}" CACHE INTERNAL "")
set(CMAKE_MODULE_LINKER_FLAGS "-Wl,--as-needed,--sysroot,${ALDE_CTC_SYSROOT}/ ${_link_flags}" CACHE INTERNAL "")
set(CMAKE_SHARED_LINKER_FLAGS "-Wl,--as-needed,--sysroot,${ALDE_CTC_SYSROOT}/ ${_link_flags}" CACHE INTERNAL "")

# set(OpenCV_DIR ${ALDE_CTC_CROSS}/opencv2/share/OpenCV/ CACHE INTERNAL "" FORCE)
