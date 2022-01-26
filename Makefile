#
#  MAKEFILE -- The IDA Sendmail Enhancement Kit.
#  Copyright (c) 1987 Lennart Lovstrand
#  CIS Dept, Univ of Linkoping, Sweden
#
#  Use it, abuse it, but don't sell it.
#

#  Global definitions; will be exported to all Makefiles
MAN8DIR=	/usr/man/manl		# Place for the section 8 manuals
MAN8EXT=	.l			# Extension for section 8 manuals
MAN1DIR=	/usr/man/manl		# Place for the section 1 manuals
MAN1EXT=	.l			# Extension for section 1 manuals
BINDIR=		/usr/local/bin		# Where the binary aux files should go
LIBDIR=		/usr/lib/mail		# Where the data files should be
SRCDIR=		../../src		# The sendmail src subdirectory
INCLUDEDIR=	../../include		# The sendmail include subdirectory
DOCDIR=		../../doc		# The sendmail doc subdirctory
MDBM=		#-DMDBM -I$(SRCDIR)	# Only defined if you want to use mdbm
DBMLIB=		-ldbm			# Change to -lmdbm if you use mdbm
DBMDIREXT=	.dir			# Change to .map for mdbm
DBMPAGEXT=	.pag			# Change to .dat for mdbm
TROFF=		pstroff			# The [nt]roff program of your choice

configure:	config.ed
		@echo ">>> Propagating changes to subdirectories."
		for M in */Makefile; do \
			ed $$M <config.ed; \
		done

config.ed:	Makefile
		egrep '^[^#	].*=' Makefile | \
		sed -e 's/[ 	]*#.*$$//' -e 's/#.*$$//' \
			-e 's/^\(.*=\).*$$/g\/^\1\/c\\;&\\;./' | \
		tr ';' '\012' >$@
		echo w >>$@
		echo q >>$@

clean:
		-rm -f \#* *~ config.ed

spotless:	clean
		for d in */.; do \
			(cd $$d; make clean); \
		done
