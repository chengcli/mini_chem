// C/C++
#include <iostream>
#include <cstring>

// minichem
#include "mini_chem.h"  
#include "mini_chem.hpp"

void MiniChem::Initialize() {
  read_react_list_(data_file_, species_file_,
                   network_dir_, metallicity_str_);
}

void MiniChem::Run(double T_in, double P_in, double t_end, double *VMR) const {
  // Call Fortran subroutine
  mini_ch_dlsode_(T_in, P_in, t_end, VMR, metallicity_str_);
}

void set_fix_sized_string(char dest[], const std::string &src, int len)
{
  snprintf(dest, len, "%s", src.c_str());
  std::fill(dest + src.size(), dest + len, ' ');
  dest[len] = '\0';
}
