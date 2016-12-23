########################################################################
#                          -*- Makefile -*-                            #
########################################################################
# General Conventions for Makefiles
SHELL = /bin/sh
.SUFFIXES:
.SUFFIXES: .c .f .F .cc .cpp .h .hh .inc .o .a
.DEFAULT_GOAL := main

########################################################################
## Flags

## Compiler and additional compiler Flags
# use "./configure ifort" first
#FC  = ifort
# use "./configure gfortran" first
FC  = gfortran
CXX = g++
CC  = gcc

# p-flag to enable code profiling with gprof: gprof ./pwhg_main* gmon.out > analysis.txt
FCFLAGS  = -g
CXXFLAGS = -g
CFLAGS   = -g
  
# recommended compiler flags
ifeq ($(FC), ifort)
  LDFLAGS  = -pg
  REC_FCFLAGS   = -fpp -extend-source
  REC_FCFLAGS  += $(FCFLAGS)
else ifeq ($(FC), gfortran)
  LDFLAGS  = -ff2c -pg
  REC_FCFLAGS   = -fno-automatic -fno-range-check
  REC_FCFLAGS  += -ffixed-line-length-none -lgfortran -DU77EXT=0 -DQuad=0
  REC_FCFLAGS  += -ff2c -fno-second-underscore
  REC_FCFLAGS  += $(FCFLAGS)
  #$(error $(REC_FCFLAGS))
endif
REC_CXXFLAGS  = -fomit-frame-pointer -ffast-math -Wall -m64
REC_CXXFLAGS += $(CXXFLAGS)
REC_CFLAGS    = -fomit-frame-pointer -ffast-math -Wall -m64
REC_CFLAGS   += -DNOUNDERSCORE=0 -DBIGENDIAN=0
REC_CFLAGS   += $(CFLAGS)

UNAME = $(shell uname)
ifeq ($(UNAME), Darwin)
  #Mac OSX
  REC_CFLAGS   += -stdlib=libstdc++ -mmacosx-version-min=10.6 -Qunused-arguments
  REC_CXXFLAGS += -stdlib=libstdc++ -mmacosx-version-min=10.6 -Qunused-arguments
endif

## PDF
## choose PDF: native,lhapdf
## LHAPDF package has to be installed separately
## wheter to link precompiled LHAPDF library statically or compile it 
## from source (static, none)
PDF = lhapdf
PDFSTATIC = none

## path to static lhapdf library
#STATICLIBSLHAPDF = /opt/lib/libLHAPDF.a

## choose analysis: none, default
ANALYSIS = default

## path to LHAPDF config executable
LHAPDF_CONFIG = lhapdf-config

## path to fastjet config executable
FASTJET_CONFIG = fastjet-config

## Pythia8
# if you want to use Pythia8 instead of Pythia6 uncomment the following
#USE_PYTHIA8 = yes
# path to pythia8-config executable
# (uncomment only if you want to use a locally installed Pythia8)
#PYTHIA8_CONFIG = pythia8-config

# (not necessary anymore)
## path to fortran and c++ libraries
# (use $locate libstdc++.a to find the library)
#ifeq ($(UNAME), Darwin)
#  #Mac OSX
#  LIBGFORTRANPATH = /usr/local/lib
#  LIBSTDCPPPATH   = /usr/local/lib
#else
#  #Linux 
#  LIBGFORTRANPATH = /usr/lib/gcc/x86_64-linux-gnu/4.8
#  LIBSTDCPPPATH   = /usr/lib/gcc/x86_64-linux-gnu/4.8
#endif

## warning for type-conversions -> basically useless, as those occur in
## too many places
#WARN  = -Wconversion -Wall -Wtabs -Wall -Wimplicit-interface
## -fbounds-check sometimes causes a weird error due to non-lazy
## evaluation of boolean in gfortran.
#WARN += -fbounds-check
## gfortran 4.4.1 optimized with -O3 yields erroneous results
## Use -O2 to be on the safe side
OPT = -O2

### generate directory build, if not yet existing
$(shell mkdir -p build)

########################################################################
## Runtime flags

## Preprocessor
# it might be advisable to use the -ffree-line-length-none 
# or -ffixed-line-length-none options
CPP = -cpp

## For debugging uncomment the following, choose a number between 0 and 
# 4 to choose the level of verbosity (higher means more output).
LEVEL = 0
DEBUG = -ggdb -pg -DDEBUG=$(LEVEL)

## More debugging flags
# Check UV finiteness in FormCalc Virtuals: -DCHECKUV
# Check if MadGraph and FormCalc born amplitudes are the same during 
# calculation and abort if they are not: -DCHECK_FORM_MAD
# Note: Use this only for testing born amplitudes, not for the final 
# program and not while checking real amplitudes!
#USRFLAGS += -DCHECK_FORM_MAD

########################################################################
#           -*- no editing is required below this line -*-             #
########################################################################

########################################################################
## Paths

WORKINGDIR = $(shell pwd)
COLLIER = $(WORKINGDIR)/COLLIER-1.1
COLLIERINTERFACE = $(WORKINGDIR)/collier
LT = $(WORKINGDIR)/LoopTools-2.12

# includes
CINCLUDE = $(WORKINGDIR)/collier/include
LTINCLUDE   = $(WORKINGDIR)/LoopTools-2.12/src/include

# modules
ifeq ($(UNAME), Darwin)
  #Mac OSX
  CMODULES = $(COLLIERINTERFACE)/modules/MacOSX_$(FC)
endif
ifeq ($(UNAME), Linux)
  #Linux
  CMODULES = $(COLLIERINTERFACE)/modules/Linux_$(FC)
endif

########################################################################
## search for the files and set paths

vpath %.f $(WORKINGDIR)
vpath %.F90 $(WORKINGDIR)/collier
vpath %.o $(WORKINGDIR)/build

########################################################################
## Source files

### USER Files ###
USER = main.o

### Functions
FUNC = lt_collier_interface_complex.o

SOURCESMAIN = $(USER) $(FUNC)

########################################################################
## Libraries

### COLLIER ###
LIBS += libcollier.a

### LoopTools ###
LIBS += libooptools.a

########################################################################
## combine all flags, libraries and includes

ALL_FCFLAGS   = $(REC_FCFLAGS) $(OPT) $(WARN) $(CPP) $(DEBUG) $(USRFLAGS)
ALL_FCFLAGS  += -I$(CINCLUDE) -I$(LTINCLUDE)

ALL_FCFLAGS  += -J$(CMODULES)

LINKER = $(CPPFLAGS) $(LIBS) $(LDFLAGS)

HEADERS += $(wildcard *.h $(CINCLUDE)/*.h $(LTINCLUDE)/*.h)
HEADERS += $(wildcard *.mod $(CMODULES)/*.mod)

########################################################################
## Rules, generate objects

%.o: %.f $(HEADERS)
	@echo "Compiling:" $<
	@$(FC) $(ALL_FCFLAGS) -c -o build/$@ $<

%.o: %.F90 $(HEADERS)
	@echo "Compiling:" $<
	@$(FC) $(ALL_FCFLAGS) -c -o build/$@ $<

########################################################################
## Rules, link
## type make -j4 [rule] to speed up the compilation

libcollier.a:
	cd $(COLLIER)/build && make
	mkdir -p $(CMODULES)
	cp $(COLLIER)/modules/*.mod $(CMODULES)

liblooptools.a:
	cd $(LT) && make FC="$(FC)" F77="$(FC)" FFLAGS="$(ALL_FCFLAGS)" CXXFLAGS="$(REC_CXXFLAGS)" CFLAGS="$(REC_CFLAGS)"

libs: libcollier.a liblooptools.a

main: $(SOURCESMAIN)
	$(FC) $(ALL_FCFLAGS) $(patsubst %,build/%,$(SOURCESMAIN)) $(LINKER) -o $@

clean-libs:
	cd $(COLLIER) && rm -rf build/*

clean:
	  rm -f build/*.o main *.a

clean-all: clean-libs clean

########################################################################
#                       -*- End of Makefile -*-                        #
########################################################################
