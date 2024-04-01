# compile the minichem module

string(TOLOWER ${CMAKE_BUILD_TYPE} buildl)
string(TOUPPER ${CMAKE_BUILD_TYPE} buildu)

set(namel minichem)
string(TOUPPER ${namel} nameu)

set(_${namel}_src
    dlsode.f
    mini_ch_ce_interp.f90 
    mini_ch_chem.f90
    mini_ch_class.f90
    mini_ch_i_dlsode.f90
    mini_ch_precision.f90
    mini_ch_read_reac_list.f90
    )

add_library(${namel}_${buildl}
    STATIC
    ${_${namel}_src}
    )

set_target_properties(${namel}_${buildl}
    PROPERTIES
    COMPILE_FLAGS ${MY_Fortran_FLAGS}
    )

add_library(minichem::minichemf ALIAS ${namel}_${buildl})
