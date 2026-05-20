/*
 * Copyright 1997, Regents of the University of Minnesota
 *
 * metis.h
 *
 * This file includes all necessary header files
 *
 * Started 8/27/94
 * George
 *
 * $Id: metislib.h 10655 2011-08-02 17:38:11Z benjamin $
 */

#ifndef _LIBMETIS_METISLIB_H_
#define _LIBMETIS_METISLIB_H_

#include "gklib#include#GKlib.h"

#if defined(ENABLE_OPENMP)
  #include <omp.h>
#endif


#include "metis#include#metis.h"
#include "metis#libmetis#rename.h"
#include "metis#libmetis#gklib_defs.h"

#include "metis#libmetis#defs.h"
#include "metis#libmetis#struct.h"
#include "metis#libmetis#macros.h"
#include "metis#libmetis#proto.h"


#if defined(COMPILER_MSC)
#if defined(rint)
  #undef rint
#endif
#define rint(x) ((idx_t)((x)+0.5))  /* MSC does not have rint() function */
#endif

#endif
