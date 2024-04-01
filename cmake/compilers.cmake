# Setup for GCC compiler:
#
if(CMAKE_Fortran_COMPILER_ID MATCHES "GNU")
  if(CMAKE_BUILD_TYPE STREQUAL "Debug")
    set(${PROJECT_NAME}_Fortran_FLAGS "-g3" 
      CACHE STRING INTERNAL "${PROJECT_NAME} Fortran compiler flags")
  elseif(CMAKE_BUILD_TYPE STREQUAL "Release")
    set(${PROJECT_NAME}_Fortran_FLAGS "-O3 -pipe"
      CACHE STRING INTERNAL "${PROJECT_NAME} Fortran compiler flags")
  else()
    message(FATAL_ERROR "Unknown build type: ${CMAKE_BUILD_TYPE}")
  endif()
  set(KNOWN_FORTRAN_COMPILER TRUE)
endif()

if(CMAKE_CXX_COMPILER_ID MATCHES "GNU")
  if(CMAKE_BUILD_TYPE STREQUAL "Debug")
    set(${PROJECT_NAME}_CXX_FLAGS "-g3"
      CACHE STRING INTERNAL "${PROJECT_NAME} CXX compiler flags")
  elseif(CMAKE_BUILD_TYPE STREQUAL "Release")
    set(${PROJECT_NAME}_CXX_FLAGS "-O3"
      CACHE STRING INTERNAL "${PROJECT_NAME} CXX compiler flags")
  else()
    message(FATAL_ERROR "Unknown build type: ${CMAKE_BUILD_TYPE}")
  endif()
  set(KNOWN_CXX_COMPILER TRUE)
endif()

# Setup for Clang compiler:
#
if (CMAKE_Fortran_COMPILER_ID MATCHES "Clang" )
  if(CMAKE_BUILD_TYPE STREQUAL "Debug")
    set(${PROJECT_NAME}_Fortran_FLAGS "-g3"
      CACHE STRING INTERNAL "${PROJECT_NAME} Fortran compiler flags")
  elseif(CMAKE_BUILD_TYPE STREQUAL "Release")
    set(${PROJECT_NAME}_Fortran_FLAGS "-O3 -pipe"
      CACHE STRING INTERNAL "${PROJECT_NAME} Fortran compiler flags")
  else()
    message(FATAL_ERROR "Unknown build type: ${CMAKE_BUILD_TYPE}")
  endif()
  set(KNOWN_FORTRAN_COMPILER TRUE)
endif()

if(CMAKE_CXX_COMPILER_ID MATCHES "Clang")
  if(CMAKE_BUILD_TYPE STREQUAL "Debug")
    set(${PROJECT_NAME}_CXX_FLAGS "-g3"
      CACHE STRING INTERNAL "${PROJECT_NAME} CXX compiler flags")
  elseif(CMAKE_BUILD_TYPE STREQUAL "Release")
    set(${PROJECT_NAME}_CXX_FLAGS "-O3"
      CACHE STRING INTERNAL "${PROJECT_NAME} CXX compiler flags")
  else()
    message(FATAL_ERROR "Unknown build type: ${CMAKE_BUILD_TYPE}")
  endif()
  set(KNOWN_CXX_COMPILER TRUE)
endif()

# Setup for ICC compiler:
#
if(CMAKE_Fortran_COMPILER_ID MATCHES "Intel")
  if(CMAKE_BUILD_TYPE STREQUAL "Debug")
    set(${PROJECT_NAME}_Fortran_FLAGS "-g3"
      CACHE STRING INTERNAL "${PROJECT_NAME} Fortran compiler flags")
  elseif(CMAKE_BUILD_TYPE STREQUAL "Release")
    set(${PROJECT_NAME}_Fortran_FLAGS "-O3 -pipe"
      CACHE STRING INTERNAL "${PROJECT_NAME} Fortran compiler flags")
  else()
    message(FATAL_ERROR "Unknown build type: ${CMAKE_BUILD_TYPE}")
  endif()
  set(KNOWN_FORTRAN_COMPILER TRUE)
endif()

if(CMAKE_CXX_COMPILER_ID MATCHES "Intel")
  if(CMAKE_BUILD_TYPE STREQUAL "Debug")
    set(${PROJECT_NAME}_CXX_FLAGS "-g3"
      CACHE STRING INTERNAL "${PROJECT_NAME} CXX compiler flags")
  elseif(CMAKE_BUILD_TYPE STREQUAL "Release")
    set(${PROJECT_NAME}_CXX_FLAGS "-O3"
      CACHE STRING INTERNAL "${PROJECT_NAME} CXX compiler flags")
  else()
    message(FATAL_ERROR "Unknown build type: ${CMAKE_BUILD_TYPE}")
  endif()
  set(KNOWN_CXX_COMPILER TRUE)
endif()

if (NOT KNOWN_FORTRAN_COMPILER)
  message(FATAL_ERROR "\nUnknown Fortran compiler!\n")
endif()

if (NOT KNOWN_CXX_COMPILER)
  message(FATAL_ERROR "\nUnknown C++ compiler!\n")
endif()
