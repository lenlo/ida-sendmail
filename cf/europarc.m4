# Sendmail configuration file for domain EuroPARC.Xerox.COM
define(ALIASES, %mail.aliases)dnl
define(DOMAINTABLE, %mail.domaintable)dnl
define(GENERICFROM, %mail.generics)dnl
define(MAILERTABLE, LIBDIR/mailertable)dnl
define(PATHTABLE, %mail.pathtable)dnl
define(PSEUDODOMAINS, BITNET CSNET JUNET MAILNET UUCP)dnl
define(RSH_SERVER, mailhost)dnl
define(UUCPNODES, |uuname)dnl
define(XEROXGV, Xerox.COM)dnl
define(XEROXNS, XNS.EuroPARC.Xerox.COM)dnl
define(XNSDOMAIN, IP:RX)dnl
define(XNSMAIL, /usr/local/bin/xnsmail)dnl
include(Sendmail.mc)dnl
