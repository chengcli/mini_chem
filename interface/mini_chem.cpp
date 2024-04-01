// C/C++
#include <iostream>
#include <cstring>

// minichem
#include <mini_chem.h>
#include "mini_chem.hpp"

void MiniChem::Initialize() {
  read_react_list_(data_file_, species_file_,
                   network_dir_, metallicity_str_);
}

void MiniChem::Run(double T_in, double P_in, double t_end, 
                   double *VMR, std::string network) const 
{
  char network_str[MiniChem::kMaxStringLength + 1];
  set_fix_sized_string(network_str, network, MiniChem::kMaxStringLength);

  // Call Fortran subroutine
  mini_ch_dlsode_(&T_in, &P_in, &t_end, VMR, network_str);
}

void set_fix_sized_string(char dest[], const std::string &src, int len)
{
  snprintf(dest, len, "%s", src.c_str());
  std::fill(dest + src.size(), dest + len, ' ');
  dest[len] = '\0';
}

void interp_ce_table(int n_sp, double T_in, double P_in,
                     double *VMR, double *mu, std::string icfile)
{
  char icfile_str[MiniChem::kMaxStringLength + 1];
  set_fix_sized_string(icfile_str, icfile.c_str(), MiniChem::kMaxStringLength);

  interp_ce_table_(&n_sp, &T_in, &P_in, VMR, mu, icfile_str);
}
