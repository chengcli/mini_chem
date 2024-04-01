//! This file contains the usage and tests for the mini_chem_dlsode solver
// C/C++
#include <cassert>
#include <vector>
#include <iostream>

// mini_chem
#include <minichem/mini_chem.hpp>

int main(int argc, char **argv) {
  MiniChem mc;

  mc.SetDataFile("chem_data/mini_chem_data_NCHO.txt");
  mc.SetSpeciesFile("chem_data/mini_chem_sp_NCHO.txt");
  mc.SetNetworkDir("chem_data/1x/");
  mc.SetMetallicityStr("1x");

  mc.Initialize();

  int n_sp = 13;

  // interpolate from ce table
  std::vector<double> vmr_ic(n_sp);
  std::string ic_file = "chem_data/IC/mini_chem_IC_FastChem_1x.txt";

  double mu;
  double T_in = 1500.;
  double P_in = 1.e6;
  interp_ce_table(n_sp, T_in, P_in, vmr_ic.data(), &mu, ic_file);

  std::cout << "mu: " << mu << std::endl;
  for (int i = 0; i < n_sp; ++i) {
    std::cout << "vmr[" << i << "]: " << vmr_ic[i] << std::endl;
  }

  std::cout << "run mini_chem" << std::endl;

  std::vector<double> vmr = {
    0.0, 0.9975, 0.001074, 0.0, 0.0, 0.0, 0., 0.00059024, 0, 0.00014159, 0.0, 0.0, 0.0
  };
  assert(vmr.size() == n_sp);

  double t_step = 60.;

  // NOTE:
  // In src_mini_chem_dlsode/main.f90, the subroutine mini_ch_dlsode 
  // was called with:
  //  call mini_ch_dlsode(T_in, P_in, t_step, VMR(1:n_sp-1), network)
  // So the size of VMR is n_sp-1, not n_sp.
  // The last species is not passed to the subroutine.
  mc.Run(T_in, P_in, t_step, vmr.data(), "NCHO");

  for (int i = 0; i < n_sp; ++i) {
    std::cout << "vmr[" << i << "]: " << vmr[i] << std::endl;
  }
}
