//! \file mini_chem.h
//! \brief mini_chem dlsode C-Interface
// *****************************************************************************

#ifndef INTERFACE_MINI_CHEM_H_
#define INTERFACE_MINI_CHEM_H_

#define FEXPAND(mname,fname)   __ ## mname ## _ ## MOD ## _ ## fname

#define mini_ch_dlsode_ FEXPAND(mini_ch_i_dlsode, mini_ch_dlsode)
#define interp_ce_table_ FEXPAND(mini_ch_ce_interp, interp_ce_table)
#define read_react_list_ FEXPAND(mini_ch_read_reac_list, read_react_list)

#ifdef __cplusplus
extern "C" {
#endif 

void interp_ce_table_(int const *n_sp, 
                      double const *T_in,
                      double const *P_in, 
                      double *VMR, 
                      double *mu, 
                      char const * table);

void read_react_list_(char const *data_file, 
                      char const *sp_file, 
                      char const *net_dir, 
                      char const *met_str);

void mini_ch_dlsode_(double const *T_in, 
                     double const *P_in, 
                     double const *t_end,
                     double *VMR, 
                     char const * network);

#ifdef __cplusplus
} //  extern "C"
#endif 

#endif // INTERFACE_MINI_CHEM_H_
