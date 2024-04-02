# Installs minichem++ interface

set(namel "minichem++")
string(TOUPPER ${namel} nameu)

if(CMAKE_Fortran_COMPILER_ID MATCHES "GNU")
  set(${PROJECT_NAME}_FEXPAND "__ ## mname ## _MOD_ ## fname"
    CACHE INTERNAL "Fortran name mangling macro")
elseif(CMAKE_Fortran_COMPILER_ID MATCHES "Intel")
  set(${PROJECT_NAME}_FEXPAND "mname ## _mp_ ## fname ## _"
    CACHE INTERNAL "Fortran name mangling macro")
else()
  message(FATAL_ERROR "Unsupported Fortran compiler")
endif()

file(GLOB src_files
    *.cpp
    )

string(TOLOWER ${CMAKE_BUILD_TYPE} buildl)
string(TOUPPER ${CMAKE_BUILD_TYPE} buildu)

add_library(${namel}_${buildl}
    OBJECT
    ${src_files}
    )

set_target_properties(${namel}_${buildl}
    PROPERTIES
    COMPILE_FLAGS ${${PROJECT_NAME}_CXX_FLAGS}
    )

target_include_directories(${namel}_${buildl}
    PRIVATE
    ${CMAKE_CURRENT_BINARY_DIR}
    )

target_link_libraries(${namel}_${buildl}
    minichem::minichemf
    )

configure_file(mini_chem.h.in mini_chem.h @ONLY)

add_library(minichem::minichem++ ALIAS ${namel}_${buildl})
