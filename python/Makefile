#
# LSST Data Management System
# Copyright 2008, 2009 LSST Corporation.
#
# This product includes software developed by the
# LSST Project (http://www.lsst.org/).
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the LSST License Statement and
# the GNU General Public License along with this program.  If not,
# see <http://www.lsstcorp.org/LegalNotices/>.
#
# F. Pierfederici <fpierfed@gmail.com>
# M. Granvik

include ../make.config
include ../Makefile.include

# Work around f2py's "feature" where it doesn't add proper shared library
# linker flags if LDFLAGS are set. See https://github.com/numpy/numpy/issues/1171
# for more detail.
F2PY := f2py
ifneq ($(LDFLAGS),)
    ifeq ($(LIBEXT),dylib)
        F2PY := LDFLAGS="-undefined dynamic_lookup -bundle $(RPATHOPTS) $(LDFLAGS)" $(F2PY)
    else
        F2PY := LDFLAGS="$(FC_SHARED_GFORTRAN) $(LDFLAGS)" $(F2PY)
    endif
endif

all: liboorb.$(LIBEXT)

liboorb.o: liboorb.f90
	$(FC) -c $(FCOPTIONS) $(FC_INC)../$(CLASSPATH) \
	$(FC_INC)../$(MODULEPATH) $(FC_INC)../main liboorb.f90

wrapper.o: wrapper.f90 liboorb.o
	$(FC) -c $(FCOPTIONS) $(FC_INC)../$(CLASSPATH) \
	$(FC_INC)../$(MODULEPATH) \
	$(FC_INC)../main \
	wrapper.f90

liboorb.$(LIBEXT): modules classes main wrapper.o liboorb.o
	$(FC) $(FCOPTIONS) -shared -o liboorb.$(LIBEXT) \
	$(FC_INC)../$(CLASSPATH) $(FC_INC)../$(MODULEPATH) \
	liboorb.o wrapper.o \
	../main/io.o \
	../$(CLASSPATH)/*.o \
	../$(MODULEPATH)/*.o

pyoorb: liboorb
	$(F2PY) -m pyoorb pyoorb.f90 --build-dir ./build -c --noarch -loorb -L../lib \
	--f90exec=$(FC) --f90flags="$(FC_INC)../$(CLASSPATH) $(FC_INC)../$(MODULEPATH)" 

pyoorb.o: liboorb
	$(FC) -c $(FCOPTIONS) pyoorb.f90 $(FC_INC)../$(MAINPATH) \
	$(FC_INC)../$(CLASSPATH) $(FC_INC)../$(MODULEPATH)

liboorb:
	cd ../$(LIBPATH) ; make

test: test.f90 pyoorb.o
	$(FC) $(FCOPTIONS) pyoorb.o -loorb -L../lib test.f90 -o test



main:
	cd ../main/ ; make io.o

classes:
	cd ../$(CLASSPATH) ; $(MAKE) all

modules:
	cd ../$(MODULEPATH) ; $(MAKE) all


# Remove library and modules:
clean:
	rm -fr build *~ *.mod *.o \
	*.so *.dylib *.$(LIBEXT) *.pyc *.pyc.$(OS) \
	test

