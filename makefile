# for gfortran Compiler
#===================

F90 = gfortran
F90LINKER =  gfortran

#Debugging and development flags
#FFLAGS	= -Og -g -pipe -Wall -Wextra -fbacktrace -fcheck=all -ffpe-trap=invalid,zero,overflow
#FFLAGS	= -Og -pipe -Wall -Wextra -g -fbacktrace

#Serial flags
FFLAGS  = -O3 -pipe

#Parallel flags
#FFLAGS	= -O3 -pipe -fopenmp

# for ifort Compiler
#====================

#F90 = ifort
#F90LINKER = ifort

#FFLAGS   = -O0 -g -traceback -fpp -prec-div -fp-model source -fpe0 -ipo
#FFLAGS    = -O0 -g -traceback -xHost -fpp -fp-model source -qopenmp -ipo
#FFLAGS    = -O3 -xHost -qopenmp -fpp -fp-model source -ipo

#====================

DEFS      =
INCLUDES  =
LFLAGS    = $(FFLAGS)


OBJECTS = \
lapack.o \
lapackc.o \
dc_lapack.o \
seulex.o \
rodas.o \
radau5.o \
dvode.o \
dlsode.o \
mini_ch_precision.o \
mini_ch_class.o \
mini_ch_read_reac_list.o \
mini_ch_chem.o \
mini_ch_i_seulex.o \
mini_ch_i_rodas.o \
mini_ch_i_radau5.o \
mini_ch_i_dvode.o \
mini_ch_i_dlsode.o \
mini_ch_main.o \


# executable statement
EXECS  = mini_chem

.SUFFIXES : .o .f90 .f

default: mini_chem

mini_chem: $(OBJECTS)
	$(F90LINKER) $(LFLAGS) $(OBJECTS) -o $(EXECS)

clean:
	rm -f *.o *.mod *~ *__genmod.f90 $(EXECS)

.f90.o:
	$(F90) $(FFLAGS) $(DEFS) -c $<

.f.o:
	$(F90) $(FFLAGS) $(DEFS) -c $<
