#ifndef INTERFACE_MINI_CHEM_HPP_  
#define INTERFACE_MINI_CHEM_HPP_

// C/C++ headers
#include <string>
#include <cstring>

void set_fix_sized_string(char dest[], const std::string &src, int len);

class MiniChem {
 public:
  static constexpr int kMaxStringLength = 200;

  MiniChem() {}
  virtual ~MiniChem() {}

  void SetDataFile(const std::string &data_file) {
    set_fix_sized_string(data_file_, data_file, kMaxStringLength);
  }

  void SetSpeciesFile(const std::string &species_file) {
    set_fix_sized_string(species_file_, species_file, kMaxStringLength);
  }

  void SetNetworkDir(const std::string &network_dir) {
    set_fix_sized_string(network_dir_, network_dir, kMaxStringLength);
  }

  void SetMetallicityStr(const std::string &metallicity_str) {
    set_fix_sized_string(metallicity_str_, metallicity_str, kMaxStringLength);
  }

  void Initialize();
  void Run(double T_in, double P_in, double t_end, double *VMR) const;
 
 protected:
  int nspecies_;
  char data_file_[kMaxStringLength + 1];
  char species_file_[kMaxStringLength + 1];
  char network_dir_[kMaxStringLength + 1];
  char metallicity_str_[kMaxStringLength + 1];
};

#endif // INTERFACE_MINI_CHEM_HPP_
