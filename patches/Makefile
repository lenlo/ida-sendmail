#
#  MAKEFILE -- Sendmail Patches.
#  Copyright (c) 1987 Lennart Lovstrand
#  CIS Dept, Univ of Linkoping, Sweden
#
#  Use it, abuse it, but don't sell it.
#

SRCDIFFS=	Makefile.diff Version.c.diff alias.c.diff \
		arpadate.c.diff conf.c.diff conf.h.diff daemon.c.diff \
		deliver.c.diff domain.c.diff headers.c.diff macro.c.diff \
		main.c.diff parseaddr.c.diff queue.c.diff readcf.c.diff \
		recipient.c.diff savemail.c.diff sendmail.h.diff \
		srvrsmtp.c.diff usersmtp.c.diff util.c.diff
DOCDIFFS=	op.me.diff


#  The following definitions are inserted by ../Makefile
#  Change them there--not here!
MDBM=
DBMLIB=		-ldbm
SRCDIR=		../../src
DOCDIR=		../../doc

patch:
		for f in $(SRCDIFFS); do \
			patch $(SRCDIR)/`basename $$f .diff` $$f; \
		done
		for f in $(DOCDIFFS); do \
			patch $(DOCDIR)/`basename $$f .diff` $$f; \
		done
		-if [ -n "$(MDBM)" ]; then \
			cp mdbm_compat.h $(SRCDIR); \
			patch -d $(SRCDIR) -b .old < MDBM.diffs; \
			sh MDBM.edit $(SRCDIR) $(DBMLIB); \
		fi

backup:
		tar cvf Backup.tar $(SRCDIR)/*.[hc] $(DOCDIR)/op.me

restore:
		tar xvf Backup.tar

clean:
		-rm -f \#* *~ Backup.tar
