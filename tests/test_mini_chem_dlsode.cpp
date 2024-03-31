//! This file contains the usage and tests for the mini_chem_dlsode solver
// C/C++
#include <cassert>
#include <vector>

// mini_chem
#include <mini_chem/mini_chem.hpp>

int main(int argc, char **argv) {
  MiniChem mc;

  mc.SetDataFile("chem_data/mini_chem_data_NCHO.txt");
  mc.SetSpeciesFile("chem_data/mini_chem_sp_NCHO.txt");
  mc.SetNetworkDir("chem_data/1x/");
  mc.SetMetallicityStr("1x");

  mc.Initialize();

  std::string network = "NCHO";
  double T_in = 1500.;
  double P_in = 1.e6;
  int n_sp = 13;

  std::vector<double> vmr = {
    0.0, 0.9975, 0.001074, 0.0, 0.0, 0.0, 0., 0.00059024, 0, 0.00014159, 0.0, 0.0, 0.0
  };

  assert(vmr.size() == n_sp);

  //mini_chem.Run(T_in, P_in, t_end, vmr.data());
}
