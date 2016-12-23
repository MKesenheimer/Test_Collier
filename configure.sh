#!/bin/sh
# calls the LoopTools and SLHAlib configure scripts

WORKINGDIR=$(pwd)
COLLIER=$WORKINGDIR/COLLIER-1.1
LT=$WORKINGDIR/LoopTools-2.12

COMPILER=$1
if [ "$1" = "" ]; then
  COMPILER=gfortran
fi

mkdir -p $COLLIER/build
cd $LT && ./configure FC=$COMPILER
cd $COLLIER/build && cmake -DCMAKE_Fortran_COMPILER=$COMPILER -Dstatic=ON ..