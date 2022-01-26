#
#  MAKEFILE -- Library Files.
#  Copyright (c) 1987, 1988 Lennart Lovstrand
#  CIS Dept, Univ of Linkoping, Sweden
#
#  Use it, abuse it, but don't sell it.
#
#  EuroPARC version without DECnet.
#  Remove those files from TABLES that you aren't using.


LOCALDOMAINS=	EuroPARC.Xerox.COM UUCP		# only if domaintable is used
PATHFLAGS=	-C25 -i -lEuroNet
SENDMAIL=	/usr/lib/sendmail
SKILL=		/usr/local/bin/skill		# not required
TABLES=		$(YP)domaintable$(DBMDIREXT) $(YP)generics$(DBMDIREXT) \
		$(YP)pathtable$(DBMDIREXT) $(YP)aliases$(DBMDIREXT)
#		mailertable$(DBMDIREXT) uucp/xtable$(DBMDIREXT)
UUCPNODES=	/usr/lib/uucp/L.sys
# Prefix for YP dbm files; remove this if you won't be using YP databases
YP=		/etc/yp/europarc/mail.


#  The following definitions are inserted by ../Makefile
#  Change them there--not here!
DBMDIREXT=	.dir
DBMPAGEXT=	.pag


#  Update all dbm tables
all:	$(TABLES)

aliases generics:	xaliases
	xalparse xaliases aliases generics

$(YP)aliases$(DBMDIREXT):	aliases newaliases.cf $(YP)domaintable$(DBMDIREXT)
	$(SENDMAIL) -Cnewaliases.cf -bi
	if [ -n "$(YP)" ]; then \
		mv aliases.dir $(YP)aliases.dir; \
		mv aliases.pag $(YP)aliases.pag; \
	fi

$(YP)generics$(DBMDIREXT):	generics
	dbm -L make generics $(YP)generics

$(YP)domaintable$(DBMDIREXT):	domaintable
	if [ -n "$(LOCALDOMAINS)" ]; then \
		dbm parse domaintable | mkdomext $(LOCALDOMAINS) |\
			dbm -IL load $(YP)domaintable; \
	else \
		dbm parse domaintable | dbm -IL load $(YP)domaintable; \
	fi

$(YP)pathtable$(DBMDIREXT):	pathtable
	pathalias $(PATHFLAGS) pathtable | dbm load $(YP)pathtable

mailertable$(DBMDIREXT):	mailertable
	dbm -L make mailertable mailertable

uucp/xtable$(DBMDIREXT):	uucp/xtable $(UUCPNODES)
	(dbm parse uucp/xtable; \
	 awk '{printf "%s.UUCP\t%s\n", $$1, $$1}' $(UUCPNODES)) | \
	 dbm -IL load uucp/xtable

stop:
	-$(SKILL) sendmail

restart:	stop
	$(SENDMAIL) -bd -q30m

clean:
	-rm -f \#* *~ *.dir *.pag *.map *.dat */*.dir */*.pag */*.map */*.dat
