
macro(setup_test namel)
  string(TOLOWER ${CMAKE_BUILD_TYPE} buildl)
  string(TOUPPER ${CMAKE_BUILD_TYPE} buildu)

  add_executable(${namel}.${buildl} ${namel}.cpp)

  set_target_properties(${namel}.${buildl}
                        PROPERTIES 
                        COMPILE_FLAGS ${CMAKE_CXX_FLAGS_${buildu}})

  target_include_directories(
    ${namel}.${buildl}
    PRIVATE ${MINICHEM_INCLUDE_DIR})

  target_link_libraries(
    ${namel}.${buildl}
    ${MINICHEM_LIBRARY_${buildu}}
    )

  add_test(NAME ${namel}.${buildl} COMMAND ${namel}.${buildl})
endmacro()

message(STATUS "MINICHEM_INCLUDE_DIR: ${MINICHEM_INCLUDE_DIR}")
setup_test(test_mini_chem_dlsode)
