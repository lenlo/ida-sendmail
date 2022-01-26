#
#  MAKEFILE -- The Documentation Files.
#  Copyright (c) 1987 Lennart Lovstrand
#  CIS Dept, Univ of Linkoping, Sweden
#
#  Use it, abuse it, but don't sell it.
#

MAN1S=		dbm.1 mkdomext.1
MAN8S=		xalparse.8
MANS=		$(MAN1S) $(MAN8S)
DOC=		paper.ms
DOCS=		part1.ms part2.ms

#  The following definitions are inserted by ../Makefile
#  Change them there--not here!
MAN8DIR=	/usr/man/manl
MAN8EXT=	.l
MAN1DIR=	/usr/man/manl
MAN1EXT=	.l
TROFF=		pstroff

doc:		$(DOC)
		refer -e -l,2 -s $(DOC) | tbl | $(TROFF) -ms

doc.lpr:	$(DOC)
		refer -e -l,2 -s $(DOC) | tbl | nroff -ms > $@

man:		$(MANS)
		for m in $(MANS); do \
			$(TROFF) -man $$m; \
		done

man.lpr:	$(MANS)
		for m in $(MANS); do \
			nroff -man $$m > $$m.lpr; \
		done

$(DOC):
		cat $(DOCS) >$(DOC)
		-rm -f $(DOCS)

install:	$(MANS)
		for m in $(MAN1S); do \
			cp $$m $(MAN1DIR)/`basename $$m .1`$(MAN1EXT); \
		done
		for m in $(MAN8S); do \
			cp $$m $(MAN8DIR)/`basename $$m .8`$(MAN8EXT); \
		done

clean:
		-rm -f \#* *~ *.lpr
