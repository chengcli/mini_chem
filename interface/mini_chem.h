//! \file mini_chem.h
//! \brief mini_chem dlsode C-Interface
// *****************************************************************************

#ifndef INTERFACE_MINI_CHEM_H_
#define INTERFACE_MINI_CHEM_H_

#define FEXPAND(mname,fname)   __ ## mname ## _ ## MOD ## _ ## fname

#define mini_ch_dlsode_ FEXPAND(mini_ch_i_dlsode, mini_ch_dlsode)
#define interp_ce_table_ FEXPAND(mini_ch_ce_interp, interp_ce_table)
#define read_react_list_ FEXPAND(mini_ch_read_react_list, read_react_list)

#ifdef __cplusplus
extern "C" {
#endif 

void interp_ce_table_(int n_sp, double T_in, double P_in, double *VMR, double mu, char const * table);

void read_react_list_(char const * data_file, char const * sp_file, char const * net_dir, char const * met);

void mini_ch_dlsode_(double T_in, double P_in, double t_end, double *VMR, char const * network);

#ifdef __cplusplus
} //  extern "C"
#endif 

#endif // INTERFACE_MINI_CHEM_H_
