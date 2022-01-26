#	General configuration file for newaliases program
#
#	Check that the DOMAINTABLE definition agrees with your site's setup.
#	Note that ALIASES never, never, never should be set to a YP map here.
#
define(ALIASES, LIBDIR/aliases)dnl
define(DOMAINTABLE, %mail.domaintable)dnl
define(NEWALIASES)dnl
include(Sendmail.mc)dnl
