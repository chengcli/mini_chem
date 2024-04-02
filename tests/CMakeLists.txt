string(TOLOWER ${CMAKE_BUILD_TYPE} buildl)

macro(minichem_setup_test namel)
  add_executable(${namel}.${buildl} ${namel}.cpp)

  set_target_properties(${namel}.${buildl}
                        PROPERTIES 
                        COMPILE_FLAGS ${${PROJECT_NAME}_CXX_FLAGS})

  target_include_directories(${namel}.${buildl}
                             PRIVATE ${MINICHEM_INCLUDE_DIR})

  target_link_libraries(${namel}.${buildl}
                        minichem::minichem++)

  add_test(NAME ${namel}.${buildl} COMMAND ${namel}.${buildl})
endmacro()

minichem_setup_test(test_mini_chem_dlsode)
