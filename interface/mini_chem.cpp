// minichem
#include "mini_chem.h"  
#include "mini_chem.hpp"

void MiniChem::Initialize() {
  read_react_list_(data_file_.c_str(), species_file_.c_str(), network_dir_.c_str(), met_.c_str());
}

void MiniChem::Run(double T_in, double P_in, double t_end, double *VMR) const {
  // Call the C++ function
  mini_ch_dlsode_(T_in, P_in, t_end, VMR, met_.c_str());
}
