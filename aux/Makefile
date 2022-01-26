#
#  MAKEFILE -- Auxiliary Files.
#  Copyright (c) 1987 Lennart Lovstrand
#  CIS Dept, Univ of Linkoping, Sweden
#
#  Use it, abuse it, but don't sell it.
#
#  Rmail has it's own options, go change them there.
#

BINS=		dbm mkdomext scanf xalparse
CFLAGS=		-O -DVMUNIX -I$(INCLUDEDIR)

#  The following definitions are inserted by ../Makefile
#  Change them there--not here!
BINDIR=		/usr/local/bin
LIBDIR=		/usr/lib/mail
SRCDIR=		../../src
INCLUDEDIR=	../../include
DBMLIB=		-ldbm

all:		$(BINS) rmail

dbm:		dbm.c
		$(CC) $(CFLAGS) $(MDBM) -o dbm dbm.c $(DBMLIB)

rmail:		rmail.c
		$(CC) $(CFLAGS) $(MDBM) -o rmail rmail.c $(DBMLIB)

install:	$(BINS)
		cp $(BINS) $(BINDIR)
		cd $(BINDIR); strip $(BINS)
		@echo '>>> Do "make install-rmail" to explitly install rmail.'

install-rmail:	rmail
		install -m 4755 -o root -s rmail /bin

clean:
		-rm -f \#* *~ *.o $(BINS) rmail

.c.o:
		$(CC) $(CFLAGS) -c $<

.c:
		$(CC) $(CFLAGS) -o $@ $<
