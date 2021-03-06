# Sendmail configuration file for host majestix.liu.se
define(ALIASES, LIBDIR/aliases)
define(DECNETXTABLE, LIBDIR/decnet/xtable)
define(DECNETNODES, LIBDIR/decnet/nodes)
define(DEFAULT_DOMAIN, liu.se)
define(DOMAINTABLE, LIBDIR/domaintable)
define(GENERICFROM, LIBDIR/generics)
define(LIUIDA)
define(MAILERTABLE, LIBDIR/mailertable)
define(PATHTABLE, LIBDIR/pathtable)
define(PSEUDONYMS, ida.liu.se liuida all)
define(UUCPNAME, liuida)
define(UUCPNODES, /usr/lib/uucp/L.sys)
define(UUCPRELAYS, LIBDIR/uucp/relays)
define(UUCPXTABLE, LIBDIR/uucp/xtable)
include(Sendmail.mc)
