#ifndef INTERFACE_MINI_CHEM_HPP_  
#define INTERFACE_MINI_CHEM_HPP_

// C/C++ headers
#include <string>

class MiniChem {
 public:
  MiniChem() {}
  virtual ~MiniChem() {}

  void Initialize();
  void Run(double T_in, double P_in, double t_end, double *VMR) const;
 
 protected:
  int nspecies_;
  std::string data_file_;
  std::string species_file_;
  std::string network_dir_;
  std::string met_;
};

#endif // INTERFACE_MINI_CHEM_HPP_
