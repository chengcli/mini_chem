# Include path
#
#   include: minichem
#
# Library files
#   
#   library: libminichem_debug.a
#   library: libminichem_release.a
#
# Usage would be
#
#   include_directories(${MINICHEM_INCLUDE_DIR})
#   target_link_libraries(minichem::minichemf minichem::minichem++)

cmake_minimum_required(VERSION 3.10)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

project(
  minichem
  HOMEPAGE_URL https://github.com/chengcli/mini_chem
  LANGUAGES CXX Fortran
  DESCRIPTION "C++ interface to the minichem library"
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
include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/compilers.cmake)

## 2. set up project specific configuration ##
message(STATUS "2. Set up project specific configuration ...")

message(STATUS "3. Set up minichem source codes")
add_subdirectory(src_mini_chem_dlsode)
add_subdirectory(interface)

set(MINICHEM_INCLUDE_DIR 
  "${CMAKE_CURRENT_SOURCE_DIR}"
  CACHE PATH INTERNAL "Path to minichem include directory")

add_subdirectory(tests)
