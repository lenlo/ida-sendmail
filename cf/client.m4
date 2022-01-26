# Sendmail configuration file for Sun-3 clients (*.liu.se)
define(ALIASES, LIBDIR/aliases)
define(DECNETXTABLE, LIBDIR/decnet/xtable)
define(DECNETNODES, LIBDIR/decnet/nodes)
define(DEFAULT_DOMAIN, liu.se)
define(DOMAINTABLE, LIBDIR/domaintable)
define(GENERICFROM, LIBDIR/generics)
define(LIUIDA)
define(PSEUDONYMS, all)
define(RELAY_HOST, majestix)
define(RELAY_MAILER, TCP)
define(RSH_SERVER, majestix)
include(Sendmail.mc)