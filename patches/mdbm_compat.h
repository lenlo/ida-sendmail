/**
 **	MDBM Compatibility File
 **
 **	These definitions will make sendmail use Maryland's mdbm
 **	library package instead of the new multifile database
 **	routines of 4.3.
 **
 **	Note: Don't use this if you already have ndbm.
 **/

#include <mdbm.h>

typedef struct mdbm DBMFILE;

#ifndef NDBM
# define NDBM
#endif NDBM
#ifndef MDBM
# define MDBM
#endif MDBM

/*
 *  Mdbm equivalents for ndbm functions
 */

#define DB_DIREXT	".map"
#define DB_PAGEXT	".dat"

#define DBM_REPLACE	MDBM_REPLACE
#define DBM_INSERT	MDBM_INSERT

#define dbm_dirfno(db)	((db)->mdbm_mapfd)
#define dbm_pagfno(db)	((db)->mdbm_datafd)

#define dbm_open(file, flags, mode) \
			mdbm_open(file, flags, mode, NULL, NULL, NULL)
#define dbm_close	mdbm_close
#define dbm_fetch	mdbm_fetch
#define dbm_store	mdbm_store
#define dbm_firstkey	mdbm_firstkey
#define dbm_nextkey	mdbm_nextkey /* don't forget to fill in 2nd param! */
