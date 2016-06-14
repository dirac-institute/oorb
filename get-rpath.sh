#!/bin/bash
# Hack for gfortran compilers on El Capitan which have @rpath
# in their install_name.
#
# Prints out the rpath flags that should be passed to the compiler
# to add that rpath to the binaries we generate.
#
# Injected into the makefiles by ./configure
#

if [[ "$OSTYPE" != darwin* ]]; then
	# Only relevant on OS X
	exit -1;
fi

if [[ "$1" != gfortran ]]; then
	# Only know how to do this for gfortran
	exit -1;
fi

# Exit if no gfortran on the path
which "$1" >/dev/null 2>&1 || exit -1;

LIBDIR="$(dirname $(dirname $(which gfortran)))/lib"
LIBGFORTRAN="$LIBDIR/libgfortran.3.dylib"
if [[ -f "$LIBGFORTRAN" ]]; then
	INSTALL_NAME="$(otool -D $LIBGFORTRAN | tail -n 1)"
	if [[ $INSTALL_NAME == @rpath/* ]]; then
		RPATHFLAGS="-Wl,-rpath,$LIBDIR"
		echo "$RPATHFLAGS"
	fi
fi
