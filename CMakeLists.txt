# Installs mini_chem library
#   
#   library: libminichem_debug.a
#   library: libminichem_release.a
#
# Define the following variables
#
#   MINICHEM_INCLUDE_DIR
#   MINICHEM_LIBRARY_DEBUG
#   MINICHEM_LIBRARY_RELEASE
#
# Normal usage would be
#
#   include_directories( ${MINICHEM_INCLUDE_DIR})
#   target_link_libraries( ${MINICHEM_LIBRARY_DEBUG})
#
cmake_minimum_required(VERSION 3.10)

project(
  MINICHEM
  LANGUAGES CXX Fortran
  )

if (NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE Release)
  message(STATUS "Default Build Type = Release")
  message(STATUS "")
else()
  message(STATUS "Build Type = ${CMAKE_BUILD_TYPE}")
  message(STATUS "")
endif()

LIST(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/cmake/modules/)

## 1. set up compiler flags ##
message(STATUS "1. Set up project compiler flags ...")
message(STATUS "Include ${CMAKE_SOURCE_DIR}/cmake/compilers.cmake")
include(${CMAKE_SOURCE_DIR}/cmake/compilers.cmake)

## 2. set up project specific configuration ##
message(STATUS "2. Set up project specific configuration ...")

message(STATUS "Set up rrtmg_sw source codes")
add_subdirectory(src_mini_chem_dlsode)
add_subdirectory(interface)

set(MINICHEM_INCLUDE_DIR
  "${CMAKE_CURRENT_SOURCE_DIR}"
  CACHE INTERNAL "mini_chem include directory")

add_subdirectory(tests)

