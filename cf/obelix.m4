# Sendmail configuration file for host obelix.UUCP
define(ALIASES, LIBDIR/aliases)
define(BSD29)
define(DEFAULT_DOMAIN, liu.se)
define(RELAY_HOST, asterix)
define(RELAY_MAILER, UUCP-B)
define(PSEUDONYMS, obelix.UUCP obelix.liu.se obelix.liu obelix.ida.liu.se)
define(UUCPNODES, /usr/lib/uucp/L.sys)
include(Sendmail.mc)
